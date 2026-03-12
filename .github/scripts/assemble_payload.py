#!/usr/bin/env python3
"""
assemble_payload.py
Gathers PR diff, context, RuboCop results, and guidelines into llm_payload.json.
Environment variables (set by the Actions workflow):
    BASE_SHA, HEAD_SHA, REPO, PR_NUMBER, PR_TITLE, PR_BODY
    LLM_IGNORE_PATHS, LLM_CONTEXT_LINES
"""

import json
import os
import pathlib
import re
import subprocess
import sys

# ── Configuration ─────────────────────────────────────────────────────────────
IGNORE_PATTERNS = os.environ.get(
    "LLM_IGNORE_PATHS",
    "vendor/,node_modules/,*.lock,db/schema.rb,*.min.js,generated/"
).split(",")

CONTEXT_LINES   = int(os.environ.get("LLM_CONTEXT_LINES", "5"))
BASE_SHA        = os.environ["BASE_SHA"]
HEAD_SHA        = os.environ["HEAD_SHA"]
REPO            = os.environ.get("REPO", "")
PR_TITLE        = os.environ.get("PR_TITLE", "")
PR_BODY         = os.environ.get("PR_BODY", "")[:1000]    # cap description length
MAX_PAYLOAD_CHARS = 600_000   # ~180k tokens — hard ceiling before chunking

# Language detection by file extension
LANG_MAP = {
    ".rb": "Ruby", ".rake": "Ruby", ".gemspec": "Ruby",
    ".js": "JavaScript", ".jsx": "JavaScript",
    ".ts": "TypeScript", ".tsx": "TypeScript",
    ".py": "Python",
    ".go": "Go",
    ".java": "Java",
    ".kt": "Kotlin",
    ".cs": "C#",
    ".rs": "Rust",
    ".php": "PHP",
    ".erb": "ERB/HTML",
    ".html": "HTML", ".htm": "HTML",
    ".css": "CSS", ".scss": "SCSS",
    ".yml": "YAML", ".yaml": "YAML",
    ".json": "JSON",
    ".sh": "Shell",
    ".md": "Markdown",
    ".sql": "SQL",
}

# Paths that are considered security-sensitive (prioritised in chunking)
SECURITY_PATHS = [
    "auth", "authn", "authz", "authentication", "authorization",
    "payment", "billing", "crypto", "session", "token", "secret",
    "admin", "permission", "role", "policy",
]


def is_ignored(filepath: str) -> bool:
    """Return True if this file should be excluded from review."""
    p = filepath.lstrip("/")
    for pattern in IGNORE_PATTERNS:
        pattern = pattern.strip()
        if not pattern:
            continue
        if pattern.endswith("/") and p.startswith(pattern):
            return True
        if pattern.startswith("*.") and p.endswith(pattern[1:]):
            return True
        if p == pattern or p.startswith(pattern):
            return True
    return False


def detect_language(filepath: str) -> str:
    suffix = pathlib.Path(filepath).suffix.lower()
    return LANG_MAP.get(suffix, "Unknown")


def get_changed_files() -> list[str]:
    result = subprocess.run(
        ["git", "diff", "--name-only", f"{BASE_SHA}...{HEAD_SHA}"],
        capture_output=True, text=True, check=True,
    )
    files = [f for f in result.stdout.strip().splitlines() if f]
    return [f for f in files if not is_ignored(f)]


def get_diff(filepath: str) -> str:
    result = subprocess.run(
        ["git", "diff", f"-U{CONTEXT_LINES}", BASE_SHA, HEAD_SHA, "--", filepath],
        capture_output=True, text=True,
    )
    return result.stdout


def get_definition_context(filepath: str, diff_text: str) -> str:
    """
    Heuristic: for Ruby files, find method/class names called in the diff
    that are defined in the same file, and include their definitions.
    Returns up to 2000 chars of additional context.
    """
    if not filepath.endswith(".rb"):
        return ""
    if not pathlib.Path(filepath).exists():
        return ""

    # Extract method names referenced in changed lines (lines starting with + or -)
    changed_lines = [l[1:] for l in diff_text.splitlines()
                     if l.startswith(("+", "-")) and not l.startswith(("+++", "---"))]
    method_calls = set()
    for line in changed_lines:
        # Match simple Ruby method calls: word( or .word
        for m in re.finditer(r'(?:^|\s|\.)([a-z_][a-z0-9_]{2,})\s*(?:\(|$)', line):
            method_calls.add(m.group(1))

    if not method_calls:
        return ""

    source = pathlib.Path(filepath).read_text(errors="replace")
    snippets = []
    for method in method_calls:
        # Find method definition in source
        match = re.search(
            rf'^\s*def\s+{re.escape(method)}\b.*?(?=\n\s*def\s|\nend\s*\n\s*def\s|\Z)',
            source, re.MULTILINE | re.DOTALL
        )
        if match:
            snippet = match.group(0)[:500]  # cap per method
            snippets.append(f"# Definition of {method}:\n{snippet}")

    context = "\n\n".join(snippets[:3])  # at most 3 definitions
    return context[:2000]


# ── Secret redaction ──────────────────────────────────────────────────────────
SECRET_PATTERNS = [
    re.compile(r'(api[_-]?key|secret|password|token|auth[_-]?token|private[_-]?key|access[_-]?key)\s*[=:]\s*[\'"]([^\'"\\s]{8,})[\'"]', re.I),
    re.compile(r'(AKIA[0-9A-Z]{16})'),                                  # AWS access key
    re.compile(r'([0-9a-zA-Z/+]{40})'),                                  # generic 40-char base64 secret (conservative)
    re.compile(r'sk-[a-zA-Z0-9]{32,}'),                                  # OpenAI-style key
    re.compile(r'ghp_[a-zA-Z0-9]{36}'),                                  # GitHub PAT
    re.compile(r'-----BEGIN [A-Z ]+PRIVATE KEY-----'),                   # PEM header
]

def redact_secrets(text: str) -> str:
    for pattern in SECRET_PATTERNS:
        text = pattern.sub("[REDACTED]", text)
    return text


# ── RuboCop results ───────────────────────────────────────────────────────────
def load_rubocop(changed_files: list[str]) -> dict:
    rubocop_path = pathlib.Path("rubocop_output.json")
    if not rubocop_path.exists():
        return {}
    try:
        raw = json.loads(rubocop_path.read_text())
    except json.JSONDecodeError:
        return {}
    result = {}
    changed_set = set(changed_files)
    for file_result in raw.get("files", []):
        path = file_result.get("path", "")
        offenses = file_result.get("offenses", [])
        if offenses and path in changed_set:
            result[path] = [
                {
                    "cop":      o.get("cop_name", ""),
                    "severity": o.get("severity", ""),
                    "message":  o.get("message", ""),
                    "line":     o.get("location", {}).get("line"),
                }
                for o in offenses
            ]
    return result


# ── Guidelines ────────────────────────────────────────────────────────────────
def load_guidelines() -> str:
    for path in [".claude/CLAUDE.md", "CONTRIBUTING.md", "docs/CONTRIBUTING.md"]:
        p = pathlib.Path(path)
        if p.exists():
            return p.read_text()
    return ""


# ── Chunking ──────────────────────────────────────────────────────────────────
def is_security_sensitive(filepath: str) -> bool:
    lower = filepath.lower()
    return any(kw in lower for kw in SECURITY_PATHS)


def prioritise_files(files: list[str], diffs: dict) -> list[str]:
    """Order: security-sensitive > most hunks > alphabetical."""
    def sort_key(f):
        security = 0 if is_security_sensitive(f) else 1
        hunk_count = diffs.get(f, "").count("\n@@")
        return (security, -hunk_count, f)
    return sorted(files, key=sort_key)


def build_chunks(ordered_files: list[str], diffs: dict, rubocop: dict,
                 lang_map: dict, extra_ctx: dict, pr_meta: dict,
                 guidelines: str) -> list[dict]:
    """Split files into chunks that fit within MAX_PAYLOAD_CHARS."""
    chunks = []
    current_files = []
    current_size = 0

    base_meta = json.dumps({"pr": pr_meta, "guidelines": guidelines})
    base_size = len(base_meta)

    for f in ordered_files:
        file_entry = {
            "path":     f,
            "language": lang_map.get(f, "Unknown"),
            "diff":     diffs.get(f, ""),
            "rubocop":  rubocop.get(f, []),
            "context":  extra_ctx.get(f, ""),
        }
        entry_size = len(json.dumps(file_entry))

        if current_size + entry_size + base_size > MAX_PAYLOAD_CHARS and current_files:
            chunks.append(current_files)
            current_files = []
            current_size = 0

        current_files.append(file_entry)
        current_size += entry_size

    if current_files:
        chunks.append(current_files)

    return chunks


# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    print("Assembling review payload…")

    changed_files = get_changed_files()
    print(f"  Changed files (after ignore filter): {len(changed_files)}")
    if not changed_files:
        print("  No reviewable files changed. Writing empty payload.")
        payload = {"pr": {}, "files": [], "guidelines": "", "chunks": 1}
        pathlib.Path("llm_payload.json").write_text(json.dumps(payload))
        return

    # Collect diffs
    diffs = {}
    for f in changed_files:
        raw_diff = get_diff(f)
        if raw_diff:
            diffs[f] = redact_secrets(raw_diff)

    # Extra definition context
    extra_ctx = {}
    for f in changed_files:
        ctx = get_definition_context(f, diffs.get(f, ""))
        if ctx:
            extra_ctx[f] = ctx

    lang_map     = {f: detect_language(f) for f in changed_files}
    rubocop      = load_rubocop(changed_files)
    guidelines   = load_guidelines()

    pr_meta = {
        "repo":        REPO,
        "title":       PR_TITLE,
        "description": PR_BODY,
    }

    ordered = prioritise_files(list(diffs.keys()), diffs)
    chunks  = build_chunks(ordered, diffs, rubocop, lang_map, extra_ctx, pr_meta, guidelines)

    # Determine if we should use fallback (small diff)
    total_changed_lines = sum(
        sum(1 for l in d.splitlines() if l.startswith(("+", "-"))
            and not l.startswith(("+++", "---")))
        for d in diffs.values()
    )
    use_fallback = total_changed_lines <= int(
        os.environ.get("LLM_SMALL_DIFF_THRESHOLD", "50")
    )

    payload = {
        "pr":           pr_meta,
        "guidelines":   guidelines,
        "chunks":       len(chunks),
        "use_fallback": use_fallback,
        "files_per_chunk": [
            [f["path"] for f in chunk] for chunk in chunks
        ],
        # First chunk embedded directly; subsequent chunks in chunks_extra
        "files":        chunks[0] if chunks else [],
        "chunks_extra": chunks[1:] if len(chunks) > 1 else [],
    }

    pathlib.Path("llm_payload.json").write_text(json.dumps(payload, indent=2))
    print(f"  Chunks: {len(chunks)}  |  Total changed lines: {total_changed_lines}"
          f"  |  Use fallback model: {use_fallback}")
    print("  llm_payload.json written.")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
call_llm.py
Sends the assembled payload to the Anthropic API (with optional OpenAI fallback)
and writes the merged review result to llm_result.json.
"""

import json
import os
import pathlib
import sys
import time

# ── Configuration ─────────────────────────────────────────────────────────────
MODEL           = os.environ.get("LLM_MODEL",          "claude-sonnet-4-20250514")
FALLBACK_MODEL  = os.environ.get("LLM_FALLBACK_MODEL", "claude-haiku-4-5-20251001")
MAX_TOKENS      = int(os.environ.get("LLM_MAX_TOKENS", "4096"))
ANTHROPIC_KEY   = os.environ.get("ANTHROPIC_API_KEY", "")
OPENAI_KEY      = os.environ.get("OPENAI_API_KEY", "")

SYSTEM_PROMPT_PATH = pathlib.Path(".github/prompts/code_reviewer.txt")


def load_system_prompt() -> str:
    if SYSTEM_PROMPT_PATH.exists():
        return SYSTEM_PROMPT_PATH.read_text()
    raise FileNotFoundError(
        f"System prompt not found at {SYSTEM_PROMPT_PATH}. "
        "Create .github/prompts/code_reviewer.txt — see design document Section 4."
    )


def build_user_message(pr_meta: dict, files: list, guidelines: str) -> str:
    payload = {
        "pr":         pr_meta,
        "guidelines": guidelines,
        "files":      files,
    }
    return (
        "<review_request>\n"
        + json.dumps(payload, indent=2)
        + "\n</review_request>\n\n"
        "Respond with ONLY the JSON object described in your instructions. "
        "No preamble, no markdown fences."
    )


def call_anthropic(model: str, system: str, user_msg: str, retries: int = 3) -> str:
    """Call Anthropic Messages API. Returns raw text response."""
    try:
        import anthropic
    except ImportError:
        sys.exit("anthropic package not installed. Run: pip install anthropic")

    client = anthropic.Anthropic(api_key=ANTHROPIC_KEY)

    for attempt in range(1, retries + 1):
        try:
            response = client.messages.create(
                model=model,
                max_tokens=MAX_TOKENS,
                system=system,
                messages=[{"role": "user", "content": user_msg}],
            )
            return response.content[0].text.strip()
        except Exception as e:
            err_str = str(e)
            # Rate limit / overload — back off and retry
            if any(code in err_str for code in ["529", "529", "rate_limit", "overloaded"]):
                wait = 2 ** attempt
                print(f"  Anthropic rate limit (attempt {attempt}/{retries}). "
                      f"Retrying in {wait}s…")
                time.sleep(wait)
            else:
                raise
    raise RuntimeError(f"Anthropic API failed after {retries} attempts.")


def call_openai(model: str, system: str, user_msg: str) -> str:
    """OpenAI fallback."""
    try:
        import openai
    except ImportError:
        sys.exit("openai package not installed. Run: pip install openai")

    client = openai.OpenAI(api_key=OPENAI_KEY)
    response = client.chat.completions.create(
        model=model,
        max_tokens=MAX_TOKENS,
        messages=[
            {"role": "system", "content": system},
            {"role": "user",   "content": user_msg},
        ],
        response_format={"type": "json_object"},
    )
    return response.choices[0].message.content.strip()


def parse_json_response(raw: str, model: str, system: str, user_msg: str) -> dict:
    """Parse JSON, with one retry if the initial parse fails."""
    # Strip accidental markdown code fences
    cleaned = raw
    if cleaned.startswith("```"):
        lines = cleaned.splitlines()
        cleaned = "\n".join(lines[1:-1] if lines[-1].strip() == "```" else lines[1:])

    try:
        return json.loads(cleaned)
    except json.JSONDecodeError:
        print("  JSON parse failed on first attempt. Retrying with explicit reminder…")
        # Retry: append the bad response and ask again
        try:
            import anthropic
            client = anthropic.Anthropic(api_key=ANTHROPIC_KEY)
            response = client.messages.create(
                model=model,
                max_tokens=MAX_TOKENS,
                system=system,
                messages=[
                    {"role": "user",      "content": user_msg},
                    {"role": "assistant", "content": raw},
                    {"role": "user",      "content":
                        "Your previous response was not valid JSON. "
                        "Return ONLY the JSON object — no preamble, no markdown, "
                        "no explanation."},
                ],
            )
            return json.loads(response.content[0].text.strip())
        except Exception:
            pass
    raise ValueError("Could not parse a valid JSON response from the model.")


def merge_chunk_results(results: list[dict]) -> dict:
    """Merge multiple per-chunk results into a single result object."""
    if len(results) == 1:
        return results[0]

    all_comments = []
    total_files  = 0
    seen         = set()

    for r in results:
        total_files += r.get("stats", {}).get("files_reviewed", 0)
        for c in r.get("comments", []):
            key = (c.get("file"), c.get("line"), c.get("title"))
            if key not in seen:
                seen.add(key)
                all_comments.append(c)

    # Aggregate verdict: changes_requested wins
    verdicts = [r.get("verdict", "pass") for r in results]
    verdict  = "changes_requested" if "changes_requested" in verdicts else "pass"

    # Average confidence
    confidences = [r.get("confidence", 0.5) for r in results]
    confidence  = round(sum(confidences) / len(confidences), 2)

    # Combine summaries
    summaries = [r.get("summary", "") for r in results if r.get("summary")]
    summary   = " | ".join(summaries)[:400]

    return {
        "verdict":    verdict,
        "confidence": confidence,
        "summary":    summary,
        "comments":   all_comments,
        "stats": {
            "files_reviewed": total_files,
            "issues_found":   len(all_comments),
        },
    }


# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    payload_path = pathlib.Path("llm_payload.json")
    if not payload_path.exists():
        sys.exit("llm_payload.json not found. Run assemble_payload.py first.")

    payload = json.loads(payload_path.read_text())
    system  = load_system_prompt()

    pr_meta    = payload.get("pr", {})
    guidelines = payload.get("guidelines", "")
    n_chunks   = payload.get("chunks", 1)
    use_fallback = payload.get("use_fallback", False)

    # Select model
    active_model = FALLBACK_MODEL if use_fallback else MODEL
    print(f"Model: {active_model} (use_fallback={use_fallback})  |  Chunks: {n_chunks}")

    # Build list of chunks: first chunk + any extras
    all_chunks = [payload.get("files", [])] + payload.get("chunks_extra", [])

    chunk_results = []
    for i, files in enumerate(all_chunks, 1):
        if not files:
            continue
        print(f"  Reviewing chunk {i}/{n_chunks} ({len(files)} file(s))…")
        user_msg = build_user_message(pr_meta, files, guidelines)

        raw_text = None
        try:
            raw_text = call_anthropic(active_model, system, user_msg)
        except Exception as anthropic_err:
            print(f"  Anthropic error: {anthropic_err}")
            if OPENAI_KEY:
                print("  Falling back to OpenAI gpt-4o…")
                try:
                    raw_text = call_openai("gpt-4o", system, user_msg)
                except Exception as openai_err:
                    print(f"  OpenAI fallback also failed: {openai_err}")
            if raw_text is None:
                # Write a safe failure result and exit non-zero so verdict can be set
                pathlib.Path("llm_result.json").write_text(json.dumps({
                    "verdict":    "pass",
                    "confidence": 0.0,
                    "summary":    "LLM review could not be completed due to an API error.",
                    "comments":   [],
                    "stats":      {"files_reviewed": 0, "issues_found": 0},
                    "_error":     str(anthropic_err),
                }))
                sys.exit(1)

        result = parse_json_response(raw_text, active_model, system, user_msg)
        chunk_results.append(result)
        print(f"    Chunk {i} verdict: {result.get('verdict')}  |  "
              f"Issues: {result.get('stats', {}).get('issues_found', '?')}")

    if not chunk_results:
        chunk_results = [{
            "verdict":    "pass",
            "confidence": 1.0,
            "summary":    "No reviewable files in this PR.",
            "comments":   [],
            "stats":      {"files_reviewed": 0, "issues_found": 0},
        }]

    merged = merge_chunk_results(chunk_results)
    pathlib.Path("llm_result.json").write_text(json.dumps(merged, indent=2))
    print(f"\nFinal verdict: {merged['verdict']}  |  "
          f"Issues: {merged['stats']['issues_found']}  |  "
          f"Confidence: {int(merged.get('confidence', 0) * 100)}%")


if __name__ == "__main__":
    main()

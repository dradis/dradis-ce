#!/usr/bin/env python3
"""
set_verdict.py
Creates or updates the GitHub Check Run for this workflow with the
final pass/failure verdict from llm_result.json.
"""

import json
import os
import pathlib
import sys
from datetime import datetime, timezone

import requests

# ── Configuration ─────────────────────────────────────────────────────────────
GH_TOKEN      = os.environ["GH_TOKEN"]
REPO          = os.environ["REPO"]
HEAD_SHA      = os.environ["HEAD_SHA"]
BYPASS        = os.environ.get("BYPASS", "false").lower() == "true"
LLM_STEP      = os.environ.get("LLM_STEP", "success")  # success | failure | skipped
FAIL_SEVERITY = os.environ.get("LLM_FAIL_SEVERITY", "major")

SEVERITY_ORDER = ["nit", "minor", "major", "critical"]

GH_API  = "https://api.github.com"
HEADERS = {
    "Authorization":        f"Bearer {GH_TOKEN}",
    "Accept":               "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28",
}

CHECK_NAME = "LLM Code Review"


def threshold_index() -> int:
    try:
        return SEVERITY_ORDER.index(FAIL_SEVERITY)
    except ValueError:
        return SEVERITY_ORDER.index("major")


def determine_conclusion(result: dict | None) -> tuple[str, str]:
    """
    Returns (conclusion, summary_text) where conclusion is one of:
        success | failure | neutral
    """
    # Bypass label present — always neutral (allows merge)
    if BYPASS:
        return "neutral", (
            "Bypass label detected (`override/llm`). "
            "Check marked as neutral — merge is permitted."
        )

    # LLM step itself failed (API error, script crash)
    if LLM_STEP != "success" or result is None:
        return "neutral", (
            "LLM review could not complete (API or script error). "
            "Check marked neutral — review manually."
        )

    comments  = result.get("comments", [])
    verdict   = result.get("verdict", "pass")
    idx       = threshold_index()

    blocking = any(
        SEVERITY_ORDER.index(c.get("severity", "nit")) >= idx
        for c in comments
    )

    if verdict == "changes_requested" and blocking:
        issues = sum(
            1 for c in comments
            if SEVERITY_ORDER.index(c.get("severity", "nit")) >= idx
        )
        return "failure", (
            f"{issues} issue(s) at or above threshold "
            f"(`LLM_FAIL_SEVERITY={FAIL_SEVERITY}`). "
            "Review the LLM comments and address them, or add the "
            "`override/llm` label to bypass."
        )

    return "success", (
        f"No blocking issues found. "
        f"Verdict: {verdict}  |  "
        f"Issues: {result.get('stats', {}).get('issues_found', 0)}"
    )


def find_existing_check_run() -> int | None:
    """Return the ID of an existing check run for this SHA, or None."""
    url  = f"{GH_API}/repos/{REPO}/commits/{HEAD_SHA}/check-runs"
    resp = requests.get(url, headers=HEADERS, params={"check_name": CHECK_NAME})
    if not resp.ok:
        return None
    runs = resp.json().get("check_runs", [])
    return runs[0]["id"] if runs else None


def create_or_update_check_run(conclusion: str, summary: str, result: dict | None):
    now = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

    # Build output details
    text_lines = []
    if result:
        for c in result.get("comments", []):
            sev  = c.get("severity", "nit")
            file = c.get("file", "")
            line = c.get("line", "")
            loc  = f"{file}:{line}" if line else file
            text_lines.append(f"- **[{sev.upper()}]** {c.get('title','')} — `{loc}`")

    output = {
        "title":   CHECK_NAME,
        "summary": summary,
        "text":    "\n".join(text_lines) if text_lines else "No issues flagged.",
    }

    body = {
        "name":         CHECK_NAME,
        "head_sha":     HEAD_SHA,
        "status":       "completed",
        "conclusion":   conclusion,
        "completed_at": now,
        "output":       output,
    }

    existing_id = find_existing_check_run()

    if existing_id:
        url  = f"{GH_API}/repos/{REPO}/check-runs/{existing_id}"
        resp = requests.patch(url, headers=HEADERS, json=body)
    else:
        url  = f"{GH_API}/repos/{REPO}/check-runs"
        resp = requests.post(url, headers=HEADERS, json=body)

    if not resp.ok:
        print(f"  Check run API error {resp.status_code}: {resp.text[:300]}")
        # Non-fatal — PR review comment was already posted
    else:
        print(f"  Check run '{conclusion}': {resp.json().get('html_url', '')}")


def main():
    result = None
    result_path = pathlib.Path("llm_result.json")
    if result_path.exists():
        try:
            result = json.loads(result_path.read_text())
        except json.JSONDecodeError:
            print("  Warning: llm_result.json is malformed; treating as API error.")

    conclusion, summary = determine_conclusion(result)
    print(f"  Setting check run conclusion: {conclusion}")
    create_or_update_check_run(conclusion, summary, result)

    # Exit non-zero when failing so the workflow step itself is marked failed
    if conclusion == "failure":
        sys.exit(1)


if __name__ == "__main__":
    main()

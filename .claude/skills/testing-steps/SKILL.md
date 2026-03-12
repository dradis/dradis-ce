---
name: testing-steps
description: Generate acceptance testing steps after completing a feature or bug fix. Use when the user asks for testing steps, a testing plan, or how to test something.
---

Based on the work done in this conversation, generate an acceptance testing plan for the Support / Customer Success team.

The plan must follow this exact format:

**How To Test**

A numbered list of steps where each step is either:
- An **action**: what the tester does (e.g. "Navigate to...", "Login as...", "Create a...", "Edit a...", "Delete a...", "Click on...")
- An **assertion**: what the tester verifies (e.g. "Assert the record was deleted", "Assert the error message appeared", "Assert the flash message reads...")

Rules:
- Begin with any prerequisite steps (login, seed data, navigation to starting point)
- Cover the happy path first, then edge cases and error states
- Every action that changes state should be followed by an assertion
- For API-related features include a curl example step with the expected response
- Steps must be specific enough for someone unfamiliar with the codebase to follow in a browser — no ambiguity
- Do not add explanations or commentary outside the numbered list

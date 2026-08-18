---
description: Saves session state to docs/handoff.md to resume cheaply after /clear
---

Write/overwrite `docs/handoff.md`, MAX 30 lines:

```
# Handoff <date>
Task: 1 sentence.
Done: bullets (only what matters to continue).
Next step: actionable bullets, in order.
Hot files: path — why it matters (1 line each).
Pitfalls: what was tried and failed / decisions made and why.
Active plan: docs/plans/NNN (if any).
```

No conversation history, no pasted code. Only what the next session needs to rediscover nothing.
At the end: confirm saved and suggest `/clear`. Next session: "read docs/handoff.md" is far cheaper than inheriting a bloated context.

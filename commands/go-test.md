---
description: Runs the suite via the go-tester agent and triages failures cheaply
argument-hint: [package or -race or -cover]
---

Delegate to the **go-tester** agent: "$ARGUMENTS" (empty => `./...`).
Relay the report. On failures in autopilot mode: ask once whether to fix; yes => go-implementer with the diagnosis.

---
name: build-journal
description: Activate Build Journal tracking for this session
---

Activate Build Journal tracking for this session.

1. Confirm: "Build Journal tracking is on for this session."
2. Ask the user: "Want the end-of-session interview when we wrap up?" (Yes / No)
3. Begin watching for wrap-up signals to trigger the build-journal skill.

If the user declines the interview, still watch for wrap-up signals but skip the interview step when the skill fires.

Wrap-up signals include: "closing out", "done for the day", "wrapping up", "project is done", "pausing work", "picking this up tomorrow", "stopping for now", "session complete".

When a wrap-up signal is detected, invoke the build-journal skill to generate the retrospective.

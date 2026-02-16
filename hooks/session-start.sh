#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Build Journal plugin is active. At the START of this session, before doing any other work, ask the user these two questions using the AskUserQuestion tool (in a single call with both questions):\n\n1. 'Want Build Journal tracking this session?' (Yes / No)\n2. 'Want the end-of-session interview when we wrap up?' (Yes / No)\n\nIf the user declines tracking, do NOT mention Build Journal again this session.\n\nIf the user accepts tracking, watch for session-closing signals throughout the conversation:\n- Full retrospective triggers: 'closing out', 'project is done', 'wrapping up the build', 'session complete'\n- Daily recap triggers: 'done for the day', 'pausing work', 'picking this up tomorrow', 'stopping for now'\n\nWhen you detect these signals, invoke the build-journal skill."
  }
}
EOF

exit 0

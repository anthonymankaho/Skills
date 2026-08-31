---
tags: [skill, builtin, artifact, runtime]
---

# Skill: Artifact Capabilities

Runtime capabilities a published Artifact page can be granted beyond static HTML: reading live/connected data, remembering what people do on it (polls, sign-up sheets, checklists, self-editing documents), keeping state shared across viewers, knowing who is viewing, asking Claude a question of its own, storing files people add, or handing the viewer a file to save. Load whenever the user asks for an artifact that needs any such runtime behavior — required before declaring any `capabilities` option or writing `window.claude.*` code.

## Full detail
Built into Claude Code — no separate SKILL.md on disk; invoked via the `artifact-capabilities` skill name.

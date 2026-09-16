---
name: meeting-updates
description: Turns a pile of work info into short, concrete, agenda-ready meeting updates. Uses the user's notes when given, fills gaps from Claude Code session transcripts, git history, and any connected tools, and asks a few quick questions when there is nothing to go on. Use when the user asks for meeting updates, a standup, a status update, or "what did I do this week".
argument-hint: "[window, e.g. 3d, 2w, 2026-09-01] [your notes]"
---

# Meeting Updates

The job is formatting: turn whatever information exists into short, concrete updates the user can bring to a meeting. Gathering information only supports that job.

## 1. Read the arguments

- **Window:** a leading `Nd`, `Nw`, or date. Default 7 days.
- **Notes:** all other argument text. Notes are the main source and override anything else.

## 2. Inform (always)

Notes miss things, so always check what is available, even when notes are given:

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/inform.sh" <days>
```

It lists recent Claude Code sessions (title, first prompt) and the user's own git commits, grouped by directory. Treat it as the record of what happened. Read an individual transcript only when an item is unclear.

If Jira, Confluence, or Microsoft 365 tools are connected in this session, also check them for the user's activity in the window. Skip any that are not connected; do not ask the user to set them up.

Merge the findings with the notes. Notes win on conflict. Add relevant findings the notes left out and mark them "(found, please confirm)".

## 3. Ask when it is thin

If nothing was found and there are no notes, or if for any item you cannot say what changed, where it stands, and what is next, do not guess. Ask only the questions below that are still unanswered, then stop and wait:

> Rough answers are fine:
> 1. What did you work on since the last meeting?
> 2. What is finished, and what is still in progress?
> 3. Is anything blocked, or do you need a decision or help from someone?
> 4. What is next, and by when?

## 4. Write

- Group by project or initiative, using the team's names when known. One project may span many sessions and commits.
- Drop noise: config tweaks, one-prompt sessions that went nowhere, and this skill run itself.
- A commit shows progress, not completion. Only call something done when the evidence says so.
- Never invent work, people, owners, or dates. Mark anything inferred.
- Plain language, no em dashes.

Output exactly this format:

```
## Updates: <git config user.name>, <start date> to <end date>

**For the agenda:** <items that need team discussion, a decision, or help; or "None">

### <Project or initiative>
<Summary: 1 to 3 sentences on what changed and where it stands.>
Blocker: <only if one exists>
Next step: <specific action>, <owner>, <date if known>
```

Include Blocker and Next step lines only when they exist and the summary does not already say them. End with one line listing the sources used, then ask whether anything is missing. Write the output to `./updates-<YYYY-MM-DD>.md` only if the user asks for a file.

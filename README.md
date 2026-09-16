# updates-skill

Turn a pile of work info into short, concrete updates you can bring to a meeting.

Give it your notes and it also checks your tools for anything you missed. If it finds nothing, or too little to say what changed and what is next, it asks a few quick questions and builds the updates from your answers.

| Path | For | Where it looks for your work |
| --- | --- | --- |
| [`prompt/meeting-updates.md`](prompt/meeting-updates.md) | Microsoft 365 Copilot, or any AI assistant | Teams, Outlook, SharePoint, OneDrive, Loop, Jira, Confluence: whatever the assistant can access |
| [`skills/meeting-updates/`](skills/meeting-updates/) | Claude Code | Session transcripts, git commits, and any connected Jira, Confluence, or Microsoft 365 tools |

Both produce the same format, which matches the Summary / Blocker / Next step format used by the [AI PM agent](https://github.com/cu-aaii/ai-pm-agent).

## Using the prompt

1. Open [`prompt/meeting-updates.md`](prompt/meeting-updates.md) and copy everything below the line.
2. Paste it into Copilot. Use Copilot with work data turned on (the "Work" tab) so it can read your Microsoft 365 content.
3. Optionally, add your notes at the bottom.
4. Review the result, then share it.

## Using the Claude Code skill

Install it for your user account:

```bash
git clone git@github.com:cu-aaii/updates-skill.git
mkdir -p ~/.claude/skills
cp -r updates-skill/skills/meeting-updates ~/.claude/skills/
```

Then, in Claude Code:

```
/meeting-updates
/meeting-updates 3d
/meeting-updates finished the intake form, waiting on legal review of the vendor terms
```

A leading window (`3d`, `2w`, or a date) is optional; the default is 7 days. Everything else is treated as your notes. Notes win over anything the skill finds; findings your notes left out are marked for you to confirm.

Requirements: `jq` and `git`.

The skill runs [`scripts/inform.sh`](skills/meeting-updates/scripts/inform.sh) to list recent sessions and commits. You can run the script on its own to see what it finds:

```bash
bash skills/meeting-updates/scripts/inform.sh 7
```

## Output

```
## Updates: Jane Doe, 2026-09-09 to 2026-09-16

**For the agenda:** Vendor terms need legal review before launch.

### Intake form
Built and tested the new intake form; it is ready to launch once the vendor terms are approved.
Blocker: Vendor terms are waiting on legal review.
Next step: Send the terms to legal, Jane, by 2026-09-18.

Sources: my notes, Claude Code sessions, git commits in 1 repo
```

## Roadmap

- Send updates automatically when the skill runs.

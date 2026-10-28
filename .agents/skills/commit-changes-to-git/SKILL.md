---
name: commit-changes-to-git
description: |
  Use this skill when the user wants to commit changes
  in the working tree of the current Git repository.
---

## Scope

Operate on Git repository in current working directory.
Refuse to bundle unrelated changes into one commit.

## Boundaries

Commit files untouched, never reformatting, linting, testing, or building.
Honor hooks and signing unless user asked to bypass them.
Land one local commit, never amending, rebasing, force-pushing, or pushing.

## Staging

Stage only paths user named, or everything when user said so.
Refuse to stage secrets.
Warn user about skipped secrets instead.

## Message

Respect Conventional Commits standard.
Prepend ticket number to description with `#` when user named issue.
Derive message from diff and conversation, never from branch name.

## Format

Shape commit as `type: summary` subject, then optional body.

## Review

List staged files for user before committing.
Show commit subject to user before committing.

## Pre-Commit Verification
Check diff budget: `git diff --cached --stat | tail -n 1`.
If total changed lines (insertions + deletions) exceed 100:
- ABORT commit immediately.
- Refuse to execute `git commit`.
- Ask user for task decomposition or unstage changes down to <=100 lines.

## Authorship

Limit message to its description.
Skip `Co-authored-by:` trailers, promotional lines, signatures, and emoji.
Preserve configured author and committer identity.

## Example

User fixes typo in `README.md` and says "commit it".
Stage `README.md` alone.
Write subject `docs: fix typo in README`.
Land one commit carrying that subject.

## Done

Confirm one new commit appears after run.
Stop after single commit lands.

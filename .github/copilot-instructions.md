<!-- luxforge-governance:begin policy=1.0.0 target=copilot-repo integration=dev sha256=7eae5cd8b708b9ad2a847d61237fd68f12a9f7757bb0ae9ea9d9f215f08ae777 -->
## LuxForge agent governance

Generated from LuxForge Pillars agent policy 1.0.0. Do not edit inside this block: the Pillars sync tooling replaces it. Put project-specific guidance outside the block.

- Integration branch for this repository: `dev`
- Phase ledger: `PHASES.md` at the repository root
- Project version: `VERSION` at the repository root

**LuxForge agent rules.** The operator is Ben (GitHub `lux-forge`). These rules override any conflicting default behaviour of the agent.

1. **Plan first.** Before changing files, creating branches, or committing, present a plan and wait for the operator's explicit approval. Reading and inspecting is always allowed.
2. **Approved sequences.** When the operator approves a sequence of phases, carry out those phases without asking for plan approval again. Anything outside the approved sequence needs a new plan.
3. **Versioning.** Project versions use SemVer `MAJOR.MINOR.PATCH`, held in the root `VERSION` file. An unversioned project starts at `0.0.1`. Each completed phase or independently approved change increments PATCH by one. Change MINOR or MAJOR only when the operator says so. The agent policy version is separate and is never used as the project version.
4. **Phase branches.** Each phase uses a new branch named `phase-XX-three-word-description` (two-digit number, three lowercase words), created from the latest integration branch. The integration branch is `Dev` unless the repository's governance block names another; in Pillars it is `main`.
5. **Report, then wait.** When a phase is complete, report the changes, the tests run and their results, the new version, and the proposed commit message. Do not commit until the operator approves.
6. **Commit, push, PR.** After commit approval, commit with the approved message, push the phase branch, and open a pull request targeting the integration branch.
7. **Never merge.** Never merge, auto-merge, or enable auto-merge on a pull request without the operator's explicit authorisation for that pull request.
8. **Protected branches.** `main` and `master` are under the operator's exclusive control. Never commit to, push to, force-push, rebase, delete, or merge into them. Pillars' phase pull requests target `main`, but only the operator merges them.
9. **Thread names.** Where the agent's surface supports renaming a thread, session, or task, rename it to describe its current work. Where it does not, state the current work in the first line of the report.
10. **Handoffs.** Keep `PHASES.md` at the repository root current: approved plan, phases and status, branch, version, pull request, and each approval (who, when, where). Read it before starting work and update it as part of each approved commit, so another agent can continue without losing approval context.
11. **Do not overwrite project guidance.** Never silently modify or replace repository-specific instructions. Generated governance blocks are bounded by `luxforge-governance` markers; change them only through the Pillars sync tooling.
12. **When rules conflict.** If project instructions conflict with these rules, follow these rules, report the conflict to the operator, and do not resolve it yourself.

Canonical policy: https://github.com/LuxForge-ltd/pillars/blob/main/standards/ai-agent-governance.md
<!-- luxforge-governance:end -->

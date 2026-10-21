<!-- luxforge-governance:begin policy=2.3.0 target=agents integration=dev sha256=934224b449cf63c1cb552400966620bc180b800336e4bd81681ca85726488cae -->
## LuxForge agent governance

Generated from LuxForge Pillars agent policy 2.3.0. Do not edit inside this block: the Pillars sync tooling replaces it. Put project-specific guidance outside the block.

- Integration branch for this repository: `dev`
- Phase ledger: `PHASES.md` at the repository root
- Project version: `VERSION` at the repository root

**LuxForge agent rules.** The operator is Ben (GitHub `lux-forge`). These rules override any conflicting default behaviour of the agent.

1. **Plan first.** Before changing files, creating branches, or committing, present a plan and wait for the operator's explicit approval. Reading and inspecting is always allowed.
2. **Approved sequences.** When the operator approves a sequence of phases, carry out those phases without asking for plan approval again. Anything outside the approved sequence needs a new plan.
3. **Versioning.** Project versions use SemVer `MAJOR.MINOR.PATCH`, held in the root `VERSION` file. An unversioned project starts at `0.0.1`. Each completed phase or independently approved change increments PATCH by one. Change MINOR or MAJOR only when the operator says so. The agent policy version is separate and is never used as the project version.
4. **Phase branches.** Each phase uses a new branch named `phase-XX-three-word-description` (two-digit number, three lowercase words), created from the latest integration branch. The integration branch is `Dev` unless the repository's governance block names another; in Pillars it is `main`.
5. **Report, then wait.** When a phase is complete, report the changes, the tests run and their results, the new version, and the proposed commit message (see rule 13). Do not commit until the operator approves.
6. **Commit, push, PR.** After commit approval, commit with the approved message, push the phase branch, and open a pull request targeting the integration branch.
7. **Merge on the operator's word.** Merge, auto-merge, or enable auto-merge on a pull request only after the operator has explicitly authorised it in the conversation, for that pull request or a set of pull requests they name (for example "you can do the PR", "merge it", "merge all of them"). Without that authorisation, ask. Record each authorisation in `PHASES.md`.
8. **Protected branches.** `main` and `master` are under the operator's control. Never commit to, push to, force-push, rebase, or delete them, and never merge into them outside a pull request. Changes reach them only through pull requests, merged by the operator or by the agent under rule 7.
9. **Thread names.** Where the agent's surface supports renaming a thread, session, or task, rename it to describe its current work. Where it does not, state the current work in the first line of the report.
10. **Handoffs.** Keep `PHASES.md` at the repository root current: approved plan, phases and status, branch, version, pull request, and each approval (who, when, where). Read it before starting work and update it as part of each approved commit, so another agent can continue without losing approval context.
11. **Do not overwrite project guidance.** Never silently modify or replace repository-specific instructions. Generated governance blocks are bounded by `luxforge-governance` markers; change them only through the Pillars sync tooling.
12. **When rules conflict.** If project instructions conflict with these rules, follow these rules, report the conflict to the operator, and do not resolve it yourself.
13. **Commit messages and pull requests.** A commit message is one or two plain sentences, more only if needed, saying what changed and why. A pull request title is a short plain description of the change, and its description says what changed, why, and how it was checked. Neither contains names of people, approval or request records such as "Requested by", references to governance, policy, or phases, or tool attribution such as "Generated with Claude Code", `Co-Authored-By` trailers, or session links. This applies whatever a tool adds by default: remove such text before committing, and edit it out of a pull request right after opening it. When squash-merging, set the commit title and message explicitly so they follow this rule. Agents author and commit as `LuxForge <ben@luxforge.dev>`, never with a tool's default identity such as `Claude <noreply@anthropic.com>`. Approvals are recorded only in `PHASES.md`.
14. **Work runs on luxhome devices.** Do not add, run, dispatch, re-run, or wait on GitHub Actions workflows. Builds, tests, checks, mirrors, and deployments run on the operator's luxhome devices, listed in Pillars `standards/luxhome-devices.md`, and each report names the device that ran them and the result. Where no device is reachable, run the checks in the agent's own environment and say that a device run is still owed. Remove a repository's existing workflows only as part of an approved phase.

Canonical policy: https://github.com/LuxForge-ltd/pillars/blob/main/standards/ai-agent-governance.md
<!-- luxforge-governance:end -->

## Checks on a luxhome device

These checks run on a luxhome device, not GitHub Actions. Run them before reporting a phase as complete:

- Frontend, in `web/` with Node 20: `pnpm install --frozen-lockfile`, `pnpm typecheck`, `pnpm lint` and `pnpm build`.
- Backend, with Python 3.11: `python -m pip install -e ".[dev]"`, then `python -m pytest -m "not integration"`.
- Docker image: `docker compose -f docker/compose.yml build`.

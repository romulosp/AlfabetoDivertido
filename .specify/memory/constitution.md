<!--
Sync Impact Report

Version change: 0.1.0 -> 1.0.0
Authorization: project owner requested correction of all analysis findings on 2026-10-04.
Modified principles: Library-First (single-file packaging clarified);
Integration Coverage (mandatory local automation; CI required when configured).
Modified sections: Development Workflow; Governance.
Removed sections: duplicate unfilled constitution scaffold after the ratified document.
Migration: retain test-first; record local test command, environment, artifact version/hash,
and approving reviewer; run the same critical suite in CI when CI is configured.
Bump rationale: MAJOR because the unconditional CI/amendment process is redefined
for a local project without Git/CI. This is an explicit amendment, not a waiver.
Template impact: no template or command source changed; they read this constitution at runtime.
Deferred placeholders/TODOs: none
-->

# 1-infantil-alfabetizacao Constitution

## Core Principles

### Library-First
All reusable logic MUST be authored as small, well-documented logical units that can be
tested independently. A logical unit MAY be a pure function inside the single HTML
explicitly requested for this project; separate runtime files are not required.
If a reusable library is actually exposed to developers, it MUST include its contract
and examples. Rationale: testable rules do not require changing the delivery format.

### CLI Contract
Every tool or library exposed to developers MUST provide a predictable IO
contract: CLI arguments and stdin for input, stdout for standard output, and
stderr for errors. Tools SHOULD support a machine-readable JSON mode for
automation. Rationale: predictable IO simplifies automation, CI validation,
and reproducible debugging.

### Test-First (NON-NEGOTIABLE)
Unit tests and at least one integration test for new features MUST be written
before implementation. Tests are the primary specification for behavior; all
changes MUST include passing tests. Rationale: ensures stability for learning
focused experiences where regressions reduce pedagogical value.

### Integration Coverage
Changes that affect public contracts, data formats, or game flow MUST include
integration tests that exercise end-to-end scenarios. Critical behaviors MUST pass
reproducible automated tests locally before delivery, whether Git or CI exists or not.
The record MUST identify the test command, environment, artifact version/hash and result.
When repository CI is configured, the same critical suite MUST also pass in CI before
merge or delivery through that repository. Local-only delivery does not require creating
a repository or remote pipeline. Rationale: mandatory execution applies immediately;
the execution venue matches the project's available workflow.

### Observability & Versioning
All runtime processes SHOULD emit structured logs and meaningful errors. The
project MUST follow semantic versioning for public interfaces: MAJOR for
breaking changes, MINOR for additive changes, PATCH for fixes. Rationale:
clear upgrade paths and easier compatibility management.

## Constraints & Standards

Technology and quality constraints:

- Language: Use Python or the project's primary language consistently.
- Accessibility: UI and content MUST follow basic accessibility practices for
  children’s interfaces (readable fonts, clear contrasts, simple navigation).
- Performance: Target devices are low-powered tablets; prefer lightweight
  assets and simple animations.

## Development Workflow

Processes and review requirements:

- Code review: Every change MUST have at least one approving reviewer.
- Validation gates: Local delivery MUST pass unit and integration tests before acceptance.
  A configured repository CI MUST run the critical suite, and pull requests in that
  repository MUST pass unit and integration tests before merge.
- Documentation: New features MUST include a short README and developer
  example demonstrating intended use.

## Governance

Amendments MUST state the change, rationale, migration steps and version impact, and
receive explicit approval from the project owner or a maintainer. In a Git/PR workflow,
record the proposal and approval in a PR. In the current local workflow without Git,
an explicit owner instruction authorizes the documented amendment; record it in the
Sync Impact Report and retain the amendment in the versioned constitution text.

Version policy: Bump `CONSTITUTION_VERSION` according to semantic rules:

- MAJOR: Backward-incompatible governance removals or redefinitions.
- MINOR: Addition of new principle or substantive expansion.
- PATCH: Clarifications, wording, or typo fixes.

Compliance: Authors MUST demonstrate the applicable gates in the local validation
record and, when used, the PR/CI record. Review approval MUST identify at least one
approving reviewer; a record of test execution alone is not review approval.

**Version**: 1.0.0 | **Ratified**: 2026-10-04 | **Last Amended**: 2026-10-04

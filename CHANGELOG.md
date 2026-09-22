# Changelog

Notable VERA-specific changes are documented here.

The repository's earlier Git history is preserved for technical lineage and license transparency. This changelog begins with VERA development work rather than reproducing the full history of the underlying reference implementation.

## [Unreleased]

### Added

- VERA product identity and terminology.
- Evidence-centered, human-in-the-loop workflow documentation.
- Reproducible local development baseline for frontend, backend, MySQL, CDK, and the Python review agent.
- `scripts/verify-local.sh` for local project verification.
- VERA development roadmap covering structured extraction, deterministic validation, SQL-backed checks, AI evaluation, security, observability, and pilot readiness.

### Changed

- Updated project documentation to describe Review Standards, Criteria, Assessments, Evidence, and Reviewer Decisions.
- Updated repository deployment defaults and project metadata to use VERA naming.
- Clarified that final decisions remain with human reviewers.
- Refocused planned document processing around selective AI use, deterministic validation, and traceable evidence.

### Fixed

- Backend TypeScript lint configuration now parses test files correctly.
- Corrected a backend regular-expression lint error found during local baseline verification.

## [0.1.0] - 2026-09-22

### Added

- Established the first verified VERA local-development baseline.
- Verified local MySQL connectivity and applied all tracked Prisma migrations.
- Verified backend formatting, lint, tests, TypeScript build, and health endpoint.
- Verified frontend formatting and production build.
- Verified CDK tests and TypeScript build.
- Verified the Python review-agent local test subset.

### Known Issues

- Frontend ESLint configuration still requires repair before it can be used as a reliable project gate.
- Current npm audit findings require exploitability review and controlled dependency updates.
- Full AWS document-processing and human-review workflows have not yet been validated end to end.

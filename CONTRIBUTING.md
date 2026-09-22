# Contributing to VERA

Thanks for your interest in contributing to VERA.

VERA is under active development. Contributions should be focused, testable, and consistent with the project's human-in-the-loop design.

## Reporting Bugs and Feature Requests

Use the GitHub issue tracker to report bugs or suggest features.

Please include:

- a clear description of the issue or request
- steps to reproduce the behavior when applicable
- the environment or package involved
- relevant logs or screenshots with secrets removed
- the expected behavior

Do not include credentials, private documents, authentication tokens, AWS account information, or other sensitive data in an issue.

## Pull Requests

Before opening a pull request:

1. Work from the latest `main` branch.
2. Keep the change focused on one problem or feature.
3. Run the relevant tests, formatting, and builds.
4. Update documentation when behavior or setup changes.
5. Avoid committing generated secrets, local environment files, or private documents.

### Project Verification

For broad changes, run:

```bash
./scripts/verify-local.sh
```

Package-specific checks may also be required:

```bash
cd backend && npm run format && npm test && npm run build
cd frontend && npm run format && npm run build
cd cdk && npm test -- --runInBand && npm run build
cd review-item-processor && uv run pytest
```

Some tests depend on deployed AWS resources and may be skipped locally.

## Engineering Principles

Contributions should preserve these project principles:

- final decisions remain with human reviewers
- AI-generated analysis should be distinguishable from deterministic validation and human decisions
- evidence and source references should be traceable
- uploaded documents should be treated as untrusted input
- authorization boundaries should be explicit and testable
- sensitive information should not be written to logs
- AWS changes should be reviewed for cost and least-privilege access

## Security Issues

Do not publish sensitive vulnerability details in a public issue.

If you identify a security problem, open a minimal issue stating that a security concern exists without including exploit details or sensitive information. Coordinate further disclosure privately with the repository owner.

## License

By contributing, you agree that your contribution may be distributed under the terms in the repository's [`LICENSE`](LICENSE) file.

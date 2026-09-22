# Sprint 1 Report — Reproducible Local Development

## Result

The local RAPID development stack is installed and its build, test, database,
and runtime paths have been verified on Apple Silicon with Node.js 22.

## Environment

| Component | Verified version or state |
| --- | --- |
| Node.js | 22.23.2 |
| npm | 10.9.8 |
| Python | 3.13.5 managed by `uv` for the agent environment |
| uv | 0.12.17 |
| Docker Engine | 29.6.1 |
| Docker Compose | 5.3.0 |
| MySQL | 8.0.46, running as `rapid-mysql` |

## Completed work

- Started the repository's local MySQL Compose service.
- Verified the documented `rapid_user` can connect to the `rapid` database.
- Installed backend, frontend, and CDK dependencies with `npm ci`.
- Synced review-agent dependencies with `uv sync --extra dev`.
- Generated the Prisma client and applied all twelve tracked migrations.
- Corrected the backend ESLint TypeScript project so test files can be parsed.
- Corrected one backend regular-expression lint error.
- Added `scripts/verify-local.sh` as a safe, non-destructive verification entry point.
- Expanded local-development troubleshooting for Node versions, Docker, ports,
  and Apple Silicon.

## Verification evidence

- Backend formatting: passed.
- Backend lint: passed with 34 inherited warnings and no errors.
- Backend tests: 32 passed.
- Backend TypeScript build: passed.
- Backend runtime: `GET http://127.0.0.1:3000/health` returned `{"status":"ok"}`.
- Frontend formatting: passed.
- Frontend TypeScript/Vite production build: passed.
- Frontend runtime: Vite served the application at `http://127.0.0.1:5173`.
- CDK tests: 12 passed.
- CDK TypeScript build: passed.
- Review-agent tests: 11 passed and 2 AWS-dependent tests skipped.

## Baseline findings

### Frontend lint is not yet a valid gate

The inherited frontend lint setup is internally inconsistent:

- `eslint.config.js` imports `typescript-eslint`, but that package is not declared.
- The legacy `.eslintrc.cjs` points at the solution-style `tsconfig.json`, whose
  source files live in referenced projects instead of its own `include` list.
- Running an equivalent flat configuration also exposes a large existing lint
  backlog that should not be disguised as a Sprint 1 regression.

The all-package verifier therefore runs frontend formatting and the strict
TypeScript production build, but temporarily omits frontend ESLint. Repairing
the lint policy and baselining existing findings should be tracked separately.

### Dependency audit findings

Clean locked installs reported existing npm audit findings:

| Package | Findings |
| --- | ---: |
| Backend | 19 total: 2 low, 6 moderate, 11 high |
| Frontend | 16 total: 1 low, 3 moderate, 12 high |
| CDK | 7 total: 2 low, 5 high |

No automatic audit fixes were applied because forced upgrades may introduce
breaking changes. Findings require exploitability review and controlled
dependency updates.

## Local commands

Start the database:

```bash
docker compose -f assets/local/docker-compose.yml up -d
```

Run the complete local verification workflow:

```bash
./scripts/verify-local.sh
```

Start the backend:

```bash
cd backend
export RAPID_LOCAL_DEV=true
npm run dev
```

Start the frontend in another terminal:

```bash
cd frontend
npm run dev
```

Full sign-in still requires values for a deployed Cognito User Pool in
`frontend/.env.local`, as documented in `docs/en/local-development.md`.

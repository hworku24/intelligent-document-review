# RAPID

RAPID is an AI-assisted document review application built on AWS.

It helps a reviewer turn a policy, regulation, guideline, or specification into
a structured checklist. The reviewer can then upload another document and ask
the application to assess it against that checklist.

The result is not just a Pass or Fail label. RAPID also shows the model's
reasoning, confidence, source references, and tool activity so a person can
review the evidence and make the final decision.

This repository started from the AWS sample
[Review and Assessment Powered by Intelligent Documentation](https://github.com/aws-samples/review-and-assessment-powered-by-intelligent-documentation).
We are rebuilding and adapting it in small, testable sprints rather than
treating the sample as a finished production system.

> RAPID is a decision-support tool. It does not replace legal, medical,
> compliance, engineering, or other professional judgment. A qualified person
> must make the final decision.

## What the application does

A typical review looks like this:

1. An administrator uploads a document that describes the review rules.
2. Amazon Bedrock extracts those rules into a checklist.
3. A reviewer checks and edits the generated checklist.
4. The reviewer uploads the documents they want to assess.
5. RAPID evaluates each checklist item and provides a result, confidence score,
   explanation, and source references.
6. A human reviewer accepts, overrides, or comments on the result.

The repository includes sample documents in [`examples`](./examples) so the
workflow can be tested without using private information.

## Current project status

Sprint 1 is complete. The local database, backend, frontend, infrastructure
package, and Python review agent have all been installed and verified.

Current verification results:

- Backend: 32 tests passing
- AWS CDK: 12 tests passing
- Python review agent: 11 tests passing, with 2 AWS-dependent tests skipped
- Backend, frontend, and CDK production builds passing
- Local backend health endpoint verified
- Local frontend development server verified

See [SPRINT_PLAN.md](./SPRINT_PLAN.md) for the complete roadmap and
[SPRINT_1_REPORT.md](./SPRINT_1_REPORT.md) for the detailed setup record.

## Technology overview

| Area             | Technology                                 |
| ---------------- | ------------------------------------------ |
| Frontend         | React, TypeScript, Vite, Tailwind CSS, SWR |
| Backend          | Fastify, TypeScript, Prisma                |
| Local database   | MySQL 8 in Docker                          |
| Cloud database   | Amazon Aurora MySQL Serverless v2          |
| Authentication   | Amazon Cognito                             |
| Document storage | Amazon S3                                  |
| AI processing    | Amazon Bedrock and Strands Agents          |
| Workflows        | AWS Step Functions and Amazon SQS          |
| Agent runtime    | Amazon Bedrock AgentCore                   |
| Infrastructure   | AWS CDK                                    |
| Python tooling   | Python 3.13 and uv                         |

## Repository structure

```text
.
├── backend/                 Fastify API, Prisma schema, and workflow handlers
├── frontend/                React web application
├── cdk/                     AWS infrastructure definitions
├── review-item-processor/   Python review agent
├── assets/local/            Local MySQL Docker configuration
├── examples/                English and Japanese sample documents
├── docs/                    Architecture and development documentation
├── scripts/                 Local project utilities
├── SPRINT_PLAN.md           Delivery roadmap and task checklist
└── SPRINT_1_REPORT.md       Local setup and verification record
```

There is intentionally no root `package.json`. The backend, frontend, and CDK
directories are separate TypeScript packages. The review agent is a separate
Python package managed with `uv`.

## Prerequisites

Install these tools before starting:

- Node.js 20 or later. Node.js 22 is recommended.
- npm
- Docker Desktop with Docker Compose
- Python 3.13 or later
- `uv`
- AWS CLI

The local setup can run the database and API without an AWS deployment. Full
sign-in, document storage, checklist processing, and AI review still require
AWS resources and credentials.

Check your local versions:

```bash
node --version
npm --version
docker --version
docker compose version
python3 --version
uv --version
aws --version
```

## Local setup

### 1. Start MySQL

From the repository root:

```bash
docker compose -f assets/local/docker-compose.yml up -d
```

The local database uses these development-only values:

```text
Host: localhost
Port: 3306
Database: rapid
User: rapid_user
Password: rapid_password
```

Do not reuse these credentials outside local development.

### 2. Install and prepare the backend

```bash
cd backend
npm ci
npm run prisma:generate
npm run prisma:migrate
```

Start the backend with local authentication bypass enabled:

```bash
export RAPID_LOCAL_DEV=true
npm run dev
```

The API will be available at `http://localhost:3000`.

Confirm that it is healthy:

```bash
curl http://localhost:3000/health
```

Expected response:

```json
{ "status": "ok" }
```

`RAPID_LOCAL_DEV=true` only changes backend authentication during local
development. It has no effect on deployed Lambda functions.

### 3. Install and start the frontend

Open another terminal:

```bash
cd frontend
npm ci
cp .env.example .env.local
npm run dev
```

The frontend will be available at `http://localhost:5173`.

The frontend does not have a local authentication bypass. To sign in, replace
the placeholder Cognito values in `frontend/.env.local` with values from a
deployed RAPID stack:

```text
VITE_APP_REGION=<aws-region>
VITE_APP_USER_POOL_ID=<cognito-user-pool-id>
VITE_APP_USER_POOL_CLIENT_ID=<cognito-client-id>
VITE_APP_API_ENDPOINT=http://localhost:3000
```

The file is ignored by Git. Do not commit real environment values or secrets.

### 4. Prepare the Python review agent

```bash
cd review-item-processor
uv sync --extra dev
uv run pytest
```

The review agent normally runs in Amazon Bedrock AgentCore. Local tests cover
the parts of its behavior that do not require live AWS resources.

## Verify the whole project

After dependencies are installed and MySQL is running, execute this from the
repository root:

```bash
./scripts/verify-local.sh
```

The script checks formatting, runs the available test suites, and builds each
package. It does not reset or delete the database.

The inherited frontend ESLint setup is not currently a reliable verification
gate. The issue and its impact are documented in
[SPRINT_1_REPORT.md](./SPRINT_1_REPORT.md). The strict TypeScript and Vite build
still runs as part of project verification.

## Useful commands

### Check the database container

```bash
docker compose -f assets/local/docker-compose.yml ps
```

### Stop the local database

```bash
docker compose -f assets/local/docker-compose.yml down
```

This keeps the MySQL volume and its data.

### Open Prisma Studio

```bash
cd backend
npm run prisma:studio
```

Prisma Studio will be available at `http://localhost:5555`.

### Run backend tests

```bash
cd backend
npm test
```

### Build the frontend

```bash
cd frontend
npm run build
```

### Run CDK tests

```bash
cd cdk
npm test -- --runInBand
```

## AWS deployment

A complete deployment creates two CDK stacks:

- `RapidFrontendWafStack` contains the CloudFront WAF resources in `us-east-1`.
- `RapidStack` contains the main application resources in the selected region.

Docker must be running because the CDK build packages several Lambda functions
and the AgentCore runtime as container images.

Before deploying:

1. Use a sandbox AWS account.
2. Confirm Bedrock model availability in the selected region.
3. Review service quotas and expected cost.
4. Restrict allowed IP ranges where possible.
5. Disable Cognito self-sign-up unless it is truly required.
6. Review `cdk/lib/parameter.ts` and the resulting `cdk diff`.

Basic deployment commands:

```bash
cd cdk
npm ci
export AWS_DEFAULT_REGION=<region>
npx cdk bootstrap
npm run deploy
```

Do not deploy casually. The default architecture includes Aurora Serverless,
networking, storage, workflow, AI, and authentication resources that can incur
ongoing AWS charges.

See these guides before deploying:

- [Deployment options](./docs/en/deployment-options.md)
- [Developer guide](./docs/en/developer-guide.md)
- [Local development guide](./docs/en/local-development.md)

## Known baseline issues

The current code builds and its core test suites pass, but it is not yet a
finished production system.

- The frontend ESLint configuration needs to be repaired and its existing
  findings need to be triaged.
- Locked npm installs currently report dependency vulnerabilities in the
  backend, frontend, and CDK packages.
- The frontend production bundle is large and would benefit from code splitting.
- Full local sign-in depends on a deployed Cognito User Pool.
- AI workflows depend on deployed AWS services and cannot run entirely offline.
- Default AWS settings must be reviewed before any production deployment.

These are tracked as baseline findings, not hidden as successful checks.

## Data and security notes

- Use synthetic documents while developing whenever possible.
- Never commit credentials, tokens, account identifiers, or private documents.
- Treat uploaded content as untrusted input.
- Review IAM permissions, storage policies, retention settings, and network
  exposure before handling sensitive information.
- Keep human review in the final decision path.
- Test cleanup and recovery procedures before relying on the application.

## Roadmap

Work is organized into the following stages:

1. Reproducible local development
2. AWS sandbox deployment
3. End-to-end workflow validation
4. Product and user-experience customization
5. Prompt, model, and evaluation quality
6. Security, privacy, and resilience
7. Observability and operations
8. Pilot release and handoff

The detailed tasks, dependencies, and acceptance criteria are in
[SPRINT_PLAN.md](./SPRINT_PLAN.md).

## License and attribution

This project is based on an AWS Samples repository and retains its original
license. See [LICENSE](./LICENSE) for the license terms and
[CONTRIBUTING.md](./CONTRIBUTING.md) for contribution guidance.

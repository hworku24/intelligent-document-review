# VERA

**Verification and Evidence Review Assistant**

VERA is an AI-assisted document review platform built on AWS. It helps users turn policies, regulations, standards, guidelines, and other source documents into structured review criteria, then evaluate uploaded documents against those criteria.

Instead of returning only a pass or fail result, VERA is designed to show the evidence behind an assessment. Each result can include an explanation, confidence information, source references, and model activity so a human reviewer can understand how the conclusion was reached.

The goal is not to automate professional judgment. The goal is to make document review faster, more structured, and easier to verify.

> VERA is a decision-support system. Final decisions should remain with a qualified human reviewer.

---

## What VERA Does

A typical VERA workflow looks like this:

1. A user uploads a source standard, policy, regulation, guideline, or specification.
2. Amazon Bedrock analyzes the source document and extracts individual review criteria.
3. A reviewer verifies and edits the generated Review Standard.
4. The reviewer uploads one or more documents for assessment.
5. VERA evaluates the document against each criterion.
6. Each criterion receives a result such as:
   * **Meets**
   * **Needs Review**
   * **Does Not Meet**
7. VERA provides supporting evidence, analysis, confidence information, and source references.
8. A human reviewer makes the final decision and can accept, override, or comment on the AI-generated result.

This keeps AI in a supporting role while preserving a clear human decision point.

---

## Why I Am Building This

Document review often requires people to compare large documents against complex policies, standards, or requirements.

That process can involve:

* finding relevant requirements
* breaking broad requirements into individual criteria
* locating supporting evidence
* checking whether evidence satisfies a requirement
* documenting why a decision was made
* repeating the same process across many documents

VERA explores how generative AI and cloud workflows can assist with these tasks while keeping evidence, traceability, and human review at the center of the system.

The project also covers the full lifecycle of an AI application, including frontend development, APIs, databases, asynchronous workflows, cloud infrastructure, generative AI, evaluation, security, observability, and human-centered product design.

---

## Project Foundation

VERA uses an open-source AWS document-review reference implementation as part of its technical foundation. The project is being developed around an evidence-centered, human-in-the-loop review workflow, with VERA-specific terminology, product design, validation logic, reviewer controls, evaluation, and deployment work layered on top of that foundation.

The repository preserves the applicable open-source license and commit history so the technical lineage remains transparent.

---

## Current Project Status

VERA currently has a reproducible local development environment with the major application components installed, tested, and building successfully.

The current baseline includes:

* React and TypeScript frontend
* Fastify and TypeScript backend
* Prisma data layer
* local MySQL database through Docker
* Python document review agent
* AWS CDK infrastructure package
* local backend development mode
* automated project verification script
* backend, frontend, CDK, and Python test coverage
* working frontend and backend development servers

Current verification results:

* Backend: 32 tests passing
* AWS CDK: 12 tests passing
* Python review agent: 11 tests passing
* 2 AWS-dependent Python tests skipped locally
* Backend TypeScript build passing
* Frontend production build passing
* CDK build passing
* Local backend health endpoint verified
* Local frontend development server verified

### Remaining Work

The project is still under active development.

Major areas that remain include:

* completing VERA terminology and user-facing workflow updates around Review Standards, Criteria, Assessments, Evidence, and Reviewer Decisions
* standardizing internal environment variables, resource names, database identifiers, and infrastructure naming
* deploying and validating the application in an AWS sandbox environment
* testing the complete document upload, extraction, assessment, and human-review workflow
* adding structured field extraction with Amazon Textract where appropriate
* adding deterministic validation and SQL-backed reference matching
* improving onboarding, navigation, empty states, and user-facing error handling
* building representative synthetic test documents and evaluation datasets
* measuring model accuracy, latency, token usage, cost, false positives, and false negatives
* improving prompts and model-routing behavior
* validating source citations and evidence quality
* testing prompt injection and adversarial document behavior
* strengthening authentication and authorization boundaries
* reviewing IAM permissions, storage policies, networking, and data retention
* adding operational dashboards, alerts, tracing, and cost monitoring
* testing failure recovery and queue behavior
* resolving current dependency and frontend linting issues
* improving frontend bundle performance
* validating accessibility and responsive behavior
* preparing the project for repeatable deployment and pilot use

The goal is to move from a locally verified technical baseline to a complete, secure, measurable, and human-reviewable document assessment system.

---

## Product Terminology

VERA uses terminology centered around evidence and human review.

| Concept | VERA Term |
| --- | --- |
| Checklist | Review Standard |
| Checklist Item | Criterion |
| Review | Assessment |
| Pass | Meets |
| Fail | Does Not Meet |
| Ambiguous Result | Needs Review |
| Model Reasoning | Analysis |
| Source References | Evidence |
| Final Judgment | Reviewer Decision |

---

## High-Level Architecture

```text
                         VERA
                          │
                          ▼
                  React / TypeScript
                       Frontend
                          │
                          ▼
                    Fastify API
                          │
             ┌────────────┼────────────┐
             │            │            │
             ▼            ▼            ▼
          Cognito       Aurora         S3
                         MySQL
                                       │
                                       ▼
                              Document Processing
                                       │
                                       ▼
                              Step Functions / SQS
                                       │
                                       ▼
                                 Amazon Bedrock
                                       │
                                       ▼
                                  AI Review Agent
                                       │
                                       ▼
                              Evidence + Assessment
                                       │
                                       ▼
                                Human Reviewer
```

The system separates the web application, data layer, document storage, workflow orchestration, and AI processing so each part can be tested and evolved independently.

---

## Technology Stack

| Area | Technology |
| --- | --- |
| Frontend | React, TypeScript, Vite, Tailwind CSS, SWR |
| Backend | Fastify, TypeScript, Prisma |
| Local Database | MySQL 8 with Docker |
| Cloud Database | Amazon Aurora MySQL Serverless v2 |
| Authentication | Amazon Cognito |
| Document Storage | Amazon S3 |
| AI | Amazon Bedrock |
| Agent Framework | Strands Agents |
| Agent Runtime | Amazon Bedrock AgentCore |
| Workflows | AWS Step Functions |
| Messaging | Amazon SQS |
| Infrastructure | AWS CDK |
| Python | Python 3.13+, uv |
| Testing | Jest, Pytest |
| Containers | Docker |

---

## Repository Structure

```text
.
├── backend/
│   └── Fastify API, Prisma models, and application services
├── frontend/
│   └── React web application
├── cdk/
│   └── AWS infrastructure definitions
├── review-item-processor/
│   └── Python AI review agent
├── assets/
│   └── Local development infrastructure
├── examples/
│   └── Sample documents for testing
├── docs/
│   └── Architecture and developer documentation
├── scripts/
│   └── Local development and verification utilities
├── SPRINT_PLAN.md
│   └── Development planning and task tracking
└── SPRINT_1_REPORT.md
    └── Initial local setup and verification record
```

The project does not use a root `package.json`.

The frontend, backend, and CDK directories are separate TypeScript packages. The AI review agent is a separate Python package managed with `uv`.

---

# Local Development

## Prerequisites

Install the following before running VERA locally:

* Node.js 20 or later
* Node.js 22 recommended
* npm
* Docker Desktop
* Docker Compose
* Python 3.13 or later
* uv
* AWS CLI

Check your installed versions:

```bash
node --version
npm --version
docker --version
docker compose version
python3 --version
uv --version
aws --version
```

## 1. Start the Local Database

From the repository root:

```bash
docker compose -f assets/local/docker-compose.yml up -d
```

Check that the container is running:

```bash
docker compose -f assets/local/docker-compose.yml ps
```

Do not reuse local development credentials in a deployed environment.

## 2. Start the Backend

```bash
cd backend
npm ci
npm run prisma:generate
npm run prisma:migrate
export VERA_LOCAL_DEV=true
npm run dev
```

The backend should be available at `http://localhost:3000`.

Check its health:

```bash
curl http://localhost:3000/health
```

Expected response:

```json
{
  "status": "ok"
}
```

## 3. Start the Frontend

Open a second Terminal window and run:

```bash
cd frontend
npm ci
cp .env.example .env.local
npm run dev
```

The frontend should be available at `http://localhost:5173`.

## Authentication

The backend supports a local development authentication mode. The frontend currently depends on Amazon Cognito for full sign-in behavior.

A deployed environment provides values similar to:

```text
VITE_APP_REGION=<aws-region>
VITE_APP_USER_POOL_ID=<cognito-user-pool-id>
VITE_APP_USER_POOL_CLIENT_ID=<cognito-client-id>
VITE_APP_API_ENDPOINT=http://localhost:3000
```

Do not commit real credentials, tokens, AWS account information, or secrets.

## 4. Prepare the AI Review Agent

```bash
cd review-item-processor
uv sync --extra dev
uv run pytest
```

Some agent behavior requires live AWS resources and cannot run completely offline.

---

# Verify the Project

Once dependencies are installed and MySQL is running, return to the repository root and run:

```bash
./scripts/verify-local.sh
```

This provides a single verification workflow across the major packages without automatically deleting or resetting the local database.

---

# AWS Deployment

VERA is designed to run on AWS using managed services for authentication, storage, workflows, relational data, and generative AI.

Before deploying:

1. Use a sandbox AWS account.
2. Confirm the intended AWS region.
3. Confirm Amazon Bedrock model availability.
4. Review AWS service quotas and estimated costs.
5. Restrict network access where possible.
6. Review Cognito configuration and IAM permissions.
7. Inspect the CDK diff.
8. Confirm teardown behavior before testing.

Docker must be running during CDK deployment because parts of the application are packaged as container images.

Basic deployment workflow:

```bash
cd cdk
npm ci
export AWS_DEFAULT_REGION=<region>
npx cdk bootstrap
npm run deploy
```

Services such as Aurora Serverless, Bedrock, networking infrastructure, and storage may generate ongoing charges.

---

# Development Process

Development work is organized into sprints so changes can be made, tested, and documented in manageable increments.

Current planning covers:

* local development
* product terminology and workflows
* AWS infrastructure
* structured extraction and deterministic validation
* core assessment workflows
* user experience
* AI evaluation
* security and resilience
* observability
* performance
* deployment
* release preparation

Detailed engineering tasks and acceptance criteria are tracked in [`SPRINT_PLAN.md`](./SPRINT_PLAN.md).

---

# AI Evaluation

A major part of VERA is evaluating the quality of the AI system rather than simply connecting an application to a language model.

Evaluation work includes:

* criterion extraction accuracy
* false positive assessments
* false negative assessments
* unsupported claims
* evidence quality
* citation correctness
* ambiguity handling
* prompt injection resistance
* latency
* token usage
* model cost
* prompt regressions
* model regressions

Model and prompt changes should eventually be tested against a repeatable evaluation dataset before release.

---

# Human-in-the-Loop Design

VERA is intentionally designed so the AI does not make the final decision.

```text
AI Assessment
      │
      ▼
Evidence + Analysis
      │
      ▼
Human Review
      │
      ▼
Reviewer Decision
```

A reviewer should be able to inspect the evidence, review the explanation, see uncertainty, override an assessment, leave feedback, and make the final decision.

The AI-generated assessment and the human decision should remain separately identifiable in the system.

---

# Security Principles

Uploaded documents should always be treated as untrusted input.

Development and deployment should follow several basic principles:

* never commit credentials or authentication tokens
* never commit private user documents
* use synthetic documents during development whenever possible
* validate uploaded file types
* review S3 access policies
* apply least-privilege IAM permissions
* review authentication and authorization boundaries
* prevent one user from accessing another user's documents
* consider prompt injection during document processing
* redact sensitive information from logs
* define document retention and deletion behavior
* monitor unexpected AWS usage and cost
* preserve human oversight for consequential decisions

---

# Known Baseline Issues

The current baseline runs successfully, but several areas still need work:

* frontend ESLint configuration needs repair
* existing npm dependency vulnerabilities require review
* the frontend bundle would benefit from additional code splitting
* frontend authentication currently depends on Cognito
* AI workflows depend on deployed AWS services
* AWS infrastructure defaults need additional review
* full cloud workflows have not yet been validated end to end
* AI evaluation and regression testing are still being developed
* security and failure-recovery testing remain in progress

---

# License

See [`LICENSE`](./LICENSE) for the repository license and applicable copyright notice.

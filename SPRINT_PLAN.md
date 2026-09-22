# VERA Recreation Sprint Plan

## Goal

Recreate, understand, customize, and productionize the VERA document-review application in controlled increments. The target is a deployed application that can turn source documents into checklists, assess uploaded documents with Amazon Bedrock, support human review, and operate securely and reliably.

## Working assumptions

- Sprint length: two weeks.
- Team: one small cross-functional team; tasks can be reassigned as needed.
- Initial deployment is a non-production AWS environment.
- The existing AWS sample is the technical baseline; changes should be incremental and traceable.
- Node.js 22, Docker, AWS CLI, Python 3.13+, and `uv` are the supported local toolchain.
- A sprint is complete only when its acceptance gate passes and the relevant documentation is updated.

## Definition of Done

Every completed engineering task must meet the following conditions:

- Acceptance criteria are demonstrated or covered by automated tests.
- Changed TypeScript packages pass formatting, linting where available, tests, and builds.
- Changed Python code passes its relevant pytest suite.
- Infrastructure changes pass CDK build/tests and produce a reviewed `cdk diff`.
- No credentials, account IDs, private documents, or generated secrets are committed.
- User-facing behavior and operational steps are documented.
- Accessibility, security, logging, and failure behavior are considered.

---

## Sprint 0 — Discovery and delivery baseline

**Outcome:** The team understands the inherited system, has a prioritized recreation scope, and can make changes safely.

### Subtasks

- [ ] **S0-01 — Confirm product scope and success metrics**
  - Identify target users, document types, expected review volume, required languages, and compliance constraints.
  - Define measurable targets for review accuracy, latency, availability, and cost per review.
  - **Acceptance:** A one-page scope statement and agreed success metrics exist.

- [ ] **S0-02 — Inventory the architecture and data flows**
  - Map the React frontend, Fastify API, Prisma/Aurora data layer, S3 storage, Cognito authentication, Step Functions workflows, SQS queue, Bedrock models, and AgentCore runtime.
  - Mark trust boundaries and locations where customer documents or model outputs persist.
  - **Acceptance:** The architecture map covers upload, checklist extraction, review, feedback, and deletion paths.

- [ ] **S0-03 — Establish repository workflow**
  - Confirm branching, commit, review, and release conventions.
  - Document package-specific commands and the rule that no root `package.json` is introduced.
  - Create issue labels for frontend, backend, agent, infrastructure, security, and documentation.
  - **Acceptance:** A contributor can identify how to start work, verify it, and submit it.

- [ ] **S0-04 — Capture the current baseline**
  - Record the upstream commit and current configuration defaults.
  - Run dependency and secret scans.
  - Record known failures separately from newly introduced regressions.
  - **Acceptance:** Baseline results and known issues are documented.

- [ ] **S0-05 — Prepare environment requirements**
  - Upgrade local Node.js from 18 to Node.js 22.
  - Install `uv` and confirm Python 3.13+ availability.
  - Confirm Docker is running and AWS CLI credentials point to the intended sandbox account.
  - **Acceptance:** All prerequisite version checks pass without exposing credentials.

### Sprint gate

- Scope, architecture, risks, environments, ownership, and success metrics are agreed.
- The repository can be changed without losing the upstream reference point.

---

## Sprint 1 — Reproducible local development

**Outcome:** Backend, frontend, and database can be installed, built, tested, and started consistently on a developer machine.

### Subtasks

- [x] **S1-01 — Start and validate local MySQL**
  - Start `assets/local/docker-compose.yml`.
  - Verify health, database creation, user grants, persistence, and reset behavior.
  - **Acceptance:** The database is reachable with the documented local connection string after a clean start.

- [x] **S1-02 — Bootstrap the backend**
  - Install locked dependencies with `npm ci`.
  - Generate Prisma artifacts and apply migrations.
  - Start the Fastify API with `VERA_LOCAL_DEV=true`.
  - **Acceptance:** `GET /health` succeeds and backend build/tests pass.

- [x] **S1-03 — Bootstrap the frontend**
  - Install locked dependencies and create an untracked `.env.local` from the example.
  - Start Vite and verify its API endpoint configuration.
  - Document the Cognito dependency and the absence of a local authentication bypass in the frontend.
  - **Acceptance:** The frontend builds and reaches the local backend without console-breaking errors.

- [x] **S1-04 — Bootstrap the Python review agent**
  - Sync production and development dependencies with `uv`.
  - Run the agent unit tests and record any AWS-dependent exclusions.
  - **Acceptance:** The local test subset passes reproducibly from a clean checkout.

- [x] **S1-05 — Add a single developer verification command**
  - Add a non-root orchestration script or documented command that checks prerequisites and runs package verification without violating the repository structure.
  - Keep destructive database reset operations opt-in.
  - **Acceptance:** One documented workflow verifies frontend, backend, CDK, and agent packages.

- [x] **S1-06 — Document local troubleshooting**
  - Cover ports, Docker readiness, Prisma generation, environment variables, Cognito configuration, and Apple Silicon considerations.
  - **Acceptance:** A new developer can reproduce the local setup from the documentation.

### Sprint gate

- Clean install and builds succeed for all packages.
- Local database and API health check succeed.
- Frontend is accessible locally, with any cloud-auth requirement explicitly recorded.

---

## Sprint 2 — AWS sandbox foundation and first deployment

**Outcome:** A secure, disposable sandbox deployment is available and its infrastructure can be reproduced.

### Subtasks

- [ ] **S2-01 — Select the AWS environment and region**
  - Confirm account, primary region, Bedrock model availability, quotas, budget, and tagging rules.
  - Verify whether CloudFront/WAF or the S3 + API Gateway frontend mode is appropriate.
  - **Acceptance:** Environment decision and cost owner are recorded.

- [ ] **S2-02 — Define safe sandbox parameters**
  - Restrict allowed IP ranges where feasible.
  - Disable Cognito self-sign-up unless explicitly needed.
  - Select approved Bedrock models and conservative concurrency limits.
  - **Acceptance:** `parameter.ts` reflects reviewed sandbox settings with no secrets.

- [ ] **S2-03 — Bootstrap CDK regions**
  - Install CDK dependencies and bootstrap the target region.
  - Bootstrap `us-east-1` if the CloudFront WAF stack is used.
  - **Acceptance:** CDK bootstrap completes in each required region.

- [ ] **S2-04 — Review infrastructure changes before deployment**
  - Run CDK build/tests and inspect the synthesized templates and `cdk diff`.
  - Review IAM wildcard permissions, public endpoints, removal policies, and estimated fixed cost.
  - **Acceptance:** Risks are acknowledged before creating cloud resources.

- [ ] **S2-05 — Deploy the sandbox stacks**
  - Deploy both stacks and capture non-secret outputs.
  - Verify CloudFormation completion and resolve failed resources.
  - **Acceptance:** Frontend URL, API, database, workflows, storage, and authentication resources are healthy.

- [ ] **S2-06 — Configure initial administrator access**
  - Create or designate a test user and set the required `custom:vera_role` attribute.
  - Test sign-in, sign-out, token expiry, and admin-only access.
  - **Acceptance:** An authorized administrator can use the deployed UI and an unauthorized user cannot access admin features.

- [ ] **S2-07 — Write teardown and cost-control runbook**
  - Document resources that survive `cdk destroy` and any manual cleanup.
  - Add budget alarms or equivalent cost monitoring.
  - **Acceptance:** The sandbox can be safely removed and unexpected spend is detectable.

### Sprint gate

- The application is deployed in a sandbox account.
- Security-sensitive defaults and expected cost have been reviewed.
- Authentication and teardown procedures are proven.

---

## Sprint 3 — End-to-end core workflow parity

**Outcome:** The recreated system completes the sample’s primary checklist and document-review journey.

### Subtasks

- [ ] **S3-01 — Validate document upload handling**
  - Test supported PDF and image types, size limits, invalid files, duplicate names, and presigned URL expiry.
  - **Acceptance:** Valid uploads succeed and unsafe or unsupported inputs fail with useful messages.

- [ ] **S3-02 — Validate checklist extraction**
  - Upload an included sample checklist document.
  - Observe page splitting, parallel extraction, aggregation, and persistence.
  - Test editing and deleting extracted checklist items.
  - **Acceptance:** A usable checklist is generated and stored without manual database changes.

- [ ] **S3-03 — Validate the review queue**
  - Submit reviews up to and beyond configured concurrency and queue-depth limits.
  - Confirm ordering, status transitions, retry behavior, and user-facing error responses.
  - **Acceptance:** Jobs are neither lost nor duplicated and overload behavior is controlled.

- [ ] **S3-04 — Validate AI review results**
  - Run the English sample use cases through Pass and Fail paths.
  - Verify rationale, confidence, page references, model metadata, and tool-call history.
  - **Acceptance:** Results are complete, traceable to source content, and reviewable by a human.

- [ ] **S3-05 — Validate human-in-the-loop actions**
  - Test final judgment, overrides, comments/feedback, and role-based access.
  - Confirm feedback does not silently alter historical AI results.
  - **Acceptance:** Human decisions are clearly distinguished from model output and persist correctly.

- [ ] **S3-06 — Add an end-to-end smoke suite**
  - Automate stable API/UI checks while isolating costly nondeterministic model assertions.
  - Store only synthetic fixtures.
  - **Acceptance:** The suite catches broken upload, checklist, review, and result-view flows.

### Sprint gate

- At least one bundled sample completes from upload through final human judgment.
- Failures can be diagnosed from application and AWS logs.

---

## Sprint 4 — Product customization and user experience

**Outcome:** The generic AWS sample becomes a coherent product tailored to the intended users and review domain.

### Subtasks

- [ ] **S4-01 — Define the product identity and information architecture**
  - Choose product name, navigation labels, terminology, supported locale, and help content.
  - Inventory upstream branding that must remain attributed versus replaceable sample branding.
  - **Acceptance:** A reviewed content and navigation specification exists.

- [ ] **S4-02 — Implement visual and content customization**
  - Update product copy, metadata, theme tokens, and permitted assets.
  - Preserve shared components, `react-icons`, and existing Tailwind configuration rules.
  - **Acceptance:** No unintended VERA/sample branding remains in user-facing screens.

- [ ] **S4-03 — Improve onboarding and empty states**
  - Guide users through creating a checklist, uploading review documents, and interpreting results.
  - Add actionable error and empty-state messages.
  - **Acceptance:** A first-time test user can complete the main workflow without developer help.

- [ ] **S4-04 — Add domain-specific sample material**
  - Create synthetic, legally shareable checklist and review documents for the target use case.
  - Add expected outcomes and test notes.
  - **Acceptance:** The example demonstrates a meaningful Pass and Fail scenario without sensitive data.

- [ ] **S4-05 — Review accessibility and responsive behavior**
  - Test keyboard navigation, focus order, labels, contrast, modal behavior, status announcements, and common viewport sizes.
  - **Acceptance:** Critical workflow screens meet the agreed accessibility baseline.

- [ ] **S4-06 — Validate localization behavior**
  - Ensure updated strings are translated or intentionally limited to a supported language.
  - Test date, number, and long-document-title rendering.
  - **Acceptance:** No missing translation keys or layout-breaking strings remain.

### Sprint gate

- The application has an approved identity and domain-specific demonstration.
- A representative user completes the workflow without engineering assistance.

---

## Sprint 5 — Review quality, prompts, and evaluation

**Outcome:** Review quality is measurable, prompts are controlled, and model changes can be evaluated before release.

### Subtasks

- [ ] **S5-01 — Build a representative evaluation dataset**
  - Define synthetic or approved documents, checklist items, expected outcomes, acceptable rationales, and citation expectations.
  - Include ambiguous, missing, contradictory, image-heavy, and adversarial inputs.
  - **Acceptance:** The dataset covers the intended review domain and major failure modes.

- [ ] **S5-02 — Establish baseline model performance**
  - Run the current default models and record accuracy, false-pass/false-fail rates, latency, token usage, and estimated cost.
  - **Acceptance:** Results are reproducible and tied to model and prompt versions.

- [ ] **S5-03 — Tune checklist extraction prompts**
  - Improve completeness, atomicity, source traceability, and duplicate handling.
  - Protect against instructions embedded in uploaded documents.
  - **Acceptance:** Extraction improves against the baseline without unacceptable regressions.

- [ ] **S5-04 — Tune review prompts and model routing**
  - Define when lightweight versus high-accuracy models are used.
  - Calibrate confidence and ensure uncertainty is surfaced instead of invented evidence.
  - **Acceptance:** Routing meets the agreed quality, latency, and cost targets.

- [ ] **S5-05 — Validate citations and tool-enabled reviews**
  - Test file-read, Citations API, Knowledge Base, Code Interpreter, and permitted MCP paths separately.
  - Confirm tool failures are bounded and visible.
  - **Acceptance:** Every supported tool path has passing evaluation cases and known limitations.

- [ ] **S5-06 — Add an evaluation regression gate**
  - Define thresholds and a repeatable command or pipeline for comparing prompt/model changes.
  - **Acceptance:** A change that breaches a quality threshold is clearly flagged before deployment.

### Sprint gate

- Quality, latency, and cost are measured against a versioned evaluation set.
- Prompt and model updates have an objective release gate.

---

## Sprint 6 — Security, privacy, and resilience

**Outcome:** The system has documented controls for sensitive documents and predictable behavior under failure or abuse.

### Subtasks

- [ ] **S6-01 — Threat-model the application**
  - Cover upload abuse, prompt injection, data leakage, broken authorization, insecure MCP tools, SSRF, denial of service, and supply-chain risks.
  - **Acceptance:** Threats have owners, severity, mitigations, and verification steps.

- [ ] **S6-02 — Verify authentication and authorization boundaries**
  - Test owner-versus-admin access for all checklist, review, document, prompt, and user-management APIs.
  - Test invalid, expired, and incorrectly scoped tokens.
  - **Acceptance:** Automated tests prove protected resources cannot be accessed across users.

- [ ] **S6-03 — Harden document handling and retention**
  - Validate MIME/type detection, filename handling, malware strategy, encryption, lifecycle policies, deletion, and log redaction.
  - **Acceptance:** Document retention and deletion match written policy and are testable.

- [ ] **S6-04 — Reduce infrastructure exposure and permissions**
  - Review IAM roles, bucket policies, security groups, API exposure, WAF rules, secrets, KMS needs, and VPC options.
  - **Acceptance:** Unnecessary public access and wildcard privileges are removed or explicitly justified.

- [ ] **S6-05 — Exercise failure and recovery paths**
  - Inject model throttling, queue saturation, malformed model output, database unavailability, agent timeout, and partial workflow failure.
  - **Acceptance:** Failures end in observable, recoverable states without duplicate finalization or lost jobs.

- [ ] **S6-06 — Run dependency and code security checks**
  - Scan npm/Python dependencies, containers, IaC, and source.
  - Triage findings by exploitability and document accepted risk.
  - **Acceptance:** No unresolved critical findings remain for the pilot release.

### Sprint gate

- High-risk threats are mitigated or explicitly accepted by an accountable owner.
- Access control, data lifecycle, and recovery tests pass.

---

## Sprint 7 — Observability, operations, and performance

**Outcome:** Operators can detect, diagnose, and respond to service, quality, and cost problems.

### Subtasks

- [ ] **S7-01 — Define service-level indicators**
  - Track API errors/latency, queue depth and age, workflow success, model throttles, review duration, token usage, and cost signals.
  - **Acceptance:** Each critical user journey has measurable health indicators.

- [ ] **S7-02 — Build operational dashboards and alarms**
  - Add actionable thresholds with links to runbooks.
  - Avoid alarms that expose document contents or produce excessive noise.
  - **Acceptance:** A forced failure produces the intended alert with enough context to begin diagnosis.

- [ ] **S7-03 — Improve traceability**
  - Propagate correlation identifiers across API requests, SQS messages, Step Functions, Lambda functions, and agent execution.
  - **Acceptance:** An operator can trace one review from submission to completion across services.

- [ ] **S7-04 — Establish performance baselines**
  - Measure typical and large-document behavior under representative concurrency.
  - Identify bottlenecks and confirm service quotas.
  - **Acceptance:** The system meets agreed latency and throughput targets or has a prioritized remediation plan.

- [ ] **S7-05 — Create operational runbooks**
  - Cover stuck reviews, throttling, failed migrations, unavailable models, expired credentials, queue saturation, restore, and teardown.
  - **Acceptance:** Another operator can execute the runbooks without author assistance.

- [ ] **S7-06 — Verify backup and restore**
  - Define recovery objectives and test database/document restoration where required.
  - **Acceptance:** A timed recovery exercise meets the agreed recovery targets.

### Sprint gate

- Dashboards, alerts, tracing, runbooks, and recovery evidence are ready for a pilot.

---

## Sprint 8 — Pilot, release, and handoff

**Outcome:** The customized application is accepted by pilot users and can be released and supported responsibly.

### Subtasks

- [ ] **S8-01 — Prepare release candidate**
  - Freeze intended scope, version configuration/prompts, generate release notes, and run all quality gates.
  - **Acceptance:** Builds, tests, security checks, evaluation thresholds, and deployment checks pass.

- [ ] **S8-02 — Run user acceptance testing**
  - Recruit representative users and test realistic document-review scenarios.
  - Capture usability, trust, accuracy, and workflow feedback.
  - **Acceptance:** Blocking defects are closed and product owner signs off.

- [ ] **S8-03 — Validate human-review policy**
  - Make decision-support limitations, escalation paths, and required final human judgment explicit.
  - **Acceptance:** Users understand the system cannot replace professional judgment.

- [ ] **S8-04 — Execute release rehearsal**
  - Deploy to a fresh environment, run smoke tests, test rollback, and verify monitoring.
  - **Acceptance:** Deployment and rollback complete using only documented procedures.

- [ ] **S8-05 — Launch the pilot**
  - Deploy the approved version, seed approved samples, provision users, and monitor initial usage.
  - **Acceptance:** Pilot users can complete the target workflow and support channels are active.

- [ ] **S8-06 — Conduct handoff and retrospective**
  - Transfer architecture, operational, security, cost, evaluation, and support knowledge.
  - Prioritize post-pilot backlog based on evidence.
  - **Acceptance:** Ownership is explicit and the next release backlog is ordered.

### Sprint gate

- Pilot acceptance is recorded.
- Release, rollback, support, and ownership are operational.

---

## Dependency map

| Sprint | Depends on | Unlocks |
| --- | --- | --- |
| 0 — Discovery | Repository checkout | All implementation work |
| 1 — Local baseline | Sprint 0 | Safe feature development |
| 2 — AWS sandbox | Sprint 0; environment access | Cloud workflow testing |
| 3 — Core parity | Sprints 1 and 2 | Product customization and quality tuning |
| 4 — Product UX | Sprint 3 | Representative pilot experience |
| 5 — Quality/evaluation | Sprint 3; target use cases | Objective release decisions |
| 6 — Security/resilience | Sprints 2 and 3 | Pilot approval |
| 7 — Operations | Sprints 2, 3, and 6 | Supported pilot |
| 8 — Pilot/release | Sprints 4 through 7 | Production backlog |

## Immediate starting backlog

Work should begin in this order:

1. S0-01 — Confirm product scope and success metrics.
2. S0-05 — Prepare environment requirements.
3. S1-01 — Start and validate local MySQL.
4. S1-02 — Bootstrap the backend.
5. S1-03 — Bootstrap the frontend.
6. S1-04 — Bootstrap the Python review agent.

Cloud deployment tasks should not begin until the AWS sandbox account, region, cost owner, and access controls are confirmed.

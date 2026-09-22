# VERA Development Sprint Plan

## Goal

Build VERA into a secure, measurable, human-in-the-loop document review system that can turn source standards into structured criteria, assess uploaded documents, surface supporting evidence, and preserve a clear human decision point.

## Working Assumptions

- Sprint length: two weeks.
- Initial deployment target: non-production AWS sandbox.
- Supported local toolchain: Node.js 22, Docker, AWS CLI, Python 3.13+, and `uv`.
- Changes should be incremental, testable, and documented.
- A sprint is complete only when its acceptance gate passes.

## Definition of Done

Every completed engineering task should meet the following conditions:

- Acceptance criteria are demonstrated or covered by automated tests.
- Changed TypeScript packages pass formatting, applicable linting, tests, and builds.
- Changed Python code passes its relevant pytest suite.
- Infrastructure changes pass CDK build/tests and produce a reviewed `cdk diff`.
- No credentials, account IDs, private documents, or generated secrets are committed.
- User-facing behavior and operational steps are documented.
- Accessibility, security, logging, and failure behavior are considered.

---

## Sprint 1: Reproducible Local Development

**Outcome:** Backend, frontend, database, infrastructure package, and Python review agent can be installed, built, tested, and started consistently on a developer machine.

### Completed

- [x] Start and validate local MySQL.
- [x] Install backend, frontend, and CDK dependencies.
- [x] Generate Prisma artifacts and apply all tracked migrations.
- [x] Start and verify the Fastify API.
- [x] Build and verify the React frontend.
- [x] Sync and test the Python review agent.
- [x] Add `scripts/verify-local.sh` as a single local verification workflow.
- [x] Document troubleshooting for Node, Docker, ports, Prisma, environment variables, and Apple Silicon.

### Acceptance Gate

- Backend tests and TypeScript build pass.
- Frontend production build passes.
- CDK tests and TypeScript build pass.
- Local database and API health checks succeed.
- Python local test subset passes.

---

## Sprint 2: AWS Sandbox Foundation

**Outcome:** A secure, disposable AWS sandbox deployment is reproducible and observable.

### Tasks

- [ ] Confirm account, region, Bedrock model availability, quotas, and budget.
- [ ] Review Cognito configuration and disable unnecessary self-sign-up.
- [ ] Review network exposure, WAF settings, IAM permissions, and removal policies.
- [ ] Bootstrap required CDK regions.
- [ ] Run CDK build/tests, synth, and `cdk diff` before deployment.
- [ ] Deploy sandbox infrastructure and verify frontend, API, database, storage, workflows, and authentication.
- [ ] Configure an initial VERA administrator.
- [ ] Document teardown and cost-control procedures.

### Acceptance Gate

- The application deploys successfully in a sandbox environment.
- Authentication works for authorized users and blocks unauthorized access.
- Expected costs and security-sensitive defaults are documented.
- The environment can be safely removed.

---

## Sprint 3: Structured Document Processing and Validation

**Outcome:** VERA can extract review-relevant information and route verifiable fields through deterministic checks before AI-assisted interpretation.

### Tasks

- [ ] Define supported document types, upload limits, and validation rules.
- [ ] Add Amazon Textract processing for structured field extraction where appropriate.
- [ ] Normalize extracted fields into a consistent internal schema.
- [ ] Add deterministic validation for fields that can be verified without a language model.
- [ ] Add SQL-backed reference matching for values that should be checked against trusted data.
- [ ] Record validation results separately from model-generated analysis.
- [ ] Define routing rules for complete, incomplete, conflicting, and ambiguous information.
- [ ] Add retry, timeout, failure-state, and duplicate-processing protections.
- [ ] Add synthetic test documents covering valid, invalid, incomplete, and contradictory cases.

### Acceptance Gate

- Structured fields can be extracted and normalized from representative documents.
- Deterministic and SQL-backed checks return traceable results.
- Ambiguous cases are clearly routed for further analysis or human review.
- Failed processing does not silently produce a final assessment.

---

## Sprint 4: Review Standards and Assessment Workflow

**Outcome:** Users can move from a source standard to criteria, assessment results, evidence, and a final reviewer decision.

### Tasks

- [ ] Finalize Review Standard, Criterion, Assessment, Evidence, and Reviewer Decision terminology across the application.
- [ ] Validate source-standard upload and criterion extraction.
- [ ] Allow reviewers to verify and edit generated criteria before use.
- [ ] Evaluate assessment documents against individual criteria.
- [ ] Return `Meets`, `Needs Review`, or `Does Not Meet` at criterion level.
- [ ] Surface evidence, analysis, confidence information, and source references.
- [ ] Keep deterministic validation results distinguishable from AI-generated analysis.
- [ ] Allow a human reviewer to accept, override, or comment on an assessment.
- [ ] Preserve model output and final human decisions as separate records.

### Acceptance Gate

- A representative workflow completes from source standard to final human decision.
- Evidence can be traced back to source material.
- Human overrides are explicit and auditable.

---

## Sprint 5: Evaluation and Selective AI Routing

**Outcome:** AI is used where interpretation adds value, while rule-based and database-backed logic handles verifiable cases.

### Tasks

- [ ] Create a representative evaluation dataset using synthetic or approved documents.
- [ ] Measure criterion extraction accuracy.
- [ ] Measure false-positive and false-negative assessment rates.
- [ ] Track unsupported claims and citation failures.
- [ ] Define when deterministic logic is sufficient and when AI analysis is warranted.
- [ ] Define routing behavior for ambiguous cases.
- [ ] Track latency, token usage, and estimated model cost.
- [ ] Test prompt-injection and adversarial-document behavior.
- [ ] Add a repeatable evaluation regression workflow.

### Acceptance Gate

- Model and prompt changes can be compared against a versioned evaluation set.
- VERA can explain why a case was handled deterministically, by AI, or by human review.
- Quality, latency, and cost are measurable.

---

## Sprint 6: Security, Privacy, and Resilience

**Outcome:** Sensitive documents are handled predictably and major failure or abuse paths are tested.

### Tasks

- [ ] Threat-model upload abuse, prompt injection, data leakage, broken authorization, SSRF, denial of service, and supply-chain risks.
- [ ] Test owner-versus-admin authorization boundaries.
- [ ] Validate MIME/type handling, filename handling, encryption, retention, deletion, and log redaction.
- [ ] Review IAM roles, bucket policies, security groups, API exposure, and secrets handling.
- [ ] Exercise model throttling, queue saturation, malformed model output, database failures, agent timeouts, and partial workflow failure.
- [ ] Review dependency and infrastructure security findings by exploitability.

### Acceptance Gate

- High-risk threats are mitigated or explicitly documented.
- Access-control and data-lifecycle tests pass.
- Failures end in observable, recoverable states.

---

## Sprint 7: Observability, Performance, and Pilot Readiness

**Outcome:** VERA is measurable, supportable, and ready for controlled pilot use.

### Tasks

- [ ] Track API errors and latency, queue depth and age, workflow success, model throttles, review duration, token usage, and cost.
- [ ] Add operational dashboards and alarms.
- [ ] Add correlation IDs and structured logging across major workflows.
- [ ] Test representative load and document sizes.
- [ ] Improve frontend bundle performance and user-facing error handling.
- [ ] Validate keyboard navigation, labels, focus behavior, contrast, and responsive layouts.
- [ ] Document known limitations, operational runbooks, rollback, and recovery procedures.
- [ ] Run final end-to-end regression and evaluation suites.

### Acceptance Gate

- Critical user journeys are observable.
- Pilot-scale load is understood.
- Known limitations and operational procedures are documented.
- The system can be deployed, verified, monitored, and rolled back repeatably.

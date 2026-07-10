# Test Report: health-check

## 1. Summary

| Item | Value |
|------|------:|
| Test files | 5 |
| Test cases | 16 |
| Service tests | 4 |
| Validator tests | 0 |
| Controller tests | 5 |
| Route tests | 2 |
| Repository tests | 4 |
| Utility tests | 0 |

## 2. Test Files

| File | Type | Purpose |
|------|------|---------|
| `backend/tests/unit/modules/health-check/health-check.service.test.ts` | Unit | Verifies database and Redis dependency status mapping. |
| `backend/tests/unit/modules/health-check/health-check.controller.test.ts` | Unit | Verifies liveness/readiness response bodies, status codes, and error propagation. |
| `backend/tests/unit/modules/health-check/health-check.repository.test.ts` | Unit | Verifies Prisma readiness query and Redis ping behavior with mocked dependencies. |
| `backend/tests/unit/modules/health-check/health-check.module.test.ts` | Unit | Verifies module wiring exports a controller instance. |
| `backend/tests/integration/modules/health-check/health-check.route.test.ts` | Route integration | Verifies public health route registration. |

## 3. Test Cases

### Service

| Test Case | Purpose |
|-----------|---------|
| `checkDatabase returns up with measured latency when the database responds` | Covers successful database readiness check. |
| `checkDatabase returns down with a stable message when the repository fails` | Covers database failure mapping. |
| `checkRedis returns up with measured latency when Redis responds` | Covers successful Redis readiness check. |
| `checkRedis returns down with a stable message when Redis fails` | Covers Redis failure mapping. |

### Validator

| Test Case | Purpose |
|-----------|---------|
| N/A | The module has no validator. |

### Controller

| Test Case | Purpose |
|-----------|---------|
| `getLiveness returns an up status without dependency checks` | Covers public liveness response and avoids dependency calls. |
| `getReadiness returns ready when database and Redis are up` | Covers HTTP 200 readiness response. |
| `getReadiness returns degraded when the database is down` | Covers HTTP 503 for database outage. |
| `getReadiness returns degraded when Redis is down` | Covers HTTP 503 for Redis outage. |
| `getReadiness propagates unexpected service errors to the async route wrapper` | Covers unexpected exception propagation. |

### Route

| Test Case | Purpose |
|-----------|---------|
| `routes GET /health to the liveness handler without auth middleware` | Verifies liveness route registration. |
| `routes GET /health/ready to the readiness handler without auth middleware` | Verifies readiness route registration. |

### Repository

| Test Case | Purpose |
|-----------|---------|
| `checkReady executes a lightweight database readiness query` | Verifies Prisma `$queryRaw` readiness query shape. |
| `checkReady propagates database failures` | Verifies database errors are not swallowed in repository layer. |
| `checkRedis pings Redis once` | Verifies Redis dependency check. |
| `checkRedis propagates Redis failures` | Verifies Redis errors are not swallowed in repository layer. |

### Utility

| Test Case | Purpose |
|-----------|---------|
| N/A | The module has no utility functions. |

## 4. Business Requirement Coverage

| Requirement | Covered By | Status |
|-------------|------------|--------|
| Liveness endpoint returns HTTP 200 with `status: up`, uptime seconds, and timestamp. | Controller liveness test, route liveness test | Covered |
| Liveness endpoint does not depend on database or Redis availability. | Controller liveness test | Covered |
| Readiness endpoint checks database and Redis. | Controller readiness tests, service tests | Covered |
| Readiness returns HTTP 200 and `status: ready` only when all dependencies are up. | Controller all-up readiness test | Covered |
| Readiness returns HTTP 503, `success: false`, and `status: degraded` when database is down. | Controller database-down readiness test | Covered |
| Readiness returns HTTP 503, `success: false`, and `status: degraded` when Redis is down. | Controller Redis-down readiness test | Covered |
| Service converts database failures into a down dependency result. | Service database failure test | Covered |
| Service converts Redis failures into a down dependency result. | Service Redis failure test | Covered |
| Repository uses `SELECT 1` for database readiness. | Repository database query test | Covered |
| Repository uses Redis `ping` for Redis readiness. | Repository Redis ping test | Covered |
| Health routes are public and registered at `/` and `/ready`. | Route tests | Covered |

## 5. Coverage Summary

Health-check source coverage from `backend/coverage/coverage-final.json` after running targeted tests:

| Metric | Value |
|--------|------:|
| Statements | 100% |
| Branches | 100% |
| Functions | 100% |
| Lines | 100% |

The Vitest text summary is global because `backend/vitest.config.ts` includes all `src/modules/**/*.ts`; unrelated modules remain outside this report's scope.

## 6. Coverage Gaps

No uncovered health-check branches or business behavior were identified after coverage review.

## 7. Duplicate or Overlapping Tests

No duplicate or overlapping health-check test scenarios were identified.

## 8. Skipped or Todo Tests

No `test.skip`, `describe.skip`, or `test.todo` entries were added for health-check.

## 9. Final Notes

The health-check test suite covers controller responses, service dependency mapping, repository dependency calls, route registration, and module wiring. The module has no validators, write operations, ownership checks, concurrency-sensitive behavior, or transaction boundaries to test.

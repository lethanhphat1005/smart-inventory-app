# Test Report: access-control

## 1. Summary

| Item | Value |
|------|------:|
| Test files | 3 |
| Test cases | 17 |
| Service tests | 12 |
| Validator tests | 0 |
| Controller tests | 0 |
| Route tests | 0 |
| Repository tests | 0 |
| Utility tests | 0 |
| Middleware tests | 4 |
| Module export tests | 1 |

## 2. Test Files

| File | Type | Purpose |
|------|------|---------|
| `backend/tests/unit/modules/access-control/access-control.service.test.ts` | Unit | Verifies role permission lookup, unknown-role fallback, and allow/deny permission decisions. |
| `backend/tests/unit/modules/access-control/require-permission.middleware.test.ts` | Unit | Verifies permission middleware success, role normalization, forbidden errors, and missing store-context errors. |
| `backend/tests/unit/modules/access-control/access-control.module.test.ts` | Unit | Verifies the public module barrel exports permission middleware and constants. |

## 3. Test Cases

### Service

| Test Case | Purpose |
|-----------|---------|
| `returns permissions configured for OWNER` | Confirms owner permissions come from `ROLE_PERMISSIONS`. |
| `returns permissions configured for MANAGER` | Confirms manager permissions come from `ROLE_PERMISSIONS`. |
| `returns permissions configured for STAFF` | Confirms staff permissions come from `ROLE_PERMISSIONS`. |
| `returns an empty permission list for an unknown role` | Covers defensive fallback for unsupported roles. |
| `allows owners to perform owner-only store writes` | Confirms owner-only permission grants. |
| `allows managers to manage store members` | Confirms manager membership write grants. |
| `allows staff to perform permitted transaction writes` | Confirms staff transaction grants. |
| `denies STAFF when PRODUCT_WRITE is not configured` | Confirms staff cannot write products. |
| `denies STAFF when STORE_MEMBER_WRITE is not configured` | Confirms staff cannot manage store members. |
| `denies MANAGER when STORE_WRITE is not configured` | Confirms managers cannot write stores. |
| `denies OWNER when STORE_MEMBER_READ is not configured` | Captures the current owner permission matrix exactly. |
| `denies unknown roles` | Confirms unsupported roles cannot pass permission checks. |

### Validator

| Test Case | Purpose |
|-----------|---------|
| None | This module has no validator. |

### Controller

| Test Case | Purpose |
|-----------|---------|
| None | This module has no controller. |

### Route

| Test Case | Purpose |
|-----------|---------|
| None | This module has no route. |

### Repository

| Test Case | Purpose |
|-----------|---------|
| None | This module has no repository. |

### Utility

| Test Case | Purpose |
|-----------|---------|
| None | This module has no utility functions. |

### Middleware

| Test Case | Purpose |
|-----------|---------|
| `calls next without an error when the store role has the permission` | Confirms allowed requests continue. |
| `normalizes lower-case roles before checking permissions` | Confirms persisted lower-case store roles map to app role constants. |
| `passes forbidden error when the store role does not have the permission` | Confirms authorization denial uses a 403 error. |
| `passes bad request error when store context is missing` | Confirms middleware forwards the missing-context error from `requireReqStoreContext`. |

### Module

| Test Case | Purpose |
|-----------|---------|
| `exports public permission middleware and constants` | Confirms route modules can import the public access-control API. |

## 4. Business Requirement Coverage

| Requirement | Covered By | Status |
|-------------|------------|--------|
| Return the exact permission list for each supported app role. | Service role lookup parameterized test | Covered |
| Unknown roles must not receive permissions. | Unknown-role lookup and permission tests | Covered |
| Permission checks must allow configured role-permission pairs. | Owner, manager, and staff allow tests | Covered |
| Permission checks must deny unconfigured role-permission pairs. | Staff, manager, and owner deny tests | Covered |
| Middleware must require store context before authorizing. | Missing store-context middleware test | Covered |
| Middleware must normalize lower-case store roles before permission checks. | Lower-case owner middleware test | Covered |
| Middleware must forward forbidden errors for unauthorized actions. | Forbidden middleware test | Covered |
| Public module exports must remain stable for consuming routes. | Module export test | Covered |

## 5. Coverage Summary

Module-specific coverage from `npm run test:coverage -- access-control`:

| Metric | Value |
|--------|------:|
| Statements | 100% executable access-control files; `index.ts` is 0/0 |
| Branches | 100% executable access-control files; `index.ts` is 0/0 |
| Functions | 100% executable access-control files; `index.ts` is 0/0 |
| Lines | 100% executable access-control files; `index.ts` is 0/0 |

Project aggregate from the same filtered command is low because Vitest includes all `src/modules/**/*.ts` files in the denominator while only access-control tests were selected.

## 6. Coverage Gaps

No uncovered access-control branches or executable lines remain in `access-control.service.ts` or `require-permission.middleware.ts`.

`index.ts` reports 0/0 executable coverage because it is a pure export barrel. Its public behavior is covered by `access-control.module.test.ts`.

## 7. Duplicate or Overlapping Tests

No duplicate test cases identified.

## 8. Skipped or Todo Tests

No `test.skip`, `describe.skip`, or `test.todo` cases were added.

## 9. Final Notes

The suite covers the module's security-sensitive behavior: role permission mapping, allow/deny decisions, role normalization, and error forwarding. The module has no controller, route, repository, validator, or transaction behavior, so no integration or persistence tests were required.

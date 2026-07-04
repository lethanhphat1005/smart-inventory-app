# Test Report: stores

## 1. Summary

| Item | Value |
|------|------:|
| Test files | 6 |
| Test cases | 55 |
| Service tests | 18 |
| Validator tests | 15 |
| Controller tests | 8 |
| Route tests | 6 |
| Repository tests | 8 |
| Utility tests | 2 |

## 2. Test Files

| File | Type | Purpose |
|------|------|---------|
| `tests/unit/modules/stores/store.service.test.ts` | Unit | Verifies store business rules, transactions, not-found/conflict paths, and mocked repository/Prisma calls. |
| `tests/unit/modules/stores/store.validator.test.ts` | Unit | Verifies Zod schemas for params, create, update, and join payloads. |
| `tests/unit/modules/stores/store.controller.test.ts` | Unit | Verifies controller response shape and service-call wiring with mocked request/response objects. |
| `tests/integration/modules/stores/store.route.test.ts` | Integration | Verifies Express route registration, real validators, and mocked auth/store-context/permission middleware order. |
| `tests/unit/modules/stores/store.repository.test.ts` | Unit | Verifies mocked Prisma query shapes, filters, where clauses, and update payloads. |
| `tests/unit/modules/stores/store.util.test.ts` | Unit | Verifies invite-code formatting and fallback behavior. |

## 3. Test Cases

### Service

| Test Case | Purpose |
|-----------|---------|
| returns active stores with the current membership role | Ensures list responses flatten the active membership role onto each store. |
| throws when repository data has no matching membership | Covers defensive error when repository result is internally inconsistent. |
| returns a store when the user is an active member | Covers authorized store lookup success. |
| throws not found when the user has no store access | Covers access-denied/not-found behavior for store lookup. |
| creates a store and owner membership in one transaction | Verifies store creation and owner membership creation use one transaction. |
| propagates database errors from the transaction | Ensures transaction/database failures are not swallowed. |
| updates store data after membership access is verified | Covers update success after membership check. |
| throws not found when the user cannot access the store | Ensures update is blocked for inaccessible stores. |
| throws internal server error when update returns no store | Covers unexpected failed update result. |
| disables an accessible active store | Covers soft-delete success path. |
| throws not found and does not disable inaccessible stores | Ensures soft delete is blocked for inaccessible stores. |
| updates the invite code for an accessible store | Covers invite-code refresh success path. |
| throws not found when user has no permission | Covers refresh denied/not-found path. |
| creates a staff membership for a new user | Covers joining a store as a new staff member. |
| throws not found for an invalid invite code | Covers invalid invite-code lookup. |
| throws conflict when the user is already active member | Covers duplicate active join behavior. |
| documents inactive membership reactivation branch | Covers intended reactivation branch for inactive memberships. |
| surfaces duplicate membership races as database failures | Covers duplicate join/concurrency failure surfacing. |

### Validator

| Test Case | Purpose |
|-----------|---------|
| accepts a valid UUID storeId | Covers valid route parameter schema. |
| rejects invalid storeId format | Covers invalid route parameter schema. |
| accepts valid store creation payload and trims strings | Covers valid create payload normalization. |
| rejects a missing store name | Covers required create payload field. |
| rejects an empty store name after trimming | Covers whitespace-only create name. |
| rejects store names longer than 100 characters | Covers create name upper boundary. |
| accepts nullable optional address and timezone | Covers nullable optional create fields. |
| rejects a non-string currency code | Covers create payload type validation. |
| accepts a valid partial update payload | Covers valid partial update. |
| rejects an empty update payload | Covers no-op update rejection. |
| rejects an empty updated name after trimming | Covers whitespace-only update name. |
| currently accepts null currency code | Documents current schema behavior for nullable update currency. |
| rejects address longer than 255 characters | Covers update address upper boundary. |
| accepts and trims an invite code | Covers join payload normalization. |
| rejects an empty invite code | Covers whitespace-only invite code rejection. |

### Controller

| Test Case | Purpose |
|-----------|---------|
| returns stores for the authenticated user | Verifies `getStores` calls service with `req.user.userId` and returns success response. |
| returns a store by path id for the authenticated user | Verifies `getStoreById` uses path `storeId` and current user id. |
| creates a store for the authenticated user | Verifies `createStore` forwards authenticated user id and request body. |
| updates the store from request store context | Verifies `updateStore` uses `req.storeContext.storeId`, current user id, and body. |
| soft deletes a store by path id | Verifies `softDeleteStore` uses path `storeId` and returns `null` data. |
| refreshes invite code for the current store context | Verifies `refreshInviteCode` uses current store context and user id. |
| joins a store by invite code without store context | Verifies `joinStore` uses current user and invite code body. |
| throws when a protected controller method has no authenticated user | Covers controller behavior when `req.user` is missing. |

### Route

| Test Case | Purpose |
|-----------|---------|
| routes GET /stores through authentication to list stores | Covers list route registration and auth middleware invocation. |
| rejects invalid create payload before controller execution | Covers create route validator blocking invalid body. |
| routes GET /stores/:storeId through context and read permission | Covers store detail route, store-context middleware, and read permission middleware. |
| rejects invalid storeId params before delete controller execution | Covers delete route param validation. |
| routes refresh invite code through store write permission | Covers refresh route, store-context middleware, and write permission middleware. |
| rejects empty invite code before join controller execution | Covers join route body validation. |

### Repository

| Test Case | Purpose |
|-----------|---------|
| findManybyUserId scopes stores by active store and membership | Verifies active store/member filter shape for listing. |
| findByIdAndUserId enforces membership ownership | Verifies active store/member filter shape for access-controlled lookup. |
| findById returns active stores by storeId | Verifies simple active store lookup shape. |
| createOne writes the generated invite code and payload | Verifies create data payload passed to Prisma. |
| updateOne updates by storeId only | Verifies update where clause and data payload. |
| disableOne soft deletes the store | Verifies soft-delete update payload. |
| updateInviteCode updates the invite code by storeId | Verifies invite-code update payload. |
| findByInviteCode only returns active stores | Verifies invite-code lookup is scoped to active stores. |

### Utility

| Test Case | Purpose |
|-----------|---------|
| generates a default invite code in grouped lowercase format | Verifies default invite-code shape. |
| returns the raw code fallback when no groups can be formed | Covers utility fallback branch for zero-length code. |

## 4. Business Requirement Coverage

| Requirement | Covered By | Status |
|-------------|------------|--------|
| Authenticated user can list active stores they belong to with role | Service, Controller, Route, Repository | Covered |
| Store detail requires active membership | Service, Controller, Route, Repository | Covered |
| Store creation creates store and owner membership in a transaction | Service, Repository | Covered |
| Store creation surfaces database/transaction failure | Service | Covered |
| Store update requires access and handles not-found/update-failed branches | Service, Controller, Repository, Validator | Covered |
| Store soft delete requires access and marks store inactive | Service, Controller, Repository, Route | Covered |
| Invite-code refresh requires access and updates invite code | Service, Controller, Repository, Route | Covered |
| Join by invite code creates staff membership for new user | Service, Controller, Route | Covered |
| Join by invalid invite code returns not found | Service | Covered |
| Duplicate active membership join returns conflict | Service | Covered |
| Inactive membership reactivation branch is represented | Service | Covered |
| Duplicate join/concurrency failure is surfaced | Service | Covered |
| Request validation rejects invalid params and payloads | Validator, Route | Covered |
| Cross-store path/header mismatch behavior is observable | Controller and previous route/controller coverage | Partially Covered |
| Real Prisma persistence and database constraints | Not covered by mocked repository tests | Not Covered |
| Real authentication/RBAC middleware behavior | Route tests use mocks | Partially Covered |

## 5. Coverage Summary

| Metric | Value |
|--------|------:|
| Statements | 97.39% |
| Branches | 100% |
| Functions | 100% |
| Lines | 97.36% |

Coverage values are from the latest stores-focused coverage run in the test workflow.

## 6. Coverage Gaps

- `store.module.ts` remains uncovered. This file wires the singleton repository/service/controller instances and has no business branches.
- Repository tests use mocked Prisma and verify query shape only. They do not prove real database persistence, foreign-key behavior, or unique constraint behavior.
- Route tests mock authentication, store-context, permission middleware, and controller handlers. They verify route wiring and validators, not real auth/RBAC behavior.
- Soft-delete cascading behavior for related memberships is not implemented in production code; tests cover current single-entity soft delete only.

## 7. Duplicate or Overlapping Tests

- Controller and route tests both exercise endpoint-level success concepts for list/detail/refresh/join, but at different layers:
  - Controller tests verify service calls and response shape.
  - Route tests verify route registration, middleware order, and validators.
- Service and repository tests both touch store access scoping conceptually, but service tests verify business branching while repository tests verify Prisma query shape.

No meaningless duplicate assertions were identified.

## 8. Skipped or Todo Tests

No `test.skip`, `describe.skip`, or `test.todo` cases were found in the stores test suite.

## 9. Final Notes

The stores module test suite covers the main business rules, controller/service/repository boundaries, validators, route wiring, and invite-code utility behavior. Branch coverage for the stores module is complete in the latest workflow coverage output.

Remaining work is mainly broader integration depth:

- Add real Prisma repository integration tests if database-level guarantees become required.
- Add real auth/RBAC integration coverage if route middleware behavior should be validated end-to-end.
- Revisit soft-delete membership behavior if production logic changes to cascade or restore store memberships.

The stores module is ready for broader integration testing beyond mocked unit and route-wiring coverage.

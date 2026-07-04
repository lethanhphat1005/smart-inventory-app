# Test Report: store-member

## 1. Summary

| Item                           | Value |
| ------------------------------ | ----: |
| Test files                     |     7 |
| Test cases                     |    52 |
| Service tests                  |    19 |
| Validator tests                |     9 |
| Controller tests               |     4 |
| Route tests                    |     6 |
| Repository tests               |     8 |
| Utility tests                  |     0 |
| Middleware/module wiring tests |     6 |

## 2. Test Files

| File                                                                       | Type              | Purpose                                                                                                |
| -------------------------------------------------------------------------- | ----------------- | ------------------------------------------------------------------------------------------------------ |
| `tests/unit/modules/store-member/store-member.service.test.ts`             | Unit              | Business rules for listing members, RBAC membership lookup, removal, role changes, errors, and events. |
| `tests/unit/modules/store-member/store-member.repository.test.ts`          | Unit              | Mocked Prisma query shape for membership reads, writes, creates, and reactivation.                     |
| `tests/unit/modules/store-member/store-member.validator.test.ts`           | Unit              | Zod validation for member params, role body, and member-list query params.                             |
| `tests/unit/modules/store-member/store-member.controller.test.ts`          | Unit              | Controller request extraction, service calls, response status, and response body.                      |
| `tests/unit/modules/store-member/require-store-context.middleware.test.ts` | Unit              | Store-context middleware happy path and auth/header/access failures.                                   |
| `tests/unit/modules/store-member/store-member.module.test.ts`              | Unit              | Module wiring exports repository, service, and controller instances.                                   |
| `tests/integration/modules/store-member/store-member.route.test.ts`        | Route integration | Express route wiring, middleware order effects, validators, permissions, and controller dispatch.      |

## 3. Test Cases

### Service

| Test Case                                                         | Purpose                                                              |
| ----------------------------------------------------------------- | -------------------------------------------------------------------- |
| returns active member profile data with role and join date        | Verifies member list mapping from repository DTO to public response. |
| propagates repository failures when listing members fails         | Verifies unexpected list errors are not swallowed.                   |
| throws bad request when userId is missing                         | Validates RBAC lookup input guard.                                   |
| throws bad request when storeId is missing                        | Validates RBAC lookup input guard.                                   |
| returns null when no active membership exists                     | Verifies access middleware can distinguish no membership.            |
| returns membership data for RBAC middleware                       | Verifies successful RBAC membership lookup.                          |
| soft deletes a staff member when requester is owner               | Verifies removal happy path.                                         |
| throws not found when target user is not a store member           | Covers missing target member.                                        |
| throws bad request when target member is already inactive         | Covers duplicate/removal idempotency guard.                          |
| prevents users from removing themselves                           | Covers self-removal protection.                                      |
| prevents removing the store owner                                 | Covers owner protection.                                             |
| prevents managers from removing other managers case-insensitively | Covers role hierarchy protection.                                    |
| propagates repository errors during soft delete                   | Covers write failure.                                                |
| updates role and emits ROLE_UPDATED when requester is owner       | Covers role update happy path and side effect event.                 |
| forbids non-owner requesters from changing roles                  | Covers authorization failure.                                        |
| throws not found when target is not an active member              | Covers missing target on role update.                                |
| throws not found when target membership is inactive               | Covers inactive target on role update.                               |
| prevents changing the store owner role                            | Covers owner role protection.                                        |
| rejects no-op role changes                                        | Covers duplicate role guard.                                         |
| propagates repository errors during role update                   | Covers update failure.                                               |

### Validator

| Test Case                                             | Purpose                                                    |
| ----------------------------------------------------- | ---------------------------------------------------------- |
| accepts a valid UUID userId                           | Validates path params happy path.                          |
| rejects invalid userId format                         | Covers malformed UUID.                                     |
| rejects missing userId                                | Covers missing path param.                                 |
| accepts manager and staff roles                       | Covers allowed public role changes.                        |
| rejects owner role changes through the public payload | Covers owner escalation prevention at validation boundary. |
| rejects missing or non-string role values             | Covers invalid role body shape.                            |
| applies default pagination values                     | Covers query defaults.                                     |
| coerces valid pagination query strings                | Covers query coercion and trimming.                        |
| rejects invalid pagination boundaries                 | Covers page/limit boundaries.                              |

### Controller

| Test Case                                                        | Purpose                                                    |
| ---------------------------------------------------------------- | ---------------------------------------------------------- |
| removes a target user using authenticated user and store context | Verifies request user/context extraction and service call. |
| throws bad request when remove target userId param is missing    | Covers controller guard before service call.               |
| updates a target member role from store context                  | Verifies role update request mapping and response.         |
| returns store members for the current store context              | Verifies list request mapping and response.                |

### Route

| Test Case                                                         | Purpose                                                  |
| ----------------------------------------------------------------- | -------------------------------------------------------- |
| routes GET /store-members through auth and store context          | Verifies list route middleware and controller dispatch.  |
| rejects invalid list pagination before controller execution       | Verifies query validator stops invalid requests.         |
| routes DELETE /store-members/:userId through delete permission    | Verifies delete permission and controller dispatch.      |
| rejects invalid delete userId before controller execution         | Verifies params validator stops invalid delete requests. |
| routes PATCH /store-members/:userId/role through write permission | Verifies write permission and controller dispatch.       |
| rejects invalid role payload before controller execution          | Verifies body validator stops invalid role requests.     |

### Repository

| Test Case                                                               | Purpose                                            |
| ----------------------------------------------------------------------- | -------------------------------------------------- |
| findOne scopes membership by user, store, and active status             | Verifies active membership read query.             |
| findByIdsWithStore fetches the composite membership with owner id       | Verifies composite lookup and owner include.       |
| findManyByStoreId returns active members with active users only         | Verifies list scoping and selected profile fields. |
| softDeleteMember marks the membership inactive by composite key         | Verifies soft-delete update shape.                 |
| updateRole updates only the role by composite key                       | Verifies role update shape.                        |
| createOne creates a membership and selects public fields                | Verifies create shape and returned fields.         |
| findOneByUserIdAndStoreId scopes RBAC lookup to active store membership | Verifies RBAC store and membership active filters. |
| reactivateMembership restores active status and role                    | Verifies reactivation update shape.                |

### Utility

| Test Case | Purpose                                  |
| --------- | ---------------------------------------- |
| None      | No store-member utility functions exist. |

### Middleware And Module

| Test Case                                                  | Purpose                                      |
| ---------------------------------------------------------- | -------------------------------------------- |
| stores active membership context on the request            | Verifies middleware attaches `storeContext`. |
| passes bad request error when x-store-id header is missing | Covers missing store header.                 |
| passes unauthorized error when request user is missing     | Covers missing authenticated user.           |
| passes forbidden error when user has no store membership   | Covers cross-store/no-access denial.         |
| exports repository and service instances                   | Covers module wiring.                        |

## 4. Business Requirement Coverage

| Requirement                                                                               | Covered By                   | Status  |
| ----------------------------------------------------------------------------------------- | ---------------------------- | ------- |
| List only active store members and active user profiles                                   | Service, repository, route   | Covered |
| Map member profile fields plus role and joinedAt                                          | Service                      | Covered |
| RBAC membership lookup requires userId and storeId                                        | Service                      | Covered |
| RBAC lookup returns null for no active membership                                         | Service, middleware          | Covered |
| RBAC lookup must scope to active store and active membership                              | Repository                   | Covered |
| Removing a member performs soft delete, not hard delete                                   | Service, repository          | Covered |
| Cannot remove a non-member or already inactive member                                     | Service                      | Covered |
| Cannot remove self                                                                        | Service                      | Covered |
| Cannot remove store owner                                                                 | Service                      | Covered |
| Manager cannot remove another manager                                                     | Service                      | Covered |
| Only owner can update member roles                                                        | Service, route               | Covered |
| Role changes can only target active non-owner members                                     | Service                      | Covered |
| Public role payload cannot set owner                                                      | Validator, route             | Covered |
| No-op role changes are rejected                                                           | Service                      | Covered |
| Role updates emit `ROLE_UPDATED`                                                          | Service                      | Covered |
| Route layer enforces auth, store context, permissions, params, query, and body validation | Route, middleware, validator | Covered |
| Repository writes use composite `userId_storeId` keys                                     | Repository                   | Covered |

## 5. Coverage Summary

Store-member module-specific coverage from `coverage/coverage-final.json` after `npm run test:coverage -- store-member`:

| Metric     |   Value |
| ---------- | ------: |
| Statements | 100.00% |
| Branches   | 100.00% |
| Functions  | 100.00% |
| Lines      | 100.00% |

Project-wide coverage from the same command is low because Vitest coverage includes all `src/modules/**/*.ts` while this run intentionally targeted only store-member tests.

## 6. Coverage Gaps

No uncovered store-member statements, branches, functions, or lines remain after the coverage-review pass.

## 7. Duplicate or Overlapping Tests

No meaningful duplicate tests identified. Validator behavior is intentionally covered at both schema-unit level and route-boundary level for high-value request rejection paths.

## 8. Skipped or Todo Tests

No `test.skip`, `describe.skip`, or `test.todo` cases are present in the store-member test suite.

## 9. Final Notes

The store-member module now has unit coverage for service, repository, validator, controller, middleware, and module wiring, plus route integration coverage for middleware and validation boundaries. The suite is ready for broader integration testing against a real database if persistence-level behavior for store membership lifecycle is needed later.

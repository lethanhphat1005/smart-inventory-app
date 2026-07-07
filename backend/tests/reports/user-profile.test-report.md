# Test Report: user-profile

## 1. Summary

| Item | Value |
|------|------:|
| Test files | 7 |
| Test cases | 34 |
| Service tests | 7 |
| Validator tests | 6 |
| Controller tests | 7 |
| Route tests | 5 |
| Repository tests | 5 |
| Middleware tests | 3 |
| Module tests | 1 |
| Utility tests | 0 |

## 2. Test Files

| File | Type | Purpose |
|------|------|---------|
| `tests/unit/modules/user-profile/user-profile.service.test.ts` | Unit | Covers profile creation idempotency, profile retrieval, update authorization preconditions at service boundary, not-found cases, and repository failure propagation. |
| `tests/unit/modules/user-profile/user-profile.repository.test.ts` | Unit | Covers Prisma query shapes for lookup, create, find-by-id, update, and database failure propagation. |
| `tests/unit/modules/user-profile/user-profile.controller.test.ts` | Unit | Covers request-user extraction, response status/body, ownership guard, missing param guard, and unauthenticated request behavior. |
| `tests/unit/modules/user-profile/user-profile.validator.test.ts` | Unit | Covers UUID params and update body validation, trimming, optional fields, invalid types, and field length boundaries. |
| `tests/unit/modules/user-profile/optional-profile.middleware.test.ts` | Unit | Covers token-only authentication success, token extraction failure, and provider verification failure. |
| `tests/unit/modules/user-profile/user-profile.module.test.ts` | Unit | Covers singleton module wiring exports. |
| `tests/integration/modules/user-profile/user-profile.route.test.ts` | Integration | Covers route registration, middleware selection, validator short-circuiting, and controller dispatch. |

## 3. Test Cases

### Service

| Test Case | Purpose |
|-----------|---------|
| returns the existing profile without creating a duplicate | Ensures profile creation is idempotent for an existing auth user. |
| creates a profile when none exists for the auth user id | Ensures missing profiles are created with the requested payload. |
| propagates repository failures while checking for an existing profile | Ensures database failures are not swallowed. |
| returns the profile for an auth user id | Ensures profile lookup returns repository data. |
| throws not found when the auth user has no profile | Ensures missing current profile maps to 404. |
| updates an existing profile by user id | Ensures update checks existence and writes provided fields. |
| throws not found when the target profile does not exist | Ensures missing target profile blocks update. |

### Validator

| Test Case | Purpose |
|-----------|---------|
| accepts a valid UUID userId | Verifies valid path params. |
| rejects invalid userId format | Verifies invalid path params fail before controller execution. |
| accepts a partial update and trims strings | Verifies update payload transformation. |
| accepts omitted optional fields | Documents current empty-body behavior. |
| rejects invalid field types | Verifies type safety for update body fields. |
| rejects values longer than field limits | Verifies max lengths for full name, address, and phone. |

### Controller

| Test Case | Purpose |
|-----------|---------|
| creates the current user profile from auth user context and body | Verifies service call and 201 response for profile creation. |
| defaults missing email and full name while creating a profile | Verifies controller defaulting behavior. |
| gets the current user profile by auth user id | Verifies current-profile lookup and 200 response. |
| updates the current user profile when the path id matches the request user | Verifies ownership match allows update. |
| rejects profile updates when userId path param is missing | Verifies bad request guard. |
| rejects attempts to update another user profile | Verifies forbidden cross-user update guard. |
| throws unauthorized when request user is missing | Verifies unauthenticated requests fail. |

### Route

| Test Case | Purpose |
|-----------|---------|
| routes POST /profiles/me/profile through token-only auth | Verifies create-profile route uses `verifyAuthOnly`. |
| routes GET /profiles/me through full authentication | Verifies current-profile route uses `authenticate`. |
| routes PATCH /profiles/:userId through authentication and validators | Verifies update route wiring. |
| rejects invalid userId params before update controller execution | Verifies params validator short-circuits invalid UUIDs. |
| rejects invalid update body before update controller execution | Verifies body validator short-circuits invalid payloads. |

### Repository

| Test Case | Purpose |
|-----------|---------|
| findByAuthUserId looks up a unique profile by auth user id | Verifies Prisma `findUnique` where clause. |
| createOne writes the auth id, email, and full name | Verifies Prisma `create` data shape. |
| findById looks up a unique profile by user id | Verifies Prisma `findUnique` user id lookup. |
| updateOne updates only the provided profile fields | Verifies Prisma `update` where/data shape. |
| propagates database failures | Ensures Prisma failures are propagated. |

### Middleware

| Test Case | Purpose |
|-----------|---------|
| sets minimal request user context from a valid access token | Verifies token-only auth populates `req.user`. |
| passes token extraction failures to next | Verifies auth parsing errors are forwarded. |
| passes provider verification failures to next | Verifies token verification errors are forwarded. |

### Module

| Test Case | Purpose |
|-----------|---------|
| exports initialized repository, service, and controller singletons | Verifies module wiring exports are initialized. |

### Utility

| Test Case | Purpose |
|-----------|---------|
| N/A | No module-specific utility functions exist. |

## 4. Business Requirement Coverage

| Requirement | Covered By | Status |
|-------------|------------|--------|
| Create a user profile for an authenticated Supabase user when no local profile exists. | Service, controller, route, repository tests | Covered |
| Do not create duplicate profiles when a local profile already exists for an auth user id. | Service test | Covered |
| Return the current authenticated user's profile. | Service, controller, route tests | Covered |
| Return 404 when the current authenticated user's profile does not exist. | Service test | Covered |
| Update only the current user's own profile. | Controller, route, service, repository tests | Covered |
| Reject attempts to update another user's profile. | Controller test | Covered |
| Validate update path params as UUIDs. | Validator, route tests | Covered |
| Validate update body field types and length boundaries. | Validator, route tests | Covered |
| Authenticate profile creation with token-only auth before a local profile exists. | Middleware, route tests | Covered |
| Propagate repository, token extraction, and token verification failures. | Service, repository, middleware tests | Covered |

## 5. Coverage Summary

Note: Column "Value" indicates the module coverage only.

| Metric | Value |
|--------|------:|
| Statements | 100.00% |
| Branches | 100.00% |
| Functions | 100.00% |
| Lines | 100.00% |

## 6. Coverage Gaps

No uncovered user-profile module branches remain in the V8 coverage JSON after running the standalone module suite.

Current behavior allows an empty update body because `updateUserProfileBodySchema` has only optional fields and no refinement. This is documented by test coverage, not changed.

## 7. Duplicate or Overlapping Tests

No duplicate tests were identified within the standalone `user-profile` suite.

Two legacy tests under `tests/unit/modules/user/` also contain `user-profile` in their names, but they cover the older `src/modules/user` profile service/repository and are not counted in this report.

## 8. Skipped or Todo Tests

None.

## 9. Final Notes

The standalone `user-profile` module now has unit coverage for service, repository, controller, validator, middleware, and module wiring, plus route-level integration coverage.

One production route registration issue was fixed: `PATCH /:userId` is now registered on the local router instead of a re-imported `userProfileRouter` binding from the module index.

The module is ready for broader integration testing with real authentication and database persistence when a test database workflow is available.

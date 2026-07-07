# Test Report: auth

## 1. Summary

| Item                | Value |
| ------------------- | ----: |
| Test files          |     4 |
| Test cases          |    17 |
| Service tests       |    11 |
| Validator tests     |     0 |
| Controller tests    |     0 |
| Route tests         |     0 |
| Repository tests    |     0 |
| Utility tests       |     0 |
| Middleware tests    |     2 |
| Provider tests      |     3 |
| Module wiring tests |     1 |

## 2. Test Files

| File                                                              | Type | Purpose                                                                                                                                              |
| ----------------------------------------------------------------- | ---- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `backend/tests/unit/modules/auth/auth-session.service.test.ts`    | Unit | Covers Authorization header parsing, full request authentication, local profile lookup, token-only verification, and dependency failure propagation. |
| `backend/tests/unit/modules/auth/supabase-auth.provider.test.ts`  | Unit | Covers Supabase token verification success and invalid or empty Supabase user responses.                                                             |
| `backend/tests/unit/modules/auth/authenticate.middleware.test.ts` | Unit | Covers Express middleware user attachment and error forwarding.                                                                                      |
| `backend/tests/unit/modules/auth/auth.module.test.ts`             | Unit | Covers auth module export wiring.                                                                                                                    |

## 3. Test Cases

### Service

| Test Case                                                                      | Purpose                                                                                       |
| ------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------- |
| `extracts a trimmed bearer access token`                                       | Verifies Bearer token extraction and whitespace trimming.                                     |
| `throws unauthorized error when the authorization header is missing`           | Verifies missing credentials are rejected with 401.                                           |
| `throws unauthorized error when the authorization header is not bearer`        | Verifies non-Bearer credentials are rejected with 401.                                        |
| `throws unauthorized error when the bearer token is empty`                     | Verifies empty Bearer tokens are rejected with 401.                                           |
| `returns the active local user mapped from a valid Supabase token`             | Verifies Supabase verification, active local profile lookup, and returned current-user shape. |
| `throws unauthorized error when the authenticated Supabase user has no email`  | Verifies Supabase users without email cannot authenticate.                                    |
| `throws unauthorized error when the local user profile is missing or inactive` | Verifies tokens without active local profiles cannot authenticate.                            |
| `propagates Supabase token verification failures`                              | Verifies provider failures stop authentication and skip profile lookup.                       |
| `propagates local profile lookup failures`                                     | Verifies unexpected local user lookup failures are not swallowed.                             |
| `returns Supabase identity without requiring a local user profile`             | Verifies token-only auth returns Supabase identity and skips profile lookup.                  |
| `propagates Supabase token verification failures`                              | Verifies token-only auth propagates provider failures.                                        |

### Validator

| Test Case | Purpose                             |
| --------- | ----------------------------------- |
| None      | Auth module has no validator files. |

### Controller

| Test Case | Purpose                              |
| --------- | ------------------------------------ |
| None      | Auth module has no controller files. |

### Route

| Test Case | Purpose                         |
| --------- | ------------------------------- |
| None      | Auth module has no route files. |

### Repository

| Test Case | Purpose                              |
| --------- | ------------------------------------ |
| None      | Auth module has no repository files. |

### Utility

| Test Case | Purpose                           |
| --------- | --------------------------------- |
| None      | Auth module has no utility files. |

### Middleware

| Test Case                                                      | Purpose                                                                               |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| `attaches the authenticated user to the request and continues` | Verifies authenticated request state is stored on `req.user` before calling `next()`. |
| `forwards authentication errors`                               | Verifies middleware forwards service errors through Express error handling.           |

### Provider

| Test Case                                                    | Purpose                                                                            |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------- |
| `returns the Supabase user for a valid token`                | Verifies Supabase client is called with the access token and the user is returned. |
| `throws forbidden error when Supabase returns an auth error` | Verifies Supabase auth errors are converted to 403.                                |
| `throws forbidden error when Supabase returns no user`       | Verifies empty Supabase user responses are converted to 403.                       |

### Module

| Test Case                             | Purpose                                                               |
| ------------------------------------- | --------------------------------------------------------------------- |
| `exports the authenticate middleware` | Verifies `backend/src/modules/auth/index.ts` exposes auth middleware. |

## 4. Business Requirement Coverage

| Requirement                                                                                           | Covered By                                                       | Status  |
| ----------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- | ------- |
| Requests must provide an `Authorization` header.                                                      | `auth-session.service.test.ts`                                   | Covered |
| Authorization must use the `Bearer ` scheme.                                                          | `auth-session.service.test.ts`                                   | Covered |
| Bearer token must not be empty after trimming.                                                        | `auth-session.service.test.ts`                                   | Covered |
| Access tokens must be verified by Supabase.                                                           | `auth-session.service.test.ts`, `supabase-auth.provider.test.ts` | Covered |
| Invalid or expired Supabase tokens must be rejected with forbidden status.                            | `supabase-auth.provider.test.ts`                                 | Covered |
| Fully authenticated requests require a Supabase email.                                                | `auth-session.service.test.ts`                                   | Covered |
| Fully authenticated requests require an active local user profile.                                    | `auth-session.service.test.ts`                                   | Covered |
| Returned current-user identity must use the local user id, Supabase auth id, and local profile email. | `auth-session.service.test.ts`                                   | Covered |
| Token-only verification must not require a local profile lookup.                                      | `auth-session.service.test.ts`                                   | Covered |
| Middleware must attach authenticated user context to the request.                                     | `authenticate.middleware.test.ts`                                | Covered |
| Middleware must forward authentication failures.                                                      | `authenticate.middleware.test.ts`                                | Covered |
| Auth index must export the middleware used by other modules.                                          | `auth.module.test.ts`                                            | Covered |
| Auth module has no write operations and no transaction requirement.                                   | Source review                                                    | Covered |

## 5. Coverage Summary

Auth-specific coverage from `npm run test:coverage -- auth`:

| Metric     | Value |
| ---------- | ----: |
| Statements |  100% |
| Branches   |  100% |
| Functions  |  100% |
| Lines      |  100% |

Tracked auth files at 100%: `index.ts`, `constants/auth.constant.ts`, `middlewares/authenticate.middleware.ts`, `providers/supabase-auth.provider.ts`, and `services/auth-session.service.ts`.

## 6. Coverage Gaps

No uncovered auth branches remained after the coverage-review pass.

The project-wide coverage text output is low when run with the `auth` filter because Vitest still reports all `src/modules/**/*.ts` files. The auth-specific JSON entries are fully covered.

## 7. Duplicate or Overlapping Tests

No duplicate auth tests were identified. Supabase failure propagation is tested separately for full authentication and token-only verification because those are distinct public service methods.

## 8. Skipped or Todo Tests

No `test.skip`, `describe.skip`, or `test.todo` entries exist in the auth test files.

## 9. Final Notes

The auth module test suite covers the security-critical token extraction, Supabase verification, local profile enforcement, token-only identity flow, middleware behavior, provider error mapping, and module export wiring.

No validator, repository, controller, route, transaction, or concurrency tests were generated because the auth module does not contain those layers or any write operations.

Validation commands:

- `npm test -- auth`: 4 test files passed, 17 tests passed.
- `npm run test:coverage -- auth`: auth files reached 100% statements, branches, functions, and lines.
- `npm test`: 72 test files passed, 522 tests passed.

# Test Report: notification

## 1. Summary

| Item             | Value |
| ---------------- | ----: |
| Test files       |     6 |
| Test cases       |    50 |
| Service tests    |    10 |
| Validator tests  |     4 |
| Controller tests |    12 |
| Route tests      |    10 |
| Repository tests |    13 |
| Utility tests    |     0 |

## 2. Test Files

| File                                                                | Type        | Purpose                                                                                                                                                                         |
| ------------------------------------------------------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `tests/unit/modules/notification/notification.service.test.ts`      | Unit        | Covers token delegation, notification persistence, Firebase multicast payloads, priority selection, stale-token cleanup, Firebase failure handling, and read/delete delegation. |
| `tests/unit/modules/notification/notification.validator.test.ts`    | Unit        | Covers register/remove token schema acceptance, trimming, missing fields, invalid types, empty strings, and whitespace strings.                                                 |
| `tests/unit/modules/notification/notification.controller.test.ts`   | Unit        | Covers authenticated-user extraction, store header checks, query defaults/parsing, service calls, success responses, bad requests, and service error propagation.               |
| `tests/unit/modules/notification/notification.repository.test.ts`   | Unit        | Covers Prisma query shapes for token upsert/delete/find, notification create/list/read/delete/read-all, bulk token deletion, and store-name fallback.                           |
| `tests/unit/modules/notification/notification.module.test.ts`       | Unit        | Covers singleton module wiring for repository, service, and controller exports.                                                                                                 |
| `tests/integration/modules/notification/notification.route.test.ts` | Integration | Covers Express route registration, authentication middleware behavior, body validation, controller dispatch, `/read-all` routing, and async error forwarding.                   |

## 3. Test Cases

### Service

| Test Case                                                                     | Purpose                                                                    |
| ----------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| registerToken upserts the user FCM token                                      | Verifies token registration delegates to repository.                       |
| removeToken deletes all matching token rows                                   | Verifies token removal delegates to repository.                            |
| creates an in-app notification and skips Firebase when the user has no tokens | Ensures notification is persisted and push send is skipped without tokens. |
| sends normal-priority push notifications with reference data                  | Verifies normal Firebase payload shape and metadata.                       |
| uses high priority for urgent notification types and cleans invalid tokens    | Verifies priority rules and cleanup of invalid/unregistered FCM tokens.    |
| does not delete tokens for non-stale Firebase failures                        | Ensures retryable/internal Firebase errors do not remove tokens.           |
| ignores stale Firebase failures that do not map to a local token              | Covers defensive cleanup guard for response/token length mismatch.         |
| does not clean stale Firebase failures for blank token values                 | Covers defensive cleanup guard for falsy token values.                     |
| logs and swallows Firebase send failures after persisting the notification    | Ensures push infrastructure failures do not fail the service method.       |
| delegates notification queries and mutations to the repository                | Verifies list, mark-read, soft-delete, and mark-all-read delegation.       |

### Validator

| Test Case                                                                         | Purpose                                      |
| --------------------------------------------------------------------------------- | -------------------------------------------- |
| registerTokenBodySchema accepts a valid token and trims whitespace                | Verifies valid token normalization.          |
| registerTokenBodySchema rejects missing, non-string, empty, and whitespace tokens | Verifies register-token validation failures. |
| removeTokenBodySchema accepts a valid token and trims whitespace                  | Verifies valid remove-token normalization.   |
| removeTokenBodySchema rejects missing, non-string, empty, and whitespace tokens   | Verifies remove-token validation failures.   |

### Controller

| Test Case                                                       | Purpose                                                 |
| --------------------------------------------------------------- | ------------------------------------------------------- |
| registerToken uses the authenticated user and request token     | Verifies user-scoped token registration response.       |
| removeToken removes the request token                           | Verifies token removal response.                        |
| getNotifications uses defaults and the store header             | Verifies default pagination and store-scoped list call. |
| getNotifications parses pagination and type filters             | Verifies query parsing and type filter forwarding.      |
| getNotifications returns bad request when x-store-id is missing | Verifies required store header guard.                   |
| markAsRead marks the user notification as read                  | Verifies user-scoped read mutation.                     |
| deleteNotification soft-deletes the user notification           | Verifies user-scoped soft delete mutation.              |
| markAllAsRead requires the store header                         | Verifies required store header guard.                   |
| markAllAsRead marks all active store notifications as read      | Verifies user/store-scoped bulk read mutation.          |
| testSend requires the store header                              | Verifies required store header guard.                   |
| testSend creates and sends a notification                       | Verifies test-send request mapping.                     |
| propagates service failures to the async route wrapper          | Verifies controller does not swallow service errors.    |

### Route

| Test Case                                                                 | Purpose                                          |
| ------------------------------------------------------------------------- | ------------------------------------------------ |
| routes POST /register-token through auth, body validation, and controller | Verifies route middleware and handler wiring.    |
| rejects invalid register-token bodies before controller execution         | Verifies body validator blocks invalid payloads. |
| routes POST /remove-token through auth, body validation, and controller   | Verifies route middleware and handler wiring.    |
| routes POST /test-send through auth and controller                        | Verifies test-send route wiring.                 |
| routes GET /notifications through auth and controller                     | Verifies list route wiring.                      |
| routes PATCH /:notificationId/read through auth and controller            | Verifies mark-read route wiring.                 |
| routes DELETE /:notificationId through auth and controller                | Verifies delete route wiring.                    |
| routes PATCH /read-all through auth and controller                        | Verifies bulk read route wiring.                 |
| does not call controllers when authentication rejects the request         | Verifies auth short-circuit behavior.            |
| forwards controller errors through asyncWrapper to the error handler      | Verifies async error forwarding.                 |

### Repository

| Test Case                                                                                  | Purpose                                                     |
| ------------------------------------------------------------------------------------------ | ----------------------------------------------------------- |
| upsertToken creates or reassigns a token by token value                                    | Verifies Prisma upsert query shape.                         |
| deleteTokensByValue deletes all rows for a token value                                     | Verifies token delete query shape.                          |
| findTokensByUserId queries tokens for one user                                             | Verifies token lookup query shape.                          |
| createNotification stores notification data and normalizes missing referenceId to null     | Verifies create query and null normalization.               |
| createNotification preserves a provided referenceId                                        | Verifies referenceId persistence.                           |
| getUserNotifications queries active store-scoped notifications without type filter for ALL | Verifies list query defaults and active/store/user scoping. |
| getUserNotifications applies comma-separated type filters                                  | Verifies multi-type filtering.                              |
| markAsRead only updates the active notification owned by the user                          | Verifies safe read update scope.                            |
| softDelete marks the user notification inactive                                            | Verifies soft-delete query scope.                           |
| deleteMultipleTokens deletes stale tokens in bulk                                          | Verifies bulk stale-token cleanup query.                    |
| markAllAsRead updates unread active notifications for a user and store                     | Verifies bulk read update scope.                            |
| getStoreNameById returns the store name when present                                       | Verifies store lookup query shape.                          |
| getStoreNameById falls back when the store is missing                                      | Verifies display fallback behavior.                         |

### Utility

| Test Case | Purpose                                  |
| --------- | ---------------------------------------- |
| None      | No notification utility functions exist. |

## 4. Business Requirement Coverage

| Requirement                                                               | Covered By                                        | Status  |
| ------------------------------------------------------------------------- | ------------------------------------------------- | ------- |
| Register an FCM token for the authenticated user.                         | Service, Controller, Route, Repository, Validator | Covered |
| Remove an FCM token.                                                      | Service, Controller, Route, Repository, Validator | Covered |
| Persist an in-app notification before push delivery.                      | Service, Repository                               | Covered |
| Include store name in notification display title.                         | Service, Repository                               | Covered |
| Skip Firebase delivery when the user has no tokens.                       | Service                                           | Covered |
| Send Firebase multicast payloads with notification metadata.              | Service                                           | Covered |
| Use high priority for urgent notification types.                          | Service                                           | Covered |
| Clean invalid or unregistered FCM tokens after Firebase failures.         | Service, Repository                               | Covered |
| Do not remove tokens for retryable/non-stale Firebase failures.           | Service                                           | Covered |
| Swallow and log Firebase infrastructure errors.                           | Service                                           | Covered |
| List active user notifications scoped to store and optional type filters. | Controller, Repository                            | Covered |
| Mark a user-owned active notification as read.                            | Service, Controller, Route, Repository            | Covered |
| Soft-delete a user-owned notification.                                    | Service, Controller, Route, Repository            | Covered |
| Mark all unread active notifications as read for a user and store.        | Service, Controller, Route, Repository            | Covered |
| Reject missing `x-store-id` where store context is required.              | Controller                                        | Covered |
| Enforce authentication on all notification routes.                        | Route                                             | Covered |
| Enforce token body validation for token routes.                           | Validator, Route                                  | Covered |
| Propagate controller/service errors through async wrappers.               | Controller, Route                                 | Covered |

## 5. Coverage Summary

| Metric     |                                                      Value |
| ---------- | ---------------------------------------------------------: |
| Statements |   4.35% project-wide scoped run; notification service 100% |
| Branches   | 3.59% project-wide scoped run; notification service 96.15% |
| Functions  |   5.02% project-wide scoped run; notification service 100% |
| Lines      |   4.41% project-wide scoped run; notification service 100% |

## 6. Coverage Gaps

Project coverage output includes every backend module even when running only notification tests, so the project-wide percentages are not representative of this module alone.

No meaningful notification behavior remains untested. V8 still reports a small branch-detail gap in `notification.service.ts` around the defensive `tokens[idx] && tokens[idx].token` guard in stale-token cleanup, despite tests covering mapped tokens, unmapped response indexes, blank token values, stale Firebase errors, and non-stale Firebase errors.

## 7. Duplicate or Overlapping Tests

No duplicate test cases were identified. Some controller and route tests intentionally overlap at different boundaries: controller tests verify request mapping and responses, while route tests verify Express middleware ordering and dispatch.

## 8. Skipped or Todo Tests

No `test.skip`, `describe.skip`, or `test.todo` entries were added for notification.

## 9. Final Notes

The notification module now has unit coverage across service, validator, controller, repository, and module wiring, plus integration coverage for route registration and middleware behavior. Firebase and Prisma are mocked at the module boundary, so these tests validate business behavior and query shape without requiring external services.

The module is ready for broader integration testing if a real Firebase/test-database workflow is introduced later.

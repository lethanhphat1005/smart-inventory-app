# Test Report: chat-bot

## 1. Summary

| Item             | Value |
| ---------------- | ----: |
| Test files       |     9 |
| Test cases       |    49 |
| Service tests    |    16 |
| Validator tests  |     6 |
| Controller tests |     4 |
| Route tests      |     8 |
| Repository tests |     0 |
| Utility tests    |    15 |

## 2. Test Files

| File                                                        | Type        | Purpose                                                                                                            |
| ----------------------------------------------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------ |
| `tests/unit/modules/chat-bot/chatbot.service.test.ts`       | Unit        | Covers chatbot orchestration, Redis locks, LLM tool branches, draft confirmation, authorization, and cleanup.      |
| `tests/unit/modules/chat-bot/chatbot.controller.test.ts`    | Unit        | Covers request context extraction, locale selection, service delegation, and response shape.                       |
| `tests/unit/modules/chat-bot/chatbot.validator.test.ts`     | Unit        | Covers chat and confirmation request body validation.                                                              |
| `tests/unit/modules/chat-bot/chat-memory.service.test.ts`   | Unit        | Covers Redis chat history and temporary cart persistence behavior.                                                 |
| `tests/unit/modules/chat-bot/chatbot.mapper.test.ts`        | Unit        | Covers Redis key builders, inventory name normalization, exact match lookup, and coordinator messages.             |
| `tests/unit/modules/chat-bot/chatbot-guard.helper.test.ts`  | Unit        | Covers tool-call eligibility guardrails.                                                                           |
| `tests/unit/modules/chat-bot/product-search.helper.test.ts` | Unit        | Covers inventory keyword cleanup and search fallbacks.                                                             |
| `tests/unit/modules/chat-bot/time-resolver.helper.test.ts`  | Unit        | Covers relative time range resolution.                                                                             |
| `tests/integration/modules/chat-bot/chatbot.route.test.ts`  | Integration | Covers Express route registration, middleware order, validation, auth/store rejection, and async error forwarding. |

## 3. Test Cases

### Service

| Test Case                                                                          | Purpose                                                   |
| ---------------------------------------------------------------------------------- | --------------------------------------------------------- |
| rejects a new message when the Redis processing lock is already held               | Verifies concurrent chat requests are rejected.           |
| returns a casual response without saving out-of-domain history                     | Verifies casual/out-of-domain messages are not persisted. |
| handles an empty low-stock inventory and saves assistant history                   | Verifies empty inventory low-stock behavior.              |
| blocks staff users from querying audit logs                                        | Verifies audit log authorization.                         |
| returns product information for an exact inventory match                           | Verifies exact product lookup.                            |
| asks the user to choose when product lookup has multiple non-exact matches         | Verifies ambiguous product selection flow.                |
| saves current cart progress and refuses export quantities above stock              | Verifies export stock protection.                         |
| allows managers to query audit logs and maps audit log display data                | Verifies authorized audit log query and response mapping. |
| returns general restock suggestions from smart decision analysis                   | Verifies restock analysis integration.                    |
| clears stale draft references before creating a transaction draft                  | Verifies stale Redis draft reference cleanup.             |
| throws gone when confirming an expired draft action                                | Verifies expired draft handling.                          |
| forbids confirming another store or user draft action                              | Verifies cross-store/user draft protection.               |
| cancels a draft and clears chat, cart, draft, and draft reference state            | Verifies cancellation cleanup.                            |
| confirms an import draft and clears temporary state                                | Verifies import transaction confirmation.                 |
| wraps unexpected processMessage failures as AI system errors and releases the lock | Verifies error wrapping and lock release.                 |
| clears chat history, cart session, and draft reference for a user                  | Verifies manual clear-history cleanup.                    |

### Validator

| Test Case                                                  | Purpose                                    |
| ---------------------------------------------------------- | ------------------------------------------ |
| accepts and trims a valid chat message                     | Verifies chat body normalization.          |
| rejects empty and whitespace-only messages                 | Verifies required message rule.            |
| rejects messages longer than 100 characters                | Verifies message length boundary.          |
| rejects missing or non-string message values               | Verifies type safety.                      |
| accepts and trims a draft action confirmation              | Verifies confirmation body normalization.  |
| rejects empty draft IDs and non-boolean confirmation flags | Verifies confirmation validation failures. |

### Controller

| Test Case                                                                      | Purpose                                           |
| ------------------------------------------------------------------------------ | ------------------------------------------------- |
| processChat uses store context, authenticated user, payload, and header locale | Verifies service input wiring.                    |
| processChat falls back to payload locale and then Vietnamese                   | Verifies locale fallback behavior.                |
| confirmAction delegates draft confirmation with locale default                 | Verifies draft confirmation delegation.           |
| clearHistory clears both chat history and temporary sessions                   | Verifies clear-history response and service call. |

### Route

| Test Case                                                                          | Purpose                                               |
| ---------------------------------------------------------------------------------- | ----------------------------------------------------- |
| routes POST / through auth, store context, rate limits, validation, and controller | Verifies main chat route wiring.                      |
| rejects invalid chat messages before rate-limited controller execution             | Verifies body validation blocks controller execution. |
| routes POST /confirm through auth, store context, validation, and controller       | Verifies confirmation route wiring.                   |
| rejects invalid confirmation bodies before controller execution                    | Verifies confirmation validation.                     |
| routes DELETE /history through auth, store context, and controller                 | Verifies clear-history route wiring.                  |
| stops route execution when authentication rejects the request                      | Verifies auth middleware short-circuit.               |
| stops route execution when store context middleware rejects the request            | Verifies store-context short-circuit.                 |
| forwards controller errors through asyncWrapper to the error handler               | Verifies async error forwarding.                      |

### Repository

| Test Case | Purpose                                                                                    |
| --------- | ------------------------------------------------------------------------------------------ |
| None      | This module has no repository. External repositories/services are mocked in service tests. |

### Utility

| Test Case                                                                    | Purpose                                             |
| ---------------------------------------------------------------------------- | --------------------------------------------------- |
| returns an empty history when Redis has no chat data                         | Verifies empty memory read.                         |
| saves only the newest twelve messages and removes leading tool messages      | Verifies history trimming and tool-message cleanup. |
| reads, saves, and clears cart sessions by store and user                     | Verifies cart session persistence.                  |
| builds Redis keys with store, user, and draft identifiers                    | Verifies key builders.                              |
| normalizes inventory names for exact matching                                | Verifies inventory normalization.                   |
| finds exact inventory matches after normalization                            | Verifies exact-match helper.                        |
| builds coordinator messages with system, prior history, and new user message | Verifies LLM coordinator context assembly.          |
| blocks product lookup when the product name is missing                       | Verifies product guardrail.                         |
| blocks transaction tools without product and quantity information            | Verifies transaction guardrail.                     |
| blocks non-positive product quantities                                       | Verifies quantity guardrail.                        |
| allows valid transaction requests                                            | Verifies valid tool parameters pass.                |
| cleans package words and slang before searching inventory                    | Verifies search keyword cleanup.                    |
| falls back to parenthesis-stripped and normalized keywords                   | Verifies search fallbacks.                          |
| returns an empty range for missing or unknown periods                        | Verifies time resolver defensive path.              |
| resolves today and yesterday using the Vietnam time boundary                 | Verifies relative date boundaries.                  |

## 4. Business Requirement Coverage

| Requirement                                                                | Covered By                                          | Status            |
| -------------------------------------------------------------------------- | --------------------------------------------------- | ----------------- |
| Authenticated, store-scoped chat requests only                             | Route tests, controller tests                       | Covered           |
| Reject invalid chat and confirmation payloads                              | Validator tests, route validation tests             | Covered           |
| Prevent concurrent processing per store/user                               | Redis lock service test                             | Covered           |
| Release processing locks on success and failure                            | Service success/error tests                         | Covered           |
| Preserve useful chat history and avoid saving casual/out-of-domain history | Memory and service tests                            | Covered           |
| Low-stock query handles empty inventory                                    | Service low-stock test                              | Covered           |
| Product lookup handles exact and ambiguous matches                         | Service product-info tests                          | Covered           |
| Transaction draft creation stores cart and draft state                     | Service draft creation test                         | Covered           |
| Export draft refuses quantities above inventory stock                      | Service export stock test                           | Covered           |
| Draft confirmation enforces store/user ownership                           | Service forbidden draft test                        | Covered           |
| Expired draft confirmation returns gone                                    | Service expired draft test                          | Covered           |
| Draft cancellation and confirmation clean Redis, history, and cart         | Service confirmation/cancellation tests             | Covered           |
| Staff cannot query audit logs                                              | Service audit authorization test                    | Covered           |
| Manager/owner audit log queries return mapped user-facing data             | Service manager audit test                          | Covered           |
| Restock analysis can return smart-decision suggestions                     | Service restock test                                | Covered           |
| Product-search aliases and fallbacks are applied                           | ProductSearchHelper tests                           | Covered           |
| Relative time periods are resolved in Vietnam time                         | TimeResolverHelper tests                            | Partially Covered |
| Rate limiter uses user or IP key                                           | Route verifies rate-limit middleware placement only | Partially Covered |
| OpenAI provider request/response mapping                                   | Not covered                                         | Not Covered       |
| Module singleton wiring with real dependencies                             | Not covered                                         | Not Covered       |

## 5. Coverage Summary

Note: values are from `npx vitest run --coverage tests/unit/modules/chat-bot tests/integration/modules/chat-bot`. Vitest reports this module across multiple directory rows.

| Metric     |                                            Value |
| ---------- | -----------------------------------------------: |
| Statements | chat-bot 81.81%, services 77.24%, helpers 70.32% |
| Branches   | chat-bot 66.66%, services 55.76%, helpers 58.88% |
| Functions  |    chat-bot 87.5%, services 79.41%, helpers 100% |
| Lines      |    chat-bot 81.57%, services 77.43%, helpers 70% |

## 6. Coverage Gaps

- `chatbot-rate-limit.middleware.ts` is not directly covered because route tests mock the rate-limit middleware to avoid timing/global state.
- `chatbot.module.ts` singleton wiring is not covered because it imports real Redis, OpenAI, and cross-module services.
- `openai.provider.ts` is not covered; it should be tested separately with the OpenAI client mocked.
- Some private service branches remain uncovered: malformed/unsupported tool calls, low-stock non-empty pagination note, product not found, transaction ambiguous product selection, export draft confirmation, cross-sell analysis, no-data restock analysis, audit-log malformed JSON/newValue fallback, and failed lock release logging.
- Time resolver covers `today` and `yesterday`; week/month branches remain uncovered.

## 7. Duplicate or Overlapping Tests

- No duplicate tests identified. Route tests validate Express wiring; controller tests validate request-to-service mapping; service tests validate business behavior.

## 8. Skipped or Todo Tests

- No `test.skip`, `describe.skip`, or `test.todo` cases were added.

## 9. Final Notes

The chat-bot module now has focused unit and route coverage for the core business risks: authentication/store routing, payload validation, Redis locking, draft ownership, transaction draft cleanup, export stock limits, audit-log authorization, product matching, memory behavior, and restock suggestions.

Remaining gaps are mostly integration-boundary concerns: real OpenAI provider mapping, rate limiter key generation under real `express-rate-limit`, module singleton wiring, and deeper rare branches in private service helpers. The module is ready for broader integration testing with mocked external APIs or a controlled test Redis if those boundaries need stronger guarantees.

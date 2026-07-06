# Test Report: search

## 1. Summary

| Item             | Value |
| ---------------- | ----: |
| Test files       |     5 |
| Test cases       |    38 |
| Service tests    |     5 |
| Validator tests  |    12 |
| Controller tests |     4 |
| Route tests      |     6 |
| Repository tests |    11 |
| Utility tests    |     0 |

## 2. Test Files

| File                                                            | Type        | Purpose                                                                                                                                                 |
| --------------------------------------------------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `backend/tests/unit/modules/search/search.service.test.ts`      | Unit        | Verifies service delegation, pagination response shaping, signed URL mapping, and failure propagation.                                                  |
| `backend/tests/unit/modules/search/search.validator.test.ts`    | Unit        | Verifies keyword and prefix query schema coercion, defaults, trimming, and boundary validation.                                                         |
| `backend/tests/unit/modules/search/search.controller.test.ts`   | Unit        | Verifies store-context extraction, validated query forwarding, response status/body, and missing store-context failure.                                 |
| `backend/tests/unit/modules/search/search.repository.test.ts`   | Unit        | Verifies raw search short-circuits, raw query inputs, row mapping, prefix query shape, store scoping, active-status filtering, and limit normalization. |
| `backend/tests/integration/modules/search/search.route.test.ts` | Integration | Verifies route registration, auth/store-context/read-permission middleware, validator behavior, and controller routing.                                 |

## 3. Test Cases

### Service

| Test Case                                                                              | Purpose                                                                         |
| -------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| `searchProductPackagesByKeyword normalizes pagination and signs package images`        | Covers package keyword happy path, pagination normalization, and image signing. |
| `searchProductsByKeyword returns paginated products with signed image URLs`            | Covers product keyword happy path with nullable image behavior.                 |
| `searchProductsByPrefix signs autocomplete product images without pagination metadata` | Covers prefix search response mapping.                                          |
| `uses the default image bucket when STORAGE_BUCKET is not configured`                  | Covers default bucket fallback for image signing.                               |
| `propagates repository failures`                                                       | Covers unexpected repository errors.                                            |

### Validator

| Test Case                                                                    | Purpose                                              |
| ---------------------------------------------------------------------------- | ---------------------------------------------------- |
| `accepts valid keyword search query, trims keyword, and coerces pagination`  | Covers valid keyword query coercion.                 |
| `applies default pagination values`                                          | Covers default keyword pagination.                   |
| `rejects empty keyword after trimming`                                       | Covers missing/blank keyword validation.             |
| `rejects keyword longer than 100 characters`                                 | Covers keyword max length.                           |
| `rejects invalid pagination boundaries`                                      | Covers keyword pagination min/max boundaries.        |
| `accepts valid prefix query, trims prefix, and coerces limit`                | Covers valid prefix query coercion.                  |
| `allows omitted prefix limit`                                                | Covers optional prefix limit.                        |
| `rejects empty prefix after trimming`                                        | Covers missing/blank prefix validation.              |
| `rejects prefix longer than 100 characters`                                  | Covers prefix max length.                            |
| `rejects prefix limits outside the allowed range`                            | Covers prefix limit boundaries.                      |
| `validateGetProductsByKeyword stores the validated query in response locals` | Covers legacy keyword validator middleware behavior. |
| `validateGetProductsByPrefix stores the validated query in response locals`  | Covers legacy prefix validator middleware behavior.  |

### Controller

| Test Case                                                              | Purpose                                                    |
| ---------------------------------------------------------------------- | ---------------------------------------------------------- |
| `returns product package keyword search results for the current store` | Covers package keyword controller delegation and response. |
| `returns product keyword search results for the current store`         | Covers product keyword controller delegation and response. |
| `returns product prefix search results for the current store`          | Covers prefix controller delegation and response.          |
| `throws when store context is missing`                                 | Covers store-context failure path.                         |

### Route

| Test Case                                                                                         | Purpose                                               |
| ------------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| `routes GET /search/products through auth, store context, read permission, and keyword validator` | Covers product keyword route middleware and handler.  |
| `rejects invalid product keyword query before controller execution`                               | Covers keyword route validation failure.              |
| `routes GET /search/products/prefix through prefix validator`                                     | Covers prefix route middleware and handler.           |
| `rejects invalid prefix query before controller execution`                                        | Covers prefix route validation failure.               |
| `routes GET /search/product-packages using the current prefix query validator`                    | Covers current product-package route wiring.          |
| `rejects keyword-shaped product package search because the route currently requires prefix`       | Documents current product-package validator behavior. |

### Repository

| Test Case                                                                                     | Purpose                                                                     |
| --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| `searchProductPackagesByKeyword returns early when keyword is empty`                          | Covers empty keyword short-circuit.                                         |
| `searchProductPackagesByKeyword queries store-scoped active packages and maps decimal prices` | Covers package raw query inputs, pagination offset, and Decimal conversion. |
| `searchProductPackagesByKeyword returns early when escaped tokens are empty`                  | Covers tsquery operator-only keyword short-circuit.                         |
| `searchProductPackagesByKeyword maps null decimal prices and missing count rows`              | Covers nullable package price mapping and count fallback.                   |
| `searchProductsByKeyword escapes tsquery operators and maps product rows`                     | Covers token escaping, raw query inputs, and product row mapping.           |
| `searchProductsByKeyword returns early when keyword is empty`                                 | Covers empty product keyword short-circuit.                                 |
| `searchProductsByKeyword returns early when escaped tokens are empty`                         | Covers product tsquery operator-only keyword short-circuit.                 |
| `searchProductsByKeyword defaults missing count rows to zero total items`                     | Covers defensive count fallback.                                            |
| `searchProductsByPrefix returns early for blank prefix`                                       | Covers blank prefix short-circuit.                                          |
| `searchProductsByPrefix scopes active products by store and clamps limit`                     | Covers Prisma query shape and max prefix limit.                             |
| `searchProductsByPrefix uses default limit for invalid values`                                | Covers invalid prefix limit default.                                        |

### Utility

| Test Case | Purpose                                     |
| --------- | ------------------------------------------- |
| None      | No search-specific utility functions exist. |

## 4. Business Requirement Coverage

| Requirement                                                                                                   | Covered By                                              | Status  |
| ------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- | ------- |
| Product keyword search is store-scoped and active-product-only                                                | Repository raw query assertions, route permission tests | Covered |
| Product package keyword search is store-scoped and active-product/active-package-only                         | Repository raw query assertions                         | Covered |
| Keyword search supports pagination metadata                                                                   | Service and repository tests                            | Covered |
| Search result image paths are converted to signed URLs                                                        | Service tests                                           | Covered |
| Prefix autocomplete is store-scoped, active-product-only, case-insensitive, sorted by name, and limited to 20 | Repository tests                                        | Covered |
| Blank keyword/prefix inputs do not hit the database                                                           | Repository and validator tests                          | Covered |
| Invalid route queries fail before controller execution                                                        | Route tests                                             | Covered |
| Search endpoints require authentication, store context, and product read permission                           | Route tests                                             | Covered |
| Repository/database failures propagate to error handling                                                      | Service failure test                                    | Covered |

## 5. Coverage Summary

| Metric     |  Value |
| ---------- | -----: |
| Statements | 96.59% |
| Branches   |   100% |
| Functions  |   100% |
| Lines      | 96.51% |

## 6. Coverage Gaps

- `search.route.ts` currently validates `/search/product-packages` with `searchByPrefixQuerySchema`, while the controller/service method is keyword-based and the route comment documents a `keyword` query. The route tests document current behavior instead of changing production logic.
- Raw SQL text is not fully parsed in tests; repository tests verify Prisma SQL values and observable mapping/short-circuit behavior.

## 7. Duplicate or Overlapping Tests

No duplicate or overlapping scenarios identified.

## 8. Skipped or Todo Tests

No `test.skip`, `describe.skip`, or `test.todo` cases were added.

## 9. Final Notes

The search module now has initial unit and route integration coverage for service, validator, controller, repository, and route behavior. The suite is ready for coverage validation; the main remaining product question is whether `/search/product-packages` should accept keyword pagination queries or truly behave as a prefix route.

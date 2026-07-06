# Test Report: barcode

## 1. Summary

| Item             | Value |
| ---------------- | ----: |
| Test files       |     9 |
| Test cases       |    55 |
| Service tests    |    21 |
| Validator tests  |     7 |
| Controller tests |     6 |
| Route tests      |     8 |
| Repository tests |     8 |
| Utility tests    |     5 |

## 2. Test Files

| File                                                                              | Type       | Purpose                                                                             |
| --------------------------------------------------------------------------------- | ---------- | ----------------------------------------------------------------------------------- |
| `backend/tests/unit/modules/barcode/barcodes.service.test.ts`                     | Service    | Scan, cache, candidate scoring, confirm mapping, stale-provider fallback            |
| `backend/tests/unit/modules/barcode/product-package-barcode.service.test.ts`      | Service    | Create/remove package barcode mapping behavior                                      |
| `backend/tests/unit/modules/barcode/barcode-provider.service.test.ts`             | Service    | Provider orchestration, OpenFoodFacts/UPCItemDB normalization, provider fallthrough |
| `backend/tests/unit/modules/barcode/barcode.validator.test.ts`                    | Validator  | Scan, confirm, create, and remove schema validation                                 |
| `backend/tests/unit/modules/barcode/barcode.controller.test.ts`                   | Controller | Response mapping and service call wiring                                            |
| `backend/tests/unit/modules/barcode/barcode.repository.test.ts`                   | Repository | Prisma query shape and DTO mapping for barcode/cache repositories                   |
| `backend/tests/unit/modules/barcode/barcode.util.test.ts`                         | Utility    | Normalization, tokenization, noise reduction, package token extraction              |
| `backend/tests/integration/modules/barcode/barcode.route.test.ts`                 | Route      | `/barcodes/scan` and `/barcodes/confirm` middleware/validator wiring                |
| `backend/tests/integration/modules/barcode/product-package-barcode.route.test.ts` | Route      | Product-package barcode create/delete route wiring                                  |

## 3. Test Cases

### Service

| Test Case                                                                                        | Purpose                                                |
| ------------------------------------------------------------------------------------------------ | ------------------------------------------------------ |
| `uses verified exact mapping before cache or provider lookup`                                    | Exact verified mapping returns immediately             |
| `returns scored candidates and prefill from fresh cache`                                         | Fresh cache is used and candidate matches are returned |
| `creates cache from provider result and returns not found with prefill when no candidate scores` | Provider result is cached and prefill is exposed       |
| `updates expired cache and falls back to stale cache when provider fails`                        | Expired cache update and stale-cache fallback          |
| `throws a bad gateway error when provider lookup fails without cache`                            | Provider failure without cache maps to BAD_GATEWAY     |
| `scores candidates using name, brand, and package signals`                                       | Full-signal candidate scoring                          |
| `scores candidates with name-only and single auxiliary signal thresholds`                        | Dynamic score thresholds                               |
| `sorts multiple candidate matches by score`                                                      | Candidate ordering                                     |
| `rejects low scoring candidates`                                                                 | Low-score candidate rejection                          |
| `uses cache TTL by status`                                                                       | Status-specific TTL behavior                           |
| `confirms a new verified mapping for an active product package`                                  | User-confirmed mapping creation                        |
| `keeps confirm idempotent for the same package and rejects conflicts`                            | Idempotent same-package confirm and duplicate conflict |
| `rejects confirm when product package is not active in the store`                                | Missing/inactive package protection                    |
| `creates a verified mapping for an active package`                                               | Barcode-flow create mapping                            |
| `returns the existing mapping when creation is idempotent`                                       | Create flow idempotency                                |
| `rejects missing packages and cross-package duplicate mappings`                                  | Missing package and duplicate protection               |
| `removes an owned mapping`                                                                       | Delete owned mapping                                   |
| `rejects remove when mapping is missing or belongs to another package`                           | Delete missing/wrong-package protection                |
| `returns the first valid OpenFoodFacts result with normalized and extracted fields`              | First provider valid result                            |
| `falls through to UPCItemDB when OpenFoodFacts is not found`                                     | Provider fallthrough                                   |
| `returns not_found when providers fail or have no items`                                         | Provider not-found fallback                            |

### Validator

| Test Case                                              | Purpose                                   |
| ------------------------------------------------------ | ----------------------------------------- |
| `accepts a valid barcode and trims whitespace`         | Scan payload trimming                     |
| `rejects short, long, and unsupported barcode values`  | Scan validation failures                  |
| `accepts a valid confirm payload`                      | Confirm payload success                   |
| `rejects missing barcode and invalid productPackageId` | Confirm validation failures               |
| `accepts create params and body`                       | Product-package barcode create success    |
| `accepts remove params and trims barcode`              | Delete params success                     |
| `rejects invalid mapping params`                       | Product-package barcode params validation |

### Controller

| Test Case                                                       | Purpose                                     |
| --------------------------------------------------------------- | ------------------------------------------- |
| `scans a barcode for the current store and maps candidate DTOs` | Scan service call and candidate DTO mapping |
| `maps exact and not-found scan results`                         | Exact/not-found response shapes             |
| `omits optional prefill for candidate and not-found responses`  | Optional response field omission            |
| `confirms a barcode mapping and returns created status`         | Confirm controller success                  |
| `creates a package barcode mapping from params and body`        | Product-package create controller success   |
| `deletes a package barcode mapping from params`                 | Product-package delete controller success   |

### Route

| Test Case                                                                                                           | Purpose                                |
| ------------------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| `routes POST /barcodes/scan through auth, store context, read permission, and body validator`                       | Scan route middleware order            |
| `rejects invalid scan payload before controller execution`                                                          | Scan validator blocks invalid body     |
| `routes POST /barcodes/confirm through write permission and body validator`                                         | Confirm route middleware order         |
| `rejects invalid confirm payload before controller execution`                                                       | Confirm validator blocks invalid body  |
| `routes POST /product-packages/:productPackageId/barcodes through write permission and validators`                  | Product-package create route wiring    |
| `rejects invalid create params and body before controller execution`                                                | Create validators block invalid inputs |
| `routes DELETE /product-packages/:productPackageId/barcodes/:barcode through write permission and params validator` | Delete route wiring                    |
| `rejects invalid delete params before controller execution`                                                         | Delete validator blocks invalid params |

### Repository

| Test Case                                                                       | Purpose                           |
| ------------------------------------------------------------------------------- | --------------------------------- |
| `findByBarcode scopes lookup to active package and active product in store`     | Store-scoped active mapping query |
| `checkOneExistedInStore maps confidence and returns null when not found`        | Duplicate check query and mapping |
| `creates mappings and includes optional confidence and type only when provided` | Create query shape                |
| `checks barcode existence and deletes by barcode plus package id`               | Count/delete query shape          |
| `finds one barcode by active product package id`                                | Package barcode lookup query      |
| `finds the newest cache row by barcode`                                         | Cache lookup query                |
| `creates and updates cache rows with normalized and extracted fields`           | Cache create/update query shape   |
| `marks a cache row as used`                                                     | Cache hit update                  |

### Utility

| Test Case                                                                | Purpose                   |
| ------------------------------------------------------------------------ | ------------------------- |
| `normalizes text by removing accents, punctuation, and duplicate spaces` | Text normalization        |
| `normalizes API payload and returns null when no signal remains`         | API payload normalization |
| `tokenizes unique non-empty tokens`                                      | Tokenization              |
| `reduces provider title noise with configurable options`                 | Noise reduction options   |
| `extracts package-related tokens from free text`                         | Package token extraction  |

## 4. Business Requirement Coverage

| Requirement                                                       | Covered By                          | Status  |
| ----------------------------------------------------------------- | ----------------------------------- | ------- |
| Verified barcode mapping returns exact product package            | `BarcodesService` exact-match test  | Covered |
| Unmapped barcode uses fresh cache before provider lookup          | Fresh-cache scan test               | Covered |
| Expired/missing cache calls provider and stores result            | Provider cache create/update tests  | Covered |
| Provider failure without cache returns BAD_GATEWAY                | Provider failure service test       | Covered |
| Provider failure with expired cache falls back to stale cache     | Stale-cache fallback test           | Covered |
| Candidate matching scores name, brand, and package text           | Candidate scoring tests             | Covered |
| Low-score candidates are rejected and candidates sort by score    | Low-score and sorting tests         | Covered |
| User-confirmed mappings are verified and high confidence          | Confirm mapping tests               | Covered |
| Barcode cannot map to a different package in same store           | Conflict tests in both services     | Covered |
| Same-package mapping creation/confirm is idempotent               | Idempotency tests in both services  | Covered |
| Product package must exist in current store before write/delete   | Missing package tests               | Covered |
| Delete requires barcode to belong to requested package            | Delete conflict test                | Covered |
| Routes require auth, store context, and product permissions       | Route tests                         | Covered |
| Request schemas reject invalid barcode/type/UUID values           | Validator and route rejection tests | Covered |
| Repositories scope barcode lookup to active store product/package | Repository query-shape tests        | Covered |

## 5. Coverage Summary

Targeted command:

`cd backend && npm run test:coverage -- --run tests/unit/modules/barcode tests/integration/modules/barcode`

Overall report includes every backend module, so the project-wide percentages are diluted by modules outside this workflow.

| Metric     |  Value |
| ---------- | -----: |
| Statements | 13.22% |
| Branches   | 24.15% |
| Functions  | 10.95% |
| Lines      | 13.39% |

Barcode-specific notable coverage:

| Area                 | Statements | Branches | Functions |  Lines |
| -------------------- | ---------: | -------: | --------: | -----: |
| barcode/controllers  |       100% |   92.85% |      100% |   100% |
| barcode/repositories |       100% |      92% |      100% |   100% |
| barcode/services     |     98.98% |   89.87% |      100% | 98.98% |
| barcode/utils        |     95.58% |    87.5% |      100% | 95.58% |

## 6. Coverage Gaps

- `barcodes.module.ts` remains uncovered; it only wires concrete singleton dependencies.
- `barcode-provider.service.ts` line 251 remains uncovered: UPCItemDB package-text extraction with neither `size` nor title package tokens.
- `barcodes.service.ts` line 54 remains uncovered: defensive `buildPrefill` null payload guard, not reachable through public service inputs in normal flows.
- `noise-reduction.util.ts` lines 73 and 103-104 remain uncovered: falsy input and explicit generic-word removal branch.
- Controller branch report still marks a candidate-match optional-field branch around line 37 as partial, despite explicit tests for candidate responses with and without `prefill`.

## 7. Duplicate or Overlapping Tests

- Route validator rejection tests overlap lightly with direct validator unit tests, but they verify different boundaries: route short-circuiting versus schema behavior.
- Service idempotency is tested in both `BarcodesService` and `ProductPackageBarcodeService` because each exposes a separate public flow.

## 8. Skipped or Todo Tests

- No `test.skip`, `describe.skip`, or `test.todo` cases were added for barcode.

## 9. Final Notes

The barcode module now has focused unit and route coverage for scan, provider lookup, cache behavior, candidate scoring, mapping creation, mapping deletion, validators, controllers, repositories, and utilities.

Remaining gaps are low-risk defensive/provider edge branches or module composition. Broader end-to-end testing with a real database and provider stubs would be the next layer if this flow needs persistence-level confidence beyond mocked Prisma query-shape tests.

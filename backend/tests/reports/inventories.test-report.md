# Test Report: inventories

## 1. Summary

| Item             | Value |
| ---------------- | ----: |
| Test files       |     5 |
| Test cases       |    56 |
| Service tests    |    17 |
| Validator tests  |    12 |
| Controller tests |     7 |
| Route tests      |     9 |
| Repository tests |    11 |
| Utility tests    |     0 |

## 2. Test Files

| File                                                                    | Type       | Purpose                                                                                                                             |
| ----------------------------------------------------------------------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `backend/tests/unit/modules/inventories/inventory.service.test.ts`      | Service    | Inventory listing, lookup, update, batch adjustment, create/restore, transaction inventory updates, soft delete, audit logs, events |
| `backend/tests/unit/modules/inventories/inventory.validator.test.ts`    | Validator  | Params, list query, create/update body, batch adjustment body, legacy query validator middleware                                    |
| `backend/tests/unit/modules/inventories/inventory.controller.test.ts`   | Controller | Store/user context extraction, service calls, response status mapping                                                               |
| `backend/tests/unit/modules/inventories/inventory.repository.test.ts`   | Repository | Prisma query shape, store scoping, DTO mapping, status derivation, atomic quantity updates                                          |
| `backend/tests/integration/modules/inventories/inventory.route.test.ts` | Route      | Auth/store/permission middleware wiring, validator short-circuiting, route handler selection                                        |

## 3. Test Cases

### Service

| Test Case                                                                                                                | Purpose                                                     |
| ------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------- |
| `normalizes pagination, signs product images, and returns paginated inventories`                                         | List inventory response and signed image URL mapping        |
| `uses low-stock repository for low-stock listing`                                                                        | Low-stock listing delegation                                |
| `returns an existing inventory scoped by store and package`                                                              | Detail lookup success                                       |
| `throws not found when inventory is missing`                                                                             | Missing inventory error                                     |
| `updates reorder threshold and writes an audit log inside a transaction`                                                 | Update transaction and audit behavior                       |
| `adjusts a valid batch, logs each item, emits discrepancy and batch change events, and strips inventoryId from response` | Batch adjustment success, discrepancy event, response shape |
| `rejects missing or inactive inventory before opening a transaction`                                                     | Missing/inactive adjustment guard                           |
| `prevents decrease adjustments that exceed current stock`                                                                | Manual decrease underflow guard                             |
| `rejects product packages outside the store`                                                                             | Create ownership guard                                      |
| `rejects duplicate active inventory inside the transaction`                                                              | Duplicate active inventory conflict                         |
| `restores inactive inventory and writes a create audit log`                                                              | Soft-deleted inventory restore                              |
| `creates new inventory and writes an audit log`                                                                          | New inventory creation                                      |
| `imports transaction quantities, writes audit logs, and emits batch inventory change`                                    | Import transaction stock increase                           |
| `rejects export transactions when requested quantity exceeds available stock`                                            | Pre-transaction export underflow guard                      |
| `surfaces database-level export quantity conflicts with failed package ids`                                              | Concurrent export DB guard failure                          |
| `exports transaction quantities, writes audit logs, and emits decreased inventory changes`                               | Export transaction success                                  |
| `soft deletes existing inventory and records a delete audit log`                                                         | Inventory soft delete                                       |

### Validator

| Test Case                                                                      | Purpose                    |
| ------------------------------------------------------------------------------ | -------------------------- |
| `accepts a valid productPackageId UUID`                                        | Valid params               |
| `rejects invalid productPackageId format`                                      | Invalid params             |
| `coerces pagination and applies defaults`                                      | Query coercion/defaults    |
| `accepts filters and trims keyword`                                            | Query filters              |
| `rejects invalid pagination, sort, and inventory status values`                | Query validation failures  |
| `accepts reorderThreshold updates including null`                              | Update body success        |
| `rejects empty payloads and negative thresholds`                               | Update body failures       |
| `accepts valid payloads and defaults quantity to zero`                         | Create body defaults       |
| `rejects negative quantities and thresholds`                                   | Create body failures       |
| `accepts valid batch adjustment items with nullable reason and note`           | Batch adjustment success   |
| `rejects empty batches, invalid UUIDs, invalid types, and negative quantities` | Batch adjustment failures  |
| `stores validated query on res.locals and calls next`                          | Query validator middleware |

### Controller

| Test Case                                                  | Purpose                      |
| ---------------------------------------------------------- | ---------------------------- |
| `gets inventories using store context and validated query` | List controller wiring       |
| `gets low stock inventories from validated query`          | Low-stock controller wiring  |
| `gets one inventory by product package id`                 | Detail controller wiring     |
| `updates inventory using store, user, params, and body`    | Update controller wiring     |
| `adjusts inventories using store, user, and body`          | Adjustment controller wiring |
| `creates inventory and returns created status`             | Create controller wiring     |
| `deletes inventory and returns a success message`          | Delete controller wiring     |

### Route

| Test Case                                                                                       | Purpose                                 |
| ----------------------------------------------------------------------------------------------- | --------------------------------------- |
| `routes GET /inventories through auth, store context, read permission, and query validator`     | List route middleware and handler       |
| `rejects invalid list query before controller execution`                                        | List query short-circuit                |
| `routes POST /inventories through write permission and body validator`                          | Create route middleware and handler     |
| `rejects invalid create body before controller execution`                                       | Create body short-circuit               |
| `routes GET /inventories/low-stock through read permission and query validator`                 | Low-stock route middleware and handler  |
| `routes product package detail, update, and delete through expected permissions and validators` | Product-package route chain             |
| `rejects invalid product package params and empty update bodies before controller execution`    | Params/update validator short-circuit   |
| `routes POST /inventories/adjustments through write permission and body validator`              | Adjustment route middleware and handler |
| `rejects invalid adjustment body before controller execution`                                   | Adjustment validator short-circuit      |

### Repository

| Test Case                                                                                          | Purpose                                           |
| -------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| `findManyByStoreId scopes to active store inventory and maps inventory status`                     | Active store-scoped list query and status mapping |
| `findManyByStoreId filters derived inventoryStatus after mapping`                                  | Derived status filtering                          |
| `findLowStockByStoreId returns early when count is zero`                                           | Low-stock empty branch                            |
| `findLowStockByStoreId fetches low stock ids then maps selected inventories`                       | Low-stock raw SQL plus follow-up select           |
| `findManyActiveByProductPackageIds returns empty input immediately or active store-scoped records` | Active package lookup                             |
| `findOneByProductPackageId returns null or active store-scoped inventory details`                  | Detail query and null branch                      |
| `adjusts quantity using set, increment, and decrement update shapes`                               | Quantity adjustment query shapes                  |
| `updates reorder threshold and soft deletes by product package id`                                 | Update and package soft delete helpers            |
| `checks ownership, creates, restores, and soft deletes inventory records`                          | Ownership/create/restore/delete query shapes      |
| `decreaseManyForTransaction records packages that fail the database quantity guard`                | Atomic export guard                               |
| `increaseManyForTransaction increments each inventory atomically`                                  | Atomic import update                              |

### Utility

| Test Case | Purpose                              |
| --------- | ------------------------------------ |
| N/A       | No inventory utility functions exist |

## 4. Business Requirement Coverage

| Requirement                                                                      | Covered By                                                                | Status  |
| -------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | ------- |
| Inventory listing is scoped to active products/packages in the current store     | Repository list tests, route read permission test                         | Covered |
| Product images are signed before list responses are returned                     | Service list test                                                         | Covered |
| Low-stock inventories are resolved through reorder threshold logic               | Repository and service low-stock tests                                    | Covered |
| Inventory detail must be found by store and product package                      | Service/repository detail tests                                           | Covered |
| Reorder threshold updates are transactional and audited                          | Service update test                                                       | Covered |
| Batch adjustments require every package to exist and be active                   | Service missing/inactive adjustment test                                  | Covered |
| Decrease adjustments cannot reduce stock below zero                              | Service manual decrease test                                              | Covered |
| Large adjustment discrepancies emit a grouped alert event                        | Service batch adjustment test                                             | Covered |
| Batch inventory changes emit one batch change event                              | Service adjustment and transaction tests                                  | Covered |
| Inventory creation requires package ownership by store                           | Service create ownership test                                             | Covered |
| Active duplicate inventory creation is rejected                                  | Service duplicate create test                                             | Covered |
| Inactive inventory is restored instead of duplicated                             | Service restore test                                                      | Covered |
| Inventory transaction imports increase stock and write audit logs                | Service transaction import test                                           | Covered |
| Inventory transaction exports decrease stock and write audit logs                | Service transaction export test                                           | Covered |
| Export transactions guard against insufficient stock before and during DB update | Service preflight and DB conflict tests, repository updateMany guard test | Covered |
| Inventory delete is a soft delete and is audited                                 | Service and controller delete tests                                       | Covered |
| Routes require authentication, store context, and inventory permissions          | Route tests                                                               | Covered |
| Request schemas reject invalid params, query, body, and adjustment payloads      | Validator and route rejection tests                                       | Covered |

## 5. Coverage Summary

Inventories-only aggregate coverage from the same run:

| Metric     |  Value |
| ---------- | -----: |
| Statements | 96.35% |
| Branches   | 85.39% |
| Functions  | 98.30% |
| Lines      | 96.65% |

Inventory file coverage:

| Area                            | Statements | Branches | Functions |  Lines |
| ------------------------------- | ---------: | -------: | --------: | -----: |
| inventories/inventory.module.ts |         0% |     100% |      100% |     0% |
| inventories/inventory.route.ts  |       100% |     100% |      100% |   100% |
| inventories/controller          |       100% |     100% |      100% |   100% |
| inventories/repository          |       100% |   97.61% |      100% |   100% |
| inventories/service             |     95.61% |   74.46% |    96.15% | 96.36% |
| inventories/validator           |       100% |     100% |      100% |   100% |

## 6. Coverage Gaps

- `inventory.module.ts` remains uncovered; it only wires singleton dependencies.
- `inventory.service.ts` has a defensive map branch for impossible missing inventory after length validation, an unsupported transaction type default branch, and a no-discrepancy event branch not directly asserted.
- `inventory.repository.ts` branch coverage only misses the unreachable default path where `adjustQuantity` receives a type outside the public validator/type contract.
- Route tests intentionally mock controllers, and controller tests cover response wiring separately.
- No real database integration tests were added; repository tests use mocked Prisma and validate query shape/DTO mapping only.

## 7. Duplicate or Overlapping Tests

- Validator failures are covered both directly and through route short-circuit tests. The overlap is intentional because they verify different boundaries.
- Decrease/export insufficient stock is covered at service and repository levels because the service has a preflight guard and the repository has the DB-level concurrency guard.

## 8. Skipped or Todo Tests

- No `test.skip`, `describe.skip`, or `test.todo` cases were added for inventories.

## 9. Final Notes

The inventories module now has focused unit and route coverage for inventory listing, low-stock lookup, store-scoped detail lookup, reorder threshold updates, batch adjustments, create/restore flows, transaction import/export stock changes, soft delete, validators, controllers, routes, and Prisma repository query shape.

One transaction risk remains documented: the brand-new `createInventory` branch opens a transaction but calls the injected repository's `createOne` instead of the transaction-scoped repository. The test captures current behavior; production logic was not changed during this test workflow.

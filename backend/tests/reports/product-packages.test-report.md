# Test Report: product-packages

## 1. Summary

| Item | Value |
|------|------:|
| Test files | 8 |
| Test cases | 51 |
| Service tests | 15 |
| Validator tests | 9 |
| Controller tests | 6 |
| Route tests | 7 |
| Repository tests | 14 |
| Utility tests | 0 |

## 2. Test Files

| File | Type | Purpose |
|------|------|---------|
| `backend/tests/unit/modules/product-packages/product-package.service.test.ts` | Unit | Product package business rules, transactions, audit logs, signed URLs, not-found and duplicate flows |
| `backend/tests/unit/modules/product-packages/unit.service.test.ts` | Unit | Unit service delegation |
| `backend/tests/unit/modules/product-packages/product-package.validator.test.ts` | Unit | Params, create body, update body, and list query schemas |
| `backend/tests/unit/modules/product-packages/product-package.controller.test.ts` | Unit | Product package and unit controller request extraction and responses |
| `backend/tests/unit/modules/product-packages/product-package.repository.test.ts` | Unit | Mocked Prisma query shape, store scoping, active-status filtering, Decimal conversion |
| `backend/tests/unit/modules/product-packages/unit.repository.test.ts` | Unit | Unit repository query shape and empty-id shortcut |
| `backend/tests/integration/modules/product-packages/product-package.route.test.ts` | Route integration | Product package route auth/store/permission/validator/controller wiring |
| `backend/tests/integration/modules/product-packages/unit.route.test.ts` | Route integration | Unit route auth/controller wiring |

## 3. Test Cases

### Service

| Test Case | Purpose |
|-----------|---------|
| returns paginated store packages with signed product image URLs | Verifies pagination normalization and signed product images |
| requires the product before listing packages by product id | Prevents package reads for missing/out-of-store products |
| throws not found when the product is missing before package lookup | Covers product-not-found branch |
| returns package detail with a signed product image URL | Covers detail lookup and signed URL mapping |
| throws not found when package detail is missing | Covers package-not-found branch |
| delegates active package and product-id helper lookups | Covers helper lookups used by transactions/other modules |
| creates packages, inventories, and audit logs in one transaction | Verifies transactional create, inventory creation, display names, audit logs |
| rejects duplicate unit and variant combinations in the request | Covers duplicate request payload guard |
| rejects missing units and existing variants before creating | Covers null/missing units and existing active package conflicts |
| updates unit-dependent display name and writes an audit log for changes | Covers unit replacement, display name sync, audit diff |
| updates variant and import price without changing unit display name | Covers partial non-unit update branches |
| does not write an update audit log when submitted values do not change | Covers no-op audit suppression |
| throws before updating when the package or replacement unit is missing | Covers update not-found branches |
| soft deletes a package and its inventory in one transaction | Verifies package/inventory soft-delete and audit log |
| returns all units from the repository | Covers unit service delegation |

### Validator

| Test Case | Purpose |
|-----------|---------|
| accepts valid product and package params | Valid UUID params |
| rejects invalid params | Invalid UUID rejection |
| accepts valid create payloads, trims variant, and coerces prices | Valid create schema transforms |
| rejects empty create arrays and invalid nested values | Create schema validation failures |
| accepts valid update payloads with null optional values | Valid update schema transforms |
| rejects empty update payloads because unitId is required by the schema | Documents current PATCH schema behavior |
| rejects invalid update values | Invalid unit and negative price failures |
| coerces list query defaults and accepts filters | Query coercion, sorting, category filter |
| rejects invalid list query values | Query limit, sort, and category validation |

### Controller

| Test Case | Purpose |
|-----------|---------|
| returns store packages using the validated query from locals | Store context and validated query forwarding |
| returns packages for a product path id | Product id forwarding |
| returns package detail by path id | Package id forwarding |
| creates packages for the current store, user, and product | Store/user/product/body forwarding |
| updates and soft deletes a package by path id | Update/delete forwarding and responses |
| returns all units | Unit response wiring |

### Route

| Test Case | Purpose |
|-----------|---------|
| routes GET /product-packages through auth, store context, read permission, and query validator | List route middleware order and query validation |
| rejects invalid package list query before controller execution | Invalid query short-circuit |
| routes product package list and create nested under products | Product nested GET/POST route wiring |
| rejects invalid product id and invalid create body before controller execution | Params/body validation short-circuit |
| routes package detail, update, and delete through validators and permissions | Detail/update/delete route wiring |
| rejects invalid package id and empty update body before controller execution | Package params/update body validation |
| routes GET /units through authentication to the unit controller | Unit route auth/controller wiring |

### Repository

| Test Case | Purpose |
|-----------|---------|
| findManyByStore scopes active packages by store and category | Store/category scope and pagination query shape |
| findManyByProductId and findDetailOne convert decimal prices | Decimal to number conversion for detail/list records |
| findManyByProductIdForNameSync returns simple active packages for a product | Product name sync query shape |
| findOne enforces store scope and active status | Single package scope |
| returns early for empty active package and product-id lookups | Empty input shortcuts |
| findManyActiveByIds and findProductIdsHavingActivePackages scope by store | Active package helper query shape |
| findOneExistedVariant queries active duplicate unit and variant pairs | Duplicate variant detection query |
| findBarcodeCandidates returns early without tokens and searches token groups | Barcode matching token query shape |
| creates packages with nested inventory and converts returned prices | Nested inventory create query shape |
| updates only provided fields and soft deletes by id | Update data filtering and soft-delete query |
| updates display names and soft deletes many packages by product id | Product rename sync and product cascade query |
| findOneById queries a unit by id | Unit single lookup query shape |
| findManyByIds returns early for empty input and queries id lists | Unit list lookup shortcut/query |
| findAll returns all unit DTO fields | Unit list query shape |

### Utility

| Test Case | Purpose |
|-----------|---------|
| None | No module-local utility functions are present |

## 4. Business Requirement Coverage

| Requirement | Covered By | Status |
|-------------|------------|--------|
| Product package reads are scoped by store and active product/package status | Service, repository, route tests | Covered |
| Product image URLs are signed on package read responses | Service tests | Covered |
| Product must exist before product package creation or product-specific listing | Service tests | Covered |
| Unit ids must resolve before package creation/update | Service and repository tests | Covered |
| Duplicate package unit/variant combinations are rejected in the same request | Service tests | Covered |
| Existing active package variants are rejected before create | Service and repository tests | Covered |
| Package create also creates inventory and audit logs transactionally | Service tests | Covered |
| Package update recalculates display name when unit changes | Service tests | Covered |
| Package update writes audit logs only for actual changes | Service tests | Covered |
| Package soft delete also soft deletes inventory and logs the cascade | Service tests | Covered |
| Route access requires auth, store context, and product permissions where applicable | Route tests | Covered |
| Unit listing requires authentication | Route tests | Covered |
| Validators reject invalid params, create bodies, update bodies, and list queries | Validator and route tests | Covered |
| PATCH package price/variant without unitId should be accepted if DTO intent is partial update | Validator and route tests show current rejection | Not Covered |

## 5. Coverage Summary

Note: Column "Value" indicates product-packages module coverage only from the focused coverage run.

| Metric | Value |
|--------|------:|
| Statements | 96.21% |
| Branches | 76.04% |
| Functions | 100.00% |
| Lines | 96.21% |

File-level highlights:

| File Group | Statements | Branches | Functions |
|------------|-----------:|---------:|----------:|
| `services/product-package.service.ts` | 100.00% | 89.47% | 100.00% |
| `services/unit.service.ts` | 100.00% | 100.00% | 100.00% |
| `repositories/product-package.repository.ts` | 100.00% | 66.07% | 100.00% |
| `repositories/unit.repository.ts` | 100.00% | 100.00% | 100.00% |
| `controllers/*` | 100.00% | 100.00% | 100.00% |
| `routes/*` | 100.00% | 100.00% | 100.00% |
| `product-package.validator.ts` | 100.00% | 100.00% | 100.00% |

## 6. Coverage Gaps

- Remaining branch gaps in `ProductPackageRepository` are mostly conditional object spread/nullish conversion branches for optional update fields and nullable Decimal prices.
- Remaining branch gaps in `ProductPackageService` are defensive/default branches such as fallback storage bucket and nullable variant formatting.
- Module singleton files are not directly tested; route/controller/service tests cover the behavior after mocking singleton imports.
- No real Prisma integration test verifies persistence, unique constraints, transaction rollback, or concurrent duplicate package creation.

## 7. Duplicate or Overlapping Tests

- Controller and route tests both touch endpoint-level happy paths, but at different boundaries: controller request extraction vs route middleware/validator wiring.
- Validator and route tests both cover invalid payloads; route tests verify controller short-circuiting while validator tests verify schema behavior directly.

## 8. Skipped or Todo Tests

- No `test.skip`, `describe.skip`, or `test.todo` cases were added for this module.

## 9. Final Notes

The product-packages module now has focused unit and route coverage for service business rules, mocked repository query shape, validation, controllers, and route middleware wiring. The main remaining risk is database-level behavior: transaction rollback, Prisma constraints, and concurrent duplicate package creation are not proven without a real test database.

One business-rule mismatch was documented: `UpdateProductPackageDto` is partial, but `updateProductPackageBodySchema` currently requires `unitId`, so PATCH requests that only update `variant`, `importPrice`, or `sellingPrice` are rejected before reaching the service.

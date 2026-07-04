# Test Report: products

## 1. Summary

| Item | Value |
|------|------:|
| Test files | 5 |
| Test cases | 57 |
| Service tests | 17 |
| Validator tests | 17 |
| Controller tests | 5 |
| Route tests | 8 |
| Repository tests | 10 |
| Utility tests | 0 |

## 2. Test Files

| File | Type | Purpose |
|------|------|---------|
| `tests/unit/modules/products/product.service.test.ts` | Unit | Verifies product business rules, category checks, signed image URLs, transactions, audit logs, package-name sync, soft delete, and repository/Prisma failure paths. |
| `tests/unit/modules/products/product.validator.test.ts` | Unit | Verifies Zod schemas for params, create body, update body, and list query validation/defaults. |
| `tests/unit/modules/products/product.controller.test.ts` | Unit | Verifies controller request-context extraction, service-call wiring, status codes, and success response shape. |
| `tests/integration/modules/products/product.route.test.ts` | Integration | Verifies Express route registration, real validators, and mocked auth/store-context/permission middleware wiring. |
| `tests/unit/modules/products/product.repository.test.ts` | Unit | Verifies mocked Prisma query shapes, store scoping, active-status filters, data payloads, pagination, Decimal conversion, and soft-delete updates. |

## 3. Test Cases

### Service

| Test Case | Purpose |
|-----------|---------|
| returns paginated products with signed image URLs | Covers product listing, pagination metadata, and signed URL mapping. |
| returns a product detail with signed image URL | Covers detail lookup success and signed URL mutation. |
| throws not found when the product is missing or outside the store | Covers product detail not-found/cross-store behavior. |
| requires an existing category and signs product images | Covers category existence check and category product signed URLs. |
| throws not found when the category is missing | Covers missing category branch before product lookup. |
| delegates active product lookup to the repository | Covers active product lookup by ids. |
| creates a product and audit log in one transaction | Verifies product creation, audit logging, transaction usage, and signed URL return. |
| does not start a transaction when the category is missing | Ensures create is blocked before writes when category validation fails. |
| propagates transaction failures | Ensures database/transaction failures are surfaced. |
| updates package display names by replacing the old product name | Covers product-package display-name sync behavior. |
| throws when a package displayName is missing | Covers defensive package sync failure. |
| updates product, syncs package names, and writes an audit log for changes | Covers update success, audit diff, and package sync count. |
| updates without audit log when submitted values do not change | Covers no-op audit branch and avoids unnecessary package sync. |
| throws not found before update when the product is missing | Ensures update is blocked for missing/inaccessible products. |
| checks a replacement category before updating | Covers replacement category validation before update transaction. |
| soft deletes the product and its packages in one transaction | Verifies product/package soft delete and audit log in one transaction. |
| throws not found before delete when the product is missing | Ensures delete is blocked for missing/inaccessible products. |

### Validator

| Test Case | Purpose |
|-----------|---------|
| accepts a valid UUID productId | Covers valid route parameter schema. |
| rejects invalid productId format | Covers invalid product id route parameter. |
| accepts valid product creation payload and trims strings | Covers valid create payload normalization. |
| accepts nullable optional imageUrl and brand | Covers nullable optional create fields. |
| rejects missing required name | Covers required create name. |
| rejects an empty product name after trimming | Covers whitespace-only create name. |
| rejects names longer than 255 characters | Covers create name upper boundary. |
| rejects invalid categoryId format | Covers invalid create category id. |
| rejects empty brand after trimming | Covers whitespace-only create brand. |
| accepts a valid partial update payload | Covers valid partial update normalization. |
| rejects an empty update payload | Covers no-op update rejection. |
| rejects empty updated name after trimming | Covers whitespace-only update name. |
| rejects invalid optional categoryId | Covers invalid update category id. |
| coerces pagination and applies defaults | Covers list query coercion and default sort values. |
| accepts filters and trims brand | Covers list category/brand filters and sorting options. |
| rejects limits above 100 | Covers list query limit upper boundary. |
| rejects invalid sort fields | Covers list query enum validation. |

### Controller

| Test Case | Purpose |
|-----------|---------|
| returns products for the current store using validated query | Verifies list controller uses store context and `res.locals.validatedQuery`. |
| returns a product detail by path id | Verifies detail controller uses current store and path product id. |
| creates a product for the current store and user | Verifies create controller adds `storeId` and forwards authenticated user id. |
| updates a product by path id | Verifies update controller uses current store, user id, path product id, and body. |
| soft deletes a product by path id | Verifies delete controller uses current store/user/path id and returns `null` data. |

### Route

| Test Case | Purpose |
|-----------|---------|
| routes GET /products through auth, store context, read permission, and query validator | Covers list route registration and middleware chain. |
| rejects invalid list query before controller execution | Covers list query validator blocking invalid input. |
| routes POST /products through write permission and body validator | Covers create route registration and write permission wiring. |
| rejects invalid create payload before controller execution | Covers create body validator blocking invalid input. |
| routes GET /products/:productId through read permission and params validator | Covers detail route registration and params validator. |
| rejects invalid productId params before delete controller execution | Covers delete route params validation. |
| rejects empty update body before controller execution | Covers update body validator no-op rejection. |
| routes PATCH and DELETE /products/:productId through write permission | Covers update/delete route registration and write permission wiring. |

### Repository

| Test Case | Purpose |
|-----------|---------|
| findManyByStoreId scopes active products by store and filters | Verifies list query where clause, brand/category filters, sorting, pagination, and count query. |
| findOne enforces store scope and active status | Verifies simple product lookup is scoped to current store and active products. |
| findDetailOne converts package prices to numbers | Covers detail lookup shape and Decimal-to-number conversion for package prices. |
| findManyActiveByIds returns early for empty input | Covers defensive no-query branch for empty id lists. |
| findManyActiveByIds scopes ids by store and active status | Verifies active product id lookup query shape. |
| createOne writes the product payload | Verifies create data payload and selected response shape. |
| updateOne updates by productId | Verifies update where clause and data payload. |
| findManyByCategoryId returns active products and count for a category | Verifies category product lookup query shape and count calculation. |
| uncategorizeMany moves products in a store to the fallback category | Verifies category reassignment updateMany shape and returned count. |
| softDeleteOne marks a product inactive | Verifies product soft-delete update payload. |

### Utility

| Test Case | Purpose |
|-----------|---------|
| _None_ | No product-specific utility functions exist in this module. |

## 4. Business Requirement Coverage

| Requirement | Covered By | Status |
|-------------|------------|--------|
| Products can be listed by current store with pagination, sorting, category filter, and case-insensitive brand filter | Service, Validator, Route, Repository | Covered |
| Product list and detail responses return signed image URLs | Service | Covered |
| Product detail lookup is scoped to current store and active products | Service, Controller, Route, Repository | Covered |
| Products can be listed by category only when the category exists | Service, Repository | Covered |
| Missing category returns not found before create/update/category listing work proceeds | Service | Covered |
| Active product lookup by ids is scoped to store and active products | Service, Repository | Covered |
| Product creation validates category, writes product, writes audit log, and returns signed image URL | Service, Controller, Validator, Route, Repository | Covered |
| Product creation surfaces transaction/database failures | Service | Covered |
| Product update validates product and optional replacement category before writing | Service, Controller, Validator, Route, Repository | Covered |
| Product name update syncs package display names and records synced package count | Service | Covered |
| Product update does not write audit log when submitted values do not change | Service | Covered |
| Product soft delete marks product inactive, soft deletes packages, and writes audit log transactionally | Service, Controller, Route, Repository | Covered |
| Request validation rejects invalid params, empty bodies, invalid UUIDs, invalid query bounds, and invalid enum values | Validator, Route | Covered |
| Cross-store access is blocked by store-scoped repository queries | Service, Repository | Covered |
| Real Prisma persistence, foreign keys, and database constraints | Not covered by mocked repository tests | Not Covered |
| Real authentication, store-context, and RBAC middleware behavior | Route tests use mocks | Partially Covered |

## 5. Coverage Summary

| Metric | Value |
|--------|------:|
| Statements | 97.63% |
| Branches | 93.33% |
| Functions | 100% |
| Lines | 97.61% |

Coverage values are from the latest products-focused coverage run in the test workflow.

## 6. Coverage Gaps

- `product.module.ts` remains uncovered. This file wires singleton repository/service/controller instances and has no product business branches.
- `product.service.ts` has an uncovered branch on the `STORAGE_BUCKET` environment fallback. This is configuration fallback behavior, not product business logic.
- `product.repository.ts` still has a partially covered branch in `findDetailOne` around null detail results. Service-level not-found behavior is covered, but the repository null-return branch itself is not directly asserted.
- Repository tests use mocked Prisma and verify query shape only. They do not prove real database persistence, foreign-key behavior, unique constraints, or Prisma schema-level behavior.
- Route tests mock authentication, store-context, permission middleware, and controller handlers. They verify route wiring and validators, not real auth/RBAC decisions.

## 7. Duplicate or Overlapping Tests

- Controller and route tests both cover endpoint success concepts for list/detail/create/update/delete, but at different layers:
  - Controller tests verify service calls, request context, and response shape.
  - Route tests verify Express registration, middleware wiring, and validators.
- Service and repository tests both touch store scoping, but service tests verify business behavior while repository tests verify Prisma query shape.
- Validator and route tests overlap on invalid request input. Validator tests cover schema behavior directly; route tests prove invalid inputs stop before controller execution.

No meaningless duplicate assertions were identified.

## 8. Skipped or Todo Tests

No `test.skip`, `describe.skip`, or `test.todo` cases were found in the products test suite.

## 9. Final Notes

The products module test suite covers the core product business rules, validation boundaries, controller/service/repository separation, route wiring, transactional create/update/delete behavior, audit logging, signed URL behavior, and product-package name synchronization.

Remaining work is mainly broader integration depth:

- Add real Prisma repository integration tests if database-level guarantees become required.
- Add real auth/store-context/RBAC integration coverage if route middleware behavior should be validated end-to-end.
- Add a direct repository null-result test for `findDetailOne` if branch coverage needs to be pushed higher.

The products module is ready for broader integration testing beyond mocked unit and route-wiring coverage.

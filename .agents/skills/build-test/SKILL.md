---
name: build-test
description: Generate unit tests and integration tests for a backend module using business-review output as the source of truth, focusing on meaningful branch coverage and business behavior.
argument-hint: "[module path]"
---

# Skill: Build Test

## Objective

Generate unit tests and integration tests for a backend module.

Use business-review output as the source of truth. If a bussiness-review result doesn't exist, stop immediately.

Focus on meaningful branch coverage and business behavior.

## Input

A module directory:

backend/src/modules/<module>/

## Prerequisite

Business review has already been completed.

Use the business-review output as requirements.

### Step 1

Read:

* controller
* service
* repository
* validator
* related middlewares

### Step 2

Generate unit tests:

* <module>.service.test.ts
* <module>.validator.test.ts
* <module>.util.test.ts (if utility functions exist)

### Step 3

Generate controller or route integration tests:

* <module>.controller.test.ts
* <module>.route.test.ts

### Step 4

Generate repository tests.

If Prisma is mocked, treat the test as a unit test.

If real Prisma and a test database are used, treat the test as an integration test.

---

## Unit Test Requirements

Generate tests for:

* service
* validator
* utility functions
* repository query shape, only if Prisma is mocked

Mock:

* repository
* prisma
* redis
* external APIs
* external services

Do not mock business logic.

Verify:

* returned data
* thrown errors
* dependency calls

## Validator Test Requirements

Test:

* valid payload
* missing fields
* invalid types
* invalid formats
* boundary values
* empty strings
* whitespace values
* nullable fields
* optional fields

## Controller and Route Test Requirements

Controller tests should verify:

* status code
* response body
* service calls
* error forwarding

Route tests should verify:

* route registration
* middleware order
* validator behavior
* auth middleware behavior
* store-context middleware behavior
* permission middleware behavior

Use Supertest for route-level tests.

Mock service behavior when testing controller or route wiring.

## Repository Test Requirements

If testing with mocked Prisma:

* verify Prisma method calls
* verify where clauses
* verify select/include clauses
* verify data mapping

Place these tests under unit tests.

If testing with real Prisma:

* use a test database
* seed required records
* verify persisted data
* verify relations
* verify constraints
* clean up test data

Place these tests under integration tests.

Do not call mocked repository tests integration tests.

## Required Test Categories

Every service method must be tested for:

* Happy path
* Validation failure
* Authorization failure
* Resource not found
* Duplicate resource
* Database failure
* Unexpected exception

Always test both positive and negative flows.

## Testing Priority

1. Service
2. Validator
3. Route
4. Controller
5. Repository
6. Utility

Do not generate tests for:

* dto.ts
* type.ts

## Test Boundary Rules

Service tests:

* mock repositories and external services
* do not use Prisma
* do not use Supertest

Validator tests:

* do not mock validation logic
* test schema behavior directly

Controller tests:

* mock services
* test controller behavior

Route tests:

* use Supertest
* mock controllers or services depending on the test goal
* focus on route wiring and middleware behavior

Repository unit tests:

* mock Prisma
* test query shape only

Repository integration tests:

* use real Prisma
* use a test database
* test persistence behavior

## Shared Test Helpers

Before generating new test utilities, check whether equivalent helpers already exist.

If reusable code is identified, move it into:

tests/helpers/

Examples:

- mock middlewares
- mock users
- mock stores
- request builders
- response builders
- common test data factories
- shared test utilities

Update all affected imports.

Avoid duplicating helper implementations across modules.

## Test Location

Unit tests:

tests/unit/modules/<module-name>/

Examples:

tests/unit/modules/products/product.service.test.ts
tests/unit/modules/products/product.validator.test.ts
tests/unit/modules/products/product.repository.test.ts

Integration tests:

tests/integration/modules/<module-name>/

Examples:

tests/integration/modules/products/product.route.test.ts
tests/integration/modules/products/product.repository.integration.test.ts

Shared test helpers:

tests/helpers/

Examples:

tests/helpers/mock-authenticate.middleware.ts
tests/helpers/mock-require-store-context.middleware.ts

## Assertions

Prefer:

expect(productRepository.updateOne)
  .toHaveBeenCalledWith(...);

expect(result.productId)
  .toBe('p1');

Avoid:

expect(result).toBeDefined();

## Rules

Do not:

* modify production code
* generate duplicate tests
* add meaningless assertions
* call mocked repository tests integration tests
* place integration tests under tests/unit

Prefer meaningful branch coverage over shallow line coverage.
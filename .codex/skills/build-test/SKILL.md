# Skill: Build Test

## Objective

Generate unit tests and integration tests for a backend module.

Use business-review output as the source of truth.

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

### Step 2

Generate:

<module>.service.test.ts

### Step 3

Generate:

<module>.validator.test.ts

### Step 4

Generate:

<module>.controller.test.ts

using Supertest

### Step 5

Generate:

<module>.repository.test.ts

---

## Unit Test Requirements

Generate tests for:

* service
* validator

Mock:

* repository
* prisma
* redis
* external APIs

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

## Controller Test Requirements

Verify:

* status code
* response body
* auth middleware behavior

Response must follow:

{
  success: boolean,
  data: any,
  message?: string,
  meta?: object
}

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
3. Controller
4. Repository

Do not generate tests for:

* dto.ts
* type.ts

## Unit test rules

* For service tests, mock repositories and external services
* For controller tests, mock only external services when necessary
* Never use Prisma in service tests
* Prefer meaningful branch coverage over shallow line coverage

## Test Location

tests/unit/modules/<module-name>/

Examples:
tests/unit/modules/products/product.service.test.ts
tests/unit/modules/products/product.controller.test.ts

## Assertions

Prefer:

expect(productRepository.updateOne)
  .toHaveBeenCalledWith(...);

expect(result.productId)
  .toBe('p1');

Avoid:

expect(result).toBeDefined();

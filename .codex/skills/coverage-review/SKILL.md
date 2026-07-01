# Skill: Coverage Review

## Goal

Analyze existing test coverage and generate additional tests for uncovered branches.

This skill does NOT create an initial test suite.

This skill assumes tests already exist.

Do not modify production code unless explicitly requested.

---

## Inputs

Required:

* module source code
* existing test files
* coverage report

---

## Coverage Priority

Coverage importance order:

1. Branch Coverage
2. Function Coverage
3. Statement Coverage
4. Line Coverage

Never optimize only for line coverage.

Always prioritize missing branches.

---

## Coverage Review Process

### Step 1

Read:

* controller
* service
* repository
* validator

### Step 2

Read existing tests.

Identify:

* tested paths
* mocked dependencies
* assertion quality

### Step 3

Read coverage report.

Identify:

* uncovered files
* uncovered functions
* uncovered branches
* partially covered conditions

### Step 4

Map uncovered code back to business logic.

Determine:

* which business rule is not tested
* which execution path is not tested

### Step 5

Generate additional tests only for missing behavior.

Avoid duplicate tests.

---

## Branch Analysis

For every uncovered branch identify:

* branch condition
* expected behavior
* test data required

Examples:

if (!product)

→ Missing product test

if (inventory.quantity < quantity)

→ Inventory underflow test

if (existingBarcode)

→ Duplicate barcode test

switch(status)

→ Missing enum value test

---

## Security Coverage Checklist

Review only security-related behavior that is currently uncovered by tests.

Examples:

* unauthorized access
* forbidden access
* cross-store access
* invalid JWT
* missing JWT

---

## Concurrency Coverage Checklist

Review uncovered code related to:

* race conditions
* duplicate requests
* concurrent updates

Generate additional tests if coverage gaps exist.

---

## Database Transaction Coverage

Review whether tests exist for:

* successful transaction
* rollback behavior
* partial failure

Generate tests only if uncovered.

---

## Output Format

1. Coverage Summary

Current coverage:

* Statements
* Branches
* Functions
* Lines

2. Uncovered Branches

3. Untested Business Rules

4. Missing Edge Cases

5. Missing Security Cases

6. Coverage Improvement Plan (Prioritized list)

7. Additional Tests

* Generate only the tests required to increase coverage.

---

## Test Location

tests/unit/modules/<module-name>/

Examples:
tests/unit/modules/products/product.service.test.ts
tests/unit/modules/products/product.controller.test.ts

## Rules

Do not:

* rewrite existing tests unnecessarily
* duplicate existing coverage
* add meaningless assertions
* modify production logic

Focus on:

* uncovered behavior
* uncovered branches
* uncovered business rules

Every generated test must correspond to a real uncovered execution path.

Coverage validation is the responsibility of this skill.

Do not re-run business analysis already covered by business-review.
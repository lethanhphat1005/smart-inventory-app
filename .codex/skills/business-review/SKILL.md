# Skill: Business Review

## Goal

Analyze a backend module before test generation.

The objective is to understand:

* business rules
* execution branches
* exceptional flows
* edge cases
* security risks
* concurrency risks

Do not generate tests.

Do not modify code.

This skill is purely analytical.

---

## Inputs

Module:

src/modules/<module>

Read:

* controller
* service
* repository
* validator
* related shared utilities
* related Prisma models

---

## Analysis Process

### Step 1

Identify:

* module purpose
* main use cases
* external dependencies

### Step 2

Build business-rule inventory.

For every public service method determine:

* purpose
* inputs
* outputs
* side effects

### Step 3

Identify execution branches.

Include:

* happy paths
* validation failures
* authorization failures
* resource not found
* duplicate resources
* inactive resources
* unexpected exceptions

### Step 4

Identify exceptional flows.

Never assume a branch is impossible.

---

## Security Review

Identify:

* missing authorization checks
* privilege escalation
* insecure direct object references
* cross-store access vulnerabilities
* missing ownership validation

---

## Concurrency Review

Identify:

* race conditions
* duplicate requests
* inventory update conflicts
* concurrent transaction creation

Determine whether database transactions are required.

---

## Data Consistency Review

For every write operation determine:

* entities modified
* transaction requirements
* rollback requirements

Flag any operation updating multiple entities without transaction boundaries.

Example:

* Delete product with inventory
* Delete product with transaction history

---

## Output Format

1. Module Overview

2. Business Rules

3. Execution Branches

4. Exceptional Flows

5. Edge Cases

6. Security Risks

7. Concurrency Risks

8. Transaction Risks

9. Test Requirements

List the test scenarios required to validate the module.

For each scenario include:

* scenario
* expected result
* priority

  Critical:
  * financial loss
  * inventory corruption
  * authorization bypass

  High:
  * business rule violations

  Medium:
  * validation failures

  Low:
  * cosmetic or defensive cases

Do not generate test code.

## Test Location

tests/unit/modules/<module-name>/

Examples:
tests/unit/modules/products/product.service.test.ts
tests/unit/modules/products/product.controller.test.ts

## Domain Knowledge

Apply domain-specific rules defined in AGENTS.md.

Do not duplicate domain rules inside this skill.

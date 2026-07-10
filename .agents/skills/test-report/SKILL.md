---
name: test-report
description: Generate a final Markdown test report for a backend module by summarizing existing test cases, business-review requirements, build-test output, and coverage-review findings.
argument-hint: "[module path]"
---

# Skill: Test Report

## Goal

Generate a final Markdown report for a backend module test suite.

This is the final step of the testing workflow.

The report summarizes:

- business-review test requirements
- generated test files
- existing test cases
- coverage-review findings
- remaining gaps

Do not generate new tests.

Do not modify production code.

Do not perform coverage analysis from scratch.

---

## Inputs

Required:

- module source code
- existing test files

Optional but recommended:

- business-review output
- build-test output
- coverage-review output
- coverage report

---

## Process

### Step 1

Identify all test files for the module.

### Step 2

List all test cases from:

- describe(...)
- it(...)
- test(...)

### Step 3

Group test cases by component:

- Service
- Validator
- Controller
- Route
- Repository
- Utility

### Step 4

Summarize coverage-review findings if available.

### Step 5

Compare test cases against business-review test requirements if available.

### Step 6

Generate the final report.

---

## Output

Create:

tests/reports/<module-name>.test-report.md

---

## Report Format

# Test Report: <module-name>

## 1. Summary

| Item | Value |
|------|------:|
| Test files | |
| Test cases | |
| Service tests | |
| Validator tests | |
| Controller tests | |
| Route tests | |
| Repository tests | |
| Utility tests | |

## 2. Test Files

| File | Type | Purpose |
|------|------|---------|

## 3. Test Cases

### Service

| Test Case | Purpose |
|-----------|---------|

### Validator

| Test Case | Purpose |
|-----------|---------|

### Controller

| Test Case | Purpose |
|-----------|---------|

### Route

| Test Case | Purpose |
|-----------|---------|

### Repository

| Test Case | Purpose |
|-----------|---------|

### Utility

| Test Case | Purpose |
|-----------|---------|

## 4. Business Requirement Coverage

| Requirement | Covered By | Status |
|-------------|------------|--------|

Status:

- Covered
- Partially Covered
- Not Covered
- Unknown

## 5. Coverage Summary

Note: Column "Value" indicates the module coverage only

| Metric | Value |
|--------|------:|
| Statements | |
| Branches | |
| Functions | |
| Lines | |

## 6. Coverage Gaps

List uncovered branches or uncovered behavior from coverage-review.

## 7. Duplicate or Overlapping Tests

List duplicated scenarios.

## 8. Skipped or Todo Tests

List:

- test.skip
- describe.skip
- test.todo

## 9. Final Notes

Summarize:

- testing scope
- remaining gaps
- whether this module is ready for broader integration testing

Do not generate new tests.

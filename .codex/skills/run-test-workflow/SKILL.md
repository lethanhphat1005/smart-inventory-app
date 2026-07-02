---
name: run-test-workflow
description: Execute the standard backend testing workflow by running business-review, build-test, and coverage-review in order, carrying outputs forward and generating only required additional tests.
argument-hint: "[module path]"
---

# Skill: Run Test Workflow

## Goal

Execute the standard backend testing workflow.

## Workflow

1. Run skill: business-review.
2. Use the review output to run skill: build-test.
3. If a coverage report is available, run skill: coverage-review.
4. Generate only additional tests if required.

## Rules

Do not skip steps.

Use outputs from previous steps as inputs for subsequent steps.
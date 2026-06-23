# Smart Inventory System (SIS)

Mobile inventory management application for small retail stores.

## Tech Stack

Backend:
- Node.js
- TypeScript
- Express
- Prisma
- PostgreSQL

Frontend:
- Flutter

Backend Testing:
- Vitest
- @vitest/coverage-v8
- Supertest

## Backend Architecture

Module-first architecture

backend/src/modules/
  products/
  categories/
  stores/
  memberships/
  .etc.

Each module contains:
- controller
- service
- repository
- dto
- validator
- type

## Backend Rules

Controller
→ no business logic

Service
→ business logic only

Repository
→ Prisma access only

## Commands

npm run dev
npm run lint
npm run test
npm run test:coverage

## Response Format

{
  success,
  data,
  message?,
  meta?
}
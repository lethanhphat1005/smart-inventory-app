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
  .etc./

Each module contains:
- controller
- service
- repository
- dto
- validator
- type

## Backend Rules

Controller: no business logic

Service: business logic only

Repository: Prisma access only

# Repository Guidelines for Backend

## Project Structure & Module Organization
- `backend/` contains the Express + TypeScript API. Business code lives in `backend/src/modules`, shared utilities in `backend/src/common`, runtime config in `backend/src/config`, and Prisma schema/migrations in `backend/prisma`.

## Build, Test, and Development Commands
- Backend: `cd backend && npm run dev` starts the API with `tsx watch`; `npm run build` compiles to `dist/`; `npm start` runs the compiled server.
- Backend quality: `cd backend && npm run lint`, `npm run format:check`, and `npm run test:coverage`.
- Database/local services: `cd backend && npx supabase start`, `npx supabase status`, `npx prisma migrate dev`, `npx prisma generate`.

## Coding Style & Naming Conventions
- Backend: Follow strictly on `backend/CODE_CONVENTION.md` and `backend/eslint.config.ts`

## Testing Guidelines
- Backend tests use Vitest with V8 coverage. Coverage focuses on `backend/src/modules/**/*.ts` and excludes DTO/type files.

## Security & Configuration Tips
- Do not commit secrets. Backend values belong in local `.env`.
- Treat `serviceAccountKey.json`, Supabase keys, and Terraform variables as sensitive. Sanitize logs and example configs before sharing.

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

# Repository Guidelines

## Project Structure & Module Organization
- `backend/` contains the Express + TypeScript API. Business code lives in `backend/src/modules`, shared utilities in `backend/src/common`, runtime config in `backend/src/config`, and Prisma schema/migrations in `backend/prisma`.
- `frontend/` contains the Flutter client. Shared app layers live in `frontend/lib/core`, feature modules in `frontend/lib/features`, route setup in `frontend/lib/routes`, and assets in `frontend/assets`.
- `docs/` stores project documentation, `terraform/` holds infrastructure code, and `opt-sis/` contains deployment-related scripts and configs.

## Build, Test, and Development Commands
- Backend: `cd backend && npm run dev` starts the API with `tsx watch`; `npm run build` compiles to `dist/`; `npm start` runs the compiled server.
- Backend quality: `cd backend && npm run lint`, `npm run format:check`, and `npm run test:coverage`.
- Database/local services: `cd backend && npx supabase start`, `npx supabase status`, `npx prisma migrate dev`, `npx prisma generate`.
- Frontend: `cd frontend && flutter pub get` installs packages; `flutter run --dart-define=API_BASE_URL=... --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...` runs the app.
- Frontend quality: `cd frontend && flutter analyze` and `flutter test`.

## Coding Style & Naming Conventions
- Frontend files use `snake_case` with suffixes like `_view.dart`, `_controller.dart`, and `_widget.dart`. Classes use `PascalCase`; variables use `camelCase`; booleans start with `is`, `has`, `can`, or `will`.
- Frontend: Follow strictly on `frontend/documents/code_covention.txt`
- Backend: Follow strictly on `backend/CODE_CONVENTION.md` and `backend/eslint.config.ts`

## Testing Guidelines
- Backend tests use Vitest with V8 coverage. Coverage focuses on `backend/src/modules/**/*.ts` and excludes DTO/type files.
- Add backend tests as `*.test.ts` or `*.spec.ts` near the module under test. Prefer service and route coverage for new backend behavior.
- Frontend tests live in `frontend/test/`. Use widget tests for UI behavior and keep test names aligned with the screen or widget under test.

## Commit & Pull Request Guidelines
- Follow the repos Conventional Commit style: `feat(scope): ...`, `chore(scope): ...`, `fix(scope): ...`.
- Keep commits focused and scoped to one concern. Mention the module when useful, for example `feat(product-package): ...`.
- PRs should include a short summary, affected areas (`backend`, `frontend`, `terraform`), setup or migration notes, linked issues, and screenshots or recordings for UI changes.

## Security & Configuration Tips
- Do not commit secrets. Backend values belong in local `.env`; frontend runtime values should come from `--dart-define`.
- Treat `serviceAccountKey.json`, Supabase keys, and Terraform variables as sensitive. Sanitize logs and example configs before sharing.

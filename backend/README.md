# Backend Setup

## Prerequisites

- Node.js (v18+)
- Docker Desktop

## Installation

1. Install dependencies:

```bash
cd backend
npm i
```

2. Set up Supabase locally:

**Start Docker Desktop** (ensure it's running)

**Start Supabase:**

```bash
npx supabase start
```

After starting, you should see output similar to:

```
Database URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
API URL: http://127.0.0.1:54321
Studio: http://127.0.0.1:54323
```

**Configure Environment Variables** in `.env`:

```env
DATABASE_URL="postgresql://postgres:postgres@127.0.0.1:54322/postgres"
SUPABASE_URL="http://127.0.0.1:54321"
SUPABASE_ANON_KEY="<publishable_key_from_supabase_status>"
SUPABASE_SERVICE_ROLE_KEY="<secret_key_from_supabase_status>"
```

To view the keys:

```bash
npx supabase status
```

**Run Prisma Migrations:**

```bash
npx prisma migrate dev
```

**Generate Prisma Client:**

```bash
npx prisma generate
```

## Development

Start the development server:

```bash
npm run dev
```

## Useful Commands

**Prisma:**

```bash
# Create a new migration
npx prisma migrate dev --name <migration_name>

# Apply migrations in production
npx prisma migrate deploy

# Open Prisma Studio (database GUI)
npx prisma studio

# Reset local database (⚠️ deletes all data)
npx prisma migrate reset
```

**Supabase:**

```bash
# View Supabase status and keys
npx supabase status

# Stop Supabase
npx supabase stop

# Reset Supabase (⚠️ deletes all data)
npx supabase db reset
```

## Build & Production

```bash
# Build for production
npm run build

# Start production server
npm start
```

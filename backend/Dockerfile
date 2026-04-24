FROM node:22-alpine AS deps

WORKDIR /app

COPY package*.json .

RUN npm ci

FROM node:22-alpine AS builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules

COPY . .

RUN npx prisma generate

RUN npm run build

RUN npm prune --omit=dev && npm cache clean --force

FROM node:22-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json .
COPY --from=builder /app/package-lock.json .
COPY --from=builder /app/dist ./dist

RUN addgroup --system appgroup \
  && adduser --system --ingroup appgroup appuser

USER appuser

EXPOSE 3000

CMD [ "npm", "start" ]
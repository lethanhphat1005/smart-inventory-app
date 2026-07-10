import { describe, expect, it, vi } from 'vitest';

import { HealthCheckController } from '../../../../src/modules/health-check/health-check.controller.js';

const prismaMock = vi.hoisted(() => ({
  prisma: {
    $queryRaw: vi.fn(),
  },
}));

const redisMock = vi.hoisted(() => ({
  ping: vi.fn(),
}));

vi.mock('../../../../src/db/prismaClient.js', () => ({
  prisma: prismaMock.prisma,
}));

vi.mock('../../../../src/db/redis.js', () => ({
  redisClient: redisMock,
}));

describe('health-check module wiring', () => {
  it('exports a health-check controller instance', async () => {
    const module = await import(
      '../../../../src/modules/health-check/health-check.module.js'
    );

    expect(module.healthCheckController).toBeInstanceOf(HealthCheckController);
  });
});

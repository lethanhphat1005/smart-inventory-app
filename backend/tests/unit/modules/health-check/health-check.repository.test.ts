import { beforeEach, describe, expect, it, vi } from 'vitest';

import { HealthCheckRepository } from '../../../../src/modules/health-check/health-check.repository.js';

const redisMocks = vi.hoisted(() => ({
  ping: vi.fn(),
}));

vi.mock('../../../../src/db/redis.js', () => ({
  redisClient: {
    ping: redisMocks.ping,
  },
}));

const createMockDb = () => ({
  $queryRaw: vi.fn(),
});

describe('HealthCheckRepository', () => {
  let db: ReturnType<typeof createMockDb>;
  let healthCheckRepository: HealthCheckRepository;

  beforeEach(() => {
    vi.clearAllMocks();
    db = createMockDb();
    healthCheckRepository = new HealthCheckRepository(db as never);
  });

  it('checkReady executes a lightweight database readiness query', async () => {
    db.$queryRaw.mockResolvedValue([{ '?column?': 1 }]);

    await healthCheckRepository.checkReady();

    expect(db.$queryRaw).toHaveBeenCalledTimes(1);
    expect(db.$queryRaw).toHaveBeenCalledWith(['SELECT 1']);
  });

  it('checkReady propagates database failures', async () => {
    const error = new Error('database unavailable');

    db.$queryRaw.mockRejectedValue(error);

    await expect(healthCheckRepository.checkReady()).rejects.toThrow(error);
  });

  it('checkRedis pings Redis once', async () => {
    redisMocks.ping.mockResolvedValue('PONG');

    await healthCheckRepository.checkRedis();

    expect(redisMocks.ping).toHaveBeenCalledTimes(1);
  });

  it('checkRedis propagates Redis failures', async () => {
    const error = new Error('redis unavailable');

    redisMocks.ping.mockRejectedValue(error);

    await expect(healthCheckRepository.checkRedis()).rejects.toThrow(error);
  });
});

import { beforeEach, describe, expect, it, vi } from 'vitest';

import { HealthCheckService } from '../../../../src/modules/health-check/health-check.service.js';

import type { HealthCheckRepository } from '../../../../src/modules/health-check/health-check.repository.js';

type MockHealthCheckRepository = {
  checkReady: ReturnType<typeof vi.fn>;
  checkRedis: ReturnType<typeof vi.fn>;
};

const createMockHealthCheckRepository = (): MockHealthCheckRepository => ({
  checkReady: vi.fn(),
  checkRedis: vi.fn(),
});

describe('HealthCheckService', () => {
  let healthCheckRepository: MockHealthCheckRepository;
  let healthCheckService: HealthCheckService;

  beforeEach(() => {
    vi.useRealTimers();
    healthCheckRepository = createMockHealthCheckRepository();
    healthCheckService = new HealthCheckService(
      healthCheckRepository as unknown as HealthCheckRepository,
    );
  });

  it('checkDatabase returns up with measured latency when the database responds', async () => {
    vi.spyOn(Date, 'now').mockReturnValueOnce(1_000).mockReturnValueOnce(1_024);
    healthCheckRepository.checkReady.mockResolvedValue(undefined);

    const result = await healthCheckService.checkDatabase();

    expect(result).toEqual({
      status: 'up',
      latencyMs: 24,
    });
    expect(healthCheckRepository.checkReady).toHaveBeenCalledTimes(1);
  });

  it('checkDatabase returns down with a stable message when the repository fails', async () => {
    vi.spyOn(Date, 'now').mockReturnValueOnce(2_000).mockReturnValueOnce(2_045);
    healthCheckRepository.checkReady.mockRejectedValue(
      new Error('connection refused'),
    );

    const result = await healthCheckService.checkDatabase();

    expect(result).toEqual({
      status: 'down',
      latencyMs: 45,
      message: 'Database connection failed',
    });
  });

  it('checkRedis returns up with measured latency when Redis responds', async () => {
    vi.spyOn(Date, 'now').mockReturnValueOnce(3_000).mockReturnValueOnce(3_006);
    healthCheckRepository.checkRedis.mockResolvedValue(undefined);

    const result = await healthCheckService.checkRedis();

    expect(result).toEqual({
      status: 'up',
      latencyMs: 6,
    });
    expect(healthCheckRepository.checkRedis).toHaveBeenCalledTimes(1);
  });

  it('checkRedis returns down with a stable message when Redis fails', async () => {
    vi.spyOn(Date, 'now').mockReturnValueOnce(4_000).mockReturnValueOnce(4_013);
    healthCheckRepository.checkRedis.mockRejectedValue(new Error('timeout'));

    const result = await healthCheckService.checkRedis();

    expect(result).toEqual({
      status: 'down',
      latencyMs: 13,
      message: 'Redis connection failed',
    });
  });
});

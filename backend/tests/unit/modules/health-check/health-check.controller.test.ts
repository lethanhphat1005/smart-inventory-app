import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { HealthCheckController } from '../../../../src/modules/health-check/health-check.controller.js';
import { createRequest, createResponse } from '../../../helpers/index.js';

import type { HealthDependency } from '../../../../src/modules/health-check/health-check.type.js';

type MockHealthCheckService = {
  checkDatabase: ReturnType<typeof vi.fn>;
  checkRedis: ReturnType<typeof vi.fn>;
};

const createMockHealthCheckService = (): MockHealthCheckService => ({
  checkDatabase: vi.fn(),
  checkRedis: vi.fn(),
});

describe('HealthCheckController', () => {
  let healthCheckService: MockHealthCheckService;
  let healthCheckController: HealthCheckController;

  beforeEach(() => {
    vi.useRealTimers();
    healthCheckService = createMockHealthCheckService();
    healthCheckController = new HealthCheckController(
      healthCheckService as never,
    );
  });

  it('getLiveness returns an up status without dependency checks', () => {
    vi.spyOn(process, 'uptime').mockReturnValue(123.9);
    vi.setSystemTime(new Date('2026-07-10T01:02:03.000Z'));

    const req = createRequest({});
    const res = createResponse();

    healthCheckController.getLiveness(req, res);

    expect(healthCheckService.checkDatabase).not.toHaveBeenCalled();
    expect(healthCheckService.checkRedis).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: {
        status: 'up',
        uptimeSec: 123,
        checkedAt: '2026-07-10T01:02:03.000Z',
      },
    });
  });

  it('getReadiness returns ready when database and Redis are up', async () => {
    vi.setSystemTime(new Date('2026-07-10T04:05:06.000Z'));
    const database: HealthDependency = { status: 'up', latencyMs: 2 };
    const redis: HealthDependency = { status: 'up', latencyMs: 1 };
    const req = createRequest({});
    const res = createResponse();

    healthCheckService.checkDatabase.mockResolvedValue(database);
    healthCheckService.checkRedis.mockResolvedValue(redis);

    await healthCheckController.getReadiness(req, res);

    expect(healthCheckService.checkDatabase).toHaveBeenCalledTimes(1);
    expect(healthCheckService.checkRedis).toHaveBeenCalledTimes(1);
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: {
        status: 'ready',
        dependencies: {
          database,
          redis,
        },
        checkedAt: '2026-07-10T04:05:06.000Z',
      },
    });
  });

  it('getReadiness returns degraded when the database is down', async () => {
    vi.setSystemTime(new Date('2026-07-10T07:08:09.000Z'));
    const database: HealthDependency = {
      status: 'down',
      latencyMs: 10,
      message: 'Database connection failed',
    };
    const redis: HealthDependency = { status: 'up', latencyMs: 1 };
    const req = createRequest({});
    const res = createResponse();

    healthCheckService.checkDatabase.mockResolvedValue(database);
    healthCheckService.checkRedis.mockResolvedValue(redis);

    await healthCheckController.getReadiness(req, res);

    expect(res.status).toHaveBeenCalledWith(StatusCodes.SERVICE_UNAVAILABLE);
    expect(res.json).toHaveBeenCalledWith({
      success: false,
      data: {
        status: 'degraded',
        dependencies: {
          database,
          redis,
        },
        checkedAt: '2026-07-10T07:08:09.000Z',
      },
    });
  });

  it('getReadiness returns degraded when Redis is down', async () => {
    vi.setSystemTime(new Date('2026-07-10T10:11:12.000Z'));
    const database: HealthDependency = { status: 'up', latencyMs: 2 };
    const redis: HealthDependency = {
      status: 'down',
      latencyMs: 30,
      message: 'Redis connection failed',
    };
    const req = createRequest({});
    const res = createResponse();

    healthCheckService.checkDatabase.mockResolvedValue(database);
    healthCheckService.checkRedis.mockResolvedValue(redis);

    await healthCheckController.getReadiness(req, res);

    expect(res.status).toHaveBeenCalledWith(StatusCodes.SERVICE_UNAVAILABLE);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: false,
        data: expect.objectContaining({
          status: 'degraded',
          dependencies: {
            database,
            redis,
          },
        }),
      }),
    );
  });

  it('getReadiness propagates unexpected service errors to the async route wrapper', async () => {
    const error = new Error('unexpected readiness failure');
    const req = createRequest({});
    const res = createResponse();

    healthCheckService.checkDatabase.mockRejectedValue(error);
    healthCheckService.checkRedis.mockResolvedValue({ status: 'up' });

    await expect(healthCheckController.getReadiness(req, res)).rejects.toThrow(
      error,
    );
    expect(res.status).not.toHaveBeenCalled();
    expect(res.json).not.toHaveBeenCalled();
  });
});

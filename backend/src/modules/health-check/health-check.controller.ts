import { StatusCodes } from 'http-status-codes';

import type { HealthCheckService } from './health-check.service.js';
import type { Request, Response } from 'express';

export class HealthCheckController {
  constructor(private readonly healthCheckService: HealthCheckService) {}

  getLiveness = (_req: Request, res: Response): void => {
    res.status(StatusCodes.OK).json({
      success: true,
      data: {
        status: 'up',
        uptimeSec: Math.floor(process.uptime()),
        checkedAt: new Date().toISOString(),
      },
    });
  };

  getReadiness = async (_req: Request, res: Response): Promise<void> => {
    const [database, redis] = await Promise.all([
      this.healthCheckService.checkDatabase(),
      this.healthCheckService.checkRedis(),
    ]);

    const dependencies = {
      database,
      redis,
    };

    const hasDownDependency = Object.values(dependencies).some(
      (dependency) => dependency.status === 'down',
    );

    const statusCode = hasDownDependency
      ? StatusCodes.SERVICE_UNAVAILABLE
      : StatusCodes.OK;

    res.status(statusCode).json({
      success: !hasDownDependency,
      data: {
        status: hasDownDependency ? 'degraded' : 'ready',
        dependencies,
        checkedAt: new Date().toISOString(),
      },
    });
  };
}

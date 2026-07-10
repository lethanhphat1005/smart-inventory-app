import { redisClient } from '../../db/redis.js';

import type { DbClient } from '../../common/types/db.type.js';

export class HealthCheckRepository {
  constructor(private readonly prisma: DbClient) {}

  async checkReady(): Promise<void> {
    await this.prisma.$queryRaw`SELECT 1`;
  }

  async checkRedis(): Promise<void> {
    await redisClient.ping();
  }
}

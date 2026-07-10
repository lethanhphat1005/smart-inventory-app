import type { HealthCheckRepository } from './health-check.repository.js';
import type { HealthDependency } from './health-check.type.js';

export class HealthCheckService {
  constructor(private readonly healthCheckRepository: HealthCheckRepository) {}

  async checkDatabase(): Promise<HealthDependency> {
    const startedAt = Date.now();

    try {
      await this.healthCheckRepository.checkReady();

      return {
        status: 'up',
        latencyMs: Date.now() - startedAt,
      };
    } catch {
      return {
        status: 'down',
        latencyMs: Date.now() - startedAt,
        message: 'Database connection failed',
      };
    }
  }

  async checkRedis(): Promise<HealthDependency> {
    const startedAt = Date.now();

    try {
      await this.healthCheckRepository.checkRedis();

      return {
        status: 'up',
        latencyMs: Date.now() - startedAt,
      };
    } catch {
      return {
        status: 'down',
        latencyMs: Date.now() - startedAt,
        message: 'Redis connection failed',
      };
    }
  }
}

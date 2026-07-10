import { HealthCheckController } from './health-check.controller.js';
import { HealthCheckRepository } from './health-check.repository.js';
import { HealthCheckService } from './health-check.service.js';
import { prisma } from '../../db/prismaClient.js';

const healthCheckRepository = new HealthCheckRepository(prisma);
const healthCheckService = new HealthCheckService(healthCheckRepository);
const healthCheckController = new HealthCheckController(healthCheckService);

export { healthCheckController };

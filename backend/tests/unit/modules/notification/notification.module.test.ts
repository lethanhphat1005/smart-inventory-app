import { describe, expect, it, vi } from 'vitest';

import { NotificationController } from '../../../../src/modules/notification/controllers/notification.controller.js';
import { NotificationRepository } from '../../../../src/modules/notification/repositories/notification.repository.js';
import { NotificationService } from '../../../../src/modules/notification/services/notification.service.js';

const prismaMock = vi.hoisted(() => ({
  prisma: {
    fcmToken: {},
    notification: {},
    store: {},
  },
}));

vi.mock('../../../../src/db/prismaClient.js', () => ({
  prisma: prismaMock.prisma,
}));

describe('notification module wiring', () => {
  it('exports notification singleton instances', async () => {
    const module =
      await import('../../../../src/modules/notification/notification.module.js');

    expect(module.notificationRepository).toBeInstanceOf(
      NotificationRepository,
    );
    expect(module.notificationService).toBeInstanceOf(NotificationService);
    expect(module.notificationController).toBeInstanceOf(
      NotificationController,
    );
  });
});

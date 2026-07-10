import { describe, expect, it, vi } from 'vitest';

import { SmartDecisionController } from '../../../../src/modules/alerts/controllers/smart-decision.controller.js';
import { SmartDecisionService } from '../../../../src/modules/alerts/services/smart-decision.service.js';

const prismaMocks = vi.hoisted(() => ({
  prisma: {
    inventory: {},
    transactionDetail: {},
    store: {},
  },
}));

vi.mock('../../../../src/db/prismaClient.js', () => ({
  prisma: prismaMocks.prisma,
}));

describe('smart decision module wiring', () => {
  it('exports smart decision service and controller instances', async () => {
    const module =
      await import('../../../../src/modules/alerts/smart-decision.module.js');

    expect(module.smartDecisionService).toBeInstanceOf(SmartDecisionService);
    expect(module.smartDecisionController).toBeInstanceOf(
      SmartDecisionController,
    );
  });
});

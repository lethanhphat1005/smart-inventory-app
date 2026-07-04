import { describe, expect, it, vi } from 'vitest';

import { AuditLogController } from '../../../../src/modules/audit-log/controller/audit-log.controller.js';

const prismaMock = vi.hoisted(() => ({
  prisma: {
    auditLog: {},
  },
}));

vi.mock('../../../../src/db/prismaClient.js', () => ({
  prisma: prismaMock.prisma,
}));

describe('audit-log module wiring', () => {
  it('exports an audit log controller instance', async () => {
    const module =
      await import('../../../../src/modules/audit-log/audit-log.module.js');

    expect(module.auditLogController).toBeInstanceOf(AuditLogController);
  });
});

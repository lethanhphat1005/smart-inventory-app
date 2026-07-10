import { describe, expect, it, vi } from 'vitest';

import { UserFacade } from '../../../../src/modules/user/user.facade.js';

const prismaMock = vi.hoisted(() => ({
  prisma: {
    userProfile: {},
  },
}));

vi.mock('../../../../src/db/prismaClient.js', () => ({
  prisma: prismaMock.prisma,
}));

describe('user module wiring', () => {
  it('exports a user facade instance', async () => {
    const module = await import('../../../../src/modules/user/user.module.js');

    expect(module.userFacade).toBeInstanceOf(UserFacade);
  });
});

import { describe, expect, it, vi } from 'vitest';

import { StoreMemberRepository } from '../../../../src/modules/store-member/repository/store-member.repository.js';
import { StoreMemberService } from '../../../../src/modules/store-member/service/store-member.service.js';

const prismaMock = vi.hoisted(() => ({
  prisma: {
    storeMember: {},
  },
}));

vi.mock('../../../../src/db/prismaClient.js', () => ({
  prisma: prismaMock.prisma,
}));

describe('store-member module wiring', () => {
  it('exports repository and service instances', async () => {
    const module =
      await import('../../../../src/modules/store-member/store-member.module.js');

    expect(module.storeMemberRepository).toBeInstanceOf(StoreMemberRepository);
    expect(module.storeMemberService).toBeInstanceOf(StoreMemberService);
    expect(module.storeMemberController).toBeDefined();
  });
});

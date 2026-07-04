import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  appEvents,
  eventBus,
} from '../../../../src/common/events/event-bus.js';
import { StoreMemberService } from '../../../../src/modules/store-member/service/store-member.service.js';

import type {
  RawStoreMemberDto,
  StoreMemberResponseDto,
} from '../../../../src/modules/store-member/dto/store-member.dto.js';

type MockStoreMemberRepository = {
  findManyByStoreId: ReturnType<typeof vi.fn>;
  findOneByUserIdAndStoreId: ReturnType<typeof vi.fn>;
  findByIdsWithStore: ReturnType<typeof vi.fn>;
  softDeleteMember: ReturnType<typeof vi.fn>;
  updateRole: ReturnType<typeof vi.fn>;
};

const joinedAt = new Date('2026-01-01T00:00:00.000Z');

const memberFixture = (
  overrides: Partial<StoreMemberResponseDto> = {},
): StoreMemberResponseDto => ({
  userId: 'target-user',
  storeId: 'store-1',
  role: 'staff',
  activeStatus: 'active',
  joinedAt,
  ...overrides,
});

const memberWithStoreFixture = (
  overrides: Partial<
    StoreMemberResponseDto & { store: { userId: string } }
  > = {},
) => ({
  ...memberFixture(),
  store: { userId: 'owner-user' },
  ...overrides,
});

const rawMemberFixture = (
  overrides: Partial<RawStoreMemberDto> = {},
): RawStoreMemberDto => ({
  role: 'manager',
  joinedAt,
  user: {
    userId: 'user-1',
    authUserId: 'auth-user-1',
    email: 'user@example.com',
    fullName: 'Store User',
    phone: '0900000000',
    address: '123 Market Street',
    activeStatus: 'active',
    createdAt: joinedAt,
    updatedAt: joinedAt,
  },
  ...overrides,
});

const createMockRepository = (): MockStoreMemberRepository => ({
  findManyByStoreId: vi.fn(),
  findOneByUserIdAndStoreId: vi.fn(),
  findByIdsWithStore: vi.fn(),
  softDeleteMember: vi.fn(),
  updateRole: vi.fn(),
});

describe('StoreMemberService', () => {
  let repository: MockStoreMemberRepository;
  let service: StoreMemberService;

  beforeEach(() => {
    vi.clearAllMocks();
    repository = createMockRepository();
    service = new StoreMemberService(repository as never);
  });

  describe('getMembersByStoreId', () => {
    it('returns active member profile data with role and join date', async () => {
      repository.findManyByStoreId.mockResolvedValue([rawMemberFixture()]);

      const result = await service.getMembersByStoreId('store-1');

      expect(repository.findManyByStoreId).toHaveBeenCalledWith('store-1');
      expect(result).toEqual([
        {
          userId: 'user-1',
          email: 'user@example.com',
          fullName: 'Store User',
          phone: '0900000000',
          address: '123 Market Street',
          activeStatus: 'active',
          role: 'manager',
          joinedAt,
        },
      ]);
    });

    it('propagates repository failures when listing members fails', async () => {
      repository.findManyByStoreId.mockRejectedValue(new Error('db down'));

      await expect(service.getMembersByStoreId('store-1')).rejects.toThrow(
        'db down',
      );
    });
  });

  describe('getMembershipByUserIdAndStoreId', () => {
    it('throws bad request when userId is missing', async () => {
      await expect(
        service.getMembershipByUserIdAndStoreId('', 'store-1'),
      ).rejects.toMatchObject({
        message:
          'User ID and Store ID are required to fetch membership information',
        status: StatusCodes.BAD_REQUEST,
      });
      expect(repository.findOneByUserIdAndStoreId).not.toHaveBeenCalled();
    });

    it('throws bad request when storeId is missing', async () => {
      await expect(
        service.getMembershipByUserIdAndStoreId('user-1', ''),
      ).rejects.toMatchObject({
        status: StatusCodes.BAD_REQUEST,
      });
      expect(repository.findOneByUserIdAndStoreId).not.toHaveBeenCalled();
    });

    it('returns null when no active membership exists', async () => {
      repository.findOneByUserIdAndStoreId.mockResolvedValue(null);

      await expect(
        service.getMembershipByUserIdAndStoreId('user-1', 'store-1'),
      ).resolves.toBeNull();
    });

    it('returns membership data for RBAC middleware', async () => {
      const membership = {
        userId: 'user-1',
        storeId: 'store-1',
        role: 'owner',
      };

      repository.findOneByUserIdAndStoreId.mockResolvedValue(membership);

      const result = await service.getMembershipByUserIdAndStoreId(
        'user-1',
        'store-1',
      );

      expect(result).toBe(membership);
    });
  });

  describe('removeUserFromStore', () => {
    it('soft deletes a staff member when requester is owner', async () => {
      const updatedMember = memberFixture({ activeStatus: 'inactive' });

      repository.findByIdsWithStore.mockResolvedValue(memberWithStoreFixture());
      repository.softDeleteMember.mockResolvedValue(updatedMember);

      const result = await service.removeUserFromStore(
        'owner-user',
        'owner',
        'target-user',
        'store-1',
      );

      expect(repository.softDeleteMember).toHaveBeenCalledWith(
        'target-user',
        'store-1',
      );
      expect(result).toBe(updatedMember);
    });

    it('throws not found when target user is not a store member', async () => {
      repository.findByIdsWithStore.mockResolvedValue(null);

      await expect(
        service.removeUserFromStore(
          'owner-user',
          'owner',
          'target-user',
          'store-1',
        ),
      ).rejects.toMatchObject({
        message: 'User is not a member of this store',
        status: StatusCodes.NOT_FOUND,
      });
      expect(repository.softDeleteMember).not.toHaveBeenCalled();
    });

    it('throws bad request when target member is already inactive', async () => {
      repository.findByIdsWithStore.mockResolvedValue(
        memberWithStoreFixture({ activeStatus: 'inactive' }),
      );

      await expect(
        service.removeUserFromStore(
          'owner-user',
          'owner',
          'target-user',
          'store-1',
        ),
      ).rejects.toMatchObject({
        message: 'This user has already been removed from the store',
        status: StatusCodes.BAD_REQUEST,
      });
    });

    it('prevents users from removing themselves', async () => {
      repository.findByIdsWithStore.mockResolvedValue(memberWithStoreFixture());

      await expect(
        service.removeUserFromStore(
          'target-user',
          'owner',
          'target-user',
          'store-1',
        ),
      ).rejects.toMatchObject({
        message: 'You cannot remove yourself using this feature',
        status: StatusCodes.BAD_REQUEST,
      });
    });

    it('prevents removing the store owner', async () => {
      repository.findByIdsWithStore.mockResolvedValue(
        memberWithStoreFixture({ store: { userId: 'target-user' } }),
      );

      await expect(
        service.removeUserFromStore(
          'manager-user',
          'manager',
          'target-user',
          'store-1',
        ),
      ).rejects.toMatchObject({
        message: 'Cannot remove the store owner',
        status: StatusCodes.FORBIDDEN,
      });
    });

    it('prevents managers from removing other managers case-insensitively', async () => {
      repository.findByIdsWithStore.mockResolvedValue(
        memberWithStoreFixture({ role: 'manager' }),
      );

      await expect(
        service.removeUserFromStore(
          'manager-user',
          'manager',
          'target-user',
          'store-1',
        ),
      ).rejects.toMatchObject({
        message: 'Managers can only remove staff members, not other managers',
        status: StatusCodes.FORBIDDEN,
      });
    });

    it('propagates repository errors during soft delete', async () => {
      repository.findByIdsWithStore.mockResolvedValue(memberWithStoreFixture());
      repository.softDeleteMember.mockRejectedValue(new Error('write failed'));

      await expect(
        service.removeUserFromStore(
          'owner-user',
          'owner',
          'target-user',
          'store-1',
        ),
      ).rejects.toThrow('write failed');
    });
  });

  describe('updateMemberRole', () => {
    it('updates role and emits ROLE_UPDATED when requester is owner', async () => {
      const emitSpy = vi.spyOn(eventBus, 'emit');
      const updatedMember = memberFixture({ role: 'manager' });

      repository.findByIdsWithStore.mockResolvedValue(memberWithStoreFixture());
      repository.updateRole.mockResolvedValue(updatedMember);

      const result = await service.updateMemberRole(
        'owner',
        'target-user',
        'store-1',
        'manager',
      );

      expect(emitSpy).toHaveBeenCalledWith(appEvents.ROLE_UPDATED, {
        targetUserId: 'target-user',
        storeId: 'store-1',
        oldRole: 'staff',
        newRole: 'manager',
      });
      expect(repository.updateRole).toHaveBeenCalledWith(
        'target-user',
        'store-1',
        'manager',
      );
      expect(result).toBe(updatedMember);
    });

    it('forbids non-owner requesters from changing roles', async () => {
      await expect(
        service.updateMemberRole('manager', 'target-user', 'store-1', 'staff'),
      ).rejects.toMatchObject({
        message: 'Only the store owner can change member roles',
        status: StatusCodes.FORBIDDEN,
      });
      expect(repository.findByIdsWithStore).not.toHaveBeenCalled();
    });

    it('throws not found when target is not an active member', async () => {
      repository.findByIdsWithStore.mockResolvedValue(null);

      await expect(
        service.updateMemberRole('owner', 'target-user', 'store-1', 'manager'),
      ).rejects.toMatchObject({
        message: 'User is not an active member of this store',
        status: StatusCodes.NOT_FOUND,
      });
    });

    it('throws not found when target membership is inactive', async () => {
      repository.findByIdsWithStore.mockResolvedValue(
        memberWithStoreFixture({ activeStatus: 'inactive' }),
      );

      await expect(
        service.updateMemberRole('owner', 'target-user', 'store-1', 'manager'),
      ).rejects.toMatchObject({
        status: StatusCodes.NOT_FOUND,
      });
    });

    it('prevents changing the store owner role', async () => {
      repository.findByIdsWithStore.mockResolvedValue(
        memberWithStoreFixture({ store: { userId: 'target-user' } }),
      );

      await expect(
        service.updateMemberRole('owner', 'target-user', 'store-1', 'manager'),
      ).rejects.toMatchObject({
        message: 'Cannot change the role of the store owner',
        status: StatusCodes.FORBIDDEN,
      });
    });

    it('rejects no-op role changes', async () => {
      repository.findByIdsWithStore.mockResolvedValue(memberWithStoreFixture());

      await expect(
        service.updateMemberRole('owner', 'target-user', 'store-1', 'staff'),
      ).rejects.toMatchObject({
        message: 'User is already a staff',
        status: StatusCodes.BAD_REQUEST,
      });
      expect(repository.updateRole).not.toHaveBeenCalled();
    });

    it('propagates repository errors during role update', async () => {
      repository.findByIdsWithStore.mockResolvedValue(memberWithStoreFixture());
      repository.updateRole.mockRejectedValue(new Error('update failed'));

      await expect(
        service.updateMemberRole('owner', 'target-user', 'store-1', 'manager'),
      ).rejects.toThrow('update failed');
    });
  });
});

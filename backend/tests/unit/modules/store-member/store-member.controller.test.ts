import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { StoreMemberController } from '../../../../src/modules/store-member/store-member.controller.js';
import { createRequest, createResponse } from '../../../helpers/index.js';

import type {
  StoreMemberResponseDto,
  StoreMemberUserResponseDto,
} from '../../../../src/modules/store-member/store-member.dto.js';

type MockStoreMemberService = {
  removeUserFromStore: ReturnType<typeof vi.fn>;
  updateMemberRole: ReturnType<typeof vi.fn>;
  getMembersByStoreId: ReturnType<typeof vi.fn>;
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

const memberUserFixture = (
  overrides: Partial<StoreMemberUserResponseDto> = {},
): StoreMemberUserResponseDto => ({
  userId: 'target-user',
  email: 'target@example.com',
  fullName: 'Target User',
  phone: null,
  address: null,
  activeStatus: 'active',
  role: 'staff',
  joinedAt,
  ...overrides,
});

const createMockService = (): MockStoreMemberService => ({
  removeUserFromStore: vi.fn(),
  updateMemberRole: vi.fn(),
  getMembersByStoreId: vi.fn(),
});

describe('StoreMemberController', () => {
  let service: MockStoreMemberService;
  let controller: StoreMemberController;

  beforeEach(() => {
    service = createMockService();
    controller = new StoreMemberController(service as never);
  });

  it('removes a target user using authenticated user and store context', async () => {
    const removedMember = memberFixture({ activeStatus: 'inactive' });
    const req = createRequest({
      user: {
        userId: 'requester-user',
        authUserId: 'auth-user-1',
        email: null,
      },
      storeContext: {
        storeId: 'store-1',
        role: 'manager',
      },
      params: {
        userId: 'target-user',
      },
    });
    const res = createResponse<StoreMemberResponseDto>();

    service.removeUserFromStore.mockResolvedValue(removedMember);

    await controller.removeUser(req, res);

    expect(service.removeUserFromStore).toHaveBeenCalledWith(
      'requester-user',
      'manager',
      'target-user',
      'store-1',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: removedMember,
    });
  });

  it('throws bad request when remove target userId param is missing', async () => {
    const req = createRequest({
      user: {
        userId: 'requester-user',
        authUserId: 'auth-user-1',
        email: null,
      },
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
      params: {},
    });
    const res = createResponse<StoreMemberResponseDto>();

    await expect(controller.removeUser(req, res)).rejects.toMatchObject({
      message: 'Target User ID is required',
      status: StatusCodes.BAD_REQUEST,
    });
    expect(service.removeUserFromStore).not.toHaveBeenCalled();
  });

  it('updates a target member role from store context', async () => {
    const updatedMember = memberFixture({ role: 'manager' });
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
      params: {
        userId: 'target-user',
      },
      body: {
        role: 'manager',
      },
    });
    const res = createResponse<StoreMemberResponseDto>();

    service.updateMemberRole.mockResolvedValue(updatedMember);

    await controller.updateRole(req, res);

    expect(service.updateMemberRole).toHaveBeenCalledWith(
      'owner',
      'target-user',
      'store-1',
      'manager',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: updatedMember,
    });
  });

  it('returns store members for the current store context', async () => {
    const members = [memberUserFixture()];
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
    });
    const res = createResponse<StoreMemberUserResponseDto[]>();

    service.getMembersByStoreId.mockResolvedValue(members);

    await controller.getStoreMembers(req, res);

    expect(service.getMembersByStoreId).toHaveBeenCalledWith('store-1');
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: members,
    });
  });
});

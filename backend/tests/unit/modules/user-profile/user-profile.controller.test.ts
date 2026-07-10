import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { UserProfileController } from '../../../../src/modules/user-profile/controllers/user-profile.controller.js';
import { createRequest, createResponse } from '../../../helpers/index.js';

import type { UserProfileResponseDto } from '../../../../src/modules/user-profile/dtos/user-profile.dto.js';

const uuid = '550e8400-e29b-41d4-a716-446655440000';

const userProfileFixture = (
  overrides: Partial<UserProfileResponseDto> = {},
): UserProfileResponseDto =>
  ({
    userId: uuid,
    authUserId: 'auth-user-1',
    email: 'user@example.com',
    fullName: 'Test User',
    phone: null,
    address: null,
    activeStatus: 'active',
    createdAt: new Date('2026-01-01T00:00:00.000Z'),
    updatedAt: new Date('2026-01-01T00:00:00.000Z'),
    ...overrides,
  }) as UserProfileResponseDto;

const createMockService = () => ({
  createUserProfileIfNotExists: vi.fn(),
  getUserProfile: vi.fn(),
  updateUserProfile: vi.fn(),
});

describe('UserProfileController', () => {
  let service: ReturnType<typeof createMockService>;
  let controller: UserProfileController;

  beforeEach(() => {
    service = createMockService();
    controller = new UserProfileController(service as never);
  });

  it('creates the current user profile from auth user context and body', async () => {
    const profile = userProfileFixture();
    const req = createRequest({
      user: {
        userId: '',
        authUserId: 'auth-user-1',
        email: 'user@example.com',
      },
      body: {
        fullName: 'Test User',
      },
    });
    const res = createResponse<UserProfileResponseDto>();

    service.createUserProfileIfNotExists.mockResolvedValue(profile);

    await controller.createMyProfile(req, res);

    expect(service.createUserProfileIfNotExists).toHaveBeenCalledWith(
      'auth-user-1',
      {
        email: 'user@example.com',
        fullName: 'Test User',
      },
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.CREATED);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: profile,
    });
  });

  it('defaults missing email and full name while creating a profile', async () => {
    const req = createRequest({
      user: {
        userId: '',
        authUserId: 'auth-user-1',
        email: null,
      },
      body: {},
    });
    const res = createResponse<UserProfileResponseDto>();

    service.createUserProfileIfNotExists.mockResolvedValue(
      userProfileFixture(),
    );

    await controller.createMyProfile(req, res);

    expect(service.createUserProfileIfNotExists).toHaveBeenCalledWith(
      'auth-user-1',
      {
        email: '',
        fullName: '',
      },
    );
  });

  it('gets the current user profile by auth user id', async () => {
    const profile = userProfileFixture();
    const req = createRequest({
      user: {
        userId: uuid,
        authUserId: 'auth-user-1',
        email: 'user@example.com',
      },
    });
    const res = createResponse<UserProfileResponseDto>();

    service.getUserProfile.mockResolvedValue(profile);

    await controller.getMyProfile(req, res);

    expect(service.getUserProfile).toHaveBeenCalledWith('auth-user-1');
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: profile,
    });
  });

  it('updates the current user profile when the path id matches the request user', async () => {
    const profile = userProfileFixture({ fullName: 'Updated User' });
    const payload = { fullName: 'Updated User' };
    const req = createRequest({
      user: {
        userId: uuid,
        authUserId: 'auth-user-1',
        email: 'user@example.com',
      },
      params: {
        userId: uuid,
      },
      body: payload,
    });
    const res = createResponse<UserProfileResponseDto>();

    service.updateUserProfile.mockResolvedValue(profile);

    await controller.updateUserProfile(req, res);

    expect(service.updateUserProfile).toHaveBeenCalledWith(uuid, payload);
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
  });

  it('rejects profile updates when userId path param is missing', async () => {
    const req = createRequest({
      user: {
        userId: uuid,
        authUserId: 'auth-user-1',
        email: 'user@example.com',
      },
      params: {},
      body: {
        fullName: 'Updated User',
      },
    });
    const res = createResponse<UserProfileResponseDto>();

    await expect(controller.updateUserProfile(req, res)).rejects.toMatchObject({
      message: 'User ID is required and must be a valid string',
      status: StatusCodes.BAD_REQUEST,
    });
    expect(service.updateUserProfile).not.toHaveBeenCalled();
  });

  it('rejects attempts to update another user profile', async () => {
    const otherUserId = '660e8400-e29b-41d4-a716-446655440000';
    const req = createRequest({
      user: {
        userId: uuid,
        authUserId: 'auth-user-1',
        email: 'user@example.com',
      },
      params: {
        userId: otherUserId,
      },
      body: {
        fullName: 'Updated User',
      },
    });
    const res = createResponse<UserProfileResponseDto>();

    await expect(controller.updateUserProfile(req, res)).rejects.toMatchObject({
      message: 'You do not have permission to update another user profile',
      status: StatusCodes.FORBIDDEN,
    });
    expect(service.updateUserProfile).not.toHaveBeenCalled();
  });

  it('throws unauthorized when request user is missing', async () => {
    const req = createRequest({});
    const res = createResponse<UserProfileResponseDto>();

    await expect(controller.getMyProfile(req, res)).rejects.toMatchObject({
      message: 'User is not authenticated',
      status: StatusCodes.UNAUTHORIZED,
    });
  });
});

import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { UserProfileService } from '../../../../src/modules/user-profile/services/user-profile.service.js';

import type {
  CreateUserProfileDto,
  UpdateUserProfileDto,
  UserProfileResponseDto,
} from '../../../../src/modules/user-profile/dtos/user-profile.dto.js';

const userProfileFixture = (
  overrides: Partial<UserProfileResponseDto> = {},
): UserProfileResponseDto =>
  ({
    userId: '550e8400-e29b-41d4-a716-446655440000',
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

const createMockRepository = () => ({
  findByAuthUserId: vi.fn(),
  createOne: vi.fn(),
  findById: vi.fn(),
  updateOne: vi.fn(),
});

describe('UserProfileService', () => {
  let repository: ReturnType<typeof createMockRepository>;
  let service: UserProfileService;

  beforeEach(() => {
    repository = createMockRepository();
    service = new UserProfileService(repository as never);
  });

  describe('createUserProfileIfNotExists', () => {
    it('returns the existing profile without creating a duplicate', async () => {
      const profile = userProfileFixture();

      repository.findByAuthUserId.mockResolvedValue(profile);

      const result = await service.createUserProfileIfNotExists('auth-user-1', {
        email: 'new@example.com',
        fullName: 'New Name',
      });

      expect(result).toEqual(profile);
      expect(repository.findByAuthUserId).toHaveBeenCalledWith('auth-user-1');
      expect(repository.createOne).not.toHaveBeenCalled();
    });

    it('creates a profile when none exists for the auth user id', async () => {
      const payload: CreateUserProfileDto = {
        email: 'user@example.com',
        fullName: 'Test User',
      };
      const profile = userProfileFixture(payload);

      repository.findByAuthUserId.mockResolvedValue(null);
      repository.createOne.mockResolvedValue(profile);

      const result = await service.createUserProfileIfNotExists(
        'auth-user-1',
        payload,
      );

      expect(result).toEqual(profile);
      expect(repository.createOne).toHaveBeenCalledWith('auth-user-1', payload);
    });

    it('propagates repository failures while checking for an existing profile', async () => {
      const error = new Error('database unavailable');

      repository.findByAuthUserId.mockRejectedValue(error);

      await expect(
        service.createUserProfileIfNotExists('auth-user-1', {
          email: 'user@example.com',
          fullName: 'Test User',
        }),
      ).rejects.toThrow(error);
    });
  });

  describe('getUserProfile', () => {
    it('returns the profile for an auth user id', async () => {
      const profile = userProfileFixture();

      repository.findByAuthUserId.mockResolvedValue(profile);

      const result = await service.getUserProfile('auth-user-1');

      expect(result).toEqual(profile);
      expect(repository.findByAuthUserId).toHaveBeenCalledWith('auth-user-1');
    });

    it('throws not found when the auth user has no profile', async () => {
      repository.findByAuthUserId.mockResolvedValue(null);

      await expect(service.getUserProfile('auth-user-1')).rejects.toMatchObject(
        {
          message: 'Không tìm thấy thông tin người dùng.',
          status: StatusCodes.NOT_FOUND,
        },
      );
    });
  });

  describe('updateUserProfile', () => {
    it('updates an existing profile by user id', async () => {
      const payload: UpdateUserProfileDto = {
        fullName: 'Updated User',
        phone: '1234567890',
      };
      const updatedProfile = userProfileFixture(payload);

      repository.findById.mockResolvedValue(userProfileFixture());
      repository.updateOne.mockResolvedValue(updatedProfile);

      const result = await service.updateUserProfile(
        '550e8400-e29b-41d4-a716-446655440000',
        payload,
      );

      expect(result).toEqual(updatedProfile);
      expect(repository.findById).toHaveBeenCalledWith(
        '550e8400-e29b-41d4-a716-446655440000',
      );
      expect(repository.updateOne).toHaveBeenCalledWith(
        '550e8400-e29b-41d4-a716-446655440000',
        payload,
      );
    });

    it('throws not found when the target profile does not exist', async () => {
      repository.findById.mockResolvedValue(null);

      await expect(
        service.updateUserProfile('missing-user', { fullName: 'Updated User' }),
      ).rejects.toMatchObject({
        message: 'User profile not found',
        status: StatusCodes.NOT_FOUND,
      });
      expect(repository.updateOne).not.toHaveBeenCalled();
    });
  });
});

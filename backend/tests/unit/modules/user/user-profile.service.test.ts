import { beforeEach, describe, expect, it, vi } from 'vitest';

import { UserProfileService } from '../../../../src/modules/user/services/user-profile.service.js';

import type { UserProfileAuthDTO } from '../../../../src/modules/user/dtos/user.dto.js';

const createUserProfile = (
  overrides: Partial<UserProfileAuthDTO> = {},
): UserProfileAuthDTO => ({
  userId: 'user-1',
  authUserId: 'auth-user-1',
  email: 'user@example.com',
  fullName: 'Test User',
  activeStatus: 'active',
  ...overrides,
});

const createMockRepository = () => ({
  findByAuthUserId: vi.fn(),
});

describe('UserProfileService', () => {
  let repository: ReturnType<typeof createMockRepository>;
  let service: UserProfileService;

  beforeEach(() => {
    repository = createMockRepository();
    service = new UserProfileService(repository as never);
  });

  it('returns the active user profile for an auth user id', async () => {
    const userProfile = createUserProfile();

    repository.findByAuthUserId.mockResolvedValue(userProfile);

    const result = await service.getActiveUserByAuthUserId('auth-user-1');

    expect(result).toEqual(userProfile);
    expect(repository.findByAuthUserId).toHaveBeenCalledWith('auth-user-1');
  });

  it('returns null when no local profile exists for the auth user id', async () => {
    repository.findByAuthUserId.mockResolvedValue(null);

    const result = await service.getActiveUserByAuthUserId('auth-user-1');

    expect(result).toBeNull();
    expect(repository.findByAuthUserId).toHaveBeenCalledWith('auth-user-1');
  });

  it('returns null when the local profile is inactive', async () => {
    repository.findByAuthUserId.mockResolvedValue(
      createUserProfile({ activeStatus: 'inactive' }),
    );

    const result = await service.getActiveUserByAuthUserId('auth-user-1');

    expect(result).toBeNull();
  });

  it('propagates repository failures', async () => {
    const error = new Error('database unavailable');

    repository.findByAuthUserId.mockRejectedValue(error);

    await expect(
      service.getActiveUserByAuthUserId('auth-user-1'),
    ).rejects.toThrow(error);
  });
});

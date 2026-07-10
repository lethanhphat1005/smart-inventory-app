import { beforeEach, describe, expect, it, vi } from 'vitest';

import { UserFacade } from '../../../../src/modules/user/user.facade.js';

import type { UserProfileAuthDTO } from '../../../../src/modules/user/dtos/user.dto.js';

const createUserProfile = (): UserProfileAuthDTO => ({
  userId: 'user-1',
  authUserId: 'auth-user-1',
  email: 'user@example.com',
  fullName: 'Test User',
  activeStatus: 'active',
});

const createMockService = () => ({
  getActiveUserByAuthUserId: vi.fn(),
});

describe('UserFacade', () => {
  let service: ReturnType<typeof createMockService>;
  let facade: UserFacade;

  beforeEach(() => {
    service = createMockService();
    facade = new UserFacade(service as never);
  });

  it('delegates active user lookup to the user profile service', async () => {
    const userProfile = createUserProfile();

    service.getActiveUserByAuthUserId.mockResolvedValue(userProfile);

    const result = await facade.getActiveUserByAuthUserId('auth-user-1');

    expect(result).toEqual(userProfile);
    expect(service.getActiveUserByAuthUserId).toHaveBeenCalledWith(
      'auth-user-1',
    );
  });

  it('returns null from the user profile service', async () => {
    service.getActiveUserByAuthUserId.mockResolvedValue(null);

    const result = await facade.getActiveUserByAuthUserId('auth-user-1');

    expect(result).toBeNull();
  });

  it('propagates user profile service failures', async () => {
    const error = new Error('service unavailable');

    service.getActiveUserByAuthUserId.mockRejectedValue(error);

    await expect(
      facade.getActiveUserByAuthUserId('auth-user-1'),
    ).rejects.toThrow(error);
  });
});

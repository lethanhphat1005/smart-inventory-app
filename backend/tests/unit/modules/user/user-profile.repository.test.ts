import { beforeEach, describe, expect, it, vi } from 'vitest';

import { UserProfileRepository } from '../../../../src/modules/user/repositories/user-profile.repository.js';

const prismaMock = vi.hoisted(() => ({
  prisma: {
    userProfile: {
      findUnique: vi.fn(),
    },
  },
}));

vi.mock('../../../../src/db/prismaClient.js', () => ({
  prisma: prismaMock.prisma,
}));

describe('UserProfileRepository', () => {
  let repository: UserProfileRepository;

  beforeEach(() => {
    vi.clearAllMocks();
    repository = new UserProfileRepository();
  });

  it('findByAuthUserId selects the auth-facing user profile fields', async () => {
    const userProfile = {
      userId: 'user-1',
      authUserId: 'auth-user-1',
      email: 'user@example.com',
      fullName: 'Test User',
      activeStatus: 'active',
    };

    prismaMock.prisma.userProfile.findUnique.mockResolvedValue(userProfile);

    const result = await repository.findByAuthUserId('auth-user-1');

    expect(result).toEqual(userProfile);
    expect(prismaMock.prisma.userProfile.findUnique).toHaveBeenCalledWith({
      where: { authUserId: 'auth-user-1' },
      select: {
        userId: true,
        authUserId: true,
        email: true,
        fullName: true,
        activeStatus: true,
      },
    });
  });

  it('findByAuthUserId returns null when the profile is missing', async () => {
    prismaMock.prisma.userProfile.findUnique.mockResolvedValue(null);

    const result = await repository.findByAuthUserId('auth-user-1');

    expect(result).toBeNull();
  });

  it('findByAuthUserId propagates database failures', async () => {
    const error = new Error('database unavailable');

    prismaMock.prisma.userProfile.findUnique.mockRejectedValue(error);

    await expect(repository.findByAuthUserId('auth-user-1')).rejects.toThrow(
      error,
    );
  });
});

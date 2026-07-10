import { beforeEach, describe, expect, it, vi } from 'vitest';

import { UserProfileRepository } from '../../../../src/modules/user-profile/repositories/user-profile.repository.js';

const prismaMock = vi.hoisted(() => ({
  prisma: {
    userProfile: {
      findUnique: vi.fn(),
      create: vi.fn(),
      update: vi.fn(),
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

  it('findByAuthUserId looks up a unique profile by auth user id', async () => {
    const profile = { userId: 'user-1', authUserId: 'auth-user-1' };

    prismaMock.prisma.userProfile.findUnique.mockResolvedValue(profile);

    const result = await repository.findByAuthUserId('auth-user-1');

    expect(result).toEqual(profile);
    expect(prismaMock.prisma.userProfile.findUnique).toHaveBeenCalledWith({
      where: {
        authUserId: 'auth-user-1',
      },
    });
  });

  it('createOne writes the auth id, email, and full name', async () => {
    const profile = { userId: 'user-1', authUserId: 'auth-user-1' };

    prismaMock.prisma.userProfile.create.mockResolvedValue(profile);

    const result = await repository.createOne('auth-user-1', {
      email: 'user@example.com',
      fullName: 'Test User',
    });

    expect(result).toEqual(profile);
    expect(prismaMock.prisma.userProfile.create).toHaveBeenCalledWith({
      data: {
        authUserId: 'auth-user-1',
        email: 'user@example.com',
        fullName: 'Test User',
      },
    });
  });

  it('findById looks up a unique profile by user id', async () => {
    const profile = { userId: 'user-1' };

    prismaMock.prisma.userProfile.findUnique.mockResolvedValue(profile);

    const result = await repository.findById('user-1');

    expect(result).toEqual(profile);
    expect(prismaMock.prisma.userProfile.findUnique).toHaveBeenCalledWith({
      where: { userId: 'user-1' },
    });
  });

  it('updateOne updates only the provided profile fields', async () => {
    const profile = {
      userId: 'user-1',
      fullName: 'Updated User',
      phone: '1234567890',
    };

    prismaMock.prisma.userProfile.update.mockResolvedValue(profile);

    const result = await repository.updateOne('user-1', {
      fullName: 'Updated User',
      phone: '1234567890',
    });

    expect(result).toEqual(profile);
    expect(prismaMock.prisma.userProfile.update).toHaveBeenCalledWith({
      where: { userId: 'user-1' },
      data: {
        fullName: 'Updated User',
        phone: '1234567890',
      },
    });
  });

  it('propagates database failures', async () => {
    const error = new Error('database unavailable');

    prismaMock.prisma.userProfile.findUnique.mockRejectedValue(error);

    await expect(repository.findByAuthUserId('auth-user-1')).rejects.toThrow(
      error,
    );
  });
});

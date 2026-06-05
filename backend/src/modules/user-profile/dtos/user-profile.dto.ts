import type { UserProfile } from '../../../generated/prisma/client.js';

export type UserProfileResponseDto = UserProfile;

export type CreateUserProfileDto = Pick<UserProfile, 'email' | 'fullName'>;

export type UpdateUserProfileDto = Partial<
  Pick<UserProfile, 'fullName' | 'address' | 'phone'>
>;

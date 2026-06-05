import type { StoreMember } from '../../../generated/prisma/client.js';

export type StoreMembershipList = Pick<StoreMember, 'userId' | 'storeId'>;

export type StoreMembershipResponseDto = Omit<StoreMember, 'joinedAt'>;

export type CreateStoreMembershipDto = Omit<
  StoreMember,
  'joinedAt' | 'activeStatus'
>;

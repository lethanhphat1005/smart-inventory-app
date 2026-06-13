import type {
  StoreMember,
  UserProfile,
} from '../../../generated/prisma/client.js';
import type { StoreRole } from '../../../generated/prisma/enums.js';

export type StoreMemberResponseDto = StoreMember;

export type UpdateStoreMemberRoleDto = {
  role: StoreRole;
};

export type StoreMemberUserResponseDto = Pick<
  UserProfile,
  'userId' | 'email' | 'fullName' | 'phone' | 'address' | 'activeStatus'
> & {
  role: StoreRole;
  joinedAt: Date;
};

export type RawStoreMemberDto = {
  role: StoreRole;
  joinedAt: Date;
  user: UserProfile;
};

export type StoreMembershipList = Pick<StoreMember, 'userId' | 'storeId'>;

export type RbacStoreMembershipResponseDto = Omit<
  StoreMember,
  'joinedAt' | 'activeStatus'
>;

export type CreateStoreMembershipDto = Omit<
  StoreMember,
  'joinedAt' | 'activeStatus'
>;

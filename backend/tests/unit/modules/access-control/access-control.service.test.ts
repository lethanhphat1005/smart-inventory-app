import { describe, expect, it } from 'vitest';

import { accessControlService } from '../../../../src/modules/access-control/access-control.service.js';
import {
  PERMISSION,
  ROLE,
} from '../../../../src/modules/access-control/role-permission.constant.js';
import { ROLE_PERMISSIONS } from '../../../../src/modules/access-control/role-permission.map.js';

import type {
  AppPermission,
  AppRole,
} from '../../../../src/modules/access-control/app-role-permission.type.js';

describe('accessControlService', () => {
  describe('getPermissionsByRole', () => {
    it.each([ROLE.OWNER, ROLE.MANAGER, ROLE.STAFF] satisfies AppRole[])(
      'returns permissions configured for %s',
      (role) => {
        expect(accessControlService.getPermissionsByRole(role)).toEqual(
          ROLE_PERMISSIONS[role],
        );
      },
    );

    it('returns an empty permission list for an unknown role', () => {
      expect(
        accessControlService.getPermissionsByRole('CASHIER' as AppRole),
      ).toEqual([]);
    });
  });

  describe('hasPermission', () => {
    it('allows owners to perform owner-only store writes', () => {
      expect(
        accessControlService.hasPermission({
          role: ROLE.OWNER,
          permission: PERMISSION.STORE_WRITE,
        }),
      ).toBe(true);
    });

    it('allows managers to manage store members', () => {
      expect(
        accessControlService.hasPermission({
          role: ROLE.MANAGER,
          permission: PERMISSION.STORE_MEMBER_WRITE,
        }),
      ).toBe(true);
    });

    it('allows staff to perform permitted transaction writes', () => {
      expect(
        accessControlService.hasPermission({
          role: ROLE.STAFF,
          permission: PERMISSION.TRANSACTION_WRITE,
        }),
      ).toBe(true);
    });

    it.each([
      [ROLE.STAFF, PERMISSION.PRODUCT_WRITE],
      [ROLE.STAFF, PERMISSION.STORE_MEMBER_WRITE],
      [ROLE.MANAGER, PERMISSION.STORE_WRITE],
      [ROLE.OWNER, PERMISSION.STORE_MEMBER_READ],
    ] satisfies [AppRole, AppPermission][])(
      'denies %s when %s is not configured',
      (role, permission) => {
        expect(
          accessControlService.hasPermission({
            role,
            permission,
          }),
        ).toBe(false);
      },
    );

    it('denies unknown roles', () => {
      expect(
        accessControlService.hasPermission({
          role: 'CASHIER' as AppRole,
          permission: PERMISSION.PRODUCT_READ,
        }),
      ).toBe(false);
    });
  });
});

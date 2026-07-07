import { describe, expect, it } from 'vitest';

import { requirePermission } from '../../../../src/modules/access-control/require-permission.middleware.js';
import { PERMISSION } from '../../../../src/modules/access-control/role-permission.constant.js';

describe('access-control module exports', () => {
  it('exports public permission middleware and constants', async () => {
    const module =
      await import('../../../../src/modules/access-control/index.js');

    expect(module.requirePermission).toBe(requirePermission);
    expect(module.PERMISSION).toBe(PERMISSION);
  });
});

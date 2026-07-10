import { beforeEach, describe, expect, it, vi } from 'vitest';

import { UnitService } from '../../../../src/modules/product-packages/services/unit.service.js';

describe('UnitService', () => {
  const unitRepository = {
    findAll: vi.fn(),
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('returns all units from the repository', async () => {
    unitRepository.findAll.mockResolvedValue([
      {
        unitId: 'unit-1',
        code: 'PCS',
        name: 'piece',
      },
    ]);

    const service = new UnitService(unitRepository as never);

    await expect(service.getAllUnits()).resolves.toEqual([
      {
        unitId: 'unit-1',
        code: 'PCS',
        name: 'piece',
      },
    ]);
    expect(unitRepository.findAll).toHaveBeenCalledTimes(1);
  });
});

import { describe, expect, it } from 'vitest';

import {
  userProfileController,
  userProfileRepository,
  userProfileService,
} from '../../../../src/modules/user-profile/user-profile.module.js';

describe('userProfileModule', () => {
  it('exports initialized repository, service, and controller singletons', () => {
    expect(userProfileRepository).toBeDefined();
    expect(userProfileService).toBeDefined();
    expect(userProfileController).toBeDefined();
  });
});

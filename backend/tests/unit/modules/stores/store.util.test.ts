import { describe, expect, it } from 'vitest';

import { generateFormattedInviteCode } from '../../../../src/modules/stores/store.util.js';

describe('generateFormattedInviteCode', () => {
  it('generates a default invite code in grouped lowercase format', () => {
    const inviteCode = generateFormattedInviteCode();

    expect(inviteCode).toMatch(/^[a-z0-9]{4}(-[a-z0-9]{4}){3}$/);
  });

  it('returns the raw code fallback when no groups can be formed', () => {
    const inviteCode = generateFormattedInviteCode(0);

    expect(inviteCode).toBe('');
  });
});

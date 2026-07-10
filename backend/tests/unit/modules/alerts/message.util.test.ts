import { describe, expect, it, vi } from 'vitest';

import { getRandomMessage } from '../../../../src/modules/alerts/utils/message.util.js';

describe('alert message utils', () => {
  it('returns an empty string when no templates are provided', () => {
    expect(getRandomMessage([])).toBe('');
  });

  it('returns a template at the generated random index', () => {
    const randomSpy = vi.spyOn(Math, 'random').mockReturnValue(0.7);

    expect(getRandomMessage(['first', 'second', 'third'])).toBe('third');

    randomSpy.mockRestore();
  });
});

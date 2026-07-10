import { afterEach, describe, expect, it, vi } from 'vitest';

import { TimeResolverHelper } from '../../../../src/modules/chat-bot/services/helpers/time-resolver.helper.js';

describe('TimeResolverHelper', () => {
  afterEach(() => {
    vi.useRealTimers();
  });

  it('returns an empty range for missing or unknown periods', () => {
    expect(TimeResolverHelper.resolveTimePeriod(undefined)).toEqual({});
    expect(TimeResolverHelper.resolveTimePeriod('forever')).toEqual({});
  });

  it('resolves today and yesterday using the Vietnam time boundary', () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2026-07-08T05:30:00.000Z'));

    expect(TimeResolverHelper.resolveTimePeriod('today')).toEqual({
      startDate: '2026-07-07T17:00:00.000Z',
    });
    expect(TimeResolverHelper.resolveTimePeriod('yesterday')).toEqual({
      startDate: '2026-07-06T17:00:00.000Z',
      endDate: '2026-07-07T16:59:59.999Z',
    });
  });
});

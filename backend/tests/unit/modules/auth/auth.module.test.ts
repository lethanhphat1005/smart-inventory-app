import { describe, expect, it, vi } from 'vitest';

const moduleMocks = vi.hoisted(() => ({
  authenticate: vi.fn(),
}));

vi.mock(
  '../../../../src/modules/auth/middlewares/authenticate.middleware.js',
  () => ({
    authenticate: moduleMocks.authenticate,
  }),
);

describe('auth module wiring', () => {
  it('exports the authenticate middleware', async () => {
    const module = await import('../../../../src/modules/auth/index.js');

    expect(module.authenticate).toBe(moduleMocks.authenticate);
  });
});

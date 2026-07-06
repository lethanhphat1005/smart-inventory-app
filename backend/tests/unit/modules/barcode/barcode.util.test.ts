import { describe, expect, it } from 'vitest';

import {
  extractPackagingTokensFromText,
  normalizeApiPayload,
  normalizeText,
  reduceProviderNoise,
  tokenizeText,
} from '../../../../src/modules/barcode/utils/index.js';

describe('barcode utils', () => {
  it('normalizes text by removing accents, punctuation, and duplicate spaces', () => {
    expect(normalizeText(' Ca phe sua - 500ML! ')).toBe('ca phe sua 500ml');
    expect(normalizeText('   ')).toBeUndefined();
    expect(normalizeText(null)).toBeUndefined();
  });

  it('normalizes API payload and returns null when no signal remains', () => {
    expect(
      normalizeApiPayload({
        normalizedName: ' Coca-Cola ',
        normalizedBrand: ' Coca Cola ',
        normalizedPackageText: ' 330ML ',
      }),
    ).toEqual({
      normalizedName: 'coca cola',
      normalizedBrand: 'coca cola',
      normalizedPackageText: '330ml',
    });
    expect(
      normalizeApiPayload({
        normalizedName: '',
        normalizedBrand: null,
        normalizedPackageText: undefined,
      }),
    ).toBeNull();
  });

  it('tokenizes unique non-empty tokens', () => {
    expect(tokenizeText('coca cola coca 330ml')).toEqual([
      'coca',
      'cola',
      '330ml',
    ]);
    expect(tokenizeText(undefined)).toEqual([]);
  });

  it('reduces provider title noise with configurable options', () => {
    expect(
      reduceProviderNoise('Cola Drink (imported) [sale] - 6 pack 330ml'),
    ).toBe('Cola Drink');
    expect(
      reduceProviderNoise('Brand 24', {
        removePackagingPhrases: false,
        keepNumbers: false,
      }),
    ).toBe('Brand');
    expect(
      reduceProviderNoise('330ml', { keepNumbers: false }),
    ).toBeUndefined();
  });

  it('extracts package-related tokens from free text', () => {
    expect(extractPackagingTokensFromText('Cola 24 x 330ml bottles')).toEqual([
      '330ml',
      '24',
      'bottles',
      'x',
    ]);
    expect(extractPackagingTokensFromText(null)).toEqual([]);
  });
});

import { describe, expect, it, vi } from 'vitest';

import {
  searchByKeywordQuerySchema,
  searchByPrefixQuerySchema,
  validateGetProductsByKeyword,
  validateGetProductsByPrefix,
} from '../../../../src/modules/search/search.validator.js';

import type { NextFunction, Request, Response } from 'express';

describe('search validators', () => {
  describe('searchByKeywordQuerySchema', () => {
    it('accepts valid keyword search query, trims keyword, and coerces pagination', () => {
      const result = searchByKeywordQuerySchema.parse({
        keyword: ' Milk ',
        page: '2',
        limit: '25',
      });

      expect(result).toEqual({
        keyword: 'Milk',
        page: 2,
        limit: 25,
      });
    });

    it('applies default pagination values', () => {
      const result = searchByKeywordQuerySchema.parse({
        keyword: 'Milk',
      });

      expect(result).toEqual({
        keyword: 'Milk',
        page: 1,
        limit: 50,
      });
    });

    it('rejects empty keyword after trimming', () => {
      expect(() =>
        searchByKeywordQuerySchema.parse({ keyword: '   ' }),
      ).toThrow('Keyword is required');
    });

    it('rejects keyword longer than 100 characters', () => {
      expect(() =>
        searchByKeywordQuerySchema.parse({ keyword: 'a'.repeat(101) }),
      ).toThrow('Keyword must be at most 100 characters');
    });

    it('rejects invalid pagination boundaries', () => {
      expect(() =>
        searchByKeywordQuerySchema.parse({ keyword: 'Milk', page: '0' }),
      ).toThrow();
      expect(() =>
        searchByKeywordQuerySchema.parse({ keyword: 'Milk', limit: '101' }),
      ).toThrow();
    });
  });

  describe('searchByPrefixQuerySchema', () => {
    it('accepts valid prefix query, trims prefix, and coerces limit', () => {
      const result = searchByPrefixQuerySchema.parse({
        prefix: ' Mi ',
        limit: '5',
      });

      expect(result).toEqual({
        prefix: 'Mi',
        limit: 5,
      });
    });

    it('allows omitted prefix limit', () => {
      const result = searchByPrefixQuerySchema.parse({
        prefix: 'Mi',
      });

      expect(result).toEqual({
        prefix: 'Mi',
      });
    });

    it('rejects empty prefix after trimming', () => {
      expect(() => searchByPrefixQuerySchema.parse({ prefix: '   ' })).toThrow(
        'Prefix is required',
      );
    });

    it('rejects prefix longer than 100 characters', () => {
      expect(() =>
        searchByPrefixQuerySchema.parse({ prefix: 'a'.repeat(101) }),
      ).toThrow('Prefix must be at most 100 characters');
    });

    it('rejects prefix limits outside the allowed range', () => {
      expect(() =>
        searchByPrefixQuerySchema.parse({ prefix: 'Mi', limit: '0' }),
      ).toThrow();
      expect(() =>
        searchByPrefixQuerySchema.parse({ prefix: 'Mi', limit: '21' }),
      ).toThrow();
    });
  });

  describe('legacy validator middlewares', () => {
    it('validateGetProductsByKeyword stores the validated query in response locals', () => {
      const req = {
        query: {
          keyword: ' Milk ',
          page: '2',
          limit: '25',
        },
      } as unknown as Request;
      const res = {
        locals: {},
      } as Response;
      const next = vi.fn() as NextFunction;

      validateGetProductsByKeyword(req, res, next);

      expect(res.locals.validatedQuery).toEqual({
        keyword: 'Milk',
        page: 2,
        limit: 25,
      });
      expect(next).toHaveBeenCalledTimes(1);
    });

    it('validateGetProductsByPrefix stores the validated query in response locals', () => {
      const req = {
        query: {
          prefix: ' Mi ',
          limit: '5',
        },
      } as unknown as Request;
      const res = {
        locals: {},
      } as Response;
      const next = vi.fn() as NextFunction;

      validateGetProductsByPrefix(req, res, next);

      expect(res.locals.validatedQuery).toEqual({
        prefix: 'Mi',
        limit: 5,
      });
      expect(next).toHaveBeenCalledTimes(1);
    });
  });
});

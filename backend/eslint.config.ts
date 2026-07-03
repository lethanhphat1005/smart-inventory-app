import js from '@eslint/js';
import { defineConfig } from 'eslint/config';
import prettier from 'eslint-config-prettier';
import importPlugin from 'eslint-plugin-import';
import security from 'eslint-plugin-security';
import unusedImports from 'eslint-plugin-unused-imports';
import globals from 'globals';
import tseslint from 'typescript-eslint';

export default defineConfig([
  {
    ignores: [
      'dist/**',
      'build/**',
      'coverage/**',
      'node_modules/**',
      '*.config.ts',
      '*.config.js',
      '*.config.cjs',
    ],
  },

  js.configs.recommended,
  ...tseslint.configs.recommended,
  prettier, // Tắt các rule xung đột với Prettier

  {
    files: ['**/*.ts', '**/*.mts', '**/*.cts'],
    languageOptions: {
      parser: tseslint.parser,
      parserOptions: {
        project: './tsconfig.eslint.json',
        sourceType: 'module',
        ecmaVersion: 'latest',
      },
      globals: {
        ...globals.node,
      },
    },
    plugins: {
      import: importPlugin,
      'unused-imports': unusedImports,
      security,
    },
    rules: {
      // ---FORMAT & STYLE---
      semi: ['error', 'always'], // Bắt buộc có dấu ; ở cuối statement
      quotes: ['error', 'single', { avoidEscape: true }], // Bắt buộc dùng nháy đơn, trừ khi cần escape

      // Cảnh báo nếu 1 dòng quá 100 ký tự
      // ignoreUrls / ignoreStrings để đỡ quá gắt với URL hoặc string dài
      'max-len': [
        'warn',
        {
          code: 100,
          ignoreUrls: true,
          ignoreStrings: true,
          ignoreTemplateLiterals: true,
          ignoreComments: false,
        },
      ],

      'eol-last': ['error', 'always'], // File phải kết thúc bằng 1 ký tự xuống dòng
      'no-trailing-spaces': 'error', // Không cho phép dư khoảng trắng ở cuối dòng
      curly: ['error', 'all'], // Bắt buộc luôn dùng {} cho if / else / for / while

      'brace-style': ['error', '1tbs', { allowSingleLine: false }], // Không cho phép block viết gộp trên một dòng

      'nonblock-statement-body-position': ['error', 'below'], // Ép phần thân statement nằm ở dòng riêng

      eqeqeq: ['error', 'always'], // Bắt buộc dùng === và !== thay vì == và !=

      'padding-line-between-statements': [
        'error',
        // Thêm 1 dòng trống sau block khai báo biến/hằng trước khi sang statement khác
        { blankLine: 'always', prev: ['const', 'let', 'var'], next: '*' },

        // Nhưng không bắt buộc dòng trống giữa các khai báo liên tiếp
        {
          blankLine: 'any',
          prev: ['const', 'let', 'var'],
          next: ['const', 'let', 'var'],
        },

        // Luôn có 1 dòng trống trước return
        { blankLine: 'always', prev: '*', next: 'return' },
      ],

      'one-var': ['error', 'never'], // Mỗi dòng chỉ khai báo 1 biến hoặc 1 hằng

      // ---IMPORT ORDER---
      // Sắp xếp import theo nhóm:
      // built-in -> external -> internal -> parent/sibling/index
      // đồng thời chèn dòng trống giữa các nhóm
      'import/order': [
        'error',
        {
          groups: [
            'builtin',
            'external',
            'internal',
            ['parent', 'sibling', 'index'],
            'object',
            'type',
          ],
          'newlines-between': 'always',
          alphabetize: {
            order: 'asc',
            caseInsensitive: true,
          },
          pathGroups: [
            {
              pattern: '@/**',
              group: 'internal',
            },
          ],
          pathGroupsExcludedImportTypes: ['builtin'],
        },
      ],

      // ---UNUSED IMPORTS / VARS---

      // Tắt rule mặc định để tránh trùng với plugin unused-imports/no-unused-vars
      'no-unused-vars': 'off',
      '@typescript-eslint/no-unused-vars': 'off',

      'unused-imports/no-unused-imports': 'error', // Báo lỗi khi có import không dùng tới

      // Cảnh báo biến hoặc parameter không dùng
      // Cho phép prefix "_" để biểu thị cố ý không dùng
      'unused-imports/no-unused-vars': [
        'warn',
        {
          vars: 'all',
          varsIgnorePattern: '^_',
          args: 'after-used',
          argsIgnorePattern: '^_',
        },
      ],

      // ---TYPESCRIPT SAFETY---
      '@typescript-eslint/no-explicit-any': 'warn', // Cảnh báo khi dùng any

      '@typescript-eslint/naming-convention': [
        'error',

        // Biến, function, method, parameter dùng lowerCamelCase
        {
          selector: ['variableLike', 'function', 'method', 'parameter'],
          format: ['camelCase'],
          leadingUnderscore: 'allow',
        },

        // Class, interface, type alias, enum dùng UpperCamelCase
        {
          selector: 'typeLike',
          format: ['PascalCase'],
        },

        // Hằng số cấp module/global cho phép UPPER_SNAKE_CASE
        {
          selector: 'variable',
          modifiers: ['const', 'global'],
          format: ['camelCase', 'UPPER_CASE'],
        },

        // Enum member cho phép PascalCase hoặc UPPER_SNAKE_CASE
        {
          selector: 'enumMember',
          format: ['PascalCase', 'UPPER_CASE'],
        },

        // Biến, Parameter boolean nên có prefix is/has/can/will
        {
          selector: ['variable', 'parameter'],
          types: ['boolean'],
          format: ['PascalCase'],
          prefix: ['is', 'has', 'can', 'will'],
          leadingUnderscore: 'allow',
        },
      ],

      // ---ASYNC / PROMISE---
      'require-await': 'off',
      '@typescript-eslint/require-await': 'warn', // Cảnh báo async function nhưng thực tế không có await
      '@typescript-eslint/no-floating-promises': 'error', // Cảnh báo promise bị tạo ra nhưng không await / không handle
      '@typescript-eslint/no-misused-promises': 'error', // Ngăn truyền promise vào nơi không mong đợi promise

      // ---CONTROL FLOW / STATEMENTS---

      'default-case': 'error', // Mọi switch đều phải có default

      'no-fallthrough': 'error', // Không cho phép fallthrough ngoài ý muốn giữa các case

      // ---FUNCTION STYLE---

      'prefer-arrow-callback': 'error', // Ưu tiên arrow function cho callback

      'func-style': ['error', 'expression', { allowArrowFunctions: true }], // Ưu tiên function expression / arrow cho standalone function

      // ---CODE QUALITY---
      'no-else-return': ['error', { allowElseIf: false }], // Không cần else nếu if đã return bên trong
      'no-unreachable': 'error', // Không cho phép code sau return / throw
      'no-console': ['warn', { allow: ['warn', 'error', 'info'] }], // Cảnh báo console.log thông thường

      // ---SECURITY---
      'security/detect-object-injection': 'off', // Rule này thường khá noisy với object access động trong TS backend
      'security/detect-non-literal-fs-filename': 'warn', // Cảnh báo khi truyền filename không phải literal vào fs
      'security/detect-possible-timing-attacks': 'warn', // Cảnh báo các trường hợp có thể gây timing attack
      'security/detect-eval-with-expression': 'error', // Cấm eval(expression)
      'security/detect-new-buffer': 'error', // Cấm new Buffer() kiểu cũ vì không an toàn
    },
  },
]);

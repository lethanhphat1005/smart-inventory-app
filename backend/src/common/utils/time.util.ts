import type { Prisma } from '../../generated/prisma/client.js';

const DEFAULT_TIMEZONE = 'Asia/Ho_Chi_Minh';
const DEFAULT_OFFSET = '+07:00';

// NOTE: Hệ thống sẽ quy đổi tất cả datetime về
// NOTE: UTC trước khi so sánh

// convert từ date range client về UTC
// trước khi trả về filter date range cho các hàm pagination
export const buildDateRangeFilter = (
  startDate?: string,
  endDate?: string,
  offset: string = DEFAULT_OFFSET,
): Prisma.DateTimeFilter | undefined => {
  if (!startDate && !endDate) {
    return undefined;
  }

  const filter: Prisma.DateTimeFilter = {};

  if (startDate) {
    filter.gte = new Date(`${startDate}T00:00:00.000${offset}`);
  }

  if (endDate) {
    filter.lte = new Date(`${endDate}T23:59:59.999${offset}`);
  }

  return filter;
};

// convert Date trả về chuẩn ISO
export const toIsoUtc = (date: Date | null): string | null => {
  if (!date) {
    return null;
  }

  return date.toISOString();
};

/* in log debug date time.
Vd:
ISO (UTC): 2026-04-08T03:00:00.000Z
VN:       08/04/2026 10:00:00 */
export const debugDate = (date: Date): void => {
  console.info('ISO (UTC):', date.toISOString());

  console.info(
    'VN:',
    new Intl.DateTimeFormat('en-GB', {
      timeZone: DEFAULT_TIMEZONE,
      dateStyle: 'full',
      timeStyle: 'long',
    }).format(date),
  );
};

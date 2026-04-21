import { Redis } from 'ioredis';
import 'dotenv/config';

export const redisClient = new Redis(
  process.env.REDIS_URL || 'redis://127.0.0.1:6379',
);

redisClient.on('connect', () => {
  console.info('✅ Kết nối Redis thành công!');
});

redisClient.on('error', (err) => {
  console.error('❌ Lỗi kết nối Redis:', err);
});

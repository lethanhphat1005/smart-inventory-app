import { Redis } from 'ioredis';
import 'dotenv/config';

export const redisClient = new Redis(
  process.env.REDIS_URL ?? 'redis://127.0.0.1:6379',
  {
    keyPrefix: process.env.REDIS_PREFIX ?? '', // Prefix cho tất cả key

    lazyConnect: true, // Không connect ngay, chỉ connect khi có command đầu tiên
    enableReadyCheck: true, // Kiểm tra Redis đã sẵn sàng trước khi accept command

    connectTimeout: 3000, // Timeout khi establish TCP connection
    commandTimeout: 2000, // Timeout cho mỗi command Redis
    retryStrategy(times) {
      return Math.min(times * 200, 1000); // Backoff retry khi mất kết nối
    },
  },
);

redisClient.on('connect', () => console.info('Connected to Redis'));
redisClient.on('ready', () => console.info('Redis TLS ready'));
redisClient.on('error', (err) => console.error('Redis error:', err));

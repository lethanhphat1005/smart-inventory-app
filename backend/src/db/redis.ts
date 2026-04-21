import { Redis } from 'ioredis';
import 'dotenv/config';

const redisPort = Number(process.env.REDIS_PORT ?? 6379);

if (Number.isNaN(redisPort)) {
  throw new Error('REDIS_PORT must be a valid number');
}

export const redisClient = new Redis({
  host: process.env.REDIS_HOST ?? '127.0.0.1',
  port: redisPort,
  keyPrefix: process.env.REDIS_PREFIX ?? '', // Prefix cho tất cả key

  lazyConnect: true, // Không connect ngay, chỉ connect khi có command đầu tiên
  enableReadyCheck: true, // Kiểm tra Redis đã sẵn sàng trước khi accept command

  connectTimeout: 3000, // Timeout khi establish TCP connection
  commandTimeout: 2000, // Timeout cho mỗi command Redis
  retryStrategy(times) {
    return Math.min(times * 200, 1000); // Backoff retry khi mất kết nối
  },
});

redisClient.on('connect', () => console.info('Connected to Redis'));
redisClient.on('ready', () => console.info('Redis TLS ready'));
redisClient.on('error', (err) => console.error('Redis error:', err));

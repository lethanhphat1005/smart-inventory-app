import { configure } from '@codegenie/serverless-express';

import { app } from '../app.js';
import { initFirebaseAdmin } from '../config/firebase.config.js';

// Khởi tạo firebase khi khởi động server
await initFirebaseAdmin();

export const handler = configure({ app });

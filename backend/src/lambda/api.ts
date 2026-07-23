import { configure } from '@codegenie/serverless-express';

import { loadApiSecretsToEnvironment } from '../common/utils/get-aws-ssm-parameter.js';
import { initFirebaseAdmin } from '../config/firebase.config.js';

console.info('Start lambda environment: Api Function');

// load secret từ SSM Parameter vào biến môi trường khi khởi tạo server
await loadApiSecretsToEnvironment();

console.info('Loaded SSM Parameter secrets to env variables');

// Khởi tạo firebase
await initFirebaseAdmin();

// dynamic import để load secret value trước khi khởi tạo server
const { app } = await import('../app.js');

export const handler = configure({ app });

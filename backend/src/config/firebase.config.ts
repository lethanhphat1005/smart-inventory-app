import 'dotenv/config';
import { readFileSync } from 'fs';
import { join } from 'path';

import {
  initializeApp,
  cert,
  getApps,
  type ServiceAccount,
} from 'firebase-admin/app';

import { getDirectSsmParameter } from '../common/utils/index.js';

const getFirebaseServiceAccount = async (): Promise<ServiceAccount> => {
  if (process.env.NODE_ENV !== 'production') {
    const serviceAccountPath = join(process.cwd(), 'serviceAccountKey.json');

    return JSON.parse(readFileSync(serviceAccountPath, 'utf8'));
  }

  const parameterName = process.env.FIREBASE_SERVICE_ACCOUNT_PARAMETER;

  if (!parameterName) {
    throw new Error('FIREBASE_SERVICE_ACCOUNT_PARAMETER is missing');
  }

  const serviceAccountJson = await getDirectSsmParameter(parameterName);

  return JSON.parse(serviceAccountJson);
};

export const initFirebaseAdmin = async () => {
  if (!getApps().length) {
    try {
      initializeApp({
        credential: cert(await getFirebaseServiceAccount()),
      });

      console.info('[Firebase] Admin SDK initialized successfully');
    } catch (error) {
      console.error(
        '[Firebase] Lỗi khởi tạo Admin SDK. Vui lòng kiểm tra file serviceAccountKey.json',
        error,
      );
    }
  }
};

import 'dotenv/config';
import { readFileSync } from 'fs';
import { join } from 'path';

import { initializeApp, cert, getApps } from 'firebase-admin/app';

export const initFirebaseAdmin = () => {
  if (!getApps().length) {
    try {
      const serviceAccountPath =
        process.env.NODE_ENV === 'production'
          ? (process.env.FIREBASE_SERVICE_ACCOUNT_PATH ??
            '/run/secrets/serviceAccountKey.json')
          : join(process.cwd(), 'serviceAccountKey.json');
      const serviceAccount = JSON.parse(
        // eslint-disable-next-line security/detect-non-literal-fs-filename
        readFileSync(serviceAccountPath, 'utf8'),
      );

      initializeApp({
        credential: cert(serviceAccount),
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

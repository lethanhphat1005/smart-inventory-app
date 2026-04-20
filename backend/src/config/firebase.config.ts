// src/config/firebase.config.ts
import { readFileSync } from 'fs';
import { join } from 'path';

import { initializeApp, cert, getApps } from 'firebase-admin/app';

export const initFirebaseAdmin = () => {
  // Sử dụng getApps().length thay vì admin.apps.length
  if (!getApps().length) {
    try {
      // Đọc file serviceAccountKey.json từ thư mục gốc của project
      const serviceAccountPath = join(process.cwd(), 'serviceAccountKey.json');
      const serviceAccount = JSON.parse(
        readFileSync(serviceAccountPath, 'utf8'),
      );

      // Khởi tạo app với modular import
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

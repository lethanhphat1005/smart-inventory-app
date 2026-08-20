// NOTE: Tách entry point cho cron để tránh kéo theo các HTTP dependency
// không cần thiết khi Lambda khởi tạo module, và tránh circular dependency tiềm ẩn
export { smartDecisionService, smartAlertService } from './alerts.module.js';

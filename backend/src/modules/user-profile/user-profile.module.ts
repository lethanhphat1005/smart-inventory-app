import { UserProfileController } from './controllers/user-profile.controller.js';
import { UserProfileRepository } from './repositories/user-profile.repository.js';
import { UserProfileService } from './services/user-profile.service.js';

const userProfileRepository = new UserProfileRepository();
const userProfileService = new UserProfileService(userProfileRepository);
const userProfileController = new UserProfileController(userProfileService);

export { userProfileRepository, userProfileService, userProfileController };

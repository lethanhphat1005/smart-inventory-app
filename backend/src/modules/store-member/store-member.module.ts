import { StoreMemberController } from './controller/store-member.controller.js';
import { StoreMemberRepository } from './repository/store-member.repository.js';
import { StoreMemberService } from './service/store-member.service.js';
import { prisma } from '../../db/prismaClient.js';

const storeMemberRepository = new StoreMemberRepository(prisma);
const storeMemberService = new StoreMemberService(storeMemberRepository);
const storeMemberController = new StoreMemberController(storeMemberService);

export { storeMemberRepository, storeMemberService, storeMemberController };

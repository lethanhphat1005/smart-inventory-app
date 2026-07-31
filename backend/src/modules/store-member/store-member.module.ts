import { StoreMemberController } from './store-member.controller.js';
import { StoreMemberRepository } from './store-member.repository.js';
import { StoreMemberService } from './store-member.service.js';
import { prisma } from '../../db/prismaClient.js';

const storeMemberRepository = new StoreMemberRepository(prisma);
const storeMemberService = new StoreMemberService(storeMemberRepository);
const storeMemberController = new StoreMemberController(storeMemberService);

export { storeMemberRepository, storeMemberService, storeMemberController };

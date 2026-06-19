import { prisma as prismaA } from './lib/prisma'
import { prisma as prismaB } from './lib/prisma'

console.log('Même instance ?', prismaA === prismaB)  // doit afficher true
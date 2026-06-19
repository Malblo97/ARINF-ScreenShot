import 'dotenv/config'
import { PrismaClient } from '../generated/prisma/client'
import { PrismaPg } from '@prisma/adapter-pg'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL! })

export const prisma: PrismaClient =
  globalForPrisma.prisma ?? new PrismaClient({ adapter })

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}

export default prisma

/*
// Dans n'importe quel autre fichier :
import { prisma } from '../lib/prisma'

// On utilise prisma directement — toujours la même instance
const users = await prisma.userAccounts.findMany()
console.log(users)

L'opérateur ?? (nullish coalescing) signifie : "si la valeur de gauche est null ou undefined, 
prends la valeur de droite". Donc : si l'instance existe déjà dans globalThis, on la réutilise. 
Sinon, on en crée une nouvelle.
*/
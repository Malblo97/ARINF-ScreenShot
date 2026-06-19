import { prisma } from './lib/prisma'

async function main() {
  await prisma.$connect()
  console.log('Connexion Prisma OK')
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
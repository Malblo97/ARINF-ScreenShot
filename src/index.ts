import { prisma } from './lib/prisma'

async function main() {
  const user = await prisma.userAccounts.create({
    data: {
      email: 'thomas@studio.io',
      passwordHash: 'hash_temporaire',
      displayName: 'Thomas Renaud',
    }
  })
  console.log('Utilisateur créé :', user)

  const users = await prisma.userAccounts.findMany()
  console.log('Total users :', users.length)
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
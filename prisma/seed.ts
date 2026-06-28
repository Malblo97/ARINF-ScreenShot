// Source - https://stackoverflow.com/a/79873474
// Posted by Damodharan, modified by community. See post 'Timeline' for change history
// Retrieved 2026-06-28, License - CC BY-SA 4.0

import { PrismaPg } from '@prisma/adapter-pg'
import { PrismaClient } from '../src/generated/prisma/client'

const adapter = new PrismaPg({ connectionString: "postgresql://postgres:%251Ea.g8UT5RAx5bg@localhost:5432/screenshot_dev" })
const prisma = new PrismaClient({ adapter })


async function main() {
  console.log('🌱 Seed en cours...')

  // Étape 1 : créer l'utilisateur
  const thomas = await prisma.userAccounts.create({
    data: {
      email: 'thomas@studio.io',
      passwordHash: 'hash_dev_uniquement',  // jamais un vrai hash en seed
      displayName: 'Thomas Renaud'
    }
  })

  // Étape 2 : créer les rôles nécessaires
  const ownerRole = await prisma.roles.create({
    data: { name: 'owner', permissions: ['scene:write', 'validation:approve', 'member:invite'] }
  })

  // Étape 3 : créer le projet
  const project = await prisma.projects.create({
    data: {
      title: 'DRIVE 2',
      description: 'Séquel underground. Ryan revient.',
      status: 'writing',
      UsAcc_owner_id: thomas.id
    }
  })

  // Étape 4 : lier Thomas au projet
  await prisma.projectUsers.create({
    data: {
      Proj_contains_id: project.id,
      UsAcc_member_id: thomas.id,
      Rol_defines_id: ownerRole.id
    }
  })

}
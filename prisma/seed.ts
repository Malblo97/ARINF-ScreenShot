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

// Étape 5 : le script
  const script = await prisma.scripts.create({
    data: {
      title: 'Drive 2',
      variant: 'main',
      version: 3,
      Proj_contains_id: project.id
    }
  })

  // Étape 6 : les actes
  const act1 = await prisma.acts.create({
    data: { title: 'Acte I — Retour', position: 1, status: 'approved', Scri_contains_id: script.id }
  })
  const act2 = await prisma.acts.create({
    data: { title: 'Acte II — La dette', position: 2, status: 'draft', Scri_contains_id: script.id }
  })

  // Étape 7 : les scènes
  const scene1 = await prisma.scenes.create({
    data: {
      title: 'Ouverture', interiorExterior: 'EXT', location: 'AUTOROUTE A7',
      timeOfDay: 'NUIT', position: 1, status: 'approved', Act_contains_id: act1.id
    }
  })
  const scene2 = await prisma.scenes.create({
    data: {
      title: 'Le bar', interiorExterior: 'INT', location: 'BAR SATELLITE',
      timeOfDay: 'NUIT', position: 2, status: 'review', Act_contains_id: act1.id
    }
  })
  const scene3 = await prisma.scenes.create({
    data: {
      title: 'Le garage', interiorExterior: 'INT', location: 'GARAGE RAMOS',
      timeOfDay: 'JOUR', position: 1, status: 'draft', Act_contains_id: act2.id
    }
  })

// Étape 8 : les personnages
  const ryan = await prisma.characters.create({
    data: { name: 'RYAN', description: 'Chauffeur de nuit. Muet, précis, dangereux.', Proj_contains_id: project.id }
  })
  const irene = await prisma.characters.create({
    data: { name: 'IRENE', description: 'Barmaid. Connaît Ryan depuis longtemps.', Proj_contains_id: project.id }
  })

  // Étape 9 : contenu de la scène 1 (ouverture, pas de dialogue)
  await prisma.sceneElements.create({
    data: { type: 'action', content: 'Une Malibu blanche fend la pluie à 180 km/h. Aucun bruit de moteur.', position: 1, Scen_contains_id: scene1.id }
  })
  await prisma.sceneElements.create({
    data: { type: 'action', content: 'RYAN garde les deux mains sur le volant. Il ne regarde pas la route.', position: 2, Scen_contains_id: scene1.id }
  })

  // Étape 10 : contenu de la scène 2 (avec dialogue — dialog puis dialog_line enfant)
  await prisma.sceneElements.create({
    data: { type: 'action', content: "Le bar est presque vide. IRENE essuie un verre.", position: 1, Scen_contains_id: scene2.id }
  })

  const dialogIrene = await prisma.sceneElements.create({
    data: { type: 'dialog', position: 2, Scen_contains_id: scene2.id, Char_speaks_id: irene.id }
  })
  await prisma.sceneElements.create({
    data: { type: 'dialog_line', content: 'Tu es en retard.', position: 1, Scen_contains_id: scene2.id, Scen_parent_id: dialogIrene.id }
  })

  const dialogRyan = await prisma.sceneElements.create({
    data: { type: 'dialog', position: 3, Scen_contains_id: scene2.id, Char_speaks_id: ryan.id }
  })
  await prisma.sceneElements.create({
    data: { type: 'dialog_line', content: 'Je conduis.', position: 1, Scen_contains_id: scene2.id, Scen_parent_id: dialogRyan.id }
  })

  console.log('✅ Bloc 3 seedé : Characters + SceneElements (slugline calculée, action, dialog/dialog_line)')
  console.log('🎬 Seed terminé.')
}

main()

  .catch((e) => { console.error(e); process.exit(1) })
  .finally(() => prisma.$disconnect())
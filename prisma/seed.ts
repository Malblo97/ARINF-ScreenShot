// Source - https://stackoverflow.com/a/79873474
// Posted by Damodharan, modified by community. See post 'Timeline' for change history
// Retrieved 2026-06-28, License - CC BY-SA 4.0

import { PrismaPg } from '@prisma/adapter-pg'
import { PrismaClient } from '../src/generated/prisma/client'

const adapter = new PrismaPg({ connectionString: "postgresql://postgres:%251Ea.g8UT5RAx5bg@localhost:5432/screenshot_dev" })
const prisma = new PrismaClient({ adapter })


async function main() {
  // USER
  const user = await prisma.userAccounts.create({
    data: {
      email: "john.doe@example.com",
      passwordHash: "hashed-password",
      displayName: "John Doe",
      ajUsername: "seed",
    },
  });

  // PROJECT
  const project = await prisma.projects.create({
    data: {
      title: "Mon Premier Film",
      description: "Projet de démonstration",
      status: "draft",
      ajUser: "seed",
      UsAcc_owner_id: user.id,
    },
  });

  // SCRIPT
  const script = await prisma.scripts.create({
    data: {
      title: "Version Principale",
      variant: "main",
      version: 1,
      Proj_contains_id: project.id,
    },
  });

  // ACT (obligatoire pour créer une scène)
  const act = await prisma.acts.create({
    data: {
      title: "Acte 1",
      position: 1,
      Scri_contains_id: script.id,
    },
  });

  // SCENE
  const scene = await prisma.scenes.create({
    data: {
      title: "Ouverture",
      interiorExterior: "INT",
      location: "Appartement",
      timeOfDay: "MATIN",
      position: 1,
      Act_contains_id: act.id,
    },
  });

  // SCENE ELEMENT (non dialogue)
  const sceneElement = await prisma.sceneElements.create({
    data: {
      type: "ACTION",
      content:
        "Jean ouvre la fenêtre et observe la ville qui se réveille.",
      position: 1,
      Scen_contains_id: scene.id,
    },
  });

  console.log({
    userId: user.id,
    projectId: project.id,
    scriptId: script.id,
    sceneId: scene.id,
    sceneElementId: sceneElement.id,
  });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
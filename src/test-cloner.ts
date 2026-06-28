// src/test-cloner.ts
import { ScriptCloner } from './patterns/prototype/ScriptCloner'
import { prisma } from './lib/prisma'

async function main() {
  const cloner = new ScriptCloner(1)
  const { newScriptId } = await cloner.clone()

  const original = await prisma.scripts.findUnique({
    where: { id: 1 }, include: { Acts: { include: { Scenes: true } } }
  })
  const copy = await prisma.scripts.findUnique({
    where: { id: newScriptId }, include: { Acts: { include: { Scenes: true } } }
  })

  console.log('Original Acts:', original?.Acts.length)
  console.log('Copie Acts:', copy?.Acts.length)
  console.log('Titres identiques en structure mais titre différent:', original?.title, '/', copy?.title)
}
main().finally(() => prisma.$disconnect())
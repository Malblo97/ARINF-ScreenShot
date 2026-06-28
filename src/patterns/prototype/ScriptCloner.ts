// Ajoute dans ScriptCloner.ts
import { Cloneable } from './Cloneable'
import { prisma } from '../../lib/prisma'

export class ScriptCloner implements Cloneable<{ newScriptId: number }> {
  constructor(private sourceScriptId: number) {}
  async readFullScript(scriptId: number) {
    return prisma.scripts.findUnique({
      where: { id: scriptId },
      include: {
        Acts: {
          include: {
            Scenes: {
              include: {
                SceneElements: {
                  where: { Scen_parent_id: null }, // racines seulement
                  include: { children: true },
                  orderBy: { position: 'asc' }
                }
              },
              orderBy: { position: 'asc' }
            }
          },
          orderBy: { position: 'asc' }
        }
      }
    })
  }

  async clone(): Promise<{ newScriptId: number }> {
    const source = await this.readFullScript(this.sourceScriptId)
    if (!source) throw new Error('Script source introuvable')

    return prisma.$transaction(async (tx) => {
      const newScript = await tx.scripts.create({
        data: {
          title: `${source.title} (copie)`,
          variant: source.variant,
          version: 1,
          Proj_contains_id: source.Proj_contains_id
        }
      })

      for (const act of source.Acts) {
        const newAct = await tx.acts.create({
          data: {
            title: act.title,
            position: act.position,
            status: 'draft',  // une copie redémarre en brouillon
            Scri_contains_id: newScript.id
          }
        })

        for (const scene of act.Scenes) {
          const newScene = await tx.scenes.create({
            data: {
              title: scene.title,
              interiorExterior: scene.interiorExterior,
              location: scene.location,
              timeOfDay: scene.timeOfDay,
              position: scene.position,
              status: 'draft',
              Act_contains_id: newAct.id
            }
          })

          // Map temporaire ancien_id -> nouvel_id pour les parent_id de dialog_line
          const idMap = new Map<number, number>()

          for (const element of scene.SceneElements) {
            const newElement = await tx.sceneElements.create({
              data: {
                type: element.type,
                content: element.content,
                position: element.position,
                Char_speaks_id: element.Char_speaks_id,
                Scen_contains_id: newScene.id
              }
            })
            idMap.set(element.id, newElement.id)

            // Recréer les enfants (dialog_line) avec le bon nouveau parent_id
            for (const child of element.children) {
              await tx.sceneElements.create({
                data: {
                  type: child.type,
                  content: child.content,
                  position: child.position,
                  Scen_contains_id: newScene.id,
                  Scen_parent_id: newElement.id
                }
              })
            }
          }
        }
      }

      return { newScriptId: newScript.id }
    })
  }
}
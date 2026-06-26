import { prisma } from '../../lib/prisma'

export class ScriptCloner {
  async readFullScript(scriptId: number) {
    return prisma.scripts.findUnique({
      where: { id: scriptId },
      include: {
        Acts: {
          include: {
            Scenes: {
              include: {
                SceneElements: {
                  where: { Scen_parent_id: null },  // racines seulement
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
}
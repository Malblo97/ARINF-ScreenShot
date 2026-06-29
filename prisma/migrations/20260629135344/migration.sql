/*
  Warnings:

  - A unique constraint covering the columns `[Scen_contains_id,type,position]` on the table `SceneElements` will be added. If there are existing duplicate values, this will fail.

*/
-- DropIndex
DROP INDEX "SceneElements_Scen_contains_id_position_key";

-- CreateIndex
CREATE UNIQUE INDEX "SceneElements_Scen_contains_id_type_position_key" ON "SceneElements"("Scen_contains_id", "type", "position");

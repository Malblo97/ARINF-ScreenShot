-- DropIndex
DROP INDEX "SceneElements_Scen_contains_id_type_position_key";

-- CreateIndex
CREATE INDEX "SceneElements_Scen_contains_id_position_idx" ON "SceneElements"("Scen_contains_id", "position");

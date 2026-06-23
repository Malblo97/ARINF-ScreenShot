-- CreateTable
CREATE TABLE "SceneElements" (
    "id" SERIAL NOT NULL,
    "type" TEXT NOT NULL,
    "content" TEXT,
    "position" INTEGER NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "deletedAt" TIMESTAMP(3),
    "Scen_contains_id" INTEGER NOT NULL,
    "Scen_parent_id" INTEGER,
    "Char_speaks_id" INTEGER,

    CONSTRAINT "SceneElements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SceneElementSnapshots" (
    "id" SERIAL NOT NULL,
    "version" INTEGER NOT NULL,
    "content" TEXT,
    "changeType" TEXT NOT NULL,
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ScElem_snapshot_id" INTEGER NOT NULL,
    "UsAcc_author_id" INTEGER NOT NULL,

    CONSTRAINT "SceneElementSnapshots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ElementOperations" (
    "id" SERIAL NOT NULL,
    "opType" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "clock" INTEGER NOT NULL,
    "applied" BOOLEAN NOT NULL DEFAULT false,
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ScElem_operation_id" INTEGER NOT NULL,
    "UsAcc_author_id" INTEGER NOT NULL,

    CONSTRAINT "ElementOperations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SceneComponents" (
    "id" SERIAL NOT NULL,
    "type" TEXT NOT NULL,
    "label" TEXT NOT NULL,
    "data" JSONB NOT NULL,
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "Proj_contains_id" INTEGER NOT NULL,

    CONSTRAINT "SceneComponents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ComponentAttachments" (
    "deptId" SERIAL NOT NULL,
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ScComp_attaches_id" INTEGER NOT NULL,
    "Scen_target_id" INTEGER,
    "ScElem_target_id" INTEGER,

    CONSTRAINT "ComponentAttachments_pkey" PRIMARY KEY ("ScComp_attaches_id","deptId")
);

-- CreateTable
CREATE TABLE "Validations" (
    "id" SERIAL NOT NULL,
    "status" TEXT NOT NULL,
    "comment" TEXT,
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ProjUs_validates_id" INTEGER NOT NULL,
    "Scen_target_id" INTEGER,
    "Act_target_id" INTEGER,
    "Scri_target_id" INTEGER,
    "Sequ_target_id" INTEGER,

    CONSTRAINT "Validations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Comments" (
    "id" SERIAL NOT NULL,
    "content" TEXT NOT NULL,
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deletedAt" TIMESTAMP(3),
    "ProjUs_posts_id" INTEGER NOT NULL,
    "Scen_target_id" INTEGER,
    "ScElem_target_id" INTEGER,
    "DocVers_target_id" INTEGER,
    "DocVers_target_deptId" INTEGER,
    "Comm_parent_id" INTEGER,

    CONSTRAINT "Comments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Notes" (
    "id" SERIAL NOT NULL,
    "content" TEXT NOT NULL,
    "isPrivate" BOOLEAN NOT NULL DEFAULT true,
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ProjUs_creates_id" INTEGER NOT NULL,
    "Scen_target_id" INTEGER,
    "ScElem_target_id" INTEGER,

    CONSTRAINT "Notes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Sequencers" (
    "id" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'storyboard',
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "Proj_contains_id" INTEGER NOT NULL,

    CONSTRAINT "Sequencers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SequencerItems" (
    "deptId" SERIAL NOT NULL,
    "position" INTEGER NOT NULL,
    "durationSec" INTEGER,
    "color" TEXT,
    "thumbnailUrl" TEXT,
    "notes" TEXT,
    "Sequ_contains_id" INTEGER NOT NULL,
    "Scen_ref_id" INTEGER,

    CONSTRAINT "SequencerItems_pkey" PRIMARY KEY ("Sequ_contains_id","deptId")
);

-- CreateTable
CREATE TABLE "Documents" (
    "id" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "Proj_contains_id" INTEGER NOT NULL,

    CONSTRAINT "Documents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DocumentVersions" (
    "deptId" SERIAL NOT NULL,
    "versionNumber" INTEGER NOT NULL,
    "content" TEXT,
    "source" TEXT NOT NULL DEFAULT 'manual',
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "Doc_version_id" INTEGER NOT NULL,
    "UsAcc_creates_id" INTEGER,

    CONSTRAINT "DocumentVersions_pkey" PRIMARY KEY ("Doc_version_id","deptId")
);

-- CreateTable
CREATE TABLE "Files" (
    "id" SERIAL NOT NULL,
    "filename" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "storageUrl" TEXT NOT NULL,
    "sizeBytes" INTEGER NOT NULL,
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "DocVers_contains_id" INTEGER,
    "DocVers_contains_deptId" INTEGER,
    "Proj_belongs_id" INTEGER NOT NULL,

    CONSTRAINT "Files_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AiJobs" (
    "id" SERIAL NOT NULL,
    "action" TEXT NOT NULL,
    "entityType" TEXT,
    "entityId" INTEGER,
    "inputContext" JSONB,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "errorMessage" TEXT,
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),
    "Proj_launches_id" INTEGER NOT NULL,
    "UsAcc_asks_id" INTEGER NOT NULL,
    "Doc_produces_id" INTEGER,
    "DocVers_produces_deptId" INTEGER,

    CONSTRAINT "AiJobs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Notifications" (
    "id" SERIAL NOT NULL,
    "type" TEXT NOT NULL,
    "payload" JSONB,
    "read" BOOLEAN NOT NULL DEFAULT false,
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UsAcc_receives_id" INTEGER NOT NULL,

    CONSTRAINT "Notifications_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "SceneElements_Scen_contains_id_position_key" ON "SceneElements"("Scen_contains_id", "position");

-- CreateIndex
CREATE UNIQUE INDEX "SceneElementSnapshots_ScElem_snapshot_id_version_key" ON "SceneElementSnapshots"("ScElem_snapshot_id", "version");

-- CreateIndex
CREATE UNIQUE INDEX "SequencerItems_Sequ_contains_id_position_key" ON "SequencerItems"("Sequ_contains_id", "position");

-- CreateIndex
CREATE UNIQUE INDEX "DocumentVersions_Doc_version_id_versionNumber_key" ON "DocumentVersions"("Doc_version_id", "versionNumber");

-- CreateIndex
CREATE INDEX "Notifications_UsAcc_receives_id_read_idx" ON "Notifications"("UsAcc_receives_id", "read");

-- AddForeignKey
ALTER TABLE "SceneElements" ADD CONSTRAINT "SceneElements_Scen_contains_id_fkey" FOREIGN KEY ("Scen_contains_id") REFERENCES "Scenes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SceneElements" ADD CONSTRAINT "SceneElements_Scen_parent_id_fkey" FOREIGN KEY ("Scen_parent_id") REFERENCES "SceneElements"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SceneElements" ADD CONSTRAINT "SceneElements_Char_speaks_id_fkey" FOREIGN KEY ("Char_speaks_id") REFERENCES "Characters"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SceneElementSnapshots" ADD CONSTRAINT "SceneElementSnapshots_ScElem_snapshot_id_fkey" FOREIGN KEY ("ScElem_snapshot_id") REFERENCES "SceneElements"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SceneElementSnapshots" ADD CONSTRAINT "SceneElementSnapshots_UsAcc_author_id_fkey" FOREIGN KEY ("UsAcc_author_id") REFERENCES "UserAccounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ElementOperations" ADD CONSTRAINT "ElementOperations_ScElem_operation_id_fkey" FOREIGN KEY ("ScElem_operation_id") REFERENCES "SceneElements"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ElementOperations" ADD CONSTRAINT "ElementOperations_UsAcc_author_id_fkey" FOREIGN KEY ("UsAcc_author_id") REFERENCES "UserAccounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SceneComponents" ADD CONSTRAINT "SceneComponents_Proj_contains_id_fkey" FOREIGN KEY ("Proj_contains_id") REFERENCES "Projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ComponentAttachments" ADD CONSTRAINT "ComponentAttachments_ScComp_attaches_id_fkey" FOREIGN KEY ("ScComp_attaches_id") REFERENCES "SceneComponents"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ComponentAttachments" ADD CONSTRAINT "ComponentAttachments_Scen_target_id_fkey" FOREIGN KEY ("Scen_target_id") REFERENCES "Scenes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ComponentAttachments" ADD CONSTRAINT "ComponentAttachments_ScElem_target_id_fkey" FOREIGN KEY ("ScElem_target_id") REFERENCES "SceneElements"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Validations" ADD CONSTRAINT "Validations_ProjUs_validates_id_fkey" FOREIGN KEY ("ProjUs_validates_id") REFERENCES "ProjectUsers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Validations" ADD CONSTRAINT "Validations_Scen_target_id_fkey" FOREIGN KEY ("Scen_target_id") REFERENCES "Scenes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Validations" ADD CONSTRAINT "Validations_Act_target_id_fkey" FOREIGN KEY ("Act_target_id") REFERENCES "Acts"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Validations" ADD CONSTRAINT "Validations_Scri_target_id_fkey" FOREIGN KEY ("Scri_target_id") REFERENCES "Scripts"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Validations" ADD CONSTRAINT "Validations_Sequ_target_id_fkey" FOREIGN KEY ("Sequ_target_id") REFERENCES "Sequencers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Comments" ADD CONSTRAINT "Comments_ProjUs_posts_id_fkey" FOREIGN KEY ("ProjUs_posts_id") REFERENCES "ProjectUsers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Comments" ADD CONSTRAINT "Comments_Scen_target_id_fkey" FOREIGN KEY ("Scen_target_id") REFERENCES "Scenes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Comments" ADD CONSTRAINT "Comments_ScElem_target_id_fkey" FOREIGN KEY ("ScElem_target_id") REFERENCES "SceneElements"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Comments" ADD CONSTRAINT "Comments_DocVers_target_id_DocVers_target_deptId_fkey" FOREIGN KEY ("DocVers_target_id", "DocVers_target_deptId") REFERENCES "DocumentVersions"("Doc_version_id", "deptId") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Comments" ADD CONSTRAINT "Comments_Comm_parent_id_fkey" FOREIGN KEY ("Comm_parent_id") REFERENCES "Comments"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Notes" ADD CONSTRAINT "Notes_ProjUs_creates_id_fkey" FOREIGN KEY ("ProjUs_creates_id") REFERENCES "ProjectUsers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Notes" ADD CONSTRAINT "Notes_Scen_target_id_fkey" FOREIGN KEY ("Scen_target_id") REFERENCES "Scenes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Notes" ADD CONSTRAINT "Notes_ScElem_target_id_fkey" FOREIGN KEY ("ScElem_target_id") REFERENCES "SceneElements"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Sequencers" ADD CONSTRAINT "Sequencers_Proj_contains_id_fkey" FOREIGN KEY ("Proj_contains_id") REFERENCES "Projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SequencerItems" ADD CONSTRAINT "SequencerItems_Sequ_contains_id_fkey" FOREIGN KEY ("Sequ_contains_id") REFERENCES "Sequencers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SequencerItems" ADD CONSTRAINT "SequencerItems_Scen_ref_id_fkey" FOREIGN KEY ("Scen_ref_id") REFERENCES "Scenes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Documents" ADD CONSTRAINT "Documents_Proj_contains_id_fkey" FOREIGN KEY ("Proj_contains_id") REFERENCES "Projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DocumentVersions" ADD CONSTRAINT "DocumentVersions_Doc_version_id_fkey" FOREIGN KEY ("Doc_version_id") REFERENCES "Documents"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DocumentVersions" ADD CONSTRAINT "DocumentVersions_UsAcc_creates_id_fkey" FOREIGN KEY ("UsAcc_creates_id") REFERENCES "UserAccounts"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Files" ADD CONSTRAINT "Files_DocVers_contains_id_DocVers_contains_deptId_fkey" FOREIGN KEY ("DocVers_contains_id", "DocVers_contains_deptId") REFERENCES "DocumentVersions"("Doc_version_id", "deptId") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Files" ADD CONSTRAINT "Files_Proj_belongs_id_fkey" FOREIGN KEY ("Proj_belongs_id") REFERENCES "Projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AiJobs" ADD CONSTRAINT "AiJobs_Proj_launches_id_fkey" FOREIGN KEY ("Proj_launches_id") REFERENCES "Projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AiJobs" ADD CONSTRAINT "AiJobs_UsAcc_asks_id_fkey" FOREIGN KEY ("UsAcc_asks_id") REFERENCES "UserAccounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AiJobs" ADD CONSTRAINT "AiJobs_Doc_produces_id_DocVers_produces_deptId_fkey" FOREIGN KEY ("Doc_produces_id", "DocVers_produces_deptId") REFERENCES "DocumentVersions"("Doc_version_id", "deptId") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Notifications" ADD CONSTRAINT "Notifications_UsAcc_receives_id_fkey" FOREIGN KEY ("UsAcc_receives_id") REFERENCES "UserAccounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

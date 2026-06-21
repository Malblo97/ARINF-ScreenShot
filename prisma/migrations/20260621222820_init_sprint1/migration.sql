-- CreateTable
CREATE TABLE "UserAccounts" (
    "id" SERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "displayName" TEXT NOT NULL,
    "avatarUrl" TEXT,
    "ajUsername" TEXT,
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "moUser" TEXT,
    "moDate" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "UserAccounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuthSessions" (
    "id" SERIAL NOT NULL,
    "token" TEXT NOT NULL,
    "deviceInfo" TEXT,
    "ipAddress" TEXT,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UsAcc_owns_id" INTEGER NOT NULL,

    CONSTRAINT "AuthSessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Roles" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "permissions" JSONB,

    CONSTRAINT "Roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Projects" (
    "id" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "status" TEXT NOT NULL DEFAULT 'draft',
    "ajUser" TEXT,
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "moUser" TEXT,
    "moDate" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),
    "UsAcc_owner_id" INTEGER NOT NULL,

    CONSTRAINT "Projects_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProjectUsers" (
    "id" SERIAL NOT NULL,
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "Proj_contains_id" INTEGER NOT NULL,
    "UsAcc_member_id" INTEGER NOT NULL,
    "Rol_defines_id" INTEGER NOT NULL,

    CONSTRAINT "ProjectUsers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PermissionOverrides" (
    "id" SERIAL NOT NULL,
    "entityType" TEXT NOT NULL,
    "entityId" INTEGER NOT NULL,
    "permission" TEXT NOT NULL,
    "granted" BOOLEAN NOT NULL DEFAULT true,
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ProUs_detailed_id" INTEGER NOT NULL,

    CONSTRAINT "PermissionOverrides_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Invitations" (
    "id" SERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "statuts" TEXT NOT NULL DEFAULT 'pending',
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "Proj_sends_id" INTEGER NOT NULL,
    "UsAcc_invites_id" INTEGER NOT NULL,
    "Rol_assigned_id" INTEGER NOT NULL,

    CONSTRAINT "Invitations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProjectStatusHistories" (
    "id" SERIAL NOT NULL,
    "fromStatus" TEXT,
    "toStatus" TEXT NOT NULL,
    "reason" TEXT,
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "Proj_historical_id" INTEGER NOT NULL,
    "UsAcc_changes_id" INTEGER NOT NULL,

    CONSTRAINT "ProjectStatusHistories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Scripts" (
    "id" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "variant" TEXT NOT NULL DEFAULT 'main',
    "version" INTEGER NOT NULL DEFAULT 1,
    "ajDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deletedAt" TIMESTAMP(3),
    "Proj_contains_id" INTEGER NOT NULL,

    CONSTRAINT "Scripts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Acts" (
    "id" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "position" INTEGER NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'draft',
    "deletedAt" TIMESTAMP(3),
    "Scri_contains_id" INTEGER NOT NULL,

    CONSTRAINT "Acts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Scenes" (
    "id" SERIAL NOT NULL,
    "title" TEXT,
    "interiorExterior" TEXT,
    "location" TEXT NOT NULL,
    "timeOfDay" TEXT,
    "position" INTEGER NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "status" TEXT NOT NULL DEFAULT 'draft',
    "estimatedPageCount" INTEGER,
    "deletedAt" TIMESTAMP(3),
    "Act_contains_id" INTEGER NOT NULL,

    CONSTRAINT "Scenes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Characters" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "arc" TEXT,
    "deletedAt" TIMESTAMP(3),
    "Proj_contains_id" INTEGER NOT NULL,

    CONSTRAINT "Characters_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "UserAccounts_email_key" ON "UserAccounts"("email");

-- CreateIndex
CREATE UNIQUE INDEX "AuthSessions_token_key" ON "AuthSessions"("token");

-- CreateIndex
CREATE UNIQUE INDEX "Roles_name_key" ON "Roles"("name");

-- CreateIndex
CREATE UNIQUE INDEX "ProjectUsers_Proj_contains_id_UsAcc_member_id_key" ON "ProjectUsers"("Proj_contains_id", "UsAcc_member_id");

-- CreateIndex
CREATE UNIQUE INDEX "PermissionOverrides_ProUs_detailed_id_entityType_entityId_p_key" ON "PermissionOverrides"("ProUs_detailed_id", "entityType", "entityId", "permission");

-- CreateIndex
CREATE UNIQUE INDEX "Invitations_token_key" ON "Invitations"("token");

-- CreateIndex
CREATE UNIQUE INDEX "Scripts_Proj_contains_id_title_variant_key" ON "Scripts"("Proj_contains_id", "title", "variant");

-- CreateIndex
CREATE UNIQUE INDEX "Acts_Scri_contains_id_position_key" ON "Acts"("Scri_contains_id", "position");

-- CreateIndex
CREATE UNIQUE INDEX "Scenes_Act_contains_id_position_key" ON "Scenes"("Act_contains_id", "position");

-- CreateIndex
CREATE UNIQUE INDEX "Characters_Proj_contains_id_name_key" ON "Characters"("Proj_contains_id", "name");

-- AddForeignKey
ALTER TABLE "AuthSessions" ADD CONSTRAINT "AuthSessions_UsAcc_owns_id_fkey" FOREIGN KEY ("UsAcc_owns_id") REFERENCES "UserAccounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Projects" ADD CONSTRAINT "Projects_UsAcc_owner_id_fkey" FOREIGN KEY ("UsAcc_owner_id") REFERENCES "UserAccounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProjectUsers" ADD CONSTRAINT "ProjectUsers_Proj_contains_id_fkey" FOREIGN KEY ("Proj_contains_id") REFERENCES "Projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProjectUsers" ADD CONSTRAINT "ProjectUsers_UsAcc_member_id_fkey" FOREIGN KEY ("UsAcc_member_id") REFERENCES "UserAccounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProjectUsers" ADD CONSTRAINT "ProjectUsers_Rol_defines_id_fkey" FOREIGN KEY ("Rol_defines_id") REFERENCES "Roles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PermissionOverrides" ADD CONSTRAINT "PermissionOverrides_ProUs_detailed_id_fkey" FOREIGN KEY ("ProUs_detailed_id") REFERENCES "ProjectUsers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invitations" ADD CONSTRAINT "Invitations_Proj_sends_id_fkey" FOREIGN KEY ("Proj_sends_id") REFERENCES "Projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invitations" ADD CONSTRAINT "Invitations_UsAcc_invites_id_fkey" FOREIGN KEY ("UsAcc_invites_id") REFERENCES "UserAccounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invitations" ADD CONSTRAINT "Invitations_Rol_assigned_id_fkey" FOREIGN KEY ("Rol_assigned_id") REFERENCES "Roles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProjectStatusHistories" ADD CONSTRAINT "ProjectStatusHistories_Proj_historical_id_fkey" FOREIGN KEY ("Proj_historical_id") REFERENCES "Projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProjectStatusHistories" ADD CONSTRAINT "ProjectStatusHistories_UsAcc_changes_id_fkey" FOREIGN KEY ("UsAcc_changes_id") REFERENCES "UserAccounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Scripts" ADD CONSTRAINT "Scripts_Proj_contains_id_fkey" FOREIGN KEY ("Proj_contains_id") REFERENCES "Projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Acts" ADD CONSTRAINT "Acts_Scri_contains_id_fkey" FOREIGN KEY ("Scri_contains_id") REFERENCES "Scripts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Scenes" ADD CONSTRAINT "Scenes_Act_contains_id_fkey" FOREIGN KEY ("Act_contains_id") REFERENCES "Acts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Characters" ADD CONSTRAINT "Characters_Proj_contains_id_fkey" FOREIGN KEY ("Proj_contains_id") REFERENCES "Projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

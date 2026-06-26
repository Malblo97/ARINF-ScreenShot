ALTER TABLE "ComponentAttachments"
ADD CONSTRAINT "CHK_CompAtt_xor" CHECK (
  ("Scen_target_id" IS NOT NULL)::int +
  ("ScElem_target_id" IS NOT NULL)::int = 1
);

ALTER TABLE "Validations"
ADD CONSTRAINT "CHK_Valid_target_exactOne" CHECK (
  ("Scen_target_id" IS NOT NULL)::int +
  ("Act_target_id" IS NOT NULL)::int +
  ("Scri_target_id" IS NOT NULL)::int +
  ("Sequ_target_id" IS NOT NULL)::int = 1
);

ALTER TABLE "Comments"
ADD CONSTRAINT "CHK_Comm_target_exactOne" CHECK (
  ("Scen_target_id" IS NOT NULL)::int +
  ("ScElem_target_id" IS NOT NULL)::int +
  ("DocVers_target_id" IS NOT NULL)::int = 1
);

ALTER TABLE "Notes"
ADD CONSTRAINT "CHK_Note_target_exactOne" CHECK (
  ("Scen_target_id" IS NOT NULL)::int +
  ("ScElem_target_id" IS NOT NULL)::int = 1
);
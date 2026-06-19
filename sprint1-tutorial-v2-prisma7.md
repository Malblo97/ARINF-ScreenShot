# 🏃 Sprint 1 — Tutoriel complet (v2 — Windows + Prisma 7)

> ⚠️ **Coquille détectée :** ton projet s'appelle `screenshot-saas` et ta DB `screenshot_dev` au lieu de `screenplay-`. Je garde tes noms réels tels quels dans ce tutoriel — renomme-les toi-même si c'était une faute de frappe involontaire, sinon ignore cette note.

> Ce tutoriel remplace entièrement la version précédente. Deux choses ont changé depuis : **tu es sur Windows/PowerShell** (pas Mac/Linux), et **tu utilises Prisma 7** (architecture driver-adapter, pas l'ancienne version avec `url` direct dans `schema.prisma`).

---

## 🎯 Sprint Goal (inchangé)
> L'environnement est 100% opérationnel, 12 tables PostgreSQL existent en base via Prisma 7 avec adapter, le patron Singleton est implémenté et documenté en UML.

**Vélocité cible : 23 points**

---

## ⚠️ Ce qui est différent de la doc Prisma "classique"

| Élément | Avant (Prisma 5/6) | Maintenant (Prisma 7 — ta version réelle) |
|---|---|---|
| URL de connexion | Dans `schema.prisma`, bloc `datasource` | Dans un nouveau fichier `prisma.config.ts` à la racine |
| Génération du client | `provider = "prisma-client-js"` | `provider = "prisma-client"` + `output` obligatoire |
| Import du client | `from '@prisma/client'` | `from '../generated/prisma/client'` (chemin relatif à `output`) |
| Connexion BDD | `new PrismaClient()` seul fonctionne | Nécessite un **driver adapter** obligatoire (`@prisma/adapter-pg`) |
| Mot de passe avec caractères spéciaux | Pas géré particulièrement | Doit être **URL-encodé** (`%` → `%25`, etc.) |

---

## ✅ Definition of Done — Sprint 1

- [ ] `npx tsc --noEmit` sans erreur
- [ ] `npx prisma migrate dev` s'exécute sans erreur
- [ ] 12 tables visibles dans pgAdmin et Prisma Studio
- [ ] `src/lib/prisma.ts` exporte un Singleton fonctionnel avec adapter
- [ ] Double import de `prisma` retourne la même instance
- [ ] `uml/singleton.uxf` ouvert et lisible dans UMLet
- [ ] `.env` absent du repo Git
- [ ] Commit tagué `sprint-1-done`

---

## JOUR 1 — Setup complet + Singleton (9 pts)

### 🧠 Apprendre (20 min) avant de toucher au code

TypeScript Handbook, section *Basic Types*. Comprendre pourquoi TS existe par-dessus JS et ce que fait `strict: true`.
→ typescriptlang.org/docs/handbook/2/basic-types.html

---

### ⚙️ T-01 — Init projet Node.js + TypeScript (US-01, 30 min)

```powershell
mkdir screenshot-saas
cd screenshot-saas
npm init -y
npm install typescript ts-node @types/node eslint prettier --save-dev
npx tsc --init
```

Remplace `tsconfig.json` par :
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*", "prisma/**/*", "prisma.config.ts"],
  "exclude": ["node_modules", "dist"]
}
```

```powershell
mkdir src
echo "console.log('Screenshot SaaS — OK')" > src/index.ts
npx ts-node src/index.ts
```

✅ Le message s'affiche → continue.

---

### ⚙️ T-01b — Git + scripts npm (30 min)

```powershell
git init
"node_modules/`ndist/`n.env" | Out-File -Encoding utf8 .gitignore
```

> 💡 Sous PowerShell, `echo "a\nb" > file` n'interprète pas `\n` comme un retour à la ligne — utilise la syntaxe `` `n `` (backtick + n) comme ci-dessus, ou ouvre `.gitignore` directement dans ton éditeur et tape :
> ```
> node_modules/
> dist/
> .env
> ```

Ajoute dans `package.json` :
```json
"scripts": {
  "dev": "ts-node src/index.ts",
  "build": "tsc",
  "db:migrate": "prisma migrate dev",
  "db:studio": "prisma studio",
  "db:seed": "ts-node prisma/seed.ts"
}
```

```powershell
git add .
git commit -m "init projet TS"
```

---

### 🧠 Apprendre (15 min) — SGBD vs base de données

PostgreSQL = le serveur. `screenshot_dev` = un conteneur logique dedans. Tu peux avoir plusieurs bases dans un seul PostgreSQL installé.

---

### ⚙️ T-02 — PostgreSQL local + DB (US-02, 50 min)

**Windows :** télécharge l'installeur sur postgresql.org/download/windows. Retiens **précisément** le mot de passe que tu choisis pour l'utilisateur `postgres` — c'est lui qui va te servir dans `.env` juste après.

```powershell
# Si psql n'est pas reconnu dans PowerShell, cherche "SQL Shell (psql)" 
# dans le menu Démarrer — il est installé avec PostgreSQL
psql -U postgres
```

Dans le prompt `psql` :
```sql
CREATE DATABASE screenshot_dev;
\l
\q
```

---

### ⚠️ T-02b — Si ton mot de passe contient un caractère spécial (`%`, `@`, `#`...)

**C'est ton cas réel** — ton mot de passe contient un `%`. Les caractères spéciaux doivent être **encodés en URL** dans `DATABASE_URL`, sinon Prisma ne parse pas correctement le username/password et renvoie une erreur d'authentification avec `(not available)`.

Génère la version encodée directement avec Node :
```powershell
node -e "console.log(encodeURIComponent('TonMotDePasseAvecLePourcent'))"
```

Ça t'affiche la version à copier-coller. Table de référence si tu veux encoder à la main :

| Caractère | Encodage |
|---|---|
| `%` | `%25` |
| `@` | `%40` |
| `#` | `%23` |
| `/` | `%2F` |
| `:` | `%3A` |

**Alternative plus simple, recommandée pour un projet académique local :** change le mot de passe pour qu'il ne contienne que lettres et chiffres — ça t'évite ce piège pour tout le reste du projet.
```sql
ALTER USER postgres PASSWORD 'MotDePasseSansCaracteresSpeciaux123';
```

---

### ⚙️ T-02c — Créer `.env`

À la racine du projet, crée `.env` (avec ton mot de passe **encodé** si tu gardes le `%`, ou en clair si tu l'as changé) :

```env
DATABASE_URL="postgresql://postgres:MotDePasseEncode@localhost:5432/screenshot_dev"
```

Vérifie qu'il n'apparaît pas dans Git :
```powershell
git status
```

---

### 🧠 Apprendre (15 min) — Ce qu'est un ORM

Prisma traduit `schema.prisma` (pas du SQL) en requêtes PostgreSQL réelles via un client TypeScript généré.

---

### ⚙️ T-03 — Installer Prisma 7 + configurer (US-03, 40 min)

```powershell
npm install prisma --save-dev
npm install dotenv @prisma/adapter-pg
npx prisma init
```

**Remplace le contenu de `prisma/schema.prisma`** par :
```prisma
generator client {
  provider = "prisma-client"
  output   = "../src/generated/prisma"
}

datasource db {
  provider = "postgresql"
}
```

> ⚠️ **Différence clé avec l'ancienne doc :** pas de `url = env("DATABASE_URL")` ici — Prisma 7 l'interdit explicitement dans le schema. L'URL va dans `prisma.config.ts` à la place.

**Crée `prisma.config.ts` à la racine du projet** (même niveau que `package.json`) :
```typescript
import 'dotenv/config'
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
  },
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

**Teste la connexion :**
```powershell
npx prisma db pull
```
✅ Tu dois voir : `Introspecting based on datasource... The introspected database was empty` — c'est exactement le résultat attendu (base vide, connexion réussie).

```powershell
npx prisma validate
```

---

### 🧠 Apprendre (45 min) — Le patron Singleton en détail

refactoring.guru/fr/design-patterns/singleton + l'exemple TypeScript. Comprendre : quel problème il résout, pourquoi le constructeur est privé, ce qu'est un membre statique, comment ça se note en UML.

---

### ⚙️ T-13 — Implémenter le Singleton avec adapter Prisma 7 (US-13, 1h15)

```powershell
mkdir src\lib
```

**Crée `src/lib/prisma.ts` :**
```typescript
import 'dotenv/config'
import { PrismaClient } from '../generated/prisma/client'
import { PrismaPg } from '@prisma/adapter-pg'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL! })

export const prisma: PrismaClient =
  globalForPrisma.prisma ?? new PrismaClient({ adapter })

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}

export default prisma
```

> ⚠️ **Le chemin d'import dépend exactement de ton `output`** dans `schema.prisma`. Si tu as `output = "../src/generated/prisma"`, alors depuis `src/lib/prisma.ts` le chemin correct est `'../generated/prisma/client'` (une seule remontée, puisque `lib/` et `generated/` sont tous les deux dans `src/`).
>
> Vérifie après chaque `npx prisma generate` la ligne de sortie du terminal — elle te dit l'emplacement réel :
> ```
> ✔ Generated Prisma Client (7.x.x) to .\src\generated\prisma in 27ms
> ```

**Modifie `src/index.ts` pour tester :**
```typescript
import { prisma } from './lib/prisma'

async function main() {
  await prisma.$connect()
  console.log('Connexion Prisma OK')
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
```

```powershell
npx ts-node src/index.ts
```
✅ `Connexion Prisma OK` s'affiche sans erreur TypeScript.

**Test du Singleton — double import retourne la même instance :**

Crée `src/test-singleton.ts` :
```typescript
import { prisma as prismaA } from './lib/prisma'
import { prisma as prismaB } from './lib/prisma'

console.log('Même instance ?', prismaA === prismaB)  // doit afficher true
```
```powershell
npx ts-node src/test-singleton.ts
```

---

### ⚙️ T-13b — UML Singleton dans Umletino (45 min)

```powershell
mkdir uml
```

Va sur **umletino.com**. Crée une classe avec ce panel attributes :
```
PrismaClientSingleton
--
-_instance_: PrismaClient
-adapter: PrismaPg
--
-PrismaClientSingleton()
+_getInstance()_: PrismaClient
+disconnect(): void
```

Ajoute une UMLNote :
```
Patron : Singleton

Garantit qu'une seule
instance de PrismaClient
existe dans toute l'app.

Évite les connexions
PostgreSQL orphelines
en mode hot-reload.

Adapté à Prisma 7 :
l'adapter PrismaPg est
créé une seule fois et
réutilisé par l'instance.
```

Exporte : **File → Export as UXF** → `uml/singleton.uxf`

```powershell
git add .
git commit -m "feat: Singleton PrismaClient avec adapter Prisma 7 + UML"
```

**Fin Jour 1 : 9 pts (US-01, US-02, US-03, US-13)**

---

## JOUR 2 — BDD Bloc 1 Auth + Projet (8 pts)

### 🧠 Apprendre (30 min) — Modèles et relations Prisma

prisma.io/docs → Data model → Models, puis → Relations (one-to-many). Chaque relation se déclare des **deux côtés**.

---

### ⚙️ T-06 — UserAccounts + Roles + AuthSessions (US-06, 1h)

Dans `prisma/schema.prisma`, **après** le bloc `datasource`, ajoute :

```prisma
model UserAccounts {
  id            Int       @id @default(autoincrement())
  email         String    @unique
  passwordHash  String
  displayName   String
  avatarUrl     String?
  ajDate        DateTime  @default(now())
  moDate        DateTime  @updatedAt
  deletedAt     DateTime?

  AuthSessions  AuthSessions[]
  Projects      Projects[]
  ProjectUsers  ProjectUsers[]
}

model AuthSessions {
  id          Int      @id @default(autoincrement())
  token       String   @unique
  deviceInfo  String?
  ipAddress   String?
  expiresAt   DateTime
  ajDate      DateTime @default(now())

  UsAcc_owns_id  Int
  UserAccounts   UserAccounts @relation(fields: [UsAcc_owns_id], references: [id])
}

model Roles {
  id          Int     @id @default(autoincrement())
  name        String  @unique
  permissions Json?

  ProjectUsers  ProjectUsers[]
  Invitations   Invitations[]
}
```

```powershell
npx prisma validate
```
Corrige les erreurs affichées (relations inverses manquantes le plus souvent).

---

### ⚙️ T-07 — Projects, ProjectUsers, PermissionOverrides, Invitations, ProjectStatusHistories (US-07, 2h)

```prisma
model Projects {
  id           Int       @id @default(autoincrement())
  title        String
  description  String?
  status       String    @default("draft")
  ajDate       DateTime  @default(now())
  moDate       DateTime  @updatedAt
  deletedAt    DateTime?

  UsAcc_owner_id  Int
  UserAccounts    UserAccounts @relation(fields: [UsAcc_owner_id], references: [id])

  ProjectUsers            ProjectUsers[]
  Invitations             Invitations[]
  ProjectStatusHistories  ProjectStatusHistories[]
  Scripts                 Scripts[]
}

model ProjectUsers {
  id      Int      @id @default(autoincrement())
  ajDate  DateTime @default(now())

  Proj_contains_id  Int
  UsAcc_member_id   Int
  Rol_defines_id    Int

  Projects      Projects      @relation(fields: [Proj_contains_id], references: [id])
  UserAccounts  UserAccounts  @relation(fields: [UsAcc_member_id], references: [id])
  Roles         Roles         @relation(fields: [Rol_defines_id], references: [id])

  PermissionOverrides  PermissionOverrides[]

  @@unique([Proj_contains_id, UsAcc_member_id])
}

model PermissionOverrides {
  id          Int      @id @default(autoincrement())
  entityType  String
  entityId    Int
  permission  String
  granted     Boolean  @default(true)
  ajDate      DateTime @default(now())

  ProUs_detailed_id  Int
  ProjectUsers       ProjectUsers @relation(fields: [ProUs_detailed_id], references: [id])

  @@unique([ProUs_detailed_id, entityType, entityId, permission])
}

model Invitations {
  id          Int      @id @default(autoincrement())
  email       String
  token       String   @unique
  statuts     String   @default("pending")
  expiresAt   DateTime

  Proj_sends_id     Int
  UsAcc_invites_id  Int
  Rol_assigned_id   Int

  Projects      Projects      @relation(fields: [Proj_sends_id], references: [id])
  UserAccounts  UserAccounts  @relation(fields: [UsAcc_invites_id], references: [id])
  Roles         Roles         @relation(fields: [Rol_assigned_id], references: [id])
}

model ProjectStatusHistories {
  id          Int      @id @default(autoincrement())
  fromStatus  String?
  toStatus    String
  reason      String?
  ajDate      DateTime @default(now())

  Proj_historical_id  Int
  UsAcc_changes_id    Int

  Projects      Projects      @relation(fields: [Proj_historical_id], references: [id])
  UserAccounts  UserAccounts  @relation(fields: [UsAcc_changes_id], references: [id])
}
```

> 💡 N'oublie pas d'ajouter `Invitations Invitations[]` et `ProjectStatusHistories ProjectStatusHistories[]` dans le modèle `UserAccounts` aussi (relations inverses), sinon `prisma validate` va te le signaler.

```powershell
npx prisma validate
git add .
git commit -m "feat: schema Bloc 1 complet"
```

**Fin Jour 2 : 8 pts supplémentaires → total 17 pts**

---

## JOUR 3 — BDD Bloc 2 + Migration (6 pts)

### 🧠 Apprendre (10 min) — `@relation` simple

Pas besoin de Composite IDs cette fois — `Acts` et `Scenes` ont une PK simple `id`. Juste une FK classique à comprendre.

---

### ⚙️ T-08 — Scripts, Acts, Scenes, Characters (US-08, 2h)

```prisma
model Scripts {
  id          Int       @id @default(autoincrement())
  title       String
  variant     String    @default("main")
  version     Int       @default(1)
  ajDate      DateTime  @default(now())
  deletedAt   DateTime?

  Proj_contains_id  Int
  Projects          Projects @relation(fields: [Proj_contains_id], references: [id])

  Acts  Acts[]

  @@unique([Proj_contains_id, title, variant])
}

model Acts {
  id        Int       @id @default(autoincrement())
  title     String
  position  Int
  status    String    @default("draft")
  deletedAt DateTime?

  Scri_contains_id  Int
  Scripts           Scripts @relation(fields: [Scri_contains_id], references: [id])

  Scenes  Scenes[]

  @@unique([Scri_contains_id, position])
}

model Scenes {
  id                  Int       @id @default(autoincrement())
  title               String?
  interiorExterior    String?
  location            String
  timeOfDay           String?
  position            Int
  version             Int       @default(1)
  status              String    @default("draft")
  estimatedPageCount  Int?
  deletedAt           DateTime?

  Act_contains_id  Int
  Acts             Acts @relation(fields: [Act_contains_id], references: [id])

  @@unique([Act_contains_id, position])
}

model Characters {
  id           Int       @id @default(autoincrement())
  name         String
  description  String?
  arc          String?
  deletedAt    DateTime?

  Proj_contains_id  Int
  Projects          Projects @relation(fields: [Proj_contains_id], references: [id])

  @@unique([Proj_contains_id, name])
}
```

> N'oublie pas `Characters Characters[]` dans `Projects`.

```powershell
npx prisma validate
```

---

### ⚙️ T-12 — Migration finale Sprint 1 (US-12-S1, 1h)

```powershell
npx prisma migrate dev --name init_sprint1
```

✅ Sortie attendue : `Your database is now in sync with your schema.`

**Vérifie dans psql :**
```powershell
psql -U postgres -d screenshot_dev
```
```sql
\dt
\q
```
Tu dois voir 12 tables + `_prisma_migrations`.

**Vérifie dans Prisma Studio :**
```powershell
npx prisma studio
```
→ s'ouvre sur `http://localhost:5555`, les 12 modèles apparaissent dans le panneau gauche.

**Test create/findMany — modifie `src/index.ts` :**
```typescript
import { prisma } from './lib/prisma'

async function main() {
  const user = await prisma.userAccounts.create({
    data: {
      email: 'thomas@studio.io',
      passwordHash: 'hash_temporaire',
      displayName: 'Thomas Renaud',
    }
  })
  console.log('Utilisateur créé :', user)

  const users = await prisma.userAccounts.findMany()
  console.log('Total users :', users.length)
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
```

```powershell
npm run dev
```

```powershell
git add .
git commit -m "feat: migration Sprint 1 — 12 tables en base"
git tag sprint-1-done
```

**Fin Jour 3 : 6 pts supplémentaires → total 23 pts. Sprint terminé un jour en avance.**

---

## JOUR 4 — Review + Rétro + Avance Sprint 2

Avec les 23 pts déjà atteints, ce jour est consacré à :

1. **Vérifier la DoD** point par point (20 min)
2. **Sprint Review** : relancer les commandes clés en live pour confirmer qu'elles fonctionnent encore (20 min)
3. **Sprint Retrospective** : noter précisément les blocages rencontrés — note spécifiquement les 3 problèmes Prisma 7 que tu as résolus (config datasource, import client, adapter), ils valent la peine d'être documentés dans ton rapport comme preuve de résolution de problème réel (15 min)
4. **Apprentissage anticipé Sprint 2** : Self-relations Prisma (1h) + théorie Prototype (45 min)

---

## ⚠️ Table des erreurs Prisma 7 spécifiques — mise à jour

| Erreur | Cause | Solution |
|---|---|---|
| `The datasource property url is no longer supported in schema files` | Prisma 7, `url` encore dans `schema.prisma` | Retire `url` du schema, mets-la dans `prisma.config.ts` |
| `Authentication failed... for '(not available)'` | Mot de passe avec caractère spécial non encodé, ou `.env` non chargé | Encoder le mot de passe (`encodeURIComponent`) + vérifier `import 'dotenv/config'` en premier dans `prisma.config.ts` |
| `Module '"@prisma/client"' has no exported member 'PrismaClient'` | Prisma 7 ne génère plus dans `@prisma/client` mais dans ton `output` custom | Importer depuis le chemin relatif vers `output` (ex: `'../generated/prisma/client'`) |
| `PrismaClient needs to be constructed with a non-empty, valid PrismaClientOptions` | `new PrismaClient()` sans adapter | Passer un adapter : `new PrismaClient({ adapter })` |
| Import path souligné en rouge dans VS Code | Le chemin relatif ne correspond pas à l'`output` réel | Relancer `npx prisma generate` et lire la ligne de sortie exacte (`Generated Prisma Client ... to .\...`) |

---

## 📁 Structure finale du projet — fin Sprint 1

```
screenshot-saas/
├── prisma/
│   ├── schema.prisma          ← 12 modèles, SANS url
│   └── migrations/
│       └── ..._init_sprint1/
├── src/
│   ├── generated/
│   │   └── prisma/             ← généré automatiquement, NE PAS éditer à la main
│   │       └── client.ts
│   ├── lib/
│   │   └── prisma.ts           ← Singleton avec adapter PrismaPg ✅
│   ├── index.ts
│   └── test-singleton.ts
├── uml/
│   └── singleton.uxf           ← ✅
├── prisma.config.ts            ← NOUVEAU fichier Prisma 7
├── .env                        ← jamais commité
├── .gitignore
├── package.json
└── tsconfig.json
```

---

*Sprint 1 v2 — adapté Windows + Prisma 7 · Screenshot SaaS · 19 juin 2026*

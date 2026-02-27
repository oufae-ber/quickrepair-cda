# 🔧 QuickRepair France — Digitalisation du SI

> **Projet CDA Bac+3 — ESIC | Semestre 1 2025-2026**  
> Étude de cas pratique : Digitalisation du système d'information d'une chaîne de réparation multi-boutiques

---

## 👥 Membres du groupe

| Membre | Rôle | Email |
|---|---|---|
| **Ouafae Berhili** | Architecte BDD & Ingénieure BI | beouafae@etudiant-esic.fr |
| **Amal Bouzaher** | Développeuse App & DevOps | biamal@etudiant-esic.fr |

**Groupe :** AMOU  
**Encadrant :** J. Banka (jbanka@esic.fr)

---

## 📋 Description du projet

QuickRepair France est une chaîne de 5 boutiques de réparation d'appareils électroniques en Île-de-France. Ce projet vise à digitaliser son système d'information via :

- Une **base de données relationnelle** (PostgreSQL 14 — 19 tables) hébergée sur Supabase
- Une **application CRUD** (Retool) pour gérer clients, appareils, réparations et devis
- Un **dashboard décisionnel** (Metabase) avec 6 KPI métiers
- Un **dépôt Git versionné** (GitHub) avec historique propre

---

## 🏗️ Architecture technique

```
┌─────────────────────────────────────────────────────┐
│                 QuickRepair France SI                │
├──────────────┬──────────────┬───────────────────────┤
│  Supabase    │   Retool     │      Metabase          │
│  PostgreSQL  │   App CRUD   │   Dashboard BI         │
│  19 tables   │  4 modules   │   6 KPI                │
└──────┬───────┴──────┬───────┴───────────────────────┘
       │              │
       └──────────────┴──→  GitHub (versioning)
```

---

## 🛠️ Technologies utilisées

| Technologie | Usage | Version |
|---|---|---|
| **PostgreSQL** | Base de données relationnelle (19 tables) | 14+ |
| **Supabase** | Hébergement BDD cloud + API REST | - |
| **Retool** | Application CRUD (Clients, Réparations, Devis) | - |
| **Metabase** | Dashboard BI — 6 KPI métiers | - |
| **GitHub** | Versioning du code et documentation | - |
| **Git** | Gestion des commits | 2.x |

---

## 🗄️ Base de données — 19 tables

| Groupe | Tables |
|---|---|
| **Référence** | `role`, `boutique`, `employe`, `client`, `appareil`, `type_reparation`, `statut` |
| **Logistique** | `piece`, `fournisseur`, `fournisseur_piece`, `stock`, `commande_fournisseur`, `commande_ligne` |
| **Atelier** | `reparation`, `historique_statut`, `devis`, `devis_ligne`, `reparation_piece`, `paiement` |

---

## 📁 Structure du dépôt

```
quickrepair-cda/
├── README.md
├── MissionA_Organisation/
│   ├── sprint_planning.xlsx        # A.1 — Planification Agile (3 sprints)
│   ├── journal_de_bord.xlsx        # A.3 — Journal de bord quotidien
│   └── repartition_taches.xlsx     # A.3 — Répartition des tâches
├── MissionB_Prototype/
│   ├── sql/
│   │   ├── create_database.sql     # Schéma 19 tables PostgreSQL
│   │   └── insert_data.sql         # Données de test
│   ├── config/
│   │   └── supabase_config.md      # Config connexion Supabase
│   └── screenshots/                # Captures Retool + Metabase
├── MissionC_Technique/
│   ├── plan_tests.xlsx             # C.2 — Plan de tests T01→T10
│   └── guide_installation.pdf      # C.3 — Guide d'installation
└── MissionD_Documentation/
    ├── documentation_technique.pdf
    ├── retrospective.pdf
    └── slides.pdf
```

---

## 🚀 Instructions d'installation

### Prérequis

- Compte [Supabase](https://supabase.com) (gratuit)
- Compte [Retool](https://retool.com) (gratuit)
- Compte [Metabase Cloud](https://www.metabase.com) (gratuit)
- Git installé en local

### Étape 1 — Cloner le dépôt

```bash
git clone https://github.com/oufae-ber/quickrepair-cda.git
cd quickrepair-cda
```

### Étape 2 — Configurer la base de données (Supabase)

1. Créer un projet sur [supabase.com](https://supabase.com)
2. Aller dans **SQL Editor**
3. Exécuter `MissionB_Prototype/sql/create_database.sql`
4. Exécuter `MissionB_Prototype/sql/insert_data.sql`
5. Vérifier : 19 tables créées, données présentes

### Étape 3 — Configurer l'application Retool

1. Créer un compte sur [retool.com](https://retool.com)
2. Aller dans **Resources → New Resource → PostgreSQL**
3. Renseigner les credentials Supabase (host, port 5432, database, user, password)
4. Tester la connexion

### Étape 4 — Configurer le dashboard Metabase

1. Créer un compte sur [metabase.com](https://www.metabase.com)
2. Aller dans **Admin → Databases → Add database**
3. Choisir **PostgreSQL** et renseigner les credentials Supabase
4. Importer ou recréer les 6 questions KPI

### Étape 5 — Configurer votre identité Git

```bash
# Pour Ouafae
git config user.name "Ouafae Berhili"
git config user.email "ouafae.berhili@etudiant-esic.fr"

# Pour Amal
git config user.name "Amal Bouzaher"
git config user.email "amal.bouzaher@etudiant-esic.fr"
```

---

## 🔐 Identifiants de test

| Rôle | Email | Mot de passe |
|---|---|---|
| **Responsable boutique** | lucas.martin@quickrepair.fr | QuickRepair2026! |
| **Technicien** | j.lemoine@quickrepair.fr | Technicien2026! |
| **Agent d'accueil** | c.renaud@quickrepair.fr | Accueil2026! |

---

## 📊 KPI Dashboard Metabase

| # | KPI | Table(s) source |
|---|---|---|
| KPI 1 | CA mensuel par boutique | `paiement`, `reparation`, `boutique` |
| KPI 2 | Réparations en cours par boutique | `reparation`, `historique_statut` |
| KPI 3 | Répartition par statut (camembert) | `statut`, `historique_statut` |
| KPI 4 | Top 5 types de réparation | `type_reparation`, `reparation` |
| KPI 5 | Délai moyen de réparation par boutique | `reparation` (date_depot / date_fin) |
| KPI 6 | Stock sous seuil d'alerte | `stock` |

---

## 📝 Historique des commits

| Commit | Auteur | Description |
|---|---|---|
| `Initial commit` | Ouafae Berhili | Initialisation du dépôt |
| `feat: ajout scripts SQL create_database` | Ouafae Berhili | Schéma 19 tables PostgreSQL |
| `feat: ajout fichiers Mission A et scripts` | Ouafae Berhili | Sprint planning, journal de bord |
| `docs: README complet avec description projet` | Ouafae Berhili | Documentation README |
| `feat: ajout insert_data.sql données de test` | Amal Bouzaher | Données de test toutes tables |
| `feat: config Retool et screenshots Mission B` | Amal Bouzaher | Config Retool + captures |
| `feat: ajout MissionC plan tests et guide` | Amal Bouzaher | Plan tests T01→T10 + guide |

---

## 🔗 Liens utiles

- **Dépôt GitHub :** https://github.com/oufae-ber/quickrepair-cda
- **Supabase projet :** https://supabase.com/dashboard
- **Retool app :** https://retool.com
- **Metabase dashboard :** https://www.metabase.com

---

## 📄 Licence

Projet académique — ESIC CDA Bac+3 | Semestre 1 2025-2026  
Groupe AMOU — Ouafae Berhili & Amal Bouzaher

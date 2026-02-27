# ⚙️ Configuration Supabase — QuickRepair France

> **Projet CDA Bac+3 — ESIC | Groupe AMOU**  
> Ouafae Berhili & Amal Bouzaher

---

## 🔗 Chaîne de connexion

### Session Pooler (recommandé — compatible IPv4)

```
postgresql://postgres.jljnpbslvytiubljuzrd:[YOUR-PASSWORD]@aws-1-eu-west-1.pooler.supabase.com:5432/postgres
```

> ⚠️ Remplacer `[YOUR-PASSWORD]` par le mot de passe réel de la base

---

## 📋 Paramètres de connexion détaillés

| Paramètre | Valeur |
|---|---|
| **Host** | `aws-1-eu-west-1.pooler.supabase.com` |
| **Port** | `5432` |
| **Database** | `postgres` |
| **User** | `postgres.jljnpbslvytiubljuzrd` |
| **Password** | `[YOUR-PASSWORD]` |
| **SSL** | `require` |
| **Méthode** | Session pooler |
| **Région** | `eu-west-1` (Europe — Irlande) |

---

## 🗄️ Base de données — 19 tables créées

### Tables de référence (7)
| Table | Description |
|---|---|
| `role` | Rôles utilisateurs RBAC (ADMIN, RESP_BOUTIQUE, TECH, ACCUEIL, LOGISTIQUE) |
| `boutique` | 5 points de vente Île-de-France |
| `employe` | Employés / utilisateurs du SI |
| `client` | Clients QuickRepair |
| `appareil` | Appareils déposés par les clients |
| `type_reparation` | Catalogue des types de réparations |
| `statut` | Référentiel des statuts (cycle de vie) |

### Tables logistique / pièces (6)
| Table | Description |
|---|---|
| `piece` | Pièces détachées (références internes) |
| `fournisseur` | Fournisseurs de pièces |
| `fournisseur_piece` | Prix fournisseur par pièce (N:N) |
| `stock` | Stock de pièces par boutique |
| `commande_fournisseur` | Commandes fournisseurs |
| `commande_ligne` | Lignes de commande |

### Tables atelier / réparations (6)
| Table | Description |
|---|---|
| `reparation` | Réparations (objet central du SI) |
| `historique_statut` | Traçabilité des changements de statut |
| `devis` | Devis associé à une réparation |
| `devis_ligne` | Détail opérations et pièces du devis |
| `reparation_piece` | Pièces consommées par réparation |
| `paiement` | Paiement associé à une réparation |

---

## 🚀 Instructions d'installation de la base

### Étape 1 — Créer le projet Supabase
1. Aller sur [supabase.com](https://supabase.com)
2. Cliquer **"New project"**
3. Nom du projet : `quickrepair-db`
4. Choisir région : **eu-west-1 (Europe West)**
5. Définir un mot de passe fort
6. Cliquer **"Create new project"**

### Étape 2 — Créer les 19 tables
1. Aller dans **SQL Editor**
2. Cliquer **"New query"**
3. Copier-coller le contenu de `create_database.sql`
4. Cliquer **"Run"** (▶️)
5. Vérifier : **19 tables créées** dans Table Editor

### Étape 3 — Insérer les données de test
1. Nouvelle query dans SQL Editor
2. Copier-coller le contenu de `insert_data.sql`
3. Cliquer **"Run"** (▶️)
4. Vérifier les données dans Table Editor

### Étape 4 — Récupérer la chaîne de connexion
1. Aller dans **Settings → Database**
2. Section **"Connection string"**
3. Choisir **"Session pooler"**
4. Copier la chaîne URI

---

## 🔌 Connexion Retool

Dans Retool → **Resources → New Resource → PostgreSQL** :

| Champ | Valeur |
|---|---|
| Host | `aws-1-eu-west-1.pooler.supabase.com` |
| Port | `5432` |
| Database name | `postgres` |
| Database username | `postgres.jljnpbslvytiubljuzrd` |
| Database password | `[YOUR-PASSWORD]` |
| SSL | ✅ Activé |

---

## 🔌 Connexion Metabase

Dans Metabase → **Admin → Databases → Add database** :

| Champ | Valeur |
|---|---|
| Database type | `PostgreSQL` |
| Host | `aws-1-eu-west-1.pooler.supabase.com` |
| Port | `5432` |
| Database name | `postgres` |
| Username | `postgres.jljnpbslvytiubljuzrd` |
| Password | `[YOUR-PASSWORD]` |
| SSL | ✅ Activé |

---

## 📊 Données de test insérées

| Table | Nb enregistrements |
|---|---|
| `boutique` | 5 boutiques (B01→B05) |
| `role` | 5 rôles |
| `employe` | 12 employés |
| `client` | 20 clients |
| `appareil` | 30 appareils |
| `type_reparation` | 20 types |
| `statut` | 11 statuts |
| `piece` | 20 pièces |
| `fournisseur` | 5 fournisseurs |
| `reparation` | 20 réparations |

---





*Configuration établie par Ouafae Berhili — Groupe AMOU — CDA Bac+3 ESIC S1 2025-2026*

-- =========================================================
-- QuickRepair France - Base de données (PostgreSQL 14+)
-- Script : create_database_postgresql.sql
-- Converti depuis MySQL 8 / InnoDB
-- =========================================================

-- Supprime et recrée la base (à exécuter en tant que superuser)
-- DROP DATABASE IF EXISTS quickrepair_db;
-- CREATE DATABASE quickrepair_db ENCODING 'UTF8';
-- \c quickrepair_db

-- -----------------------
-- TABLES DE REFERENCE
-- -----------------------

/* Rôles applicatifs (RBAC) */
CREATE TABLE role (
  id_role SERIAL PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE,
  libelle VARCHAR(80) NOT NULL,
  CONSTRAINT chk_role_code CHECK (code IN ('ADMIN','RESP_BOUTIQUE','TECH','ACCUEIL','LOGISTIQUE'))
);
COMMENT ON TABLE role IS 'Rôles utilisateurs (RBAC)';

/* Boutiques (5 points de vente) */
CREATE TABLE boutique (
  id_boutique VARCHAR(10) PRIMARY KEY,
  nom VARCHAR(120) NOT NULL,
  adresse VARCHAR(200) NOT NULL,
  ville VARCHAR(100) NOT NULL,
  code_postal VARCHAR(10) NOT NULL,
  CONSTRAINT chk_cp_boutique CHECK (code_postal ~ '^[0-9]{5}$')
);
COMMENT ON TABLE boutique IS 'Boutiques QuickRepair (Ile-de-France)';

/* Employés */
CREATE TABLE employe (
  id_employe SERIAL PRIMARY KEY,
  id_boutique VARCHAR(10) NOT NULL,
  id_role INT NOT NULL,
  nom VARCHAR(100) NOT NULL,
  prenom VARCHAR(100) NOT NULL,
  email_pro VARCHAR(255) NOT NULL UNIQUE,
  actif BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_employe_boutique FOREIGN KEY (id_boutique) REFERENCES boutique(id_boutique)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_employe_role FOREIGN KEY (id_role) REFERENCES role(id_role)
    ON UPDATE CASCADE ON DELETE RESTRICT
);
COMMENT ON TABLE employe IS 'Employés / utilisateurs du SI';

/* Clients */
CREATE TABLE client (
  id_client SERIAL PRIMARY KEY,
  nom VARCHAR(100) NOT NULL,
  prenom VARCHAR(100) NOT NULL,
  telephone VARCHAR(20) NOT NULL,
  email VARCHAR(255) NULL UNIQUE,
  ville VARCHAR(100) NULL,
  code_postal VARCHAR(10) NULL,
  client_depuis DATE NOT NULL DEFAULT CURRENT_DATE,
  CONSTRAINT chk_cp_client CHECK (code_postal IS NULL OR code_postal ~ '^[0-9]{5}$')
);
COMMENT ON TABLE client IS 'Clients QuickRepair (données personnelles)';

/* Appareils */
CREATE TABLE appareil (
  id_appareil SERIAL PRIMARY KEY,
  id_client INT NOT NULL,
  marque VARCHAR(80) NOT NULL,
  modele VARCHAR(120) NOT NULL,
  categorie VARCHAR(40) NOT NULL,
  numero_serie VARCHAR(80) NULL UNIQUE,
  CONSTRAINT chk_categorie_appareil CHECK (categorie IN ('Smartphone','PC Portable','Tablette','Console','Montre connectée')),
  CONSTRAINT fk_appareil_client FOREIGN KEY (id_client) REFERENCES client(id_client)
    ON UPDATE CASCADE ON DELETE RESTRICT
);
COMMENT ON TABLE appareil IS 'Appareils déposés par les clients';

/* Catalogue des types de réparations */
CREATE TABLE type_reparation (
  code_type VARCHAR(20) PRIMARY KEY,
  libelle VARCHAR(200) NOT NULL,
  categorie_appareil VARCHAR(40) NOT NULL,
  prix_moyen NUMERIC(10,2) NOT NULL,
  duree_moy_h NUMERIC(5,2) NOT NULL,
  CONSTRAINT chk_prix_moyen CHECK (prix_moyen >= 0),
  CONSTRAINT chk_duree_moy CHECK (duree_moy_h >= 0)
);
COMMENT ON TABLE type_reparation IS 'Catalogue des types de réparations';

/* Statuts (cycle de vie) */
CREATE TABLE statut (
  id_statut SERIAL PRIMARY KEY,
  libelle VARCHAR(80) NOT NULL UNIQUE,
  ordre INT NOT NULL,
  CONSTRAINT chk_statut_ordre CHECK (ordre >= 1)
);
COMMENT ON TABLE statut IS 'Référentiel des statuts de réparation';

-- -----------------------
-- LOGISTIQUE / PIECES
-- -----------------------

/* Pièces détachées */
CREATE TABLE piece (
  id_piece SERIAL PRIMARY KEY,
  reference VARCHAR(60) NOT NULL UNIQUE,
  libelle VARCHAR(200) NOT NULL,
  categorie VARCHAR(60) NOT NULL
);
COMMENT ON TABLE piece IS 'Pièces détachées (références internes)';

/* Fournisseurs */
CREATE TABLE fournisseur (
  id_fournisseur VARCHAR(10) PRIMARY KEY,
  nom VARCHAR(150) NOT NULL,
  specialite VARCHAR(150) NULL,
  delai_moy_jours INT NULL,
  ville VARCHAR(100) NULL,
  CONSTRAINT chk_delai_fournisseur CHECK (delai_moy_jours IS NULL OR delai_moy_jours >= 0)
);
COMMENT ON TABLE fournisseur IS 'Fournisseurs de pièces détachées';

/* N:N fournisseur - pièce avec prix */
CREATE TABLE fournisseur_piece (
  id_fournisseur VARCHAR(10) NOT NULL,
  id_piece INT NOT NULL,
  prix_unitaire NUMERIC(10,2) NOT NULL,
  ref_piece_fournisseur VARCHAR(60) NULL,
  PRIMARY KEY (id_fournisseur, id_piece),
  CONSTRAINT chk_prix_fp CHECK (prix_unitaire >= 0),
  CONSTRAINT fk_fp_fournisseur FOREIGN KEY (id_fournisseur) REFERENCES fournisseur(id_fournisseur)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_fp_piece FOREIGN KEY (id_piece) REFERENCES piece(id_piece)
    ON UPDATE CASCADE ON DELETE CASCADE
);
COMMENT ON TABLE fournisseur_piece IS 'Prix fournisseur par pièce (N:N avec attribut)';

/* Stock par boutique */
CREATE TABLE stock (
  id_boutique VARCHAR(10) NOT NULL,
  id_piece INT NOT NULL,
  quantite INT NOT NULL DEFAULT 0,
  seuil_alerte INT NOT NULL DEFAULT 5,
  emplacement VARCHAR(60) NULL,
  PRIMARY KEY (id_boutique, id_piece),
  CONSTRAINT chk_stock_qte CHECK (quantite >= 0),
  CONSTRAINT chk_stock_seuil CHECK (seuil_alerte >= 0),
  CONSTRAINT fk_stock_boutique FOREIGN KEY (id_boutique) REFERENCES boutique(id_boutique)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_stock_piece FOREIGN KEY (id_piece) REFERENCES piece(id_piece)
    ON UPDATE CASCADE ON DELETE CASCADE
);
COMMENT ON TABLE stock IS 'Stock de pièces par boutique';

/* Commandes fournisseurs */
CREATE TABLE commande_fournisseur (
  id_commande SERIAL PRIMARY KEY,
  id_fournisseur VARCHAR(10) NOT NULL,
  id_boutique VARCHAR(10) NOT NULL,
  date_commande DATE NOT NULL DEFAULT CURRENT_DATE,
  date_reception_prevue DATE NULL,
  date_reception DATE NULL,
  statut_commande VARCHAR(20) NOT NULL,
  CONSTRAINT chk_statut_commande CHECK (statut_commande IN ('en_cours','livree','annulee')),
  CONSTRAINT fk_cf_fournisseur FOREIGN KEY (id_fournisseur) REFERENCES fournisseur(id_fournisseur)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_cf_boutique FOREIGN KEY (id_boutique) REFERENCES boutique(id_boutique)
    ON UPDATE CASCADE ON DELETE RESTRICT
);
COMMENT ON TABLE commande_fournisseur IS 'Commandes de pièces auprès des fournisseurs';

/* Lignes de commande fournisseur */
CREATE TABLE commande_ligne (
  id_commande INT NOT NULL,
  id_piece INT NOT NULL,
  quantite INT NOT NULL,
  prix_achat NUMERIC(10,2) NOT NULL,
  PRIMARY KEY (id_commande, id_piece),
  CONSTRAINT chk_cl_qte CHECK (quantite >= 1),
  CONSTRAINT chk_cl_prix CHECK (prix_achat >= 0),
  CONSTRAINT fk_cl_commande FOREIGN KEY (id_commande) REFERENCES commande_fournisseur(id_commande)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_cl_piece FOREIGN KEY (id_piece) REFERENCES piece(id_piece)
    ON UPDATE CASCADE ON DELETE RESTRICT
);
COMMENT ON TABLE commande_ligne IS 'Lignes de commande fournisseur';

-- -----------------------
-- ATELIER / REPARATIONS
-- -----------------------

/* Réparations */
CREATE TABLE reparation (
  id_reparation SERIAL PRIMARY KEY,
  id_appareil INT NOT NULL,
  id_boutique VARCHAR(10) NOT NULL,
  code_type VARCHAR(20) NOT NULL,
  technicien_principal_id INT NOT NULL,
  technicien_qc_id INT NULL,
  numero_suivi VARCHAR(30) NOT NULL UNIQUE,
  date_depot TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  description_panne TEXT NOT NULL,
  devis_montant NUMERIC(10,2) NULL,
  devis_accepte BOOLEAN NULL,
  date_debut TIMESTAMP NULL,
  date_fin TIMESTAMP NULL,
  date_fin_garantie DATE NULL,
  CONSTRAINT chk_devis_montant CHECK (devis_montant IS NULL OR devis_montant >= 0),
  CONSTRAINT fk_rep_appareil FOREIGN KEY (id_appareil) REFERENCES appareil(id_appareil)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_rep_boutique FOREIGN KEY (id_boutique) REFERENCES boutique(id_boutique)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_rep_type FOREIGN KEY (code_type) REFERENCES type_reparation(code_type)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_rep_tech_principal FOREIGN KEY (technicien_principal_id) REFERENCES employe(id_employe)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_rep_tech_qc FOREIGN KEY (technicien_qc_id) REFERENCES employe(id_employe)
    ON UPDATE CASCADE ON DELETE SET NULL
);
COMMENT ON TABLE reparation IS 'Réparations (objet central du SI)';

/* Historique des statuts */
CREATE TABLE historique_statut (
  id_hist SERIAL PRIMARY KEY,
  id_reparation INT NOT NULL,
  id_statut INT NOT NULL,
  id_employe_auteur INT NOT NULL,
  date_changement TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  commentaire TEXT NULL,
  CONSTRAINT fk_hs_rep FOREIGN KEY (id_reparation) REFERENCES reparation(id_reparation)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_hs_statut FOREIGN KEY (id_statut) REFERENCES statut(id_statut)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_hs_auteur FOREIGN KEY (id_employe_auteur) REFERENCES employe(id_employe)
    ON UPDATE CASCADE ON DELETE RESTRICT
);
COMMENT ON TABLE historique_statut IS 'Traçabilité des changements de statut (RG6)';

/* Devis (0..1 par réparation) */
CREATE TABLE devis (
  id_devis SERIAL PRIMARY KEY,
  id_reparation INT NOT NULL UNIQUE,
  date_devis TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  montant_total NUMERIC(10,2) NOT NULL,
  statut_devis VARCHAR(20) NOT NULL,
  CONSTRAINT chk_devis_total CHECK (montant_total >= 0),
  CONSTRAINT chk_statut_devis CHECK (statut_devis IN ('brouillon','envoye','accepte','refuse')),
  CONSTRAINT fk_devis_rep FOREIGN KEY (id_reparation) REFERENCES reparation(id_reparation)
    ON UPDATE CASCADE ON DELETE CASCADE
);
COMMENT ON TABLE devis IS 'Devis associé à une réparation (RG7)';

/* Lignes de devis */
CREATE TABLE devis_ligne (
  id_devis_ligne SERIAL PRIMARY KEY,
  id_devis INT NOT NULL,
  type_ligne VARCHAR(10) NOT NULL,
  libelle VARCHAR(200) NOT NULL,
  qte INT NOT NULL DEFAULT 1,
  prix_unitaire NUMERIC(10,2) NOT NULL,
  CONSTRAINT chk_dl_type CHECK (type_ligne IN ('OPERATION','PIECE')),
  CONSTRAINT chk_dl_qte CHECK (qte >= 1),
  CONSTRAINT chk_dl_pu CHECK (prix_unitaire >= 0),
  CONSTRAINT fk_dl_devis FOREIGN KEY (id_devis) REFERENCES devis(id_devis)
    ON UPDATE CASCADE ON DELETE CASCADE
);
COMMENT ON TABLE devis_ligne IS 'Détail des opérations et pièces du devis';

/* Pièces utilisées sur une réparation (N:N) */
CREATE TABLE reparation_piece (
  id_reparation INT NOT NULL,
  id_piece INT NOT NULL,
  quantite INT NOT NULL DEFAULT 1,
  prix_applique NUMERIC(10,2) NOT NULL,
  PRIMARY KEY (id_reparation, id_piece),
  CONSTRAINT chk_rp_qte CHECK (quantite >= 1),
  CONSTRAINT chk_rp_prix CHECK (prix_applique >= 0),
  CONSTRAINT fk_rp_rep FOREIGN KEY (id_reparation) REFERENCES reparation(id_reparation)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_rp_piece FOREIGN KEY (id_piece) REFERENCES piece(id_piece)
    ON UPDATE CASCADE ON DELETE RESTRICT
);
COMMENT ON TABLE reparation_piece IS 'Pièces réellement consommées par réparation (RG3)';

/* Paiements (0..1 par réparation) */
CREATE TABLE paiement (
  id_paiement SERIAL PRIMARY KEY,
  id_reparation INT NOT NULL UNIQUE,
  date_paiement TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  montant NUMERIC(10,2) NOT NULL,
  mode VARCHAR(10) NOT NULL,
  reference VARCHAR(80) NULL,
  CONSTRAINT chk_p_montant CHECK (montant >= 0),
  CONSTRAINT chk_p_mode CHECK (mode IN ('CB','especes','virement')),
  CONSTRAINT fk_p_rep FOREIGN KEY (id_reparation) REFERENCES reparation(id_reparation)
    ON UPDATE CASCADE ON DELETE CASCADE
);
COMMENT ON TABLE paiement IS 'Paiement associé à une réparation (RG8)';

-- -----------------------
-- INDEXES (recherche / performance)
-- -----------------------
CREATE INDEX idx_client_nom ON client(nom, prenom);
CREATE INDEX idx_appareil_client ON appareil(id_client);
CREATE INDEX idx_reparation_numero_suivi ON reparation(numero_suivi);
CREATE INDEX idx_reparation_boutique ON reparation(id_boutique);
CREATE INDEX idx_reparation_type ON reparation(code_type);
CREATE INDEX idx_histo_rep_date ON historique_statut(id_reparation, date_changement);
CREATE INDEX idx_stock_seuil ON stock(id_boutique, seuil_alerte, quantite);
CREATE INDEX idx_employe_boutique_role ON employe(id_boutique, id_role);
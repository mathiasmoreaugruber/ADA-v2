WITH Gestion_Identites;
USE  Gestion_Identites;
PACKAGE Gestion_Personnel IS
   TYPE T_Categorie IS (Aucun, Technicien, Ingenieur);
   TYPE T_Statut IS (Disponible, En_Prestation);
   TYPE T_Employe IS RECORD
      ID              : T_Id;
      Categorie       : T_Categorie;
      Nb_J_Prestation : Integer;
      Statut          : T_Statut;
      Depart          : Boolean;
   END RECORD;
   TYPE T_Cellule_Employe;
   TYPE T_Ptr_Employe IS ACCESS T_Cellule_Employe;
   TYPE T_Cellule_Employe IS RECORD
      Val  : T_Employe;
      Suiv : T_Ptr_Employe;
   END RECORD;
   PROCEDURE Saisie_Emp     (E : OUT T_Employe);
   PROCEDURE Ajout_Emp      (E : IN T_Employe; Tete : IN OUT T_Ptr_Employe; Ok : OUT Boolean);
   PROCEDURE Supp_Emp       (Tete : IN OUT T_Ptr_Employe; N : IN T_Nom; C : IN T_Categorie; Ok : OUT Boolean);
   PROCEDURE Fin_Prestation (Tete : IN OUT T_Ptr_Employe; N : IN T_Nom; C : IN T_Categorie; Nb_Jours : IN Integer);
   PROCEDURE Supp_Departs   (Tete : IN OUT T_Ptr_Employe);
   PROCEDURE Vis_Employe    (E : IN T_Employe);
   PROCEDURE Vis_Employes   (Tete : IN T_Ptr_Employe);
   PROCEDURE Vis_Employe_D  (Tete : IN T_Ptr_Employe; N : IN T_Nom; C : IN T_Categorie; Ok : OUT Boolean);
   FUNCTION  Cherche_Dispo  (Tete : IN T_Ptr_Employe; C : IN T_Categorie) RETURN T_Ptr_Employe;
END Gestion_Personnel;

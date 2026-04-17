with Gestion_Identites; use Gestion_Identites;
with Gestion_Demande;   use Gestion_Demande;
with Gestion_Date;      use Gestion_Date;
with Gestion_Materiel;  use Gestion_Materiel;
with Gestion_Personnel; use Gestion_Personnel;
with Gestion_Client;    use Gestion_Client;
package Gestion_Location is
   type T_Location is record
      N               : Integer;
      Id_Client       : T_Id;
      Duree           : Integer;
      Debut           : T_Date;
      Fin             : T_Date;
      Attente         : Integer;
      Accomp          : T_Categorie;
      Id_Employe      : T_Id;
      Id_Materiel     : Integer;
      Nature_Materiel : T_Cate_Materiel;
   end record;
   type T_Cellule_Location;
   type T_Pointeur_Location is access T_Cellule_Location;
   type T_Cellule_Location is record
      Val  : T_Location;
      Suiv : T_Pointeur_Location;
   end record;
   procedure Creer_Location
     (D        : in T_Demande;
      L        : out T_Location;
      Date     : in T_Date;
      Tete_Mat : in T_Pt;
      Tete_Emp : in T_Ptr_Employe);
   procedure Ajout_Location
     (L : in T_Location; Tete : in out T_Pointeur_Location);
   procedure Visualisation_Location (L : in T_Location);
   procedure Visualisation_Locations (Tete : in T_Pointeur_Location);
   procedure Visu_Locations_En_Cours
     (Tete : in T_Pointeur_Location; D : in T_Date);
   procedure Visu_Locations_Archivees
     (Tete : in T_Pointeur_Location; D : in T_Date);
   procedure Visu_Locations_Employe
     (Tete : in T_Pointeur_Location; Id : in T_Id; D : in T_Date);
   procedure Visu_Locations_Client
     (Tete : in T_Pointeur_Location; Id : in T_Id; D : in T_Date);
   procedure Traiter_Fins
     (Tete_En_Cours : in out T_Pointeur_Location;
      Tete_Archive  : in out T_Pointeur_Location;
      Abr           : in out T_ABR_Clients;
      Tete_Mat      : in out T_Pt;
      Tete_Emp      : in out T_Ptr_Employe;
      Date_Hier     : in T_Date);
   function Calcul_Prix
     (Duree : in Integer; Mat : in T_Cate_Materiel; Acc : in T_Categorie)
      return Integer;
   procedure user_story_location (Tete : in out T_Pointeur_Location);
end Gestion_Location;

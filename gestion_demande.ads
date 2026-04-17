with ada.text_io;         use Ada.Text_Io;
with ada.integer_text_io; use Ada.Integer_Text_Io;
with gestion_identites;   use Gestion_Identites;
with gestion_materiel;    use Gestion_Materiel;
with gestion_client;      use Gestion_Client;
with gestion_date;        use Gestion_Date;
with gestion_personnel;   use Gestion_Personnel;
package Gestion_Demande is
   type T_demande is record
      numero         : integer;
      id_client      : T_Client;
      duree          : integer range 1 .. 10;
      date           : T_date;
      accompagnement : T_Categorie;
      materiel       : T_cate_materiel;
   end record;
   type T_cell_demande;
   type T_pt_demande is access T_cell_demande;
   type T_cell_demande is record
      demande : T_demande;
      suiv    : T_pt_demande;
   end record;
   type T_file_demande is record
      tete, queue : T_pt_demande;
   end record;
   procedure enfiler (D : in out T_file_demande; dem : in T_demande);
   procedure defiler
     (D : in out T_file_demande; id_cible : in integer; ok : out Boolean);
   procedure nv_demande
     (D          : in out T_file_demande;
      Abr        : in out T_ABR_Clients;
      date       : in T_date;
      id_demande : in out integer);
   procedure visu_demande (D : in T_file_demande);
   procedure supp_dem_id (D : in out T_file_demande);
   procedure user_story_demande (D : in out T_file_demande);
end Gestion_Demande;

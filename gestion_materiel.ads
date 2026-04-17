with ada.Text_IO;
with ada.integer_text_io;
with gestion_date;
use ada.Text_IO;
use ada.integer_text_io;
use gestion_date;
package gestion_materiel is
   type T_cate_materiel is (camera, son, sono, projection, lumiere);
   type T_materiel is record
      cat         : T_cate_materiel;
      id_materiel : integer;
      date        : T_date;
      nb_jours    : integer;
      Dispo       : boolean;
      indic_sup   :
        boolean;
   end record;
   type T_liste_materiel;
   type T_pt is access T_liste_materiel;
   type T_liste_materiel is record
      materiel : T_materiel;
      suiv     : T_pt;
   end record;
   procedure liberer (tete : in out T_pt);
   procedure visu_1pack
     (tete : in T_pt);
   procedure visu_tous_pack (tete : in T_pt);
   procedure visu_pack_dispo
     (tete : in T_pt);
   procedure nv_pack
     (mat     : out T_materiel;
      tete    : in out T_pt;
      id_pack : in out integer);
   procedure chercher_supprimer_pack_idcat
     (tete : in out T_pt;
      id   : in integer;
      mat  : in T_cate_materiel;
      ok   :
        out boolean);
   procedure sup_pack_idcat
     (tete :
        in out T_pt);
   procedure chercher_supprimer_pack_date
     (tete : in out T_pt; date : in T_Date; ok : in out boolean);
   procedure sup_pack_date
     (tete :
        in out T_pt);
   procedure user_story_materiel
     (tete :
        in out T_pt);
   function Cherche_Meilleur_Pack
     (tete : in T_pt; cat : in T_cate_materiel) return T_pt;
   procedure Rendre_Pack (p : in T_pt; nb_jours : in integer);
end gestion_materiel;

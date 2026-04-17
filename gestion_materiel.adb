with ada.Text_IO;
with ada.integer_text_io;
with gestion_date;
with ada.Unchecked_Deallocation;
use ada.Text_IO;
use ada.integer_text_io;
use gestion_date;
package body gestion_materiel is
   procedure free is new ada.Unchecked_Deallocation (T_liste_materiel, T_pt);
   procedure liberer (tete : in out T_pt) is
   begin
      free (tete);
   end liberer;
   procedure visu_1pack (tete : in T_pt) is
   begin
      new_line;
      put ("Categorie du pack : ");
      put (T_cate_materiel'Image (tete.materiel.cat));
      new_line;
      put ("id materiel du pack :");
      put (tete.materiel.id_materiel);
      new_line;
      put ("Date debut : ");
      Affichage_Date (tete.materiel.date);
      put ("Nombre de jours de location : ");
      put (tete.materiel.nb_jours);
      new_line;
      if tete.materiel.dispo then
         put ("Materiel disponible");
      else
         put ("Materiel deja loue");
      end if;
      new_line;
      if tete.materiel.indic_sup then
         put ("Le pack va etre supprime");
      else
         put ("Le pack doit etre garde");
      end if;
      new_line;
      new_line;
      put ("------------------------------------------------");
      new_line;
   end visu_1pack;
   procedure visu_tous_pack (tete : in T_pt) is
   begin
      if tete /= null then
         visu_1pack (tete);
         visu_tous_pack (tete.suiv);
      end if;
   end visu_tous_pack;
   procedure visu_pack_dispo (tete : in T_pt) is
   begin
      if tete /= null then
         if tete.materiel.dispo = true then
            visu_1pack (tete);
         end if;
         visu_pack_dispo (tete.suiv);
      end if;
   end visu_pack_dispo;
   procedure nv_pack
     (mat : out T_materiel; tete : in out T_pt; id_pack : in out integer)
   is
      n : integer;
   begin
      loop
         begin
            put
              ("Saisir la categorie du pack (0: camera, 1: son, 2: sono, 3: projection, 4: lumiere) :");
            get (n);
            skip_line;
            exit when n >= 0 and then n <= 4;
            put_line ("Categorie invalide, veuillez reessayer.");
         exception
            when Data_Error =>
               Skip_Line;
               Put_Line ("Erreur de saisie, recommencez");
            when Constraint_Error =>
               Skip_Line;
               Put_Line ("Mauvaise valeur, recommencez");
         end;
      end loop;
      mat.cat := T_cate_materiel'Val (n);
      mat.id_materiel := id_pack;
      id_pack := id_pack + 1;
      Saisie_Date (mat.date);
      mat.nb_jours := 0;
      mat.dispo := true;
      mat.indic_sup := false;
      tete := new T_liste_materiel'(mat, tete);
   end nv_pack;
   procedure chercher_supprimer_pack_idcat
     (tete : in out T_pt;
      id   : in integer;
      mat  : in T_cate_materiel;
      ok   : out boolean)
   is
      tmp : T_pt := tete;
   begin
      if tmp = null then
         ok := false;
      elsif tmp.materiel.id_materiel = id and then tmp.materiel.cat = mat then
         ok := true;
         if tmp.materiel.dispo = true then
            tmp := tete;
            tete := tete.suiv;
            Liberer (tmp);
            put_line ("Le pack a ete supprime.");
         else
            tete.materiel.indic_sup := true;
            put_line
              ("Le pack ne peut pas être supprime car il est deja loue, mais il va être marque pour suppression.");
         end if;
      else
         chercher_supprimer_pack_idcat (tete.suiv, id, mat, ok);
      end if;
   end chercher_supprimer_pack_idcat;
   procedure sup_pack_idcat (tete : in out T_pt) is
      id : integer;
      n  : T_cate_materiel;
      v  : integer;
      ok : boolean := false;
   begin
      if tete = null then
         ok := false;
         put_line ("La liste est vide");
      else
         loop
            begin
               put ("Saisir l'id du pack a supprimer :");
               get (id);
               skip_line;
               put
                 ("Saisir la categorie du pack a supprimer (0: camera, 1: son, 2: sono, 3: projection, 4: lumiere) :");
               get (v);
               skip_line;
               exit when id > 0 and then v >= 0 and then v <= 4;
               put_line ("Id ou categorie invalide, veuillez reessayer.");
            exception
               when Data_Error =>
                  Skip_Line;
                  Put_Line ("Erreur de saisie, recommencez");
               when Constraint_Error =>
                  Skip_Line;
                  Put_Line ("Mauvaise valeur, recommencez");
            end;
         end loop;
         n := T_cate_materiel'Val (v);
         chercher_supprimer_pack_idcat (tete, id, n, ok);
         if not ok then
            put_line ("Aucun pack n'a ete supprime.");
         end if;
      end if;
   end sup_pack_idcat;
   procedure chercher_supprimer_pack_date
     (tete : in out T_pt; date : in T_date; ok : in out boolean)
   is
      tmp : T_pt := tete;
   begin
      if tete /= null then
         if Difference_Jours (tete.materiel.date, date) > 0 then
            ok := true;
            if tete.materiel.dispo = true then
               tmp := tete;
               tete := tete.suiv;
               Liberer (tmp);
               put_line ("Le pack a ete supprime.");
               chercher_supprimer_pack_date (tete, date, ok);
            else
               tete.materiel.indic_sup := true;
               put_line
                 ("Le pack ne peut pas être supprime car il est deja loue, mais il va être marque pour suppression.");
               chercher_supprimer_pack_date (tete.suiv, date, ok);
            end if;
         else
            chercher_supprimer_pack_date (tete.suiv, date, ok);
         end if;
      end if;
   end chercher_supprimer_pack_date;
   procedure sup_pack_date (tete : in out T_pt) is
      d  : T_date;
      ok : boolean := false;
   begin
      if tete = null then
         put_line ("La liste est vide");
         ok := false;
      else
         put_line
           ("Saisir la date de reference pour la suppression des packs :");
         Saisie_Date (d);
         chercher_supprimer_pack_date (tete, d, ok);
         if not ok then
            put_line ("Aucun pack n'a ete supprime.");
         else
            put_line ("La suppression des packs a ete effectuee.");
         end if;
      end if;
   end sup_pack_date;
   procedure user_story_materiel (tete : in out T_pt) is
   begin
      tete := new T_liste_materiel;
      tete.materiel.cat := camera;
      tete.materiel.id_materiel := 8;
      tete.materiel.date := (18, 4, 2026);
      tete.materiel.nb_jours := 0;
      tete.materiel.dispo := false;
      tete.materiel.indic_sup := false;
      tete := new T_liste_materiel'(tete.materiel, tete);
      tete.materiel.cat := camera;
      tete.materiel.id_materiel := 4;
      tete.materiel.date := (17, 4, 2026);
      tete.materiel.nb_jours := 0;
      tete.materiel.dispo := true;
      tete.materiel.indic_sup := false;
      tete := new T_liste_materiel'(tete.materiel, tete);
      tete.materiel.cat := camera;
      tete.materiel.id_materiel := 1;
      tete.materiel.date := (15, 4, 2025);
      tete.materiel.nb_jours := 0;
      tete.materiel.dispo := true;
      tete.materiel.indic_sup := false;
      tete := new T_liste_materiel'(tete.materiel, tete);
      tete.materiel.cat := sono;
      tete.materiel.id_materiel := 7;
      tete.materiel.date := (18, 4, 2026);
      tete.materiel.nb_jours := 0;
      tete.materiel.dispo := false;
      tete.materiel.indic_sup := false;
      tete := new T_liste_materiel'(tete.materiel, tete);
      tete.materiel.cat := sono;
      tete.materiel.id_materiel := 6;
      tete.materiel.date := (17, 4, 2026);
      tete.materiel.nb_jours := 0;
      tete.materiel.dispo := true;
      tete.materiel.indic_sup := false;
      tete := new T_liste_materiel'(tete.materiel, tete);
      tete.materiel.cat := projection;
      tete.materiel.id_materiel := 5;
      tete.materiel.date := (17, 4, 2026);
      tete.materiel.nb_jours := 0;
      tete.materiel.dispo := true;
      tete.materiel.indic_sup := false;
      tete := new T_liste_materiel'(tete.materiel, tete);
      tete.materiel.cat := projection;
      tete.materiel.id_materiel := 3;
      tete.materiel.date := (16, 4, 2026);
      tete.materiel.nb_jours := 0;
      tete.materiel.dispo := true;
      tete.materiel.indic_sup := false;
      tete := new T_liste_materiel'(tete.materiel, tete);
      tete.materiel.cat := lumiere;
      tete.materiel.id_materiel := 9;
      tete.materiel.date := (19, 4, 2026);
      tete.materiel.nb_jours := 0;
      tete.materiel.dispo := false;
      tete.materiel.indic_sup := false;
      tete := new T_liste_materiel'(tete.materiel, tete);
      tete.materiel.cat := lumiere;
      tete.materiel.id_materiel := 2;
      tete.materiel.date := (15, 4, 2026);
      tete.materiel.nb_jours := 0;
      tete.materiel.dispo := false;
      tete.materiel.indic_sup := false;
   end user_story_materiel;
   function Cherche_Meilleur_Pack
     (tete : in T_pt; cat : in T_cate_materiel) return T_pt
   is
      p       : T_pt := tete;
      meilleur : T_pt := null;
   begin
      while p /= null loop
         if p.materiel.cat = cat and then p.materiel.dispo = true
            and then p.materiel.indic_sup = false
         then
            if meilleur = null or else
               p.materiel.nb_jours < meilleur.materiel.nb_jours
            then
               meilleur := p;
            end if;
         end if;
         p := p.suiv;
      end loop;
      return meilleur;
   end Cherche_Meilleur_Pack;
   procedure Rendre_Pack (p : in T_pt; nb_jours : in integer) is
   begin
      p.materiel.dispo := true;
      p.materiel.nb_jours := p.materiel.nb_jours + nb_jours;
      if p.materiel.indic_sup then
         null;
      end if;
   end Rendre_Pack;
end gestion_materiel;

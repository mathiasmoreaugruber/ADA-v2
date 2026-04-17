with ada.text_io;         use Ada.Text_Io;
with ada.integer_text_io; use Ada.Integer_Text_Io;
with gestion_identites;   use Gestion_Identites;
with gestion_materiel;    use Gestion_Materiel;
with gestion_client;      use Gestion_Client;
with gestion_date;        use Gestion_Date;
with gestion_personnel;   use Gestion_Personnel;
package body Gestion_Demande is
   procedure enfiler (D : in out T_file_demande; dem : in T_demande) is
   begin
      if D.tete = null then
         D.tete := new T_cell_demande'(dem, null);
         D.queue := D.tete;
      else
         D.queue.suiv := new T_cell_demande'(dem, null);
         D.queue := D.queue.suiv;
      end if;
   end enfiler;
   procedure defiler
     (D : in out T_file_demande; id_cible : in integer; ok : out Boolean)
   is
      tmp  : T_pt_demande := D.tete;
      prec : T_pt_demande := null;
   begin
      ok := false;
      while tmp /= null loop
         if tmp.demande.numero = id_cible then
            if prec = null then
               D.tete := tmp.suiv;
               if D.tete = null then
                  D.queue := null;
               end if;
            else
               prec.suiv := tmp.suiv;
               if tmp.suiv = null then
                  D.queue := prec;
               end if;
            end if;
            ok := true;
            return;
         end if;
         prec := tmp;
         tmp := tmp.suiv;
      end loop;
   end defiler;
   procedure nv_demande
     (D          : in out T_file_demande;
      Abr        : in out T_ABR_Clients;
      date       : in T_date;
      id_demande : in out integer)
   is
      dem             : T_demande;
      identifiant     : T_id;
      client          : T_Client;
      Res_Abr         : T_ABR_Clients;
      rep, rep2, rep3 : integer;
   begin
      Put ("---Nouvelle demande de location---");
      new_line;
      Put ("Recherche du client");
      new_line;
      client := Saisie_Client;
      Res_Abr := cherche_Client (client.Id, Abr);
      if Res_Abr = null then
         Put ("client non trouve il faut l'ajouter : ");
         new_line;
         Nv_Client (client, Abr);
         Put ("client ajoute");
         new_line;
      else
         Put ("client trouve");
         new_line;
         client := Res_Abr.client;
      end if;
      dem.id_client := client;
      loop
         begin
            Put ("combien de jours voulez vous louer le materiel ?");
            new_line;
            Get (dem.duree);
            Skip_Line;
            exit when dem.duree >= 1 and dem.duree < 11;
            Put ("duree de location doit etre entre 1 et 10 jours");
            new_line;
         exception
            when Data_Error =>
               skip_line;
               put_line ("erreur de saisie, il faut un nombre entre 1 et 10");
               new_line;
            when Constraint_Error =>
               skip_line;
               put_line ("erreur de saisie, il faut un nombre entre 1 et 10");
               new_line;
         end;
      end loop;
      dem.date := date;
      loop
         begin
            Put ("voulez vous un accompagnement ? 1 pour oui, 0 pour non : ");
            new_line;
            Get (rep);
            Skip_Line;
            exit when rep = 1 or rep = 0;
            Put ("La reponse doit etre 1 pour oui ou 0 pour non");
            new_line;
         exception
            when Data_Error =>
               skip_line;
               put_line
                 ("erreur de saisie, la reponse doit etre 1 pour oui ou 0 pour non");
               new_line;
            when Constraint_Error =>
               skip_line;
               put_line
                 ("erreur de saisie, la reponse doit etre 1 pour oui ou 0 pour non");
               new_line;
         end;
      end loop;
      if rep = 1 then
         loop
            begin
               put
                 ("Quel accompagnateur souhaitez vous ? 0 : technicien 1 : ingénieur");
               new_line;
               get (rep2);
               skip_line;
               exit when rep2 = 0 or rep2 = 1;
               put
                 ("La reponse doit etre 0 pour technicien ou 1 pour ingenieur");
               new_line;
            exception
               when Data_Error =>
                  skip_line;
                  put_line
                    ("erreur de saisie, la reponse doit etre 0 pour technicien ou 1 pour ingenieur");
                  new_line;
               when Constraint_Error =>
                  skip_line;
                  put_line
                    ("erreur de saisie, la reponse doit etre 0 pour technicien ou 1 pour ingenieur");
                  new_line;
            end;
         end loop;
         dem.accompagnement := T_Categorie'val (rep2 + 1);
      else
         dem.accompagnement := Aucun;
      end if;
      loop
         begin
            put
              ("Quel materiel va être loué ? 0 : camera 1 : son 2 : sono 3 : projection 4 : lumiere");
            new_line;
            get (rep3);
            skip_line;
            exit when rep3 >= 0 and rep3 <= 4;
            put
              ("La reponse doit etre : 0 : camera 1 : son 2 : sono 3 : projection 4 : lumiere");
            new_line;
         exception
            when Data_Error =>
               skip_line;
               put_line
                 ("erreur de saisie, il faut  0 : camera 1 : son 2 : sono 3 : projection 4 : lumiere");
               new_line;
            when Constraint_Error =>
               skip_line;
               put_line
                 ("erreur de saisie, il faut  0 : camera 1 : son 2 : sono 3 : projection 4 : lumiere");
               new_line;
         end;
      end loop;
      dem.materiel := T_cate_materiel'val (rep3);
      dem.numero := id_demande;
      id_demande := id_demande + 1;
      enfiler (D, dem);
      Put ("La demande est enregistree et elle est mise en attente");
      new_line;
   end nv_demande;
   procedure visu_demande (D : in T_file_demande) is
      tmp : T_pt_demande := D.tete;
   begin
      while tmp /= null loop
         Put ("numero de la demande : ");
         Put (tmp.demande.numero, 0);
         new_line;
         Put ("nom du client : ");
         Affiche (tmp.demande.id_client.Id.id_Nom);
         new_line;
         Put ("prenom : ");
         Affiche (tmp.demande.id_client.ID.id_Prenom);
         New_Line;
         put ("duree de location : ");
         Put (tmp.demande.duree, 0);
         new_line;
         Put ("date de la demande : ");
         Affichage_Date (tmp.demande.date);
         Put ("accompagnement : ");
         case tmp.demande.accompagnement is
            when technicien =>
               Put ("technicien");
            when ingenieur  =>
               Put ("ingenieur");
            when aucun      =>
               Put ("aucun");
         end case;
         New_Line;
         Put ("materiel loue : ");
         case tmp.demande.materiel is
            when camera     =>
               Put ("camera");
            when son        =>
               Put ("son");
            when sono       =>
               Put ("sono");
            when projection =>
               Put ("projection");
            when lumiere    =>
               Put ("lumiere");
         end case;
         New_Line;
         tmp := tmp.suiv;
         new_line;
      end loop;
   end visu_demande;
   procedure supp_dem_id (D : in out T_file_demande) is
      id_sup : integer;
      ok     : Boolean;
   begin
      if D.tete = null then
         Put_line ("il n'y a aucune demande donc pas de suppression possible");
         return;
      end if;
      loop
         begin
            put ("quel est le numero de la demande a supprimer ?");
            get (id_sup);
            skip_line;
            exit when id_sup > 0;
            put ("le numero de la demande doit etre superieur a 0");
            new_line;
         exception
            when Data_Error =>
               skip_line;
               put_line ("erreur de saisie, il faut un nombre superieur a 0");
               new_line;
            when Constraint_Error =>
               skip_line;
               put_line ("erreur de saisie, il faut un nombre superieur a 0");
               new_line;
         end;
      end loop;
      defiler (D, id_sup, ok);
      if ok then
         Put ("demande supprimee");
      else
         Put ("aucune demande ne correspond a ce numero");
      end if;
   end supp_dem_id;
   procedure user_story_demande (D : in out T_file_demande) is
      dem : T_demande;
   begin
      dem.numero := 2;
      dem.id_client.id.id_Nom := ("Personne                      ", 8);
      dem.id_client.id.id_Prenom := ("Paul                          ", 4);
      dem.id_client.Nb_Loc := 0;
      dem.id_client.Fact := 0;
      dem.id_client.Mont := 0;
      dem.duree := 4;
      dem.date := (19, 4, 2026);
      dem.accompagnement := Aucun;
      dem.materiel := son;
      enfiler (D, dem);
      dem.numero := 4;
      dem.id_client.id.id_Nom := ("Romeo                         ", 5);
      dem.id_client.id.id_Prenom := ("Juliette                      ", 8);
      dem.id_client.Nb_Loc := 0;
      dem.id_client.Fact := 0;
      dem.id_client.Mont := 0;
      dem.duree := 2;
      dem.date := (20, 4, 2026);
      dem.accompagnement := Ingenieur;
      dem.materiel := camera;
      enfiler (D, dem);
      dem.numero := 5;
      dem.id_client.id.id_Nom := ("Tigresse                      ", 8);
      dem.id_client.id.id_Prenom := ("Lily                          ", 4);
      dem.id_client.Nb_Loc := 0;
      dem.id_client.Fact := 0;
      dem.id_client.Mont := 0;
      dem.duree := 3;
      dem.date := (20, 4, 2026);
      dem.accompagnement := Ingenieur;
      dem.materiel := camera;
      enfiler (D, dem);
      dem.numero := 8;
      dem.id_client.id.id_Nom := ("Dubois                        ", 6);
      dem.id_client.id.id_Prenom := ("Josette                       ", 7);
      dem.id_client.Nb_Loc := 0;
      dem.id_client.Fact := 0;
      dem.id_client.Mont := 0;
      dem.duree := 2;
      dem.date := (21, 4, 2026);
      dem.accompagnement := Technicien;
      dem.materiel := lumiere;
      enfiler (D, dem);
      dem.numero := 9;
      dem.id_client.id.id_Nom := ("Tigresse                      ", 8);
      dem.id_client.id.id_Prenom := ("Lily                          ", 4);
      dem.id_client.Nb_Loc := 0;
      dem.id_client.Fact := 0;
      dem.id_client.Mont := 0;
      dem.duree := 4;
      dem.date := (21, 4, 2026);
      dem.accompagnement := Technicien;
      dem.materiel := lumiere;
      enfiler (D, dem);
      dem.numero := 10;
      dem.id_client.id.id_Nom := ("Rebel                         ", 5);
      dem.id_client.id.id_Prenom := ("Alicia                        ", 6);
      dem.id_client.Nb_Loc := 0;
      dem.id_client.Fact := 0;
      dem.id_client.Mont := 0;
      dem.duree := 2;
      dem.date := (21, 4, 2026);
      dem.accompagnement := Ingenieur;
      dem.materiel := son;
      enfiler (D, dem);
   end user_story_demande;
end Gestion_Demande;

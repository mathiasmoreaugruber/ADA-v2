with Ada.Text_IO, Ada.Integer_Text_IO; use Ada.Text_IO, Ada.Integer_Text_IO;
package body Gestion_Location is
   function Prix_Materiel (Mat : T_Cate_Materiel) return Integer is
   begin
      case Mat is
         when camera     =>
            return 412;
         when Son        =>
            return 335;
         when Sono       =>
            return 125;
         when Projection =>
            return 120;
         when lumiere    =>
            return 110;
      end case;
   end Prix_Materiel;
   function Prix_Employe (Acc : T_Categorie) return Integer is
   begin
      case Acc is
         when Technicien =>
            return 140;
         when Ingenieur  =>
            return 230;
         when Aucun      =>
            return 0;
      end case;
   end Prix_Employe;
   function Calcul_Prix
     (Duree : in Integer; Mat : in T_Cate_Materiel; Acc : in T_Categorie)
      return Integer
   is
      Prix : Integer;
   begin
      Prix := Duree * (Prix_Materiel (Mat) + Prix_Employe (Acc));
      if Duree >= 8 then
         Prix := Prix - Prix / 20;
      end if;
      return Prix;
   end Calcul_Prix;
   function Calcul_Fin (Debut : T_Date; Duree : Integer) return T_Date is
      D : T_Date := Debut;
      N : Integer := Duree - 1;
   begin
      while N > 0 loop
         Lendemain (D);
         N := N - 1;
      end loop;
      return D;
   end Calcul_Fin;
   procedure Creer_Location
     (D        : in T_Demande;
      L        : out T_Location;
      Date     : in T_Date;
      Tete_Mat : in T_Pt;
      Tete_Emp : in T_Ptr_Employe)
   is
      Pack : T_Pt;
      Emp  : T_Ptr_Employe;
   begin
      L.N := D.numero;
      L.Id_Client := D.id_client.id;
      L.Duree := D.duree;
      L.Debut := Date;
      L.Fin := Calcul_Fin (Date, D.duree);
      L.Attente := Difference_Jours (D.Date, Date) - 1;
      L.Accomp := D.accompagnement;
      if D.accompagnement /= Aucun then
         Emp := Cherche_Dispo (Tete_Emp, D.accompagnement);
         L.Id_Employe := Emp.Val.ID;
         Emp.Val.Statut := En_Prestation;
      end if;
      Pack := Cherche_Meilleur_Pack (Tete_Mat, D.materiel);
      L.Id_Materiel := Pack.materiel.id_materiel;
      L.Nature_Materiel := D.materiel;
      Pack.Materiel.Dispo := False;
   end Creer_Location;
   procedure Ajout_Location
     (L : in T_Location; Tete : in out T_Pointeur_Location) is
   begin
      Tete := new T_Cellule_Location'(L, Tete);
   end Ajout_Location;
   procedure Visualisation_Location (L : in T_Location) is
   begin
      Put ("Identifiant     : ");
      Put (L.N, 1);
      New_Line;
      Put ("Client          : ");
      Affiche (L.Id_Client.id_Nom);
      Put (" ");
      Affiche (L.Id_Client.id_Prenom);
      New_Line;
      Put ("Duree           : ");
      Put (L.Duree, 1);
      Put_Line (" jours");
      Put ("Debut           : ");
      Affichage_Date (L.Debut);
      Put ("Fin             : ");
      Affichage_Date (L.Fin);
      Put ("Attente         : ");
      Put (L.Attente, 1);
      Put_Line (" jours");
      if L.Accomp /= Aucun then
         Put ("Accompagnement  : ");
         if L.Accomp = Technicien then
            Put ("Technicien");
         else
            Put ("Ingenieur");
         end if;
         Put (" - ");
         Affiche (L.Id_Employe.id_Nom);
         Put (" ");
         Affiche (L.Id_Employe.id_Prenom);
         New_Line;
      else
         Put_Line ("Accompagnement  : Aucun");
      end if;
      Put ("Pack n°         : ");
      Put (L.Id_Materiel, 1);
      New_Line;
      Put ("Materiel        : ");
      case L.Nature_Materiel is
         when camera     =>
            Put_Line ("Cameras");
         when Son        =>
            Put_Line ("Prise de son");
         when Sono       =>
            Put_Line ("Sono");
         when Projection =>
            Put_Line ("Projection");
         when lumiere    =>
            Put_Line ("Lumieres");
      end case;
      Put_Line
        ("------------------------------------------------------------");
   end Visualisation_Location;
   procedure Visualisation_Locations (Tete : in T_Pointeur_Location) is
      P : T_Pointeur_Location := Tete;
   begin
      if P = NULL then
         Put_Line ("Aucune location.");
         return;
      end if;
      while P /= NULL loop
         Visualisation_Location (P.Val);
         P := P.Suiv;
      end loop;
   end Visualisation_Locations;
   procedure Visu_Locations_En_Cours
     (Tete : in T_Pointeur_Location; D : in T_Date)
   is
      P      : T_Pointeur_Location := Tete;
      Trouve : Boolean := False;
   begin
      while P /= NULL loop
         if Difference_Jours (D, P.Val.Fin) >= 0 then
            Visualisation_Location (P.Val);
            Trouve := True;
         end if;
         P := P.Suiv;
      end loop;
      if not Trouve then
         Put_Line ("Aucune location en cours.");
      end if;
   end Visu_Locations_En_Cours;
   procedure Visu_Locations_Archivees
     (Tete : in T_Pointeur_Location; D : in T_Date)
   is
      P      : T_Pointeur_Location := Tete;
      Trouve : Boolean := False;
   begin
      while P /= NULL loop
         if Difference_Jours (D, P.Val.Fin) < 0 then
            Visualisation_Location (P.Val);
            Trouve := True;
         end if;
         P := P.Suiv;
      end loop;
      if not Trouve then
         Put_Line ("Aucune location archivee.");
      end if;
   end Visu_Locations_Archivees;
   procedure Visu_Locations_Employe
     (Tete : in T_Pointeur_Location; Id : in T_Id; D : in T_Date)
   is
      P      : T_Pointeur_Location := Tete;
      MN, MP : Boolean;
      Cours  : Boolean := False;
      Passe  : Boolean := False;
   begin
      Put_Line ("Prestation en cours :");
      while P /= NULL loop
         if P.Val.Accomp /= Aucun then
            Identique (P.Val.Id_Employe.id_Nom, Id.id_Nom, MN);
            Identique (P.Val.Id_Employe.id_Prenom, Id.id_Prenom, MP);
            if MN and MP then
               if Difference_Jours (D, P.Val.Fin) >= 0 then
                  Visualisation_Location (P.Val);
                  Cours := True;
               end if;
            end if;
         end if;
         P := P.Suiv;
      end loop;
      if not Cours then
         Put_Line ("Aucune prestation en cours.");
      end if;
      Put_Line ("Prestations passees :");
      P := Tete;
      while P /= NULL loop
         if P.Val.Accomp /= Aucun then
            Identique (P.Val.Id_Employe.id_Nom, Id.id_Nom, MN);
            Identique (P.Val.Id_Employe.id_Prenom, Id.id_Prenom, MP);
            if MN and MP then
               if Difference_Jours (D, P.Val.Fin) < 0 then
                  Visualisation_Location (P.Val);
                  Passe := True;
               end if;
            end if;
         end if;
         P := P.Suiv;
      end loop;
      if not Passe then
         Put_Line ("Aucune prestation passee.");
      end if;
   end Visu_Locations_Employe;
   procedure Visu_Locations_Client
     (Tete : in T_Pointeur_Location; Id : in T_Id; D : in T_Date)
   is
      P      : T_Pointeur_Location := Tete;
      MN, MP : Boolean;
      Cours  : Boolean := False;
      Passe  : Boolean := False;
   begin
      Put_Line ("Locations en cours :");
      while P /= NULL loop
         Identique (P.Val.Id_Client.id_Nom, Id.id_Nom, MN);
         Identique (P.Val.Id_Client.id_Prenom, Id.id_Prenom, MP);
         if MN and MP then
            if Difference_Jours (D, P.Val.Fin) >= 0 then
               Visualisation_Location (P.Val);
               Cours := True;
            end if;
         end if;
         P := P.Suiv;
      end loop;
      if not Cours then
         Put_Line ("Aucune location en cours.");
      end if;
      Put_Line ("Locations passees :");
      P := Tete;
      while P /= NULL loop
         Identique (P.Val.Id_Client.id_Nom, Id.id_Nom, MN);
         Identique (P.Val.Id_Client.id_Prenom, Id.id_Prenom, MP);
         if MN and MP then
            if Difference_Jours (D, P.Val.Fin) < 0 then
               Visualisation_Location (P.Val);
               Passe := True;
            end if;
         end if;
         P := P.Suiv;
      end loop;
      if not Passe then
         Put_Line ("Aucune location passee.");
      end if;
   end Visu_Locations_Client;
   procedure Traiter_Fins
     (Tete_En_Cours : in out T_Pointeur_Location;
      Tete_Archive  : in out T_Pointeur_Location;
      Abr           : in out T_ABR_Clients;
      Tete_Mat      : in out T_Pt;
      Tete_Emp      : in out T_Ptr_Employe;
      Date_Hier     : in T_Date)
   is
      P      : T_Pointeur_Location := Tete_En_Cours;
      Prec   : T_Pointeur_Location := NULL;
      Suiv   : T_Pointeur_Location;
      Noeud  : T_ABR_Clients;
      Prix   : Integer;
      MN, MP : Boolean;
   begin
      while P /= NULL loop
         Suiv := P.Suiv;
         if Difference_Jours (Date_Hier, P.Val.Fin) = 0 then
            Prix :=
              Calcul_Prix (P.Val.Duree, P.Val.Nature_Materiel, P.Val.Accomp);
            Noeud := Cherche_Client (P.Val.Id_Client, Abr);
            if Noeud /= NULL then
               Noeud.Client.Nb_Loc := Noeud.Client.Nb_Loc + 1;
               Noeud.Client.Fact := Noeud.Client.Fact + Prix;
               Put ("Facture imputee au client ");
               Affiche (P.Val.Id_Client.id_Nom);
               Put (" ");
               Affiche (P.Val.Id_Client.id_Prenom);
               Put (" : ");
               Put (Prix, 0);
               Put_Line (" euros.");
            end if;
            declare
               Pack_Ptr : T_Pt := Tete_Mat;
            begin
               while Pack_Ptr /= NULL loop
                  if Pack_Ptr.materiel.id_materiel = P.Val.Id_Materiel then
                     Rendre_Pack (Pack_Ptr, P.Val.Duree);
                     exit;
                  end if;
                  Pack_Ptr := Pack_Ptr.Suiv;
               end loop;
            end;
            if P.Val.Accomp /= Aucun then
               Fin_Prestation
                 (Tete_Emp,
                  P.Val.Id_Employe.id_Nom,
                  P.Val.Accomp,
                  P.Val.Duree);
            end if;
            if Prec = NULL then
               Tete_En_Cours := Suiv;
            else
               Prec.Suiv := Suiv;
            end if;
            P.Suiv := Tete_Archive;
            Tete_Archive := P;
            Put ("Location ");
            Put (P.Val.N, 0);
            Put_Line (" archivee.");
         else
            Prec := P;
         end if;
         P := Suiv;
      end loop;
   end Traiter_Fins;
   procedure user_story_location (Tete : in out T_Pointeur_Location) is
      L : T_Location;
   begin
      L.N := 7;
      L.Id_Client.id_Nom := ("Bartok                        ", 6);
      L.Id_Client.id_Prenom := ("Belle                         ", 5);
      L.Duree := 2;
      L.Debut := (21, 4, 2026);
      L.Fin := (22, 4, 2026);
      L.Attente := 0;
      L.Accomp := Technicien;
      L.Id_Employe.id_Nom := ("Guerre                        ", 6);
      L.Id_Employe.id_Prenom := ("Martin                        ", 6);
      L.Id_Materiel := 7;
      L.Nature_Materiel := sono;
      Ajout_Location (L, Tete);
      L.N := 1;
      L.Id_Client.id_Nom := ("Mouton                        ", 6);
      L.Id_Client.id_Prenom := ("Aline                         ", 5);
      L.Duree := 6;
      L.Debut := (17, 4, 2026);
      L.Fin := (22, 4, 2026);
      L.Attente := 0;
      L.Accomp := Ingenieur;
      L.Id_Employe.id_Nom := ("Aurele                        ", 6);
      L.Id_Employe.id_Prenom := ("Marc                          ", 4);
      L.Id_Materiel := 2;
      L.Nature_Materiel := lumiere;
      Ajout_Location (L, Tete);
      L.N := 6;
      L.Id_Client.id_Nom := ("Arc                           ", 3);
      L.Id_Client.id_Prenom := ("Jean                          ", 4);
      L.Duree := 10;
      L.Debut := (14, 4, 2026);
      L.Fin := (23, 4, 2026);
      L.Attente := 0;
      L.Accomp := Aucun;
      L.Id_Employe.id_Nom := ("                              ", 0);
      L.Id_Employe.id_Prenom := ("                              ", 0);
      L.Id_Materiel := 8;
      L.Nature_Materiel := camera;
      Ajout_Location (L, Tete);
      L.N := 3;
      L.Id_Client.id_Nom := ("Belle                         ", 5);
      L.Id_Client.id_Prenom := ("Lucie                         ", 5);
      L.Duree := 5;
      L.Debut := (20, 4, 2026);
      L.Fin := (24, 4, 2026);
      L.Attente := 0;
      L.Accomp := Ingenieur;
      L.Id_Employe.id_Nom := ("Galvin                        ", 6);
      L.Id_Employe.id_Prenom := ("Luc                           ", 3);
      L.Id_Materiel := 9;
      L.Nature_Materiel := lumiere;
      Ajout_Location (L, Tete);
   end user_story_location;
end Gestion_Location;

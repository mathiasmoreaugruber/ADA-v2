WITH Ada.Text_IO, Ada.Integer_Text_IO;
USE  Ada.Text_IO, Ada.Integer_Text_IO;
WITH Gestion_Identites;
USE  Gestion_Identites;
WITH Gestion_Date;
USE  Gestion_Date;
WITH Gestion_Materiel;
USE  Gestion_Materiel;
WITH Gestion_Client;
USE  Gestion_Client;
WITH Gestion_Personnel;
USE  Gestion_Personnel;
WITH Gestion_Demande;
USE  Gestion_Demande;
WITH Gestion_Location;
USE  Gestion_Location;
PROCEDURE Main IS
   Date_Courante  : T_Date    := (22, 4, 2026);
   Tete_Mat       : T_Pt                := NULL;
   Abr_Clients    : T_ABR_Clients       := NULL;
   Tete_Emp       : T_Ptr_Employe       := NULL;
   File_Dem       : T_File_Demande;
   Tete_Loc       : T_Pointeur_Location := NULL;
   Tete_Archive   : T_Pointeur_Location := NULL;
   Next_Id_Pack   : Integer := 10;
   Next_Id_Dem    : Integer := 11;
   FUNCTION Lire_Entier (Min, Max : Integer) RETURN Integer IS
      N : Integer;
   BEGIN
      LOOP
         BEGIN
            Get (N);
            Skip_Line;
            IF N >= Min AND THEN N <= Max THEN
               RETURN N;
            END IF;
            Put ("Valeur hors bornes (");
            Put (Min, 1); Put (" .. "); Put (Max, 1);
            Put_Line ("), reessayez :");
         EXCEPTION
            WHEN Data_Error =>
               Skip_Line;
               Put_Line ("Saisie invalide (entier attendu), reessayez :");
            WHEN Constraint_Error =>
               Skip_Line;
               Put_Line ("Valeur trop grande, reessayez :");
         END;
      END LOOP;
   END Lire_Entier;
   PROCEDURE Affiche_Entete IS
   BEGIN
      New_Line;
      Put_Line ("============================================================");
      Put ("  Prestations Audiovisuelles  -  Date du jour : ");
      Affichage_Date (Date_Courante);
      Put_Line ("============================================================");
   END Affiche_Entete;
   PROCEDURE Supp_Packs_Indic (Tete : IN OUT T_Pt) IS
      P    : T_Pt;
      Prec : T_Pt := NULL;
   BEGIN
      P := Tete;
      WHILE P /= NULL LOOP
         IF P.Materiel.Indic_Sup AND THEN P.Materiel.Dispo THEN
            Put ("Pack numero ");
            Put (P.Materiel.Id_Materiel, 1);
            Put_Line (" supprime (suppression differee).");
            IF Prec = NULL THEN
               Tete := P.Suiv;
               Liberer (P);
               P := Tete;
            ELSE
               Prec.Suiv := P.Suiv;
               DECLARE Tmp : T_Pt := P; BEGIN
                  P := P.Suiv;
                  Liberer (Tmp);
               END;
            END IF;
         ELSE
            Prec := P;
            P := P.Suiv;
         END IF;
      END LOOP;
   END Supp_Packs_Indic;
   PROCEDURE Traiter_Demandes IS
      Ptr  : T_Pt_Demande;
      Pack : T_Pt;
      Emp  : T_Ptr_Employe;
      Loc  : T_Location;
      Ok   : Boolean;
   BEGIN
      Ptr := File_Dem.Tete;
      WHILE Ptr /= NULL LOOP
         DECLARE
            D    : T_Demande    RENAMES Ptr.Demande;
            Suiv : T_Pt_Demande := Ptr.Suiv;
         BEGIN
            Pack := Cherche_Meilleur_Pack (Tete_Mat, D.Materiel);
            IF Pack /= NULL THEN
               IF D.Accompagnement = Aucun THEN
                  Emp := NULL;
                  Ok  := True;
               ELSE
                  Emp := Cherche_Dispo (Tete_Emp, D.Accompagnement);
                  Ok  := (Emp /= NULL);
               END IF;
               IF Ok THEN
                  Creer_Location (D, Loc, Date_Courante, Tete_Mat, Tete_Emp);
                  Ajout_Location (Loc, Tete_Loc);
                  DECLARE
                     Noeud : T_ABR_Clients :=
                       Cherche_Client (D.Id_Client.Id, Abr_Clients);
                  BEGIN
                     IF Noeud = NULL THEN
                        Nv_Client (D.Id_Client, Abr_Clients);
                     END IF;
                  END;
                  Put ("Demande ");
                  Put (D.Numero, 1);
                  Put (" satisfaite  ->  location creee pour ");
                  Affiche (D.Id_Client.Id.Id_Nom);
                  Put (" ");
                  Affiche (D.Id_Client.Id.Id_Prenom);
                  New_Line;
                  Defiler (File_Dem, D.Numero, Ok);
               END IF;
            END IF;
         END;
         Ptr := Ptr.Suiv;
      END LOOP;
   END Traiter_Demandes;
   PROCEDURE Passer_Au_Lendemain IS
      Hier : T_Date := Date_Courante;
   BEGIN
      Lendemain (Date_Courante);
      Put ("--- Passage au ");
      Affichage_Date (Date_Courante);
      Put_Line ("--- Traitement des fins de location ---");
      Traiter_Fins (Tete_Loc, Tete_Archive, Abr_Clients,
                    Tete_Mat, Tete_Emp, Hier);
      Supp_Departs (Tete_Emp);
      Supp_Packs_Indic (Tete_Mat);
      Put_Line ("--- Traitement des demandes en attente ---");
      Traiter_Demandes;
      Put_Line ("--- Fin du passage au lendemain ---");
   END Passer_Au_Lendemain;
   PROCEDURE Charger_Donnees IS
      FUNCTION Mk_Nom (S : String; K : Integer) RETURN T_Nom IS
         N : T_Nom;
      BEGIN
         N.Nom := (OTHERS => ' ');
         N.Nom (1 .. K) := S (S'First .. S'First + K - 1);
         N.Knom := K;
         RETURN N;
      END Mk_Nom;
      FUNCTION Mk_Id (Nom : String; Kn : Integer;
                      Pre : String; Kp : Integer) RETURN T_Id IS
         I : T_Id;
      BEGIN
         I.Id_Nom    := Mk_Nom (Nom, Kn);
         I.Id_Prenom := Mk_Nom (Pre, Kp);
         RETURN I;
      END Mk_Id;
      FUNCTION Mk_Client (Nom : String; Kn : Integer;
                          Pre : String; Kp : Integer) RETURN T_Client IS
         C : T_Client;
      BEGIN
         C.Id     := Mk_Id (Nom, Kn, Pre, Kp);
         C.Nb_Loc := 0;
         C.Fact   := 0;
         C.Mont   := 0;
         RETURN C;
      END Mk_Client;
      E  : T_Employe;
      Ok : Boolean;
   BEGIN
      Put_Line ("Chargement des donnees initiales...");
      User_Story_Materiel (Tete_Mat);
      E.ID              := Mk_Id ("Galvin", 6, "Luc", 3);
      E.Categorie       := Ingenieur;
      E.Nb_J_Prestation := 0;
      E.Statut          := En_Prestation;
      E.Depart          := False;
      Ajout_Emp (E, Tete_Emp, Ok);
      E.ID              := Mk_Id ("Aurele", 6, "Marc", 4);
      E.Categorie       := Ingenieur;
      E.Nb_J_Prestation := 0;
      E.Statut          := En_Prestation;
      E.Depart          := False;
      Ajout_Emp (E, Tete_Emp, Ok);
      E.ID              := Mk_Id ("Guerre", 6, "Martin", 6);
      E.Categorie       := Technicien;
      E.Nb_J_Prestation := 0;
      E.Statut          := En_Prestation;
      E.Depart          := False;
      Ajout_Emp (E, Tete_Emp, Ok);
      E.ID              := Mk_Id ("Fer", 3, "Lucie", 5);
      E.Categorie       := Technicien;
      E.Nb_J_Prestation := 0;
      E.Statut          := Disponible;
      E.Depart          := False;
      Ajout_Emp (E, Tete_Emp, Ok);
      User_Story_Demande (File_Dem);
      Next_Id_Dem := 11;
      Nv_Client (Mk_Client ("Mouton",  6, "Aline",   5), Abr_Clients);
      Nv_Client (Mk_Client ("Belle",   5, "Lucie",   5), Abr_Clients);
      Nv_Client (Mk_Client ("Romeo",   5, "Juliette",8), Abr_Clients);
      Nv_Client (Mk_Client ("Personne",8, "Paul",    4), Abr_Clients);
      Nv_Client (Mk_Client ("Tigresse",8, "Lily",    4), Abr_Clients);
      Nv_Client (Mk_Client ("Arc",     3, "Jean",    4), Abr_Clients);
      Nv_Client (Mk_Client ("Rebel",   5, "Alicia",  6), Abr_Clients);
      Nv_Client (Mk_Client ("Dubois",  6, "Josette", 7), Abr_Clients);
      Nv_Client (Mk_Client ("Bartok",  6, "Belle",   5), Abr_Clients);
      User_Story_Location (Tete_Loc);
      Put_Line ("Donnees chargees.");
      New_Line;
   END Charger_Donnees;
   PROCEDURE Affiche_Menu IS
   BEGIN
      New_Line;
      Put_Line ("--- MENU PRINCIPAL ---");
      Put_Line (" 1  Visualiser le materiel (tous les packs)");
      Put_Line (" 2  Visualiser les packs disponibles");
      Put_Line (" 3  Ajouter un nouveau pack");
      Put_Line (" 4  Supprimer un pack (par numero et categorie)");
      Put_Line (" 5  Supprimer les packs mis en service avant une date");
      Put_Line ("---");
      Put_Line (" 6  Visualiser le personnel");
      Put_Line (" 7  Visualiser les infos d'un employe");
      Put_Line (" 8  Ajouter un employe");
      Put_Line (" 9  Enregistrer la demande de depart d'un employe");
      Put_Line ("---");
      Put_Line ("10  Visualiser la clientele (ABR prefixe)");
      Put_Line ("11  Enregistrer un reglement client");
      Put_Line ("---");
      Put_Line ("12  Visualiser les demandes en attente");
      Put_Line ("13  Enregistrer une nouvelle demande de location");
      Put_Line ("14  Supprimer une demande de location");
      Put_Line ("---");
      Put_Line ("15  Visualiser les locations en cours");
      Put_Line ("16  Visualiser les locations archivees");
      Put_Line ("17  Locations (en cours et passees) par employe");
      Put_Line ("18  Locations (en cours et passees) par client");
      Put_Line ("---");
      Put_Line ("19  Passer au lendemain");
      Put_Line ("---");
      Put_Line (" 0  Quitter");
      Put ("Votre choix : ");
   END Affiche_Menu;
   PROCEDURE Action_Ajouter_Pack IS
      M : T_Materiel;
   BEGIN
      Nv_Pack (M, Tete_Mat, Next_Id_Pack);
   END Action_Ajouter_Pack;
   PROCEDURE Action_Supprimer_Pack_Idcat IS
   BEGIN
      Sup_Pack_Idcat (Tete_Mat);
   END Action_Supprimer_Pack_Idcat;
   PROCEDURE Action_Supprimer_Pack_Date IS
   BEGIN
      Sup_Pack_Date (Tete_Mat);
   END Action_Supprimer_Pack_Date;
   PROCEDURE Action_Info_Employe IS
      N   : T_Nom;
      Rep : Character;
      Cat : T_Categorie;
      Ok  : Boolean;
   BEGIN
      Put ("Nom de l'employe : ");
      Saisie_N (N);
      LOOP
         Put ("Categorie (T=Technicien / I=Ingenieur) : ");
         DECLARE Ligne : String (1 .. 10); Last : Integer; BEGIN
            Get_Line (Ligne, Last);
            IF Last >= 1 THEN Rep := Ligne (1); ELSE Rep := ' '; END IF;
         END;
         EXIT WHEN Rep = 'T' OR Rep = 't' OR Rep = 'I' OR Rep = 'i';
         Put_Line ("Saisie invalide.");
      END LOOP;
      IF Rep = 'T' OR Rep = 't' THEN
         Cat := Technicien;
      ELSE
         Cat := Ingenieur;
      END IF;
      Vis_Employe_D (Tete_Emp, N, Cat, Ok);
   END Action_Info_Employe;
   PROCEDURE Action_Ajouter_Employe IS
      E  : T_Employe;
      Ok : Boolean;
   BEGIN
      Saisie_Emp (E);
      Ajout_Emp (E, Tete_Emp, Ok);
      IF Ok THEN
         Put_Line ("Employe ajoute avec succes.");
      END IF;
   END Action_Ajouter_Employe;
   PROCEDURE Action_Depart_Employe IS
      N   : T_Nom;
      Rep : Character;
      Cat : T_Categorie;
      Ok  : Boolean;
   BEGIN
      Put ("Nom de l'employe : ");
      Saisie_N (N);
      LOOP
         Put ("Categorie (T=Technicien / I=Ingenieur) : ");
         DECLARE Ligne : String (1 .. 10); Last : Integer; BEGIN
            Get_Line (Ligne, Last);
            IF Last >= 1 THEN Rep := Ligne (1); ELSE Rep := ' '; END IF;
         END;
         EXIT WHEN Rep = 'T' OR Rep = 't' OR Rep = 'I' OR Rep = 'i';
         Put_Line ("Saisie invalide.");
      END LOOP;
      IF Rep = 'T' OR Rep = 't' THEN
         Cat := Technicien;
      ELSE
         Cat := Ingenieur;
      END IF;
      Supp_Emp (Tete_Emp, N, Cat, Ok);
      IF NOT Ok THEN
         Put_Line ("Employe non trouve.");
      END IF;
   END Action_Depart_Employe;
   PROCEDURE Action_Reglement IS
      Id      : T_Id;
      Montant : Integer;
      Noeud   : T_ABR_Clients;
   BEGIN
      Put_Line ("Identite du client :");
      Saisie_Identite (Id);
      Noeud := Cherche_Client (Id, Abr_Clients);
      IF Noeud = NULL THEN
         Put_Line ("Client non trouve.");
         RETURN;
      END IF;
      IF Noeud.Client.Fact = 0 THEN
         Put_Line ("Ce client n'a pas de facture en instance.");
         RETURN;
      END IF;
      Put ("Facture en instance : ");
      Put (Noeud.Client.Fact, 1);
      Put_Line (" euros.");
      Put ("Montant a regler (1 .. ");
      Put (Noeud.Client.Fact, 1);
      Put (") : ");
      Montant := Lire_Entier (1, Noeud.Client.Fact);
      Reglement (Id, Montant, Abr_Clients);
   END Action_Reglement;
   PROCEDURE Action_Nouvelle_Demande IS
   BEGIN
      Nv_Demande (File_Dem, Abr_Clients, Date_Courante, Next_Id_Dem);
   END Action_Nouvelle_Demande;
   PROCEDURE Action_Supprimer_Demande IS
   BEGIN
      Supp_Dem_Id (File_Dem);
   END Action_Supprimer_Demande;
   PROCEDURE Action_Loc_Employe IS
      Id     : T_Id;
      P      : T_Pointeur_Location;
      MN, MP : Boolean;
      Cours  : Boolean := False;
      Passe  : Boolean := False;
   BEGIN
      Put_Line ("Identite de l'employe :");
      Saisie_Identite (Id);
      Put_Line ("Prestation en cours :");
      P := Tete_Loc;
      WHILE P /= NULL LOOP
         IF P.Val.Accomp /= Aucun THEN
            Identique (P.Val.Id_Employe.Id_Nom, Id.Id_Nom, MN);
            Identique (P.Val.Id_Employe.Id_Prenom, Id.Id_Prenom, MP);
            IF MN AND MP THEN
               Visualisation_Location (P.Val);
               Cours := True;
            END IF;
         END IF;
         P := P.Suiv;
      END LOOP;
      IF NOT Cours THEN Put_Line ("Aucune prestation en cours."); END IF;
      Put_Line ("Voici ses prestations passees :");
      P := Tete_Archive;
      WHILE P /= NULL LOOP
         IF P.Val.Accomp /= Aucun THEN
            Identique (P.Val.Id_Employe.Id_Nom, Id.Id_Nom, MN);
            Identique (P.Val.Id_Employe.Id_Prenom, Id.Id_Prenom, MP);
            IF MN AND MP THEN
               Visualisation_Location (P.Val);
               Passe := True;
            END IF;
         END IF;
         P := P.Suiv;
      END LOOP;
      IF NOT Passe THEN Put_Line ("Aucune prestation passee."); END IF;
   END Action_Loc_Employe;
   PROCEDURE Action_Loc_Client IS
      Id     : T_Id;
      P      : T_Pointeur_Location;
      MN, MP : Boolean;
      Cours  : Boolean := False;
      Passe  : Boolean := False;
   BEGIN
      Put_Line ("Identite du client :");
      Saisie_Identite (Id);
      Put_Line ("Location en cours :");
      P := Tete_Loc;
      WHILE P /= NULL LOOP
         Identique (P.Val.Id_Client.Id_Nom, Id.Id_Nom, MN);
         Identique (P.Val.Id_Client.Id_Prenom, Id.Id_Prenom, MP);
         IF MN AND MP THEN
            Visualisation_Location (P.Val);
            Cours := True;
         END IF;
         P := P.Suiv;
      END LOOP;
      IF NOT Cours THEN Put_Line ("Aucune location en cours."); END IF;
      P := Tete_Archive;
      WHILE P /= NULL LOOP
         Identique (P.Val.Id_Client.Id_Nom, Id.Id_Nom, MN);
         Identique (P.Val.Id_Client.Id_Prenom, Id.Id_Prenom, MP);
         IF MN AND MP THEN
            IF NOT Passe THEN Put_Line ("Locations passees :"); END IF;
            Visualisation_Location (P.Val);
            Passe := True;
         END IF;
         P := P.Suiv;
      END LOOP;
      IF NOT Passe THEN Put_Line ("Pas de locations passees."); END IF;
   END Action_Loc_Client;
   Choix : Integer;
BEGIN
   Charger_Donnees;
   LOOP
      Affiche_Entete;
      Affiche_Menu;
      Choix := Lire_Entier (0, 19);
      New_Line;
      CASE Choix IS
         WHEN 0 =>
            Put_Line ("Au revoir !");
            EXIT;
         WHEN 1 =>
            Put_Line ("=== Tous les packs ===");
            IF Tete_Mat = NULL THEN
               Put_Line ("Aucun pack.");
            ELSE
               Visu_Tous_Pack (Tete_Mat);
            END IF;
         WHEN 2 =>
            Put_Line ("=== Packs disponibles ===");
            Visu_Pack_Dispo (Tete_Mat);
         WHEN 3 =>
            Put_Line ("=== Ajout d'un pack ===");
            Action_Ajouter_Pack;
         WHEN 4 =>
            Put_Line ("=== Suppression d'un pack (id + categorie) ===");
            Action_Supprimer_Pack_Idcat;
         WHEN 5 =>
            Put_Line ("=== Suppression des packs avant une date ===");
            Action_Supprimer_Pack_Date;
         WHEN 6 =>
            Put_Line ("=== Personnel ===");
            Vis_Employes (Tete_Emp);
         WHEN 7 =>
            Put_Line ("=== Infos d'un employe ===");
            Action_Info_Employe;
         WHEN 8 =>
            Put_Line ("=== Ajout d'un employe ===");
            Action_Ajouter_Employe;
         WHEN 9 =>
            Put_Line ("=== Demande de depart d'un employe ===");
            Action_Depart_Employe;
         WHEN 10 =>
            Put_Line ("=== Clientele (ordre prefixe) ===");
            IF Abr_Clients = NULL THEN
               Put_Line ("Aucun client.");
            ELSE
               Visu_Clients (Abr_Clients);
            END IF;
         WHEN 11 =>
            Put_Line ("=== Reglement client ===");
            Action_Reglement;
         WHEN 12 =>
            Put_Line ("=== Demandes en attente ===");
            IF File_Dem.Tete = NULL THEN
               Put_Line ("Aucune demande en attente.");
            ELSE
               Visu_Demande (File_Dem);
            END IF;
         WHEN 13 =>
            Put_Line ("=== Nouvelle demande de location ===");
            Action_Nouvelle_Demande;
         WHEN 14 =>
            Put_Line ("=== Suppression d'une demande ===");
            Action_Supprimer_Demande;
         WHEN 15 =>
            Put_Line ("=== Locations en cours ===");
            IF Tete_Loc = NULL THEN
               Put_Line ("Aucune location en cours.");
            ELSE
               Visu_Locations_En_Cours (Tete_Loc, Date_Courante);
            END IF;
         WHEN 16 =>
            Put_Line ("=== Locations archivees ===");
            IF Tete_Archive = NULL THEN
               Put_Line ("Aucune location archivee.");
            ELSE
               Visualisation_Locations (Tete_Archive);
            END IF;
         WHEN 17 =>
            Put_Line ("=== Locations par employe ===");
            Action_Loc_Employe;
         WHEN 18 =>
            Put_Line ("=== Locations par client ===");
            Action_Loc_Client;
         WHEN 19 =>
            Put_Line ("=== Passage au lendemain ===");
            Passer_Au_Lendemain;
         WHEN OTHERS =>
            Put_Line ("Option inconnue.");
      END CASE;
   END LOOP;
END Main;

WITH Ada.Text_IO, Ada.Integer_Text_IO;
USE  Ada.Text_IO, Ada.Integer_Text_IO;
PACKAGE BODY Gestion_Personnel IS
   PROCEDURE Saisie_Emp (E : OUT T_Employe) IS
      Rep : Character;
   BEGIN
      Put("Nom : ");
      Saisie_N(E.ID.id_Nom);
      Put("Prenom : ");
      Saisie_N(E.ID.id_Prenom);
      LOOP
         Put("Categorie (T=Technicien / I=Ingenieur) : ");
         DECLARE Ligne : String(1..10); Last : Integer; BEGIN
            Get_Line(Ligne, Last);
            IF Last >= 1 THEN Rep := Ligne(1); ELSE Rep := ' '; END IF;
         END;
         EXIT WHEN Rep = 'T' OR Rep = 't' OR Rep = 'I' OR Rep = 'i';
         Put_Line("Saisie invalide, reessayez.");
      END LOOP;
      IF Rep = 'T' OR Rep = 't' THEN
         E.Categorie := Technicien;
      ELSE
         E.Categorie := Ingenieur;
      END IF;
      E.Nb_J_Prestation := 0;
      LOOP
         Put("Statut (D=Disponible / P=En prestation) : ");
         DECLARE Ligne : String(1..10); Last : Integer; BEGIN
            Get_Line(Ligne, Last);
            IF Last >= 1 THEN Rep := Ligne(1); ELSE Rep := ' '; END IF;
         END;
         EXIT WHEN Rep = 'D' OR Rep = 'd' OR Rep = 'P' OR Rep = 'p';
         Put_Line("Saisie invalide, reessayez.");
      END LOOP;
      IF Rep = 'D' OR Rep = 'd' THEN
         E.Statut := Disponible;
      ELSE
         E.Statut := En_Prestation;
      END IF;
      E.Depart := False;
   END Saisie_Emp;
   PROCEDURE Ajout_Emp (E : IN T_Employe; Tete : IN OUT T_Ptr_Employe; Ok : OUT Boolean) IS
      P      : T_Ptr_Employe := Tete;
      MN, MP : Boolean;
   BEGIN
      WHILE P /= NULL LOOP
         IF P.Val.Categorie = E.Categorie THEN
            Identique(P.Val.ID.id_Nom,    E.ID.id_Nom,    MN);
            Identique(P.Val.ID.id_Prenom, E.ID.id_Prenom, MP);
            IF MN AND MP THEN
               Put_Line("Erreur : un employe de meme categorie avec la meme identite existe deja.");
               Ok := False;
               RETURN;
            END IF;
         END IF;
         P := P.Suiv;
      END LOOP;
      Tete := NEW T_Cellule_Employe'(E, Tete);
      Ok   := True;
   END Ajout_Emp;
   PROCEDURE Supp_Emp (Tete : IN OUT T_Ptr_Employe; N : IN T_Nom;
                       C : IN T_Categorie; Ok : OUT Boolean) IS
      P    : T_Ptr_Employe := Tete;
      Meme : Boolean;
      function Correspond (Cell : T_Ptr_Employe) return Boolean is
         M : Boolean;
      begin
         if Cell.Val.Categorie /= C then return False; end if;
         Identique(Cell.Val.ID.id_Nom, N, M);
         return M;
      end Correspond;
   BEGIN
      Ok := False;
      IF Tete = NULL THEN
         Put_Line("Employe non trouve.");
         RETURN;
      END IF;
      IF Correspond(Tete) THEN
         IF Tete.Val.Statut = Disponible THEN
            Tete := Tete.Suiv;
            Put_Line("Employe supprime immediatement.");
         ELSE
            Tete.Val.Depart := True;
            Put_Line("Demande de depart enregistree (employe en prestation).");
         END IF;
         Ok := True;
         RETURN;
      END IF;
      WHILE P.Suiv /= NULL LOOP
         IF Correspond(P.Suiv) THEN
            IF P.Suiv.Val.Statut = Disponible THEN
               P.Suiv := P.Suiv.Suiv;
               Put_Line("Employe supprime immediatement.");
            ELSE
               P.Suiv.Val.Depart := True;
               Put_Line("Demande de depart enregistree (employe en prestation).");
            END IF;
            Ok := True;
            RETURN;
         END IF;
         P := P.Suiv;
      END LOOP;
      Put_Line("Employe non trouve.");
   END Supp_Emp;
   PROCEDURE Fin_Prestation (Tete : IN OUT T_Ptr_Employe; N : IN T_Nom;
                              C : IN T_Categorie; Nb_Jours : IN Integer) IS
      P    : T_Ptr_Employe := Tete;
      Meme : Boolean;
      function Correspond (Cell : T_Ptr_Employe) return Boolean is
         M : Boolean;
      begin
         if Cell.Val.Categorie /= C then return False; end if;
         Identique(Cell.Val.ID.id_Nom, N, M);
         return M;
      end Correspond;
      procedure Traite (Cell : T_Ptr_Employe) is
      begin
         Cell.Val.Statut          := Disponible;
         Cell.Val.Nb_J_Prestation := Cell.Val.Nb_J_Prestation + Nb_Jours;
      end Traite;
   BEGIN
      IF Tete = NULL THEN RETURN; END IF;
      IF Correspond(Tete) THEN
         Traite(Tete);
         IF Tete.Val.Depart THEN
            Tete := Tete.Suiv;
            Put_Line("Employe parti apres fin de prestation.");
         END IF;
         RETURN;
      END IF;
      WHILE P.Suiv /= NULL LOOP
         IF Correspond(P.Suiv) THEN
            Traite(P.Suiv);
            IF P.Suiv.Val.Depart THEN
               P.Suiv := P.Suiv.Suiv;
               Put_Line("Employe parti apres fin de prestation.");
            END IF;
            RETURN;
         END IF;
         P := P.Suiv;
      END LOOP;
   END Fin_Prestation;
   PROCEDURE Supp_Departs (Tete : IN OUT T_Ptr_Employe) IS
      P : T_Ptr_Employe;
   BEGIN
      WHILE Tete /= NULL AND THEN Tete.Val.Depart AND THEN Tete.Val.Statut = Disponible LOOP
         Tete := Tete.Suiv;
      END LOOP;
      IF Tete = NULL THEN RETURN; END IF;
      P := Tete;
      WHILE P.Suiv /= NULL LOOP
         IF P.Suiv.Val.Depart AND P.Suiv.Val.Statut = Disponible THEN
            P.Suiv := P.Suiv.Suiv;
         ELSE
            P := P.Suiv;
         END IF;
      END LOOP;
   END Supp_Departs;
   PROCEDURE Vis_Employe (E : IN T_Employe) IS
   BEGIN
      Affi_identite(E.ID);
      IF E.Categorie = Technicien THEN
         Put_Line("Technicien");
      ELSIF E.Categorie = Ingenieur THEN
         Put_Line("Ingenieur");
      ELSE
         Put_Line("Aucun");
      END IF;
      Put("Nombre de jours de prestation realises : ");
      Put(E.Nb_J_Prestation, 1); New_Line;
      IF E.Statut = Disponible THEN
         Put_Line("Disponible");
      ELSE
         Put_Line("Actuellement en prestation");
      END IF;
      IF E.Depart THEN
         Put_Line("A demande son depart de la societe");
      END IF;
   END Vis_Employe;
   PROCEDURE Vis_Employes (Tete : IN T_Ptr_Employe) IS
      P : T_Ptr_Employe := Tete;
   BEGIN
      IF P = NULL THEN
         Put_Line("Aucun employe."); RETURN;
      END IF;
      WHILE P /= NULL LOOP
         Vis_Employe(P.Val); New_Line;
         P := P.Suiv;
      END LOOP;
   END Vis_Employes;
   PROCEDURE Vis_Employe_D (Tete : IN T_Ptr_Employe; N : IN T_Nom;
                             C : IN T_Categorie; Ok : OUT Boolean) IS
      P    : T_Ptr_Employe := Tete;
      Meme : Boolean;
   BEGIN
      Ok := False;
      WHILE P /= NULL LOOP
         IF P.Val.Categorie = C THEN
            Identique(P.Val.ID.id_Nom, N, Meme);
            IF Meme THEN
               Vis_Employe(P.Val);
               Ok := True;
               RETURN;
            END IF;
         END IF;
         P := P.Suiv;
      END LOOP;
      Put_Line("Employe non trouve.");
   END Vis_Employe_D;
   FUNCTION Cherche_Dispo (Tete : IN T_Ptr_Employe; C : IN T_Categorie)
                            RETURN T_Ptr_Employe IS
      P        : T_Ptr_Employe := Tete;
      Meilleur : T_Ptr_Employe := NULL;
   BEGIN
      WHILE P /= NULL LOOP
         IF P.Val.Categorie = C
            AND THEN P.Val.Statut = Disponible
            AND THEN NOT P.Val.Depart
         THEN
            IF Meilleur = NULL
               OR ELSE P.Val.Nb_J_Prestation < Meilleur.Val.Nb_J_Prestation
            THEN
               Meilleur := P;
            END IF;
         END IF;
         P := P.Suiv;
      END LOOP;
      RETURN Meilleur;
   END Cherche_Dispo;
END Gestion_Personnel;

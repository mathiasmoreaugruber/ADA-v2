WITH Gestion_Identites, Ada.Text_IO, Ada.Integer_Text_IO;
USE  Gestion_Identites, Ada.Text_IO, Ada.Integer_Text_IO;
PACKAGE BODY Gestion_Client IS
   PROCEDURE Visualise (C : IN T_Client) IS
   BEGIN
      Affi_identite(C.id);
      Put("Nombre de locations terminees : "); Put(C.Nb_Loc); New_Line;
      Put("Facture en attente (euros)     : "); Put(C.Fact);  New_Line;
      Put("Montant deja regle (euros)     : "); Put(C.Mont);  New_Line;
   END Visualise;
   PROCEDURE Visu_Clients (A : IN T_ABR_Clients) IS
   BEGIN
      IF A /= NULL THEN
         Visualise(A.Client); New_Line;
         Visu_Clients(A.Fg);
         Visu_Clients(A.Fd);
      END IF;
   END Visu_Clients;
   PROCEDURE Nv_Client (C : IN T_Client; A : IN OUT T_ABR_Clients) IS
      Sup : Boolean;
   BEGIN
      IF A = NULL THEN
         A := NEW T_Noeud_Client'(C, NULL, NULL);
      ELSE
         Comp_id(C.id, A.Client.id, Sup);
         IF Sup THEN
            Nv_Client(C, A.Fd);
         ELSE
            Nv_Client(C, A.Fg);
         END IF;
      END IF;
   END Nv_Client;
   FUNCTION Saisie_Client RETURN T_Client IS
      C : T_Client;
   BEGIN
      Saisie_identite(C.id);
      C.Nb_Loc := 0;
      C.Fact   := 0;
      C.Mont   := 0;
      RETURN C;
   END Saisie_Client;
   PROCEDURE Recherche (I : IN T_id; A : IN T_ABR_Clients) IS
      Sup  : Boolean;
      Meme_N, Meme_P : Boolean;
   BEGIN
      IF A = NULL THEN
         Put("Client non trouve."); New_Line;
      ELSE
         Identique(A.Client.id.id_Nom,    I.id_Nom,    Meme_N);
         Identique(A.Client.id.id_Prenom, I.id_Prenom, Meme_P);
         IF Meme_N AND Meme_P THEN
            Visualise(A.Client);
         ELSE
            Comp_id(I, A.Client.id, Sup);
            IF Sup THEN
               Recherche(I, A.Fd);
            ELSE
               Recherche(I, A.Fg);
            END IF;
         END IF;
      END IF;
   END Recherche;
   FUNCTION Cherche_Client (I : IN T_id; A : IN T_ABR_Clients) RETURN T_ABR_Clients IS
      Sup    : Boolean;
      Meme_N, Meme_P : Boolean;
   BEGIN
      IF A = NULL THEN
         RETURN NULL;
      ELSE
         Identique(A.Client.id.id_Nom,    I.id_Nom,    Meme_N);
         Identique(A.Client.id.id_Prenom, I.id_Prenom, Meme_P);
         IF Meme_N AND Meme_P THEN
            RETURN A;
         ELSE
            Comp_id(I, A.Client.id, Sup);
            IF Sup THEN
               RETURN Cherche_Client(I, A.Fd);
            ELSE
               RETURN Cherche_Client(I, A.Fg);
            END IF;
         END IF;
      END IF;
   END Cherche_Client;
   PROCEDURE Reglement (I : IN T_id; Montant : IN Integer; A : IN OUT T_ABR_Clients) IS
      Noeud : T_ABR_Clients;
   BEGIN
      Noeud := Cherche_Client(I, A);
      IF Noeud = NULL THEN
         Put("Client non trouve."); New_Line;
      ELSIF Montant > Noeud.Client.Fact THEN
         Put("Erreur : montant superieur a la facture en instance (");
         Put(Noeud.Client.Fact); Put(" euros)."); New_Line;
      ELSE
         Noeud.Client.Fact := Noeud.Client.Fact - Montant;
         Noeud.Client.Mont := Noeud.Client.Mont + Montant;
         Put("Reglement enregistre. Facture restante : ");
         Put(Noeud.Client.Fact); Put(" euros."); New_Line;
      END IF;
   END Reglement;
END Gestion_Client;

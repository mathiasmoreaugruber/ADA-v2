WITH Gestion_Identites;
USE  Gestion_Identites;
PACKAGE Gestion_Client IS
   TYPE T_Client IS RECORD
      id     : T_id;
      Nb_Loc : Integer;
      Fact   : Integer;
      Mont   : Integer;
   END RECORD;
   TYPE T_Noeud_Client;
   TYPE T_ABR_Clients IS ACCESS T_Noeud_Client;
   TYPE T_Noeud_Client IS RECORD
      Client : T_Client;
      Fg, Fd : T_ABR_Clients;
   END RECORD;
   PROCEDURE Visualise     (C : IN T_Client);
   PROCEDURE Visu_Clients  (A : IN T_ABR_Clients);
   PROCEDURE Nv_Client     (C : IN T_Client; A : IN OUT T_ABR_Clients);
   FUNCTION  Saisie_Client RETURN T_Client;
   PROCEDURE Recherche     (I : IN T_id; A : IN T_ABR_Clients);
   FUNCTION  Cherche_Client (I : IN T_id; A : IN T_ABR_Clients) RETURN T_ABR_Clients;
   PROCEDURE Reglement     (I : IN T_id; Montant : IN Integer; A : IN OUT T_ABR_Clients);
END Gestion_Client;

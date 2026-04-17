With ada.text_io, ada.Integer_Text_IO;
Use ada.text_io, ada.Integer_Text_IO;
package Gestion_Identites is
   Subtype T_mot is String(1..30);
   Type T_nom is record
      nom  : T_mot;
      Knom : Integer;
   end record;
   Type T_id is record
      id_Nom, id_Prenom : T_Nom;
   end record;
   procedure Saisie_N        (N : out T_nom);
   procedure Saisie_identite (I : out T_id);
   procedure Affiche         (N : in T_nom);
   procedure Affi_identite   (I : in T_id);
   procedure Identique       (N1, N2 : in T_nom; Meme : out Boolean);
   procedure Comp_id         (I1, I2 : in T_id; I1superieur : out Boolean);
end Gestion_Identites;

with Ada.Text_IO, Ada.Integer_Text_IO;
USE  Ada.Text_IO, Ada.Integer_Text_IO;
PACKAGE BODY Gestion_Identites IS
   function Nom_Valide (N : T_mot; K : Integer) return Boolean is
      Nb_Underscore : Integer := 0;
      Phase_Chiffre : Boolean := False;
   begin
      if K = 0 then return False; end if;
      if N(1) = '_' or N(K) = '_' then return False; end if;
      for i in 1..K loop
         if N(i) in 'A'..'Z' or N(i) in 'a'..'z' then
            if Phase_Chiffre then return False; end if;
         elsif N(i) in '0'..'9' then
            Phase_Chiffre := True;
         elsif N(i) = '_' then
            Nb_Underscore := Nb_Underscore + 1;
            if Nb_Underscore > 1    then return False; end if;
            if Phase_Chiffre        then return False; end if;
         else
            return False;
         end if;
      end loop;
      return True;
   end Nom_Valide;
   procedure Saisie_N (N : out T_nom) is
      Last   : Integer;
      Valide : Boolean;
   begin
      loop
         N.nom := (others => ' ');
         Get_Line(N.nom, Last);
         N.Knom := Last;
         Valide := Nom_Valide(N.nom, N.Knom);
         if not Valide then
            Put("Nom invalide. Regles : lettres, 1 seul '_' (pas debut/fin), chiffres uniquement en fin.");
            New_Line;
            Put("Reessayez : ");
         end if;
         exit when Valide;
      end loop;
   end Saisie_N;
   procedure Saisie_identite (I : out T_id) is
      name, pr : T_nom;
   begin
      Put("Nom : ");
      Saisie_N(name);
      I.id_Nom := name;
      Put("Prenom : ");
      Saisie_N(pr);
      I.id_Prenom := pr;
   end Saisie_identite;
   procedure Affiche (N : in T_nom) is
   begin
      Put(N.nom(1..N.Knom));
   end Affiche;
   procedure Affi_identite (I : in T_id) is
   begin
      Affiche(I.id_Nom);    Put(" ");
      Affiche(I.id_Prenom); New_Line;
   end Affi_identite;
   procedure Identique (N1, N2 : in T_nom; Meme : out Boolean) is
   begin
      if N1.Knom /= N2.Knom then
         Meme := False;
      else
         Meme := (N1.nom(1..N1.Knom) = N2.nom(1..N2.Knom));
      end if;
   end Identique;
   function Nom_Superieur (N1, N2 : T_nom) return Boolean is
      n : Integer;
   begin
      if N1.Knom > N2.Knom then
         n := N2.Knom;
      else
         n := N1.Knom;
      end if;
      for i in 1..n loop
         if N1.nom(i) > N2.nom(i) then return True;  end if;
         if N1.nom(i) < N2.nom(i) then return False; end if;
      end loop;
      return N1.Knom > N2.Knom;
   end Nom_Superieur;
   procedure Comp_id (I1, I2 : in T_id; I1superieur : out Boolean) is
      meme : Boolean;
   begin
      Identique(I1.id_Nom, I2.id_Nom, meme);
      if not meme then
         I1superieur := Nom_Superieur(I1.id_Nom, I2.id_Nom);
      else
         Identique(I1.id_Prenom, I2.id_Prenom, meme);
         if meme then
            I1superieur := False;
         else
            I1superieur := Nom_Superieur(I1.id_Prenom, I2.id_Prenom);
         end if;
      end if;
   end Comp_id;
END Gestion_Identites;

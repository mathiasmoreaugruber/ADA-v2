with Ada.Text_IO, Ada.Integer_Text_IO; use Ada.Text_IO, Ada.Integer_Text_IO;
package body Gestion_Date is
   function Annee_Bis (A : Natural) return Boolean is
      Bis : Boolean;
   begin
      Bis := False;
      if (A mod 4 = 0) and (A mod 100 /= 0 or A mod 400 = 0) then
         Bis := True;
      else
         Bis := False;
      end if;
      return (Bis);
   end Annee_Bis;
   function Nb_Jour (M : Tint_12; A : Natural) return Integer is
      Nb : Integer;
   begin
      case M is
         when 01 | 03 | 05 | 07 | 08 | 10 | 12 =>
            Nb := 31;
         when 04 | 06 | 09 | 11                =>
            Nb := 30;
         when 02                               =>
            if Annee_Bis (A) = True then
               Nb := 29;
            else
               Nb := 28;
            end if;
      end case;
      return (Nb);
   end Nb_Jour;
   procedure Saisie_Date (D : in out T_Date) is
   begin
      loop
         begin
            Put ("Saisir une annee ");
            Get (D.A);
            Skip_Line;
            exit when D.A > 0;
         exception
            when Data_Error =>
               Skip_Line;
               Put_Line ("Erreur de saisie, recommencez");
            when Constraint_Error =>
               Skip_Line;
               Put_Line ("Mauvaise valeur, recommencez");
         end;
      end loop;
      loop
         begin
            Put ("Saisir le mois en chiffre ");
            Get (D.M);
            Skip_Line;
            exit when D.M >= 1 and D.M <= 12;
         exception
            when Data_Error =>
               Skip_Line;
               Put_Line ("Erreur de saisie, recommencez");
            when Constraint_Error =>
               Skip_Line;
               Put_Line ("Mauvaise valeur, recommencez");
         end;
      end loop;
      loop
         begin
            Put ("Saisir le jour (nombre) ");
            Get (D.J);
            Skip_Line;
            exit when D.J <= Nb_Jour (D.M, D.A);
         exception
            when Data_Error =>
               Skip_Line;
               Put_Line ("Erreur de saisie, recommencez");
            when Constraint_Error =>
               Skip_Line;
               Put_Line ("Mauvaise valeur, recommencez");
         end;
      end loop;
   end Saisie_Date;
   procedure Affichage_Date (D : in T_Date) is
   begin
      Put (D.J);
      Put ("/");
      Put (Tint_12'Image (D.M));
      Put ("/");
      Put (D.A, 0);
      New_Line;
   end Affichage_Date;
   procedure Lendemain (Date_Du_Jour : in out T_Date) is
   begin
      if Date_Du_Jour.J < Nb_Jour (Date_Du_Jour.M, Date_Du_Jour.A) then
         Date_Du_Jour.J := Date_Du_Jour.J + 1;
      else
         Date_Du_Jour.J := 1;
         if Date_Du_Jour.M = Tint_12'Last then
            Date_Du_Jour.M := Tint_12'First;
            Date_Du_Jour.A := Date_Du_Jour.A + 1;
         else
            Date_Du_Jour.M := Tint_12'Succ (Date_Du_Jour.M);
         end if;
      end if;
   end Lendemain;
   procedure Initialise_Date (D : in out T_Date) is
   begin
      D.J := 1;
      D.M := 1;
      D.A := 0;
   end Initialise_Date;
   function Date_J (D : T_Date) return Integer is
      TT_Jours : Integer := 0;
   begin
      for I in 1 .. D.A - 1 loop
         if Annee_Bis (I) then
            TT_Jours := TT_Jours + 366;
         else
            TT_Jours := TT_Jours + 365;
         end if;
      end loop;
      for I in 1 .. D.M - 1 loop
         TT_Jours := TT_Jours + Nb_Jour (I, D.A);
      end loop;
      TT_Jours := TT_Jours + D.J;
      return TT_Jours;
   end Date_J;
   function Difference_Jours (Date1, Date2 : T_Date) return Integer is
      Resultat : Integer;
   begin
      Resultat := (Date_J (Date2) - Date_J (Date1));
      return (Resultat);
   end Difference_Jours;
end Gestion_Date;

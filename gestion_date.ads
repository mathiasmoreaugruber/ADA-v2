with Ada.Text_IO, Ada.Integer_Text_IO; use Ada.Text_IO, Ada.Integer_Text_IO;
package Gestion_Date is
   subtype Int31 is Integer range 1 .. 31;
   subtype Tint_12 is integer range 1 .. 12;
   type T_Date is record
      J : Int31;
      M : Tint_12;
      A : Natural;
   end record;
   function Annee_Bis (A : Natural) return Boolean;
   function Nb_Jour (M : Tint_12; A : Natural) return Integer;
   procedure Saisie_Date (D : in out T_Date);
   procedure Affichage_Date (D : in T_Date);
   procedure Lendemain (Date_Du_Jour : in out T_Date);
   procedure Initialise_Date (D : in out T_Date);
   function Date_J (D : T_Date) return Integer;
   function Difference_Jours (Date1, Date2 : T_date) return Integer;
end Gestion_Date;

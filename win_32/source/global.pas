unit Global;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function hari: String;
function CHari(Waktu: TDateTime): String;
function rupiah(Rp: String): String;
function hapus(Sel: String): String;
implementation
//convert day to special format string
function hari: String;
var
 YY,MM,DD: Word;
begin
  DecodeDate(Date,YY,MM,DD);
  hari:= format('%.2d-%.2d-%d',[dd,mm,yy]);
end;
//convert date to spesial format string
function CHari(Waktu: TDateTime): String;
var
  YY,MM,DD: Word;
  begin
   DecodeDate(Waktu,YY,MM,DD);
   CHari:= format('%.2d-%.2d-%d',[dd,mm,yy]);
  end;
//convert number to rupiah
function rupiah(Rp: String):String;
 var
   lnt: Integer;
   smt: String;

 begin
   smt:='';
   lnt:=length(Rp);
   case lnt of
    3:
      begin
        smt:= Rp;
        smt:='Rp.' + format('%28s',[smt]);
      end;
    4:
      begin
        smt:=copy(Rp,1,1) + '.' + copy(Rp,2,3);
        smt:='Rp.' + format('%22s',[smt]);
      end;
    5:
      begin
        smt:=copy(Rp,1,2) + '.' + copy(Rp,3,3);
        smt:='Rp.' + format('%21s',[smt]);
      end;
    6:
      begin
        smt:=copy(Rp,1,3) + '.' + copy(Rp,4,3);
        smt:='Rp.' + format('%20s',[smt]);
      end;
    7:
      begin
        smt:=copy(Rp,1,1) + '.' + copy(Rp,2,3) + '.' + copy(Rp,5,3);
        smt:='Rp.' + format('%19s',[smt]);
      end;
    8:
      begin
        smt:=copy(Rp,1,2) + '.' + copy(Rp,3,3) + '.' + copy(Rp,6,3);
        smt:='Rp.' + format('%14s',[smt]);
      end;
   end;
   rupiah:=smt;
 end;
 //convert rupiah to number
 function hapus(Sel: String): String;
 var
   lt: Integer;
   p1: Integer;
   p2: Integer;
   se: String;
   smt: String;
   smp: String;
 begin
   lt:=length(Sel);

   se:= Copy(Sel,4,lt);
   p1:= Pos('.',se);
   smt:=Copy(se,(p1 + 1),lt);
   p2:= Pos('.',smt);
   if(p2=0) then
    begin
     se := Copy(se,1,(p1-1)) + smt;
    end
   else
    begin
      smp:= Copy(smt,1,(p2-1)) + Copy(smt,(p2+1),lt);
      se:= Copy(se,1,(p1-1)) + smp;
    end;
   hapus:=se;
 end;

end.


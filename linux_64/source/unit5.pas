unit Unit5;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Grids,
  StdCtrls, db, sqldb, sqlite3conn;

type

  { TForm5 }

  TForm5 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Image1: TImage;
    Panel1: TPanel;
    Panel2: TPanel;
    SG1: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Simpan(sender: TObject; aCol, aRow: Integer);
  private

  public
     i: Integer;
  end;

var
  Form5: TForm5;

implementation

{$R *.lfm}

{ TForm5 }

procedure Create_Header;
begin
   Form5.SG1.Cells[0,0] := 'KID';
   Form5.SG1.Cells[1,0] := 'Kode Keluar';
   Form5.SG1.Cells[2,0] := 'Nama Kode';
end;
procedure Create_Cells(Ind: Integer; Qry: TSQLQuery);
begin
Form5.SG1.Cells[0,Ind] := Qry.FieldByName('k_id').AsString;
Form5.SG1.Cells[1,Ind] := Qry.FieldByName('k_kode').AsString;
Form5.SG1.Cells[2,Ind] := Qry.FieldByName('k_nama').AsString;
end;

procedure TForm5.FormCreate(Sender: TObject);
begin
  SG1.Options:= SG1.Options + [goEditing];
end;
procedure Simpan_Item;
var
  SCon : TSQLConnection;
  STran: TSQLTransaction;
  pQry : TSQLQuery;

begin
 SCon  := TSQLite3Connection.Create(nil);
 STran := TSQLTransaction.Create(SCon);
 SCon.Transaction := STran;
 SCon.DatabaseName:='buku.db';
 pQry := TSQLQuery.Create(nil);
 pQry.SQL.Text := 'insert into keluar(k_kode,k_nama) values(:no,:nm)';
 pQry.ParamByName('no').AsString:=Form5.Edit1.Text;
 pQry.ParamByName('nm').AsString:=Form5.Edit2.Text;
 pQry.DataBase:= SCon;
 pQry.ExecSQL;
 STran.Commit;
 pQry.Close;
 SCon.Close;
 pQry.Free;
 STran.Free;
 SCon.Free;
 Form5.Visible:=False;
  Form5.Visible:=True;
end;
procedure TForm5.FormShow(Sender: TObject);
var
 SCon : TSQLConnection;
 STran: TSQLTransaction;
 pQry : TSQLQuery;

begin
 SCon  := TSQLite3Connection.Create(nil);
 STran := TSQLTransaction.Create(SCon);
 SCon.Transaction := STran;
 SCon.DatabaseName:='buku.db';
 pQry := TSQLQuery.Create(nil);
 pQry.SQL.Text := 'select * from keluar';
 pQry.DataBase:= Scon;
 pQry.Open;
 SG1.Clean;
 i:= 0;
 Create_Header;   {procedure}
 while not pQry.EOF do
 begin
    i := i + 1;
    Create_Cells(i, pQry);    {procedure}
    pQry.Next;
 end;
 pQry.Close;
 pQry.Free;
 STran.Free;
 SCon.Free;
end;

procedure TForm5.Image1Click(Sender: TObject);
begin
  if MessageDlg('Menyimpan item', 'Mau menyimpan item?', mtConfirmation,
    [mbYes, mbNo, mbIgnore],0) = mrYes
  then
    try
      Simpan_Item;  {procedure}
    except
      ShowMessage('Ada yang belum diisi atau dipilih!');
   end;
end;
procedure TForm5.Simpan(sender: TObject; aCol, aRow: Integer);
var
  SCon : TSQLConnection;
  STran: TSQLTransaction;
  pQry : TSQLQuery;

begin
 SCon  := TSQLite3Connection.Create(nil);
 STran := TSQLTransaction.Create(SCon);
 SCon.Transaction := STran;
 SCon.DatabaseName:='buku.db';
 pQry := TSQLQuery.Create(nil);
 Case aCol of
  1: begin
     pQry.SQL.Text := 'update keluar set k_kode=:kel where k_id=:hid';
     pQry.ParamByName('kel').Value:=SG1.Cells[aCol,aRow];
  end;
  2: begin
     pQry.SQL.Text := 'update keluar set k_nama=:dia where k_id=:hid';
     pQry.ParamByName('dia').Value:=SG1.Cells[aCol,aRow];
  end;
 end;
 pQry.ParamByName('hid').Value:=SG1.Cells[0,aRow];
 pQry.DataBase:=SCon;
 pQry.ExecSQL;
 STran.Commit;
 pQry.Close;
 SCon.Close;
 pQry.Free;
 STran.Free;
 SCon.Free;
end;

end.


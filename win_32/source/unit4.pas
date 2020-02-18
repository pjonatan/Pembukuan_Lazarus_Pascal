unit Unit4;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids,
  ExtCtrls, StdCtrls, db, sqldb, sqlite3conn;

type

  { TForm4 }

  TForm4 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Image1: TImage;
    Panel1: TPanel;
    Panel2: TPanel;
    SG1: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Simpan(Sender: TObject; aCol, aRow: Integer);
  private

  public
     i: Integer;
  end;

var
  Form4: TForm4;

implementation

{$R *.lfm}

{ TForm4 }

procedure Create_Header;
begin
   Form4.SG1.Cells[0,0] := 'KID';
   Form4.SG1.Cells[1,0] := 'Kode Masuk';
   Form4.SG1.Cells[2,0] := 'Nama Kode';
end;
procedure Create_Cells(Ind: Integer; Qry: TSQLQuery);
begin
Form4.SG1.Cells[0,Ind] := Qry.FieldByName('m_id').AsString;
Form4.SG1.Cells[1,Ind] := Qry.FieldByName('m_kode').AsString;
Form4.SG1.Cells[2,Ind] := Qry.FieldByName('m_nama').AsString;
end;
procedure TForm4.FormCreate(Sender: TObject);
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
 pQry.SQL.Text := 'insert into masuk(m_kode,m_nama) values(:no,:nm)';
 pQry.ParamByName('no').AsString:=Form4.Edit1.Text;
 pQry.ParamByName('nm').AsString:=Form4.Edit2.Text;
 pQry.DataBase:= SCon;
 pQry.ExecSQL;
 STran.Commit;
 pQry.Close;
 SCon.Close;
 pQry.Free;
 STran.Free;
 SCon.Free;
 Form4.Visible:=False;
 Form4.Visible:=True;
end;
procedure TForm4.FormShow(Sender: TObject);
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
  pQry.SQL.Text := 'select * from masuk';
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

procedure TForm4.Image1Click(Sender: TObject);
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

  procedure TForm4.Simpan(Sender: TObject; aCol, aRow: Integer);
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
      pQry.SQL.Text := 'update masuk set m_kode=:kel where m_id=:hid';
      pQry.ParamByName('kel').Value:=SG1.Cells[aCol,aRow];
   end;
   2: begin
      pQry.SQL.Text := 'update masuk set m_nama=:dia where m_id=:hid';
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


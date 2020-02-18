unit Unit3;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Grids, db, sqldb, sqlite3conn, Global;

type

  { TForm3 }

  TForm3 = class(TForm)
    Tg1: TComboBox;
    Bl1: TComboBox;
    Th1: TComboBox;
    Tg2: TComboBox;
    Bl2: TComboBox;
    Th2: TComboBox;
    Image1: TImage;
    Image2: TImage;
    Panel1: TPanel;
    SG: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Ubah(sender: TObject; aCol, aRow: Integer);

  private

  public
    i: Integer;
  end;

var
  Form3: TForm3;

implementation

{$R *.lfm}

procedure Create_Header;
begin
   Form3.SG.Cells[0,0] := 'TID';
   Form3.SG.Cells[1,0] := 'Tanggal';
   Form3.SG.Cells[2,0] := 'K_Masuk';
   Form3.SG.Cells[3,0] := 'K_Keluar';
   Form3.SG.Cells[4,0] := 'No_Bukti';
   Form3.SG.Cells[5,0] := 'Keterangan';
   Form3.SG.Cells[6,0] := 'Jm_Masuk';
   Form3.SG.Cells[7,0] := 'Jm_Keluar';
   Form3.SG.Cells[8,0] := 'Saldo';
end;
procedure Create_Cells(Ind: Integer; Qry: TSQLQuery);
begin
Form3.SG.Cells[0,Ind] := Qry.FieldByName('t_id').AsString;
Form3.SG.Cells[1,Ind] := DateToStr(Qry.FieldByName('tanggal').AsDateTime);
Form3.SG.Cells[2,Ind] := Qry.FieldByName('m_kode').AsString;
Form3.SG.Cells[3,Ind] := Qry.FieldByName('k_kode').AsString;
Form3.SG.Cells[4,Ind] := Qry.FieldByName('nomor').AsString;
Form3.SG.Cells[5,Ind] := Qry.FieldByName('keterangan').AsString;
  if(Qry.FieldByName('masuk').AsInteger=0) then
    begin
      Form3.SG.Cells[6,Ind].IsEmpty;
    end
  else
    begin
     Form3.SG.Cells[6,Ind] := rupiah(Qry.FieldByName('masuk').AsString);
    end;
  if(Qry.FieldByName('keluar').AsInteger=0) then
    begin
      Form3.SG.Cells[7,Ind].IsEmpty;
    end
  else
    begin
     Form3.SG.Cells[7,Ind] := rupiah(Qry.FieldByName('keluar').AsString);
    end;
Form3.SG.Cells[8,Ind] := rupiah(Qry.FieldByName('saldo').AsString);
end;
procedure TForm3.FormCreate(Sender: TObject);

begin
SG.Options:= SG.Options + [goEditing];
  i:=0;
  while i<31 do
  begin
    i:= i + 1;
    Form3.Tg1.Items.Add(IntToStr(i));
    Form3.Tg2.Items.Add(IntToStr(i));
  end;
  i:=0;
  while i<12 do
  begin
    i:= i + 1;
    Form3.Bl1.Items.Add(IntToStr(i));
    Form3.Bl2.Items.Add(IntToStr(i));
  end;
  i:=2019;
  while i<2024 do
  begin
    i:= i + 1;
    Form3.Th1.Items.Add(IntToStr(i));
    Form3.Th2.Items.Add(IntToStr(i));
  end;
end;

procedure TForm3.Image1Click(Sender: TObject);
var
  SCon : TSQLConnection;
  STran: TSQLTransaction;
  pQry : TSQLQuery;
  Tanggal1: String;
  Tanggal2: String;

begin
Tanggal1:= Form3.Tg1.Text + '-' + Form3.Bl1.Text + '-' + Form3.Th1.Text;
Tanggal2:= Form3.Tg2.Text + '-' + Form3.Bl2.Text + '-' + Form3.Th2.Text;
try
  SCon  := TSQLite3Connection.Create(nil);
  STran := TSQLTransaction.Create(SCon);
  SCon.Transaction := STran;
  SCon.DatabaseName:='buku.db';
  pQry := TSQLQuery.Create(nil);
  pQry.SQL.Text := 'select * from transaksi where tanggal>=:tg1 and tanggal <=:tg2';
  pQry.ParamByName('tg1').AsDateTime:=StrToDate(Tanggal1);
  pQry.ParamByName('tg2').AsDateTime:=StrToDate(Tanggal2);
  pQry.Database := Scon;
  pQry.Open;
  SG.Clean;
  SG.TitleFont.Color:=clFuchsia;
  SG.TitleFont.Style:=[fsBold];
  i:= 0;
  Create_Header;
  while not pQry.EOF do
  begin
   i := i + 1;
   Create_Cells(i, pQry);
   pQry.Next;
  end;
  pQry.Close;
  pQry.Free;
  STran.Free;
  SCon.Free;
 except
   ShowMessage('Tanggal belum dipilih!');
 end;
end;
procedure TForm3.Ubah(sender: TObject; aCol, aRow: Integer);
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
      pQry.SQL.Text := 'update transaksi set tanggal=:tg where t_id=:hid';
      pQry.ParamByName('tg').Value:=StrToDate(SG.Cells[aCol,aRow]);
   end;
   2: begin
      pQry.SQL.Text := 'update transaksi set m_kode=:mk where t_id=:hid';
      pQry.ParamByName('mk').Value:=SG.Cells[aCol,aRow];
   end;
   3: begin
      pQry.SQL.Text := 'update transaksi set k_kode=:kk where t_id=:hid';
      pQry.ParamByName('kk').Value:=SG.Cells[aCol,aRow];
   end;
   4: begin
      pQry.SQL.Text := 'update transaksi set nomor=:nm where t_id=:hid';
      pQry.ParamByName('nm').Value:=SG.Cells[aCol,aRow];
   end;
   5: begin
      pQry.SQL.Text := 'update transaksi set keterangan=:kt where t_id=:hid';
      pQry.ParamByName('kt').Value:=SG.Cells[aCol,aRow];
   end;
   6: begin
      pQry.SQL.Text := 'update transaksi set masuk=:ms where t_id=:hid';
      pQry.ParamByName('ms').Value:=hapus(SG.Cells[aCol,aRow]);
   end;
   7: begin
      pQry.SQL.Text := 'update transaksi set keluar=:kl where t_id=:hid';
      pQry.ParamByName('kl').Value:=hapus(SG.Cells[aCol,aRow]);
   end;
   8: begin
      pQry.SQL.Text := 'update transaksi set saldo=:sd where t_id=:hid';
      pQry.ParamByName('sd').Value:=hapus(SG.Cells[aCol,aRow]);
   end;
  end;
  pQry.ParamByName('hid').Value:=SG.Cells[0,aRow];
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


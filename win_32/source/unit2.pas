unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Grids, db, sqldb, sqlite3conn, global;

type

  { TForm2 }

  TForm2 = class(TForm)
    Edit8: TEdit;
    Nomor: TPanel;
    Kode_Masuk: TComboBox;
    Kode_Keluar: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Image1: TImage;
    SG: TStringGrid;
    Tanggal  : TPanel;
    Kode_M   : TPanel;
    Kode_K   : TPanel;
    Keterangan: TPanel;
    Jm_Masuk : TPanel;
    Jm_Keluar: TPanel;
    Saldo    : TPanel;
    procedure Image1Click(Sender: TObject);
    procedure Isi_saldo(Sender: TObject);
    procedure Isi_saldo2(Sender: TObject);
    procedure Kode_KeluarChange(Sender: TObject);
    procedure Kode_KeluarClick(Sender: TObject);
    procedure Kode_MasukChange(Sender: TObject);
    procedure Kode_MasukClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Kode_KClick(Sender: TObject);
    procedure Kode_MClick(Sender: TObject);
    procedure Ubah(Sender: TObject; aCol, aRow: Integer);

  private

  public
    Total: Integer;
    L_Row: Integer;
    i: Integer;
    cek: Integer;
  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }

procedure Create_Header;
begin
   Form2.SG.Cells[0,0] := 'TID';
   Form2.SG.Cells[1,0] := 'Tanggal';
   Form2.SG.Cells[2,0] := 'K_Masuk';
   Form2.SG.Cells[3,0] := 'K_Keluar';
   Form2.SG.Cells[4,0] := 'No_Bukti';
   Form2.SG.Cells[5,0] := 'Keterangan';
   Form2.SG.Cells[6,0] := 'Jm_Masuk';
   Form2.SG.Cells[7,0] := 'Jm_Keluar';
   Form2.SG.Cells[8,0] := 'Saldo';
end;
procedure Create_Cells(Ind: Integer; Qry: TSQLQuery);
begin
Form2.SG.Cells[0,Ind] := Qry.FieldByName('t_id').AsString;
Form2.SG.Cells[1,Ind] := DateToStr(Qry.FieldByName('tanggal').AsDateTime);
Form2.SG.Cells[2,Ind] := Qry.FieldByName('m_kode').AsString;
Form2.SG.Cells[3,Ind] := Qry.FieldByName('k_kode').AsString;
Form2.SG.Cells[4,Ind] := Qry.FieldByName('nomor').AsString;
Form2.SG.Cells[5,Ind] := Qry.FieldByName('keterangan').AsString;
  if(Qry.FieldByName('masuk').AsInteger=0) then
    begin
      Form2.SG.Cells[6,Ind].IsEmpty;
    end
  else
    begin
     Form2.SG.Cells[6,Ind] := rupiah(Qry.FieldByName('masuk').AsString);
    end;
  if(Qry.FieldByName('keluar').AsInteger=0) then
    begin
      Form2.SG.Cells[7,Ind].IsEmpty;
    end
  else
    begin
     Form2.SG.Cells[7,Ind] := rupiah(Qry.FieldByName('keluar').AsString);
    end;
Form2.SG.Cells[8,Ind] := rupiah(Qry.FieldByName('saldo').AsString);
end;
procedure TForm2.FormCreate(Sender: TObject);
var
  SCon : TSQLConnection;
  STran: TSQLTransaction;
  pQry : TSQLQuery;
  Isi: String;

begin
  cek:=0;
  SG.Options:= SG.Options + [goEditing];
  Form2.Edit1.Text:=hari;
  SCon  := TSQLite3Connection.Create(nil);
  STran := TSQLTransaction.Create(SCon);
  SCon.Transaction := STran;
  SCon.DatabaseName:='buku.db';
  pQry := TSQLQuery.Create(nil);
  pQry.SQL.Text := 'select count(*) from transaksi';
  pQry.DataBase:= Scon;
  pQry.Open;
  if(pQry.Fields[0].AsInteger=0) then
    begin
      Total:=0;
    end
  else
    begin
     L_Row:=pQry.Fields[0].AsInteger;
     pQry.Clear;
     pQry.SQL.Text:='select * from transaksi where t_id=:lt_id';
     pQry.ParamByName('lt_id').Value:=L_Row;
     pQry.Open;
     Total:=pQry.FieldByName('saldo').AsInteger;
    end;
  pQry.Clear;
  pQry.SQL.Text := 'select * from masuk';
  pQry.DataBase:= Scon;
  pQry.Open;
  while not pQry.EOF do
  begin
    Isi:= pQry.FieldByName('m_kode').AsString +
            pQry.FieldByName('m_nama').AsString;
    Kode_Masuk.Items.Add(Isi);
    pQry.Next;
  end;
  pQry.Close;
  pQry.SQL.Text := 'select * from keluar';
  pQry.DataBase:= Scon;
  pQry.Open;
  while not pQry.EOF do
  begin
    Isi:= pQry.FieldByName('k_kode').AsString +
            pQry.FieldByName('k_nama').AsString;
    Kode_Keluar.Items.Add(Isi);
    pQry.Next;
  end;
  pQry.Close;
  SCon.Close;
  pQry.Free;
  STran.Free;
  SCon.Free;
end;
procedure Simpan_Trans;
var
  SCon : TSQLConnection;
  STran: TSQLTransaction;
  pQry : TSQLQuery;
  ms1: Integer;
  kl1: Integer;

begin
 SCon  := TSQLite3Connection.Create(nil);
 STran := TSQLTransaction.Create(SCon);
 SCon.Transaction := STran;
 SCon.DatabaseName:='buku.db';
 pQry := TSQLQuery.Create(nil);
 pQry.SQL.Text := 'insert into transaksi(tanggal,m_kode,k_kode,keterangan,' +
                   'masuk,keluar,saldo) values(:tg,:mk,:kk,:kt,:ms,:kl,:sl)';
 pQry.ParamByName('tg').AsDate:=StrToDate(Form2.Edit1.Text);
 pQry.ParamByName('mk').Value:=Form2.Edit2.Text;
 pQry.ParamByName('kk').Value:=Form2.Edit3.Text;
 pQry.ParamByName('kt').Value:=Form2.Edit4.Text;
 if(Form2.Edit5.Text='') then
     ms1:=0
 else
     ms1:=StrToInt(Form2.Edit5.Text);
 pQry.ParamByName('ms').Value:=ms1;
 if(Form2.Edit6.Text='') then
     kl1:=0
 else
     kl1:=StrToInt(Form2.Edit6.Text);
 pQry.ParamByName('kl').Value:=kl1;
 pQry.ParamByName('sl').Value:=StrToInt(Form2.Edit7.Text);
 pQry.DataBase:= SCon;
 pQry.ExecSQL;
 STran.Commit;
 pQry.Close;
 SCon.Close;
 pQry.Free;
 STran.Free;
 SCon.Free;
end;

procedure TForm2.Kode_MasukChange(Sender: TObject);
Var
  kombo: String;
  kode: String;
  nama: String;
  leng: Integer;
begin
  cek:=0;
  kombo:= Kode_Masuk.Text;
  if(kombo='') then abort;
  leng:=Length(kombo);
  kode:=Copy(kombo,1,4);
  nama:=Copy(kombo,5,(leng-4));
  Edit2.Text:=kode;
  Edit3.Text:='';
  Edit4.Text:=nama;
  Edit5.Enabled:=True;
  Edit6.Enabled:=False;
  Kode_Masuk.Visible:=False;
  Kode_Keluar.Visible:=False;
  Kode_M.Visible:=True;
  Kode_K.Visible:=True;
end;
procedure TForm2.Kode_MasukClick(Sender: TObject);
begin

end;

procedure TForm2.Isi_saldo(Sender: TObject);
begin
 if(Edit2.Text='m001') then
   begin
     Edit7.Text:=Edit5.Text;
   end
 else
   begin
    if(cek=0) then
     begin
       if(Edit5.Text<>'') then
        begin
         Total:= Total + StrToInt(Edit5.Text);
         Edit7.Text:=IntToStr(Total);
         cek:=1;
        end;
     end;
   end;
end;

procedure TForm2.Image1Click(Sender: TObject);
begin
  if MessageDlg('Menyimpan data', 'Mau menyimpan data?', mtConfirmation,
    [mbYes, mbNo, mbIgnore],0) = mrYes
  then
    try
      Simpan_Trans;
      Form2.Edit2.Text:='';
      Form2.Edit3.Text:='';
      Form2.Edit4.Text:='';
      Form2.Edit5.Text:='';
      Form2.Edit6.Text:='';
      Form2.Edit7.Text:='';
      Form2.Visible:=False;
      Form2.Visible:=True;
    except
      ShowMessage('Ada yang belum diisi!');
   end;
end;

procedure TForm2.Isi_saldo2(Sender: TObject);
begin
  if(cek=0) then
    begin
      if(Edit6.Text<>'') then
        begin
         Total:= Total - StrToInt(Edit6.Text);
         Edit7.Text:=IntToStr(Total);
         cek:=1;
        end;
    end;
end;

procedure TForm2.Kode_KeluarChange(Sender: TObject);
Var
  kombo: String;
  kode: String;
  nama: String;
  leng: Integer;
begin
  cek:=0;
  kombo:= Kode_Keluar.Text;
  leng:=Length(kombo);
  kode:=Copy(kombo,1,4);
  nama:=Copy(kombo,5,(leng-4));
  Edit3.Text:=kode;
  Edit2.Text:='';
  Edit4.Text:=nama;
  Edit6.Enabled:=True;
  Edit5.Enabled:=False;
  Kode_Keluar.Visible:=False;
  Kode_Masuk.Visible:=False;
  Kode_K.Visible:=True;
  Kode_M.Visible:=True;
end;

procedure TForm2.Kode_KeluarClick(Sender: TObject);

begin

end;
procedure TForm2.Kode_KClick(Sender: TObject);
begin
  if(cek=0) then
    begin
      Form2.Kode_K.Visible:=False;
      Form2.Kode_Keluar.Visible:=True;
      cek:=1;
    end
  else
    begin
     Form2.Kode_K.Visible:=False;
     Form2.Kode_Keluar.Visible:=True;
     Form2.Kode_Keluar.BringToFront;
     Form2.Kode_Masuk.Visible:=False;
     cek:=0;
    end;
end;

procedure TForm2.Kode_MClick(Sender: TObject);
begin
  if(cek=0) then
    begin
     Form2.Kode_M.Visible:=False;
     Form2.Kode_Masuk.Visible:=True;
     cek:=1;
    end
  else
    begin
     Form2.Kode_M.Visible:=False;
     Form2.Kode_Masuk.Visible:=True;
     Form2.Kode_Masuk.BringToFront;
     Form2.Kode_Keluar.Visible:=False;
     Form2.Kode_K.Visible:=False;
     cek:=0;
    end;
end;
procedure TForm2.FormShow(Sender: TObject);
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
  pQry.SQL.Text := 'select count(*) from transaksi';
  pQry.Database := Scon;
  pQry.Open;
  L_Row:=pQry.Fields[0].AsInteger;
  pQry.Clear;
  pQry.SQL.Text := 'select * from transaksi';
  pQry.Open;
  SG.Clean;
  SG.TitleFont.Color:=clRed;
  SG.TitleFont.Style:=[fsBold];
  i:= 0;
  Create_Header;
  while i< (L_Row - 15) do
  begin
    i := i + 1;
     pQry.Next;
  end;
  i:=0;
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
end;
procedure TForm2.Ubah(sender: TObject; aCol, aRow: Integer);
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


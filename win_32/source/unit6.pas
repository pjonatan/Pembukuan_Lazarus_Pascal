unit Unit6;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Grids,
  StdCtrls, db, sqldb, sqlite3conn, libjpfpdf, Global;

type

  { TForm6 }

  TForm6 = class(TForm)
    Bulan: TComboBox;
    SaveDialog1: TSaveDialog;
    Tahun: TComboBox;
    Image1: TImage;
    Image2: TImage;
    Panel1: TPanel;
    Panel2: TPanel;
    SG: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);

  private

  public
    i: Integer;
    Tanggal1: String;
    Tanggal2: String;
  end;

var
  Form6: TForm6;

implementation

{$R *.lfm}

{ TForm6 }

procedure Create_Header;
begin
   Form6.SG.Cells[0,0] := 'TID';
   Form6.SG.Cells[1,0] := 'Tanggal';
   Form6.SG.Cells[2,0] := 'K_Masuk';
   Form6.SG.Cells[3,0] := 'K_Keluar';
   Form6.SG.Cells[4,0] := 'No_Bukti';
   Form6.SG.Cells[5,0] := 'Keterangan';
   Form6.SG.Cells[6,0] := 'Jm_Masuk';
   Form6.SG.Cells[7,0] := 'Jm_Keluar';
   Form6.SG.Cells[8,0] := 'Saldo';
end;
procedure Create_Cells(Ind: Integer; Qry: TSQLQuery);
begin
Form6.SG.Cells[0,Ind] := Qry.FieldByName('t_id').AsString;
Form6.SG.Cells[1,Ind] := DateToStr(Qry.FieldByName('tanggal').AsDateTime);
Form6.SG.Cells[2,Ind] := Qry.FieldByName('m_kode').AsString;
Form6.SG.Cells[3,Ind] := Qry.FieldByName('k_kode').AsString;
Form6.SG.Cells[4,Ind] := Qry.FieldByName('nomor').AsString;
Form6.SG.Cells[5,Ind] := Qry.FieldByName('keterangan').AsString;
  if(Qry.FieldByName('masuk').AsInteger=0) then
    begin
      Form6.SG.Cells[6,Ind].IsEmpty;
    end
  else
    begin
     Form6.SG.Cells[6,Ind] := rupiah(Qry.FieldByName('masuk').AsString);
    end;
  if(Qry.FieldByName('keluar').AsInteger=0) then
    begin
      Form6.SG.Cells[7,Ind].IsEmpty;
    end
  else
    begin
     Form6.SG.Cells[7,Ind] := rupiah(Qry.FieldByName('keluar').AsString);
    end;
Form6.SG.Cells[8,Ind] := rupiah(Qry.FieldByName('saldo').AsString);
end;
procedure TForm6.Image1Click(Sender: TObject);
var
  SCon : TSQLConnection;
  STran: TSQLTransaction;
  pQry : TSQLQuery;
begin
 Tanggal1:=  Form6.Tahun.Text + '-' + format('%.2d',[StrToInt(Form6.Bulan.Text)]) + '-' + '01';
 Case Form6.Bulan.Text of
   '1', '3', '5', '7', '8', '10', '12':
     Tanggal2:=  Form6.Tahun.Text + '-' + Form6.Bulan.Text + '-' + '31';
   '2':
     Tanggal2:=  Form6.Tahun.Text + '-' + Form6.Bulan.Text + '-' + '28';
   '4','6','9','11':
     Tanggal2:=  Form6.Tahun.Text + '-' + Form6.Bulan.Text + '-' + '30';
  end;
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

procedure TForm6.FormCreate(Sender: TObject);
begin
   i:=0;
  while i<12 do
  begin
    i:= i + 1;
    Form6.Bulan.Items.Add(IntToStr(i));
  end;
  i:=2019;
 while i<2025 do
 begin
   i:= i + 1;
   Form6.Tahun.Items.Add(IntToStr(i));
 end;     end;

procedure TForm6.Image2Click(Sender: TObject);
var
  filename: string;
  SCon : TSQLConnection;
  STran: TSQLTransaction;
  pQry : TSQLQuery;
  Qry : TSQLQuery;
  pdf: TJPFpdf;
  Jumlah: Integer;
   Bl: String;
   Th: String;
   Pb: String;
   PdfY: Integer;
   ct: Integer;
   Jm: Integer;
   Total_Masuk: Integer;
   Total_Keluar: Integer;
begin
 if SaveDialog1.Execute then
   begin
     filename:= SaveDialog1.FileName;
     ShowMessage('Diexport ke -> ' + filename + '.pdf');
   end;
 Bl:=Form6.Bulan.Text;
 Th:=Form6.Tahun.Text;
 pdf:= TJPFpdf.Create(poPortrait,puMM,pfA4);
 pdf.AddPage();
 pdf.SetFont(ffHelvetica,fsBold,14);
 pdf.SetTextColor(cRed);
 pdf.Image('logo.png',10,6,15);
 pdf.SetXY(30,15);
 pdf.Cell(170,8,'PGKICIC Laporan keuangan Bulan : ' + Bl + ' Tahun: ' + Th,'1',0,'C',0);
 pdf.SetTextColor(cBlue);
 pdf.SetXY(10,23);
 pdf.Cell(140,7,'Item Masuk','1',0,'C',0);
 pdf.SetX(150);
 pdf.Cell(50,7,'Jumlah','1',0,'C',0);
 pdf.SetTextColor(cBlack);
 pdf.SetFont(ffHelvetica,fsNormal,12);
 SCon  := TSQLite3Connection.Create(nil);
 STran := TSQLTransaction.Create(SCon);
 SCon.Transaction := STran;
 SCon.DatabaseName:='buku.db';
 pQry := TSQLQuery.Create(nil);
 pQry.SQL.Text := 'select * from masuk';
 pQry.DataBase:=Scon;
 pQry.Open;
 Jumlah:=0;
 Total_Masuk:=0;
 ct:=0;
 PdfY:=30;
while not pQry.EOF do
 begin
  Pb:=pQry.FieldByName('m_kode').AsString;
  while ct<i do
   begin
     ct:= ct +1;
     if(Form6.SG.Cells[2,ct]=Pb) then
       begin
          Jm:=StrToInt(hapus(Form6.SG.Cells[6,ct]));
          Jumlah:=Jumlah + Jm;
       end;
   end;
   if(Jumlah>0) then
     begin
      pdf.SetXY(10,PdfY);
      pdf.Cell(140,7,pQry.FieldByName('m_nama').AsString,'1',0,'L',0);
      pdf.SetX(150);
      Pb:=Form6.SG.Cells[6,ct];
      pdf.Cell(50,7,rupiah(IntToStr(Jumlah)),'1',0,'L',0);
      PdfY := PdfY + 7;
     end;
   Total_Masuk:= Total_Masuk + Jumlah;
   Jumlah:=0;
   ct:=0;
   if(PdfY<263) then
     begin
      pQry.Next;
     end
   else
   begin
    pdf.AddPage();
    pdf.SetFont(ffHelvetica,fsBold,14);
    pdf.SetTextColor(cRed);
    pdf.Image('logo.png',10,6,15);
    pdf.SetXY(30,15);
    pdf.Cell(170,8,'PGKICIC Laporan keuangan Bulan : ' + Bl + ' Tahun: ' + Th,'1',0,'C',0);
    pdf.SetTextColor(cBlue);
    pdf.SetXY(10,23);
    pdf.Cell(140,7,'Item','1',0,'C',0);
    pdf.SetX(150);
    pdf.Cell(50,7,'Jumlah','1',0,'C',0);
    pdf.SetTextColor(cBlack);
    pdf.SetFont(ffHelvetica,fsNormal,12);
    PdfY := 30;
    PQry.Next;
   end;
 end;
 pdf.SetXY(10,PdfY);
 pdf.SetTextColor(cRed);
 pdf.Cell(140,7,'Total masuk','1',0,'R',0);
 pdf.SetX(150);
 pdf.Cell(50,7,rupiah(IntToStr(Total_Masuk)),'1',0,'L',0);
 PdfY:= PdfY + 7;
 pdf.SetTextColor(cBlue);
 pdf.SetXY(10,PdfY);
 if(PdfY < 260) then
  begin
   pdf.Cell(140,7,'Item Keluar','1',0,'C',0);
   pdf.SetX(150);
   pdf.Cell(50,7,'Jumlah','1',0,'C',0);
   pdf.SetTextColor(cBlack);
   PdfY := PdfY + 7;
   pQry.Clear;
   pQry.SQL.Text := 'select * from keluar';
   pQry.DataBase:=Scon;
   pQry.Open;
   Jumlah:=0;
   Total_Keluar:=0;
   ct:=0;
   while not pQry.EOF do
    begin
      Pb:=pQry.FieldByName('k_kode').AsString;
      while ct<i do
       begin
        ct:= ct +1;
        if(Form6.SG.Cells[3,ct]=Pb) then
          begin
           Jm:=StrToInt(hapus(Form6.SG.Cells[7,ct]));
           Jumlah:=Jumlah + Jm;
          end;
       end;
       if(Jumlah>0) then
         begin
          pdf.SetXY(10,PdfY);
          pdf.Cell(140,7,pQry.FieldByName('k_nama').AsString,'1',0,'L',0);
          pdf.SetX(150);
          Pb:=Form6.SG.Cells[6,ct];
          pdf.Cell(50,7,rupiah(IntToStr(Jumlah)),'1',0,'L',0);
          PdfY := PdfY + 7;
         end;
       Total_Keluar:= Total_Keluar + Jumlah;
       Jumlah:=0;
       ct:=0;
       if(PdfY<263) then
         begin
           pQry.Next;
         end
       else
        begin
          pdf.AddPage();
          pdf.SetFont(ffHelvetica,fsBold,14);
          pdf.SetTextColor(cRed);
          pdf.Image('logo.png',10,6,15);
          pdf.SetXY(30,15);
          pdf.Cell(170,8,'PGKICIC Laporan keuangan Bulan : ' + Bl + ' Tahun: ' + Th,'1',0,'C',0);
          pdf.SetTextColor(cBlue);
          pdf.SetXY(10,23);
          pdf.Cell(140,7,'Item','1',0,'C',0);
          pdf.SetX(150);
          pdf.Cell(50,7,'Jumlah','1',0,'C',0);
          pdf.SetTextColor(cBlack);
          pdf.SetFont(ffHelvetica,fsNormal,12);
          PdfY := 30;
          PQry.Next;
        end;
   end;
  end;
 pdf.SetXY(10,PdfY);
 pdf.SetTextColor(cRed);
 pdf.Cell(140,7,'Total keluar','1',0,'R',0);
 pdf.SetX(150);
 pdf.Cell(50,7,rupiah(IntToStr(Total_Keluar)),'1',0,'L',0);
 PdfY := PdfY + 7;
 pdf.SetXY(10,PdfY);
 pdf.SetTextColor(cRed);
 pdf.Cell(140,7,'Saldo akhir','1',0,'R',0);
 pdf.SetX(150);
 pdf.Cell(50,7,rupiah(IntToStr(Total_Masuk - Total_Keluar)),'1',0,'L',0);
 pdf.SaveToFile(filename + '.pdf');
 pdf.Free;
 ShowMessage('Sudah selesai!');
 pQry.Close;
 pQry.Free;
 STran.Free;
 SCon.Free;
end;
end.


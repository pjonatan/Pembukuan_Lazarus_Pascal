unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
   Unit2, Unit3, Unit4, Unit5, Unit6;

type

  { TForm1 }

  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    procedure Panel1Click(Sender: TObject);
    procedure Panel2Click(Sender: TObject);
    procedure Panel3Click(Sender: TObject);
    procedure Panel4Click(Sender: TObject);
    procedure Panel5Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Panel3Click(Sender: TObject);
begin
    Form4.Visible:=True;
end;

procedure TForm1.Panel4Click(Sender: TObject);
begin
    Form5.Visible:=True;
end;
procedure TForm1.Panel5Click(Sender: TObject);
begin
    Form6.Visible:=True;
end;
procedure TForm1.Panel1Click(Sender: TObject);
begin
  Form2.Visible:=True;
end;

procedure TForm1.Panel2Click(Sender: TObject);
begin
  Form3.Visible:=True;
end;


end.


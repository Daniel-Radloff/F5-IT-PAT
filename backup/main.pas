unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, FileCtrl, Menus,
  ComboEx, StdCtrls, ExtCtrls, EditBtn, Buttons, RTTICtrls, Engine,
  Custom_Classes;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnExit_Select: TButton;
    btnNext_Select: TButton;
    btnReset_Select: TButton;
    btnHelp: TButton;
    btnShowHints: TButton;
    btnOther: TButton;
    cmbStart: TComboBox;
    cmbFinnal: TComboBox;
    edtFilterStart: TEdit;
    edtFilterFinal: TEdit;
    gbxWelcome: TGroupBox;
    memWelcome: TMemo;
    pnlLocationSelect: TPanel;
    pnlTimeSelect: TPanel;
    StaticText1: TStaticText;
    tedtStart: TTimeEdit;
    tedtEnd: TTimeEdit;
    procedure FormActivate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormActivate(Sender: TObject);
var
		  x: pStopArray;
begin
  x := Engine.MainEngine.GiveStopsArr();
  y := x^[1];
end;

end.


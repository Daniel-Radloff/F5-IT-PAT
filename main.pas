unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, FileCtrl, Menus,
  ComboEx, StdCtrls, ExtCtrls, EditBtn, Buttons, RTTICtrls, Engine,
  Custom_Classes, EngineInterface;

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
    procedure btnOtherClick(Sender: TObject);
    procedure btnShowHintsClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  test: pAPpEngine;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormActivate(Sender: TObject);
var
  x: Integer;
  a: pAppEngine;
begin
  //test := EngineInterface.Engine();
  x := 1;
end;

procedure TForm1.btnOtherClick(Sender: TObject);
var
  routes: pBusRouteArr;
  x: FullRouteArr;
begin
  routes := test^.GiveRoutesArr();
  x := test^.GetRoute('2b32bf','e82700',660,800);
  test^.AdminAddToRoute(routes[3],2,True);
end;

procedure TForm1.btnShowHintsClick(Sender: TObject);
begin
  test := EngineInterface.Engine();
end;

end.


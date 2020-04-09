unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, FileCtrl, Menus,
  ComboEx, StdCtrls, ExtCtrls, EditBtn, Buttons, RTTICtrls;

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
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

end.


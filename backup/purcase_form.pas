unit Purcase_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TForm2 }

  TForm2 = class(TForm)
    btnHelp: TButton;
    btnExit: TButton;
    btnReset: TButton;
    btnPurchase: TButton;
    btnShowHints: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    cxgRouteSpecify: TCheckGroup;
    gbxSelectRoute: TGroupBox;
    gbxOverview: TGroupBox;
    gbxActions: TGroupBox;
    gbxConfirm: TGroupBox;
    lsbxRouteOptions: TListBox;
    Memo1: TMemo;
    memOverview: TMemo;
    pnlOverview: TPanel;
  private

  public

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

end.


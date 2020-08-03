unit Admin_interface;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, DBGrids, StdCtrls,
  ExtCtrls, Data_Connection, db;

type

  { TForm3 }

  TForm3 = class(TForm)
    btnEdit: TButton;
    btnReset: TButton;
    btnComit: TButton;
    btnAdd: TButton;
    btnDelete: TButton;
    btnModify: TButton;
    btnHints: TButton;
    btnHelp: TButton;
    btnExit: TButton;
    btnSearch: TButton;
    btnSwitch: TButton;
    btnStartExit: TButton;
    DBGrid1: TDBGrid;
    edtFilter: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    lblFilter: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    memInfo1: TMemo;
    memInfo2: TMemo;
    memInfo3: TMemo;
    pnlStartInfo: TPanel;
    pnlHelp: TPanel;
  private

  public

  end;

var
  Form3: TForm3;

implementation

{$R *.lfm}

end.


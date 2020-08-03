unit Admin_edit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TForm4 }

  TForm4 = class(TForm)
    btnHints: TButton;
    btnHelp: TButton;
    btnRemove: TButton;
    btnInsert: TButton;
    btnAppend: TButton;
    btnModify: TButton;
    btnExit: TButton;
    btnUndo: TButton;
    btnConfirm: TButton;
    btnNewStop: TButton;
    btnGenLin: TButton;
    btnGenRotation: TButton;
    edtRoute: TEdit;
    GroupBox1: TGroupBox;
    gbxStops: TGroupBox;
    gbxChanges: TGroupBox;
    gbxConfirm: TGroupBox;
    Label1: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    Memo1: TMemo;
    Panel1: TPanel;
  private

  public

  end;

var
  Form4: TForm4;

implementation

{$R *.lfm}

end.


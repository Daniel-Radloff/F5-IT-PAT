unit Admin_edit_add_stop;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TForm5 }

  TForm5 = class(TForm)
    btnAdd: TButton;
    btnRemove: TButton;
    btnCancel: TButton;
    btnConfirm: TButton;
    edtFilter: TEdit;
    edtName: TEdit;
    gbxName: TGroupBox;
    gbxClose: TGroupBox;
    GroupBox1: TGroupBox;
    ListBox1: TListBox;
    ListBox2: TListBox;
    memWarn: TMemo;
    pnlClose: TPanel;
  private

  public

  end;

var
  Form5: TForm5;

implementation

{$R *.lfm}

end.


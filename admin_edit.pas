unit Admin_edit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
           EngineInterface, Engine, Custom_Classes;

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
    btnConfirm: TButton;
    btnGenLin: TButton;
    btnGenRotation: TButton;
    edtStartTime: TEdit;
    edtEndTime: TEdit;
    edtRoute: TEdit;
    GroupBox1: TGroupBox;
    gbxStops: TGroupBox;
    gbxChanges: TGroupBox;
    gbxConfirm: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ListBox2: TListBox;
    Memo1: TMemo;
    Panel1: TPanel;
    procedure btnExitClick(Sender: TObject);
  private
    pToCurrentRoute : pRoute;
  public
    procedure InitAdminEdit(lbx:TListBox; StopsInRoute: strArr; Route:pRoute);

  end;

var
  Form4: TForm4;

implementation

{$R *.lfm}

{ TForm4 }

procedure TForm4.btnExitClick(Sender: TObject);
begin
  Form4.Close;
end;

procedure TForm4.InitAdminEdit(lbx: TListBox; StopsInRoute: strArr;
  Route: pRoute);
var
  each: String;
begin
  lbx.Clear;
  for each in StopsInRoute do
    lbx.Items.Add(each);
  edtStartTime.Caption := Route^.GetRouteStartStr();
  edtEndTime.Caption := Route^.GetRouteEndStr();
  edtRoute.Caption := Route^.GetHID();
  pToCurrentRoute := Route;
end;

end.


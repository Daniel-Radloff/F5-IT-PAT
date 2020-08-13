unit Admin_interface;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, DBGrids, StdCtrls,
  ExtCtrls, Data_Connection, db, EngineInterface, Engine, Custom_Classes,
  Admin_edit;

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
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnModifyClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure btnStartExitClick(Sender: TObject);
    procedure btnSwitchClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    bTableRoutes : boolean;
    procedure AddRoute();
  public

  end;

var
  Form3: TForm3;

implementation

{$R *.lfm}

{ TForm3 }

procedure TForm3.btnStartExitClick(Sender: TObject);
begin
  pnlStartInfo.Visible := False;
  GroupBox1.Enabled := True;
  GroupBox2.Enabled := True;
  GroupBox3.Enabled := True;
  GroupBox4.Enabled := True;
  MainEngine.AdminShowTbl('R');
  // This is annoying but it is neccicary for the correct format
  DBGrid1.Columns.Items[3].DisplayFormat := '#0.00';
  pnlStartInfo.Enabled := False;
end;

procedure TForm3.btnSwitchClick(Sender: TObject);
begin
  // not strictly necicary use of a switch but whatever
  case bTableRoutes of
  True : begin
    bTableRoutes := False;
    btnAdd.Caption := 'Add New Stop';
    btnDelete.Caption := 'Delete Stop';
    btnModify.Enabled := False;
    EngineInterface.MainEngine.AdminShowTbl('B');
  end;
  False : begin
    bTableRoutes := True;
    btnAdd.Caption := 'Add New Route';
    btnDelete.Caption := 'Delete Route';
    btnModify.Enabled := True;
    EngineInterface.MainEngine.AdminShowTbl('R');
    // Again for correct format
    DBGrid1.Columns.Items[3].DisplayFormat := '#0.00';
  end;
end;
end;

procedure TForm3.btnModifyClick(Sender: TObject);
var
  sID: String;
  RouteToEdit: pRoute;
  StopsInRoute: strArr;
begin
  // Take the selected row at 1st column as value
  sID := DBGrid1.Columns.Items[0].Field.AsString;
  RouteToEdit := EngineInterface.MainEngine.GetRoutePtr(sID);
  StopsInRoute := RouteToEdit^.getStopsInfo;
  Admin_edit.Form4.InitAdminEdit(Admin_edit.Form4.ListBox2,StopsInRoute,
                                 RouteToEdit);
  Admin_edit.Form4.ShowModal;
end;

procedure TForm3.btnSearchClick(Sender: TObject);
var
  sSearch: TCaption;
begin
  sSearch := edtFilter.Text;
  // want to use some ado code to do this cause I have none
end;

procedure TForm3.btnExitClick(Sender: TObject);
begin
  Form3.Close;
end;

procedure TForm3.btnAddClick(Sender: TObject);
var
  RouteName, RoutePrice, RouteStart, RouteEnd: String;
  each: Char;
  test: Longint;
begin

end;

procedure TForm3.btnDeleteClick(Sender: TObject);
var
  sID: String;
begin
  sID := DBGrid1.Columns.Items[0].Field.AsString;
  MainEngine.AdminDeleteRoute(sID);
  MainEngine.AdminShowTbl('R');
  // In Order to update changes we must restart the AppEngine
  MainEngine.ReStart();
end;

procedure TForm3.FormActivate(Sender: TObject);
begin
  bTableRoutes := True;
end;

procedure TForm3.AddRoute();
var
  RouteName, RoutePrice, RouteStart, RouteEnd: String;
  bPass: Boolean;
  test: Longint;
  each: Char;
begin
  // Set the first RouteName to the default
  RouteName := 'First stop - Last stop (Color)';
  while True do
  begin
    // Use a loop so we can try again
  bPass := True;
  RouteName := InputBox('Create Route', 'Route Name:', RouteName);
  // Check for any invalid inputs
  for each in RouteName do
    begin
    // TryStrToInt is a anoying function in this context, test is not used but
    //             is needed
      if TryStrToInt(each,test) = True then
      begin
        ShowMessage('A Routes Name may not contain any numbers please re-enter '
                       + ' the route name without any numbers');
        bPass := False;
      end;
    end;
  // if no int then continue
  if bPass = True then break;
  // Now we don't need to re-enter the entire name.
  //     This is much less annoying... pls give me marks :(
  end;
  while True do
  begin
  RoutePrice := InputBox('Price','Please give the standard rate for the ticket',
                                         '10, R10.45');
  end;
  RouteStart := InputBox('Starting Time', 'Please enter a staring time:',
                                   'Enter in format XX:XX 24 hour time');
  RouteEnd := InputBox('End Time', 'Please enter the End time of the Route:',
                            'Please enter in format XX:XX 24 hour time');
end;

end.


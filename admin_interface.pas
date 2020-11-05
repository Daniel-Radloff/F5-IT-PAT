unit Admin_interface;
// Daniel Radloff
// Provides interface for route and stop modification
//          Restarting is necicary because of the
//          way arrays and pointers interface and
//          are assinged to each other. I have yet to find
//          a solution for this

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, DBGrids, StdCtrls,
  ExtCtrls, Data_Connection, DB, EngineInterface, Engine, Custom_Classes,
  Admin_edit, Admin_edit_add_stop;

type

  { TForm3 }

  TForm3 = class(TForm)
    btnAdd: TButton;
    btnDelete: TButton;
    btnModify: TButton;
    btnHints: TButton;
    btnHelp: TButton;
    btnSwitch: TButton;
    btnStartExit: TButton;
    btnExit: TButton;
    DBGrid1: TDBGrid;
    edtFilter: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    lblFilter: TLabel;
    Memo2: TMemo;
    memInfo1: TMemo;
    memInfo2: TMemo;
    memInfo3: TMemo;
    pnlStartInfo: TPanel;
    pnlHelp: TPanel;
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnHintsClick(Sender: TObject);
    procedure btnModifyClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure btnStartExitClick(Sender: TObject);
    procedure btnSwitchClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    bTableRoutes: boolean;
    bRestart: boolean;
    procedure AddRoute();
    procedure AddStop();
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
  btnExit.Enabled := True;
  MainEngine.AdminShowTbl('R');
  edtFilter.Text := 'Routes';
  // This is annoying but it is neccicary for the correct format
  DBGrid1.Columns.Items[3].DisplayFormat := '#0.00';
  pnlStartInfo.Enabled := False;
end;

procedure TForm3.btnSwitchClick(Sender: TObject);
begin
  // not strictly necicary use of a switch but whatever
  case bTableRoutes of
    True:
    begin
      bTableRoutes := False;
      btnAdd.Caption := 'Add New Stop';
      btnDelete.Caption := 'Delete Stop';
      edtFilter.Text := 'Stop';
      btnModify.Enabled := False;
      EngineInterface.MainEngine.AdminShowTbl('B');
    end;
    False:
    begin
      bTableRoutes := True;
      btnAdd.Caption := 'Add New Route';
      btnDelete.Caption := 'Delete Route';
      edtFilter.Text := 'Route';
      btnModify.Enabled := True;
      EngineInterface.MainEngine.AdminShowTbl('R');
      // Again for correct format
      DBGrid1.Columns.Items[3].DisplayFormat := '#0.00';
    end;
  end;
  if bRestart = True then
  begin
    btnModify.Enabled := False;
    ShowMessage('Please restart the program for you changes to take effect');
  end;
end;

procedure TForm3.btnModifyClick(Sender: TObject);
var
  sID: string;
  RouteToEdit: pRoute;
  StopsInRoute: strArr;
begin
  // Take the selected row at 1st column as value
  sID := DBGrid1.Columns.Items[0].Field.AsString;
  RouteToEdit := EngineInterface.MainEngine.GetRoutePtr(sID);
  StopsInRoute := RouteToEdit^.getStopsInfo;
  Admin_edit.Form4.InitAdminEdit(Admin_edit.Form4.ListBox2, StopsInRoute,
    RouteToEdit);
  Admin_edit.Form4.ShowModal;
  MainEngine.AdminShowTbl('R');
  DBGrid1.Columns.Items[3].DisplayFormat := '#0.00';
end;

procedure TForm3.btnSearchClick(Sender: TObject);
var
  sSearch, sTable: string;
begin
  sSearch := edtFilter.Text;
  case bTableRoutes of
    True : sTable := 'SELECT * FROM RoutesTbl WHERE RouteID LIKE "%' + sSearch +
                     '%" or RouteName LIKE "%' + sSearch + '%" or EndTime LIKE '
                     + '"%' + sSearch + '%" or StartTime LIKE "%' + sSearch +
                       '%" or TicketPrice LIKE "%' + sSearch + '%"';
    False : sTable := 'BusStopTBL WHERE (BusStopID, Location, Close, Name) LIKE'
                      + ' "% ';
  end;
  With DataBase do
  begin
    SQLQuery1.Close;
    SQLQuery1.SQL.Text := sTable;
    SQLQuery1.Open;
    SQLTransaction1.Commit;
  end;
  // want to use some ado code to do this cause I have none
end;

procedure TForm3.btnExitClick(Sender: TObject);
begin
  if bRestart = True then
  begin
    showMessage('Important Structural Modifications to Database Detected' + #13
                           + 'Exiting Program, restarting to avoid corruption' +
                           ' and for changes to take effect');
    Application.Terminate;
    exit()
  end;
  Showmessage('No Critical Modifications Registered. You do not need to '+
                  'restart for changes to take effect');
  Form3.Close;
end;

procedure TForm3.btnHelpClick(Sender: TObject);
begin
  ShowMessage('Select a button to modify the table');
end;

procedure TForm3.btnHintsClick(Sender: TObject);
begin
  Form5.ShowModal;
end;

procedure TForm3.btnAddClick(Sender: TObject);
var
  sConfirm: String;
begin
  sConfirm := InputBox('Add', 'Please confirm that you would like to add a item'
                              , 'No, Type YES to Confirm');
  if sConfirm = 'YES' then
  begin
  if bTableRoutes = True then
  begin
    AddRoute();
    MainEngine.AdminShowTbl('R');
    DBGrid1.Columns.Items[3].DisplayFormat := '#0.00';
  end
  else
  begin
    AddStop();
    MainEngine.AdminShowTbl('B');
  end;
  bRestart := True;
  btnModify.Enabled := False;
  showMessage('Important Structural Modifications to Database Detected' + #13
                           + 'Please restart for changes to take effect and' +
                           ' Functionality to return to normal');
end;
end;

procedure TForm3.btnDeleteClick(Sender: TObject);
var
  sID, sConfirm: string;
begin
  sConfirm := InputBox('Delete','Please confirm that you want to delete this' +
                                        ' item.', 'NO, type YES to Confirm');
  if sConfirm = 'YES' then
  begin
  if bTableRoutes = True then
  begin
    sID := DBGrid1.Columns.Items[0].Field.AsString;
    MainEngine.AdminDeleteRoute(sID);
    MainEngine.AdminShowTbl('R');
    DBGrid1.Columns.Items[3].DisplayFormat := '#0.00';
  end
  else
  begin
    sID := DBGrid1.Columns.Items[0].Field.AsString;
    MainEngine.AdminDeleteStop(sID);
    MainEngine.AdminShowTbl('B');
  end;
  bRestart := True;
  btnModify.Enabled := False;
  ShowMessage('You need to restart the program to continue making route'
    + 'modifications.');
  ShowMessage('Your changes will only take effect in the main program once'
    + ' you restart');
  // In Order to update changes we must restart the AppEngine
  //    but delphi thinks otherwize
  end;
end;

procedure TForm3.FormActivate(Sender: TObject);
begin
  bTableRoutes := True;
end;

procedure TForm3.AddRoute();
var
  RouteName, RoutePrice, RouteStart, RouteEnd: string;
  bPass: boolean;
  test: longint;
  each: char;
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
      if TryStrToInt(each, test) = True then
      begin
        ShowMessage('A Routes Name may not contain any numbers please re-enter '
          + ' the route name without any numbers');
        bPass := False;
      end;
    end;
    // if no int then continue
    if bPass = True then
      break;
    // Now we don't need to re-enter the entire name.
    //     This is much less annoying... pls give me marks :(
  end;
  RoutePrice := '10, 10.45';
  while True do
  begin
    bPass := True;
    RoutePrice := InputBox('Price', 'Please give the standard rate for the ticket',
      RoutePrice);
    for each in RoutePrice do
    begin
      //   Check for any letters
      if TryStrToInt(each, test) = False then
        if (each = ',') then
        begin
          ShowMessage('Please do not use any letters in this field. Use "." '
            + ' to indicate decimals');
          bPass := False;
          continue;
        end;
    end;
    if bPass = True then
      break;
  end;

  RouteStart := '0000';
  RouteEnd := '0000';

  MainEngine.AdminAddNewRoute(RouteName, RouteStart, RouteEnd,
    StrToFloat(RoutePrice));
end;

procedure TForm3.AddStop();
var
  StopLocation: string;
  each: Char;
  itest: Longint;
  bPass: Boolean;
begin
  bPass := True;
  While True do
  begin
  StopLocation := 'General area around Stop';
  StopLocation := InputBox('Enter Stop Location', 'Please enter the location' +
    ' of the stop', StopLocation);
  bPass := True;
  for each in StopLocation do
      if TryStrToInt(each,itest) = True then bPass := False;
  if bPass = True then
  break
  else
    ShowMessage('Please Do not enter numbers in a stop name');
  end;
  MainEngine.AdminAddNewStop(StopLocation);
end;

end.

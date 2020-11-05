unit Main;
// Daniel Radloff
// Initial interface. Used to access all other parts of program
// Also used to enter data for route recomendation engine

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, FileCtrl, Menus,
  ComboEx, StdCtrls, ExtCtrls, EditBtn, Buttons, RTTICtrls, Engine,
  Custom_Classes, EngineInterface, Purcase_form, Admin_interface,
  Admin_edit_add_stop;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnExit_Select: TButton;
    btnNext_Select: TButton;
    btnReset_Select: TButton;
    btnShowMap: TButton;
    btnOther: TButton;
    btnhelp: TButton;
    cmbStart: TComboBox;
    cmbFinnal: TComboBox;
    gbxWelcome: TGroupBox;
    lblEnd: TLabel;
    lblStart: TLabel;
    memWelcome: TMemo;
    pnlLocationSelect: TPanel;
    pnlTimeSelect: TPanel;
    StaticText1: TStaticText;
    tedtStart: TTimeEdit;
    tedtEnd: TTimeEdit;
    procedure btnExit_SelectClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnNext_SelectClick(Sender: TObject);
    procedure btnOtherClick(Sender: TObject);
    procedure btnReset_SelectClick(Sender: TObject);
    procedure btnShowMapClick(Sender: TObject);
    procedure cmbFinnalClick(Sender: TObject);
    procedure cmbFinnalEnter(Sender: TObject);
    procedure cmbFinnalSelect(Sender: TObject);
    procedure cmbStartClick(Sender: TObject);
    procedure cmbStartEnter(Sender: TObject);
    procedure cmbStartSelect(Sender: TObject);
    procedure edtEndTimeEditingDone(Sender: TObject);
    procedure tedtEndChange(Sender: TObject);
    procedure tedtEndEditingDone(Sender: TObject);
    procedure tedtStartChange(Sender: TObject);
    procedure tedtStartEditingDone(Sender: TObject);
  private
    // I can't do anything else ... im sorry.
    procedure InitProgram();
  public

  end;

var
  Form1: TForm1;
  test: integer;
  Userdata: FindRoutesInput;

implementation

{$R *.lfm}

{ TForm1 }


procedure TForm1.tedtEndChange(Sender: TObject);
begin
  if test <> 1 then
    InitProgram();
end;

procedure TForm1.tedtEndEditingDone(Sender: TObject);
var
  iMinutes, iHours: LongInt;
  sLine: string;
begin
  sLine := tedtStart.Text;
  iHours := StrToInt(COPY(sLine,0,2));
  iMinutes := StrToInt(COPY(sline,4,2));
  Userdata.EndTime := iHours * 60 + iMinutes
end;

procedure TForm1.tedtStartChange(Sender: TObject);
begin
  if test <> 1 then
    InitProgram();
end;

procedure TForm1.tedtStartEditingDone(Sender: TObject);
var
  sLine: string;
  iHours, iMinutes: LongInt;
begin
  sLine := tedtStart.Text;
  iHours := StrToInt(COPY(sLine,0,2));
  iMinutes := StrToInt(COPY(sline,4,2));
  Userdata.StartTime := iHours * 60 + iMinutes;
end;

procedure TForm1.InitProgram();
var
  AllStops: pArr;
  stop: pBusStop;
begin
  test := EngineInterface.Engine;
  AllStops := EngineInterface.MainEngine.GiveStopsArr();
  for stop in AllStops do
  begin
    cmbStart.Items.Add(stop^.GetName);
    cmbFinnal.Items.Add(stop^.GetName);
  end;
  cmbStart.Items.Delete(0);
  cmbFinnal.Items.Delete(0);
  Userdata.EndTime := -1;
  Userdata.StartTime := -1;
  AllStops := nil;
end;

procedure TForm1.btnOtherClick(Sender: TObject);
var
  routes: pBusRouteArr;
  x: FullRouteArr;
begin
  if test <> 1 then
    InitProgram();
  Admin_interface.Form3.ShowModal;
end;

procedure TForm1.btnHelpClick(Sender: TObject);
begin
  if test <> 1 then
    InitProgram();
  ShowMessage('Fill out the 4 boxes with Locations and times and click next to'+
                    ' generate routes to your destination.');
  ShowMessage('Select the Admin button to modify the program.');
end;

procedure TForm1.btnExit_SelectClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.btnNext_SelectClick(Sender: TObject);
begin
  if (Userdata.EndTime <> -1) and (Userdata.StartTime <> -1) and
    (Userdata.EndStop <> nil) and (Userdata.StartStop <> nil) then
  begin
    Purcase_form.ViableRoutes := MainEngine.GetRoute(Userdata);
    Purcase_form.Form2.ShowModal;
  end
  else
    ShowMessage('Please fill in all required fields');
end;

procedure TForm1.btnReset_SelectClick(Sender: TObject);
begin
  tedtEnd.Text := '23:59';
  tedtStart.Text := '00:00';
  cmbStart.ItemIndex := -1;
  cmbFinnal.ItemIndex := -1;
  Userdata.EndTime := -1;
  Userdata.StartTime := -1;
  Userdata.EndStop := nil;
  Userdata.StartStop := nil;
end;

procedure TForm1.btnShowMapClick(Sender: TObject);
begin
  if test <> 1 then
    InitProgram();
  Form5.ShowModal();
end;

procedure TForm1.cmbFinnalClick(Sender: TObject);
begin
  if test <> 1 then
    InitProgram();
end;

procedure TForm1.cmbFinnalEnter(Sender: TObject);
begin
  if test <> 1 then
    InitProgram();
end;

procedure TForm1.cmbFinnalSelect(Sender: TObject);
var
  Stops: pArr;
begin
  if cmbStart.ItemIndex = cmbFinnal.ItemIndex then
  begin
    ShowMessage('Please select two different stops. Your starting stop is equal'
      + ' to your finnal destination.');
    cmbFinnal.ItemIndex := -1;
    Exit;
  end;
  Stops := MainEngine.GiveStopsArr;
  Userdata.EndStop := Stops[cmbFinnal.ItemIndex];
  Stops := nil;
end;

procedure TForm1.cmbStartClick(Sender: TObject);
begin
  if test <> 1 then
    InitProgram();
end;

procedure TForm1.cmbStartEnter(Sender: TObject);
begin
  if test <> 1 then
    InitProgram();
end;

procedure TForm1.cmbStartSelect(Sender: TObject);
var
  Stops: pArr;
begin
  if cmbStart.ItemIndex = cmbFinnal.ItemIndex then
  begin
    ShowMessage('Please select two different stops. Your starting stop is equal'
      + ' to your finnal destination.');
    cmbStart.ItemIndex := -1;
    Exit;
  end;
  Stops := MainEngine.GiveStopsArr;
  Userdata.StartStop := Stops[cmbStart.ItemIndex];
  Stops := nil;
end;

procedure TForm1.edtEndTimeEditingDone(Sender: TObject);
begin

end;


end.

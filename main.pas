unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, FileCtrl, Menus,
  ComboEx, StdCtrls, ExtCtrls, EditBtn, Buttons, RTTICtrls, Engine,
  Custom_Classes, EngineInterface, Purcase_form, Admin_interface;

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
    edtStartTime: TEdit;
    edtEndTime: TEdit;
    gbxWelcome: TGroupBox;
    lblEnd: TLabel;
    lblStart: TLabel;
    memWelcome: TMemo;
    pnlLocationSelect: TPanel;
    pnlTimeSelect: TPanel;
    StaticText1: TStaticText;
    procedure btnHelpClick(Sender: TObject);
    procedure btnNext_SelectClick(Sender: TObject);
    procedure btnOtherClick(Sender: TObject);
    procedure btnReset_SelectClick(Sender: TObject);
    procedure btnShowHintsClick(Sender: TObject);
    procedure cmbFinnalClick(Sender: TObject);
    procedure cmbFinnalEnter(Sender: TObject);
    procedure cmbFinnalSelect(Sender: TObject);
    procedure cmbStartClick(Sender: TObject);
    procedure cmbStartEnter(Sender: TObject);
    procedure cmbStartSelect(Sender: TObject);
    procedure edtEndTimeEditingDone(Sender: TObject);
    procedure edtStartTimeEditingDone(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    // I can't do anything else ... im sorry.
    procedure InitProgram();
  public

  end;

var
  Form1: TForm1;
  test: integer;
  Userdata : FindRoutesInput;

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

procedure TForm1.InitProgram();
var
  AllStops: pArr;
  stop : pBusStop;
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
  if test <> 1 then InitProgram();
  Admin_interface.Form3.ShowModal;
end;

procedure TForm1.btnHelpClick(Sender: TObject);
begin
  if test <> 1 then InitProgram();
  MainEngine.ReStart();
end;

procedure TForm1.btnNext_SelectClick(Sender: TObject);
begin
  if (Userdata.EndTime <> -1) and (Userdata.StartTime <> -1)
     and (Userdata.EndStop <> nil) and (Userdata.StartStop <> nil) then
     begin
     Purcase_form.ViableRoutes := MainEngine.GetRoute(Userdata);
     Purcase_form.Form2.ShowModal;
     end
  else showmessage('Please fill in all required fields');
end;

procedure TForm1.btnReset_SelectClick(Sender: TObject);
begin
  edtStartTime.Text := '00:00';
  edtEndTime.Text := '23:59';
  cmbStart.ItemIndex := -1;
  cmbFinnal.ItemIndex := -1;
  Userdata.EndTime := -1;
  Userdata.StartTime := -1;
  Userdata.EndStop := nil;
  Userdata.StartStop := nil;
end;

procedure TForm1.btnShowHintsClick(Sender: TObject);
begin
  if test <> 1 then InitProgram();
end;

procedure TForm1.cmbFinnalClick(Sender: TObject);
begin
  if test <> 1 then InitProgram();
end;

procedure TForm1.cmbFinnalEnter(Sender: TObject);
begin
  if test <> 1 then InitProgram();
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
  if test <> 1 then InitProgram();
end;

procedure TForm1.cmbStartEnter(Sender: TObject);
begin
  if test <> 1 then InitProgram();
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
  Stops := Nil;
end;

procedure TForm1.edtEndTimeEditingDone(Sender: TObject);
var
  sline: string;
  iHours, iMinutes: LongInt;
begin
  sline := edtEndTime.Text;
  try
    // format can be in either
       // 0000
       //  or
       // 00:00
    case length(sline) of
    4 : begin
      iHours := StrToInt(copy(sLine,0,2));
      iMinutes := StrToInt(copy(sLine,2,2));
      // Will this work???!??!!?
      if (iHours >= 24) or (iMinutes >= 60) then
      begin
      showmessage('Please enter a time is one of the following formats:' + #13 +
                          '"0000" or "23:59"' + #13 + 'Do Not Enter a number' +
                          ' above 23 for hours, use 00 and do not use a number '
                          + 'above 59 for minutes, increase the amount of hours'
                          );
      Exit;
      end;
      // if end
      Userdata.EndTime := iHours*60 + iMinutes;
      end;
      // case end 4
      5 : begin
        iHours := StrToInt(copy(sLine,0,2));
        iMinutes := StrToInt(copy(sLine,4,2));

        if (iHours >= 24) or (iMinutes >= 60) then
        begin
        showmessage('Please enter a time is one of the following formats:' + #13 +
                          '"0000" or "23:59"' + #13 + 'Do Not Enter a number' +
                          ' above 23 for hours, use 00 and do not use a number '
                          + 'above 59 for minutes, increase the amount of hours'
                          );
        Exit;
        end;
        // if end
        Userdata.EndTime := iHours*60+iMinutes;
      end;
      // case end 5
    end;
  except
    showmessage('Please enter a time is one of the following formats:' + #13 +
                          '"0000" or "23:59"' + #13 + 'Do Not Enter a number' +
                          ' above 23 for hours, use 00 and do not use a number '
                          + 'above 59 for minutes, increase the amount of hours'
                          );
  end;
end;


procedure TForm1.edtStartTimeEditingDone(Sender: TObject);
var
  sline: string;
  iHours, iMinutes: LongInt;
begin
  // This input needs to be fixed and be more generic
  sline := edtStartTime.Text;
  try
    // format can be in either
       // 0000
       //  or
       // 00:00
    case length(sline) of
    4 : begin
      iHours := StrToInt(copy(sLine,0,2));
      iMinutes := StrToInt(copy(sLine,2,2));
      // Will this work???!??!!?
      if (iHours >= 24) or (iMinutes >= 60) then
      begin
      showmessage('Please enter a time is one of the following formats:' + #13 +
                          '"0000" or "23:59"' + #13 + 'Do Not Enter a number' +
                          ' above 23 for hours, use 00 and do not use a number '
                          + 'above 59 for minutes, increase the amount of hours'
                          );
      Exit;
      end;
      // if end
      Userdata.StartTime := iHours*60 + iMinutes;
      end;
      // case end 4
      5 : begin
        iHours := StrToInt(copy(sLine,0,2));
        iMinutes := StrToInt(copy(sLine,4,2));

        if (iHours >= 24) or (iMinutes >= 60) then
        begin
        showmessage('Please enter a time is one of the following formats:' + #13 +
                          '"0000" or "23:59"' + #13 + 'Do Not Enter a number' +
                          ' above 23 for hours, use 00 and do not use a number '
                          + 'above 59 for minutes, increase the amount of hours'
                          );
        Exit;
        end;
        // if end
        Userdata.StartTime := iHours*60+iMinutes;
      end;
      // case end 5
    end;
  except
    showmessage('Please enter a time is one of the following formats:' + #13 +
                          '"0000" or "23:59"' + #13 + 'Do Not Enter a number' +
                          ' above 23 for hours, use 00 and do not use a number '
                          + 'above 59 for minutes, increase the amount of hours'
                          );
  end;
end;
end.


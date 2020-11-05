unit Admin_edit;
// Daniel RAdloff
// Modifys Routes and edits data

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  EditBtn, EngineInterface, Engine, Custom_Classes, Admin_edit_add_stop;

type

  { TForm4 }

  TForm4 = class(TForm)
    btnHints: TButton;
    btnHelp: TButton;
    btnRemove: TButton;
    btnInsert: TButton;
    btnAppend: TButton;
    btnModify: TButton;
    btnConfirm: TButton;
    btnSetPrice: TButton;
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
    tedtStart: TTimeEdit;
    tedtEnd: TTimeEdit;
    procedure btnAppendClick(Sender: TObject);
    procedure btnConfirmClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnHintsClick(Sender: TObject);
    procedure btnInsertClick(Sender: TObject);
    procedure btnModifyClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnSetPriceClick(Sender: TObject);
    procedure edtRouteEditingDone(Sender: TObject);
    procedure ListBox2Click(Sender: TObject);
    procedure tedtEndEditingDone(Sender: TObject);
    procedure tedtStartEditingDone(Sender: TObject);
  private
    pToCurrentRoute: pRoute;
  public
    procedure InitAdminEdit(lbx: TListBox; StopsInRoute: strArr; Route: pRoute);
    procedure RefreshInterface(RoutePtr: pBusRoute; lbx: TListBox);

  end;

var
  Form4: TForm4;
  AllStops, AllStopsNames: array of string;

implementation

{$R *.lfm}

{ TForm4 }

procedure TForm4.btnExitClick(Sender: TObject);
begin
  Form4.Close;
end;

procedure TForm4.btnHelpClick(Sender: TObject);
begin
  showmessage('Select a stop in the list to make modifications');
  ShowMessage('Modify the route name, start and end times, and price in the ' +
                      ' fields and buttons provided');
end;

procedure TForm4.btnHintsClick(Sender: TObject);
begin
  Form5.ShowModal();
end;

procedure TForm4.btnInsertClick(Sender: TObject);
var
  IntervalRange: integer;
  arrIntervalRange: IntArr;
  Interval, sID: string;
  iInterval: longint;
begin
  sID := AllStops[InputCombo('Add Stop', 'Select a stop to add', AllStopsNames)];
  if MainEngine.DoesStopRepeat(pToCurrentRoute, sID) = True then
  begin
    ShowMessage('There are already two instances of this stop in this route.' +
      #13 + 'This program does not allow more than two' +
      ' instances of a stop to exist within a route');
    Exit;
  end;

  // Get Intervals between stops
  arrIntervalRange := MainEngine.AdminGetIntervals(ListBox2.ItemIndex -
    1, True, pToCurrentRoute);
  // Get abs minutes
  IntervalRange := arrIntervalRange[1] - arrIntervalRange[0];
  // If current stop is not the last stop in the route
  // Do validation
  while True do
  begin
    Interval := InputBox('Enter Time Interval', 'Please enter the time, in' +
      'minutes, taken to travel between these two stops. Must' +
      ' be lower than' + ' ' + IntToStr(IntervalRange) + '.',
      'Please enter only numbers');
    if TryStrToInt(Interval, iInterval) = True then
    if iInterval < IntervalRange then
    begin
      Break
    end
    else
      ShowMessage('Please enter a number lower than ' + IntToStr(IntervalRange))
    else
      ShowMessage('Please only enter a number without decimals');
  end;
  MainEngine.AdminAddToRoute(pToCurrentRoute, ListBox2.ItemIndex, sID,
    iInterval + arrIntervalRange[0], False);
  RefreshInterface(pToCurrentRoute, ListBox2);
  Memo1.Lines.Add('- Inserted a stop into the route');
end;

procedure TForm4.btnModifyClick(Sender: TObject);
var
  IntervalRangeLast, IntervalRangeFirst: integer;
  Interval: string;
  iInterval: longint;
begin
  IntervalRangeLast := MainEngine.AdminGetIntervals(ListBox2.ItemIndex - 1,
    True, pToCurrentRoute)[0];
  if ListBox2.ItemIndex <> ListBox2.Count - 1 then
    IntervalRangeFirst := MainEngine.AdminGetIntervals(ListBox2.ItemIndex,
      True, pToCurrentRoute)[1]
  else
    IntervalRangeFirst := -1;
  if IntervalRangeFirst <> -1 then
  begin
    while True do
    begin
      Interval := InputBox('Enter Time Interval', 'Please enter the time, in' +
        'minutes, taken to travel between these two stops. Must' +
        ' be lower than' + ' ' + IntToStr(IntervalRangeFirst-IntervalRangeLast)
        + '.', 'Please enter only numbers');
      if TryStrToInt(Interval, iInterval) = True then
      if (iInterval < IntervalRangeFirst-IntervalRangeLast) and (iInterval > 0)
      then
        Break
      else
        ShowMessage('Please enter a number lower than ' + IntToStr(
                                    IntervalRangeFirst-IntervalRangeLast))
      else
        ShowMessage('Please only enter a number without decimals');
    end;
    MainEngine.AdminModifyRouteStopTimes(pToCurrentRoute, ListBox2.ItemIndex,
      iInterval + IntervalRangeLast);
  end
  else
  begin
    while True do
    begin
      Interval := InputBox('Enter Time Interval', 'Please enter the time, in' +
        'minutes, taken to travel to this stop from the previoce' +
        'one.', 'Please enter only numbers');
      if TryStrToInt(Interval, iInterval) = True then
        Break
      else
        ShowMessage('Please only enter a number without decimals');
    end;
    MainEngine.AdminModifyRouteStopTimes(pToCurrentRoute, ListBox2.ItemIndex,
      iInterval + IntervalRangeLast);
  end;
  Memo1.Lines.Add('- Modifyed a stops interval');
end;

procedure TForm4.btnRemoveClick(Sender: TObject);
begin
  MainEngine.AdminDeleteRouteStop(pToCurrentRoute, ListBox2.ItemIndex);
  RefreshInterface(pToCurrentRoute, ListBox2);
  Memo1.Lines.Add('- Removed a Stop.');
end;

procedure TForm4.btnSetPriceClick(Sender: TObject);
var
  sPrice: String;
  rPrice: Extended;
begin
  sPrice := InputBox('Set Price', 'Enter a new price for the route',
                          FloatToStr(pToCurrentRoute^.GetPrice));
  if sPrice = FloatToStr(pToCurrentRoute^.GetPrice) then exit
  else
    if TryStrToFloat(sPrice,rPrice) = True then
       MainEngine.AdminModifyRoutePrice(pToCurrentRoute, rPrice)
    else ShowMessage('Please enter a valid numerical value');
  Memo1.Lines.Add('- Set the price of the route to R' + sPrice);
end;

procedure TForm4.edtRouteEditingDone(Sender: TObject);
begin
  MainEngine.AdminModifyRouteName(pToCurrentRoute,edtRoute.Text);
end;

procedure TForm4.ListBox2Click(Sender: TObject);
begin
  if (ListBox2.ItemIndex = -1) and (ListBox2.Count = 0) then
  begin
    btnRemove.Enabled := False;
    btnInsert.Enabled := False;
    btnModify.Enabled := False;
    btnAppend.Enabled := True;
    exit;
  end;
  case ListBox2.ItemIndex of
    0:
    begin
      btnInsert.Enabled := False;
      btnRemove.Enabled := True;
      btnModify.Enabled := False;
      btnAppend.Enabled := True;
    end;
    -1:
    begin
      btnRemove.Enabled := False;
      btnInsert.Enabled := False;
      btnModify.Enabled := False;
      btnAppend.Enabled := False;
    end;
    else
    begin
      btnInsert.Enabled := True;
      btnRemove.Enabled := True;
      btnModify.Enabled := True;
      btnAppend.Enabled := True;
    end;
  end;
end;

procedure TForm4.tedtEndEditingDone(Sender: TObject);
var
  sStart, sEnd : string;
begin
  sStart := tedtStart.Text;
  sStart := sStart.Replace(':','');
  sEnd := tedtEnd.Text;
  sEnd := sEnd.Replace(':','');
  MainEngine.AdminModifyRouteTimes(pToCurrentRoute,sStart,sEnd);
end;

procedure TForm4.tedtStartEditingDone(Sender: TObject);
var
  sStart, sEnd: string;
begin
  sStart := tedtStart.Text;
  sStart := sStart.Replace(':','');
  sEnd := tedtEnd.Text;
  sEnd := sEnd.Replace(':','');
  MainEngine.AdminModifyRouteTimes(pToCurrentRoute,sStart,sEnd);
end;

procedure TForm4.btnAppendClick(Sender: TObject);
var
  sID, Interval: string;
  IntervalRange, iInterval: integer;
  arrIntervalRange: IntArr;

begin
  // Get Stop ID
  try
    begin
      sID := AllStops[InputCombo('Add Stop', 'Select a stop to add',
        AllStopsNames)];
    end
  except
    exit;
  end;
  if MainEngine.DoesStopRepeat(pToCurrentRoute, sID) = True then
  begin
    ShowMessage('There are already two instances of this stop in this route.' +
      #13 + 'This program does not allow more than two' +
      ' instances of a stop to exist within a route');
    Exit;
  end;
  // If we are not at the end or the route is not empty
  if (ListBox2.ItemIndex <> -1) and (ListBox2.ItemIndex - (ListBox2.Count - 1) <> 0) then
  begin
    // Get Intervals between stops
    arrIntervalRange := MainEngine.AdminGetIntervals(ListBox2.ItemIndex,
      True, pToCurrentRoute);
    // Get abs minutes
    IntervalRange := arrIntervalRange[1] - arrIntervalRange[0];
  end;
  // If we are adding a stop to a route with no stops
  if (ListBox2.ItemIndex = -1) and (ListBox2.Count = 0) then
    // First stop in route therefore no interval except 0
    MainEngine.AdminAddToRoute(pToCurrentRoute, -1, sID, 0, True)
  // If current stop is not the last stop in the route
  else if ListBox2.ItemIndex <> ListBox2.Count - 1 then
  begin
    // Do validation
    while True do
    begin
      Interval := InputBox('Enter Time Interval', 'Please enter the time, in' +
        'minutes, taken to travel between these two stops. Must' +
        ' be lower than' + ' ' + IntToStr(IntervalRange) + '.',
        'Please enter only numbers');
      if TryStrToInt(Interval, iInterval) = True then
      if iInterval > IntervalRange then
        Break
      else
        ShowMessage('Please enter a number lower than ' +
                            IntToStr(IntervalRange))
      else
        ShowMessage('Please only enter a number without decimals');
    end;
    MainEngine.AdminAddToRoute(pToCurrentRoute, ListBox2.ItemIndex, sID,
      iInterval + arrIntervalRange[0], True);
  end
  else
    // If current stop is the last stop in the route then no need to set
    //    interval restriction becasue there are no stops infront
  begin
    // Do validation
    while True do
    begin
      Interval := InputBox('Enter Time Interval', 'Please enter the time, in' +
        'minutes, taken to travel to this stop from the previoce' +
        'one.', 'Please enter only numbers');
      if TryStrToInt(Interval, iInterval) = True then
        Break
      else
        ShowMessage('Please only enter a number without decimals');
    end;
    if ListBox2.Count <> 1 then
    begin
      arrIntervalRange := MainEngine.AdminGetIntervals(ListBox2.ItemIndex,
        False, pToCurrentRoute);

      iInterval := iInterval + arrIntervalRange[1];
    end;
    MainEngine.AdminAddToRoute(pToCurrentRoute, ListBox2.ItemIndex
      , sID, iInterval, True);
  end;
  RefreshInterface(pToCurrentRoute, ListBox2);
  Memo1.Lines.Add('- Appended a stop to the route');
end;

procedure TForm4.btnConfirmClick(Sender: TObject);
begin
  Form4.Close;
end;

procedure TForm4.InitAdminEdit(lbx: TListBox; StopsInRoute: strArr; Route: pRoute);
var
  each: string;
  pAllStops: pArr;
  Count: integer;
  Stop: pBusStop;
begin
  lbx.Clear;
  Count := 0;
  for each in StopsInRoute do
  begin
    lbx.Items.Add(each + ' ' + IntToStr(Route^.GetInterval(Count)));
    inc(Count);
  end;
  tedtStart.text := Route^.GetRouteStartStr();
  tedtEnd.text := Route^.GetRouteEndStr();
  edtRoute.Caption := Route^.GetHID();
  pToCurrentRoute := Route;
  pAllStops := MainEngine.GiveStopsArr();
  Count := 0;
  setlength(AllStops, length(pAllStops));
  setlength(AllStopsNames, length(pAllStops));
  for Stop in pAllStops do
  begin
    AllStops[Count] := Stop^.GetID;
    AllStopsNames[Count] := Stop^.GetName;
    Inc(Count);
  end;
  pAllStops := nil;
  lbx.ItemIndex := -1;
  ListBox2Click(Form4);
end;

procedure TForm4.RefreshInterface(RoutePtr: pBusRoute; lbx: TListBox);
var
  StopsInRoute: strArr;
  each: string;
begin
  StopsInRoute := RoutePtr^.getStopsInfo();
  lbx.Clear;
  for each in StopsInRoute do
    lbx.Items.Add(each);
  if lbx.Count <> 0 then
    lbx.ItemIndex := 0;
  ListBox2Click(Form4);
end;

end.

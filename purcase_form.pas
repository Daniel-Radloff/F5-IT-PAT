unit Purcase_form;
// Daniel Radloff
// User interface to purchace tickets and view routes between destinations
//      Uses Engine to create text file

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Engine, EngineInterface,Admin_edit_add_stop;

type

  { TForm2 }

  TForm2 = class(TForm)
    btnHelp: TButton;
    btnReset: TButton;
    btnPurchase: TButton;
    btnShowHints: TButton;
    Button1: TButton;
    gbxSelectRoute: TGroupBox;
    gbxOverview: TGroupBox;
    gbxActions: TGroupBox;
    gbxConfirm: TGroupBox;
    lsbxRouteOptions: TListBox;
    Memo1: TMemo;
    memOverview: TMemo;
    pnlOverview: TPanel;
    procedure btnHelpClick(Sender: TObject);
    procedure btnPurchaseClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnShowHintsClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lsbxRouteOptionsSelectionChange(Sender: TObject; User: boolean);
  private
    procedure GetDirections(Routes: FullRouteArr; lsbx: TListBox; memo: TMemo);
    procedure PopulateSelection(Routes: FullRouteArr; lsbx: TListBox);
  public

  end;

var
  Form2: TForm2;
  ViableRoutes: FullRouteArr;
  PurchaceIndex : integer;

implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.FormShow(Sender: TObject);
begin
  PopulateSelection(ViableRoutes, lsbxRouteOptions);
  lsbxRouteOptions.ItemIndex := -1;
  memOverview.Clear;
end;

procedure TForm2.btnResetClick(Sender: TObject);
begin
  Form2.Close;
end;

procedure TForm2.btnShowHintsClick(Sender: TObject);
begin
  Form5.ShowModal();
end;

procedure TForm2.Button1Click(Sender: TObject);
var
  fOut : TextFile;
  Routes: FullRouteWithTimes;
begin
  with TStringList.Create do
  try
    for Routes in ViableRoutes[PurchaceIndex] do
    begin
      Add('===========================================================');
      Add('R' + FloatToStr(Routes.RouteAndStop.Route^.GetPrice));
      Add(routes.RouteAndStop.Route^.GetHID);
      Add(convTimeToStr(routes.DepartureTime));
      Add('===========================================================');
    end;
    SaveToFile('Ticket.txt');
  finally
    Free;
  end;
  with memOverview.Lines do
  try
    SaveToFile('Directions');
  finally
  end;
  Form2.Close;
end;

procedure TForm2.btnPurchaseClick(Sender: TObject);
var
  routes: FullRouteWithTimes;
begin
  PurchaceIndex := lsbxRouteOptions.ItemIndex;
  Memo1.Lines.Clear;
  for routes in ViableRoutes[PurchaceIndex] do
  begin
    Memo1.Lines.Add('R' + FloatToStr(Routes.RouteAndStop.Route^.GetPrice));
    Memo1.Lines.Add(routes.RouteAndStop.Route^.GetHID);
    Memo1.Lines.Add(convTimeToStr(routes.DepartureTime));
    Memo1.Lines.Add(#13);
  end;
  Button1.Enabled := True;
end;

procedure TForm2.btnHelpClick(Sender: TObject);
begin
  showmessage('Select a route from the list of items to see a overview' +
                      'of the route.');
  ShowMessage('Then select purchace to view all the costs associated with the' +
                    ' route and click confirm purchace to generate a ticket.');
end;

procedure TForm2.lsbxRouteOptionsSelectionChange(Sender: TObject; User: boolean);
begin
  GetDirections(ViableRoutes, lsbxRouteOptions, memOverview);
  Button1.Enabled := False;
end;

procedure TForm2.GetDirections(Routes: FullRouteArr; lsbx: TListBox; memo: TMemo);
var
  Selection: array of FullRouteWithTimes;
  Count: integer;
begin
  Selection := Routes[lsbx.ItemIndex];
  Count := 0;
  memo.Lines.Clear;
  while Count < length(Selection) - 1 do
  begin
    memo.Lines.Add('Get on to the: "' +
      Selection[Count].RouteAndStop.Route^.GetHID +
      '"' + ' bus route at the "' +
      Selection[Count].RouteAndStop.Stop^.GetName
      + '" stop at ' + convTimeToStr(
      Selection[Count].DepartureTime) + '. Get Off at ' +
      Selection[Count + 1].RouteAndStop.Stop^.getStopTrueName
      + ' in ' +
      Selection[Count + 1].RouteAndStop.Stop^.GetName + '.');
    memo.Lines.Add(#13);
    Inc(Count);
  end;
end;

procedure TForm2.PopulateSelection(Routes: FullRouteArr; lsbx: TListBox);
var
  Route: array of FullRouteWithTimes;
begin
  lsbx.Clear;
  for Route in Routes do
  begin
    lsbx.Items.Add(convTimeToStr(Route[0].DepartureTime) + ' -> ' +
      convTimeToStr(Route[length(route) - 1].DepartureTime) +
      #13 + Route[Length(route) - 1].RouteAndStop.Route^.GetHID);
  end;
  ViableRoutes := Routes;
  Button1.Enabled := False;
end;

end.





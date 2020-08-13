unit Purcase_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Engine, EngineInterface;

type

  { TForm2 }

  TForm2 = class(TForm)
    btnHelp: TButton;
    btnReset: TButton;
    btnPurchase: TButton;
    btnShowHints: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    cxgRouteSpecify: TCheckGroup;
    gbxSelectRoute: TGroupBox;
    gbxOverview: TGroupBox;
    gbxActions: TGroupBox;
    gbxConfirm: TGroupBox;
    lsbxRouteOptions: TListBox;
    Memo1: TMemo;
    memOverview: TMemo;
    pnlOverview: TPanel;
    procedure btnResetClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lsbxRouteOptionsSelectionChange(Sender: TObject; User: boolean);
  private
    procedure GetDirections(Routes:FullRouteArr;lsbx:TListBox;memo:TMemo);
    procedure PopulateSelection(Routes:FullRouteArr;lsbx:TListBox);
  public

  end;

var
  Form2: TForm2;
  ViableRoutes : FullRouteArr;

implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.FormShow(Sender: TObject);
begin
  PopulateSelection(ViableRoutes,lsbxRouteOptions);
  lsbxRouteOptions.ItemIndex := -1;
  memOverview.Clear;
end;

procedure TForm2.btnResetClick(Sender: TObject);
begin
  TForm2.Close;
end;

procedure TForm2.lsbxRouteOptionsSelectionChange(Sender: TObject; User: boolean
  );
begin
  GetDirections(ViableRoutes,lsbxRouteOptions,memOverview);
end;

procedure TForm2.GetDirections(Routes: FullRouteArr; lsbx: TListBox; memo: TMemo
  );
var
  Selection : array of FullRouteWithTimes;
  count: Integer;
begin
  Selection := Routes[lsbx.ItemIndex];
  count := 0;
  memo.Lines.Clear;
  while count < length(Selection)-1 do
  begin
    memo.Lines.Add('Get on to the: "' +
                        Selection[count].RouteAndStop.Route^.GetHID + '"'
                        + ' bus route at the "' +
                        Selection[count].RouteAndStop.Stop^.GetName
                        + '" stop at ' +
                        convTimeToStr(Selection[count].DepartureTime) +
                        '. Get Off at ' +
                        Selection[count+1].RouteAndStop.Stop^.getStopTrueName
                        + ' in ' +
                        Selection[count+1].RouteAndStop.Stop^.GetName + '.');
    memo.Lines.Add(#13);
    inc(count);
  end;
end;

procedure TForm2.PopulateSelection(Routes: FullRouteArr; lsbx: TListBox);
var
  Route : array of FullRouteWithTimes;
begin
  lsbx.Clear;
  for Route in Routes do
  begin
    lsbx.Items.Add(convTimeToStr(Route[0].DepartureTime) + ' -> ' +
                   convTimeToStr(Route[length(route)-1].DepartureTime) + #13
                   + Route[Length(route)-1].RouteAndStop.Route^.GetHID);
  end;
end;

end.


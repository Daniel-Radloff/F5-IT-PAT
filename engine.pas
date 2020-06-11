unit Engine;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Custom_Classes, Data_Connection;

type

  StopArray = array of BusStop;
  { APEngine }

  APEngine = class
  private
    BusStops: Custom_Classes.StopArray;
    function GetNewStops(): int16;
  public
    constructor Create(); overload;
    function InitializeProgram(): int16;
    function StopsToInt():integer;
    function GiveStopsArr(): Custom_Classes.pStopArray;

  end;

 var MainEngine: APEngine;
 procedure Init();

implementation

procedure Init();
var
		  x: Integer;
begin
  MainEngine := APEngine.Create();
  MainEngine.InitializeProgram();
  x := MainEngine.StopsToInt();
end;

{ Engine }

function APEngine.GetNewStops(): int16;
var
  NewStop: BusStop;
begin
  with DataBase do Begin
  // Populate data source with all BusStops
    GetAllStops();
    setLength(BusStops,0);
    while not SQLQuery1.EOF do
    begin
      // Create the new bus Stop
      NewStop := BusStop.Create(SQLQuery1.Fields[3].AsString,
       SQLQuery1.Fields[0].AsString, SQLQuery1.Fields[1].AsString);
       // Increase length of Stops array
       setlength(BusStops,length(BusStops)+1);
       // Add New stop
       BusStops[length(BusStops)-1] := NewStop;
       SQLQuery1.Next();
    end;
  end;
end;

constructor APEngine.Create();
begin
  SetLength(BusStops,0);
end;

function APEngine.InitializeProgram(): int16;
begin
  GetNewStops();
end;

function APEngine.StopsToInt(): integer;
begin
  Result := length(self.BusStops);
end;

function APEngine.GiveStopsArr(): Custom_Classes.pStopArray;
begin
  Result := @self.BusStops;
end;

end.

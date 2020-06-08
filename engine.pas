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
    BusStops: StopArray;
    function GetNewStops(): int16;
  public
    constructor Create(); overload;
    function InitializeProgram(): int16;

  end;

 var Main : APEngine;
 procedure Init();

implementation

procedure Init();
begin
  Main.Create();
  Main.InitializeProgram();
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
    while not SQLQuery.EOF do
    begin
      // Create the new bus Stop
      NewStop := BusStop.Create(SQLQuery.Fields[3].AsString,
       SQLQuery.Fields[0].AsString, SQLQuery.Fields[1].AsString);
       // Increase length of Stops array
       setlength(BusStops,length(BusStops)+1);
       // Add New stop
       BusStops[length(BusStops)-1] := NewStop;
       SQLQuery.Next();
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
end.

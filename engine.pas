unit Engine;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Custom_Classes, Data_Connection, db;

type

  { APEngine }

  APEngine = class
  private
    BusStops: Custom_Classes.StopArray;
    pBusStops : pArr;
    function GetNewStops(): int16;
  public
    constructor Create(); overload;
    function InitializeProgram(): int16;
    function StopsToInt():integer;
    function GiveStopsArr(): Custom_Classes.pStopArray;

  end;

 var MainEngine: APEngine;
 procedure Init();
 function BinSearchMulti(Field : pArr; Search : string): pBusStop;

implementation

procedure Init();
var
		  x: Integer;
begin
  MainEngine := APEngine.Create();
  MainEngine.InitializeProgram();
  x := MainEngine.StopsToInt();
end;

function BinSearchMulti(Field: pArr; Search: string): pBusStop;
var
  index: integer;
  rIndex: Extended;
  ID: String;
begin
  rIndex := length(Field)/2;
  index := round(rIndex);
  ID := Field[index]^.GetID();
  if ID = Search then
     Result := Field[index];
  if ID < Search then
     Result := BinSearchMulti(Copy(Field,index),Search);
  if ID > Search then
     Result := BinSearchMulti(Copy(Field,0,index), Search);
end;

{ Engine }

function APEngine.GetNewStops(): int16;
var
  NewStop: BusStop;
  StopsIDRaw, linked: String;
  arrLinked : array of string;
  CVCPos, Count: Integer;
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
    setLength(pBusStops, Length(BusStops));
    for Count := 0 to length(BusStops) do
    begin
      pBusStops[Count] := @BusStops[Count];
    end;
    // Reset Query pos
    SQLQuery1.First;
    // New loop
    Count := 0;
    While not SQLQuery1.EOF do
    begin
      // Get linked stops
      StopsIDRaw := SQLQuery1.Fields[2].AsString;
      // Clear array
      SetLength(arrLinked, 0);
      // Find ',' and give POS
      While POS(',', StopsIDRaw) > 0 do
      begin
        // Do it again because I couldent be botherd to fix the loop
        CVCPos := POS(',', StopsIDRaw);
        // Increase array
        SetLength(arrLinked, length(arrLinked)+1);
        // add item
        arrLinked[length(arrLinked)-1] := COPY(StopsIDRaw,0,CVCPos-1);
        // Remove the added stop so we don't infinite loop
        DELETE(StopsIDRaw,1,CVCPos);
      end;
      // Increase array
      SetLength(arrLinked, length(arrLinked)+1);
      // add item
      arrLinked[length(arrLinked)-1] := StopsIDRaw;

      // Search
      for linked in arrLinked do
      begin
        BusStops[count].AddClose(BinSearchMulti(Self.pBusStops,linked))
      end;
      inc(Count);
    end;
  end;
  Result := 0;
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

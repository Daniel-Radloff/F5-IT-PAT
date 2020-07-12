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
    AllRoutes : RouteArray;
    pAllRoutes : pBusRouteArr;
    function GetNewStops(): int16;
  public
    constructor Create(); overload;
    // Change sec prefs when stable
    function InitializeProgram(): int16;
    function StopsToInt():integer;
    // Delete when the thing works, this is terrible
    function GiveStopsArr(): Custom_Classes.pStopArray;
    function GetRoute(sStart: string; sEnd: string): pBusRouteArr;

  end;

 var MainEngine: APEngine;
 procedure Init();
 function BinSearchRawR(Field : pBusRouteArr; Search : string): pBusRoute;
 function BinSearchRaw(Field : pArr; Search: string): pBusStop;

implementation

procedure Init();
var
		  x: Integer;
begin
  MainEngine := APEngine.Create();
  MainEngine.InitializeProgram();
  x := MainEngine.StopsToInt();
end;

function BinSearchRawR(Field: pBusRouteArr; Search: string): pBusRoute;
var
  index: integer;
  rIndex: Extended;
  ID: String;
begin
  rIndex := length(Field)/2;
  index := round(rIndex);
  ID := Field[index]^.GetID();
  if ID = Search then
     begin
     Result := Field[index];
     end;
  if ID < Search then
     begin
     // I do this and pray that the compiler takes care of deconstructing the
     //   copys when the function exits,
     Result := BinSearchRawR(Copy(Field,index),Search);
     end;
  if ID > Search then
     begin
     Result := BinSearchRawR(Copy(Field,0,index), Search);
     end;
end;

function BinSearchRaw(Field: pArr; Search: string): pBusStop;
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
       // I do this and pray that the compiler takes care of deconstructing the
       //   copys when the function exits,
     Result := BinSearchRaw(Copy(Field,index),Search);
  if ID > Search then
     Result := BinSearchRaw(Copy(Field,0,index), Search);
end;

{ Engine }

function APEngine.GetNewStops(): int16;
var
  NewStop: BusStop;
  NewRoute, everyRoute: BusRoute;
  RouteIDRaw, linked: String;
  arrLinked : array of string;
  CVCPos, Count: Integer;
begin
  with DataBase do Begin
  // Populate data source with all BusStops
    GetAllStops();
    setLength(BusStops,0);
    // Create Bus Stops
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
    // this is idiotic as a array is inherently a list of pointers so a raw
    //      copy will suffice... CHANGE IT?!?!?!?
    setLength(pBusStops, Length(BusStops));
    for Count := 0 to length(BusStops) do
    begin
      pBusStops[Count] := @BusStops[Count];
    end;


    // now its time to get all the routes


    // Close because not close = bad *ptsd intensifys
    SQLQuery1.Close;
    GetAllRoutes();
    // Reset Query pos for no reason but it'll die if u don't
    SQLQuery1.First;
    // New loop for future
    Count := 0;
    // set AllRoutes arr length
    SetLength(AllRoutes,0);
    // Create all the routes
    while not SQLQuery1.EOF do
    begin
      // Make the route
      WriteLn(SQLQuery1.Fields[0].AsString);
      WriteLn(SQLQuery1.Fields[1].AsString);
      WriteLn(SQLQuery1.Fields[2].AsString);
      WriteLn(SQLQuery1.Fields[3].AsString);
      WriteLn(SQLQuery1.Fields[4].AsString);
      NewRoute := BusRoute.Create(SQLQuery1.Fields[0].AsString,
               SQLQuery1.Fields[1].AsString, SQLQuery1.Fields[2].AsString,
               SQLQuery1.Fields[3].AsFloat, SQLQuery1.Fields[4].AsString);
      // inc array lenght
      SetLength(AllRoutes, length(AllRoutes)+1);
      // Pop array
      AllRoutes[Length(AllRoutes)-1] := NewRoute;

      SQLQuery1.Next();
    end;
    // Make another pointer arr for stop manipulation and pointer linking
    setlength(pAllRoutes, length(AllRoutes));
    for Count := 0 to length(pAllRoutes) do
    begin
      pAllRoutes[Count] := @AllRoutes[Count];
    end;

    // Get all Stops
    SQLQuery1.Close;
    GetAllStops();
    SQLQuery1.First();




    // SPICE TIME !!!!
    // pop Stop route lists
    count := 0;
    While not SQLQuery1.EOF do
    begin
      // Get linked stops
      RouteIDRaw := SQLQuery1.Fields[2].AsString;
      // Clear array
      SetLength(arrLinked, 0);
      // Find ',' and give POS
      While POS(',', RouteIDRaw) > 0 do
      begin
        // Do it again because I couldent be botherd to fix the loop
        CVCPos := POS(',', RouteIDRaw);
        // Increase array
        SetLength(arrLinked, length(arrLinked)+1);
        // add item
        arrLinked[length(arrLinked)-1] := COPY(RouteIDRaw,0,CVCPos-1);
        // Remove the added stop so we don't infinite loop
        DELETE(RouteIDRaw,1,CVCPos);
      end;
      // Copy the last one cause we missed it cause it doesn't have a ','
      // Increase array
      SetLength(arrLinked, length(arrLinked)+1);
      // add item
      arrLinked[length(arrLinked)-1] := RouteIDRaw;

      // Search and link routes properly
      for linked in arrLinked do
      begin
        // yumy yumy binnary search, much .... MUCH faster search than
        //      standard for loop step step step thing
        BusStops[count].AddClose(BinSearchRawR(Self.pAllRoutes,linked));
        writeLn(BusStops[count].GetLinkedRoutes());
      end;
      inc(Count);
      SQLQuery1.Next();
    end;





    // Yes this is a long function and I should abstract and simplify it
    //     ............ oh well...........

    // Now its time to make our route stops, they are used so we don't need
    //     to re-enter 1000 stops and routes with pretty much the same data.
    //     Just link it
    //     its just better from a logic point
    //     sorry computer
    //     OOP wasnt kind to you in the first place
    //     but it makes my life much easier





    // Start a NNNOOOTHHHERRR looooooooooop
    // Create the routestops
    for everyRoute in AllRoutes do
    begin
      // Get some of that juciy data from the db
      SQLQuery1.Close;
      GetRouteStops(everyRoute);
      // Its time for another loop lol
      // set to first
      SQLQuery1.First;
      WriteLn(SQLQuery1.Fields[0].AsString);
      WriteLn(SQLQuery1.Fields[1].AsString);
      WriteLn(SQLQuery1.Fields[2].AsString);
      WriteLn(SQLQuery1.Fields[3].AsString);
      while not SQLQuery1.EOF do
      begin
        // POP the thing
        everyRoute.PopulateRoute(SQLQuery1.Fields[1].AsInteger,
          BinSearchRaw(self.pBusStops, SQLQuery1.Fields[2].AsString),
          StrToInt(SQLQuery1.Fields[3].AsString));
        SQLQuery1.Next;
      end;
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

function APEngine.GetRoute(sStart: string; sEnd: string): pBusRouteArr;
var
  pbStart, pbEnd: pBusStop;
begin
  pbStart := BinSearchRaw(pBusStops,sStart);
  pbEnd := BinSearchRaw(pBusStops, sEnd);
  Result := pbStart^.FindRouteInit(pbEnd);
end;

end.

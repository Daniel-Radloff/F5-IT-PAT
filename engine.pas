unit Engine;
// Daniel Radloff
// This is the declaration of the engine unit along with some other
//      types. See line 28 for more details

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Custom_Classes, Data_Connection, DB, Math;

type
  FullRouteWithTimes = record
    RouteAndStop: StopRouteLink;
    DepartureTime: integer;
  end;

  FindRoutesInput = record
    StartStop: pBusStop;
    EndStop: pBusStop;
    StartTime: integer;
    EndTime: integer;
  end;

  // should make this or the array of FullRoutes an object
  FullRouteArr = array of array of FullRouteWithTimes;
  { APEngine }
  // The engine is the king of this kingdom
  //     It controls and handles all background processing
  //     if I have time ill make it run on its own thread
  //     to give the user feedback from the program but for
  //     now its fast enough to remain single threaded
  APEngine = class
  private
    BusStops: Custom_Classes.StopArray;
    AllRoutes: RouteArray;
    function GetNewStops(): int16;
  public
    pBusStops: pArr;
    pAllRoutes: pBusRouteArr;
    constructor Create(); overload;
    // Change sec prefs when stable
    function InitializeProgram(): int16;
    function StopsToInt(): integer;
    function DoesStopRepeat(RoutePtr: pBusRoute; ID: string): boolean;

    // User End functions
    // Delete when the thing works, this is terrible
    function GiveStopsArr(): pArr;
    function GiveRoutesArr(): pBusRouteArr;
    function GetRoutePtr(sID: string): pRoute;
    // Find all routes to a location
    function GetRoute(sStart: string; sEnd: string; StartTime: integer;
      EndTime: integer): FullRouteArr;
    function GetRoute(Input: FindRoutesInput): FullRouteArr; overload;

    // Some nice little data base features for the admin screen

    // Use with flags: 'B', 'R' to display apropreate table. no RS because
    //     table is not human readable
    procedure AdminShowTbl(param: string);
    // Delete a stop from a route
    procedure AdminDeleteRouteStop(RoutePtr: pRoute; StopPOS: integer);
    // Delete a route lol im going insane
    //        I'll see if I have time to make it better
    procedure AdminDeleteRoute(RouteID: string);
    // Delete a stop from the database.
    //        I might just check the input arg on this. Might use a
    //          string or a routeStop but those will be easy fixes as
    //          I already have existing implimentations to get
    //          the pointer to the busStop for both
    procedure AdminDeleteStop(StopID: string);
    // Checks and returns viable intervals between two concurent stops
    //        Need for the Admin frm
    function AdminGetIntervals(SelectedPOS: integer; Append: boolean;
      RoutePtr: pBusRoute): IntArr;
    // Add a RouteStop to the Route
    procedure AdminAddToRoute(RoutePtr: pRoute; SelectedPOS: integer;
      Stop: string; interval: integer; Append: boolean);
    // Make a new Route. I think this requires a reload of the
    //      Engine so the routes are in order for a BinarySearch
    procedure AdminAddNewRoute(RouteName: string; DigitalStart, EndTime: string;
      RoutePrice: real);
    // Create a new stop. Same prediciment as above
    procedure AdminAddNewStop(Location: string);
    // Modify the Stop linked to a route stop
    //        validates that stop does not appear twice already
    procedure AdminModifyRouteStopTimes(RoutePtr: pRoute; POS, Interval: integer);
    // Modify the route name
    procedure AdminModifyRouteName(RoutePtr: pRoute; NewName: string);
    // Modify route start and end times
    procedure AdminModifyRouteTimes(RoutePtr: pRoute; Start, EndTime: string);
    // Modify route Price
    procedure AdminModifyRoutePrice(RoutePtr: pRoute; NewPrice: real);
    // Use override to not call default
    destructor Destroy; override;
    // Restart
    procedure ReStart();


  end;

function BinSearchRawR(Field: pBusRouteArr; Search: string): pBusRoute;
function BinSearchRaw(Field: pArr; Search: string): pBusStop;
// A blatent copy paste of the other two functions but the most
//   efficient way to do it so I don't mind. Besides, less work
function binCarefullDelPOSR(Field: pBusRouteArr; Search: string): integer;
function BinCarefullDelPOS(Field: pArr; Search: string): integer;

implementation

// I don't know why this isn't part of the engine object but it doesn't matter
//   and I might still find a use for it later.
function BinSearchRawR(Field: pBusRouteArr; Search: string): pBusRoute;
var
  index: integer;
  rIndex: extended;
  ID: string;
begin
  rIndex := length(Field) / 2;
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
    Result := BinSearchRawR(Copy(Field, index), Search);
  end;
  if ID > Search then
  begin
    Result := BinSearchRawR(Copy(Field, 0, index), Search);
  end;
end;

function BinSearchRaw(Field: pArr; Search: string): pBusStop;
var
  index: integer;
  rIndex: extended;
  ID: string;
begin
  rIndex := length(Field) / 2;
  index := round(rIndex);
  ID := Field[index]^.GetID();
  if ID = Search then
    Result := Field[index];
  if ID < Search then
    // I do this and pray that the compiler takes care of deconstructing the
    //   copys when the function exits,
    Result := BinSearchRaw(Copy(Field, index), Search);
  if ID > Search then
    Result := BinSearchRaw(Copy(Field, 0, index), Search);
end;

function binCarefullDelPOSR(Field: pBusRouteArr; Search: string): integer;
var
  index: integer;
  rIndex: extended;
  ID: string;
begin
  rIndex := length(Field) / 2;
  index := round(rIndex);
  ID := Field[index]^.GetID();
  if ID = Search then
  begin
    Result := index;
  end;
  if ID < Search then
  begin
    // I do this and pray that the compiler takes care of deconstructing the
    //   copys when the function exits,
    Result := binCarefullDelPOSR(Copy(Field, index), Search);
  end;
  if ID > Search then
  begin
    Result := binCarefullDelPOSR(Copy(Field, 0, index), Search);
  end;
end;

function BinCarefullDelPOS(Field: pArr; Search: string): integer;
var
  index: integer;
  rIndex: extended;
  ID: string;
begin
  rIndex := length(Field) / 2;
  index := round(rIndex);
  ID := Field[index]^.GetID();
  if ID = Search then
    Result := index;
  if ID < Search then
    // I do this and pray that the compiler takes care of deconstructing the
    //   copys when the function exits,
    Result := BinCarefullDelPOS(Copy(Field, index), Search);
  if ID > Search then
    Result := BinCarefullDelPOS(Copy(Field, 0, index), Search);
end;

{ Engine }

function APEngine.GetNewStops(): int16;
var
  NewStop: BusStop;
  NewRoute, everyRoute: BusRoute;
  RouteIDRaw, linked: string;
  arrLinked: array of string;
  CVCPos, Count, NumofStops: integer;
begin
  with DataBase do
  begin
    // Populate data source with all BusStops
    NumofStops := StopCount();
    GetAllStops();
    setLength(BusStops, 0);
    // Create Bus Stops
    setLength(BusStops, NumofStops);
    Count := 0;
    while not SQLQuery1.EOF do
    begin
      // Create the new bus Stop
      NewStop := BusStop.Create(SQLQuery1.Fields[3].AsString,
        SQLQuery1.Fields[0].AsString, SQLQuery1.Fields[1].AsString);
      // Increase length of Stops array
      // Add New stop
      BusStops[Count] := NewStop;
      Inc(Count);
      SQLQuery1.Next();
    end;
    // this is idiotic as a array is inherently a list of pointers so a raw
    //      copy will suffice... CHANGE IT?!?!?!?
    setLength(pBusStops, Length(BusStops));
    for Count := 0 to length(BusStops) do
    begin
      pBusStops[Count] := @(BusStops[Count]);
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
    SetLength(AllRoutes, 0);
    // Create all the routes
    while not SQLQuery1.EOF do
    begin
      // Make the route
      {WriteLn(SQLQuery1.Fields[0].AsString);
      WriteLn(SQLQuery1.Fields[1].AsString);
      WriteLn(SQLQuery1.Fields[2].AsString);
      WriteLn(SQLQuery1.Fields[3].AsString);
      WriteLn(SQLQuery1.Fields[4].AsString);}
      NewRoute := BusRoute.Create(SQLQuery1.Fields[0].AsString,
        SQLQuery1.Fields[1].AsString, SQLQuery1.Fields[2].AsString,
        SQLQuery1.Fields[3].AsFloat, SQLQuery1.Fields[4].AsString);
      // inc array lenght
      SetLength(AllRoutes, length(AllRoutes) + 1);
      // Pop array
      AllRoutes[Length(AllRoutes) - 1] := NewRoute;

      SQLQuery1.Next();
    end;
    // Make another pointer arr for stop manipulation and pointer linking
    setlength(pAllRoutes, length(AllRoutes));
    for Count := 0 to length(pAllRoutes) do
    begin
      pAllRoutes[Count] := @(AllRoutes[Count]);
    end;

    // Get all Stops
    SQLQuery1.Close;
    GetAllStops();
    SQLQuery1.First();




    // SPICE TIME !!!!
    // pop Stop route lists
    Count := 0;
    while not SQLQuery1.EOF do
    begin
      // Get linked stops
      RouteIDRaw := SQLQuery1.Fields[2].AsString;
      // Clear array
      SetLength(arrLinked, 0);
      // Find ',' and give POS
      while POS(',', RouteIDRaw) > 0 do
      begin
        // Do it again because I couldent be botherd to fix the loop
        CVCPos := POS(',', RouteIDRaw);
        // Increase array
        SetLength(arrLinked, length(arrLinked) + 1);
        // add item
        arrLinked[length(arrLinked) - 1] := COPY(RouteIDRaw, 0, CVCPos - 1);
        // Remove the added stop so we don't infinite loop
        Delete(RouteIDRaw, 1, CVCPos);
      end;
      // Copy the last one cause we missed it cause it doesn't have a ','
      // Increase array
      SetLength(arrLinked, length(arrLinked) + 1);
      // add item
      arrLinked[length(arrLinked) - 1] := RouteIDRaw;
      if arrLinked[0] = '' then
      begin
        Inc(Count);
        SQLQuery1.Next();
        Continue;
      end;
      // Search and link routes properly
      for linked in arrLinked do
      begin
        // yumy yumy binnary search, much .... MUCH faster search than
        //      standard for loop step step step thing
        BusStops[Count].AddClose(BinSearchRawR(Self.pAllRoutes, linked));
        //writeLn(BusStops[Count].GetLinkedRoutes());
      end;
      Inc(Count);
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
      {WriteLn(SQLQuery1.Fields[0].AsString);
      WriteLn(SQLQuery1.Fields[1].AsString);
      WriteLn(SQLQuery1.Fields[2].AsString);
      WriteLn(SQLQuery1.Fields[3].AsString);}
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
  self.InitializeProgram();
  inherited;
end;

function APEngine.InitializeProgram(): int16;
begin
  GetNewStops();
  Result := 0;
end;

function APEngine.StopsToInt(): integer;
begin
  Result := length(self.BusStops);
end;

function APEngine.DoesStopRepeat(RoutePtr: pBusRoute; ID: string): boolean;
var
  StopPtr: pBusStop;
begin
  StopPtr := BinSearchRaw(self.pBusStops, ID);
  Result := RoutePtr^.DoesStopRepeat(StopPtr);
end;

function APEngine.GiveStopsArr(): pArr;
begin
  Result := copy(self.pBusStops);
end;

function APEngine.GiveRoutesArr(): pBusRouteArr;
begin
  Result := self.pAllRoutes;
end;

function APEngine.GetRoutePtr(sID: string): pRoute;
begin
  // Easy peasy
  Result := BinSearchRawR(self.pAllRoutes, sID);
end;

function APEngine.GetRoute(sStart: string; sEnd: string; StartTime: integer;
  EndTime: integer): FullRouteArr;
var
  pbStart, pbEnd: pBusStop;
  ViableRoutes: RouteIntesecArr;
  Route: arrStopRouteLink;
  FullCalculatedRoute: FullRouteArr;
  TempFullRoute: FullRouteWithTimes;
  ArrivalInterval, NewRouteIntervals: TimeCalcArr;
  tStartTime, RouteStartTime, Count, FullInterval, TotalCount,
  Iinterval, BusArrival: integer;
  Interval: IntArr;
  TempStopRoute: StopRouteLink;
begin
  // Get Stops to look for
  pbStart := BinSearchRaw(pBusStops, sStart);
  pbEnd := BinSearchRaw(pBusStops, sEnd);
  ViableRoutes := pbStart^.FindRouteInit(pbEnd, pbStart);

  // Great. Now look for times that link closely with the route
  // Keeps track for FullCalculatedRoute array
  TotalCount := -1;
  SetLength(FullCalculatedRoute, length(ViableRoutes));
  tStartTime := StartTime;
  for Route in ViableRoutes do
  begin
    // A Route is a group of Intersections that lead onto different routes
    Count := 0;
    Inc(TotalCount);
    tStartTime := StartTime;
    while Count < length(Route) - 1 do
    begin
      //writeln(Route[Count].Route^.GetHID);
      RouteStartTime := Route[Count].Route^.GetRouteStart;
      // Get next interval
      FullInterval := Route[Count].Route^.GetFullInterval;
      // Calculate Closest Time that we depart at for default
      // case is much faster than a if because of how it is compiled and
      //      executed at runtime. Kindof works like a hash table so it will
      //      imediatly jump to the else statement without comparing our
      //      count var.
      case Count of
        0:
        begin
          //       BIG BRAIN NOTE!!!!!!!!!!!!!!!!!!!!!!
          //       IF its a walk r then we don't need to calcute a time,
          // just use the given start time since we are already there
          //       and then modify second step to fit our calcs

          // We do this for first stop because we can either arrive before
          //    Specifyed time or after
          Interval := route[0].Route^.GetStopInterval(Route[0].Stop);
          while (RouteStartTime + FullInterval + interval[0]) < tStartTime do
          begin
            interval[0] := interval[0] + FullInterval;
          end;
          if (interval[0] + FullInterval) - StartTime < abs(interval[0] - StartTime) then
            interval[0] := interval[0] + FullInterval;
          // NOTE::!!!!
          //             Start Time should be included in time calc ie
          //             Before loop start
          //             we also need to check the second option
          //             if there is one
          Iinterval := interval[0] + RouteStartTime;
          // Inc Length
          setLength(FullCalculatedRoute[Totalcount], Count + 1);
          // Assign Vals
          TempStopRoute.Stop := Route[Count].Stop;
          TempStopRoute.Route := Route[Count].Route;
          TempFullRoute.RouteAndStop := TempStopRoute;
          TempFullRoute.DepartureTime := Iinterval;
          // Assign to arr
          FullCalculatedRoute[TotalCount, Count] := TempFullRoute;
          Inc(Count);
          tStartTime := Iinterval;
          Continue;
        end;

        else
        begin
          // Get some values by using patterns to know what values we can use
          ArrivalInterval := Route[Count - 1].Route^.GetStopInterval(
            Route[Count - 1].Stop, Route[Count].Stop);
          //        Calc when bus will arrive
          BusArrival := (ArrivalInterval[1].interval -
            ArrivalInterval[0].interval) + tStartTime;
          //         Get Stop arrival intervals for new route
          // cant tell if >= matters because of loop condition but better safe
          //      than access violation. If len 2 then loop I think loop will
          //      catch it but im not 100% sure

          { TODO : add when we need to get off and wait for next bus }
          if Count >= length(route) - 1 then
            break;
          // Do you even understand how much pain it took to get to this point?
          //    I cant be botherd to write another overloaded function that
          //    returns a more clean result at this moment. I'll kill
          //    myself if I have to do that again.
          NewRouteIntervals :=
            Route[Count + 1].Route^.GetStopInterval(Route[Count].Stop,
            Route[Count + 1].Stop);
          // We need to be at the stop before the bus is so we go till
          //    we go over and then add that full interval after the loop
          while RouteStartTime + FullInterval +
            NewRouteIntervals[0].interval < BusArrival do
          begin
            NewRouteIntervals[0].interval :=
              NewRouteIntervals[0].interval + FullInterval;
          end;
          NewRouteIntervals[0].interval :=
            NewRouteIntervals[0].interval + FullInterval;
          // Assign to out Iinterval value and add new route data
          Iinterval := NewRouteIntervals[0].interval + RouteStartTime;
        end;
      end;
      // Inc Length
      setLength(FullCalculatedRoute[Totalcount], Count + 1);
      // Assign Vals
      TempStopRoute.Stop := Route[Count].Stop;
      TempStopRoute.Route := Route[Count + 1].Route;
      TempFullRoute.RouteAndStop := TempStopRoute;
      TempFullRoute.DepartureTime := Iinterval;
      // Assign to arr
      FullCalculatedRoute[TotalCount, Count] := TempFullRoute;
      Inc(Count);
      tStartTime := Iinterval;
    end;
    NewRouteIntervals := Route[Count].Route^.GetStopInterval(
      Route[Count - 1].Stop, Route[Count].Stop);
    // Inc Length
    setLength(FullCalculatedRoute[Totalcount], Count + 1);
    // Assign Vals
    TempFullRoute.RouteAndStop := Route[Count];
    TempFullRoute.DepartureTime := Iinterval + NewRouteIntervals[1].interval;
    // Assign to arr
    FullCalculatedRoute[TotalCount, Count] := TempFullRoute;
    Inc(Count);
    tStartTime := Iinterval;
  end;
  Result := FullCalculatedRoute;
end;

function APEngine.GetRoute(Input: FindRoutesInput): FullRouteArr;
var
  pbStart, pbEnd: pBusStop;
  ViableRoutes: RouteIntesecArr;
  Route: arrStopRouteLink;
  FullCalculatedRoute: FullRouteArr;
  TempFullRoute: FullRouteWithTimes;
  ArrivalInterval, NewRouteIntervals: TimeCalcArr;
  tStartTime, RouteStartTime, Count, FullInterval, TotalCount,
  Iinterval, BusArrival: integer;
  Interval: IntArr;
  TempStopRoute: StopRouteLink;
begin
  // Get Stops to look for
  // just use index cause we know it
  pbStart := Input.StartStop;
  pbEnd := Input.EndStop;
  ViableRoutes := pbStart^.FindRouteInit(pbEnd, pbStart);

  // Great. Now look for times that link closely with the route
  // Keeps track for FullCalculatedRoute array
  TotalCount := -1;
  SetLength(FullCalculatedRoute, length(ViableRoutes));
  tStartTime := Input.StartTime;
  for Route in ViableRoutes do
  begin
    // A Route is a group of Intersections that lead onto different routes
    Count := 0;
    Inc(TotalCount);
    tStartTime := Input.StartTime;
    while Count < length(Route) - 1 do
    begin
      //writeln(Route[Count].Route^.GetHID);
      RouteStartTime := Route[Count].Route^.GetRouteStart;
      // Get next interval
      FullInterval := Route[Count].Route^.GetFullInterval;
      // Calculate Closest Time that we depart at for default
      // case is much faster than a if because of how it is compiled and
      //      executed at runtime. Kindof works like a hash table so it will
      //      imediatly jump to the else statement without comparing our
      //      count var.
      case Count of
        0:
        begin
          //       BIG BRAIN NOTE!!!!!!!!!!!!!!!!!!!!!!
          //       IF its a walk r then we don't need to calcute a time,
          // just use the given start time since we are already there
          //       and then modify second step to fit our calcs

          // We do this for first stop because we can either arrive before
          //    Specifyed time or after
          Interval := route[0].Route^.GetStopInterval(Route[0].Stop);
          while (RouteStartTime + FullInterval + interval[0]) < tStartTime do
          begin
            interval[0] := interval[0] + FullInterval;
          end;
          if (interval[0] + FullInterval) - Input.StartTime <
            abs(interval[0] - Input.StartTime) then
            interval[0] := interval[0] + FullInterval;
          // NOTE::!!!!
          //             Start Time should be included in time calc ie
          //             Before loop start
          //             we also need to check the second option
          //             if there is one
          Iinterval := interval[0] + RouteStartTime;
          // Inc Length
          setLength(FullCalculatedRoute[Totalcount], Count + 1);
          // Assign Vals
          TempStopRoute.Stop := Route[Count].Stop;
          TempStopRoute.Route := Route[Count].Route;
          TempFullRoute.RouteAndStop := TempStopRoute;
          TempFullRoute.DepartureTime := Iinterval;
          // Assign to arr
          FullCalculatedRoute[TotalCount, Count] := TempFullRoute;
          Inc(Count);
          tStartTime := Iinterval;
          Continue;
        end;

        else
        begin
          // Get some values by using patterns to know what values we can use
          ArrivalInterval := Route[Count - 1].Route^.GetStopInterval(
            Route[Count - 1].Stop, Route[Count].Stop);
          //        Calc when bus will arrive
          BusArrival := (ArrivalInterval[1].interval -
            ArrivalInterval[0].interval) + tStartTime;
          //         Get Stop arrival intervals for new route
          // cant tell if >= matters because of loop condition but better safe
          //      than access violation. If len 2 then loop I think loop will
          //      catch it but im not 100% sure

          { TODO : add when we need to get off and wait for next bus }
          if Count >= length(route) - 1 then
            break;
          // Do you even understand how much pain it took to get to this point?
          //    I cant be botherd to write another overloaded function that
          //    returns a more clean result at this moment. I'll kill
          //    myself if I have to do that again.
          NewRouteIntervals :=
            Route[Count + 1].Route^.GetStopInterval(Route[Count].Stop,
            Route[Count + 1].Stop);
          // We need to be at the stop before the bus is so we go till
          //    we go over and then add that full interval after the loop
          while RouteStartTime + FullInterval +
            NewRouteIntervals[0].interval < BusArrival do
          begin
            NewRouteIntervals[0].interval :=
              NewRouteIntervals[0].interval + FullInterval;
          end;
          NewRouteIntervals[0].interval :=
            NewRouteIntervals[0].interval + FullInterval;
          // Assign to out Iinterval value and add new route data
          Iinterval := NewRouteIntervals[0].interval + RouteStartTime;
        end;
      end;
      // Inc Length
      setLength(FullCalculatedRoute[Totalcount], Count + 1);
      // Assign Vals
      TempStopRoute.Stop := Route[Count].Stop;
      TempStopRoute.Route := Route[Count + 1].Route;
      TempFullRoute.RouteAndStop := TempStopRoute;
      TempFullRoute.DepartureTime := Iinterval;
      // Assign to arr
      FullCalculatedRoute[TotalCount, Count] := TempFullRoute;
      Inc(Count);
      tStartTime := Iinterval;
    end;
    NewRouteIntervals := Route[Count].Route^.GetStopInterval(
      Route[Count - 1].Stop, Route[Count].Stop);
    // Inc Length
    setLength(FullCalculatedRoute[Totalcount], Count + 1);
    // Assign Vals
    TempFullRoute.RouteAndStop := Route[Count];
    TempFullRoute.DepartureTime := Iinterval + NewRouteIntervals[1].interval;
    // Assign to arr
    FullCalculatedRoute[TotalCount, Count] := TempFullRoute;
    Inc(Count);
    tStartTime := Iinterval;
  end;
  Result := FullCalculatedRoute;
end;

procedure APEngine.AdminShowTbl(param: string);
begin
  UpperCase(param);
  with Data_Connection.DataBase do
  begin
    case param of
      'B':
      begin
        SQLQuery1.Close;
        SQLQuery1.SQL.Clear;
        SQLQuery1.SQL.Text := 'SELECT * FROM BusStopTBL';
        SQLQuery1.Open;
      end;
      'R':
      begin
        SQLQuery1.Close;
        SQLQuery1.SQL.Clear;
        SQLQuery1.SQL.Text := 'SELECT * FROM RoutesTBL';
        SQLQuery1.Open;
      end;
      else
        {WriteLn('ERROR FROM AdminShowTbl() in Engine' + #13 + '+++++++++++++++' +
          #13 + 'Error, unknown flag recieved: avalible flags are "B"'
          + ' and "R".' + #13 + '__________________________________');}
    end;
  end;
end;

procedure APEngine.AdminDeleteRouteStop(RoutePtr: pRoute; StopPOS: integer);
var
  iRanOutOfIdeasForASensibleName: pBusStop;
  ToUpdateTo: integer;
begin
  // dismantle objects
  iRanOutOfIdeasForASensibleName := RoutePtr^.GetStopAtPos(StopPOS);
  // I just realized that we need to check if its the first or last
  //   stop and if it is then we need to modify all the interval values...
  //            YIKES
  RoutePtr^.DeleteStop(StopPOS);
  with Data_Connection.DataBase do
  begin
    SQLQuery1.Clear;
    SQLQuery1.SQL.Text := 'DELETE FROM RouteStopsTbl where RouteID = ' +
      QuotedStr(RoutePtr^.GetID) + 'AND RoutePosition = ' +
      IntToStr(StopPOS);
    SQLQuery1.ExecSQL;
    SQLTransaction1.Commit;
    while StopPOS <= RoutePtr^.GetLastPos() do
    begin
      SQLQuery1.Close;
      SQLQuery1.Clear;
      {writeln('UPDATE RouteStopsTbl SET RoutePosition = ' +
        IntToStr(StopPOS) + ' Interval = ' +
        QuotedStr(IntToStr(RoutePtr^.GetInterval(StopPOS)))
        + ' WHERE RouteID = ' + QuotedStr(RoutePtr^.GetID) +
        ' AND RoutePosition = ' + IntToStr(StopPOS + 1));}
      ToUpdateTo := StopPOS;
      SQLQuery1.SQL.Text := 'UPDATE RouteStopsTbl SET RoutePosition = ' +
        IntToStr(ToUpdateTo) + ' , Interval = ' +
        QuotedStr(IntToStr(RoutePtr^.GetInterval(StopPOS)))
        + ' WHERE RouteID = ' + QuotedStr(RoutePtr^.GetID) +
        ' AND RoutePosition = ' + IntToStr(ToUpdateTo + 1);
      SQLQuery1.ExecSQL;
      // Library nonsense
      SQLTransaction1.Commit;
      Inc(StopPOS);
    end;
    if RoutePtr^.IsStopInRoute(iRanOutOfIdeasForASensibleName) = False then
    begin
      SQLQuery1.Close;
      // Remove first so we update it correctly
      iRanOutOfIdeasForASensibleName^.RemoveLinked(RoutePtr);
      SQLQuery1.Clear;
      //writeln(iRanOutOfIdeasForASensibleName^.GetLinkedRoutes());
      SQLQuery1.SQL.Text := 'UPDATE BusStopTbl SET Close = ' +
        QuotedStr(
        iRanOutOfIdeasForASensibleName^.GetLinkedRoutes)
        + ' WHERE BusStopID = ' + QuotedStr(
        iRanOutOfIdeasForASensibleName^.GetID);
      SQLQuery1.ExecSQL;
    end;
    SQLTransaction1.Commit();
  end;
end;

procedure APEngine.AdminDeleteRoute(RouteID: string);
var
  Route: pBusRoute;
  AffectedRoutes: pArr;
  Affected: pBusStop;
begin
  // I knew this was worth doing properly hahahahahahahahhaha I just saved
  //   myself from so much pain
  Route := BinSearchRawR(self.pAllRoutes, RouteID);
  // In the BusRoute func I destroyed the objects first but thats stupid and
  //    makes things more complicated. If you think im going to rewrite it
  //    then you are sorely mistaken, that function can go to hell.
  //    However I will learn from my mistakes.

  // Make sure to trace during testing, I don't think the logic checks out.
  with Data_Connection.DataBase do
  begin
    SQLQuery1.Close;
    SQLQuery1.Clear;
    SQLQuery1.SQL.Text := 'DELETE FROM RouteStopsTbl WHERE RouteID = ' +
      QuotedStr(Route^.GetID);
    SQLQuery1.ExecSQL;

    SQLQuery1.Close;
    SQLQuery1.Clear;
    SQLQuery1.SQL.Text := 'DELETE FROM RoutesTbl Where RouteID = ' +
      QuotedStr(Route^.GetID);
    SQLQuery1.ExecSQL;

    AffectedRoutes := Route^.ClearRoute();
    for Affected in AffectedRoutes do
    begin
      SQLQuery1.Close;
      SQLQuery1.Clear;
      SQLQuery1.SQL.Text := 'UPDATE BusStopTbl SET Close = ' +
        QuotedStr(Affected^.GetLinkedRoutes) +
        ' WHERE BusStopID = ' + QuotedStr(Affected^.GetID);
      SQLQuery1.ExecSQL;
    end;
    // FreePascal nonsense
    SQLQuery1.Close;
    SQLTransaction1.Commit();
  end;
  // Now we must Null and destroy the pointer and objects and remove them from
  //     our lists
  //count := 0;
  //while count < length(self.pAllRoutes)-1 do
  //begin
  //  if self.pAllRoutes[count]^.GetID = RouteID then
  //     break;
  //  inc(count);
  //end;

  //// If found (Which it will be)... go through and delete it.
  //Route^.Destroy();
  //Route := Nil;
  //if count < length(self.pAllRoutes) then
  //begin
  //   while count < length(self.pAllRoutes)-1 do
  //   begin
  //     self.AllRoutes[count] := self.AllRoutes[count+1];
  //     inc(count);
  //   end;
  //end;
  //self.pAllRoutes[length(self.pAllRoutes)-1] := nil;
  //setlength(self.AllRoutes, length(self.AllRoutes)-1);
  //self.pAllRoutes[length(self.AllRoutes)] := nil;
  //DataBase.SQLTransaction1.Commit;
  //Affected := nil;
  //AffectedRoutes := nil;
end;

procedure APEngine.AdminDeleteStop(StopID: string);
var
  LinkedRoutes: pBusRouteArr;
  Route: pRoute;
  iPOS: integer;
  StopPtr: pBusStop;
begin
  // Ok so hears what im thinking.
  //    Stop knows what routes are linked to it.
  //    Put those routes into a list and itirate through
  //        Deleteing all instances of the stop with AdmindeleteStopRoute? +yes
  //        or We can use a modifyed version of the DeleteStop func of the -no
  //        Route class. From there we just update the entire table
  StopPtr := BinSearchRaw(self.pBusStops, StopID);
  LinkedRoutes := StopPtr^.GetLinkedRoutes(True);
  for Route in LinkedRoutes do
  begin
    while True do
    begin
      // make sure that you trace this carefully
      iPOS := Route^.GetStopPos(StopPtr);
      if iPOS >= 0 then
        // there is no way im rewriting that and doing it would make 0 sense
        self.AdminDeleteRouteStop(Route, iPOS)
      else
        break;
    end;
  end;
  with DataBase do
  begin
    SQLQuery1.Close;
    SQLQuery1.SQL.Text := 'DELETE FROM BusStopTBL WHERE BusStopID = ' +
      QuotedStr(StopPtr^.GetID);
    SQLQuery1.ExecSQL;
    SQLTransaction1.Commit();
  end;
  // Do I just tell them to restart?  - NO, you are better than that BOY!!!
  //DeletePOS := BinCarefullDelPOS(self.pBusStops,StopPtr^.GetID);
  //self.pBusStops[DeletePOS] := nil;
  //self.BusStops[DeletePOS].Destroy();
  //while DeletePOS < length(Self.BusStops) do
  //begin
  //  self.pBusStops[DeletePOS] := self.pBusStops[DeletePOS+1];
  //  self.BusStops[DeletePOS] := self.BusStops[DeletePOS+1];
  //end;
  //setLength(self.pBusStops, length(self.pBusStops)-1);
  //SetLength(self.BusStops, length(self.BusStops)-1);
end;

function APEngine.AdminGetIntervals(SelectedPOS: integer; Append: boolean;
  RoutePtr: pBusRoute): IntArr;
begin
  case Append of
    True: Result := RoutePtr^.GetIntervalsFrom(SelectedPOS);
    False: Result := RoutePtr^.GetIntervalsFrom(SelectedPOS - 1);
  end;
end;

procedure APEngine.AdminAddToRoute(RoutePtr: pRoute; SelectedPOS: integer;
  Stop: string; interval: integer; Append: boolean);
var
  Count: integer;
  StopPtr: pBusStop;
begin
  StopPtr := BinSearchRaw(self.pBusStops, Stop);
  // This should not be a switch but whatever ---> fixed it. Its now a if.
  if Append = False then
    Dec(SelectedPOS);
  // I should have improved how the selected position is handled but
  //  that would just be a mess to change at this point and it
  //  is already working just fine with out any performance implications.

  // Add to the route
  RoutePtr^.AddNewStop(StopPtr, SelectedPOS, interval);
  // Update stop data
  StopPtr^.AddClose(RoutePtr);
  // because its always appended and the 2nd val is the new stop.
  // --> um no it is not. Fixed more brainlet code
  Count := SelectedPOS + 1;

  // I hate databases
  with Data_Connection.DataBase do
  begin
    // GetLastPos gives true index so we don't need -1
    // --> but the array is one longer so we need it
    while Count <= RoutePtr^.GetLastPos() - 1 do
    begin
      SQLQuery1.Close;
      // table does not yet have new entry so shift everything up and
      //       Then add the new kid
      SQLQuery1.SQL.Text := 'UPDATE RouteStopsTbl SET RoutePosition = ' +
        IntToStr(Count + 1) + ' WHERE RoutePosition = ' +
        IntToStr(Count) + ' AND RouteID = ' + QuotedStr(RoutePtr^.GetID) +
        ' AND Interval = ' + IntToStr(RoutePtr^.GetInterval(count+1));
      SQLQuery1.ExecSQL;
      SQLTransaction1.Commit;
      Inc(Count);
    end;
    SQLQuery1.Close;
    // Inserts new data
    // Please note that this table is beyond human comprehension and
    //        is not possible to easyly understand. The program handles
    //        everything for us and it mearly serves to reduce repetitive data;
    SQLQuery1.SQL.Text := 'INSERT INTO RouteStopsTbl VALUES(' +
      QuotedStr(RoutePtr^.GetID) + ',' + IntToStr(
      SelectedPOS + 1) + ',' + QuotedStr(StopPtr^.GetID) +
      ',' + IntToStr(interval) + ')';
    SQLQuery1.ExecSQL;

    // Now Update StopData. I Should have made these functions but oh well
    SQLQuery1.Close;
    //              This won't affect data if stop is already part of
    //              Route
    SQLQuery1.SQL.Text := 'UPDATE BusStopTBL SET Close = ' +
      QuotedStr(StopPtr^.GetLinkedRoutes) +
      ' WHERE BusStopID = ' + QuotedStr(StopPtr^.GetID);
    SQLQuery1.ExecSQL;
    SQLTransaction1.Commit();
  end;
  StopPtr := nil;
  RoutePtr := nil;
  self.AdminShowTbl('R');
end;

procedure APEngine.AdminAddNewRoute(RouteName: string;
  DigitalStart, EndTime: string; RoutePrice: real);
var
  RandomHex: string;
  bDupe: boolean;
begin
  with Data_Connection.DataBase do
  begin
    while True do
    begin
      // the random fucntion doesn't generate entropy for some reason,
      //     There is probably a flag I can set but this needs to be here
      //     anyway so
      bDupe := False;
      RandomHex := IntToHex(random(16777215), 6);
      GetAllRoutes();
      SQLQuery1.First;
      while not SQLQuery1.EOF do
      begin
        if SQLQuery1.Fields[0].AsString = RandomHex then
          bDupe := True;

        SQLQuery1.Next;
      end;
      if bDupe = False then
        break;
    end;
    SQLQuery1.Close;
    SQLQuery1.SQL.Text := 'INSERT INTO RoutesTBL VALUES(' +
      QuotedStr(RandomHex) + ', ' + QuotedStr(EndTime) +
      ', ' + QuotedStr(DigitalStart) + ', ' +
      FloatToStr(RoutePrice) + ', ' + QuotedStr(RouteName) + ')';
    SQLQuery1.ExecSQL;
    SQLTransaction1.Commit;
  end;
  // Add object to list or restart program
end;

procedure APEngine.AdminAddNewStop(Location: string);
var
  RandomNum: integer;
  RandomHex: string;
  bDupe: boolean;
begin
  with Data_Connection.DataBase do
  begin
    while True do
    begin
      // the random fucntion doesn't generate entropy for some reason,
      //     There is probably a flag I can set but this needs to be here
      //     anyway so
      bDupe := False;
      RandomHex := IntToHex(random(16777215), 6);
      GetAllStops();
      SQLQuery1.First;
      while not SQLQuery1.EOF do
      begin
        if SQLQuery1.Fields[0].AsString = RandomHex then
          bDupe := True;

        SQLQuery1.Next;
      end;
      if bDupe = False then
        break;
    end;
    // bDupe will already be false here
    while True do
    begin
      bDupe := False;
      // Now make the stop name, ie Stop ***
      RandomNum := random(999);
      GetAllStops();
      SQLQuery1.First;
      while not SQLQuery1.EOF do
      begin
        // lol lots of procesing but oh well
        if StrToInt(Copy(SQLQuery1.Fields[3].AsString,
          POS(' ', SQLQuery1.Fields[3].AsString),
          length(SQLQuery1.Fields[3].AsString) - 5)) = RandomNum then
          bDupe := True;
        SQLQuery1.Next;
      end;
      if bDupe = False then
        break;
    end;

    SQLQuery1.Close;
    SQLQuery1.SQL.Text := 'INSERT INTO BusStopTBL VALUES(' +
      QuotedStr(RandomHex) + ', ' + QuotedStr(Location) +
      ',"" ,"Stop ' + IntToStr(RandomNum) + '")';
    SQLQuery1.ExecSQL;
    SQLTransaction1.Commit;
  end;
  // Add object to list or restart program
end;

procedure APEngine.AdminModifyRouteStopTimes(RoutePtr: pRoute; POS, Interval: integer);
begin
  RoutePtr^.ChangeStopIntervals(POS, Interval);
  with DataBase do
  begin
    SQLQuery1.Close;
    SQLQuery1.SQL.Text := 'UPDATE RouteStopsTBL SET Interval = ' +
                       IntToStr(Interval) + ' WHERE RouteID = ' +
                       QuotedStr(RoutePtr^.GetID) + ' AND RoutePosition = ' +
                       IntToStr(POS);
    SQLQuery1.ExecSQL;
    SQLTransaction1.Commit;
  end;
end;

procedure APEngine.AdminModifyRouteName(RoutePtr: pRoute; NewName: string);
begin
  // Modify database first
  with DataBase do
  begin
    SQLQuery1.Close;
    SQLQuery1.SQL.Text := 'UPDATE RoutesTBL SET RouteName = ' +
      QuotedStr(NewName) +
      ' WHERE RouteID = ' + QuotedStr(RoutePtr^.GetID);
    SQLQuery1.ExecSQL;
    SQLTransaction1.Commit;
  end;
  RoutePtr^.ChangeName(NewName);
end;

procedure APEngine.AdminModifyRouteTimes(RoutePtr: pRoute; Start, EndTime: string);
begin
  // Modify the data base first even though in this case it doesn't really
  //        matter. I like conssistency though.
  with DataBase do
  begin
    SQLQuery1.Close;
    SQLQuery1.SQL.Text := 'UPDATE RoutesTBL SET EndTime = ' +
      QuotedStr(EndTime) + ' ,StartTime = ' +
      QuotedStr(Start) + ' WHERE RouteID = ' +
      QuotedStr(RoutePtr^.GetID);
    SQLQuery1.ExecSQL;
    SQLTransaction1.Commit();
  end;
  RoutePtr^.ChangeTimes(Start, EndTime);
end;

procedure APEngine.AdminModifyRoutePrice(RoutePtr: pRoute; NewPrice: real);
begin
  with DataBase do
  begin
    SQLQuery1.Close;
    SQLQuery1.SQL.Text := 'UPDATE RoutesTBL SET TicketPrice = ' +
      FloatToStr(NewPrice) +
      ' WHERE RouteID = ' + RoutePtr^.GetID;
    SQLQuery1.Open;
  end;
  RoutePtr^.ChangePrice(NewPrice);
end;

destructor APEngine.Destroy;
var
  Count: integer;
begin
  Count := 0;
  while Count < length(self.BusStops) do
  begin
    FreeAndNil(self.BusStops[Count]);
    Inc(Count);
  end;
  Count := 0;
  while Count < length(self.AllRoutes) do
  begin
    FreeAndNil(self.AllRoutes[Count]);
    Inc(Count);
  end;
  Count := 0;
  while Count < length(self.pAllRoutes) do
  begin
    Self.pAllRoutes[Count] := nil;
    Inc(Count);
  end;
  Delete(pAllRoutes, 0, length(pAllRoutes));
  Count := 0;
  while Count < length(self.pBusStops) do
  begin
    self.pBusStops[Count] := nil;
    Inc(Count);
  end;
  self.pBusStops := nil;
  inherited;
end;

procedure APEngine.ReStart();
var
  Count: integer;
begin
  Count := 0;
  while Count < length(self.BusStops) do
  begin
    FreeAndNil(self.BusStops[Count]);
    Inc(Count);
  end;
  Count := 0;
  while Count < length(self.AllRoutes) do
  begin
    FreeAndNil(self.AllRoutes[Count]);
    Inc(Count);
  end;
  Count := 0;
  while Count < length(self.pAllRoutes) do
  begin
    Self.pAllRoutes[Count] := nil;
    Inc(Count);
  end;
  Count := 0;
  while Count < length(self.pBusStops) do
  begin
    self.pBusStops[Count] := nil;
    Inc(Count);
  end;
  self.GetNewStops();
end;

end.

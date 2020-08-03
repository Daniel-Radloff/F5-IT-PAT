unit Engine;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Custom_Classes, Data_Connection, db, Dialogs, math;

type
  FullRouteWithTimes = record
    RouteAndStop : StopRouteLink;
    DepartureTime : integer;
  end;


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
    pBusStops : pArr;
    AllRoutes : RouteArray;
    pAllRoutes : pBusRouteArr;
    function GetNewStops(): int16;
  public
    constructor Create(); overload;
    // Change sec prefs when stable
    function InitializeProgram(): int16;
    function StopsToInt():integer;

    // User End functions
    // Delete when the thing works, this is terrible
    function GiveStopsArr(): Custom_Classes.pStopArray;
    function GiveRoutesArr(): pBusRouteArr;
    function GetRoute(sStart: string; sEnd: string; StartTime: integer;
      EndTime: integer): FullRouteArr;

    // Some nice little data base features for the admin screen

    // Use with flags: 'B', 'R' to display apropreate table. no RS because
    //     table is not human readable
    procedure AdminShowTbl(param:string);
    // Delete a stop from a route
    procedure AdminDeleteRouteStop(RoutePtr:pRoute; StopPOS:integer);
    // Delete a route lol im going insane
    //        I'll see if I have time to make it better
    procedure AdminDeleteRoute(RouteID:String);
    // Delete a stop from the database.
    //        I might just check the input arg on this. Might use a
    //          string or a routeStop but those will be easy fixes as
    //          I already have existing implimentations to get
    //          the pointer to the busStop for both
    procedure AdminDeleteStop(StopPtr:pBusStop);
    // Checks and returns viable intervals between two concurent stops
    //        Need for the Admin frm
    function AdminGetIntervals(SelectedPOS:integer; Append:Boolean;
      RoutePtr:pBusRoute):IntArr;
    // Add a RouteStop to the Route
    procedure AdminAddToRoute(RoutePtr:pRoute; SelectedPOS:integer;
      StopPtr:pBusStop; interval:integer; Append:Boolean);
    // Make a new Route. I think this requires a reload of the
    //      Engine so the routes are in order for a BinarySearch
    procedure AdminAddNewRoute(RouteName:string;DigitalStart,EndTime:string;
      RoutePrice:real);
    // Create a new stop. Same prediciment as above
    procedure AdminAddNewStop(Location:string);
    // Modify the Stop linked to a route stop
    //        validates that stop does not appear twice already
    procedure AdminModifyRouteLinked(RoutePtr:pRoute; SelectedPOS:integer;
      StopPtr:pBusStop);
    // Modify the route name
    procedure AdminModifyRouteName(RoutePtr:pRoute;NewName:string);
    // Modify route start and end times
    procedure AdminModifyRouteTimes(RoutePtr:pRoute;Start,EndTime:string);
    // Modify route Price
    procedure AdminModifyRoutePrice(RoutePtr:pRoute; NewPrice:real);


    // Use override to not call default
    destructor Destroy; override;


  end;

 var MainEngine: APEngine;
 procedure Init();
 function BinSearchRawR(Field : pBusRouteArr; Search : string): pBusRoute;
 function BinSearchRaw(Field : pArr; Search: string): pBusStop;
 // A blatent copy paste of the other two functions but the most
 //   efficient way to do it so I don't mind. Besides, less work
 function binCarefullDelPOSR(Field : pBusRouteArr; Search : string): integer;
 function BinCarefullDelPOS(Field : pArr; Search: string): integer;

implementation

procedure Init();
var
		  x: Integer;
begin
  MainEngine := APEngine.Create();
  MainEngine.InitializeProgram();
end;

// I don't know why this isn't part of the engine object but it doesn't matter
//   and I might still find a use for it later.
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

function binCarefullDelPOSR(Field: pBusRouteArr; Search: string): integer;
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
     Result := index;
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

function BinCarefullDelPOS(Field: pArr; Search: string): integer;
var
  index: integer;
  rIndex: Extended;
  ID: String;
begin
  rIndex := length(Field)/2;
  index := round(rIndex);
  ID := Field[index]^.GetID();
  if ID = Search then
     Result := index;
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
  RouteIDRaw, linked, test: String;
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

function APEngine.GiveStopsArr(): Custom_Classes.pStopArray;
begin
  Result := @self.BusStops;
end;

function APEngine.GiveRoutesArr(): pBusRouteArr;
begin
  Result := self.pAllRoutes;
end;

function APEngine.GetRoute(sStart: string; sEnd: string; StartTime: integer;
  EndTime: integer): FullRouteArr;
var
  pbStart, pbEnd: pBusStop;
  ViableRoutes: RouteIntesecArr;
  Route: arrStopRouteLink;
  FullCalculatedRoute : FullRouteArr;
  TempFullRoute : FullRouteWithTimes;
  Intervals , ArrivalInterval, NewRouteIntervals: TimeCalcArr;
  tStartTime, RouteStartTime, count, FullInterval,
    TotalCount, Iinterval, BusArrival, LoopCount: Integer;
  Interval: IntArr;
  TempStopRoute : StopRouteLink;
begin
  // Get Stops to look for
  pbStart := BinSearchRaw(pBusStops,sStart);
  pbEnd := BinSearchRaw(pBusStops, sEnd);
  ViableRoutes := pbStart^.FindRouteInit(pbEnd,pbStart);

  // Great. Now look for times that link closely with the route
  // Keeps track for FullCalculatedRoute array
  TotalCount := -1;
  SetLength(FullCalculatedRoute,length(ViableRoutes));
  tStartTime := StartTime;
  For Route in ViableRoutes do
  begin
    // A Route is a group of Intersections that lead onto different routes
    count := 0;
    Inc(TotalCount);
    tStartTime := StartTime;
    while count < length(Route)-1 do
    begin
      RouteStartTime := Route[count].Route^.GetRouteStart;
      // Get next interval
      FullInterval := Route[Count].Route^.GetFullInterval;
      // Calculate Closest Time that we depart at for default
      // case is much faster than a if because of how it is compiled and
      //      executed at runtime. Kindof works like a hash table so it will
      //      imediatly jump to the else statement without comparing our
      //      count var.
      case count of
      0 :
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
          if (interval[0] + FullInterval)-StartTime < abs(interval[0] - StartTime) then
             interval[0] := interval[0] + FullInterval;
          // NOTE::!!!!
          //             Start Time should be included in time calc ie
          //             Before loop start
          //             we also need to check the second option
          //             if there is one
          Iinterval := interval[0] + RouteStartTime;
            // Inc Length
          setLength(FullCalculatedRoute[Totalcount],count+1);
          // Assign Vals
          TempStopRoute.Stop := Route[count].Stop;
          TempStopRoute.Route := Route[count].Route;
          TempFullRoute.RouteAndStop := TempStopRoute;
          TempFullRoute.DepartureTime := Iinterval;
          // Assign to arr
          FullCalculatedRoute[TotalCount,count] := TempFullRoute;
          Inc(Count);
          tStartTime := Iinterval;
          Continue;
        end;

      else
        begin
          // Get some values by using patterns to know what values we can use
          ArrivalInterval := Route[count-1].Route^.GetStopInterval(
                        Route[count-1].Stop, Route[count].Stop);
          //        Calc when bus will arrive
          BusArrival := (ArrivalInterval[1].interval -
                   ArrivalInterval[0].interval) + tStartTime;
          //         Get Stop arrival intervals for new route
          // cant tell if >= matters because of loop condition but better safe
          //      than access violation. If len 2 then loop I think loop will
          //      catch it but im not 100% sure
          //
          { TODO : add when we need to get off and wait for next bus }
          if count >= length(route)-1 then
             break;
          // Do you even understand how much pain it took to get to this point?
          //    I cant be botherd to write another overloaded function that
          //    returns a more clean result at this moment. I'll kill
          //    myself if I have to do that again.
          NewRouteIntervals := Route[count+1].Route^.GetStopInterval(Route[count].Stop
                      ,Route[count+1].Stop);
            // We need to be at the stop before the bus is so we go till
            //    we go over and then add that full interval after the loop
          while RouteStartTime + FullInterval + NewRouteIntervals[0].interval
                < BusArrival do
          begin
            NewRouteIntervals[0].interval := NewRouteIntervals[0].interval +
                                          FullInterval;
          end;
          NewRouteIntervals[0].interval := NewRouteIntervals[0].interval +
                                        FullInterval;
          // Assign to out Iinterval value and add new route data
          Iinterval := NewRouteIntervals[0].interval + RouteStartTime;
        end;
      end;
      // Inc Length
      setLength(FullCalculatedRoute[Totalcount],count+1);
      // Assign Vals
      TempStopRoute.Stop := Route[count].Stop;
      TempStopRoute.Route := Route[count+1].Route;
      TempFullRoute.RouteAndStop := TempStopRoute;
      TempFullRoute.DepartureTime := Iinterval;
      // Assign to arr
      FullCalculatedRoute[TotalCount,count] := TempFullRoute;
      Inc(Count);
      tStartTime := Iinterval;
    end;
    NewRouteIntervals := Route[count].Route^.GetStopInterval(Route[count-1].Stop
                      ,Route[count].Stop);
    // Inc Length
    setLength(FullCalculatedRoute[Totalcount],count+1);
    // Assign Vals
    TempFullRoute.RouteAndStop := Route[Count];
    TempFullRoute.DepartureTime := Iinterval + NewRouteIntervals[1].interval;
    // Assign to arr
    FullCalculatedRoute[TotalCount,count] := TempFullRoute;
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
    'B' :
      begin
        SQLQuery1.SQL.Clear;
        SQLQuery1.SQL.Text := 'SELECT * FROM BusStopTBL';
        SQLQuery1.Open;
      end;
    'R' :
      begin
        SQLQuery1.SQL.Clear;
        SQLQuery1.SQL.Text := 'SELECT * FROM RoutesTBL';
        SQLQuery1.Open;
      end;
    else
      WriteLn('ERROR FROM AdminShowTbl() in Engine' + #13 + '+++++++++++++++' +
                     #13+ 'Error, unknown flag recieved: avalible flags are "B"'
                     +' and "R".' + #13 + '__________________________________');
    end;
  end;
end;

procedure APEngine.AdminDeleteRouteStop(RoutePtr: pRoute; StopPOS: integer);
var
  iRanOutOfIdeasForASensibleName: pBusStop;
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
    SQLQuery1.Open;
    while StopPOS < RoutePtr^.GetLastPos() do
    begin
      SQLQuery1.Close;
      SQLQuery1.Clear;
      SQLQuery1.SQL.Text := 'UPDATE RouteStopsTbl SET RoutePosition = ' +
                            IntToStr(StopPOS) + ' Interval = ' +
                            IntToStr(RoutePtr^.GetInterval(StopPOS)) +
                            ' WHERE RouteID = '+ QuotedStr(RoutePtr^.GetID) +
                            ' AND RoutePosition = ' + IntToStr(StopPOS+1);
      SQLQuery1.Open;
      Inc(StopPOS);
    end;
    if RoutePtr^.IsStopInRoute(iRanOutOfIdeasForASensibleName) = False then
    begin
       SQLQuery1.Close;
       SQLQuery1.Clear;
       SQLQuery1.SQL.Text := 'UPDATE BusStopTbl SET Close = ' +
                       QuotedStr(
                       iRanOutOfIdeasForASensibleName^.GetLinkedRoutes)
                       + ' WHERE BusStopID = ' + QuotedStr(
                       iRanOutOfIdeasForASensibleName^.GetID);
       SQLQuery1.Open;
       iRanOutOfIdeasForASensibleName^.RemoveLinked(RoutePtr);
    end;
  end;
end;

procedure APEngine.AdminDeleteRoute(RouteID: String);
var
  Route: pBusRoute;
  AffectedRoutes: pArr;
  Affected: pBusStop;
  count: Integer;
begin
  // I knew this was worth doing properly hahahahahahahahhaha I just saved
  //   myself from so much pain
  Route := BinSearchRawR(self.pAllRoutes,RouteID);
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
    SQLQuery1.Open;

    SQLQuery1.Close;
    SQLQuery1.Clear;
    SQLQuery1.SQL.Text := 'DELETE FROM RoutesTbl Where RouteID = ' +
                          QuotedStr(Route^.GetID);
    SQLQuery1.Open;

    AffectedRoutes := Route^.ClearRoute();
    for Affected in AffectedRoutes do
    begin
      SQLQuery1.Close;
      SQLQuery1.Clear;
      SQLQuery1.SQL.Text := 'UPDATE BusStopTbl SET Close = ' +
                            QuotedStr(Affected^.GetLinkedRoutes) +
                            ' WHERE BusStopID = ' + QuotedStr(Affected^.GetID);
      SQLQuery1.Open;
    end;
  end;
  // Now we must Null and destroy the pointer and objects and remove them from
  //     our lists
  count := 0;
  while count < length(self.pAllRoutes)-1 do
  begin
    if self.pAllRoutes[count]^.GetID = RouteID then
       break;
    inc(count);
  end;

  // If found, Which it will be, go through and delete it.
  Route^.Destroy();
  Route := Nil;
  if count < length(self.pAllRoutes) then
  begin
     while count < length(self.pAllRoutes)-1 do
     begin
       self.pAllRoutes[count] := self.pAllRoutes[count+1];
       self.AllRoutes[count] := self.AllRoutes[count+1];
     end;
  end;
  setlength(self.pAllRoutes,length(self.pAllRoutes)-1);
  setlength(self.AllRoutes, length(self.AllRoutes)-1);
end;

procedure APEngine.AdminDeleteStop(StopPtr: pBusStop);
var
  LinkedRoutes: pBusRouteArr;
  Route: pRoute;
  iPOS, DeletePOS: Integer;
begin
  // Ok so hears what im thinking.
  //    Stop knows what routes are linked to it.
  //    Put those routes into a list and itirate through
  //        Deleteing all instances of the stop with AdmindeleteStopRoute? +yes
  //        or We can use a modifyed version of the DeleteStop func of the -no
  //        Route class. From there we just update the entire table

  LinkedRoutes := StopPtr^.GetLinkedRoutes(True);
  for Route in LinkedRoutes do
  begin
    while True do
    begin
      // make sure that you trace this carefully
      iPOS := Route^.GetStopPos(StopPtr);
      if iPOS >= 0 then
         // there is no way im rewriting that and doing it would make 0 sense
         self.AdminDeleteRouteStop(Route,iPOS)
      else
        break;
    end;
  end;
  with DataBase do
  begin
    SQLQuery1.Close;
    SQLQuery1.SQL.Text := 'DELETE FROM BusStopTBL WHERE BusStopID = ' +
                          QuotedStr(StopPtr^.GetID);
    SQLQuery1.Open;
  end;
  // Do I just tell them to restart?  - NO, you are better than that BOY!!!
  DeletePOS := BinCarefullDelPOS(self.pBusStops,StopPtr^.GetID);
  self.pBusStops[DeletePOS] := nil;
  self.BusStops[DeletePOS].Destroy();
  while DeletePOS < length(Self.pBusStops) do
  begin
    self.pBusStops[DeletePOS] := self.pBusStops[DeletePOS+1];
    self.BusStops[DeletePOS] := self.BusStops[DeletePOS+1];
  end;
  setLength(self.pBusStops, length(self.pBusStops)-1);
  SetLength(self.BusStops, length(self.BusStops)-1);
end;

function APEngine.AdminGetIntervals(SelectedPOS: integer; Append: Boolean;
  RoutePtr: pBusRoute): IntArr;
begin
  case Append of
  True : Result := RoutePtr^.GetIntervalsFrom(SelectedPOS);
  False : Result := RoutePtr^.GetIntervalsFrom(SelectedPOS-1);
  end;
end;

procedure APEngine.AdminAddToRoute(RoutePtr: pRoute; SelectedPOS: integer;
  StopPtr: pBusStop; interval: integer; Append: Boolean);
var
  count : integer;
begin
  // This should not be a switch but whatever
  case Append of
  False : Dec(SelectedPOS);
  end;
  // I should have improved how the selected position is handled but
  //  that would just be a mess to change at this point and it
  //  is already working just fine with out any performance implications.

  // Add to the route
  RoutePtr^.AddNewStop(StopPtr,SelectedPOS,interval);
  // Update stop data
  StopPtr^.AddClose(RoutePtr);
  // because its always appended and the 2nd val is the new stop.
  count := SelectedPOS+2;

  // I hate databases
  with Data_Connection.DataBase do
  begin
    while count < RoutePtr^.GetLastPos() do
    begin
      SQLQuery1.Close;
      SQLQuery1.SQL.Text := 'UPDATE RouteStopsTbl SET RoutePosition = ' +
                            IntToStr(count) + ' WHERE RoutePosition = ' +
                            IntToStr(count-1) +  ' AND RouteID = ' +
                            QuotedStr(RoutePtr^.GetID);
      SQLQuery1.Open;
    end;
    SQLQuery1.Close;
    // Inserts new data
    // Please note that this table is beyond human comprehension and
    //        is not possible to understand. The program handles everything
    //        for us and it mearly serves to reduce redundency;
    SQLQuery1.SQL.Text := 'INSERT INTO RouteStopsTbl VALUES(' +
                       QuotedStr(RoutePtr^.GetID) + ',' + IntToStr(
                       SelectedPOS+1) + ',' + QuotedStr(StopPtr^.GetID) +
                       ',' + IntToStr(interval) + ')';
    SQLQuery1.Open;

    // Now Update StopData. I Should have made these functions but oh well
    SQLQuery1.Close;
    SQLQuery1.SQL.Text := 'UPDATE BusStopTBL SET Close = ' +
                          QuotedStr(StopPtr^.GetLinkedRoutes)
                          + ' WHERE BusStopID = ' + QuotedStr(StopPtr^.GetID);
    SQLQuery1.Open;
  end;
  self.AdminShowTbl('R');
end;

procedure APEngine.AdminAddNewRoute(RouteName: string; DigitalStart,
  EndTime: string; RoutePrice: real);
var
  RandomHex: String;
  bDupe: Boolean;
begin
  With Data_Connection.DataBase do
  begin
    while True do
    begin
      // the random fucntion doesn't generate entropy for some reason,
      //     There is probably a flag I can set but this needs to be here
      //     anyway so
      bDupe := False;
      RandomHex := IntToHex(random(16777215),6);
      GetAllRoutes();
      SQLQuery1.First;
      while not SQLQuery1.EOF do
      begin
        if SQLQuery1.Fields[0].AsString = RandomHex then
        bDupe := True;

        SQLQuery1.Next;
      end;
      if bDupe = False then break;
    end;
    SQLQuery1.Close;
    SQLQuery1.SQL.Text := 'INSERT INTO RoutesTBL VALUES(' + QuotedStr(RandomHex)
                          + ', ' + QuotedStr(EndTime) + ', ' +
                          QuotedStr(DigitalStart) + ', ' + FloatToStr(RoutePrice)
                          + ', ' + QuotedStr(RouteName) + ')';
    SQLQuery1.Open;
  end;
  // Add object to list or restart program
end;

procedure APEngine.AdminAddNewStop(Location: string);
var
  RandomNum: Integer;
  RandomHex: String;
  bDupe: Boolean;
begin
  With Data_Connection.DataBase do
    begin
      while True do
      begin
        // the random fucntion doesn't generate entropy for some reason,
        //     There is probably a flag I can set but this needs to be here
        //     anyway so
        bDupe := False;
        RandomHex := IntToHex(random(16777215),6);
        GetAllStops();
        SQLQuery1.First;
        while not SQLQuery1.EOF do
        begin
          if SQLQuery1.Fields[0].AsString = RandomHex then
          bDupe := True;

          SQLQuery1.Next;
        end;
        if bDupe = False then break;
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
          if StrToInt(Copy(SQLQuery1.Fields[0].AsString,
             POS(' ', SQLQuery1.Fields[0].AsString),
             length(SQLQuery1.Fields[0].AsString)-5)) = RandomNum then
             bDupe := True;
        end;
        if bDupe = False then break;
      end;

      SQLQuery1.Close;
      SQLQuery1.SQL.Text := 'INSERT INTO BusStopTBL VALUES(' +
                            QuotedStr(RandomHex) + ', ' + QuotedStr(Location) +
                            ',"" ,"Stop ' + IntToStr(RandomNum) + '")';
      SQLQuery1.Open;
    end;
    // Add object to list or restart program
end;

procedure APEngine.AdminModifyRouteLinked(RoutePtr: pRoute;
  SelectedPOS: integer; StopPtr: pBusStop);
begin
  // Check if stop repeats in route
  if RoutePtr^.DoesStopRepeat(StopPtr) = True then exit; // This will be changed
                                                         // I now see the issue
  RoutePtr^.ChangeLinkedStop(StopPtr,SelectedPOS);
  StopPtr^.AddClose(RoutePtr);
end;

procedure APEngine.AdminModifyRouteName(RoutePtr: pRoute; NewName: string);
begin
  // Modify database first
  with DataBase do
    begin
      SQLQuery1.Close;
      SQLQuery1.SQL.Text := 'UPDATE RoutesTBL SET RouteName = ' +
                            QuotedStr(NewName) + ' WHERE RouteID = '
                            + QuotedStr(RoutePtr^.GetID);
      SQLQuery1.Open;
    end;
  RoutePtr^.ChangeName(NewName);
end;

procedure APEngine.AdminModifyRouteTimes(RoutePtr: pRoute; Start,
  EndTime: string);
begin
  // Modify the data base first even though in this case it doesn't really
  //        matter. I like conssistency though.
  with DataBase do
    begin
      SQLQuery1.Close;
      SQLQuery1.SQL.Text := 'UPDATE RoutesTBL SET EndTime = ' +
                            QuotedStr(EndTime) + ' StartTime = ' +
                            QuotedStr(Start) + ' WHERE RouteID = ' +
                            QuotedStr(RoutePtr^.GetID);
      SQLQuery1.Open;
    end;
  RoutePtr^.ChangeTimes(Start, EndTime);
end;

procedure APEngine.AdminModifyRoutePrice(RoutePtr: pRoute; NewPrice: real);
begin
  with DataBase do
    begin
      SQLQuery1.Close;
      SQLQuery1.SQL.Text := 'UPDATE RoutesTBL SET TicketPrice = ' +
                            FloatToStr(NewPrice) + ' WHERE RouteID = '
                            + RoutePtr^.GetID;
      SQLQuery1.Open;
    end;
  RoutePtr^.ChangePrice(NewPrice);
end;

destructor APEngine.Destroy;
var
  count : integer;
begin
  count := 0;
  While count < length(self.BusStops) do
  begin
    FreeAndNil(self.BusStops[count]);
    inc(Count)
  end;
  count := 0;
  While  count < length(self.AllRoutes) do
  begin
    FreeAndNil(self.AllRoutes[count]);
    inc(count);
  end;
  count := 0;
  while count < length(self.pAllRoutes) do
  begin
    Self.pAllRoutes[count] := nil;
    inc(count);
  end;
  setLength(self.pAllRoutes,0);
  count := 0;
  while count < length(self.pBusStops) do
  begin
    self.pBusStops[count] := nil;
    inc(count);
  end;
  setLEngth(self.pBusStops,0);
  inherited;
end;

end.

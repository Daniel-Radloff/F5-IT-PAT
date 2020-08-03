unit Custom_Classes;

{$mode objfpc}{$H+}
//{$rangeChecks on}

interface

uses
  Classes, SysUtils, contnrs;

type
  initInfoRouteStop = record
    ID : string;
    pos : integer;
    interval : integer;
  end;

  // These types are declared here but are not really used. This is to avoid
  //       circular refrence in the engine unit because I need some of them
  //       here but im to lazy to make another unit file because I already have
  //       so many.

  // Pointer to array of all stops in existance. Used for searches and
  //         manipulation
  pStopArray = ^StopArray;

  // All these types have to be defined because if they arn't the compliler
  //      has a fit and throws about 237 errors 🙁
  // Pointer to busStop
  pBusStop = ^BusStop;
  // Used to make custom arrays of pBusStops
  pArr = array of pBusStop;
  // Pointer Used to manipulate pArr
  pArrp = ^pArr;
  // Used mainly in busStop.findRoute() which returns format [[x,y,z],[x,y]]
  pRouteArray = array of pArr;
  // Pointer Used to manipulate pRouteArray in busStop.FindRoute()
  pRouteArrayp = ^pRouteArray;

  pTFPHashList = ^TFPHashList;
  pRoute = ^BusRoute;

  pBusRoute = ^BusRoute;
  pBusRouteArr = array of pRoute;


  StopRouteLink = record
    Stop : pBusStop;
    Route : pBusRoute;
  end;
  arrStopRouteLink = array of StopRoutelink;
  RouteIntesecArr = array of arrStopRouteLink;
  TimeCalc = record
    Stop : pBusStop;
    interval : integer;
  end;
  TimeCalcArr = array of TimeCalc;
  IntArr = array of integer;


  { BusStop }
//  This is a important class that is also the first class to be inititalized
//       in the initialization process. It is used to give human readable
//       information on where the stop is and what its name is, and it is
//       used to trace routes from A to B which is the main point of the
//       program.
  BusStop = Class
  Strict Private
    sName : string;
    sID : string;
    sLocation : string;
    aClose : pBusRouteArr;
    // This is the real findRoute function, you will see why it is declared here
    //      in the comments before FindRouteInit's def.
    procedure FindRoute(FinnalStop:Pointer;
      CurrentRoute: pTFPHashList; Found: pRouteArrayp; Depth: integer);
    // Return connected routes
  private
    function GetRoutes():pBusRouteArr;



    { Private End }

  Public

    // Creates the Object and is part of the first stage of program
    //         initialization
    Constructor Create(Name:String;ID:String;Location:String);
    // Is Used in second stage of Initialization and is used to populate
    //    The aClose variable of all the BusStops
    Procedure AddClose(Stop:pBusRoute);
    procedure AddClose(Stops: Array of pointer); overload;
    // Is Used in the Route finder Routine and starts the function which
    //    finds all posibble routes from the Stop it is run from to the stop
    //    specifyed. This is neccicary because of a limitation of delphi and
    //    this was the only way around it that I could think of.
    Function FindRouteInit(FinnalStop:pBusStop; StartStop:pBusStop) : RouteIntesecArr;
    function ToString: ansistring; override;
    function GetID: string;
    function GetName:string;
    // Return all with CSV
    function GetLinkedRoutes: string;
    // Return all with pointer arr. Use True or false to call
    function GetLinkedRoutes(Pointers:Boolean): pBusRouteArr; overload;
    procedure RemoveLinked(Route:pRoute);
    destructor Destroy(); override;
    { Public End }

  end;

  // This needs to be down here to the compiler can see it

  // Array of all busStops in existance
  StopArray = array of BusStop;

//    This class is used to link routes to stops, to provide a way of
//         identifying routes within a sequence of stops, finding out which
//         stops are within walking distance of each other, and calculating
//         when a bus will arive and depart at a stop in a route.

  { RouteStop }
  // ..... look ......
  // I don't understand parents or higherachie
  // so leave me alone and stop bullying me XD
  RouteStop = Class
  Strict Private
    // This is a interval used to calculate the times at which the bus will
    //      reach this stop during its shift.
    iInterval : integer;
    // This is a pointer that links the route stop to its relavent BusStop
    //      object sothat we can figure out which tickets to buy.
    linkedStop : pBusStop;
    // Used to see where the stop is located within the sequence of stops that
    //      the route uses. Esentialy places stops in order so we know the
    //      order in which the route will stop.
    // ok... I will admit, this is a really stupid value as the
    //       stops are always in order and many parts of the program
    //       require the stops to be in order but others need this
    //       variable. I should refactor but I dont have time and it
    //       is going to break so many things that its just not worth.
    routePOS : integer;

  Private
    {%H-}constructor Create(POS:integer; Stop:pBusStop;
      TimeInterval:integer);
    function isStop(stop: pBusStop): boolean;
    function GetLinkedRoutes:pBusRouteArr;
    function GetStop:pBusStop;
    function GetInterval:integer;
    function GetPos:integer;
    procedure DecPos;
    procedure IncPos;
    procedure ChangeLinked(StopPtr:pBusStop);
    procedure ChangeInterval(interval:integer);
  public
    destructor Destroy(); override;


  end;

  //  This class is used to define routes and allows the user to purchace the
  //       correct tickets for their destination

  { BusRoute }

  BusRoute = Class
    strict private
      // Name of the route (Human Readable)
      sName : string;
      // Stored as sting because manipulation is just easyer
      sTimeStart, sTimeEnd : String;
      // Used to uniquely identify in Database and in program
      sID : String;
      // Shows and is used to calcutate the cost of the route
      rPrice : real;
      // Used to store all the stops for this route.
      arrRouteStops : array of RouteStop;

    private
      function GetAllLinkedRoutes:pBusRouteArr;
      function FindStopOnRoute(RoutesToFind: pBusRouteArr): arrStopRouteLink;

    public
      constructor Create(ID: String; timeEnd: String; timeStart: String;
        price: real;Name: String);
      function PopulateRoute(Position:integer; linkedStop:pBusStop;
        iinterval:integer):int16;
      function GetID:string;
      function GetHID:string;
      function GetStopInterval(Stop:pBusStop; Stop2:pBusStop):TimeCalcArr;
      function GetStopInterval(Stop:pBusStop):IntArr; overload;
      function GetRouteStart: integer;
      // Get the full route interval
      function GetFullInterval: integer;
      procedure DeleteStop(POS:integer);
      destructor Destroy(); override;
      // im too lazy to think of anything better... leave me alone
      function GetLastPos():integer;
      function GetStopAtPos(POS:integer):pBusStop;
      // used to return pos of first instance of a stop in the route
      //      not the best but I use in because I want to re-use some
      //      other very complicated code. But it will probably come
      //      in handy somewhere else to :)
      function GetStopPos(Stop:pBusStop):integer;
      // This clears route and returns all effected stops
      function ClearRoute():pArr;
      // Returns interval info on stops inbetween the selected position and next
      function GetIntervalsFrom(POS:integer):IntArr;
      // Get interval of stop. Im really sorry these are quite confusing;
      function GetInterval(POS:integer):integer;
      // Adds a stop to the route
      procedure AddNewStop(Stop:pBusStop; StopPOS:integer; Interval:integer);
      function DoesStopRepeat(Stop:pBusStop):boolean;
      function IsStopInRoute(Stop:pBusStop):boolean;
      procedure ChangeLinkedStop(Stop:pBusStop; StopPOS:integer);
      procedure ChangeName(NewName:string);
      procedure ChangeTimes(StartNew,EndNew:string);
      procedure ChangePrice(NewPrice:real);

  end;
   // A array of all routes, used in engine for init,cals and other
  RouteArray = array of BusRoute;
  // Is There a common route. Only used in Findroute
  function IsCommonRoute(Test1:pBusRouteArr; Test2: pBusRouteArr):pBusRouteArr;
  function IsCommonRoute(Test1:pBusStop; Test2:pBusStop):StopRouteLink;
  overload;
  // Revmove dupes Modify is the list of potential dupes, Modifyer is the
  //                             List to compare and returns appended
                               //non dupe stops.
  procedure RemoveDupes(Modify: pBusRouteArr;var Modifer: pBusRouteArr);
  procedure RemoveDupes(var arr:pBusRouteArr); overload;
  function RemoveDupes(var arr:arrStopRouteLink):arrStopRouteLink;
  Function FindDupes(Modify: pBusRouteArr; Modifer: pBusRouteArr): pBusRouteArr;
  Function FindIntersections(Test1:arrStopRouteLink; Test2:arrStopRouteLink):
           RouteIntesecArr;
implementation

{ BusRoute }

function BusRoute.GetAllLinkedRoutes: pBusRouteArr;
var
  stop: RouteStop;
  StopRoutes: pBusRouteArr;
  AllRoutes: pBusRouteArr;
begin
  for stop in Self.arrRouteStops do
  begin
    StopRoutes := stop.GetLinkedRoutes();
    RemoveDupes(StopRoutes,AllRoutes);
  end;
  Result := AllRoutes;
end;

function BusRoute.FindStopOnRoute(RoutesToFind: pBusRouteArr): arrStopRouteLink;
var
  stop: RouteStop;
  StopRoutes: pBusRouteArr;
  LinkedRoute, Route: pRoute;
  FoundLinks , FilteredLinks: arrStopRouteLink;
  Link : StopRouteLink;
begin
  SetLength(FoundLinks,0);
  for stop in self.arrRouteStops do
  begin
    StopRoutes := stop.GetLinkedRoutes();
    for Route in RoutesToFind do
    begin

      for LinkedRoute in StopRoutes do
      begin
        if Route = LinkedRoute then
        begin
          Link.Route := Route;
          Link.Stop := stop.GetStop;
          SetLength(FoundLinks, length(FoundLinks)+1);
          FoundLinks[length(FoundLinks)-1] := Link;
        end;
      end;
    end;
  end;
  FilteredLinks := RemoveDupes(FoundLinks);
  FoundLinks := nil;
  Result := FilteredLinks;
end;

constructor BusRoute.Create(ID: String; timeEnd: String; timeStart: String;
  price: real; Name: String);
begin
  self.sName := Name;
  self.sTimeStart := timeStart;
  self.sTimeEnd := timeEnd;
  self.sID := ID;
  self.rPrice := price;
  SetLength(self.arrRouteStops,0);
  // pop stops list in a separtate function

end;

function BusRoute.PopulateRoute(Position: integer; linkedStop: pBusStop;
  iinterval: integer): int16;
var NewRouteStop : RouteStop;
begin
  // MAke this brand new BANGNING, EPIC route stop thing
  NewRouteStop := RouteStop.Create(Position, linkedStop, iinterval);
  // Add it to the route array thing in the route which is also in array which
  //     is linked to in another array and.... yes
  SetLength(self.arrRouteStops, length(self.arrRouteStops) + 1);
  self.arrRouteStops[length(arrRouteStops)-1] := NewRouteStop;
  Result := 0;
end;

function BusRoute.GetID: string;
begin
  Result := self.sID;
end;

function BusRoute.GetHID: string;
begin
  Result := self.sName;
end;

function BusRoute.GetStopInterval(Stop: pBusStop; Stop2: pBusStop): TimeCalcArr;
var
  EachStop : RouteStop;
  Intervals : array of TimeCalc;
  TempInterval : TimeCalc;
  count , FullRotation: integer;
begin
  for EachStop in self.arrRouteStops do
  begin
    // If We Find stop that were going to then
    if EachStop.GetStop^ = Stop2^ then
    begin
      setlength(Intervals,length(intervals)+1);
      TempInterval.Stop := Stop2;
      TempInterval.interval := EachStop.GetInterval;
      Intervals[length(intervals)-1] := TempInterval;
    end;
    if EachStop.GetStop^ = Stop^ then
    begin
      setlength(Intervals,length(intervals)+1);
      TempInterval.Stop := Stop;
      TempInterval.interval := EachStop.GetInterval;
      Intervals[length(intervals)-1] := TempInterval;
    end;
  end;
  count := 0;
  While length(intervals) > count + 1 do
  begin
    if (Intervals[count].Stop^ = Stop^) and (Intervals[count+1].Stop^ = Stop2^) then
    begin
      Result := Copy(Intervals,count,2);
      Exit;
      break;
    end;
    inc(count);
  end;
  // if none found append dupe arr and modify dupe vals
  SetLength(Intervals,length(Intervals)*2);
  count := 0;
  FullRotation := self.GetFullInterval;
  while count < Round(length(Intervals)/2) do
  begin
    TempInterval := Intervals[count];
    TempInterval.interval := FullRotation + TempInterval.interval;
    Intervals[count+(Round(length(Intervals)/2))] := TempInterval;
    Inc(count);
  end;
  // Perform again but start at half-1 because other half has been checked and
  //         Stop at half + 2
  //       Never mind SEG fault
  count := length(Intervals) - Trunc(length(Intervals)/2)-1;
  While Trunc(length(intervals)/2)+1 > count do
  begin
    if (Intervals[count].Stop = Stop) and (Intervals[count+1].Stop = Stop2) then
    begin
      Result := Copy(Intervals,count,2);
      exit;
      break;
    end;
    inc(count);
  end;
  // If still nothing then give up
  Result := nil;
end;

function BusRoute.GetStopInterval(Stop: pBusStop): IntArr;
var
  Each : RouteStop;
  Intervals : array of integer;
begin
  setlength(Intervals,0);
  for Each in self.arrRouteStops do
  begin
    if Each.GetStop = Stop then
    begin
      SetLength(Intervals,length(Intervals)+1);
      Intervals[length(Intervals)-1] := Each.GetInterval;
    end;
  end;
  Result := Intervals;
end;

function BusRoute.GetRouteStart: integer;
var
  iTime: LongInt;
  sTime: String;
  half: Int64;
begin
  sTime := self.sTimeStart;
  half := trunc(length(sTime)/2);
  if half = 2 then
  begin
    iTime := StrToInt(Copy(sTime,0,2))*60;
    Delete(sTime,1,2);
    iTime := iTime + StrToInt(sTime);
    Result := iTime;
  end
  else
  begin
    iTime := StrToInt(Copy(sTime,0,1))*60;
    delete(sTime,1,1);
    iTime := iTime + StrToInt(sTime);
    Result := iTime;
  end;
end;

function BusRoute.GetFullInterval: integer;
begin
  Result := self.arrRouteStops[length(arrRouteStops)-1].GetInterval;
end;

procedure BusRoute.DeleteStop(POS: integer);
var
  max, ToChange: Integer;
begin
  max := self.GetLastPos();
  case POS of
    0 : begin
      self.arrRouteStops[POS].Destroy();
      // reWrite array
      while POS < length(self.arrRouteStops)-1 do
      begin
        self.arrRouteStops[POS] := self.arrRouteStops[POS+1];
        self.arrRouteStops[POS].DecPos();
        inc(POS);
      end;
      SetLength(self.arrRouteStops,length(self.arrRouteStops)-1);
      // We need to change intervals... no clue how sql will look like
      POS := 0;
      while POS < Length(self.arrRouteStops) do
      begin
        ToChange := self.arrRouteStops[POS+1].GetInterval();
        self.arrRouteStops[POS+1].ChangeInterval(ToChange -
            self.arrRouteStops[POS].GetInterval);
      end;
      self.arrRouteStops[0].ChangeInterval(0);
    end;
    else begin
    self.arrRouteStops[POS].Destroy();
      // keep array in order because I can not remember
      //      If it is important or not.
    while POS < length(self.arrRouteStops)-1 do
    begin
    self.arrRouteStops[POS] := self.arrRouteStops[POS+1];
    self.arrRouteStops[POS].DecPos();
    inc(POS);
    end;
    SetLength(arrRouteStops,length(arrRouteStops)-1);
    end;
  end;
end;

destructor BusRoute.Destroy();
var
		  stop: RouteStop;
begin
  for stop in self.arrRouteStops do
  begin
    stop.Destroy();
  end;
  arrRouteStops := nil;
  inherited;
end;

function BusRoute.GetLastPos(): integer;
begin
  Result := length(self.arrRouteStops)-1;
end;

function BusRoute.GetStopAtPos(POS: integer): pBusStop;
begin
  Result := self.arrRouteStops[POS].GetStop()
end;

function BusRoute.GetStopPos(Stop: pBusStop): integer;
var
  each: RouteStop;
begin
  for each in self.arrRouteStops do
  begin
    if each.GetStop = Stop then Result := each.GetPos;
  end;
  Result := -1;
end;

function BusRoute.ClearRoute(): pArr;
var
   AffectedStops : pArr;
   Stop: RouteStop;
   Found: pBusStop;
begin
  for Stop in self.arrRouteStops do
  begin
    Stop.GetStop^.RemoveLinked(@self);
    // I Cannot bring myself to writing a better way of doing this
    for Found in AffectedStops do
    if Stop.GetStop = Found then Continue;
    SetLength(AffectedStops,length(AffectedStops)+1);
    // yes it does use more CPU cycles, but we have them
    AffectedStops[length(AffectedStops)-1] := Stop.GetStop;
  end;
  Result := AffectedStops;
end;

function BusRoute.GetIntervalsFrom(POS: integer): IntArr;
begin
  Result := IntArr.Create(self.arrRouteStops[POS].GetInterval,
             self.arrRouteStops[POS+1].GetInterval);
end;

function BusRoute.GetInterval(POS: integer): integer;
begin
  Result := self.arrRouteStops[POS].GetInterval();
end;

procedure BusRoute.AddNewStop(Stop: pBusStop; StopPOS: integer;
  Interval: integer);
var
   Compare, arrLen , count: integer;
begin
  SetLength(self.arrRouteStops,length(self.arrRouteStops)+1);
  count := 0;
  arrLen := Length(self.arrRouteStops);
  // THIS WILL NOT WORK WITH NEW OR SHORT ROUTES OR POSITIONS
  //      CLOSE TO THE END OF THE ROUTE.
  //     FIX IT BEFORE YOU HAND IN!!!!!!!!!!!!!!!!!!!!!!!
  compare := length(self.arrRouteStops)-StopPOS+3;
  while count <= Compare do
  begin
    self.arrRouteStops[arrLen-count] :=
     self.arrRouteStops[arrLen-Count-1];
    self.arrRouteStops[arrlen-count].IncPos();
    inc(count);
  end;
  self.arrRouteStops[StopPOS+1] := RouteStop.Create(StopPos+1,Stop,Interval);
end;

function BusRoute.DoesStopRepeat(Stop: pBusStop): boolean;
var
  Each: RouteStop;
  count: Integer;
begin
  count := 0;
  for Each in self.arrRouteStops do
  begin
    if Each.GetStop = Stop then Inc(Count);
    if Count = 2 then Result := True;
  end;
  Result := False;
end;

function BusRoute.IsStopInRoute(Stop: pBusStop): boolean;
var
  each: RouteStop;
begin
  for each in self.arrRouteStops do
  begin
  if each.GetStop = Stop then Result := True;
  end;
end;

procedure BusRoute.ChangeLinkedStop(Stop: pBusStop; StopPOS: integer);
begin
  self.arrRouteStops[StopPOS].ChangeLinked(Stop);
end;

procedure BusRoute.ChangeName(NewName: string);
begin
  self.sName := NewName;
end;

procedure BusRoute.ChangeTimes(StartNew, EndNew: string);
begin
  self.sTimeStart := StartNew;
  self.sTimeEnd := EndNew;
end;

procedure BusRoute.ChangePrice(NewPrice: real);
begin
  self.rPrice := NewPrice;
end;

{ RouteStop }

constructor RouteStop.Create(POS: integer; Stop: pBusStop; TimeInterval: integer
  );
begin
  self.routePOS := POS;
  self.linkedStop := Stop;
  self.iInterval := TimeInterval;
end;
// I have absolutely no clue why this is here, what it
//   is supposed to do or anything else about it.
function RouteStop.isStop(stop:pBusStop): boolean;
begin
  if Self.linkedStop = stop then Result:=True
  else Result := False;
end;

function RouteStop.GetLinkedRoutes: pBusRouteArr;
begin
  Result := Self.linkedStop^.GetRoutes();
end;

function RouteStop.GetStop: pBusStop;
begin
  Result := self.linkedStop;
end;

function RouteStop.GetInterval: integer;
begin
  Result := self.iInterval;
end;

function RouteStop.GetPos: integer;
begin
  Result := self.routePOS;
end;

procedure RouteStop.DecPos;
begin
  self.routePOS := self.routePOS-1;
end;

procedure RouteStop.IncPos;
begin
  Inc(self.routePOS);
end;

procedure RouteStop.ChangeLinked(StopPtr: pBusStop);
begin
  self.linkedStop := StopPtr;
end;

procedure RouteStop.ChangeInterval(interval: integer);
begin
  self.iInterval := interval;
end;

destructor RouteStop.Destroy();
begin
  self.linkedStop := nil;
  inherited;
end;

{ BusStop }

procedure BusStop.FindRoute(FinnalStop: Pointer; CurrentRoute: pTFPHashList;
  Found: pRouteArrayp; Depth: integer);
{var
  Stop, Been : ^BusStop;
  Back: Boolean;
  count: Integer;
  newFound : pArr;}
begin
  // This function is broken but im leaving it here because of sentimental value
  // The Way this works is a bit unconventional, instead of modifying variables
  //     inside of the function and returning their results, this modifys
  //     variables outside of the function and does not return a result directly
  //     but rather creates a result in the first function where that function
  //     can return the results to the rest of the program for further
  //     manipulation. This is neccecary because of the way delphi handles
  //     variables that are passed and declared in functions and procedures and
  //     this justifys the need for this approach that uses lots of pointers.

  // Go through each adjasent node
  {For Stop in aClose do
  begin
    // If the current node is the destination
    if Stop = FinnalStop then
    begin
      // Increase the length of the Current route
      CurrentRoute^.Add(Stop^.GetID,Stop);
      // Append the current stop/ destination to the Current route
      // Increase the length of the list of possible routes
      SetLength(Found^, length(Found^)+1);
      // Copy the current route and append it to the list of possible routes.
      //      This is to make sure that it does not change as we continue
      //      to manipulate the origial.
      for count := 0 to CurrentRoute^.Count-1 do
          begin
            SetLength(newFound, length(newFound)+1);
            newFound[Length(newFound)-1] := CurrentRoute^.Items[Count];
          end;
      Found^[length(Found^)-1] := newFound;
      // Remove and shorten the current route because if we encounter the
      //        stop again it means that we have found another viable route
      //        and if we dont we end up with corrupted and inacurate data.
      CurrentRoute^.Delete(CurrentRoute^.Count-1);
      // Move to the next stop/ goto the start of the loop and cycle to next
      Continue;
    end;

    // I don't like this implimentation but I am forced to use it because delphi
    //   lacks "if x in y" capabilitys. It might have them but im lazy and
    //   couldent be botherd to try and figure it out when Im hopefully never
    //   going to use this terrible, messy, frankenstine of a language.

    // This block checks if the current stop is one that we've been to. If it is
    //      then we ignore it and cycle trough the next item because we don't
    //      want to go in circles because in real life it wastes time and money
    //      and in programing it means that this loop will never end.
    Back := False;
    // Another for loop, this just go's through the list doing what I explained
    //         in the previoce comment. The code is pretty self explanitory.
    try
        if CurrentRoute^.Find(Stop^.GetID) = Stop then Back := True;
    Except
    end;
    if Back = True then Continue;

    // This is where things get spicy. If no conditions are met, it means we
    //      have a node that we have not yet encounterd. This is where
    //      very deep recursion occurs and where you and I both pray
    //      for no stack overflows.

    // Increase the length of the Current route.
    CurrentRoute^.Add(Stop^.GetID,Stop);
    // Use the current stops FindRoute method and parse it the pointers to the
    //     FinnalStop, CurrentRoute, and ViableRoutes. By doing this it can
    //     manipulate the variables without overwriting previoce data and alows
    //     this integral part of the program to function. The try statement just
    //     protects us in the event of a stack overflow, again mostly for
    //     testing and will hopefully never occur as modern OS'es are able
    //     to expand a userspace stack dynamicly as it fills up limiting
    //     recursion depth by memory space and memory fragmentation only. On
    //     linux I have 8MB and although windows is limited to 1MB by default
    //     this should lead to a theoretical recursion depth of arround 600 to
    //     999 which means as long as we have less that +-700 stops we should be

    //     fine. That is based on python too so we might have more space to work
    //     with.
    try
        inc(Depth);
      Stop^.FindRoute(FinnalStop, CurrentRoute, Found, Depth);
    Except
      on E : EStackOverflow do
       writeln('Warning, cannot reach any further stops down this path. ' +
                             'Ref: ' + Stop^.ToString + 'Recalculating!!!');
    end;

    // When it has finnished with the current stop delete it from the Current
    //      route for the same reason as we did when we found our destination.
    CurrentRoute^.Delete(CurrentRoute^.Count-1);
    // Cycle thru to the next node in the adjasent stops, to really understand
    //       what is going on here you need to watch it work in action inside
    //       the debugger so I would highly recommend doing that if you want to
    //       see what is really going in here. The solution works much better in
    //       other languages like python but its mine, I'm proud of it, and
    //       it feels cool writing something as crazy as this. Feel free to use
    //       this.

end;}
end;

function BusStop.GetRoutes(): pBusRouteArr;
begin
  Result := Copy(self.aClose);
end;

function IsCommonRoute(Test1: pBusRouteArr; Test2: pBusRouteArr
  ): pBusRouteArr;
var
  comp1, comp2: pRoute;
  common : pBusRouteArr;
begin
  // Set leng
  setlength(common,0);
  // Check each element
  for comp1 in Test1 do
      begin
        for comp2 in Test2 do
            begin
              // if they are = then add to common
              if comp2 = comp1 then
              begin
                setlength(common,length(common)+1);
                common[length(common)-1] := comp1;
              end;
            end;
      end;
  // return
  Result := common;
end;

function IsCommonRoute(Test1: pBusStop; Test2: pBusStop): StopRouteLink;
begin

end;

procedure RemoveDupes(Modify: pBusRouteArr; var Modifer: pBusRouteArr);
var
  count: Integer;
  found: pRoute;
begin
  for found in Modifer do
  begin
    count := 0;
    while (count <= length(Modify)) and (Length(Modify) > 0) do
    begin
      if found = Modify[length(Modify)-1-count] then
      begin
        Modify[length(Modify)-1-count] := Modify[length(Modify)-1];
        SetLength(Modify,length(Modify)-1);
      end;
      inc(Count);
  end;
  end;
  for found in Modify do
  begin
    SetLength(Modifer,length(Modifer)+1);
    Modifer[length(Modifer)-1] := found;
  end;
end;

procedure RemoveDupes(var arr: pBusRouteArr);
var
  duparr : pBusRouteArr;
  check, dupe: pRoute;
  bDupe: Boolean;
begin
  duparr := arr;
  SetLength(arr,0);
  bDupe := False;
  for check in duparr do
  begin
    for dupe in arr do
    begin
    if check = dupe then
    begin
      bDupe := True;
      break;
    end
    else bDupe := False;
    end;
    if bDupe = False then
    begin
      SetLength(arr, length(arr)+1);
      arr[length(arr)-1] := check;
    end;
  end;
end;

function RemoveDupes(var arr: arrStopRouteLink): arrStopRouteLink;
var
  duparr, newArr: arrStopRouteLink;
  dupe, check: StopRouteLink;
  bDupe: Boolean;
begin
  duparr := arr;
  // Strange issues with memory force me to do this.
  //         I to this day cannot for the life of me
  //         Understand why it segfaults if you use
  //         the orriginal arr variable but what ever.
  SetLength(newArr,0);
  bDupe := False;
  for check in duparr do
  begin
    for dupe in newArr do
    begin
    if (check.Stop = dupe.Stop) and (check.Route = dupe.Route) then
    begin
      bDupe := True;
      break;
    end
    else bDupe := False;
      end;
    if bDupe = False then
    begin
      SetLength(NewArr, length(NewArr)+1);
      SetLength(NewArr,Length(Newarr));
      Newarr[length(Newarr)-1] := check;
    end;
  end;
  Result := newArr;
end;

function FindDupes(Modify: pBusRouteArr; Modifer: pBusRouteArr):pBusRouteArr;
var
  Dupes : pBusRouteArr;
  potentialDupe, found: pRoute;
begin
  SetLength(Dupes,0);
  for found in Modifer do
    begin
      for potentialDupe in Modify do
        begin
          if found = potentialDupe then
          begin
            SetLength(Dupes,length(Dupes)+1);
            Dupes[length(Dupes)-1] := found;
            break;
          end;
        end;
    end;
  Result := Dupes;
end;

function FindIntersections(Test1: arrStopRouteLink; Test2: arrStopRouteLink
  ): RouteIntesecArr;
var
  Intersect2, Intersect1: StopRouteLink;
  ResArray : RouteIntesecArr;
  Count: Integer;
begin
  SetLength(ResArray,0);
  Count := 0;
  for Intersect1 in Test1 do
    begin
      for Intersect2 in Test2 do
        begin
          if Intersect1.Route = Intersect2.Route then
          begin
            inc(Count);
            SetLength(ResArray,count,2);
            ResArray[count-1,0] := Intersect1;
            ResArray[count-1,1] := Intersect2;
            break;
          end;
        end;
    end;
  Result := ResArray;
end;

// If you can't figure this one out...
function BusStop.GetID: string;
begin
  Result := sID;
end;

function BusStop.GetName: string;
begin
  Result := self.sLocation;
end;

function BusStop.GetLinkedRoutes: string;
var
  Route: pBusRoute;
  line : string;
begin
  line := '';
  for Route in self.aClose do
    line := line + Route^.GetID + ',';
  SetLength(line, length(line)-1);
  Result := line;
end;

function BusStop.GetLinkedRoutes(Pointers: Boolean): pBusRouteArr;
begin
  Result := self.aClose;
end;

procedure BusStop.RemoveLinked(Route: pRoute);
var
  count : integer;
begin
  count := 0;
  while count < length(self.aClose)-1 do
  begin
    if (self.aClose[count] = Route) then
    begin
      self.aClose[count] := self.aClose[length(Self.aClose)-1];
      setlength(Self.aClose, length(self.aClose)-1);
    end;
  end;
end;

destructor BusStop.Destroy();
begin
  setLength(self.aClose,0);
  inherited;
end;

constructor BusStop.Create(Name: String; ID: String; Location: String);
begin
  try
    // Initialize variables
    sName := Name;
    sID := ID;
    sLocation := Location;
    Except
      // Used for debug purposes
      on E : Exception do
         writeln(E.ClassName+ ': Error raised, stop will not be created');
    end;
  end;

procedure BusStop.AddClose(Stop: pBusRoute);
begin
  // Add new block
  SetLength(aClose, Length(aClose) + 1);
  // Populate block
  aClose[length(aClose)-1] := Stop;
end;

procedure BusStop.AddClose(Stops: array of pointer);
var
  Stop: pBusRoute;
begin
  // Overloaded version of the AddClose thing. I am probably going to do away
  //            with the old one and only use this one as its more generic
  //            to use a array compared to checking if there is one adjasent
  //            stop or many. With a array it will work either way.
  // LOl these are routes now and not stops
  for Stop in Stops do
  begin
    SetLength(aClose, Length(aClose) + 1);
    aClose[Length(aClose)-1] := Stop;
  end;
end;

function BusStop.FindRouteInit(FinnalStop: pBusStop; StartStop: pBusStop
  ): RouteIntesecArr;
var
  CommonRoutes: pBusRouteArr;
  EndRoutes, StartRoutes, AllLinkedStart, AllLinkedEnd, Path: pBusRouteArr;
  StartRoute, EndRoute, EveryCommonRoute: pRoute;
  StartConnect, EndConnect, each: arrStopRouteLink;
  InterSections, FullRoute: RouteIntesecArr;
  FirstOfFinnal, LastOfFinnal : StopRouteLink;
  count, FinnalCount: Integer;
  Startptr: pBusStop;
begin
  // Get connected Routes for both stops and see if there are common routes
  count := 0;
  FinnalCount := 0;
  Startptr := @self;
  StartRoutes := self.GetRoutes();
  EndRoutes := FinnalStop^.GetRoutes();
  CommonRoutes := IsCommonRoute(StartRoutes, EndRoutes);
  // If direct route then go at it. else
  if Length(CommonRoutes) < 1 then
  begin
    for StartRoute in StartRoutes do
    begin
      // Iterate and look for common routes that intersect the other routes
      AllLinkedStart := StartRoute^.GetAllLinkedRoutes;
      for EndRoute in EndRoutes do
      begin
        AllLinkedEnd := EndRoute^.GetAllLinkedRoutes;
        Path := IsCommonRoute(AllLinkedStart,AllLinkedEnd);
        // IF there are common routes then we have a valid route
        if length(Path) > 0 then
        begin
          RemoveDupes(Path);
          StartConnect := StartRoute^.FindStopOnRoute(Path);
          EndConnect := EndRoute^.FindStopOnRoute(Path);
          InterSections := FindIntersections(StartConnect,EndConnect);
          // for debuging purposes
          for each in InterSections do
          begin
            writeln(each[0].Stop^.GetName + ': ' + each[1].Route^.GetHID + #9 +
                                          each[1].Stop^.GetName + ': ' +
                                          each[1].Route^.GetHID);
            Inc(count);
          end;
          writeln(#13 + '________________________________' + #13);
          // Make full route
          for each in InterSections do
          begin
            FirstOfFinnal.Stop := StartStop;
            LastOfFinnal.Stop := FinnalStop;
            FirstOfFinnal.Route := StartRoute;
            LastOfFinnal.Route := EndRoute;
            SetLength(FullRoute,FinnalCount+1,4);
            FullRoute[FinnalCount,0] := FirstOfFinnal;
            FullRoute[FinnalCount,1] := each[0];
            FullRoute[FinnalCount,2] := each[1];
            FullRoute[FinnalCount,3] := LastOfFinnal;
            inc(FinnalCount);
		  end;
		end;
      end;
    end;
  end
  else
  begin
    for EveryCommonRoute in CommonRoutes do
    begin
    SetLength(FullRoute,FinnalCount+1,2);
    FirstOfFinnal.Stop := StartStop;
    LastOfFinnal.Stop := FinnalStop;
    FirstOfFinnal.Route := EveryCommonRoute;
    LastOfFinnal.Route := EveryCommonRoute;
    FullRoute[FinnalCount,0] := FirstOfFinnal;
    FullRoute[FinnalCount,1] := LastOfFinnal;
    Inc(FinnalCount);
    end;
  end;
  WriteLn(IntToStr(Count));
  Result := FullRoute;
end;

function BusStop.ToString: ansistring;
begin
  // This is selfexplanitory, mostly used for testing purposes
  Result:=sName + #9 + sID + #9 + sLocation;
end;

end.


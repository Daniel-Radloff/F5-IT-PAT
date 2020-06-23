unit Custom_Classes;

{$mode objfpc}{$H+}

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
    aClose : array of Pointer;
    // This is the real findRoute function, you will see why it is declared here
    //      in the comments before FindRouteInit's def.
    procedure FindRoute(FinnalStop:Pointer;
      CurrentRoute: pTFPHashList; Found: pRouteArrayp; Depth: integer);

    { Private End }

  Public
    // Creates the Object and is part of the first stage of program
    //         initialization
    Constructor Create(Name:String;ID:String;Location:String);
    // Is Used in second stage of Initialization and is used to populate
    //    The aClose variable of all the BusStops
    Procedure AddClose(Stop:pBusStop);
    procedure AddClose(Stops: Array of pointer); overload;
    // Is Used in the Route finder Routine and starts the function which
    //    finds all posibble routes from the Stop it is run from to the stop
    //    specifyed. This is neccicary because of a limitation of delphi and
    //    this was the only way around it that I could think of.
    Function FindRouteInit(FinnalStop:Pointer) : pRouteArray;
    function ToString: ansistring; override;
    function GetID: string;
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
    routePOS : integer;

  Private
    {%H-}constructor Create(pToArrStops: pStopArray; info : initInfoRouteStop);
    function isStop(stop: pBusStop): boolean;


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

    public
      constructor Create(Name: String; timeStart: String; timeEnd: String;
        ID: String; price: real; MasterStopList: pStopArray);

  end;

implementation

{ BusRoute }

constructor BusRoute.Create(Name: String; timeStart: String; timeEnd: String;
  ID: String; price: real;MasterStopList: pStopArray);
var
  Stop: initInfoRouteStop;
  StopInfos: array of initInfoRouteStop;
begin
  self.sName := Name;
  self.sTimeStart := timeStart;
  self.sTimeEnd := timeEnd;
  self.sID := ID;
  self.rPrice := price;
  // Data base code place holder2
  // Connect to data base and get info on route stops for this route.
  //         Place that into a array of initInfoRouteStop's and
  for Stop in StopInfos do
  begin
    SetLength(self.arrRouteStops, length(self.arrRouteStops) + 1);
    self.arrRouteStops[Length(self.arrRouteStops)-1] := RouteStop.Create(
                                                     MasterStopList,Stop);
  end;


end;

{ RouteStop }

constructor RouteStop.Create(pToArrStops: pStopArray; info: initInfoRouteStop);
var
  stop : BusStop;
begin
  iInterval := info.interval;
  for stop in pToArrStops^ do
     if stop.GetID = info.ID then break;
  Self.linkedStop := @stop;
  Self.routePOS := info.pos;
end;

function RouteStop.isStop(stop:pBusStop): boolean;
begin
  if Self.linkedStop = stop then Result:=True
  else Result := False;
end;

{ BusStop }

procedure BusStop.FindRoute(FinnalStop: Pointer; CurrentRoute: pTFPHashList;
  Found: pRouteArrayp; Depth: integer);
var
  Stop, Been : ^BusStop;
  Back: Boolean;
  count: Integer;
  newFound : pArr;
begin
  // The Way this works is a bit unconventional, instead of modifying variables
  //     inside of the function and returning their results, this modifys
  //     variables outside of the function and does not return a result directly
  //     but rather creates a result in the first function where that function
  //     can return the results to the rest of the program for further
  //     manipulation. This is neccecary because of the way delphi handles
  //     variables that are passed and declared in functions and procedures and
  //     this justifys the need for this approach that uses lots of pointers.

  // Go through each adjasent node
  For Stop in aClose do
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

end;
end;

// If you can't figure this one out...
function BusStop.GetID: string;
begin
  Result := sID;
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

procedure BusStop.AddClose(Stop: pBusStop);
begin
  // Add new block
  SetLength(aClose, Length(aClose) + 1);
  // Populate block
  aClose[length(aClose)-1] := Stop;
end;

procedure BusStop.AddClose(Stops: array of pointer);
var
  Stop: pBusStop;
begin
  // Overloaded version of the AddClose thing. I am probably going to do away
  //            with the old one and only use this one as its more generic
  //            to use a array compared to checking if there is one adjasent
  //            stop or many. With a array it will work either way.
  for Stop in Stops do
  begin
    SetLength(aClose, Length(aClose) + 1);
    aClose[Length(aClose)-1] := Stop;
  end;
end;

function BusStop.FindRouteInit(FinnalStop: Pointer): pRouteArray;
var
  // Used to Check that we are not going where we were.
  Backwards : TFPHashList;
  // A list of possible routes that is manipuated in the other function.
  Found : pRouteArray;
begin
  Backwards := TFPHashList.Create();
  Backwards.Capacity := 5000;
  //  Backwards and Found are refrenced for future modification.
  FindRoute(FinnalStop, @Backwards, @Found,1);
  //  No need to derefrence as this is orriginal variable
  Result := Found;
end;

function BusStop.ToString: ansistring;
begin
  // This is selfexplanitory, mostly used for testing purposes
  Result:=sName + #9 + sID + #9 + sLocation;
end;

end.


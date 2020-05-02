unit Custom_Classes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Dialogs;

type
  // All these types have to be defined because if they arn't the compliler
  //      has a fit and throws about 237 errors 🙁
  pRouteArray = array of array of Pointer;
  pRouteArrayp = ^pRouteArray;
  pArr = array of pointer;
  pArrp = ^pArr;

  { BusStop }

  BusStop = Class


  Private
    sName : string;
    sID : string;
    sLocation : string;
    aClose : array of Pointer;
    // This is the real findRoute function, you will see why it is declared here
    //      in the comments before FindRouteInit's def.
    procedure FindRoute(FinnalStop:Pointer;
      CurrentRoute: parrp; Found: pRouteArrayp);

    { Private End }

  Public
    // Creates the Object and is part of the first stage of program
    //         initialization
    Constructor Create(Name:String;ID:String;Location:String);
    // Is Used in second stage of Initialization and is used to populate
    //    The aClose variable of all the BusStops
    Procedure AddClose(Stop:Pointer);
    // Is Used in the Route finder Routine and starts the function which
    //    finds all posibble routes from the Stop it is run from to the stop
    //    specifyed. This is neccicary because of a limitation of delphi and
    //    this was the only way around it that I could think of.
    Function FindRouteInit(FinnalStop:Pointer) : pRouteArray;

    { Public End }

  end;


implementation

{ BusStop }

procedure BusStop.FindRoute(FinnalStop: Pointer; CurrentRoute:pArrp;
  Found: pRouteArrayp);
var
  Stop, Been : ^BusStop;
  Back: Boolean;
  Test: BusStop;
begin
  // The Way this works is a bit unconventional, instead of modifying variables
  //     inside of the function and returning their results, this modifys
  //     variables outside of the function and does not return a result directly
  //     but rather creates a result in memory where the first function called
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
      SetLength(CurrentRoute^ , length(CurrentRoute^)+1);
      // Append the current stop/ destination to the Current route
      CurrentRoute^[length(CurrentRoute^)-1] := Stop;
      // Increase the length of the list of possible routes
      SetLength(Found^, length(Found^)+1);
      // Copy the current route and append it to the list of possible routes.
      //      This is to make sure that it does not change as we continue
      //      to manipulate the origial.
      Found^[length(Found^)-1] := COPY(CurrentRoute^);
      // Remove and shorten the current route because if we encounter the
      //        stop again it means that we have found another viable route
      //        and if we dont we end up with corrupted and inacurate data.
      SetLength(CurrentRoute^, length(CurrentRoute^)-1);
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
    for Been in CurrentRoute^ do
    begin
      if been = Stop then Back := True;
    end;
    if Back = True then Continue;

    // This is where things get spicy. If no conditions are met, it means we
    //      have a node that we have not yet encounterd. This is where
    //      very deep recursion occurs and where you and I both pray
    //      for no stack overflows.

    // Increase the length of the Current route.
    SetLength(CurrentRoute^, length(CurrentRoute^)+1);
    // Appent the current new node to the Current Route;
    CurrentRoute^[length(CurrentRoute^)-1] := Stop;
    // Use the current stops FindRoute method and parse it the pointers to the
    //     FinnalStop, CurrentRoute, and ViableRoutes. By doing this it can
    //     manipulate the variables without overwriting previoce data and alows
    //     this integral part of the program to function.
    Stop^.FindRoute(FinnalStop, CurrentRoute, Found);
    // When it has finnished with the current stop delete it from the Current
    //      route for the same reason as we did when we found our destination.
    SetLength(CurrentRoute^, length(CurrentRoute^)-1);
    // Cycle thru to the next node in the adjasent stops, to really understand
    //       what is going on here you need to watch it work in action inside
    //       the debugger so I would highly recommend doing that if you want to
    //       see what is really going in here. The solution works much better in
    //       other languages like python but its mine, I'm proud of it, and
    //       it feels cool writing something as crazy as this. Feel free to use
    //       this.

end;
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
         ShowMessage(E.ClassName+ ': Error raised, stop will not be created');
    end;
  end;



procedure BusStop.AddClose(Stop: Pointer);
begin
  // Add new block
  SetLength(aClose, Length(aClose) + 1);
  // Populate block
  aClose[length(aClose)-1] := Stop;
end;

function BusStop.FindRouteInit(FinnalStop: Pointer): pRouteArray;
var
  // Used to Check that we are not going where we were.
  Backwards : pArr;
  // A list of possible routes that is manipuated in the other function.
  Found : pRouteArray;
begin
  //  Backwards and Found are refrenced for future modification.
  FindRoute(FinnalStop, @Backwards, @Found);
  //  No need to derefrence as this is orriginal variable
  Result := Found;
end;

end.


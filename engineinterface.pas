unit EngineInterface;
// Daniel Radloff

{$mode objfpc}{$H+}

interface
// Compiler does not like creating a engine in the unit in which it is defined
//          for this reason I have this unit. It contains the Engine
//          It also avoids some confusion with a few of the functions defined
//          in the Engine Unit

uses Engine, SysUtils;

type
  pAppEngine = ^APEngine;

function Engine(): integer;
function convTimeToStr(Time: integer): string;
//       Restarts AppEngine in place
procedure RestartEngine();

var
  MainEngine: APEngine;

implementation
// Ok so this is really, REALLY weird.
//    Basicly the delphi application template has a higherarche of
//    initialation that pervents objects from being created before
//    one of the forms have activated themselfves. This means that
//    the object cannot be initialized at run time or at least after
//    5 days of trying I was not able to do so. I suspect it has something
//    to do with the object handling the database but I don't know because
//    during testing it would do very strange things like skip the create
//    function entirely even though it was called and then even though it
//    could be instanciated during the main forms OnActivate method with no
//    database issues or seg faults, it would segfault for absolutely no reason
//    while the function was exiting. This is the only work around that I could
//    come up with. Call this function every time a button is clicked so we can
//    get a pointer to the object to make calls and use it and so that we can
//    create it after the form is Activated.
//    Yes it is horrific, I should not have to do this, I don't know why I have
//    to do this, and I don't want to do this but it seems to be the only way
//    to get the thing to work.
function Engine(): integer;
begin
  if MainEngine = nil then
    MainEngine := APEngine.Create();
  Result := 1;
end;

function convTimeToStr(Time: integer): string;
var
  Minutes, Hours: string;
begin
  Minutes := IntToStr(Time mod 60);
  Hours := IntToStr(Time div 60);
  if Length(Hours) < 2 then
    Hours := '0' + Hours;
  if Length(Minutes) < 2 then
    Minutes := '0' + Minutes;
  Result := Hours + ':' + Minutes;
end;

procedure RestartEngine();
begin
  MainEngine.ReStart();
end;

initialization

finalization
  FreeAndNil(MainEngine);
end.

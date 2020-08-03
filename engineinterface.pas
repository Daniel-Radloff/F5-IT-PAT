unit EngineInterface;

{$mode objfpc}{$H+}

interface

uses Engine;
type
  pAppEngine = ^APEngine;
function Engine():pAppEngine;
var MainEngine: APEngine;

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
//    to get the fucking thing to work.
function Engine(): pAppEngine;
begin
  if MainEngine = nil then MainEngine := APEngine.Create();
  Result := @MainEngine;
end;

initialization

finalization
 MainEngine.Destroy;
end.

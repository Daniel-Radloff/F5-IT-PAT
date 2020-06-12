unit TestCase1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry, Engine, Custom_Classes;

type

  TTestCase1= class(TTestCase)
  published
    procedure TestHookUp;
  end;

implementation

procedure TTestCase1.TestHookUp;
var
  x: pRouteArray;
begin
  Engine.Init();
  x := Engine.MainEngine.FindRoutes('2b32bf', 'e82700');
end;



initialization

  RegisterTest(TTestCase1);
end.


unit TestingUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry, Custom_Classes;

type

  TTestCase1= class(TTestCase)
  published
    procedure TestHookUp;
  end;

implementation

procedure TTestCase1.TestHookUp;
var
  x, y, z: BusStop;
begin
  Fail('Write your own test');
  With Custom_Classes.BusStop do
       begin
         x := BusStop.Create('test 1', '000000', 'Virtual 1');
         y := BusStop.Create('test 2', '000001', 'Virtual 2');
         z := BusStop.Create('test 3', '000002', 'Virtual 3');
         x.AddClose(@y);
         y.AddClose(@x);
         y.AddClose(@z);
         z.AddClose(@y);
       end;

end;



initialization

  RegisterTest(TTestCase1);
end.


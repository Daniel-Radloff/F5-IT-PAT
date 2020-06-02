////////////////////////////////////////////////////////////////////////////////
//                          Warning!!!!!!!!!!!!!!!!!!!                        //
//                                                                            //
//     None of the code in this unit is part of the PAT and is used           //
//     PURELY for testing purposes. Please do NOT mark any of this.           //
//     View the contents of this file for curiositys sake and for             //
//     no other reason.                                                       //
//                                                                            //
//                     DO NOT MARK THIS FILE !!!!!!!!!!!!!!                   //
//                                                                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

unit test;

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
// All this is for stress testing and bug catching. Therefore not for your eyes.
//     You can look at this but none of this should count for marks.
procedure TTestCase1.TestHookUp;
var
  o, n, m, l, k, j, h, g, f, e, d, c, b, a: BusStop;
  resraw: pRouteArray;
  Viable: ^BusStop;
  counta: Integer;
  x : pArr;
begin
  with Custom_Classes.BusStop do
  begin
    a := BusStop.Create('A', '0', '1');
    b := BusStop.Create('B','1','2');
    c := BusStop.Create('C','2','3');
    d := BusStop.Create('D', '3', '4');
    e := BusStop.Create('E', '4', '5');
    f := BusStop.Create('F', '5', '6');
    g := BusStop.Create('G', '6', '7');
    h := BusStop.Create('H' , '7', '8');
    j := BusStop.Create('J', '8', '9');
    k := BusStop.Create('K', '9', '10');
    l := BusStop.Create('L', '10', '11');
    m := BusStop.Create('M', '11', '12');
    n := BusStop.Create('N', '12', '13');
    o := BusStop.Create('O', '13', '14');

    a.AddClose([@b, @c]);
    b.AddClose([@a]);
    c.AddClose([@a, @d, @e]);
    d.AddClose([@c, @g, @f]);
    e.AddClose([@c, @h]);
    f.AddClose([@d, @g, @j]);
    g.AddClose([@d, @f, @j]);
    h.AddClose([@e, @k]);
    j.AddClose([@f, @g, @l]);
    k.AddClose([@h, @l]);
    l.AddClose([@j, @k, @m]);
    m.AddClose([@l, @n, @o]);
    n.AddClose([@m]);
    o.AddClose([@m]);

    resraw := a.FindRouteInit(@o);
    counta := 0;
    for x in resraw do
    begin
      inc(counta);
      WriteLn('Route' + IntToStr(counta));
      for viable in x do
      begin
        WriteLn(viable^.ToString);
      end;
    end;

  end;
end;



initialization

  RegisterTest(TTestCase1);
end.


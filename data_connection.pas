unit Data_Connection;
// Daniel Radloff

{$mode objfpc}{$H+}
// Database unit. I have a lot of hatered directed towards this unit
interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, DB, Custom_Classes;

type

  { TDataBase }

  TDataBase = class(TDataModule)
    DataSource1: TDataSource;
    SQLite3Connection1: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
  private

  public
    // Get all stops and sort them
    procedure GetAllStops();
    // Get all Routes and sort them
    function GetAllRoutes(): int16;
    // Get all RouteStops which are linked to a
    //     specifyed route, order by to save our
    //     sanity and little proccesing power
    //     we have left
    function GetRouteStops(route: BusRoute): int16;
    function StopCount(): integer;
  end;

var
  DataBase: TDataBase;

implementation

{$R *.lfm}

{ TDataBase }

procedure TDataBase.DataModuleCreate(Sender: TObject);
begin
  SQLite3Connection1.DatabaseName := 'PAT_5';
end;

procedure TDataBase.GetAllStops();
begin
  // Order by so the query is sorted for when we read it into arrays so
  //       The data is preped for a binary search.
  SQLQuery1.Close;
  SQLQuery1.SQL.Text := 'Select * from BusStopTBL order by BusStopID';
  SQLQuery1.Open;
end;

function TDataBase.GetAllRoutes(): int16;
begin
  // Order by so the query is sorted for when we read it into arrays so
  //       The data is preped for a binary search.
  SQLQuery1.Close;
  SQLQuery1.SQL.Text := 'SELECT * from RoutesTBL ORDER BY RouteID';
  SQLQuery1.Open;
end;

function TDataBase.GetRouteStops(route: BusRoute): int16;
begin
  // Order them so we don't need to jump around
  SQLQuery1.Close;
  SQLQuery1.SQL.Text := 'SELECT * from RouteStopsTBL WHERE RouteID = ' +
    QuotedStr(route.GetID) + ' ORDER BY RoutePosition';
  SQLQuery1.Open;
end;

function TDataBase.StopCount(): integer;
begin
  SQLQuery1.Close;
  SQLQuery1.SQL.Text := 'select COUNT(*) FROM BusStopTbl';
  SQLQuery1.Open;
  Result := SQLQuery1.Fields[0].AsInteger;
end;

end.


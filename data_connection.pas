unit Data_Connection;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, db;

type

  { TDataBase }

  TDataBase = class(TDataModule)
    Source: TDataSource;
    SQLite3Connection: TSQLite3Connection;
    SQLQuery: TSQLQuery;
    SQLTransaction: TSQLTransaction;
  private

  public
    function GetAllStops():int16;
  end;

var
  DataBase: TDataBase;

implementation

{$R *.lfm}

{ TDataBase }

function TDataBase.GetAllStops(): int16;
begin
  SQLQuery.SQL.Text := 'Select * from BusStopTBL';
  SQLQuery.Open;
end;

end.


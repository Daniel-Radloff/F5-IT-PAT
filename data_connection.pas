unit Data_Connection;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, db;

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
    function GetAllStops():int16;
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

function TDataBase.GetAllStops(): int16;
begin
  // Order by so the query is sorted for when we read it into arrays so
  //       The data is preped for a binary search.
  SQLQuery1.SQL.Text := 'Select * from BusStopTBL order by BusStopID';
  SQLQuery1.Open;
end;

end.


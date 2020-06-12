program fpcunitproject1;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, TestCase1, Data_Connection;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDataBase, DataBase);
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.


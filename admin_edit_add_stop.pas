unit Admin_edit_add_stop;
// Daniel RAdloff2
// Might be changed
//       ---> was changed, This is now a view of the city map

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TForm5 }

  TForm5 = class(TForm)
    btnClose: TButton;
    Image1: TImage;
    procedure btnCloseClick(Sender: TObject);
  private

  public

  end;

var
  Form5: TForm5;

implementation

{$R *.lfm}

{ TForm5 }

procedure TForm5.btnCloseClick(Sender: TObject);
begin
  Form5.Close;
end;

end.


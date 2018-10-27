unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Image1: TImage;
    procedure FormPaint(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

const
  IMAGE_FILE = 'woodbox.png';

implementation

{$R *.lfm}

{ TForm1 }
procedure TForm1.FormPaint(Sender: TObject);
begin
  Image1.Picture.LoadFromFile(IMAGE_FILE);
end;


end.


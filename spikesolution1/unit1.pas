unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, Forms, Controls, Graphics,
  Dialogs, TADrawUtils, TACustomSeries, TAFuncSeries, strutils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Chart1: TChart;
    Chart1LineSeries1: TLineSeries;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

const
  DEFAULT_VAL_FILE = 'default.txt';

var
  Form1: TForm1;
  tfIn: TextFile;
  s: String;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin

  ShowMessage('Importing defualt values from file: ' + DEFAULT_VAL_FILE);
  AssignFile(tfIn, DEFAULT_VAL_FILE);

  try
    // Open the file for reading
    Reset(tfIn);

    // Keep reading lines until the end of the file is reached
    while not EOF(tfIn) do
    begin
      ReadLn(tfIn, s);
      //http://lists.lazarus.freepascal.org/pipermail/lazarus/2015-September/158952.html
      Chart1LineSeries1.AddXY(StrToFloat(ExtractWord(1,s,[','])),
                              StrToFloat(ExtractWord(2,s,[','])));
    end;
    CloseFile(tfIn);
  except
    on E: EInOutError do
     writeln('File handling error occurred. Details: ', E.Message);
  end;
end;

end.


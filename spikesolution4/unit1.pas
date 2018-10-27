unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, strutils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    OpenDialog1: TOpenDialog;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
  private

  public

  end;

  { Coord }
  Coord = class
    x: Double;
    y: Double;
    z: Double;
  end;

var
  Form1: TForm1;
  pr_path: String;
  tfIn: TextFile;
  tfOut: TextFile;
  s: String;
  coords: array [0..1] of Coord;
  i: Integer;
  c: Coord;
  pov: String;

const
  //Only look for v3.7 :P
  PR_WIN64_PATH = 'C:\Program Files\POV-Ray\v3.7\bin\pvengine64.exe';
  PR_WIN32_PATH = 'C:\Program Files\POV-Ray\v3.7\bin\pvengine.exe';
  PR_UNIX_PATH = '/usr/bin/povray';
  DEFAULT_VAL_FILE = 'default.txt';
  POV_FILE = 'box.pov';

implementation
{$IFDEF WINDOWS}
uses
  ShellApi;
{$ENDIF}
{$IFDEF UNIX}
uses
  Unix;
var
  status: Longint;
{$ENDIF}

{$R *.lfm}

Function createPovText(cs: array of Coord) : String;
begin
  pov:='#include "colors.inc"background { color Cyan}camera {location <0.5, ' +
       '-3, 3>look_at <0.5, 0.5, 0.5>}box{';
  for c in cs do
  begin
    pov:=pov+'<'+FloatToStr(c.x)+','+
                 FloatToStr(c.y)+','+
                 FloatToStr(c.z)+'>';
  end;
  pov:=pov+'texture {pigment { color Yellow}}}light_source { <-10,-10,10> co' +
           'lor White}light_source { <10,-10,10> color White}light_source { ' +
           '<0.5,5,0> color White}';
  Exit(pov);
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  AssignFile(tfOut, POV_FILE);
  ShowMessage('Importing defualt values from file: ' + DEFAULT_VAL_FILE);
  AssignFile(tfIn, DEFAULT_VAL_FILE);

  try
    // Open the file for reading
    Reset(tfIn);

    // Keep reading lines until the end of the file is reached
    i:=0;
    while not EOF(tfIn) do
    begin
      ReadLn(tfIn, s);
      coords[i]:=Coord.Create;
      coords[i].x:=StrToFloat(ExtractWord(1,s,[',']));
      coords[i].y:=StrToFloat(ExtractWord(2,s,[',']));
      coords[i].z:=StrToFloat(ExtractWord(3,s,[',']));
      Inc(i);
    end;
    CloseFile(tfIn);
  except
    on E: EInOutError do
     ShowMessage('File handling error occurred. Details: '+ E.Message);
  end;

  TrackBar1.Position:=round(coords[1].y);
  TrackBar2.Position:=round(coords[0].y);

  {$IFDEF WINDOWS}
  Label1.Caption := 'Locate pvengine.exe or pvengine64.exe';
  {$IFDEF WIN64}
  if FileExists(PR_WIN64_PATH) then
  begin
       Edit1.Caption:=PR_WIN64_PATH;
  end
  else if FileExists(PR_WIN32_PATH) then
  begin
       Edit1.Caption:=PR_WIN32_PATH;
  end;
  {$ENDIF}
  {$IFDEF WIN32}
  if FileExists(PR_WIN32_PATH) then
  begin
       Edit1.Caption:=PR_WIN32_PATH;
  end;
  {$ENDIF}

  {$ENDIF}
  {$IFDEF UNIX}
  if FileExists(PR_UNIX_PATH) then
  begin
       Edit1.Caption:=PR_UNIX_PATH;
  end;
  {$ENDIF}

end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  coords[1].y:=TrackBar1.Position;
end;

procedure TForm1.TrackBar2Change(Sender: TObject);
begin
  coords[0].y:=TrackBar2.Position;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    Edit1.Caption:=OpenDialog1.Filename;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  pr_path:=Edit1.Caption;
  //Test box.pov, this will export box.png
  try
    rewrite(tfOut);
    WriteLn(tfOut, createPovText(coords));
    CloseFile(tfout);
  except
    // If there was an error the reason can be found here
    on E: EInOutError do
      ShowMessage('File handling error occurred. Details: ' + E.ClassName + '/'
      + E.Message);
  end;
  {$IFDEF WINDOWS}
  if ShellExecute(0,nil, PCHAR('"'+pr_path+'"'), PCHAR('box.pov /EXIT'),
                  nil,1)>32 then
  {$ENDIF}
  {$IFDEF UNIX}
  //Not tested
  status:=fpSystem(pr_path+' box.pov');
  if status = 0 then
  begin
    ShowMessage('Success');
  end
  else
    ShowMessage('Command exited with status code: ' + IntToStr(status));
  {$ENDIF}
end;

end.


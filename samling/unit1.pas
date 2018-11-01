unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Unit2;

type

  { TForm1 }

  TForm1 = class(TForm)
    TForm2: Unit2.TForm2;
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    OpenDialog1: TOpenDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  pr_path: String;

const
  //Only look for v3.7 :P
  PR_WIN64_PATH = 'C:\Program Files\POV-Ray\v3.7\bin\pvengine64.exe';
  PR_WIN32_PATH = 'C:\Program Files\POV-Ray\v3.7\bin\pvengine.exe';
  PR_UNIX_PATH = '/usr/bin/povray';

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
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
  Application.CreateForm(Unit2.TForm2, Form2);
  povray_path:=pr_path;
  Form2.Show();
  Form1.Hide();
end;

end.


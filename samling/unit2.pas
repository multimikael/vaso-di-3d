unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, TAFuncSeries, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ComCtrls, ExtCtrls, Math, TACustomSeries, Crt;

type
  MathFunction = function(x: Double) : Double;
  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Chart1: TChart;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ProgressBar1: TProgressBar;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;
    TrackBar4: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure TrackBar4Change(Sender: TObject);
  private

  public

  end;

var
  Form2: TForm2;
  povray_path: String;
  pov: String;
  tfOut: TextFile;
  interval_start: Double = 2;
  object_end: Double = 0.1;
  interval_size: Double = 0.05;
  x_factor: Double = 1;
  ParentForm: TForm;

const
  POV_FILE = 'figure.pov';
  IMG_FILE = 'figure.png';
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

function createPovText(i_start, obj_end, step, xfactor : Double) : String;
begin
  pov:='#include "colors.inc"';
  pov:=pov+'#declare step = '+FloatToStr(step)+';';
  pov:=pov+'#declare xfactor = '+FloatToStr(xfactor)+';';
  pov:=pov+'#declare interval_start = 0;';
  pov:=pov+'#declare interval_end = '+FloatToStr(i_start)+';';
  pov:=pov+'#declare obj_end = '+FloatToStr(obj_end)+';';
  pov:=pov+'#declare diff = interval_end-interval_start;#declare k_interval = '+
  'diff-1.4;#declare f = function(x) {(2.2*pow(x, 2)-2.66*x+5.1)*xfactor}#decl'+
  'are g = function(x) {(-3.5714*x+6.3)*xfactor}#declare h = function(x) {(3.7'+
  '*pow(x,-0.078))*xfactor}#declare i = function(x) {(1.5*x+1.5)*xfactor}#decl'+
  'are j = function(x) {4.2*xfactor}#declare k = function(x) {(-2*x+9)*xfactor'+
  '}#declare l = function(x) {(3*x-5)*xfactor}#declare m = function(x) {(0.123'+
  '86*pow(x, 2)-1.2641*x+4.52)*xfactor}#declare n = function(x) {(1.3+sqrt(pow'+
  '(0.95,2)-pow((x-6.25),2)))*xfactor}#declare o = function(x) {(sqrt(x-7.2)*1'+
  '.9+1.3)*xfactor}#declare p = function(x) {(-4*pow(2, -3/4*(x-8.058))+5.862)'+
  '*xfactor}  #macro cylindersInInterval(i_start, i_end, func)#for (index, i_s'+
  'tart, i_end-step, step)cylinder{<index, 0, 0>,<index+step, 0, 0>,func(index'+
  ')texture { pigment{Gold} }}#end#end  background{Grey}light_source {<6.5, -1'+
  '7, 0>, White}camera{location <6.5, -17, 0>look_at<6.5, 10, 0>}#for (index, '+
  '0, 0.56-step, step)cylinder {<index-k_interval, 0, 0>,<index+step-k_interva'+
  'l, 0, 0>,f(index)texture { pigment{Gold} }}  #end#for (index, 0.56, 0.7-ste'+
  'p, step)cylinder {<index-k_interval, 0, 0>,<index+step-k_interval, 0, 0>,g('+
  'index)texture { pigment{Gold} }}  #end#for (index, 0.7, 1.4-step, step)cyli'+
  'nder {<index-k_interval, 0, 0>,<index+step-k_interval, 0, 0>,h(index)textur'+
  'e { pigment{Gold} }}  #end#for (index, 1.4, 1.8-step, step)cylinder {<index'+
  '-k_interval, 0, 0>,<index+step, 0, 0>,i(index)texture { pigment{Gold} }}#en'+
  'd cylindersInInterval(1.8,2.4, j)#for (index, 2.4, 2.8-step, step)differenc'+
  'e{cylinder {<index, 0, 0>,<index+step, 0, 0>,k(index)texture { pigment{Gold'+
  '}}}cylinder {<index-0.0001*step, 0, 0>,<index+1.0001*step, 0, 0>,l(index)te'+
  'xture { pigment{Gold} }}}#end cylindersInInterval(2.4,5.3, m)cylindersInInt'+
  'erval(5.3,7.2, n)cylindersInInterval(7.2,10.8, o)cylindersInInterval(10.8,o'+
  'bj_end, p)';
  Exit(pov);
end;

function f(x: Double) : Double;
begin
  Exit((2.2*power(x, 2)-2.66*x+5.1)*x_factor);
end;

function g(x: Double) : Double;
begin
  Exit((-3.5714*x+6.3)*x_factor);
end;

function h(x: Double) : Double;
begin
  Exit((3.7*power(x,-0.078))*x_factor);
end;

function i(x: Double) : Double;
begin
  Exit((1.5*x+1.5)*x_factor);
end;

function j(x: Double) : Double;
begin
  Exit(4.2*x_factor);
end;

function k(x: Double) : Double;
begin
  Exit((-2*x+9)*x_factor);
end;

function l(x: Double) : Double;
begin
  Exit((3*x-5)*x_factor);
end;

function m(x: Double) : Double;
begin
  Exit((0.12386*power(x, 2)-1.2641*x+4.52)*x_factor);
end;

function n(x: Double) : Double;
var y: Real;
begin
  if (power(0.95, 2)-power((x-6.25), 2)) <= 0 then
    y:=0
  else
    y:=sqrt(power(0.95, 2)-power((x-6.25), 2));
  Exit((1.3+y)*x_factor);
end;

function o(x: Double) : Double;
begin
  Exit((sqrt(x-7.2)*1.9+1.3)*x_factor);
end;

function p(x: Double) : Double;
begin
  Exit((-4*power(2, -3/4*(x-8.058))+5.862)*x_factor);
end;

{ TForm2 }

function MakeFunctionSeries(i_start: Double; i_end: Double; func: MathFunction;
         Chart1: TChart; start: Double = 0; setUglyStart: Boolean = False)
         : TLineSeries;
var
  Chart1LineSeries1: TLineSeries;
  index: Double;
begin
  index:=i_start;
  Chart1LineSeries1:=TLineSeries.Create(Chart1);
  if setUglyStart then
    Chart1LineSeries1.AddXY(i_start-interval_start,func(index));
  while index < i_end+interval_size do
  begin
    //ShowMessage(FloatToStr(func(index)));
    Chart1LineSeries1.AddXY(index-start,func(index));
    index:=index+interval_size;
  end;
  Exit(Chart1LineSeries1);
end;

procedure DrawFunctions(Chart1: TChart);
begin
  Chart1.ClearSeries();
  Chart1.AddSeries(MakeFunctionSeries(0,0.56,@f,
                                      Chart1, interval_start));
  Chart1.AddSeries(MakeFunctionSeries(0.56,0.7,@g,
                                      Chart1, interval_start));
  Chart1.AddSeries(MakeFunctionSeries(0.7,1.4,@h,
                                      Chart1, interval_start));
  Chart1.AddSeries(MakeFunctionSeries(1.4,1.8,@i,
                                      Chart1,0,True));
  Chart1.AddSeries(MakeFunctionSeries(1.8,2.4,@j,Chart1));
  Chart1.AddSeries(MakeFunctionSeries(2.4,2.8,@k,Chart1));
  Chart1.AddSeries(MakeFunctionSeries(2.4,2.8,@l,Chart1));
  Chart1.AddSeries(MakeFunctionSeries(2.4,5.3,@m,Chart1));
  Chart1.AddSeries(MakeFunctionSeries(5.3,7.2,@n,Chart1));
  Chart1.AddSeries(MakeFunctionSeries(7.2,10.8,@o,Chart1));
  Chart1.AddSeries(MakeFunctionSeries(10.8,13+object_end,@p,Chart1));
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  DrawFunctions(Chart1);
  AssignFile(tfOut, POV_FILE);
  DecimalSeparator:='.';
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  ProgressBar1.Position:=1;
  try
    rewrite(tfOut);
    WriteLn(tfOut, createPovText(interval_start,object_end,interval_size,
                                 x_factor));
    CloseFile(tfout);
    ProgressBar1.Position:=10;
    {$IFDEF WINDOWS}
    if ShellExecute(0,nil, PCHAR('"'+povray_path+'"'),
       PCHAR(POV_FILE+' /EXIT -D'), nil,0)>32 then
    begin
      ProgressBar1.Position:=90;
      Delay(2000);
      Image1.Picture.Clear;
      Image1.Picture.LoadFromFile(IMG_FILE);
      ProgressBar1.Position:=100;
    end;
    {$ENDIF}
    {$IFDEF UNIX}
    //Not tested
    status:=fpSystem(povray_path+' '+POV_FILE);
    if status = 0 then
    begin
      ProgressBar1.Position:=90;
      Image1.Picture.Clear;
      ShowMessage(POV_FILE);
      Image1.Picture.LoadFromFile(IMG_FILE);
      ProgressBar1.Position:=100;
    end
    else
      ShowMessage('Command exited with status code: ' + IntToStr(status));
    {$ENDIF}

    ProgressBar1.Position:=0;
  except
    // If there was an error the reason can be found here
    on E: EInOutError do
      ShowMessage('File handling error occurred. Details: ' + E.ClassName + '/'
      + E.Message);
  end;

end;

procedure TForm2.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  ParentForm.Close;
end;

procedure TForm2.TrackBar1Change(Sender: TObject);
begin
  interval_start:=TrackBar1.Position/10;
  DrawFunctions(Chart1);
end;

procedure TForm2.TrackBar2Change(Sender: TObject);
begin
  object_end:=TrackBar2.Position;
  DrawFunctions(Chart1);
end;

procedure TForm2.TrackBar3Change(Sender: TObject);
begin
  interval_size:=TrackBar3.Position/100;
  DrawFunctions(Chart1);
end;

procedure TForm2.TrackBar4Change(Sender: TObject);
begin
  x_factor:=TrackBar4.Position/2;
  DrawFunctions(Chart1);
end;

end.


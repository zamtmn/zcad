unit uformsregister;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  uformsmanager,uform1,uform2,uform3;

implementation

initialization
  FormsManager.RegisterZCADFormInfo('f1',rect(0  ,0  ,100,100),TForm1,@Form1);
  FormsManager.RegisterZCADFormInfo('f2',rect(0  ,100,100,100),TForm2,@Form2);
  FormsManager.RegisterZCADFormInfo('f3',rect(100,0  ,100,200),TForm3,@Form3);
end.


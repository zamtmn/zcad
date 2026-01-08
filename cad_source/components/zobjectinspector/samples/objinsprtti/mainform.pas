unit mainform;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons,

  uzbUnits,uzbUnitsUtils,uzObjectInspector,UUnitManager,varmandef,
  Varman,uzOIEditors,UEnumDescriptor;

type
  {Z1}//[s]object inspector support only byte size enums[/s]
      //not for rttiregistred types!!!

  TMyEnum=(MyEnum1,MyEnum2,MyEnum3,MyEnum4);
  TMyEnum2=(one,two);
  TSubData=packed record
           a:TMyEnum;
           dataI:Integer;
  end;
  PTOtherData=^TOtherData;
  TOtherData=packed record
    data1:Integer;
    data2:Integer;
    data3:Integer;
  end;
  TData1=packed record
    subdata:TSubData;
    Enum2:TMyEnum2;
    dataI:Integer;
    dataD:Double;
    dataS:String;
    pointerToOtherData:PTOtherData;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    GDBobjinsp1: TGDBobjinsp;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    Splitter1: TSplitter;
    procedure AddOtherdata(Sender: TObject);
    procedure CreateForm(Sender: TObject);
    procedure RandomizeData(Sender: TObject);
    procedure RemoveOtherData(Sender: TObject);
    procedure SwithToData(Sender: TObject);
    procedure SwithToOtherData(Sender: TObject);
  private
    { private declarations }
    RunTimeUnit:ptunit;
    data:tdata1;
    otherdata:TOtherData;
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  UnitsFormat:TzeUnitsFormat;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.CreateForm(Sender: TObject);
  procedure AddEditorToType(const tn:string; CreateEditor:TCreateEditorFunc);//set editor to type
  var
     PT:PUserTypeDescriptor;
  begin
       PT:=RunTimeUnit^.TypeName2PTD(tn);//find type descriptor by name
       if PT<>nil then
                      begin
                           PT^.onCreateEditorFunc:=CreateEditor;//set editor to type
                      end;
  end;
var
  dummyAstring:ansistring; //unit format variable
begin
  UnitsFormat:=CreateDefaultUnitsFormat; //set unit format
  data.subdata.a:=MyEnum4;
  data.subdata.dataI:=100;
  data.Enum2:=two;
  data.dataI:=22;
  data.dataD:=1.5;
  data.dataS:='test';
  data.pointerToOtherData:=nil;

  RunTimeUnit:=units.CreateUnit('',nil,'RunTimeUnit');//create empty zscript unit
  RunTimeUnit.RegisterType(TypeInfo(TData1));//register rtti types in zscript unit

  AddEditorToType('LongInt',TBaseTypesEditors.BaseCreateEditor);//register standart editor to integer type
  AddEditorToType('Double',TBaseTypesEditors.BaseCreateEditor);//register standart editor to double type
  AddEditorToType('AnsiString',TBaseTypesEditors.BaseCreateEditor);//register standart editor to string type
  EnumGlobalEditor:=TBaseTypesEditors.EnumDescriptorCreateEditor;//register standart editor to all enum types
  GDBobjinsp1.setptr(TDisplayedData.CreateRec(@data,RunTimeUnit^.TypeName2PTD('TData1'),nil,UnitsFormat));//show data variable in inspector
end;

procedure TForm1.RandomizeData(Sender: TObject);
begin
     data.dataI:=random(1000);
     data.dataD:=random*1000;
     GDBobjinsp1.updateinsp;
end;

procedure TForm1.RemoveOtherData(Sender: TObject);
begin
  data.pointerToOtherData:=nil;//remove other data integration
  GDBobjinsp1.updateinsp;//update object inspector
end;

procedure TForm1.SwithToData(Sender: TObject);
begin
  GDBobjinsp1.setptr(TDisplayedData.CreateRec(@data,RunTimeUnit^.TypeName2PTD('TData1'),nil,UnitsFormat));//show data variable in inspector
end;

procedure TForm1.SwithToOtherData(Sender: TObject);
begin
  GDBobjinsp1.setptr(TDisplayedData.CreateRec(@otherdata,RunTimeUnit^.TypeName2PTD('TOtherData'),nil,UnitsFormat));//show otherdata variable in inspector
end;

procedure TForm1.AddOtherdata(Sender: TObject);
begin
  data.pointerToOtherData:=@otherdata;//integrate otherdata to data
  GDBobjinsp1.updateinsp;//update object inspector
end;

end.


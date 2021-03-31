{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}
{$MODE OBJFPC}
unit uzccommand_dataexport;
{$INCLUDE def.inc}

interface
uses
  CsvDocument,
  LazLogger,
  SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzccommandsmanager,
  uzeentlwpolyline,uzeentpolyline,uzeentityfactory,
  uzcdrawings,
  uzcutils,
  uzbtypes,
  uzegeometry,
  uzeentity,uzeenttext,
  URecordDescriptor,typedescriptors,Varman,gzctnrvectortypes,
  uzeparserenttypefilter,uzeparserentpropfilter;

implementation

type
  //** Тип данных для отображения в инспекторе опций
  TDataExportParam=record
    EntFilter,PropFilter:AnsiString;
    Exporter:AnsiString;
    FileName:AnsiString;
  end;

var
   DataExportParam:TDataExportParam; //**< Переменная содержащая опции команды ExportTextToCSVParam

function DataExport_com(operands:TCommandOperands):TCommandResult;
var
  count,x,y:integer;
  pv:PGDBObjText;
  ir:itrec;
  minx,maxy:double;
  FDoc:TCSVDocument;

begin
  zcShowCommandParams(SysUnit^.TypeName2PTD('TDataExportParam'),@DataExportParam);
{  count:=0;
  minx:=infinity;
  maxy:=-infinity;
  pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if (pv^.Selected)and isTextEnt(pv^.GetObjType) then begin
     inc(count);
     if minx>pv^.P_insert_in_WCS.x then
       minx:=pv^.P_insert_in_WCS.x;
     if maxy<pv^.P_insert_in_WCS.y then
       maxy:=pv^.P_insert_in_WCS.y;
    end;
  pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;
  if count>0 then begin
    FDoc:=TCSVDocument.Create;
    FDoc.Delimiter:=';';
    pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
    if pv<>nil then
    repeat
      if (pv^.Selected)and isTextEnt(pv^.GetObjType) then begin
        x:=Floor((pv^.P_insert_in_WCS.x-minx)/DataExportParam.W);
        y:=Floor((maxy-pv^.P_insert_in_WCS.y)/DataExportParam.H);
        FDoc.InsertCell(x,y,StringReplace(pv^.Content,#10#13,' ',[rfReplaceAll]));
      end;
    pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pv=nil;
    FDoc.SaveToFile(DataExportParam.FileName);
  end else
  ;}
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');

  //TDataExportParam=record
  //  EntFilter,PropFilter:AnsiString;
  //  EportProp:AnsiString;
  //  FileName:ansistring;
  //end;

  DataExportParam.EntFilter:='IncludeEntityName(''Cable'');'#13#10'IncludeEntityName(''Device'')';
  DataExportParam.PropFilter:='';
  DataExportParam.Exporter:='';
  DataExportParam.FileName:='d:\test.csv';

  SysUnit^.RegisterType(TypeInfo(TDataExportParam));//регистрируем тип данных в зкадном RTTI
  SysUnit^.SetTypeDesk(TypeInfo(TDataExportParam),['EntFilter','PropFilter','Exporter','FileName'],[FNProgram]);//Даем програмные имена параметрам, по идее это должно быть в ртти, но ненашел

  CreateCommandFastObjectPlugin(@DataExport_com,'DataExport',  CADWG,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.

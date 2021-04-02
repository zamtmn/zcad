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
unit uzccommand_exporttexttocsv;
{$INCLUDE def.inc}

interface
uses
  CsvDocument,
  LazLogger,
  SysUtils,
  math,
  uzccommandsabstract,uzccommandsimpl,
  uzbgeomtypes,
  uzccommandsmanager,
  uzeentlwpolyline,uzeentpolyline,uzeentityfactory,
  uzcdrawings,
  uzcutils,
  uzbtypes,
  uzegeometry,
  uzeentity,uzeenttext,uzeconsts,
  URecordDescriptor,typedescriptors,Varman,gzctnrvectortypes;

implementation

type
  //** Тип данных для отображения в инспекторе опций
  TExportTextToCSVParam=record
    W,H:integer;
    FileName:ansistring;
  end;

var
   ExportTextToCSVParam:TExportTextToCSVParam; //**< Переменная содержащая опции команды ExportTextToCSVParam

function ExportTextToCSV_com(operands:TCommandOperands):TCommandResult;
var
  count,x,y:integer;
  pv:PGDBObjText;
  ir:itrec;
  minx,maxy:double;
  FDoc:TCSVDocument;

function isTextEnt(ObjType:TObjID):boolean;inline;
begin
     if (ObjType=GDBtextID)
     or(ObjType=GDBMTextID)then
                               result:=true
                           else
                               result:=false;
end;

begin
  zcShowCommandParams(SysUnit^.TypeName2PTD('TExportTextToCSVParam'),@ExportTextToCSVParam);
  count:=0;
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
        x:=Floor((pv^.P_insert_in_WCS.x-minx)/ExportTextToCSVParam.W);
        y:=Floor((maxy-pv^.P_insert_in_WCS.y)/ExportTextToCSVParam.H);
        FDoc.InsertCell(x,y,StringReplace(pv^.Content,#10#13,' ',[rfReplaceAll]));
      end;
    pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pv=nil;
    FDoc.SaveToFile(ExportTextToCSVParam.FileName);
    FDoc.Free;
  end else
  ;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  ExportTextToCSVParam.W:=20;
  ExportTextToCSVParam.H:=8;
  ExportTextToCSVParam.FileName:='d:\test.csv';

  SysUnit^.RegisterType(TypeInfo(TExportTextToCSVParam));//регистрируем тип данных в зкадном RTTI
  SysUnit^.SetTypeDesk(TypeInfo(TExportTextToCSVParam),['W','H','FileName'],[FNProgram]);//Даем програмные имена параметрам, по идее это должно быть в ртти, но ненашел

  CreateCommandFastObjectPlugin(@ExportTextToCSV_com,'ExportTextToCSV',  CADWG,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.

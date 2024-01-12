{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
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
{$MODE OBJFPC}{$H+}
unit uzccommand_exporttexttocsv;
{$INCLUDE zengineconfig.inc}

interface
uses
  gvector,
  CsvDocument,
  uzbLog,uzcLog,uzcreglog,
  SysUtils,
  uzbpaths,
  math,
  uzccommandsabstract,uzccommandsimpl,
  uzegeometrytypes,
  uzccommandsmanager,
  uzeentlwpolyline,uzeentpolyline,uzeentityfactory,
  uzcdrawings,
  uzcutils,
  uzbtypes,
  uzegeometry,
  uzeentity,uzeenttext,uzeconsts,
  URecordDescriptor,typedescriptors,Varman,gzctnrVectorTypes,uzelongprocesssupport;

implementation

type
  //** Тип данных для отображения в инспекторе опций
  TExportTextToCSVParam=record
    Widths:ansistring;
    W,H:integer;
    FileName:ansistring;
  end;
  TWidths=specialize TVector<Double>;

var
   ExportTextToCSVParam:TExportTextToCSVParam; //**< Переменная содержащая опции команды ExportTextToCSVParam

function Getcolumn(x:double;Widths:TWidths):integer;
var
   i:integer;
   //l:double;
begin
  //result:=Floor((x)/ExportTextToCSVParam.W);
  //l:=0;
  for i:=0 to Widths.Size-1 do begin
    //l:=Widths[i];
    if x<Widths[i] then
       exit(i);
  end;
  exit(Widths.Size);
end;

function ExportTextToCSV_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  count,x,y:integer;
  pv,pstart:PGDBObjText;
  ir:itrec;
  minx,maxy,td:double;
  FDoc:TCSVDocument;
  Widths:TWidths;
  ts,s:ansistring;
  lpsh:TLPSHandle;
  l:double;

function isTextEnt(ObjType:TObjID):boolean;inline;
begin
     if (ObjType=GDBtextID)
     or(ObjType=GDBMTextID)then
                               result:=true
                           else
                               result:=false;
end;

begin
  lpsh:=LPS.StartLongProcess('ExportTextToCSV',@lpsh,0);
  Widths:=TWidths.Create;
  try
    zcShowCommandParams(SysUnit^.TypeName2PTD('TExportTextToCSVParam'),@ExportTextToCSVParam);
    count:=0;
    minx:=infinity;
    maxy:=-infinity;
    pstart:=nil;
    pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
    if pv<>nil then
    repeat
      if (pv^.Selected)and isTextEnt(pv^.GetObjType) then begin
        inc(count);
        if minx>pv^.P_insert_in_WCS.x then
          minx:=pv^.P_insert_in_WCS.x;
        if maxy<pv^.P_insert_in_WCS.y then
          maxy:=pv^.P_insert_in_WCS.y;
        if uppercase(pv^.Content)='START' then
          if pstart=nil then
            pstart:=pv
          else
            ProgramLog.LogOutStr('Other "Start" text marker found',LM_Error,LogModeDefault,MO_SM or MO_SH);
            //debugln('{EHM}'+'Other "Start" text marker found',[]);
      end;
    pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pv=nil;

    if pstart=nil then
      ProgramLog.LogOutStr('"Start" text marker not found',LM_Error,LogModeDefault,MO_SM or MO_SH)
      //debugln('{EHM}'+'"Start" text marker not found',[])
    else begin
      minx:=pstart^.P_insert_in_WCS.x;
      maxy:=pstart^.P_insert_in_WCS.y;
    end;

    s:=ExportTextToCSVParam.Widths;
    l:=0;
    repeat
      GetPartOfPath(ts,s,',');
      if TryStrToFloat(ts,td) then begin
        l:=l+td;
        Widths.PushBack(l)
      end else
        ProgramLog.LogOutFormatStr('"%s" Not a float',[ts],LM_Error,LogModeDefault,MO_SM or MO_SH);
        //debugln('{EHM}'+'"%s" Not a float',[ts]);
    until s='';
    if Widths.IsEmpty then
      Widths.PushBack(20.0);


    if count>0 then begin
      FDoc:=TCSVDocument.Create;
      FDoc.Delimiter:=';';
      pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
      if pv<>nil then
      repeat
        if (pv^.Selected)and isTextEnt(pv^.GetObjType) then begin
          x:=Getcolumn(pv^.P_insert_in_WCS.x-minx,Widths);//Floor((pv^.P_insert_in_WCS.x-minx)/ExportTextToCSVParam.W);
          y:=Floor((maxy-pv^.P_insert_in_WCS.y)/ExportTextToCSVParam.H);
          FDoc.Cells[x,y]:=StringReplace(string(pv^.Content),#10#13,' ',[rfReplaceAll]);
          //FDoc.InsertCell(x,y,StringReplace(pv^.Content,#10#13,' ',[rfReplaceAll]));
        end;
      pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
      until pv=nil;
      FDoc.SaveToFile(ExportTextToCSVParam.FileName);
      FDoc.Free;
    end else
    ;
  finally
    Widths.Free;
    LPS.EndLongProcess(lpsh);
    result:=cmd_ok;
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  ExportTextToCSVParam.Widths:='20,130,60,35,45,20,20,25,40';
  ExportTextToCSVParam.W:=20;
  ExportTextToCSVParam.H:=8;
  ExportTextToCSVParam.FileName:='d:\test.csv';

  SysUnit^.RegisterType(TypeInfo(TExportTextToCSVParam));//регистрируем тип данных в зкадном RTTI
  SysUnit^.SetTypeDesk(TypeInfo(TExportTextToCSVParam),['Widths','W','H','FileName'],[FNProgram]);//Даем програмные имена параметрам, по идее это должно быть в ртти, но ненашел

  CreateZCADCommand(@ExportTextToCSV_com,'ExportTextToCSV',  CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

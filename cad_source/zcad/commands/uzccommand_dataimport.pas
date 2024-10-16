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
{$MODE DELPHI}
unit uzccommand_dataimport;
{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,SysUtils,LazUTF8,
  gzctnrVectorTypes,uzelongprocesssupport,
  uzeentity,
  uzccommandsabstract,uzccommandsimpl,
  uzcdialogsfiles,
  uzbpaths,uzcinterface,
  uzeentitiestypefilter,
  uzcdrawings,uzedrawingsimple,uzgldrawcontext,
  varmandef,uzcenitiesvariablesextender,
  CsvDocument{,uzctnrvectorpgdbaseobjects},uzCtnrVectorpBaseEntity;

implementation

const
  IdentEnd='<<<';

procedure FilterArray(source,dest:PZctnrVectorPGDBaseEntity;prop,value:string);
var
   pvisible:PGDBObjEntity;
   ir:itrec;
   pvd:pvardesk;
   pentvarext:TVariablesExtender;
begin
  pvisible:=source.beginiterate(ir);
  if pvisible<>nil then
  repeat
    pentvarext:=pvisible^.GetExtension<TVariablesExtender>;
    pvd:=pentvarext.entityunit.FindVariable(prop);
    if pvd<>nil then begin
      if pvd.data.PTD.GetValueAsString(pvd.data.Addr.Instance)=value then
        dest.PushBackData(pvisible);
    end;
  pvisible:=source.iterate(ir);
  until pvisible=nil;
end;

procedure SetArray(source:PZctnrVectorPGDBaseEntity;prop,value:string;var drawing:TSimpleDrawing;var DC:TDrawContext);
var
  pvisible:PGDBObjEntity;
  ir:itrec;
  pvd:pvardesk;
  pentvarext:TVariablesExtender;
begin
  pvisible:=source.beginiterate(ir);
  if pvisible<>nil then
  repeat
    pentvarext:=pvisible^.GetExtension<TVariablesExtender>;
    pvd:=pentvarext.entityunit.FindVariable(prop);
    if pvd<>nil then begin
      pvd.data.PTD.SetValueFromString(pvd.data.Addr.Instance,value);
      pvisible.FormatEntity(drawing,DC);
    end;
  pvisible:=source.iterate(ir);
  until pvisible=nil;
end;

function GetFactColCount(FDoc:TCSVDocument;ARow: Integer):Integer;
begin
  Result:=FDoc.ColCount[ARow];
  while (result>0)and(FDoc.Cells[result-1,ARow]='')do
   dec(result);
end;

function RowValue(FDoc:TCSVDocument;ARow:Integer):string;
var
  i:integer;
begin
  result:='';
  for i:=0 to FDoc.ColCount[ARow] do
    if i=0 then
      result:=result+FDoc.Cells[i,ARow]
    else
      result:=result+';'+FDoc.Cells[i,ARow]
end;

procedure ProcessCSVLine(FDoc:TCSVDocument;Row:Integer;var drawing:TSimpleDrawing;var DC:TDrawContext);
var
  Filter:TEntsTypeFilter;
  entarray,filtredentarray:TZctnrVectorPGDBaseEntity;
  fltcounter,fltcount,FactColCount,setvarfrom:integer;
  a1,a2,atemp:PZctnrVectorPGDBaseEntity;
  VarName,VarValue:string;
begin
  FactColCount:=GetFactColCount(FDoc,row);
  if (FactColCount mod 2)=0 then
    inc(FactColCount);
  if (FactColCount<3){or((FactColCount mod 2)<>1)} then begin
    ZCMsgCallBackInterface.TextMessage(format('In row %d wrong number of parameters',[row+1]),TMWOHistoryOut);
    exit;
  end;
  Filter:=TEntsTypeFilter.Create;
  Filter.AddTypeName(FDoc.Cells[0,Row]);
  Filter.SetFilter;
  if Filter.IsEmpty then begin
    ZCMsgCallBackInterface.TextMessage(format('In row %d not found entity type %s',[row+1,FDoc.Cells[0,Row]]),TMWOHistoryOut);
    Filter.Destroy;
    exit;
  end;
  entarray.init(100);
  drawings.FindMultiEntityByType(Filter,entarray);
  if entarray.Count=0 then begin
    ZCMsgCallBackInterface.TextMessage(format('In row %d entity type %s not found in drawing',[row+1,FDoc.Cells[0,Row]]),TMWOHistoryOut);
    Filter.Destroy;
    entarray.Clear;
    entarray.done;
    exit;
  end;

  filtredentarray.init(100);

  a1:=@entarray;
  a2:=@filtredentarray;

  fltcounter:=1;
  fltcount:=(FactColCount-1) div 2;
  setvarfrom:=1;
  while fltcount>fltcounter do begin
    VarName:=FDoc.Cells[fltcounter*2-1,Row];
    if VarName=IdentEnd then begin
      inc(setvarfrom);
      Break;
    end;
    VarValue:=FDoc.Cells[fltcounter*2,Row];
    FilterArray(a1,a2,VarName,VarValue);
    a1.Clear;
    atemp:=a2;
    a2:=a1;
    a1:=atemp;
    inc(fltcounter);
    setvarfrom:=fltcounter*2-1;
  end;

  if a1^.Count<>1 then
    ZCMsgCallBackInterface.TextMessage(format('In row %d found %d candidats (%s)',[row+1,a1^.Count,RowValue(FDoc,row)]),TMWOHistoryOut);
  if a1^.Count<>0 then begin
    while setvarfrom<FactColCount do begin
      VarName:=FDoc.Cells[setvarfrom,Row];
      VarValue:=FDoc.Cells[setvarfrom+1,Row];
      SetArray(a1,VarName,VarValue,drawing,DC);
      inc(setvarfrom,2);
    end;
  end;

  Filter.Destroy;
  entarray.Clear;
  entarray.done;
  filtredentarray.Clear;
  filtredentarray.done;
end;

function DataImport_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  //pv:pGDBObjEntity;
  //ir:itrec;
  lph:TLPSHandle;
  isload:boolean;
  FDoc:TCSVDocument;
  FileName:AnsiString;
  Row:Integer;
  drawing:PTSimpleDrawing;
  DC:TDrawContext;
begin
  if length(operands)=0 then begin
    isload:=OpenFileDialog(FileName,'csv',CSVFileFilter,'',rsOpenSomething);
    if not isload then
      exit(cmd_cancel);
  end else begin
    FileName:=ExpandPath(operands);
    FileName:=FindInSupportPath(GetSupportPath,operands);
  end;
  isload:=FileExists(utf8tosys(FileName));
  if isload then begin
    drawing:=drawings.GetCurrentDWG;
    DC:=drawing.CreateDrawingRC;
    FDoc:=TCSVDocument.Create;
    try
      FDoc.Delimiter:=';';
      FDoc.LoadFromFile(utf8tosys(FileName));
      lph:=lps.StartLongProcess('Data import',nil,FDoc.RowCount);
      for Row:=0 to FDoc.RowCount-1 do begin
        ProcessCSVLine(FDoc,Row,drawing^,DC);
        lps.ProgressLongProcess(lph,Row);
      end;
      lps.EndLongProcess(lph);
    finally
      FDoc.Free;
    end;
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@DataImport_com,'DataImport',  CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

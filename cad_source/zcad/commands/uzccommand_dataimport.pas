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
  uzsbVarmanDef,Varman,uzcenitiesvariablesextender,
  CsvDocument,uzCtnrVectorpBaseEntity,
  uzeentsubordinated,UBaseTypeDescriptor,
  uzcoimultiproperties,uzcoimultipropertiesutil;

implementation

const
  IdentEnd='<<<';

var
  VU:TEntityUnit;

procedure FilterArray(Source,dest:PZctnrVectorPGDBaseEntity;prop,Value:string);
var
  pvisible:PGDBObjEntity;
  ir:itrec;
  pvd:pvardesk;
  pentvarext:TVariablesExtender;
  tmp:TMultiProperty;
  mp:TMultiProperty;
  mpd:TMultiPropertyDataForObjects;
  ChangedData:TChangedData;
  tempresult:string;
  added:boolean;
begin
  if MultiPropertiesManager.MultiPropertyDictionary.MyGetValue(prop,tmp) then begin
    mp:=TMultiProperty.CreateAndCloneFrom(tmp);
    mp.PIiterateData:=mp.MIPD.BeforeIterateProc(mp,@VU);
  end else
    mp:=nil;
  pvisible:=Source.beginiterate(ir);
  if pvisible<>nil then
    repeat
      added:=False;
      pentvarext:=pvisible^.GetExtension<TVariablesExtender>;
      pvd:=pentvarext.entityunit.FindVariable(prop);
      if pvd<>nil then begin
        if pvd.Data.PTD.GetValueAsString(pvd.Data.Addr.Instance)=Value then begin
          dest.PushBackData(pvisible);
          added:=True;
        end;
      end;
      if (mp<>nil)and(not added) then begin

        if mp<>nil then begin
          if mp.MPObjectsData.tryGetValue(TObjIDWithExtender.Create(0,nil),mpd) then begin
            ChangedData:=CreateChangedData(pvisible,mpd.GSData);
            if @mpd.EntBeforeIterateProc<>nil then
              mpd.EntBeforeIterateProc(mp.PIiterateData,ChangedData);
            mpd.EntIterateProc(mp.PIiterateData,ChangedData,mp,True,
              mpd.EntChangeProc,drawings.GetUnitsFormat);
            tempresult:=mp.MPType.GetDecoratedValueAsString(
              PVarDesk(PTOneVarData(mp.PIiterateData)^.VDAddr.Instance).Data.Addr.Instance,
              drawings.GetUnitsFormat);
            added:=True;
          end else if mp.MPObjectsData.tryGetValue(
            TObjIDWithExtender.Create(PGDBObjEntity(pvisible)^.GetObjType,nil),mpd) then begin
            ChangedData:=CreateChangedData(pvisible,mpd.GSData);
            if @mpd.EntBeforeIterateProc<>nil then
              mpd.EntBeforeIterateProc(mp.PIiterateData,ChangedData);
            mpd.EntIterateProc(mp.PIiterateData,ChangedData,mp,True,
              mpd.EntChangeProc,drawings.GetUnitsFormat);
            tempresult:=mp.MPType.GetDecoratedValueAsString(
              PVarDesk(PTOneVarData(mp.PIiterateData)^.VDAddr.Instance).Data.Addr.Instance,
              drawings.GetUnitsFormat);
            added:=True;
          end else
            tempresult:='';
        end else
          tempresult:='';

        if (tempresult=Value)and added then
          dest.PushBackData(pvisible);

      end;

      pvisible:=Source.iterate(ir);
    until pvisible=nil;

  if mp<>nil then begin
    if @mp.MIPD.AfterIterateProc<>nil then
      mp.MIPD.AfterIterateProc(mp.PIiterateData,mp);
    mp.Destroy;
  end;
end;

procedure SetArray(Source:PZctnrVectorPGDBaseEntity;prop,Value:string;
  var drawing:TSimpleDrawing;var DC:TDrawContext);
var
  pvisible:PGDBObjEntity;
  ir:itrec;
  pvd:pvardesk;
  pentvarext:TVariablesExtender;
  vn,vt,vv,vun:string;
  vd:vardesk;
  cancreatevar:boolean;
begin
  pvisible:=Source.beginiterate(ir);
  if pvisible<>nil then
    repeat
      pentvarext:=pvisible^.GetExtension<TVariablesExtender>;
      if pentvarext<>nil then begin
        cancreatevar:=extractvarfromdxfstring(prop,vn,vt,vv,vun);
        if cancreatevar then
          pvd:=pentvarext.entityunit.FindVariable(vn)
        else
          pvd:=pentvarext.entityunit.FindVariable(prop);
        if pvd<>nil then begin
          pvd.Data.PTD.SetValueFromString(pvd.Data.Addr.Instance,Value);
          pvisible.FormatEntity(drawing,DC);
        end else if cancreatevar then begin
          pentvarext.entityunit.setvardesc(vd,vn,vun,vt);
          pentvarext.entityunit.InterfaceVariables.createvariable(vd.Name,vd);
          PBaseTypeDescriptor(vd.Data.PTD)^.SetValueFromString(
            vd.Data.Addr.Instance,Value);
        end;
      end;
      pvisible:=Source.iterate(ir);
    until pvisible=nil;
end;

function GetFactColCount(FDoc:TCSVDocument;ARow:integer):integer;
begin
  Result:=FDoc.ColCount[ARow];
  while (Result>0)and(FDoc.Cells[Result-1,ARow]='') do
    Dec(Result);
end;

function RowValue(FDoc:TCSVDocument;ARow:integer):string;
var
  i:integer;
begin
  Result:='';
  for i:=0 to FDoc.ColCount[ARow] do
    if i=0 then
      Result:=Result+FDoc.Cells[i,ARow]
    else
      Result:=Result+';'+FDoc.Cells[i,ARow];
end;

procedure ProcessCSVLine(FDoc:TCSVDocument;Row:integer;var drawing:TSimpleDrawing;
  var DC:TDrawContext);
var
  Filter:TEntsTypeFilter;
  entarray,filtredentarray:TZctnrVectorPGDBaseEntity;
  fltcounter,fltcount,FactColCount,setvarfrom:integer;
  a1,a2,atemp:PZctnrVectorPGDBaseEntity;
  VarOrPropertyName,VarOrPropertyValue:string;
begin
  FactColCount:=GetFactColCount(FDoc,row);
  if (FactColCount mod 2)=0 then
    Inc(FactColCount);
  if (FactColCount<3){or((FactColCount mod 2)<>1)} then begin
    zcUI.TextMessage(format('In row %d wrong number of parameters',[row+1]),
      TMWOHistoryOut);
    exit;
  end;
  if Length(FDoc.Cells[0,Row])>1 then
    if copy(FDoc.Cells[0,Row],1,2)='##' then begin
      zcUI.TextMessage(format('Row %d commented out',[row+1]),TMWOHistoryOut);
      exit;
    end;
  Filter:=TEntsTypeFilter.Create;
  Filter.AddTypeName(FDoc.Cells[0,Row]);
  Filter.SetFilter;
  if Filter.IsEmpty then begin
    zcUI.TextMessage(format('In row %d not found entity type %s',
      [row+1,FDoc.Cells[0,Row]]),TMWOHistoryOut);
    Filter.Destroy;
    exit;
  end;
  entarray.init(100);
  drawings.FindMultiEntityByType(Filter,entarray);
  if entarray.Count=0 then begin
    zcUI.TextMessage(format('In row %d entity type %s not found in drawing',
      [row+1,FDoc.Cells[0,Row]]),TMWOHistoryOut);
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
    VarOrPropertyName:=FDoc.Cells[fltcounter*2-1,Row];
    if VarOrPropertyName=IdentEnd then begin
      Inc(setvarfrom);
      Break;
    end;
    VarOrPropertyValue:=FDoc.Cells[fltcounter*2,Row];
    FilterArray(a1,a2,VarOrPropertyName,VarOrPropertyValue);
    a1.Clear;
    atemp:=a2;
    a2:=a1;
    a1:=atemp;
    Inc(fltcounter);
    setvarfrom:=fltcounter*2-1;
  end;

  if a1^.Count<>1 then
    //zcUI.TextMessage(format('In row %d found %d candidats (%s)',[row+1,a1^.Count,RowValue(FDoc,row)]),TMWOHistoryOut);
    zcUI.TextMessage(format('In row %d found %d candidats (%s)',
      [row+1,a1^.Count,FDoc.Cells[2,Row]]),TMWOHistoryOut);
  if a1^.Count<>0 then begin
    while setvarfrom<FactColCount do begin
      VarOrPropertyName:=FDoc.Cells[setvarfrom,Row];
      VarOrPropertyValue:=FDoc.Cells[setvarfrom+1,Row];
      if (VarOrPropertyValue<>'')and(VarOrPropertyName<>'') then
        if VarOrPropertyName[1]<>'#' then
          SetArray(a1,VarOrPropertyName,VarOrPropertyValue,drawing,DC);
      Inc(setvarfrom,2);
    end;
  end;

  Filter.Destroy;
  entarray.Clear;
  entarray.done;
  filtredentarray.Clear;
  filtredentarray.done;
end;

function DataImport_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  //pv:pGDBObjEntity;
  //ir:itrec;
  lph:TLPSHandle;
  isload:boolean;
  FDoc:TCSVDocument;
  FileName:ansistring;
  Row:integer;
  drawing:PTSimpleDrawing;
  DC:TDrawContext;
begin
  if length(operands)=0 then begin
    isload:=OpenFileDialog(FileName,'csv',CSVFileFilter,'',rsOpenSomething);
    if not isload then
      exit(cmd_cancel);
  end else begin
    //FileName:=ExpandPath(operands);
    FileName:=FindInPaths(GetSupportPaths,operands);
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
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@DataImport_com,'DataImport',CADWG,0);
  VU.init('test');
  VU.InterfaceUses.PushBackIfNotPresent(sysunit);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
  VU.done;
end.

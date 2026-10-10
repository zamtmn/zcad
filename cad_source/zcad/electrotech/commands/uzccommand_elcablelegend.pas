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
unit uzcCommand_ElCableLegend;
{$mode delphi}
{$Codepage UTF8}
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,generics.Collections,
  LazUTF8,
  gzctnrVectorTypes,uzsbVarmanDef,
  uzcLog,
  gzctnrSTL,uzctnrVectorStrings,
  uzcvariablesutils,Varman,
  uzcdevicebaseabstract,
  uzccablemanager,uzcdialogsfiles,
  uzccommandsabstract,uzccommandsimpl,
  uzgldrawcontext,
  uzcutils,
  uzcinterface,
  uzeentity,uzcentcable,uzeentdevice,uzeEntTable,
  uzcEnitiesVariablesExtender,
  uzcdrawings,uzeTypes,uzccmdfloatinsert,uzeroot,uzeconsts;

implementation

type
  El_Cable_Legend_com=object(FloatInsert_com)
    procedure Command(Operands:TCommandOperands);virtual;
  end;
type
  TSummator=TMyGenMapCounter<string,double>;
  TNumStore=TMyMap<string,integer>;
  TStore=TmyVector<string>;

var
  El_Cable_Legend:El_Cable_Legend_com;

procedure CreateTable(var cman:TCableManager;var Root:GDBObjRoot);
var
  pv:PTCableDesctiptor;
  ir,ir_inDevs,ir_inSegms:itrec;
  cablename,CableMaterial,devstart,devend:AnsiString;
  CableLength,puredevstart:UnicodeString;

  totalMMC,i,index:integer;
  pvd,pmm,eq:pvardesk;
  nodeend,nodestart:PGDBObjDevice;
  Segm:PGDBObjCable;

  {line,}s,summMM:UnicodeString;
  firstline:boolean;
  pt:PGDBObjTable;
  psl:PDXFEntsInternalVectorStrings;
  DC:TDrawContext;
  pstartsegmentvarext:TVariablesExtender;
  Summator:TSummator;
  SummatorItr:TPair<string,double>;//TSummator.TPairEnumerator;
  NumStore:TNumStore;
  Store:TStore;

begin
  Summator:=TSummator.Create;
  NumStore:=TNumStore.Create;
  Store:=TStore.Create;

  pv:=cman.beginiterate(ir);
  if pv<>nil then begin
    Getmem(pointer(pt),sizeof(GDBObjTable));
    pt^.init(@root,nil,0);
    zcSetEntPropFromCurrentDrawingProp(pt);
    pt^.ptablestyle:=drawings.GetCurrentDWG.TableStyleTable.getAddres('KZ');
    pt^.tbl.Free;
    repeat
      begin
        cablename:=pv^.Name;

        pstartsegmentvarext:=pv^.StartSegment^.GetExtension<TVariablesExtender>;
        pvd:=pstartsegmentvarext.entityunit.FindVariable('DB_link');
        CableMaterial:=pstring(pvd^.Data.Addr.Instance)^;

        eq:=DWGDBUnit.FindVariable(CableMaterial);
        if eq<>nil then begin
          CableMaterial:=PDbBaseObject(eq^.Data.Addr.Instance)^.NameShort;
        end;
        CableLength:=floattostr(pv^.length);

        firstline:=True;
        devstart:='Не присоединено';
        nodestart:=pv^.Devices.beginiterate(ir_inDevs);
        if pv^.StartDevice<>nil then begin
          pvd:=FindVariableInEnt(pv^.StartDevice,'NMO_Name');
          if pvd<>nil then
            devstart:=pstring(pvd^.Data.Addr.Instance)^;
          nodeend:=pv^.Devices.iterate(ir_inDevs);
        end else
          nodeend:=nodestart;
        puredevstart:=devstart;
        psl:=pt^.tbl.CreateObject;
        psl.init(12);
        repeat
          devend:='Не присоединено';
          repeat
            if nodeend=nil then
              system.break;
            pvd:=FindVariableInEnt(nodeend,'NMO_Name');
            if pvd=nil then
              nodeend:=pv^.Devices.iterate(ir_inDevs);
          until pvd<>nil;
          if nodeend<>nil then
            devend:=pstring(pvd^.Data.Addr.Instance)^;
          if firstline then begin
            s:='';
            psl.PushBackData(cablename);
            psl.PushBackData(devstart);
          end else begin
          end;
          firstline:=False;
          devstart:=devend;
          nodeend:=pv^.Devices.iterate(ir_inDevs);
        until nodeend=nil;

        Summator.Clear;
        summMM:='';
        Segm:=pv^.Segments.beginiterate(ir_inSegms);
        if Segm<>nil then
          repeat
            pmm:=FindVariableInEnt(Segm,'CABLE_MountingMethod');
            if pmm<>nil then begin
              pvd:=FindVariableInEnt(Segm,'AmountD');
              if pvd<>nil then begin
                Summator.CountKey(pmm.GetValueAsString,pdouble(pvd^.Data.Addr.GetInstance)^);
              end;
            end;
            Segm:=pv^.Segments.iterate(ir_inSegms);
          until Segm=nil;

        if Summator.Count>0 then begin
          for i:=0 to totalMMC do
            store.Mutable[i]^:='';
          for SummatorItr in Summator do begin
            index:=NumStore[SummatorItr.Key];
            store.Mutable[index]^:=FloatToStr(SummatorItr.Value);
          end;
          for i:=0 to totalMMC do
            if i=0 then
              summMM:=store[i]
            else
              summMM:=summMM+';'+store[i];
        end;

        if summMM<>'' then
          //--line:='`'+cablename+';'+CableMaterial+';'+CableLength+';'+puredevstart+';'+devend+';'+summMM+#13#10
        else
          //--line:='`'+cablename+';'+CableMaterial+';'+CableLength+';'+puredevstart+';'+devend+#13#10;
        ;
        //--FileWrite(handle,line[1],length(line));
        s:='';
        psl.PushBackData(devend);
        psl.PushBackData('');
        psl.PushBackData('');
        psl.PushBackData('');
        psl.PushBackData('');
        psl.PushBackData(CableMaterial);
        psl.PushBackData(CableLength);
        psl.PushBackData('');
        psl.PushBackData('');
        psl.PushBackData('');

        zcUI.TextMessage(format('Cable %s, %d segments, %s, from: %s to: %s',[pv^.Name,pv^.Segments.Count,CableMaterial,puredevstart,devend]),
          TMWOHistoryOut);

      end;
      pv:=cman.iterate(ir);
    until pv=nil;

    root.AddObjectToObjArray(@pt);
    pt^.Build(drawings.GetCurrentDWG^);
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    pt^.FormatEntity(drawings.GetCurrentDWG^,dc);
  end;

    Summator.Free;
    NumStore.Free;
    Store.Free;
end;

procedure El_Cable_Legend_com.Command(Operands:TCommandOperands);
var
  cman:TCableManager;
begin
  cman.init;
  cman.build;

  CreateTable(cman,drawings.GetCurrentDWG.ConstructObjRoot);
  zcRedrawCurrentDrawing;
  cman.done;
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint)or(MMoveCamera)or(MRotateCamera));
end;

function _Cable_com_Legend(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
type
  TSummator=TMyGenMapCounter<string,double>;
  TNumStore=TMyMap<string,integer>;
  TStore=TmyVector<string>;
var
  pv:PTCableDesctiptor;
  ir,ir_inDevs,ir_inSegms:itrec;
  filename,cablename,CableMaterial,CableLength,devstart,devend,puredevstart:string;
  DCableLength:double;
  totalMMC,i,index:integer;
  handle:cardinal;
  pvd,pmm,eq:pvardesk;
  nodeend,nodestart:PGDBObjDevice;
  Segm:PGDBObjCable;

  line,s,summMM:string;
  firstline:boolean;
  cman:TCableManager;
  pt:PGDBObjTable;
  psl:PDXFEntsInternalVectorStrings;
  DC:TDrawContext;
  pstartsegmentvarext:TVariablesExtender;
  Summator:TSummator;
  SummatorItr:TPair<string,double>;//TSummator.TPairEnumerator;
  NumStore:TNumStore;
  Store:TStore;
begin
  filename:='';
  if SaveFileDialog(filename,'CSV',CSVFileFilter,'','Сохранить данные...') then begin
    DefaultFormatSettings.DecimalSeparator:=',';
    Summator:=TSummator.Create;
    NumStore:=TNumStore.Create;
    Store:=TStore.Create;
    cman.init;
    cman.build;

    pv:=cman.beginiterate(ir);
    DCableLength:=0;
    if pv<>nil then
      repeat
        DCableLength:=DCableLength+pv^.length;

        Segm:=pv^.Segments.beginiterate(ir_inSegms);
        if Segm<>nil then
          repeat
            pmm:=FindVariableInEnt(Segm,'CABLE_MountingMethod');
            if pmm<>nil then begin
              pvd:=FindVariableInEnt(Segm,'AmountD');
              if pvd<>nil then begin
                Summator.CountKey(pmm.GetValueAsString,pdouble(pvd^.Data.Addr.GetInstance)^);
              end;
            end;
            Segm:=pv^.Segments.iterate(ir_inSegms);
          until Segm=nil;

        pv:=cman.iterate(ir);
      until pv=nil;

    totalMMC:=0;
    summMM:='';
    if Summator.Count>0 then begin
      for SummatorItr in Summator do begin

        if summMM='' then
          summMM:=SummatorItr.Key
        else
          summMM:=summMM+';'+SummatorItr.Key;

        Store.PushBack(SummatorItr.Key);
        NumStore.Add(SummatorItr.Key,totalMMC);
        Inc(totalMMC);
      end;
    end;
    Dec(totalMMC);

    handle:=FileCreate(UTF8ToSys(filename),fmOpenWrite);
    if summMM='' then
      line:='Обозначение'+';'+'Материал'+';'+'Длина'+';'+'Начало'+';'+'Конец'+#13#10
    else begin
      line:='Обозначение'+';'+'Материал'+';'+'Длина'+';'+'Начало'+';'+'Конец';
      for i:=0 to totalMMC do
        line:=line+';'+Store[i];
      line:=line+#13#10;
      line:={Tria_Utf8ToAnsi}(line);
    end;
    FileWrite(handle,line[1],length(line));

    if summMM='' then
      line:=''+';'+';'+floattostr(DCableLength)+#13#10
    else begin
      line:=''+';'+';'+floattostr(DCableLength)+';'+''+';'+'';
      for SummatorItr in Summator do
        line:=line+';'+floattostr(SummatorItr.Value);
      line:=line+#13#10;
    end;
    FileWrite(handle,line[1],length(line));


    zcRedrawCurrentDrawing;
    FileClose(handle);
    cman.done;
    Summator.Destroy;
    NumStore.Destroy;
    Store.Destroy;
    DefaultFormatSettings.DecimalSeparator:='.';
  end;
  Result:=cmd_ok;
end;



initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  El_Cable_Legend.init('El_Cable_Legend',0,0,True);
  //CreateZCADCommand(@_Cable_com_Legend,'El_Cable_Legend',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

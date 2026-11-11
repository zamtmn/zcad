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
  uzcdrawings,uzeTypes,uzccmdfloatinsert,uzeroot,uzeconsts,uzeGeometryTypes,uzeGeometry;

implementation

type
  El_Cable_Legend_com=object(FloatInsert_com)
    procedure Command(Operands:TCommandOperands);virtual;
  end;

type
  TSummator=TMyGenMapCounter<string,double>;
  TSummatorItr=TPair<string,double>;//TSummator.TPairEnumerator;
  TNumStore=TMyMap<string,integer>;
  TStore=TmyVector<string>;

var
  El_Cable_Legend:El_Cable_Legend_com;

procedure CreateTableOther(const APInsert:TzePoint3d;var Root:GDBObjRoot;var cman:TCableManager;var Summator:TSummator;var NumStore:TNumStore;
  var Store:TStore);
var
  pv:PTCableDesctiptor;
  ir,ir_inSegms:itrec;

  totalMMC,i:integer;
  pvd,pmm:pvardesk;
  Segm:PGDBObjCable;

  summMM:string;
  pt:PGDBObjTable;
  psl:PDXFEntsInternalVectorStrings;
  DC:TDrawContext;
  DCableLength:double;
  SummatorItr:TSummatorItr;
begin
  pv:=cman.beginiterate(ir);
  DCableLength:=0;
  if pv<>nil then begin
    Getmem(pointer(pt),sizeof(GDBObjTable));
    pt^.init(@root,nil,0);
    pt.Local.P_insert:=APInsert;
    zcSetEntPropFromCurrentDrawingProp(pt);
    pt^.ptablestyle:=drawings.GetCurrentDWG.TableStyleTable.getAddres('KZ');
    pt^.tbl.Free;

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
  end;

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

  psl:=pt^.tbl.CreateObject;
  psl.init(12);
  psl.PushBackData('Обозначение');
  psl.PushBackData('Материал');
  psl.PushBackData('Длина');
  psl.PushBackData('Начало');
  psl.PushBackData('Конец');

  if summMM<>'' then begin
    for i:=0 to totalMMC do
      psl.PushBackData(Store[i]);
  end;

  psl.PushBackData('');
  psl.PushBackData('');
  psl.PushBackData(floattostr(DCableLength));

  if summMM<>'' then begin
    for SummatorItr in Summator do
      psl.PushBackData(floattostr(SummatorItr.Value));
  end;

  root.AddObjectToObjArray(@pt);
  pt^.Build(drawings.GetCurrentDWG^);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pt^.FormatEntity(drawings.GetCurrentDWG^,dc);
end;

function CreateTableKZ(const APInsert:TzePoint3d;var Root:GDBObjRoot;var cman:TCableManager;var Summator:TSummator;var NumStore:TNumStore;
  var Store:TStore):TzePoint3d;
var
  pv:PTCableDesctiptor;
  ir,ir_inDevs,ir_inSegms:itrec;
  cablename,CableMaterial,devstart,devend:ansistring;
  CableLength,puredevstart:unicodestring;

  totalMMC,i,index:integer;
  pvd,pmm,eq:pvardesk;
  nodeend,nodestart:PGDBObjDevice;
  Segm:PGDBObjCable;

  s,summMM:unicodestring;
  firstline:boolean;
  pt:PGDBObjTable;
  psl:PDXFEntsInternalVectorStrings;
  DC:TDrawContext;
  pstartsegmentvarext:TVariablesExtender;
  DCableLength:double;
  SummatorItr:TSummatorItr;
begin
  Result:=APInsert;
  pv:=cman.beginiterate(ir);
  if pv<>nil then begin
    Getmem(pointer(pt),sizeof(GDBObjTable));
    pt^.init(@root,nil,0);
    pt.Local.P_insert:=APInsert;
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
    Result.y:=pt.vp.BoundingBox.pMin.y;
  end;
end;

procedure El_Cable_Legend_com.Command(Operands:TCommandOperands);
var
  cman:TCableManager;
  Summator:TSummator;
  NumStore:TNumStore;
  Store:TStore;
  PInsert:TzePoint3d;
begin
  cman.init;
  cman.build;
  Summator:=TSummator.Create;
  NumStore:=TNumStore.Create;
  Store:=TStore.Create;

  PInsert:=CreateTableKZ(cP3d__0__0__0,drawings.GetCurrentDWG.ConstructObjRoot,cman,Summator,NumStore,Store);
  CreateTableOther(PInsert,drawings.GetCurrentDWG.ConstructObjRoot,cman,Summator,NumStore,Store);
  zcRedrawCurrentDrawing;
  cman.done;
  Summator.Free;
  NumStore.Free;
  Store.Free;

  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint)or(MMoveCamera)or(MRotateCamera));
end;

initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  El_Cable_Legend.init('El_Cable_Legend',0,0,True);
  //CreateZCADCommand(@_Cable_com_Legend,'El_Cable_Legend',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

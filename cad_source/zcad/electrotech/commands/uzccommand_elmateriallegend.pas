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
{$mode delphi}
unit uzcCommand_ElMaterialLegend;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  LazUTF8,Masks,
  gzctnrVectorTypes,uzsbVarmanDef,
  uzbstrproc,
  uzeconsts,
  uzcLog,
  uzctnrVectorStrings,
  Varman,
  uzcdevicebaseabstract,
  uzccablemanager,uzcdialogsfiles,
  uzccommandsabstract,uzccommandsimpl,
  uzgldrawcontext,
  uzcutils,
  uzcinterface,
  uzeentity,uzcentcable,uzeentdevice,uzeEntTable,
  uzcEnitiesVariablesExtender,
  uzcbillofmaterial,
  uzcdrawings,uzcdrawing,uzbPaths,uzcTranslations;

implementation

var
  MainSpecContentFormat:TZctnrVectorStrings;

function _Material_com_Legend(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pv:pGDBObjEntity;
  ir,ir_inscf:itrec;
  s,filename:string;
  currentgroup:PString;
  handle:cardinal;
  pvad,pvai,pvm:pvardesk;

  line:string;

  bom:GDBBbillOfMaterial;
  PBOMITEM:PGDBBOMItem;

  pt:PGDBObjTable;
  psl:PTZctnrVectorStrings;

  pdbu:ptunit;
  pdbv:pvardesk;
  pdbi:PDbBaseObject;

  cman:TCableManager;
  pcd:PTCableDesctiptor;
  DC:TDrawContext;
  pcablevarext,pstartsegmentvarext:TVariablesExtender;
  gcounter,counter:integer;
  notempty:boolean;
begin
  filename:='';
  if SaveFileDialog(filename,'CSV',CSVFileFilter,'','Сохранить данные...') then begin
    bom.init(1000);
    handle:=FileCreate(UTF8ToSys(filename),fmOpenWrite);
    line:=Tria_Utf8ToAnsi('Материал'+';'+'Количество'+';'+'Устройства'+#13#10);
    FileWrite(handle,line[1],length(line));
    pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pv<>nil then
      repeat
        if pv^.GetObjType<>GDBCableID then begin
          pcablevarext:=pv^.GetExtension<TVariablesExtender>;
          if pcablevarext<>nil then begin
            pvm:=pcablevarext.entityunit.FindVariable('DB_link',True);
            if pvm<>nil then begin
              pvad:=pcablevarext.entityunit.FindVariable('AmountD');
              pvai:=pcablevarext.entityunit.FindVariable('AmountI');
              //if (pvad<>nil)or(pvai<>nil) then
              begin
                pbomitem:=bom.findorcreate(pstring(pvm^.Data.Addr.Instance)^);
                if pbomitem<>nil then begin
                  if (pvad<>nil) then
                    pbomitem.Amount:=pbomitem.Amount+pDouble(pvad^.Data.Addr.Instance)^
                  else if (pvai<>nil) then
                    pbomitem.Amount:=pbomitem.Amount+PInteger(pvai^.Data.Addr.Instance)^
                  else
                    pbomitem.Amount:=pbomitem.Amount+1;
                  pvm:=pcablevarext.entityunit.FindVariable('NMO_Name');
                  if (pvm<>nil) then
                    if pbomitem.Names<>'' then
                      pbomitem.Names:=pbomitem.Names+', '+pstring(pvm^.Data.Addr.Instance)^
                    else
                      pbomitem.Names:=pstring(pvm^.Data.Addr.Instance)^;

                end;
              end;
            end;
          end;
        end;
        pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
      until pv=nil;

    cman.init;
    cman.build;

    pcd:=cman.beginiterate(ir);
    if pcd<>nil then
      repeat


        if pcd.StartSegment<>nil then begin
          pstartsegmentvarext:=pcd.StartSegment^.GetExtension<TVariablesExtender>;
          pvm:=pstartsegmentvarext.entityunit.FindVariable('DB_link');
          if pvm<>nil then begin
            begin
              pbomitem:=bom.findorcreate(pstring(pvm^.Data.Addr.Instance)^);
              if pbomitem<>nil then begin
                pbomitem.Amount:=pbomitem.Amount+pcd.length;
              end;
            end;
          end;
        end;


        pcd:=cman.iterate(ir);
      until pcd=nil;

    cman.done;

    DefaultFormatSettings.DecimalSeparator:=',';
    PBOMITEM:=bom.beginiterate(ir);
    if PBOMITEM<>nil then
      repeat
        line:=pbomitem.Material+';'+floattostr(pbomitem.Amount)+';'+pbomitem.Names+#13#10;
        line:=Tria_Utf8ToAnsi(line);
        FileWrite(handle,line[1],length(line));

        PBOMITEM:=bom.iterate(ir);
      until PBOMITEM=nil;
    DefaultFormatSettings.DecimalSeparator:='.';
    FileClose(handle);


    Getmem(pointer(pt),sizeof(GDBObjTable));
    pt^.initnul;
    zcSetEntPropFromCurrentDrawingProp(pt);
    pt^.ptablestyle:=drawings.GetCurrentDWG.TableStyleTable.getAddres('Spec');
    pt^.tbl.Free;

    pdbu:=PTZCADDrawing(drawings.GetCurrentDWG).DWGUnits.findunit(GetSupportPaths,InterfaceTranslate,DrawingDeviceBaseUnitName);
    currentgroup:=MainSpecContentFormat.beginiterate(ir_inscf);
    counter:=1;
    gcounter:=1;
    notempty:=False;
    if currentgroup<>nil then
      if length(currentgroup^)>1 then
        repeat
          if currentgroup^[1]='!' then begin
            psl:=pt^.tbl.CreateObject;
            //psl:=pointer(pt^.tbl.CreateObject);
            psl.init(2);

            s:='';
            psl.PushBackData(s);

            s:={Tria_Utf8ToAnsi}(currentgroup^);
            s:='  '+system.copy(s,2,length(s)-1);
            //s:='  '+system.copy(currentgroup^,2,length(currentgroup^)-1);
            psl.PushBackData(s);
            counter:=1;
            if notempty then begin
              Inc(gcounter);
              notempty:=False;
            end;
          end
          else begin
            PBOMITEM:=bom.beginiterate(ir);
            if PBOMITEM<>nil then
              repeat
                pdbv:=pdbu^.FindVariable(PBOMITEM^.Material);
                if pdbv<>nil then
                  if not(PBOMITEM.processed) then
                  begin
                    pdbi:=pdbv^.Data.Addr.Instance;
                    if MatchesMask(pdbi^.Group,currentgroup^) then
                    begin
                      PBOMITEM.processed:=True;
                      psl:=pt^.tbl.CreateObject;
                      psl.init(9);

                      pdbi^.Position:=IntToStr(gcounter)+'.'+IntToStr(counter);
                      Inc(counter);
                      notempty:=True;

                      s:=pdbi^.Position;
                      psl.PushBackData({Tria_Utf8ToAnsi}(s));

                      s:=' '+pdbi^.NameFull;
                      psl.PushBackData({Tria_Utf8ToAnsi}(s));

                      s:=pdbi^.NameShort+' '+pdbi^.Standard;
                      psl.PushBackData({Tria_Utf8ToAnsi}(s));

                      s:=pdbi^.OKP;
                      psl.PushBackData({Tria_Utf8ToAnsi}(s));

                      s:=pdbi^.Manufacturer;
                      psl.PushBackData({Tria_Utf8ToAnsi}(s));

                      s:='??';
                      case pdbi^.EdIzm of
                        _sht:s:='шт.';
                        _m:s:='м';
                      end;
                      psl.PushBackData({Tria_Utf8ToAnsi}(s));

                      s:=floattostr(PBOMITEM^.Amount);
                      psl.PushBackData(s);

                      s:='';
                      psl.PushBackData({Tria_Utf8ToAnsi}(s));
                      s:=PBOMITEM.Names;
                      psl.PushBackData({Tria_Utf8ToAnsi}(s));
                    end;

                  end;
                line:=pbomitem.Material+';'+floattostr(pbomitem.Amount)+';'+pbomitem.Names+#13#10;
                FileWrite(handle,line[1],length(line));

                PBOMITEM:=bom.iterate(ir);
              until PBOMITEM=nil;
          end;

          currentgroup:=MainSpecContentFormat.iterate(ir_inscf);
        until currentgroup=nil;

    drawings.GetCurrentROOT.AddObjectToObjArray{ObjArray.add}(@pt);
    pt^.Build(drawings.GetCurrentDWG^);
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    pt^.FormatEntity(drawings.GetCurrentDWG^,dc);


    zcRedrawCurrentDrawing;
    bom.done;
  end;
  Result:=cmd_ok;
end;




initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@_Material_com_Legend,'El_Material_Legend',CADWG,0);
  MainSpecContentFormat.init(100);
  MainSpecContentFormat.loadfromfile(FindInPaths(GetSupportPaths,'main.sf'));

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  MainSpecContentFormat.Done;
end.

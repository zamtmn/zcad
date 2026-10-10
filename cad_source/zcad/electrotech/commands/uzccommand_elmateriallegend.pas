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
unit uzcCommand_ElMaterialLegend;
{$mode delphi}
{$Codepage UTF8}
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,Classes,
  LazUTF8,Masks,
  gzctnrVectorTypes,uzsbVarmanDef,
  uzbEncoding,
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
  uzcdrawings,uzcdrawing,uzbPaths,uzcTranslations,uzccmdfloatinsert,uzeroot,uzeTypes;

implementation

type
  El_Material_Legend_com=object(FloatInsert_com)
    procedure Command(Operands:TCommandOperands);virtual;
  end;

var
  MainSpecContentFormat:TZctnrVectorStrings;
  El_Material_Legend:El_Material_Legend_com;

procedure WriteBOMToFile(const filename:string;var bom:GDBBbillOfMaterial);
var
  ir:itrec;
  uline:unicodestring;
  PBOMITEM:PGDBBOMItem;
  fileBOM:rawbytestring;
  fcp:TCodePage;
  fs:TFileStream;
  encoding:TEncoding;
  bytes:TBytes;
begin
  fs:=TFileStream.Create(UTF8ToSys(filename),fmCreate or fmOpenWrite);
  try
    fcp:=TXTCodePage(TxtFileSaveCodePage);
    fileBOM:=getBOM(fcp);
    encoding:=getEncoding(fcp);
    if fileBOM<>'' then
      fs.Write(fileBOM[1],Length(fileBOM)*SizeOf(fileBOM[1]));
    uline:='Материал;Количество;Устройства'#13#10;
    bytes:=encoding.GetBytes(uline);
    fs.Write(bytes[0],Length(bytes)*SizeOf(bytes[0]));

    DefaultFormatSettings.DecimalSeparator:=',';
    PBOMITEM:=bom.beginiterate(ir);
    if PBOMITEM<>nil then
      repeat
        uline:=pbomitem.Material+';'+floattostr(pbomitem.Amount)+';'+pbomitem.Names+#13#10;
        bytes:=encoding.GetBytes(uline);
        fs.Write(bytes[0],Length(bytes)*SizeOf(bytes[0]));

        PBOMITEM:=bom.iterate(ir);
      until PBOMITEM=nil;
    DefaultFormatSettings.DecimalSeparator:='.';
  finally
    fs.Free;
  end;
end;

procedure FillBOM(var bom:GDBBbillOfMaterial);
var
  pv:pGDBObjEntity;
  ir:itrec;
  pvad,pvai,pvm:pvardesk;
  PBOMITEM:PGDBBOMItem;
  cman:TCableManager;
  pcd:PTCableDesctiptor;
  pcablevarext,pstartsegmentvarext:TVariablesExtender;
begin
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
end;

procedure CreateTable(var bom:GDBBbillOfMaterial;var Root:GDBObjRoot);
var
  ir,ir_inscf:itrec;
  s:string;
  currentgroup:PString;
  handle:cardinal;

  line:string;

  PBOMITEM:PGDBBOMItem;

  pt:PGDBObjTable;
  psl:PDXFEntsInternalVectorStrings;

  pdbu:ptunit;
  pdbv:pvardesk;
  pdbi:PDbBaseObject;

  DC:TDrawContext;
  gcounter,counter:integer;
  notempty:boolean;
begin
  Getmem(pointer(pt),sizeof(GDBObjTable));
  pt^.init(@root,nil,0);
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
          psl.init(2);

          s:='';
          psl.PushBackData(s);

          s:=currentgroup^;
          s:='  '+system.copy(s,2,length(s)-1);
          psl.PushBackData(s);
          counter:=1;
          if notempty then begin
            Inc(gcounter);
            notempty:=False;
          end;
        end else begin
          PBOMITEM:=bom.beginiterate(ir);
          if PBOMITEM<>nil then
            repeat
              pdbv:=pdbu^.FindVariable(PBOMITEM^.Material);
              if pdbv<>nil then
                if not(PBOMITEM.processed) then begin
                  pdbi:=pdbv^.Data.Addr.Instance;
                  if MatchesMask(pdbi^.Group,currentgroup^) then begin
                    PBOMITEM.processed:=True;
                    psl:=pt^.tbl.CreateObject;
                    psl.init(9);

                    pdbi^.Position:=IntToStr(gcounter)+'.'+IntToStr(counter);
                    Inc(counter);
                    notempty:=True;

                    s:=pdbi^.Position;
                    psl.PushBackData(s);

                    s:=' '+pdbi^.NameFull;
                    psl.PushBackData(s);

                    s:=pdbi^.NameShort+' '+pdbi^.Standard;
                    psl.PushBackData(s);

                    s:=pdbi^.OKP;
                    psl.PushBackData(s);

                    s:=pdbi^.Manufacturer;
                    psl.PushBackData(s);

                    s:='??';
                    case pdbi^.EdIzm of
                      _sht:s:='шт.';
                      _m:s:='м';
                    end;
                    psl.PushBackData(s);

                    s:=floattostr(PBOMITEM^.Amount);
                    psl.PushBackData(s);

                    s:='';
                    psl.PushBackData(s);
                    s:=PBOMITEM.Names;
                    psl.PushBackData(s);
                  end;

                end;
              line:=pbomitem.Material+';'+floattostr(pbomitem.Amount)+';'+pbomitem.Names+#13#10;
              FileWrite(handle,line[1],length(line));

              PBOMITEM:=bom.iterate(ir);
            until PBOMITEM=nil;
        end;

        currentgroup:=MainSpecContentFormat.iterate(ir_inscf);
      until currentgroup=nil;

  //drawings.GetCurrentROOT.AddObjectToObjArray(@pt);
  root.ObjArray.AddPEntity(pt^);
  pt^.Build(drawings.GetCurrentDWG^);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pt^.FormatEntity(drawings.GetCurrentDWG^,dc);


  zcRedrawCurrentDrawing;
  bom.done;
end;

procedure El_Material_Legend_com.Command;
var
  bom:GDBBbillOfMaterial;
begin
  bom.init(1000);
  FillBOM(bom);
  CreateTable(bom,drawings.GetCurrentDWG.ConstructObjRoot);
  zcRedrawCurrentDrawing;
  bom.done;
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint)or(MMoveCamera)or(MRotateCamera));
  //Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  El_Material_Legend.init('El_Material_Legend',0,0,True);
  MainSpecContentFormat.init(100);
  MainSpecContentFormat.loadfromfile(FindInPaths(GetSupportPaths,'main.sf'));

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  MainSpecContentFormat.Done;
end.

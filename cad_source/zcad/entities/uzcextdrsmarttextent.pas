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
unit uzcExtdrSmartTextEnt;

interface

uses
  sysutils,
  uzbtypesbase,uzbtypes,
  math,uzegeometry,
  UGDBOpenArrayOfByte,
  uzedrawingdef,uzgldrawcontext,
  uzeffdxfsupport,
  uzeentdevice,uzeentsubordinated,uzeentity,uzeenttext,uzeblockdef,uzeentmtext,uzeentwithlocalcs,
  uzeentityextender,uzeBaseExtender;
const
  SmartTextEntExtenderName='extdrSmartTextEnt';
type
  TSmartTextEntExtender=class(TBaseEntityExtender)
    GoodLayer,BadLayer:GDBString;
    VariableName:GDBString;
    Inverse:GDBBoolean;
    class function getExtenderName:string;override;
    constructor Create(pEntity:Pointer);override;
    procedure Assign(Source:TBaseExtender);override;
    procedure onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
    procedure onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
    procedure SaveToDxf(var outhandle:GDBOpenArrayOfByte;PEnt:Pointer;var IODXFContext:TIODXFContext);override;
    procedure PostLoad(var context:TIODXFLoadContext);override;
    procedure onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);override;
  end;

implementation
procedure TSmartTextEntExtender.Assign(Source:TBaseExtender);
begin
end;

constructor TSmartTextEntExtender.Create(pEntity:Pointer);
begin
end;

procedure TSmartTextEntExtender.onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  dx:Double;
begin
  if (typeof(PGDBObjEntity(pEntity)^)=TypeOf(GDBObjText))then
    if PGDBObjText(pEntity)^.bp.ListPos.Owner<>nil then
      if typeof(PGDBObjText(pEntity)^.bp.ListPos.Owner^)=TypeOf(GDBObjDevice) then begin
        if Vertexlength(PGDBObjWithLocalCS(PGDBObjText(pEntity)^.bp.ListPos.Owner)^.P_insert_in_WCS,PGDBObjText(pEntity).P_insert_in_WCS)>10 then begin
          PGDBObjText(pEntity).Representation.DrawLineWithLT(DC,PGDBObjWithLocalCS(PGDBObjText(pEntity)^.bp.ListPos.Owner)^.P_insert_in_WCS,PGDBObjText(pEntity).P_insert_in_WCS,PGDBObjEntity(pEntity)^.vp);
          dx:=PGDBObjText(pEntity).obj_width*PGDBObjMText(pEntity).textprop.size*PGDBObjMText(pEntity).textprop.wfactor;
          if PGDBObjMText(pEntity).textprop.justify in [jsbr,jsmr,jstr] then
            dx:=-dx;
          PGDBObjText(pEntity).Representation.DrawLineWithLT(DC,PGDBObjText(pEntity).P_insert_in_WCS,
                                                                VertexAdd(PGDBObjText(pEntity).P_insert_in_WCS,CreateVertex(dx,0,0)),PGDBObjEntity(pEntity)^.vp);
        end;
  end;
end;
procedure TSmartTextEntExtender.onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  jtt2: array[-1..1,-1..1] of TTextJustify = ((jsbl, jsbc, jsbr),(jsml, jsmc, jsmr),(jstl, jstc, jstr));
  jtt: array[-1..1,-1..1] of TTextJustify = ((jsbl, jsbl, jsbr),(jsbl, jsbl, jsbr),(jsbl, jsbl, jsbr));
begin
  if typeof(PGDBObjEntity(pEntity)^)=TypeOf(GDBObjText) then begin
    if Vertexlength(PGDBObjWithLocalCS(PGDBObjText(pEntity)^.bp.ListPos.Owner)^.P_insert_in_WCS,PGDBObjText(pEntity).P_insert_in_WCS)>10 then
      PGDBObjMText(pEntity).textprop.justify:=jtt[-sign(PGDBObjText(pEntity).Local.P_insert.y),-sign(PGDBObjText(pEntity).Local.P_insert.x)]
    else
      PGDBObjMText(pEntity).textprop.justify:=jtt2[-sign(PGDBObjText(pEntity).Local.P_insert.y),-sign(PGDBObjText(pEntity).Local.P_insert.x)]
  end;
end;

class function TSmartTextEntExtender.getExtenderName:string;
begin
  result:=SmartTextEntExtenderName;
end;

procedure TSmartTextEntExtender.SaveToDxf(var outhandle:GDBOpenArrayOfByte;PEnt:Pointer;var IODXFContext:TIODXFContext);
begin
end;

procedure TSmartTextEntExtender.PostLoad(var context:TIODXFLoadContext);
begin
end;


procedure TSmartTextEntExtender.onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
begin
end;

initialization
  EntityExtenders.RegisterKey(uppercase(SmartTextEntExtenderName),TSmartTextEntExtender);
finalization
end.

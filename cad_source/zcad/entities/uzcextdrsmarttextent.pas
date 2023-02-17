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
unit uzcExtdrSmartTextEnt;

interface

uses
  sysutils,
  math,uzegeometry,
  uzctnrVectorBytes,
  uzedrawingdef,uzgldrawcontext,
  uzeffdxfsupport,
  uzeentdevice,uzeentsubordinated,uzeentity,uzeentabstracttext,uzeenttext,
  uzeblockdef,uzeentmtext,uzeentwithlocalcs,uzeentblockinsert,
  uzeentityextender,uzeBaseExtender,uzbtypes,uzegeometrytypes,uzeconsts;

type
  TDummyDtawer=procedure(var IODXFContext:TIODXFContext;var outhandle:TZctnrVectorBytes;pEntity:PGDBObjEntity;const p1,p2:GDBvertex;const drawing:TDrawingDef;var DC:TDrawContext);
  TSmartTextEntExtender=class(TBaseEntityExtender)
  public
    const
      SmartTextEntExtenderName='extdrSmartTextEnt';
  private
    const
      ExtensionLineOffsetDef=0;
      ExtensionLeaderStartLengthDef=10;
      ExtensionHeightDef=0;
      BaseLineOffsetDef:GDBvertex2D=(x:-0.2;y:-0.2);
      //добавить это расширение к примитиву можно командой
      //extdrAdd(extdrSmartTextEnt)

      //выравнивание от смещения по осям
      JustifyWoLeader: array[-1..1{y},-1..1{x}] of TTextJustify = ((jsbl, jsbc, jsbr),(jsml, jsmc, jsmr),(jstl, jstc, jstr));
      //выравнивание от смещения по осям при черчении выноски
      JustifyWithLeader: array[-1..1{y},-1..1{x}] of TTextJustify = ((jsbl, jsbl, jsbr),(jsbl, jsbl, jsbr),(jsbl, jsbl, jsbr));
      //горизонтальное смещение от выравнивания
      j2hdir: array [TTextJustify] of ShortInt =(-1,0,1,-1,0,1,-1,0,1,-1,0,1);
      //вертикальное смещение от выравнивания
      j2vdir: array [TTextJustify] of ShortInt =(1,1,1,0,0,0,-1,-1,-1,-1,-1,-1);
    //private
    public
      FExtensionLine:Boolean;
      FBaseLine:Boolean;
      FBaseLineOffset:GDBvertex2D;
      FExtensionLineOffset:Double;
      FLeaderStartLength:Double;
      //FSaveHeight:Double;
      FHeightOverride:Double;
      FHJOverride:Boolean;
      FVJOverride:Boolean;
    private
      function isDefault:boolean;
      function getOwnerInsertPoint(pEntity:Pointer):GDBVertex;
      function getOwnerScale(pEntity:Pointer):Double;
      function getTextInsertPoint(pEntity:Pointer):GDBVertex;
      function getBaseLineStartPoint(pEntity:Pointer):GDBVertex;
      function getBaseLineOffset(pEntity:Pointer):GDBvertex2D;
      function getExtensionLinetStartPoint(pEntity:Pointer):GDBVertex;
      function getTangent(pEntity:Pointer):GDBVertex;
      function getNormal(pEntity:Pointer):GDBVertex;
      function isNeedLeadert(pEntity:Pointer):Boolean;
    public
      class function getExtenderName:string;override;
      constructor Create(pEntity:Pointer);override;
      procedure Assign(Source:TBaseExtender);override;
      procedure onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
      procedure onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
      procedure SaveToDxfObjXData(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);override;
      procedure SaveToDXFfollow(PEnt:Pointer;var outhandle:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext)override;
      procedure PostLoad(var context:TIODXFLoadContext);override;
      procedure onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);override;

      procedure DrawGeom(var IODXFContext:TIODXFContext;var outhandle:TZctnrVectorBytes;pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext;tdd:TDummyDtawer);

      class function EntIOLoadExtensionLine(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
      class function EntIOLoadBaseLine(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
      class function EntIOLoadExtensionLineOffset(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
      class function EntIOLoadExtensionLeaderStartLength(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
      class function EntIOLoadTextHeigth(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
      class function EntIOLoadHJOverride(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
      class function EntIOLoadVJOverride(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
      class function EntIOLoadBaseLineOffsetX(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
      class function EntIOLoadBaseLineOffsetY(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;

      class function EntIOLoadSmartTextEntExtenderDefault(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;

      //property ExtensionLine:Boolean read FExtensionLine write FExtensionLine default true;
      //property BaseLine:Boolean read FBaseLine write FBaseLine default true;
  end;

implementation

procedure DrawLine(var IODXFContext:TIODXFContext;var outhandle:TZctnrVectorBytes;pEntity:PGDBObjEntity;const p1,p2:GDBvertex;const drawing:TDrawingDef;var DC:TDrawContext);
begin
  pEntity.Representation.DrawLineWithLT(DC,p1,p2,pEntity.vp);
end;

procedure SaveLine(var IODXFContext:TIODXFContext;var outhandle:TZctnrVectorBytes;pEntity:PGDBObjEntity;const p1,p2:GDBvertex;const drawing:TDrawingDef;var DC:TDrawContext);
begin
  //SaveToDXFObjPrefix(outhandle,'LINE','AcDbLine',IODXFContext);

  dxfStringout(outhandle,0,dxfName_Line);

  dxfStringout(outhandle,5,inttohex(IODXFContext.handle, 0));
  inc(IODXFContext.handle);

  dxfStringout(outhandle,100,dxfName_AcDbEntity);
  dxfStringout(outhandle,8,pEntity^.vp.layer^.name);
  if pEntity^.vp.color<>ClByLayer then
                             dxfStringout(outhandle,62,inttostr(pEntity^.vp.color));
  if pEntity^.vp.lineweight<>-1 then dxfIntegerout(outhandle,370,pEntity^.vp.lineweight);

  dxfStringout(outhandle,100,dxfName_AcDbLine);
  if pEntity^.vp.LineType<>{''}nil then dxfStringout(outhandle,6,pEntity^.vp.LineType^.Name);
  if pEntity^.vp.LineTypeScale<>1 then dxfDoubleout(outhandle,48,pEntity^.vp.LineTypeScale);

  dxfvertexout(outhandle,10,p1);
  dxfvertexout(outhandle,11,p2);

  dxfStringout(outhandle,1001,'DSTP_XDATA');
  dxfStringout(outhandle,1002,'{');
  dxfStringout(outhandle,1000,'_OWNERHANDLE=6E');
  dxfStringout(outhandle,1002,'}');
end;


function TSmartTextEntExtender.isDefault:boolean;
begin
  result:=(FExtensionLine and FBaseLine)and(IsDoubleEqual(FExtensionLineOffset,ExtensionLineOffsetDef))
        and(IsDoubleEqual(FLeaderStartLength,ExtensionLeaderStartLengthDef))
        and(IsDoubleEqual(FHeightOverride,ExtensionHeightDef))
        and FHJOverride and FVJOverride and
        (IsDoubleEqual(FBaseLineOffset.x,BaseLineOffsetDef.x))and((IsDoubleEqual(FBaseLineOffset.y,BaseLineOffsetDef.y)))

end;

procedure TSmartTextEntExtender.Assign(Source:TBaseExtender);
begin
  FExtensionLine:=TSmartTextEntExtender(Source).FExtensionLine;
  FBaseLine:=TSmartTextEntExtender(Source).FBaseLine;
  FExtensionLineOffset:=TSmartTextEntExtender(Source).FExtensionLineOffset;
  FLeaderStartLength:=TSmartTextEntExtender(Source).FLeaderStartLength;
  FHeightOverride:=TSmartTextEntExtender(Source).FHeightOverride;
  FHJOverride:=TSmartTextEntExtender(Source).FHJOverride;
  FVJOverride:=TSmartTextEntExtender(Source).FVJOverride;
  FBaseLineOffset:=TSmartTextEntExtender(Source).FBaseLineOffset;
end;

constructor TSmartTextEntExtender.Create(pEntity:Pointer);
begin
  FExtensionLine:=true;
  FBaseLine:=true;
  FExtensionLineOffset:=ExtensionLineOffsetDef;
  FLeaderStartLength:=ExtensionLeaderStartLengthDef;
  FHeightOverride:=ExtensionHeightDef;
  FHJOverride:=true;
  FVJOverride:=true;
  FBaseLineOffset:=BaseLineOffsetDef;
end;

function TSmartTextEntExtender.getOwnerInsertPoint(pEntity:Pointer):GDBVertex;
begin
  result:=PGDBObjWithLocalCS(PGDBObjText(pEntity)^.bp.ListPos.Owner)^.P_insert_in_WCS;
end;

function TSmartTextEntExtender.getOwnerScale(pEntity:Pointer):Double;
begin
  if ESCalcWithoutOwner in PGDBObjEntity(pEntity)^.State then
    result:=1
  else
    result:=PGDBObjBlockInsert(PGDBObjText(pEntity)^.bp.ListPos.Owner)^.scale.y;
end;

function TSmartTextEntExtender.getTextInsertPoint(pEntity:Pointer):GDBVertex;
begin
  result:=PGDBObjText(pEntity).P_insert_in_WCS;
end;

function TSmartTextEntExtender.getBaseLineStartPoint(pEntity:Pointer):GDBVertex;
var
  t,n:GDBvertex;
begin
  result:=getTextInsertPoint(pEntity);
  with getBaseLineOffset(pEntity) do begin
    if PGDBObjMText(pEntity).textprop.justify in [jsbr,jsmr,jstr] then
      result:=result+getTangent(pEntity)*x
    else
      result:=result-getTangent(pEntity)*x;
    result:=result-getNormal(pEntity)*y;
  end;
end;

function TSmartTextEntExtender.getBaseLineOffset(pEntity:Pointer):GDBVertex2D;
begin
  result:=FBaseLineOffset;
  if result.x<0 then
    result.x:=-result.x*PGDBObjMText(pEntity).textprop.size*getOwnerScale(pEntity);
  if result.y<0 then
    result.y:=-result.y*PGDBObjMText(pEntity).textprop.size*getOwnerScale(pEntity);
end;

function TSmartTextEntExtender.getExtensionLinetStartPoint(pEntity:Pointer):GDBVertex;
var
  p1,p2:GDBvertex;
  scl:double;
begin
  p1:=getOwnerInsertPoint(pEntity);
  p2:=getBaseLineStartPoint(pEntity);
  scl:=FExtensionLineOffset*abs(getOwnerScale(pEntity));
  if FExtensionLineOffset>0 then
    result:=p1+(p2-p1).NormalizeVertex*scl
  else begin
    result:=p2-p1;
    if abs(result.x)>abs(result.y)then begin
      result.y:=-result.y*(scl/abs(result.x));
      result.x:=-result.x*(scl/abs(result.x));
    end else begin
      result.x:=-result.x*(scl/abs(result.y));
      result.y:=-result.y*(scl/abs(result.y));
    end;
    result:=p1+result;
  end;
end;

function TSmartTextEntExtender.isNeedLeadert(pEntity:Pointer):Boolean;
begin
  result:=(Vertexlength(getOwnerInsertPoint(pEntity),getTextInsertPoint(pEntity))>FLeaderStartLength)and(FExtensionLine or FBaseLine)
end;

function TSmartTextEntExtender.getTangent(pEntity:Pointer):GDBVertex;
begin
  Result:=PGDBvertex(@PGDBObjMText(pEntity)^.ObjMatrix[0])^.NormalizeVertex;
end;

function TSmartTextEntExtender.getNormal(pEntity:Pointer):GDBVertex;
begin
  Result:=PGDBvertex(@PGDBObjMText(pEntity)^.ObjMatrix[1])^.NormalizeVertex;
end;

procedure TSmartTextEntExtender.DrawGeom(var IODXFContext:TIODXFContext;var outhandle:TZctnrVectorBytes;pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext;tdd:TDummyDtawer);
var
  dx:Double;
  p,pnew,dir,normal:GDBvertex;
  offs:GDBvertex2D;
  i:integer;
begin
  //if FHeightOverride>0 then
  //  PGDBObjMText(pEntity).textprop.size:=FSaveHeight;
  if (typeof(PGDBObjEntity(pEntity)^)=TypeOf(GDBObjText))or(typeof(PGDBObjEntity(pEntity)^)=TypeOf(GDBObjMText)) then
    if PGDBObjText(pEntity)^.bp.ListPos.Owner<>nil then
      if typeof(PGDBObjText(pEntity)^.bp.ListPos.Owner^)=TypeOf(GDBObjDevice) then begin
        if isNeedLeadert(pEntity) then begin
          p:=getBaseLineStartPoint(pEntity);
          if FExtensionLine then
            tdd(IODXFContext,outhandle,pEntity,getExtensionLinetStartPoint(pEntity),p,drawing,DC);
          if FBaseLine then begin
            dx:=PGDBObjText(pEntity).obj_width*PGDBObjMText(pEntity).textprop.size*PGDBObjMText(pEntity).textprop.wfactor*getOwnerScale(pEntity);
            offs:=getBaseLineOffset(pEntity);
            if PGDBObjMText(pEntity).textprop.justify in [jsbr,jsmr,jstr] then
              dx:=-dx-2*offs.x
            else
              dx:=dx+2*offs.x;
            dir:=getTangent(pEntity)*dx;
            tdd(IODXFContext,outhandle,pEntity,p,VertexAdd(p,{CreateVertex(dx,0,0)}dir),drawing,DC);
            if typeof(PGDBObjEntity(pEntity)^)=TypeOf(GDBObjMText) then
              if PGDBObjMText(pEntity).text.Count>1 then begin
                normal:=getNormal(pEntity)*pGDBObjMText(pEntity).linespace*getOwnerScale(pEntity);
                for i:=2 to PGDBObjMText(pEntity).text.Count do begin
                  pnew:=VertexAdd(p,normal);
                  tdd(IODXFContext,outhandle,pEntity,p,pnew,drawing,DC);
                  tdd(IODXFContext,outhandle,pEntity,pnew,VertexAdd(pnew,dir),drawing,DC);
                  p:=pnew;
                end;
              end;
          end;
        end;
      end;
end;



procedure TSmartTextEntExtender.onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
  DrawGeom(PTIODXFContext(nil)^,PTZctnrVectorBytes(nil)^,pEntity,drawing,DC,DrawLine);
end;

procedure TSmartTextEntExtender.onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
  function getXsign(p:GDBvertex):integer;
  begin
    result:=sign(p.x);
  end;
  function getYsign(p:GDBvertex):integer;
  begin
    result:=sign(p.y);
  end;
begin
  if (typeof(PGDBObjEntity(pEntity)^)=TypeOf(GDBObjText))or(typeof(PGDBObjEntity(pEntity)^)=TypeOf(GDBObjMText)) then begin
    if FHJOverride or FVJOverride then
      if FHJOverride and FVJOverride then begin
        if isNeedLeadert(pEntity) then
          PGDBObjMText(pEntity).textprop.justify:=JustifyWithLeader[-getYsign(PGDBObjText(pEntity).Local.P_insert),-getXsign(PGDBObjText(pEntity).Local.P_insert)]
        else
          PGDBObjMText(pEntity).textprop.justify:=JustifyWoLeader[-getYsign(PGDBObjText(pEntity).Local.P_insert),-getXsign(PGDBObjText(pEntity).Local.P_insert)]
      end else if FVJOverride then begin
        if isNeedLeadert(pEntity) then
          PGDBObjMText(pEntity).textprop.justify:=JustifyWithLeader[-getYsign(PGDBObjText(pEntity).Local.P_insert),j2hdir[PGDBObjMText(pEntity).textprop.justify]]
        else
          PGDBObjMText(pEntity).textprop.justify:=JustifyWoLeader[-getYsign(PGDBObjText(pEntity).Local.P_insert),j2hdir[PGDBObjMText(pEntity).textprop.justify]]
      end else{if FHJOverride}begin
        if isNeedLeadert(pEntity) then
          PGDBObjMText(pEntity).textprop.justify:=JustifyWithLeader[j2vdir[PGDBObjMText(pEntity).textprop.justify],-getXsign(PGDBObjText(pEntity).Local.P_insert)]
        else
          PGDBObjMText(pEntity).textprop.justify:=JustifyWoLeader[j2vdir[PGDBObjMText(pEntity).textprop.justify],-getXsign(PGDBObjText(pEntity).Local.P_insert)]
      end;
    if FHeightOverride>0 then begin
      PGDBObjMText(pEntity).textprop.size:=FHeightOverride/getOwnerScale(pEntity);
    end;
  end;
end;

class function TSmartTextEntExtender.getExtenderName:string;
begin
  result:=SmartTextEntExtenderName;
end;

procedure TSmartTextEntExtender.SaveToDxfObjXData(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);
begin
  if isDefault then
    dxfStringout(outhandle,1000,'SmartTextEntExtenderDefault=TRUE')
  else
    begin
      if not FExtensionLine then
        dxfStringout(outhandle,1000,'STEExtensionLine=FALSE');
      if not FBaseLine then
        dxfStringout(outhandle,1000,'STEBaseLineLine=FALSE');
      if not IsDoubleEqual(FExtensionLineOffset,ExtensionLineOffsetDef)then
        dxfStringout(outhandle,1000,'STEExtensionLineOffset='+FloatToStr(FExtensionLineOffset));
      if not IsDoubleEqual(FLeaderStartLength,ExtensionLeaderStartLengthDef)then
        dxfStringout(outhandle,1000,'STELeaderStartLength='+FloatToStr(FLeaderStartLength));
      if not IsDoubleEqual(FHeightOverride,ExtensionHeightDef)then
        dxfStringout(outhandle,1000,'STEHeightOverride='+FloatToStr(FHeightOverride));
      if not FHJOverride then
        dxfStringout(outhandle,1000,'STEHJOverride=FALSE');
      if not FVJOverride then
        dxfStringout(outhandle,1000,'STEVJOverride=FALSE');
      if not IsDoubleEqual(FBaseLineOffset.x,BaseLineOffsetDef.x)then
        dxfStringout(outhandle,1000,'STEBaseLineOffsetX='+FloatToStr(FBaseLineOffset.x));
      if not IsDoubleEqual(FBaseLineOffset.y,BaseLineOffsetDef.y)then
        dxfStringout(outhandle,1000,'STEBaseLineOffsetY='+FloatToStr(FBaseLineOffset.y));
    end;
end;
procedure TSmartTextEntExtender.SaveToDXFfollow(PEnt:Pointer;var outhandle:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);
begin
  DrawGeom(IODXFContext,outhandle,PGDBObjEntity(PEnt),drawing,PTDrawContext(nil)^,SaveLine);
end;

function AddSmartTextEntExtenderToEntity(PEnt:PGDBObjEntity):TSmartTextEntExtender;
begin
  result:=TSmartTextEntExtender.Create(PEnt);
  PEnt^.AddExtension(result);
end;


class function TSmartTextEntExtender.EntIOLoadExtensionLine(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  STEExtdr.FExtensionLine:=false;
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadBaseLine(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  STEExtdr.FBaseLine:=false;
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadExtensionLineOffset(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  STEExtdr.FExtensionLineOffset:=StrToFloat(_Value);
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadExtensionLeaderStartLength(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  STEExtdr.FLeaderStartLength:=StrToFloat(_Value);
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadTextHeigth(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  STEExtdr.FHeightOverride:=StrToFloat(_Value);
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadBaseLineOffsetX(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  STEExtdr.FBaseLineOffset.x:=StrToFloat(_Value);
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadBaseLineOffsetY(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  STEExtdr.FBaseLineOffset.y:=StrToFloat(_Value);
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadHJOverride(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  STEExtdr.FHJOverride:=false;
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadVJOverride(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  STEExtdr.FVJOverride:=false;
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadSmartTextEntExtenderDefault(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  result:=true;
end;

procedure TSmartTextEntExtender.PostLoad(var context:TIODXFLoadContext);
begin
end;


procedure TSmartTextEntExtender.onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
begin
end;

initialization
  EntityExtenders.RegisterKey(uppercase(TSmartTextEntExtender.SmartTextEntExtenderName),TSmartTextEntExtender);

  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEExtensionLine',TSmartTextEntExtender.EntIOLoadExtensionLine);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEBaseLineLine',TSmartTextEntExtender.EntIOLoadBaseLine);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEExtensionLineOffset',TSmartTextEntExtender.EntIOLoadExtensionLineOffset);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STELeaderStartLength',TSmartTextEntExtender.EntIOLoadExtensionLeaderStartLength);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEHeightOverride',TSmartTextEntExtender.EntIOLoadTextHeigth);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEHJOverride',TSmartTextEntExtender.EntIOLoadHJOverride);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEVJOverride',TSmartTextEntExtender.EntIOLoadVJOverride);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEBaseLineOffsetX',TSmartTextEntExtender.EntIOLoadBaseLineOffsetX);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEBaseLineOffsetY',TSmartTextEntExtender.EntIOLoadBaseLineOffsetY);

  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('SmartTextEntExtenderDefault',TSmartTextEntExtender.EntIOLoadSmartTextEntExtenderDefault);
finalization
end.

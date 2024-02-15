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
//добавить/удалить это расширение к примитиву можно командой
//extdrAdd(extdrSmartTextEnt)/extdrRemove(extdrSmartTextEnt)

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
    type
      PDir2J=^TDir2J;
      TDir2J=array[-1..1{x},-1..1{y}] of TTextJustify;
    const
      ExtensionLineStartShiftDef=1;
      ExtensionLeaderStartDrawDist=10;
      ExtensionTextHeightOverrideDef=0;
      BaseLineOffsetDef:GDBvertex2D=(x:-0.2;y:-0.2);
      RotateOverrideValueDef=0;

      //выравнивание от смещения по осям
      dir2j:TDir2J            = ((jsbl,jsml,jstl),(jsbc,jsmc,jstc),(jsbr,jsmr,jstr));
      //выравнивание от смещения по осям при черчении выноски
      dir2j_TextLeader:TDir2J = ((jsbl,jsbl,jsbl),(jsbl,jsbl,jsbl),(jsbr,jsbr,jsbr));
      //выравнивание от смещения по осям при черчении выноски для 2хстрочного мтекста
      dir2j_2LineLeader:TDir2J = ((jsmc,jsmc,jsmc),(jsmc,jsmc,jsmc),(jsmc,jsmc,jsmc));
      //горизонтальное смещение от выравнивания
      j2hdir: array [TTextJustify] of ShortInt =(-1,0,1,-1,0,1,-1,0,1,-1,0,1);
      //вертикальное смещение от выравнивания
      j2vdir: array [TTextJustify] of ShortInt =(1,1,1,0,0,0,-1,-1,-1,-1,-1,-1);
    //private
    public
      FLeaderStartDrawDist:Double;

      FExtensionLine:Boolean;
      FExtensionLineStartShift:Double;

      FBaseLine:Boolean;
      FBaseLineOffset:GDBvertex2D;

      FTextHeightOverride:Double;
      FHJOverride:Boolean;
      FVJOverride:Boolean;
      FRotateOverrideValue:Double;
      FRotateOverride:Boolean;
    private
      function isDefault:boolean;
      function getOwnerInsertPoint(pEntity:Pointer):GDBVertex;
      function getOwnerScale(pEntity:Pointer):Double;

      function getTextInsertPoint(pEntity:Pointer):GDBVertex;
      function getTextLinesCount(pEntity:Pointer):Integer;
      function getTextTangent(pEntity:Pointer):GDBVertex;
      function getTextNormal(pEntity:Pointer):GDBVertex;
      function getTextHeight(pEntity:Pointer):Double;
      function getTextWFactor(pEntity:Pointer):Double;

      function getBaseLineStartPoint(pEntity:Pointer):GDBVertex;
      function getBaseLineOffset(pEntity:Pointer):GDBvertex2D;
      function getExtensionLinetStartPoint(pEntity:Pointer):GDBVertex;

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
      procedure onRemoveFromArray(pEntity:Pointer;const drawing:TDrawingDef);override;

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
      class function EntIOLoadRotateOverride(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
      class function EntIOLoadRotateOverrideValue(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;

      class function EntIOLoadSmartTextEntExtenderDefault(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;

      class function CanBeAddedTo(pEntity:Pointer):Boolean;override;

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

class function TSmartTextEntExtender.CanBeAddedTo(pEntity:Pointer):Boolean;
var
  pt:pointer;
begin
  pt:=typeof(PGDBObjEntity(pEntity)^);
  result:=(pt=TypeOf(GDBObjText))or(pt=TypeOf(GDBObjMText));
end;

function TSmartTextEntExtender.isDefault:boolean;
begin
  result:=(FExtensionLine and FBaseLine)and(IsDoubleEqual(FExtensionLineStartShift,ExtensionLineStartShiftDef))
        and(IsDoubleEqual(FLeaderStartDrawDist,ExtensionLeaderStartDrawDist))
        and(IsDoubleEqual(FTextHeightOverride,ExtensionTextHeightOverrideDef))
        and FHJOverride and FVJOverride
        and(IsDoubleEqual(FBaseLineOffset.x,BaseLineOffsetDef.x))and((IsDoubleEqual(FBaseLineOffset.y,BaseLineOffsetDef.y)))
        and FRotateOverride and (IsDoubleEqual(FRotateOverrideValue,RotateOverrideValueDef));
end;

procedure TSmartTextEntExtender.Assign(Source:TBaseExtender);
begin
  FExtensionLine:=TSmartTextEntExtender(Source).FExtensionLine;
  FBaseLine:=TSmartTextEntExtender(Source).FBaseLine;
  FExtensionLineStartShift:=TSmartTextEntExtender(Source).FExtensionLineStartShift;
  FLeaderStartDrawDist:=TSmartTextEntExtender(Source).FLeaderStartDrawDist;
  FTextHeightOverride:=TSmartTextEntExtender(Source).FTextHeightOverride;
  FHJOverride:=TSmartTextEntExtender(Source).FHJOverride;
  FVJOverride:=TSmartTextEntExtender(Source).FVJOverride;
  FBaseLineOffset:=TSmartTextEntExtender(Source).FBaseLineOffset;
  FRotateOverrideValue:=TSmartTextEntExtender(Source).FRotateOverrideValue;
  FRotateOverride:=TSmartTextEntExtender(Source).FRotateOverride;
end;

constructor TSmartTextEntExtender.Create(pEntity:Pointer);
begin
  FExtensionLine:=true;
  FBaseLine:=true;
  FExtensionLineStartShift:=ExtensionLineStartShiftDef;
  FLeaderStartDrawDist:=ExtensionLeaderStartDrawDist;
  FTextHeightOverride:=ExtensionTextHeightOverrideDef;
  FHJOverride:=true;
  FVJOverride:=true;
  FBaseLineOffset:=BaseLineOffsetDef;
  FRotateOverrideValue:=RotateOverrideValueDef;
  FRotateOverride:=true;
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

function TSmartTextEntExtender.getTextLinesCount(pEntity:Pointer):Integer;
begin
  if typeof(PGDBObjEntity(pEntity)^)=TypeOf(GDBObjText) then
    result:=1
  else
    result:=PGDBObjMText(pEntity).text.Count;
end;

function getXsign(p:GDBvertex):integer;
begin
  result:=-sign(p.x);
end;
function getYsign(p:GDBvertex):integer;
begin
  result:=-sign(p.y);
end;

function TSmartTextEntExtender.getBaseLineStartPoint(pEntity:Pointer):GDBVertex;
var
  t,n:GDBvertex;
  dx:double;
begin
  result:=getTextInsertPoint(pEntity);
  t:=getTextTangent(pEntity);
  if PGDBObjMText(pEntity).textprop.justify in [jsbc,jsmc,jstc] then begin
    dx:=PGDBObjText(pEntity).obj_width*getTextHeight(pEntity)*getTextWFactor(pEntity)*getOwnerScale(pEntity)/2;
    if -sign((PGDBObjText(pEntity).P_insert_in_WCS-getOwnerInsertPoint(pEntity))*getTextTangent(pEntity))<0 then begin
      result:=result-t*dx;
    end else begin
      result:=result+t*dx;
      t:=-t;
    end;
  end;
  with getBaseLineOffset(pEntity) do begin
    if PGDBObjMText(pEntity).textprop.justify in [jsbr,jsmr,jstr] then
      result:=result+t*x
    else
      result:=result-t*x;
    result:=result-getTextNormal(pEntity)*y;
  end;
end;

function TSmartTextEntExtender.getBaseLineOffset(pEntity:Pointer):GDBVertex2D;
begin
  result:=FBaseLineOffset;
  if result.x<0 then
    result.x:=-result.x*getTextHeight(pEntity)*getOwnerScale(pEntity);
  if result.y<0 then begin
    if getTextLinesCount(pEntity)=2 then
      result.y:=0
    else
      result.y:=-result.y*getTextHeight(pEntity)*getOwnerScale(pEntity);
  end;
end;

function TSmartTextEntExtender.getExtensionLinetStartPoint(pEntity:Pointer):GDBVertex;
var
  p1,p2:GDBvertex;
  scl:double;
begin
  p1:=getOwnerInsertPoint(pEntity);
  p2:=getBaseLineStartPoint(pEntity);
  scl:=FExtensionLineStartShift*abs(getOwnerScale(pEntity));
  if FExtensionLineStartShift>0 then
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
  result:=((Vertexlength(getOwnerInsertPoint(pEntity),getTextInsertPoint(pEntity))/getOwnerScale(pEntity))>FLeaderStartDrawDist)and(FExtensionLine or FBaseLine)
end;

function TSmartTextEntExtender.getTextTangent(pEntity:Pointer):GDBVertex;
begin
  Result:=PGDBvertex(@PGDBObjMText(pEntity)^.ObjMatrix[0])^.NormalizeVertex;
end;

function TSmartTextEntExtender.getTextNormal(pEntity:Pointer):GDBVertex;
begin
  Result:=PGDBvertex(@PGDBObjMText(pEntity)^.ObjMatrix[1])^.NormalizeVertex;
end;

function TSmartTextEntExtender.getTextHeight(pEntity:Pointer):Double;
begin
  result:=PGDBObjMText(pEntity).textprop.size;
end;

function TSmartTextEntExtender.getTextWFactor(pEntity:Pointer):Double;
begin
  if typeof(PGDBObjEntity(pEntity)^)=TypeOf(GDBObjText) then
    result:=PGDBObjText(pEntity).textprop.wfactor
  else
    result:=PGDBObjMText(pEntity).TXTStyleIndex^.prop.wfactor;
end;

procedure TSmartTextEntExtender.DrawGeom(var IODXFContext:TIODXFContext;var outhandle:TZctnrVectorBytes;pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext;tdd:TDummyDtawer);
var
  dx:Double;
  p,pnew,dir,normal:GDBvertex;
  offs:GDBvertex2D;
  i:integer;
begin
  //if FTextHeightOverride>0 then
  //  PGDBObjMText(pEntity).textprop.size:=FSaveHeight;
  if (typeof(PGDBObjEntity(pEntity)^)=TypeOf(GDBObjText))or(typeof(PGDBObjEntity(pEntity)^)=TypeOf(GDBObjMText)) then
    if PGDBObjText(pEntity)^.bp.ListPos.Owner<>nil then
      if typeof(PGDBObjText(pEntity)^.bp.ListPos.Owner^)=TypeOf(GDBObjDevice) then begin
        if isNeedLeadert(pEntity) then begin
          p:=getBaseLineStartPoint(pEntity);
          if FExtensionLine then
            tdd(IODXFContext,outhandle,pEntity,getExtensionLinetStartPoint(pEntity),p,drawing,DC);
          if FBaseLine then begin
            dx:=PGDBObjText(pEntity).obj_width*getTextHeight(pEntity)*getTextWFactor(pEntity)*getOwnerScale(pEntity);
            offs:=getBaseLineOffset(pEntity);
            if PGDBObjMText(pEntity).textprop.justify in [jsmc] then begin
              if -sign((PGDBObjText(pEntity).P_insert_in_WCS-getOwnerInsertPoint(pEntity))*getTextTangent(pEntity))<0 then
                dx:=dx+2*offs.x
              else
                dx:=-dx-2*offs.x;
            end else if PGDBObjMText(pEntity).textprop.justify in [jsbr,jsmr,jstr] then
              dx:=-dx-2*offs.x
            else
              dx:=dx+2*offs.x;
            dir:=getTextTangent(pEntity)*dx;
            tdd(IODXFContext,outhandle,pEntity,p,VertexAdd(p,{CreateVertex(dx,0,0)}dir),drawing,DC);
            if typeof(PGDBObjEntity(pEntity)^)=TypeOf(GDBObjMText) then
              if PGDBObjMText(pEntity).text.Count>2 then begin
                normal:=getTextNormal(pEntity)*pGDBObjMText(pEntity).linespace*getOwnerScale(pEntity);
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
  if ESCalcWithoutOwner in PGDBObjEntity(pEntity)^.State then
    exit;
  DrawGeom(PTIODXFContext(nil)^,PTZctnrVectorBytes(nil)^,pEntity,drawing,DC,DrawLine);
end;

procedure TSmartTextEntExtender.onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  currXDir,currYDir,newXDir,newYDir:integer;
  PD2J:PDir2J;
  v1,v2:GDBVertex;
  l0:Double;
  a:double;
begin
  if ESCalcWithoutOwner in PGDBObjEntity(pEntity)^.State then
    exit;
  if (typeof(PGDBObjEntity(pEntity)^)=TypeOf(GDBObjText))or(typeof(PGDBObjEntity(pEntity)^)=TypeOf(GDBObjMText)) then begin
    if FRotateOverride then begin
      if PGDBObjEntity(pEntity)^.bp.ListPos.owner<>nil then begin

        if PGDBObjEntity(pEntity)^.bp.ListPos.owner<>nil then begin
          V1:=PGDBvertex(@PGDBObjEntity(pEntity)^.bp.ListPos.owner^.GetMatrix^[0])^;
          a:=FRotateOverrideValue*pi/180;
          l0:=scalardot(NormalizeVertex(V1),createvertex(cos(a),sin(a),0));
          l0:=arccos(l0);
          if v1.y<-eps then l0:=2*pi-l0;
        end else
          l0:=a;
        if (abs(PGDBObjText(pEntity)^.Local.basis.oz.x) < 1/64)and(abs(PGDBObjText(pEntity)^.Local.basis.oz.y)<1/64) then
          PGDBObjText(pEntity)^.Local.basis.ox:=CrossVertex(YWCS,PGDBObjText(pEntity)^.Local.basis.oz)
        else
          PGDBObjText(pEntity)^.Local.basis.ox:=CrossVertex(ZWCS,PGDBObjText(pEntity)^.Local.basis.oz);
        PGDBObjText(pEntity)^.local.basis.OX:=VectorTransform3D(PGDBObjText(pEntity)^.local.basis.OX,uzegeometry.CreateAffineRotationMatrix(PGDBObjText(pEntity)^.Local.basis.oz,l0));

      end;
    end;
    if FHJOverride or FVJOverride then begin
      currXDir:=j2hdir[PGDBObjMText(pEntity).textprop.justify];
      currYDir:=j2vdir[PGDBObjMText(pEntity).textprop.justify];
      v1:=PGDBObjText(pEntity).P_insert_in_WCS-getOwnerInsertPoint(pEntity);
      newXDir:=-sign(v1*getTextTangent(pEntity));//getXsign({PGDBObjText(pEntity).Local.P_insert}v1);
      newYDir:=-sign(v1*getTextNormal(pEntity));//getYsign({PGDBObjText(pEntity).Local.P_insert}v1);
      if isNeedLeadert(pEntity) then begin
        case getTextLinesCount(pEntity) of
          1:PD2J:=@dir2j_TextLeader;
          2:PD2J:=@dir2j_2LineLeader;
       else PD2J:=@dir2j_TextLeader;
        end;
      end else
        PD2J:=@dir2j;
      if FHJOverride and FVJOverride then begin
        PGDBObjMText(pEntity).textprop.justify:=PD2J^[newXDir,newYDir]
      end else if FVJOverride then begin
        PGDBObjMText(pEntity).textprop.justify:=PD2J^[currXDir,newYDir]
      end else{if FHJOverride}begin
        PGDBObjMText(pEntity).textprop.justify:=PD2J^[newXDir,currYDir]
      end;
    end;
    if FTextHeightOverride>0 then begin
      PGDBObjMText(pEntity).textprop.size:=FTextHeightOverride/getOwnerScale(pEntity);
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
    dxfStringout(outhandle,1000,'STEDefault=TRUE')
  else
    begin
      if not FExtensionLine then
        dxfStringout(outhandle,1000,'STEExtensionLine=FALSE');
      if not FBaseLine then
        dxfStringout(outhandle,1000,'STEBaseLineLine=FALSE');
      if not IsDoubleEqual(FExtensionLineStartShift,ExtensionLineStartShiftDef)then
        dxfStringout(outhandle,1000,'STEExtensionLineStartShift='+FloatToStr(FExtensionLineStartShift));
      if not IsDoubleEqual(FLeaderStartDrawDist,ExtensionLeaderStartDrawDist)then
        dxfStringout(outhandle,1000,'STELeaderStartDrawDist='+FloatToStr(FLeaderStartDrawDist));
      if not IsDoubleEqual(FTextHeightOverride,ExtensionTextHeightOverrideDef)then
        dxfStringout(outhandle,1000,'STETextHeightOverride='+FloatToStr(FTextHeightOverride));
      if not FHJOverride then
        dxfStringout(outhandle,1000,'STEHJOverride=FALSE');
      if not FVJOverride then
        dxfStringout(outhandle,1000,'STEVJOverride=FALSE');
      if not IsDoubleEqual(FBaseLineOffset.x,BaseLineOffsetDef.x)then
        dxfStringout(outhandle,1000,'STEBaseLineOffsetX='+FloatToStr(FBaseLineOffset.x));
      if not IsDoubleEqual(FBaseLineOffset.y,BaseLineOffsetDef.y)then
        dxfStringout(outhandle,1000,'STEBaseLineOffsetY='+FloatToStr(FBaseLineOffset.y));
      if not FRotateOverride then
        dxfStringout(outhandle,1000,'STERotateOverride=FALSE');
      if not IsDoubleEqual(FRotateOverrideValue,RotateOverrideValueDef)then
        dxfStringout(outhandle,1000,'STERotateOverrideValue='+FloatToStr(FRotateOverrideValue));
    end;
end;
procedure TSmartTextEntExtender.SaveToDXFfollow(PEnt:Pointer;var outhandle:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);
begin
  DrawGeom(IODXFContext,outhandle,PGDBObjEntity(PEnt),drawing,PTDrawContext(nil)^,SaveLine);
end;

function AddSmartTextEntExtenderToEntity(PEnt:PGDBObjEntity):TSmartTextEntExtender;
begin
  if TSmartTextEntExtender.CanBeAddedTo(PEnt) then begin
    result:=TSmartTextEntExtender.Create(PEnt);
    PEnt^.AddExtension(result);
  end else
    result:=nil;
end;


class function TSmartTextEntExtender.EntIOLoadExtensionLine(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  if STEExtdr<>nil then
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
  if STEExtdr<>nil then
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
  if STEExtdr<>nil then
    STEExtdr.FExtensionLineStartShift:=StrToFloat(_Value);
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadExtensionLeaderStartLength(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  if STEExtdr<>nil then
    STEExtdr.FLeaderStartDrawDist:=StrToFloat(_Value);
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadTextHeigth(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  if STEExtdr<>nil then
    STEExtdr.FTextHeightOverride:=StrToFloat(_Value);
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadBaseLineOffsetX(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  if STEExtdr<>nil then
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
  if STEExtdr<>nil then
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
  if STEExtdr<>nil then
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
  if STEExtdr<>nil then
    STEExtdr.FVJOverride:=false;
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadRotateOverride(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  if STEExtdr<>nil then
    STEExtdr.FRotateOverride:=false;
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadRotateOverrideValue(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  if STEExtdr<>nil then
    STEExtdr.FRotateOverrideValue:=StrToFloat(_Value);
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadSmartTextEntExtenderDefault(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  if STEExtdr<>nil then
    result:=true;
end;

procedure TSmartTextEntExtender.PostLoad(var context:TIODXFLoadContext);
begin
end;


procedure TSmartTextEntExtender.onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
begin
end;

procedure TSmartTextEntExtender.onRemoveFromArray(pEntity:Pointer;const drawing:TDrawingDef);
begin
end;

initialization
  EntityExtenders.RegisterKey(uppercase(TSmartTextEntExtender.SmartTextEntExtenderName),TSmartTextEntExtender);

  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEExtensionLine',TSmartTextEntExtender.EntIOLoadExtensionLine);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEBaseLineLine',TSmartTextEntExtender.EntIOLoadBaseLine);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEExtensionLineStartShift',TSmartTextEntExtender.EntIOLoadExtensionLineOffset);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STELeaderStartDrawDist',TSmartTextEntExtender.EntIOLoadExtensionLeaderStartLength);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STETextHeightOverride',TSmartTextEntExtender.EntIOLoadTextHeigth);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEHJOverride',TSmartTextEntExtender.EntIOLoadHJOverride);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEVJOverride',TSmartTextEntExtender.EntIOLoadVJOverride);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEBaseLineOffsetX',TSmartTextEntExtender.EntIOLoadBaseLineOffsetX);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEBaseLineOffsetY',TSmartTextEntExtender.EntIOLoadBaseLineOffsetY);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STERotateOverride',TSmartTextEntExtender.EntIOLoadRotateOverride);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STERotateOverrideValue',TSmartTextEntExtender.EntIOLoadRotateOverrideValue);

  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEDefault',TSmartTextEntExtender.EntIOLoadSmartTextEntExtenderDefault);
finalization
end.

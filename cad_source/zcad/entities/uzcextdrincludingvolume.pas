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
unit uzcExtdrIncludingVolume;
{$INCLUDE zengineconfig.inc}

interface
uses
  sysutils,UGDBObjBlockdefArray,uzedrawingdef,uzeExtdrAbstractEntityExtender,
  uzeExtdrBaseEntityExtender,
  uzeentsubordinated,uzeentgenericsubentry,uzeentity,
  uzeentdevice,uzeentabstracttext,uzeentwithmatrix,uzeentlwpolyline,
  uzeentpolyline,uzeentcurve,
  uzeenttext,uzeentblockinsert,
  uzsbTypeDescriptors,uzctnrVectorBytesStream,
  uzbBaseUtils,uzeTypes,uzeblockdef,
  uzsbVarmanDef,Varman,UUnitManager,URecordDescriptor,UBaseTypeDescriptor,
  usimplegenerics,uzeffdxfsupport,uzbpaths,uzcTranslations,
  gzctnrVectorTypes,uzeBaseExtender,uzeconsts,uzgldrawcontext,
  UGDBOpenArrayOfPV,UGDBPoint3DArray,UGDBPolyLine2DArray,
  uzegeometry,
  uzcEnitiesVariablesExtender,gzctnrVectorc,uzegeometrytypes;
const
  IncludingVolumeExtenderName='extdrIncludingVolume';
type

  TIncludingVolumeExtender=class;

  TVolumes=GZVectorc<TIncludingVolumeExtender>;

  TVolumesExtender=class(TBaseEntityExtender)
    Volumes:TVolumes;
    constructor Create(pEntity:Pointer);override;
    destructor Destroy;override;
    procedure AddVolume(V:TIncludingVolumeExtender);
    procedure RemoveVolume(V:TIncludingVolumeExtender);
    procedure onConnectFormattedEntsToRoot(pRootEntity,pFormattedEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
  end;


TIncludingVolumeExtender=class(TBaseEntityExtender)
    toBoundMatrix:TzeTypedMatrix4d;
    InsideEnts:GDBObjOpenArrayOfPV;
    class function getExtenderName:string;override;
    constructor Create(pEntity:Pointer);override;
    destructor Destroy;override;

    procedure Assign(Source:TBaseExtender);override;

    procedure onRemoveFromArray(pEntity:Pointer;const drawing:TDrawingDef);override;
    procedure onEntityClone(pSourceEntity,pDestEntity:pointer);override;
    procedure onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);override;
    procedure onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
    procedure onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
    procedure CopyExt2Ent(pSourceEntity,pDestEntity:pointer);override;
    procedure ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);override;
    procedure PostLoad(var context:TIODXFLoadContext);override;
    procedure onEntityConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;

    function CreateCounturArray:PGDBPolyline2DArray;
    procedure DestroyCounturArray(ACA:PGDBPolyline2DArray);

    procedure TryConnectToEnts(var Objects:GDBObjOpenArrayOfPV;const drawing:TDrawingDef;var DC:TDrawContext);
    procedure ConnectToEnt(p:PGDBObjEntity;var VolumeVExtdr,EntityExtender:TVariablesExtender;const drawing:TDrawingDef;var DC:TDrawContext);
    procedure CheckEnt(p:PGDBObjEntity;CA:PGDBPolyline2DArray;var VolumeVExtdr:TVariablesExtender;const drawing:TDrawingDef;var DC:TDrawContext);

    procedure onEntityBeforeConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;

    procedure onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);override;


    class function EntIOLoadIncludingVolumeExtender(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;

    procedure SaveToDxfObjXData(var outStream:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFSaveContext);override;

    procedure SetRoot(pEntity:Pointer;pNewRoot:Pointer);override;
  end;

function AddVolumeExtenderToEntity(PEnt:PGDBObjEntity):TIncludingVolumeExtender;

implementation

constructor TVolumesExtender.Create(pEntity:Pointer);
begin
  inherited;
  Volumes:=TVolumes.Create(10);
end;
destructor TVolumesExtender.Destroy;
begin
  Volumes.Clear;
  Volumes.Destroy;
end;
procedure TVolumesExtender.AddVolume(V:TIncludingVolumeExtender);
begin
  Volumes.PushBackData(V);
end;

procedure TVolumesExtender.RemoveVolume(V:TIncludingVolumeExtender);
var i:integer;
begin
  for i:=0 to Volumes.count-1 do
    if Volumes.parray[i]=V then begin
      Volumes.DeleteElement(i);
      exit;
    end;
end;
procedure TVolumesExtender.onConnectFormattedEntsToRoot(pRootEntity,pFormattedEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var i:integer;
  VolumeVExtdr:TVariablesExtender;
  CA:PGDBPolyline2DArray;
begin
  for i:=0 to Volumes.count-1 do begin
    VolumeVExtdr:=nil;
    CA:=Volumes.getData(i).CreateCounturArray;
    Volumes.getData(i).CheckEnt(pFormattedEntity,CA,VolumeVExtdr,drawing,DC);
    Volumes.getData(i).DestroyCounturArray(CA);
  end;
end;

function AddVolumeExtenderToEntity(PEnt:PGDBObjEntity):TIncludingVolumeExtender;
begin
     result:=TIncludingVolumeExtender.Create(PEnt);
     PEnt^.AddExtension(result);
end;
procedure TIncludingVolumeExtender.onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
begin
end;

procedure TIncludingVolumeExtender.SetRoot(pEntity:Pointer;pNewRoot:Pointer);
var
  root:PGDBObjSubordinated;
  rve:TVolumesExtender;
begin
  if pThisEntity<>nil then begin
    root:=pThisEntity^.GetMainOwner;
    if root<>nil then begin
      rve:=root^.GetExtension<TVolumesExtender>;
      if rve<>nil then
        rve.RemoveVolume(self);
    end;
  end;
  if pNewRoot<>nil then begin
    rve:=PGDBObjSubordinated(pNewRoot)^.GetExtension<TVolumesExtender>;
    if rve=nil then begin
      rve:=TVolumesExtender.Create(root);
      PGDBObjSubordinated(pNewRoot)^.AddExtension(rve);
    end;
    rve.AddVolume(self);
   end;

end;

procedure TIncludingVolumeExtender.onRemoveFromArray(pEntity:Pointer;const drawing:TDrawingDef);
var
  root:PGDBObjSubordinated;
  rve:TVolumesExtender;
begin
  if pThisEntity<>nil then begin
    root:=pThisEntity^.GetMainOwner;
    if root<>nil then begin
      rve:=root^.GetExtension<TVolumesExtender>;
      if rve<>nil then
        rve.RemoveVolume(self);
    end;
  end;
end;

constructor TIncludingVolumeExtender.Create;
var
  root:PGDBObjSubordinated;
  rve:TVolumesExtender;
begin
  inherited;
  //pThisEntity:=pEntity;
  InsideEnts.init(100);
  if(pEntity<>nil)then
    if not PGDBObjEntity(pEntity)^.CheckState([ESConstructProxy,ESTemp]) then
      if pThisEntity<>nil then begin
        root:=pThisEntity^.GetMainOwner;
        if root<>nil then begin
          rve:=root^.GetExtension<TVolumesExtender>;
          if rve=nil then begin
            rve:=TVolumesExtender.Create(root);
            root^.AddExtension(rve);
          end;
          rve.AddVolume(self);
        end;
      end;
end;
destructor TIncludingVolumeExtender.Destroy;
var
  root:PGDBObjSubordinated;
  rve:TVolumesExtender;
begin
  if pThisEntity<>nil then begin
    root:=pThisEntity^.GetMainOwner;
    if root<>nil then begin
      rve:=root^.GetExtension<TVolumesExtender>;
      if rve<>nil then
        rve.RemoveVolume(self);
    end;
  end;
  InsideEnts.Clear;
  InsideEnts.done;
end;
procedure TIncludingVolumeExtender.Assign(Source:TBaseExtender);
begin
end;

procedure TIncludingVolumeExtender.onEntityClone(pSourceEntity,pDestEntity:pointer);
begin
end;
procedure TIncludingVolumeExtender.onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);
begin
end;
procedure TIncludingVolumeExtender.onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  ir:itrec;
  pent:PGDBObjEntity;
begin
  if pThisEntity<>nil then
    if not PGDBObjEntity(pThisEntity)^.CheckState([ESConstructProxy,ESTemp]) then begin
      PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray.PushBackIfNotPresent(pThisEntity);
      if not PGDBObjEntity(pThisEntity)^.CheckState([ESConstructProxy,ESTemp]) then begin
        pent:=InsideEnts.beginiterate(ir);
        if pent<>nil then
        repeat
          PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray.PushBackIfNotPresent(pent);
          PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjCasheArray.PushBackIfNotPresent(pent);

          pent:=InsideEnts.iterate(ir);
        until pent=nil;
      end;
    end;
  InsideEnts.Clear;
end;

procedure TIncludingVolumeExtender.onEntityBeforeConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
  if pThisEntity<>nil then begin
    if IsObjectIt(TypeOf(pThisEntity^),typeof(GDBObjWithMatrix)) then begin
      toBoundMatrix:=PGDBObjWithMatrix(pThisEntity)^.GetMatrix^;
      MatrixInvert(toBoundMatrix);
    end else
      toBoundMatrix:=OneMatrix;
  end else
    toBoundMatrix:=OneMatrix;

end;

procedure TIncludingVolumeExtender.onEntityConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  Objects:GDBObjOpenArrayOfPV;
begin
  InsideEnts.Clear;
  if pThisEntity<>nil then begin
    if not PGDBObjEntity(pThisEntity)^.CheckState([ESConstructProxy,ESTemp]) then begin
      objects.init(10);
      if PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.FindObjectsInVolume(PGDBObjEntity(pThisEntity)^.vp.BoundingBox,Objects)then
        TryConnectToEnts(Objects,drawing,dc);
      objects.Clear;
      objects.done;
    end;
  end;
end;

function TIncludingVolumeExtender.CreateCounturArray:PGDBPolyline2DArray;
var
  i:integer;
begin
  Result:=nil;
  if pThisEntity<>nil then begin
    if IsObjectIt(TypeOf(pThisEntity^),typeof(GDBObjLWPolyline)) then
      result:=@PGDBObjLWPolyline(pThisEntity)^.Vertex2D_in_OCS_Array;
    if (IsObjectIt(TypeOf(pThisEntity^),typeof(GDBObjCurve)))and(PGDBObjCurve(pThisEntity)^.VertexArrayInWCS.Count>2) then begin
      Result:=GetMem(SizeOf(GDBpolyline2DArray));
      Result^.init(PGDBObjCurve(pThisEntity)^.VertexArrayInWCS.Count,false);
      for i:=0 to PGDBObjCurve(pThisEntity)^.VertexArrayInWCS.Count-1 do
        Result^.PushBackData(PzePoint2d(PGDBObjCurve(pThisEntity)^.VertexArrayInWCS.getDataMutable(i))^);
    end;
  end;
end;

procedure TIncludingVolumeExtender.DestroyCounturArray(ACA:PGDBPolyline2DArray);
begin
  if ACA<>nil then begin
    if pThisEntity<>nil then begin
      if not IsObjectIt(TypeOf(pThisEntity^),typeof(GDBObjLWPolyline)) then
        ACA.destroy;
    end else
      ACA.destroy;
  end;
end;


procedure TIncludingVolumeExtender.TryConnectToEnts(var Objects:GDBObjOpenArrayOfPV;const drawing:TDrawingDef;var DC:TDrawContext);
var
  p:PGDBObjEntity;
  ir:itrec;
  VolumeVExtdr:TVariablesExtender;
  CA:PGDBPolyline2DArray;
begin
  VolumeVExtdr:=nil;
  CA:=CreateCounturArray;
  p:=Objects.beginiterate(ir);
  if p<>nil then
  repeat
    CheckEnt(p,CA,VolumeVExtdr,drawing,DC);
  p:=Objects.iterate(ir);
  until p=nil;
  DestroyCounturArray(CA);
end;
procedure TIncludingVolumeExtender.CheckEnt(p:PGDBObjEntity;CA:PGDBPolyline2DArray;var VolumeVExtdr:TVariablesExtender;const drawing:TDrawingDef;var DC:TDrawContext);
type
  TObjectTestType=(OTTNotSupported,OTTByPoint,OTTByPoints);

var
  ppoint:PzePoint3d;
  testp:TzePoint3d;
  testp2d:TzePoint2d;
  pPonts:PGDBPoint3dArray;
  EntTestType:TObjectTestType;
  EntVExtdr:TVariablesExtender;
  i:Integer;
 begin
  EntVExtdr:=nil;
  pPonts:=nil;
  if pThisEntity<>nil then begin
    if p<>pThisEntity then begin

      if IsObjectIt(TypeOf(p^),typeof(GDBObjAbstractText)) then begin
        testp:=PGDBObjAbstractText(p)^.P_insert_in_WCS;
        EntTestType:=OTTByPoint;
      end else if IsObjectIt(TypeOf(p^),typeof(GDBObjBlockInsert)) then begin
        testp:=PGDBObjDevice(p)^.P_insert_in_WCS;
        EntTestType:=OTTByPoint;
      end else if IsObjectIt(TypeOf(p^),typeof(GDBObjCurve)) then begin
        EntVExtdr:=p^.GetExtension<TVariablesExtender>;
        if EntVExtdr=nil then
          exit;
        pPonts:=@PGDBObjCurve(p)^.VertexArrayInWCS;
        if pPonts=nil then
          exit;
        EntTestType:=OTTByPoints;
      end else begin
        {TODO: пока работает не с всеми примитивами, надо расширять на все остальное}
        //EntTestType:=OTTNotSupported;
        //testp:=NulVertex;
        exit;
      end;

      if CA<>nil then begin
          case EntTestType of
            OTTByPoint:begin
              if not IsPointInBB(testp,PGDBObjEntity(pThisEntity)^.vp.BoundingBox)then
                exit;
              testp:=VectorTransform3D(testp,toBoundMatrix);
              testp2d.x:=testp.x;
              testp2d.y:=testp.y;
              if ca.ispointinside(testp2d)then
                ConnectToEnt(p,VolumeVExtdr,EntVExtdr,drawing,DC);
            end;
            OTTByPoints:begin
              for i:=0 to pPonts^.Count-1 do begin
                ppoint:=pPonts^.getDataMutable(i);
                if not IsPointInBB(ppoint^,PGDBObjEntity(pThisEntity)^.vp.BoundingBox)then
                  exit;
                testp:=VectorTransform3D(ppoint^,toBoundMatrix);
                testp2d.x:=testp.x;
                testp2d.y:=testp.y;
                if not ca.ispointinside(testp2d)then
                  exit;
              end;
              ConnectToEnt(p,VolumeVExtdr,EntVExtdr,drawing,DC);
            end;
          end;
      end else
        if IsPointInBB(testp,PGDBObjEntity(pThisEntity)^.vp.BoundingBox)then
          ConnectToEnt(p,VolumeVExtdr,EntVExtdr,drawing,DC);

    end;
  end;
end;

procedure TIncludingVolumeExtender.ConnectToEnt(p:PGDBObjEntity;var VolumeVExtdr,EntityExtender:TVariablesExtender;const drawing:TDrawingDef;var DC:TDrawContext);
begin
  if EntityExtender=nil then
    EntityExtender:=p^.GetExtension<TVariablesExtender>;
  if EntityExtender<>nil then begin
    if VolumeVExtdr=nil then
      VolumeVExtdr:=PGDBObjEntity(pThisEntity)^.GetExtension<TVariablesExtender>;
    if VolumeVExtdr<>nil then begin
      EntityExtender.addConnected(VolumeVExtdr);
      //pEntVExtdr.EntityUnit.ConnectedUses.PushBackIfNotPresent(@VolumeVExtdr.EntityUnit);
      PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjCasheArray.PushBackIfNotPresent(p);
    end;
  end;
  InsideEnts.PushBackData(p);
end;

procedure TIncludingVolumeExtender.onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;
procedure TIncludingVolumeExtender.CopyExt2Ent(pSourceEntity,pDestEntity:pointer);
begin
end;
procedure TIncludingVolumeExtender.ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);
begin
end;

procedure TIncludingVolumeExtender.PostLoad(var context:TIODXFLoadContext);
begin
end;

class function TIncludingVolumeExtender.getExtenderName:string;
begin
  result:=IncludingVolumeExtenderName;
end;

class function TIncludingVolumeExtender.EntIOLoadIncludingVolumeExtender(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  VolumeExtender:TIncludingVolumeExtender;
begin
  VolumeExtender:=PGDBObjEntity(PEnt)^.GetExtension<TIncludingVolumeExtender>;
  if VolumeExtender=nil then begin
    VolumeExtender:=AddVolumeExtenderToEntity(PEnt);
  end;
  result:=true;
end;

procedure TIncludingVolumeExtender.SaveToDxfObjXData(var outStream:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFSaveContext);
begin
   dxfStringout(outStream,1000,'INCLUDINGVOLUMEEXTENDER=');
end;


initialization
  //extdrAdd(extdrIncludingVolume)
  EntityExtenders.RegisterKey(uppercase(IncludingVolumeExtenderName),TIncludingVolumeExtender);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('INCLUDINGVOLUMEEXTENDER',TIncludingVolumeExtender.EntIOLoadIncludingVolumeExtender);
finalization
end.


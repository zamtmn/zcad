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

unit uzeEntitiesTreeNodeData;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses
    gzctnrVectorTypes,graphics,gzctnrVectorSimple,gzctnrVectorPObjects,
    uzegeometrytypes,uzgldrawcontext,uzeentity,gzctnrVectorP,uzeTypes;
type
  TDrawType=(TDTFulDraw,TDTSimpleDraw);
  TEntityArray=GZVectorPObects<PGDBObjEntity,GDBObjEntity>;
  TEntTreeNodeData=record
    //infrustum должен идти первым. GDBObjEntity.GetInfrustumFromTree расчитывает на это
    infrustum:TActuality;
    inFrustumState:TInBoundingVolume;
    nuldrawpos,minusdrawpos,plusdrawpos:TActuality;
    FulDraw:TDrawType;
    InFrustumBoundingBox:TBoundingBox;
    NeedToSeparated:GZVectorP<PGDBObjEntity>;
    //nodedepth:Integer;
    //pluscount,minuscount:Integer;
    procedure CreateDef;
    procedure Clear;
    procedure Destroy;
    procedure AfterSeparateNode(var nul:TEntityArray);
  end;
  PEntTreeNodeData=^TEntTreeNodeData;
implementation
procedure TEntTreeNodeData.CreateDef;
begin
  infrustum:=0;
  inFrustumState:=TInBoundingVolume.IRNotAplicable;
  nuldrawpos:=0;
  FulDraw:=TDTFulDraw;
  InFrustumBoundingBox:=default(TBoundingBox);
  NeedToSeparated.initnul;
end;
procedure TEntTreeNodeData.Clear;
begin
  infrustum:=0;
  nuldrawpos:=0;
  FulDraw:=TDTFulDraw;
  NeedToSeparated.clear;
end;
procedure TEntTreeNodeData.Destroy;
begin
  NeedToSeparated.Clear;
  NeedToSeparated.done;
end;
procedure TEntTreeNodeData.AfterSeparateNode(var nul:TEntityArray);
var
  pobj:PGDBObjEntity;
  ir:itrec;
begin
  pobj:=nul.beginiterate(ir);
  if pobj<>nil then
  repeat
    if pobj^.IsNeedSeparate then begin
      if NeedToSeparated.GetCount=0 then begin
        NeedToSeparated.SetSize(nul.Count-ir.itc+1);
      end;
      NeedToSeparated.PushBackData(pobj);
    end;
    pobj:=nul.iterate(ir);
  until pobj=nil;
end;
begin
end.

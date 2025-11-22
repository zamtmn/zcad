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
{$MODE OBJFPC}{$H+}
unit uzccommand_Mirror;
{$INCLUDE zengineconfig.inc}

interface

uses
  Varman,
  uzcdrawings,
  uzeutils,
  uzglviewareadata,
  uzccommandsabstract,
  uzccommand_copy,
  uzegeometry,
  uzccommandsmanager,
  uzegeometrytypes,uzeentity,uzcLog,
  uzcstrconsts;

type
  TEntityProcess=(TEP_Erase,TEP_leave);
  PTMirrorParam=^TMirrorParam;

  TMirrorParam=record
    SourceEnts:TEntityProcess;
  end;

  mirror_com=object(copy_com)
    function CalcTransformMatrix(p1,p2:TzePoint3d):DMatrix4d;virtual;
    function AfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;
      mc:TzePoint2i;var button:byte;osp:pos_record):integer;virtual;
  end;

var
  MirrorParam:TMirrorParam;
  mirror:mirror_com;

implementation

function Mirror_com.CalcTransformMatrix(p1,p2:TzePoint3d):DMatrix4d;
var
  dist,p3:TzePoint3d;
  d:double;
  plane:TzeVector4d;
begin
  dist:=uzegeometry.VertexSub(p2,p1);
  d:=uzegeometry.oneVertexlength(dist);
  p3:=uzegeometry.VertexMulOnSc(ZWCS,d);
  p3:=uzegeometry.VertexAdd(p3,t3dp);

  plane:=PlaneFrom3Pont(p1,p2,p3);
  normalizeplane(plane);
  Result:=CreateReflectionMatrix(plane);
end;

function Mirror_com.AfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record):integer;
var
  tempmatr,MirrMatr:DMatrix4d;
  FrPos:TzePoint3d;
begin
  MirrMatr:=CalcTransformMatrix(t3dp,wc);
  if (button and MZW_LBUTTON)<>0 then begin
    case MirrorParam.SourceEnts of
      TEP_Erase:move(MirrMatr,self.CommandName);
      TEP_Leave:copy(MirrMatr,self.CommandName);
    end;
    commandmanager.executecommandend;
  end else begin
    if (drawings.GetCurrentDWG^.GetPcamera^.notuseLCS) then begin
      drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=MirrMatr;
    end else begin
      with drawings.GetCurrentDWG^.ConstructObjRoot do begin

        tempmatr:=uzegeometry.MatrixMultiply(OneMatrix,MirrMatr);
        FrPos.x:=tempmatr.mtr.v[3].x;
        FrPos.y:=tempmatr.mtr.v[3].y;
        FrPos.z:=tempmatr.mtr.v[3].z;

        ObjMatrix:=uzegeometry.CreateTranslationMatrix(-drawings.GetCurrentDWG^.GetPcamera^.CamCSOffset);
        ObjMatrix:=uzegeometry.MatrixMultiply(ObjMatrix,MirrMatr);
        ObjMatrix:=uzegeometry.MatrixMultiply(
          ObjMatrix,CreateTranslationMatrix(drawings.GetCurrentDWG^.GetPcamera^.CamCSOffset));
        FrustumPosition:=FrPos;
      end;
    end;
  end;
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  if SysUnit<>nil then begin
    SysUnit^.RegisterType(TypeInfo(TMirrorParam));
    SysUnit^.RegisterType(TypeInfo(PTMirrorParam));
    SysUnit^.SetTypeDesk(TypeInfo(TMirrorParam),[rscmSourceEntities],[FNUser]);
    SysUnit^.SetTypeDesk(TypeInfo(TEntityProcess),[rscmErase,rscmLeave],[FNUser]);
  end;

  MirrorParam.SourceEnts:=TEP_Erase;
  mirror.init('Mirror',0,0);
  mirror.SetCommandParam(@MirrorParam,'PTMirrorParam');

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);

end.

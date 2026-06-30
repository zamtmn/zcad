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
unit uzcCommand_Rotate;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzbUnitsUtils,gzctnrVectorTypes,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcstrconsts,
  uzegeometrytypes,
  uzccommandsmanager,
  uzeentline,uzeentity,uzeentityfactory,
  uzcutils,
  uzeparsercmdprompt,
  uzegeometry,
  uzcinterface,
  uzcCommand_MoveEntsByMouse;

resourcestring
  RSCLPRotateAngleCopyReference='Specify rotation angle or [${"&[C]opy",Keys[c,m],StrId[CLPIdCopy]}, ${"&[R]eference",Keys[r],StrId[CLPIdReference]}]';
  RSCLPRotateAngleMoveReference='Specify rotation angle or [${"&[M]ove",Keys[m,c],StrId[CLPIdMove]}, ${"&[R]eference",Keys[r],StrId[CLPIdReference]}]';
  RSCLPRotateWaitReferenceAngle='Specify reference angle:';

implementation

var
  clAngleCopyReference:CMDLinePromptParser.TGeneralParsedText=nil;
  clAngleMoveReference:CMDLinePromptParser.TGeneralParsedText=nil;

  MoveMode:boolean;
  Axis,RefV:TzeVector3d;

function Rotate_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
type
   TRotateCmdMode=(RCMWaitBasePoint,RCMWaitAngleCopyReference,RCMWaitReference0,RCMWaitReference1);
var
  p1:TzePoint3d;
  BasePnt,R0Pnt,R1Pnt:TzePoint3d;
  CmdMode:TRotateCmdMode;
  gr:TzcInteractiveResult;
  t_matrix:TzeTypedMatrix4d;
  Angle:Double;
  ir:itrec;
  p:PGDBObjEntity;

  procedure SetRotateCmdMode(ANewMode:TRotateCmdMode;const AForce:boolean=false);
  begin
    if not AForce then
      if CmdMode=ANewMode then
        exit;
    case ANewMode of
      RCMWaitBasePoint:begin
        commandmanager.SetPrompt(rscmBasePoint);
        commandmanager.ChangeInputMode([IPEmpty],[]);
      end;
      RCMWaitAngleCopyReference:begin
        if MoveMode then begin
          if clAngleCopyReference=nil then
            clAngleCopyReference:=CMDLinePromptParser.GetTokens(RSCLPRotateAngleCopyReference);
          commandmanager.SetPrompt(clAngleCopyReference);
        end else begin
          if clAngleMoveReference=nil then
            clAngleMoveReference:=CMDLinePromptParser.GetTokens(RSCLPRotateAngleMoveReference);
          commandmanager.SetPrompt(clAngleMoveReference);
        end;
        commandmanager.ChangeInputMode([IPEmpty],[]);
      end;
      RCMWaitReference0:begin
        commandmanager.SetPrompt(RSCLPRotateWaitReferenceAngle);
        commandmanager.ChangeInputMode([IPEmpty],[]);
      end;
    end;
    CmdMode:=ANewMode;
  end;

begin
  RefV:=CreateVector(1,0,0);
  Axis:=CreateVector(0,0,1);
  if CloneEnts>0 then begin
    SetRotateCmdMode(RCMWaitBasePoint,true);
    repeat
      case CmdMode of
        RCMWaitReference0,RCMWaitBasePoint:
          gr:=commandmanager.Get3DPoint('',p1);
        RCMWaitReference1:
          gr:=commandmanager.Get3DPointWithLineFromBase('',R0Pnt,p1);
        RCMWaitAngleCopyReference:
          gr:=commandmanager.Get3DAndRotateConstructRoot('',BasePnt,Axis,RefV,p1);
      end;
      case gr of
        IRNormal:
          case CmdMode of
            RCMWaitBasePoint:begin
              BasePnt:=p1;
              SetRotateCmdMode(RCMWaitAngleCopyReference);
            end;
            RCMWaitReference0:begin
              R0Pnt:=p1;
              SetRotateCmdMode(RCMWaitReference1);
            end;
            RCMWaitReference1:begin
              R1Pnt:=p1;
              RefV:=(R1Pnt-R0Pnt).NormalizeVertex;
              SetRotateCmdMode(RCMWaitAngleCopyReference);
            end;
            RCMWaitAngleCopyReference:begin
              if MoveMode then begin
                Context.PDWG^.ConstructObjRoot.ObjMatrix:=OneMatrix;
                zcFreeEntsInCurrentDrawingConstructRoot;
                t_matrix:=CreateTranslationMatrix(-BasePnt);
                t_matrix:=MatrixMultiply(t_matrix,CreateAffineRotationMatrix(Axis,RefV,(p1-BasePnt).NormalizeVertex));
                t_matrix:=MatrixMultiply(t_matrix,CreateTranslationMatrix(BasePnt));
                zcTransformSelectedEntsInDrawingWithUndo('Rotate',t_matrix);
                Break;
              end else begin
                zcMoveEntsFromConstructRootToCurrentDrawingWithUndo('Rotate[Copy]');
                CloneEnts;
                zcRedrawCurrentDrawing();
              end
            end;
          end;
        IRId:
          case commandmanager.GetLastId of
            CLPIdCopy:begin
              MoveMode:=not MoveMode;
              SetRotateCmdMode(CmdMode,true);
            end;
            CLPIdReference:
              SetRotateCmdMode(RCMWaitReference0);
          end;
        IRInput:begin
          case CmdMode of
            RCMWaitAngleCopyReference:begin
              if zeTryStringToAngle(commandmanager.GetLastInput,Angle,Context.PDWG^.GetUnitsFormat) then begin
                t_matrix:=CreateTranslationMatrix(-BasePnt);
                t_matrix:=MatrixMultiply(t_matrix,CreateAffineRotationMatrix(Axis,-Angle));
                t_matrix:=MatrixMultiply(t_matrix,CreateTranslationMatrix(BasePnt));
                if MoveMode then begin
                  Context.PDWG^.ConstructObjRoot.ObjMatrix:=OneMatrix;
                  zcFreeEntsInCurrentDrawingConstructRoot;
                  zcTransformSelectedEntsInDrawingWithUndo('Rotate',t_matrix);
                  Break;
                end else begin
                  Context.PDWG^.ConstructObjRoot.ObjMatrix:=OneMatrix;
                  p:=Context.PDWG^.ConstructObjRoot.ObjArray.beginiterate(ir);
                  if p<>nil then
                    repeat
                      p^.transform(t_matrix);
                      p:=Context.PDWG^.ConstructObjRoot.ObjArray.iterate(ir);
                    until p=nil;

                  zcMoveEntsFromConstructRootToCurrentDrawingWithUndo('Rotate[Copy]');
                  CloneEnts;
                  zcRedrawCurrentDrawing();
                end
              end else
                zcUI.TextMessage('Please enter angle?',TMWOShowError);
            end else
              zcUI.TextMessage('Try use mouse Luke?',TMWOShowError);
          end;
          end;
      end;
    until gr=IRCancel;
  end else begin
    zcUI.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
    Result:=cmd_ok;
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  MoveMode:=true;
  RefV:=CreateVector(1,0,0);
  Axis:=CreateVector(0,0,1);
  CreateZCADCommand(@Rotate_com,'Rotate',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  clAngleCopyReference.Free;
  clAngleMoveReference.Free;
end.

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

unit uzccmdload;
{$INCLUDE zengineconfig.inc}

interface

uses
  uzcLog,LCLType,LazUTF8,
  uzbpaths,uzeTypes,uzcuitypes,
  uzeffmanager,uzctranslations,
  uzccommandsimpl,uzccommandsabstract,
  uzcdrawings,uzcdrawing,
  uzctnrVectorBytesStream,UUnitManager,URecordDescriptor,gzctnrVectorTypes,
  Varman,varmandef,typedescriptors,
  uzgldrawcontext,
  uzedrawingsimple,uzeconsts,
  uzcinterface,
  uzcstrconsts,
  uzcutils,
  SysUtils,
  uzelongprocesssupport,uzccommandsmanager,
  uzeLogIntf;

function Load_Merge(const Operands:TCommandOperands;LoadMode:TLoadOpt):TCommandResult;
function Internal_Load_Merge(const s:ansistring;loadproc:TFileLoadProcedure;
  LoadMode:TLoadOpt):TCommandResult;
procedure DXFLoadCallBack(stage:TZEStage;&Type:TZEMsgType;msg:string);

implementation

procedure remapprjdb(pu:ptunit);
var
  pv,pvindb:pvardesk;
  ir:itrec;
  ptd:PUserTypeDescriptor;
  pfd:PFieldDescriptor;
  pf,pfindb:ppointer;
begin
  pv:=pu.InterfaceVariables.vardescarray.beginiterate(ir);
  if pv<>nil then
    repeat
      ptd:=DBUnit.TypeName2PTD(pv.Data.PTD.TypeName);
      if ptd<>nil then
        if (ptd.GetTypeAttributes and TA_OBJECT)=TA_OBJECT then begin
          pvindb:=DBUnit.InterfaceVariables.findvardescbytype(pv.Data.PTD);
          if pvindb<>nil then begin
            pfd:=PRecordDescriptor(pvindb^.Data.PTD)^.FindField('Variants');
            if pfd<>nil then begin
              pf:=pv.Data.Addr.Instance+pfd.Offset;
              pfindb:=pvindb.Data.Addr.Instance+pfd.Offset;
              pf^:=pfindb^;
            end;
          end;
        end;
      pv:=pu.InterfaceVariables.vardescarray.iterate(ir);
    until pv=nil;
end;

procedure DXFLoadCallBack(stage:TZEStage;&Type:TZEMsgType;msg:string);
begin
  if commandmanager.isBusy then begin
    case &Type of
      ZEMsgInfo:ProgramLog.LogOutStr(msg,LM_Info);
      ZEMsgCriticalInfo:ProgramLog.LogOutStr(msg,LM_Info,1,MO_SH);
      ZEMsgWarning:ProgramLog.LogOutStr(msg,LM_Info);
      ZEMsgError:ProgramLog.LogOutStr(msg,LM_Info,1,MO_SH);
    end;
  end else begin
    case &Type of
      ZEMsgInfo:ProgramLog.LogOutStr(msg,LM_Info,1,MO_SH);
      ZEMsgCriticalInfo:ProgramLog.LogOutStr(msg,LM_Info,1,MO_SH);
      ZEMsgWarning:ProgramLog.LogOutStr(msg,LM_Info,1,MO_SH);
      ZEMsgError:ProgramLog.LogOutStr(msg,LM_Info,1,MO_SM);
    end;
    //zDebugLn(msg);
  end;
end;

function Internal_Load_Merge(const s:ansistring;loadproc:TFileLoadProcedure;
  LoadMode:TLoadOpt):TCommandResult;
var
  mem:TZctnrVectorBytes;
  pu:ptunit;
  DC:TDrawContext;
  ZCDCtx:TZDrawingContext;
  lph,lph2:TLPSHandle;
  dbpas:string;
begin
  lph:=lps.StartLongProcess(rsLoadFile,nil,0);
  ZCDCtx.CreateRec(drawings.GetCurrentDWG^,drawings.GetCurrentDWG^.pObjRoot^,
    loadmode,drawings.GetCurrentDWG.CreateDrawingRC);
  loadproc(s,ZCDCtx,@DXFLoadCallBack);
  dbpas:=utf8tosys(ChangeFileExt(s,'.dbpas'));
  if not FileExists(dbpas) then begin
    dbpas:=utf8tosys(s+'.dbpas');
    if not FileExists(dbpas) then
      dbpas:='';
  end;
  if dbpas<>'' then begin
    pu:=PTZCADDrawing(drawings.GetCurrentDWG).DWGUnits.findunit(
      GetSupportPaths,InterfaceTranslate,DrawingDeviceBaseUnitName);
    if assigned(pu) then begin
      mem.InitFromFile(dbpas);
      units.parseunit(GetSupportPaths,InterfaceTranslate,mem,PTSimpleUnit(pu));
      remapprjdb(pu);
      mem.done;
    end;
  end;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  lph2:=lps.StartLongProcess('First maketreefrom afrer dxf load',nil,0,LPSOSilent);
  drawings.GetCurrentROOT.calcbb(dc);
  drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree.maketreefrom(
    drawings.GetCurrentDWG^.pObjRoot.ObjArray,
    drawings.GetCurrentDWG^.pObjRoot.vp.BoundingBox,nil);
  lps.EndLongProcess(lph2);
  lph2:=lps.StartLongProcess('drawings.GetCurrentROOT.FormatEntity afrer dxf load',
    nil,0,LPSOSilent);
  drawings.GetCurrentROOT.FormatEntity(drawings.GetCurrentDWG^,dc);
  lps.EndLongProcess(lph2);
  lph2:=lps.StartLongProcess('Second maketreefrom and redraw afrer dxf load',
    nil,0,LPSOSilent);
  if drawings.currentdwg<>PTSimpleDrawing(BlockBaseDWG) then begin
    drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree.maketreefrom(
      drawings.GetCurrentDWG^.pObjRoot.ObjArray,
      drawings.GetCurrentDWG^.pObjRoot.vp.BoundingBox,nil);
    zcRedrawCurrentDrawing;
  end;
  lps.EndLongProcess(lph2);
  lps.EndLongProcess(lph);
  zcUI.Do_GUIaction(nil,zcMsgUIActionRedraw);
  Result:=cmd_ok;
end;

function Load_Merge(const Operands:TCommandOperands;LoadMode:TLoadOpt):TCommandResult;
var
  s:ansistring;
  isload:boolean;
  loadproc:TFileLoadProcedure;
begin
  if drawings.currentdwg<>PTSimpleDrawing(BlockBaseDWG) then
    if drawings.GetCurrentROOT.ObjArray.Count>0 then begin
      if zcUI.TextQuestion(rsDWGAlreadyContainsData,'QLOAD')=zccbNo then
        exit;
    end;
  s:=operands;
  loadproc:=Ext2LoadProcMap.GetLoadProc(extractfileext(s));
  isload:=(assigned(loadproc))and(FileExists(utf8tosys(s)));
  if isload then begin
    Result:=Internal_Load_Merge(s,loadproc,LoadMode);
  end else
    zcUI.TextMessage('MERGE:'+format(rsUnableToOpenFile,[s]),TMWOShowError);
end;

end.

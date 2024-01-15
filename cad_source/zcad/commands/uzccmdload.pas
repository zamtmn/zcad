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
  uzbpaths,uzbtypes,uzcuitypes,

  uzeffmanager,uzctranslations,
  uzccommandsimpl,uzccommandsabstract,
  uzcdrawings,uzcdrawing,
  uzctnrVectorBytes,UUnitManager,URecordDescriptor,gzctnrVectorTypes,
  Varman,varmandef,typedescriptors,
  uzgldrawcontext,
  uzedrawingsimple,uzeconsts,
  uzcinterface,
  uzcstrconsts,
  uzcutils,
  sysutils;

function Load_Merge(Operands:TCommandOperands;LoadMode:TLoadOpt):TCommandResult;
function Internal_Load_Merge(s: AnsiString;loadproc:TFileLoadProcedure;LoadMode:TLoadOpt):TCommandResult;

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
              ptd:=DBUnit.TypeName2PTD(pv.data.PTD.TypeName);
              if ptd<>nil then
              if (ptd.GetTypeAttributes and TA_OBJECT)=TA_OBJECT then
              begin
                   pvindb:=DBUnit.InterfaceVariables.findvardescbytype(pv.data.PTD);
                   if pvindb<>nil then
                   begin
                        pfd:=PRecordDescriptor(pvindb^.data.PTD)^.FindField('Variants');
                        if pfd<>nil then
                        begin
                        pf:=pv.data.Addr.Instance+pfd.Offset;
                        pfindb:=pvindb.data.Addr.Instance+pfd.Offset;
                        pf^:=pfindb^;
                        end;
                   end;
              end;
              pv:=pu.InterfaceVariables.vardescarray.iterate(ir);
        until pv=nil;
end;

function Internal_Load_Merge(s: AnsiString;loadproc:TFileLoadProcedure;LoadMode:TLoadOpt):TCommandResult;
var
   mem:TZctnrVectorBytes;
   pu:ptunit;
   DC:TDrawContext;
   ZCDCtx:TZDrawingContext;
begin
  ZCDCtx.CreateRec(drawings.GetCurrentDWG^,drawings.GetCurrentDWG^.pObjRoot^,loadmode,drawings.GetCurrentDWG.CreateDrawingRC);
  loadproc(s,ZCDCtx);
  if FileExists(utf8tosys(s+'.dbpas')) then begin
    pu:=PTZCADDrawing(drawings.GetCurrentDWG).DWGUnits.findunit(GetSupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName);
    if assigned(pu) then begin
      mem.InitFromFile(s+'.dbpas');
      units.parseunit(GetSupportPath,InterfaceTranslate,mem,PTSimpleUnit(pu));
      remapprjdb(pu);
      mem.done;
    end;
  end;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  drawings.GetCurrentROOT.calcbb(dc);
  drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree.maketreefrom(drawings.GetCurrentDWG^.pObjRoot.ObjArray,drawings.GetCurrentDWG^.pObjRoot.vp.BoundingBox,nil);
  drawings.GetCurrentROOT.FormatEntity(drawings.GetCurrentDWG^,dc);
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
  if drawings.currentdwg<>PTSimpleDrawing(BlockBaseDWG) then begin
    drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree.maketreefrom(drawings.GetCurrentDWG^.pObjRoot.ObjArray,drawings.GetCurrentDWG^.pObjRoot.vp.BoundingBox,nil);
    zcRedrawCurrentDrawing;
  end;

  result:=cmd_ok;
end;

function Load_Merge(Operands:TCommandOperands;LoadMode:TLoadOpt):TCommandResult;
var
   s: AnsiString;
   isload:boolean;
   loadproc:TFileLoadProcedure;
begin
  if drawings.currentdwg<>PTSimpleDrawing(BlockBaseDWG) then
    if drawings.GetCurrentROOT.ObjArray.Count>0 then begin
      if ZCMsgCallBackInterface.TextQuestion(rsDWGAlreadyContainsData,'QLOAD')=zccbNo then
        exit;
    end;
  s:=operands;
  loadproc:=Ext2LoadProcMap.GetLoadProc(extractfileext(s));
  isload:=(assigned(loadproc))and(FileExists(utf8tosys(s)));
  if isload then begin
    result:=Internal_Load_Merge(s,loadproc,LoadMode);
  end else
    ZCMsgCallBackInterface.TextMessage('MERGE:'+format(rsUnableToOpenFile,[s]),TMWOShowError);
end;
end.

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

unit uzccmdload;
{$INCLUDE zengineconfig.inc}

interface
uses
  LCLProc,LCLType,LazUTF8,
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


function Load_Merge(Operands:TCommandOperands;LoadMode:TLoadOpt):TCommandResult;
var
   s: AnsiString;
   //fileext:String;
   isload:boolean;
   mem:TZctnrVectorBytes;
   pu:ptunit;
   loadproc:TFileLoadProcedure;
   DC:TDrawContext;
begin
     if drawings.currentdwg<>PTSimpleDrawing(BlockBaseDWG) then
       if drawings.GetCurrentROOT.ObjArray.Count>0 then begin
         if ZCMsgCallBackInterface.TextQuestion(rsDWGAlreadyContainsData,'QLOAD')=zccbNo then
           exit;
       end;
     s:=operands;
     loadproc:=Ext2LoadProcMap.GetLoadProc(extractfileext(s));
     isload:=(assigned(loadproc))and(FileExists(utf8tosys(s)));
     if isload then
     begin
          //fileext:=uppercase(ExtractFileEXT(s));
          loadproc(s,@drawings.GetCurrentDWG^.pObjRoot^,loadmode,drawings.GetCurrentDWG^);
     if FileExists(utf8tosys(s+'.dbpas')) then
     begin
           pu:=PTZCADDrawing(drawings.GetCurrentDWG).DWGUnits.findunit(SupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName);
           if assigned(pu) then begin
             mem.InitFromFile(s+'.dbpas');
             //pu^.free;
             units.parseunit(SupportPath,InterfaceTranslate,mem,PTSimpleUnit(pu));
             remapprjdb(pu);
             mem.done;
           end;
     end;
     dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
     drawings.GetCurrentROOT.calcbb(dc);
     //drawings.GetCurrentDWG.ObjRoot.format;//FormatAfterEdit;
     //drawings.GetCurrentROOT.sddf
     //drawings.GetCurrentROOT.format;
     drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree.maketreefrom(drawings.GetCurrentDWG^.pObjRoot.ObjArray,drawings.GetCurrentDWG^.pObjRoot.vp.BoundingBox,nil);
     //drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree:=createtree(drawings.GetCurrentDWG^.pObjRoot.ObjArray,drawings.GetCurrentDWG^.pObjRoot.vp.BoundingBox,@drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree,IninialNodeDepth,nil,TND_Root)^;
     drawings.GetCurrentROOT.FormatEntity(drawings.GetCurrentDWG^,dc);
     ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
     //if assigned(updatevisibleproc) then updatevisibleproc(ZMsgID_GUIActionRedraw);
     if drawings.currentdwg<>PTSimpleDrawing(BlockBaseDWG) then
                                         begin
                                         drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree.maketreefrom(drawings.GetCurrentDWG^.pObjRoot.ObjArray,drawings.GetCurrentDWG^.pObjRoot.vp.BoundingBox,nil);
                                         //drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree:=createtree(drawings.GetCurrentDWG^.pObjRoot.ObjArray,drawings.GetCurrentDWG^.pObjRoot.vp.BoundingBox,@drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree,IninialNodeDepth,nil,TND_Root)^;
                                         //isOpenGLError;
                                         zcRedrawCurrentDrawing;
                                         end;
     result:=cmd_ok;

     end
        else
        ZCMsgCallBackInterface.TextMessage('MERGE:'+format(rsUnableToOpenFile,[s]),TMWOShowError);
end;


procedure startup;
begin
end;
procedure finalize;
begin
end;
initialization
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.

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

unit zcobjinspmultiobjects;
{$INCLUDE def.inc}

interface
uses
 enitiesextendervariables,gdbdrawcontext,
  gdbase,
  UGDBDescriptor,
  varmandef,
  gdbobjectsconstdef,
  GDBEntity,
  gdbasetypes,
 Varman;
type
{Export+}
  TMSType=(
           TMST_All(*'All entities'*),
           TMST_Devices(*'Devices'*),
           TMST_Cables(*'Cables'*)
          );
  TMSEditor={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                SelCount:GDBInteger;(*'Selected objects'*)(*oi_readonly*)
                EntType:TMSType;(*'Process primitives'*)
                OU:TObjectUnit;(*'Variables'*)
                procedure FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);virtual;
                procedure CreateUnit;virtual;
                function GetObjType:GDBWord;virtual;
                constructor init;
                destructor done;virtual;
            end;
{Export-}
var
   MSEditor:TMSEditor;
implementation
uses UGDBSelectedObjArray;
constructor  TMSEditor.init;
begin
     ou.init('multiselunit');
end;
destructor  TMSEditor.done;
begin
     ou.done;
end;
procedure  TMSEditor.FormatAfterFielfmod;
var //i: GDBInteger;
    pv:pGDBObjEntity;
    //pu:pointer;
    pvd,pvdmy:pvardesk;
    //vd:vardesk;
    ir,ir2:itrec;
    //etype:integer;
    DC:TDrawContext;
    pentvarext:PTVariablesExtender;
begin
      dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
      pvd:=ou.InterfaceVariables.vardescarray.beginiterate(ir2);
      if pvd<>nil then
      repeat
            if pvd^.data.Instance=PFIELD then
            begin
                 pvd.attrib:=pvd.attrib and (not vda_different);
                 pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
                 if pv<>nil then
                 repeat
                   if (pv^.Selected)and((pv^.GetObjType=GetObjType)or(GetObjType=0)) then
                   begin
                     pentvarext:=pv^.GetExtension(typeof(TVariablesExtender));
                   if pentvarext<>nil then
                   begin
                        pvdmy:=pentvarext^.entityunit.InterfaceVariables.findvardesc(pvd^.name);
                        if pvdmy<>nil then
                          if pvd^.data.PTD=pvdmy^.data.PTD then
                          begin
                               pvdmy.data.PTD.CopyInstanceTo(pvd.data.Instance,pvdmy.data.Instance);

                               pv^.Formatentity(gdb.GetCurrentDWG^,dc);

                               if pvd^.data.PTD.GetValueAsString(pvd^.data.Instance)<>pvdmy^.data.PTD.GetValueAsString(pvdmy^.data.Instance) then
                               pvd.attrib:=pvd.attrib or vda_different;
                          end;
                   end;
                   end;
                   pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
                 until pv=nil;


            end;
            //pvdmy:=ou.InterfaceVariables.findvardesc(pvd^.name);
            pvd:=ou.InterfaceVariables.vardescarray.iterate(ir2)
      until pvd=nil;
     //createunit;
     //if assigned(ReBuildProc)then
     //                            ReBuildProc;
end;
function TMSEditor.GetObjType:GDBWord;
begin
     case EntType of
                    TMST_All:result:=0;
                    TMST_Devices:result:=GDBDeviceID;
                    TMST_Cables:result:=GDBCableID;
     end;
end;
procedure  TMSEditor.createunit;
var //i: GDBInteger;
    pv:pGDBObjEntity;
    psd:PSelectedObjDesc;
    pu:pointer;
    pvd,pvdmy:pvardesk;
    vd:vardesk;
    ir,ir2:itrec;
    pentvarext:PTVariablesExtender;
begin
     self.SelCount:=0;
     ou.free;
     //etype:=GetObjType;
     psd:=gdb.GetCurrentDWG.SelObjArray.beginiterate(ir);
     //pv:=gdb.GetCurrentDWG.ObjRoot.ObjArray.beginiterate(ir);
     if psd<>nil then
     repeat
       pv:=psd^.objaddr;
       if pv<>nil then

       if pv^.Selected then
       begin
       inc(self.SelCount);
       pentvarext:=pv^.GetExtension(typeof(TVariablesExtender));
       if ((pv^.GetObjType=GetObjType)or(GetObjType=0))and(pentvarext<>nil) then
       begin
            pu:=pentvarext^.entityunit.InterfaceUses.beginiterate(ir2);
            if pu<>nil then
            repeat
                  ou.InterfaceUses.addnodouble(@pu);
                  pu:=pentvarext^.entityunit.InterfaceUses.iterate(ir2)
            until pu=nil;
            pvd:=pentvarext^.entityunit.InterfaceVariables.vardescarray.beginiterate(ir2);
            if pvd<>nil then
            repeat
                  pvdmy:=ou.InterfaceVariables.findvardesc(pvd^.name);
                  if pvdmy=nil then
                                   begin
                                        //if (pvd^.data.PTD^.GetTypeAttributes and TA_COMPOUND)=0 then
                                        begin
                                        vd:=pvd^;
                                        //vd.attrib:=vda_different;
                                        vd.data.Instance:=nil;
                                        ou.InterfaceVariables.createvariable(pvd^.name,vd);
                                        pvd^.data.PTD.CopyInstanceTo(pvd.data.Instance,vd.data.Instance);
                                        end
                                        {   else
                                        begin

                                        end;}
                                   end
                               else
                                   begin
                                        if pvd^.data.PTD.GetValueAsString(pvd^.data.Instance)<>pvdmy^.data.PTD.GetValueAsString(pvdmy^.data.Instance) then
                                           pvdmy.attrib:=vda_different;
                                   end;

                  pvd:=pentvarext^.entityunit.InterfaceVariables.vardescarray.iterate(ir2)
            until pvd=nil;
       end;
       end;
     //pv:=gdb.GetCurrentDWG.ObjRoot.ObjArray.iterate(ir);
     psd:=gdb.GetCurrentDWG.SelObjArray.iterate(ir);
     until psd=nil;
end;

procedure finalize;
begin
     MSEditor.done;
end;
procedure startup;
begin
  MSEditor.init;
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('zcobjinspmultiobjects.initialization');{$ENDIF}
  startup;
finalization
  finalize;
end.

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

unit GDBSubordinated;
{$INCLUDE def.inc}

interface
uses gdbfieldprocessor,ugdbdrawingdef,gdbobjectsconstdef,strproc
     {$IFNDEF DELPHI},LCLProc{$ENDIF},UGDBOpenArrayOfByte,devices,
     gdbase,gdbasetypes,varman,varmandef,
     sysutils,UGDBLayerArray{,strutils};
type
//Owner:PGDBObjGenericWithSubordinated;(*'Владелец'*)
//PSelfInOwnerArray:TArrayIndex;(*'Индекс у владельца'*)

{EXPORT+}
PGDBObjSubordinated=^GDBObjSubordinated;
PGDBObjGenericWithSubordinated=^GDBObjGenericWithSubordinated;
GDBObjGenericWithSubordinated={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                                    OU:TObjectUnit;(*'Variables'*)
                                    function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger;const drawing:TDrawingDef):GDBInteger;virtual;
                                    function ImSelected(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;
                                    procedure DelSelectedSubitem(const drawing:TDrawingDef);virtual;
                                    function AddMi(pobj:PGDBObjSubordinated):PGDBpointer;virtual;abstract;
                                    procedure RemoveInArray(pobjinarray:GDBInteger);virtual;abstract;
                                    function CreateOU:GDBInteger;virtual;
                                    procedure createfield;virtual;
                                    function FindVariable(varname:GDBString):pvardesk;virtual;
                                    destructor done;virtual;
                                    function GetMatrix:PDMatrix4D;virtual;abstract;
                                    //function GetLineWeight:GDBSmallint;virtual;abstract;
                                    function GetLayer:PGDBLayerProp;virtual;abstract;
                                    function GetHandle:GDBPlatformint;virtual;
                                    function GetType:GDBPlatformint;virtual;
                                    function IsSelected:GDBBoolean;virtual;abstract;
                                    procedure FormatAfterDXFLoad(const drawing:TDrawingDef);virtual;
                                    procedure CalcGeometry;virtual;

                                    procedure Build(const drawing:TDrawingDef);virtual;


end;
TEntityAdress=packed record
                          Owner:PGDBObjGenericWithSubordinated;(*'Adress'*)
                          SelfIndex:TArrayIndex;(*'Position'*)
              end;
TTreeAdress=packed record
                          Owner:GDBPointer;(*'Adress'*)
                          SelfIndex:TArrayIndex;(*'Position'*)
              end;
GDBObjBaseProp=packed record
                      ListPos:TEntityAdress;(*'List'*)
                      TreePos:TTreeAdress;(*'Tree'*)
                 end;
GDBObjSubordinated={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjGenericWithSubordinated)
                         bp:GDBObjBaseProp;(*'Owner'*)(*oi_readonly*)(*hidden_in_objinsp*)
                         function GetOwner:PGDBObjSubordinated;virtual;abstract;
                         procedure createfield;virtual;
                         function FindVariable(varname:GDBString):pvardesk;virtual;
                         function FindShellByClass(_type:TDeviceClass):PGDBObjSubordinated;virtual;
                         destructor done;virtual;

         end;
{EXPORT-}
procedure CreateDeviceNameProcess(pEntity:PGDBObjGenericWithSubordinated;const drawing:TDrawingDef);
procedure CreateDBLinkProcess(pEntity:PGDBObjGenericWithSubordinated;const drawing:TDrawingDef);
procedure CreateDeviceNameSubProcess(pvn:pvardesk; const formatstr:GDBString;pEntity:PGDBObjGenericWithSubordinated);
function GetEntName(pu:PGDBObjGenericWithSubordinated):GDBString;

procedure extractvarfromdxfstring2(_Value:GDBString;out vn,vt,vun:GDBString);
procedure extractvarfromdxfstring(_Value:GDBString;out vn,vt,vv,vun:GDBString);
procedure OldVersVarRename(var vn,vt,vv,vun:GDBString);
implementation
uses UUnitManager,shared,log,devicebaseabstract;
destructor GDBObjSubordinated.done;
begin
     inherited;
end;

function GDBObjSubordinated.FindShellByClass(_type:TDeviceClass):PGDBObjSubordinated;
var
   pvd:pvardesk;
begin
     result:=nil;
     pvd:=ou.FindVariable('Device_Class');
     if pvd<>nil then
     if PTDeviceClass(pvd^.data.Instance)^=_type then
                                                      result:=@self;
     if result=nil then
                       if bp.ListPos.owner<>nil then
                                             result:=PGDBObjSubordinated(bp.ListPos.owner).FindShellByClass(_type);
                                                                      
end;
procedure CreateDeviceNameSubProcess(pvn:pvardesk; const formatstr:GDBString; pEntity:PGDBObjGenericWithSubordinated);
begin
     if (pvn<>nil) then
     begin
     if (formatstr<>'') then
                                      begin
                                           if pEntity<>nil then
                                                               pstring(pvn^.data.Instance)^:=textformat(formatstr,pEntity)
                                                            else
                                                               pstring(pvn^.data.Instance)^:='!!ERR(pEnttity=nil)';
                                           pvn^.attrib:=pvn^.attrib or vda_RO;
                                      end
                                         else
                                             pvn^.attrib:=pvn^.attrib and (not vda_RO);
     end;

end;
procedure CreateDBLinkProcess(pEntity:PGDBObjGenericWithSubordinated;const drawing:TDrawingDef);
var
   pvn,pvnt,pdbv:pvardesk;
   pdbu:ptunit;
   pum:PTUnitManager;
begin
     pvn:=pEntity^.OU.FindVariable('DB_link');
     pvnt:=pEntity^.OU.FindVariable('DB_MatName');
     if pvnt<>nil then
     pvnt^.attrib:=pvnt^.attrib or (vda_RO);
     if (pvn<>nil)and(pvnt<>nil) then
     begin
          pum:=drawing.GetDWGUnits;
          if pum<>nil then
          begin
            pdbu:=pum^.findunit(DrawingDeviceBaseUnitName);
            if pdbu<>nil then
            begin
              pdbv:=pdbu^.FindVariable(pstring(pvn.data.Instance)^);
              if pdbv<>nil then
                               pstring(pvnt.data.Instance)^:=PDbBaseObject(pdbv.data.Instance)^.Name
                           else
                               pstring(pvnt.data.Instance)^:='Error!!!';
              exit;
            end;
          end;
     end;
     if pvnt<>nil then
                      pstring(pvnt.data.Instance)^:='Error!!!'
end;
procedure CreateDeviceNameProcess(pEntity:PGDBObjGenericWithSubordinated;const drawing:TDrawingDef);
var
   pvn,pvnt{,pdbv}:pvardesk;
   //pdbu:ptunit;
begin
     pvn:=pEntity^.OU.FindVariable('NMO_Name');
     pvnt:=pEntity^.OU.FindVariable('NMO_Template');

     if (pvnt<>nil) then
     CreateDeviceNameSubProcess(pvn,pstring(pvnt^.data.Instance)^,pEntity);

     CreateDBLinkProcess(pentity,drawing);
end;
function GetEntName(pu:PGDBObjGenericWithSubordinated):GDBString;
var
   pvn{,pvnt}:pvardesk;
begin
     result:='';
     pvn:=pu^.OU.FindVariable('NMO_Name');
     if (pvn<>nil) then
                                      begin
                                           result:=pstring(pvn^.data.Instance)^;
                                      end;
end;
function GDBObjGenericWithSubordinated.GetType:GDBPlatformint;
begin
     result:=0;
end;
function GDBObjGenericWithSubordinated.GetHandle:GDBPlatformint;
begin
     result:=GDBPlatformint(@self);
end;
destructor GDBObjGenericWithSubordinated.done;
begin
     ou.done;
end;
procedure GDBObjGenericWithSubordinated.FormatAfterDXFLoad;
begin
     //format;
     //CalcObjMatrix;
     //calcbb;
end;
procedure GDBObjGenericWithSubordinated.CalcGeometry;
begin

end;

procedure extractvarfromdxfstring(_Value:GDBString;out vn,vt,vv,vun:GDBString);
var i:integer;
begin
    i:=pos('|',_value);
    vn:=copy(_value,1,i-1);
    _Value:=copy(_value,i+1,length(_value)-i);
    i:=pos('|',_value);
    vt:=copy(_value,1,i-1);
    _Value:=copy(_value,i+1,length(_value)-i);
    i:=pos('|',_value);
    vv:=copy(_value,1,i-1);
    vun:=copy(_value,i+1,length(_value)-i);
end;
procedure extractvarfromdxfstring2(_Value:GDBString;out vn,vt,vun:GDBString);
var i:integer;
begin
    i:=pos('|',_value);
    vn:=copy(_value,1,i-1);
    _Value:=copy(_value,i+1,length(_value)-i);
    i:=pos('|',_value);
    vt:=copy(_value,1,i-1);
    vun:=copy(_value,i+1,length(_value)-i);
end;
function ansitoutf8ifneed(var s:GDBString):boolean;
begin
     {$IFNDEF DELPHI}
     if FindInvalidUTF8Character(@s[1],length(s),false)<>-1
        then
            begin
             s:=Tria_AnsiToUtf8(s);
             //HistoryOutStr('ANSI->UTF8 '+s);
             result:=true;
            end
        else
        {$ENDIF}
            result:=false;
end;
procedure OldVersVarRename(var vn,vt,vv,vun:GDBString);
var
   nevname{,nvv}:GDBString;
begin
     {ansitoutf8ifneed(vn);
     ansitoutf8ifneed(vt);}
     ansitoutf8ifneed(vv);
     ansitoutf8ifneed(vun);
     nevname:='';
     if vn='Name' then
                      begin
                           nevname:='NMO_Name';
                      end;
     if vn='ShortName' then
                      begin
                           nevname:='NMO_BaseName';
                      end;
     if vn='Name_Template' then
                      begin
                           nevname:='NMO_Template';
                      end;
     if vn='Material' then
                      begin
                           nevname:='DB_link';
                      end;
     if vn='HeadDevice' then
                      begin
                           nevname:='GC_HeadDevice';
                           vun:='Обозначение головного устройства'
                      end;
     if vn='HeadDShortName' then
                      begin
                           nevname:='GC_HDShortName';
                           vun:='Короткое Обозначение головного устройства'
                      end;
     if vn='GroupInHDevice' then
                      begin
                           nevname:='GC_HDGroup';
                           vun:='Группа'
                      end;
     if vn='NumberInSleif' then
                      begin
                           nevname:='GC_NumberInGroup';
                           vun:='Номер в группе'
                      end;
     if vn='RoundTo' then
                      begin
                           nevname:='LENGTH_RoundTo';
                      end;
     if vn='Cable_AddLength' then
                      begin
                           nevname:='LENGTH_Add';
                      end;
     if vn='Cable_Scale' then
                      begin
                           nevname:='LENGTH_Scale';
                      end;
     if vn='TotalConnectedDevice' then
                      begin
                           nevname:='CABLE_TotalCD';
                      end;
     if vn='Segment' then
                      begin
                           nevname:='CABLE_Segment';
                      end;
     if vn='Cable_Type' then
                      begin
                           nevname:='CABLE_Type';
                      end;
     if  (vn='GC_HDGroup')
     and (vt<>'GDBString')  then
                           begin
                                vt:='GDBString';
                                //vv:=''''+vv+'''';
                           end;

     OldVersTextReplace(vv);
     if nevname<>'' then
                        begin
                             //shared.HistoryOutStr('Старая переменная '+vn+' обновлена до '+nevname);
                             vn:=nevname;
                        end;

end;
procedure GDBObjGenericWithSubordinated.Build;
begin

end;
procedure GDBObjSubordinated.createfield;
begin
     inherited;
     bp.ListPos.owner:={gdb.GetCurrentROOT}nil;
     bp.ListPos.SelfIndex:=-1{nil};
end;
procedure GDBObjGenericWithSubordinated.createfield;
begin
     inherited;
     OU.init('Entity');
     ou.InterfaceUses.add(@SysUnit);
end;
function GDBObjGenericWithSubordinated.FindVariable;
begin
     result:=ou.FindVariable(varname);
end;
function GDBObjSubordinated.FindVariable;
begin
     result:=ou.FindVariable(varname);
     if result=nil then
                       if self.bp.ListPos.Owner<>nil then
                                                 result:=self.bp.ListPos.Owner.FindVariable(varname);

end;
function GDBObjGenericWithSubordinated.CreateOU;
begin
end;
function GDBObjGenericWithSubordinated.ImEdited;
begin
end;
function GDBObjGenericWithSubordinated.ImSelected;
begin
end;
procedure GDBObjGenericWithSubordinated.DelSelectedSubitem;
begin
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBSubordinated.initialization');{$ENDIF}
end.

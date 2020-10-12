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

unit uzeentsubordinated;
{$INCLUDE def.inc}

interface
uses strutils,uzgldrawcontext,uzeentityextender,uzetextpreprocessor,uzedrawingdef,
     uzbstrproc{$IFNDEF DELPHI},LazUTF8{$ENDIF},UGDBOpenArrayOfByte,uzbgeomtypes,uzbtypes,
     gzctnrvectortypes,uzbtypesbase,sysutils,uzestyleslayers,usimplegenerics,uzeffdxfsupport;
type
{EXPORT+}
GDBObjExtendable={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                                 EntExtensions:{-}TEntityExtensions{/GDBPointer/};
                                 procedure AddExtension(ExtObj:PTBaseEntityExtender;ObjSize:GDBInteger);
                                 function GetExtension(_ExtType:pointer):{PTBaseEntityExtender}pointer;
                                 destructor done;virtual;
end;

PGDBObjSubordinated=^GDBObjSubordinated;
PGDBObjGenericWithSubordinated=^GDBObjGenericWithSubordinated;
GDBObjGenericWithSubordinated={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjExtendable)
                                    {OU:TFaceTypedData;(*'Variables'*)}
                                    procedure ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger;var drawing:TDrawingDef);virtual;
                                    procedure ImSelected(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger);virtual;
                                    procedure DelSelectedSubitem(var drawing:TDrawingDef);virtual;
                                    procedure AddMi(pobj:PGDBObjSubordinated);virtual;abstract;
                                    procedure RemoveInArray(pobjinarray:GDBInteger);virtual;abstract;
                                    procedure createfield;virtual;
                                    //function FindVariable(varname:GDBString):pvardesk;virtual;
                                    destructor done;virtual;
                                    function GetMatrix:PDMatrix4D;virtual;abstract;
                                    //function GetLineWeight:GDBSmallint;virtual;abstract;
                                    function GetLayer:PGDBLayerProp;virtual;abstract;
                                    function GetHandle:GDBPlatformint;virtual;
                                    function GetType:GDBPlatformint;virtual;
                                    function IsSelected:GDBBoolean;virtual;abstract;
                                    procedure FormatAfterDXFLoad(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                                    procedure CalcGeometry;virtual;

                                    procedure Build(var drawing:TDrawingDef);virtual;


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
TOSnapModeControl=(On,Off,AsOwner);
GDBObjSubordinated={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjGenericWithSubordinated)
                         bp:GDBObjBaseProp;(*'Owner'*)(*oi_readonly*)(*hidden_in_objinsp*)
                         OSnapModeControl:TOSnapModeControl;(*'OSnap mode control'*)
                         function GetOwner:PGDBObjSubordinated;virtual;abstract;
                         procedure createfield;virtual;
                         //function FindVariable(varname:GDBString):pvardesk;virtual;
                         //function FindShellByClass(_type:TDeviceClass):PGDBObjSubordinated;virtual;
                         destructor done;virtual;
                         procedure postload(var context:TIODXFLoadContext);virtual;abstract;
         end;
{EXPORT-}

procedure extractvarfromdxfstring2(_Value:GDBString;out vn,vt,vun:GDBString);
procedure extractvarfromdxfstring(_Value:GDBString;out vn,vt,vv,vun:GDBString);
procedure OldVersVarRename(var vn,vt,vv,vun:GDBString);
procedure OldVersTextReplace(var vv:GDBString);overload;
procedure OldVersTextReplace(var vv:unicodestring);overload;
implementation
//uses {uzcshared,}log;
procedure GDBObjExtendable.AddExtension(ExtObj:PTBaseEntityExtender;ObjSize:GDBInteger);
begin
     if not assigned(EntExtensions) then
                                        EntExtensions:=TEntityExtensions.create;
     EntExtensions.AddExtension(ExtObj,ObjSize);
end;
function GDBObjExtendable.GetExtension(_ExtType:pointer):{PTBaseEntityExtender}pointer;
begin
     if assigned(EntExtensions) then
                                    result:=EntExtensions.GetExtension(_ExtType)
                                else
                                    result:=nil;
end;

destructor GDBObjExtendable.done;
begin
     if assigned(EntExtensions)then
       EntExtensions.destroy;
end;
destructor GDBObjSubordinated.done;
begin
     inherited;
end;

{function GDBObjSubordinated.FindShellByClass(_type:TDeviceClass):PGDBObjSubordinated;
var
   pvd:pvardesk;
begin
     result:=nil;
     pvd:=PTObjectUnit(ou.Instance)^.FindVariable('Device_Class');
     if pvd<>nil then
     if PTDeviceClass(pvd^.data.Instance)^=_type then
                                                      result:=@self;
     if result=nil then
                       if bp.ListPos.owner<>nil then
                                             result:=PGDBObjSubordinated(bp.ListPos.owner).FindShellByClass(_type);
                                                                      
end;}
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
     //ou.done;
     inherited;
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
     if FindInvalidUTF8Codepoint(@s[1],length(s),false)<>-1
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
procedure OldVersTextReplace(var vv:GDBString);
begin
     vv:=AnsiReplaceStr(vv,'@@[Name]','@@[NMO_Name]');
     vv:=AnsiReplaceStr(vv,'@@[ShortName]','@@[NMO_BaseName]');
     vv:=AnsiReplaceStr(vv,'@@[Name_Template]','@@[NMO_Template]');
     vv:=AnsiReplaceStr(vv,'@@[Material]','@@[DB_link]');
     vv:=AnsiReplaceStr(vv,'@@[HeadDevice]','@@[GC_HeadDevice]');
     vv:=AnsiReplaceStr(vv,'@@[HeadDShortName]','@@[GC_HDShortName]');
     vv:=AnsiReplaceStr(vv,'@@[GroupInHDevice]','@@[GC_HDGroup]');
     vv:=AnsiReplaceStr(vv,'@@[NumberInSleif]','@@[GC_NumberInGroup]');
     vv:=AnsiReplaceStr(vv,'@@[RoundTo]','@@[LENGTH_RoundTo]');
     vv:=AnsiReplaceStr(vv,'@@[Cable_AddLength]','@@[LENGTH_Add]');
     vv:=AnsiReplaceStr(vv,'@@[Cable_Scale]','@@[LENGTH_Scale]');
     vv:=AnsiReplaceStr(vv,'@@[TotalConnectedDevice]','@@[CABLE_TotalCD]');
     vv:=AnsiReplaceStr(vv,'@@[Segment]','@@[CABLE_Segment]');
end;
procedure OldVersTextReplace(var vv:unicodestring);overload;
begin
     vv:=AnsiReplaceStr(vv,'@@[Name]','@@[NMO_Name]');
     vv:=AnsiReplaceStr(vv,'@@[ShortName]','@@[NMO_BaseName]');
     vv:=AnsiReplaceStr(vv,'@@[Name_Template]','@@[NMO_Template]');
     vv:=AnsiReplaceStr(vv,'@@[Material]','@@[DB_link]');
     vv:=AnsiReplaceStr(vv,'@@[HeadDevice]','@@[GC_HeadDevice]');
     vv:=AnsiReplaceStr(vv,'@@[HeadDShortName]','@@[GC_HDShortName]');
     vv:=AnsiReplaceStr(vv,'@@[GroupInHDevice]','@@[GC_HDGroup]');
     vv:=AnsiReplaceStr(vv,'@@[NumberInSleif]','@@[GC_NumberInGroup]');
     vv:=AnsiReplaceStr(vv,'@@[RoundTo]','@@[LENGTH_RoundTo]');
     vv:=AnsiReplaceStr(vv,'@@[Cable_AddLength]','@@[LENGTH_Add]');
     vv:=AnsiReplaceStr(vv,'@@[Cable_Scale]','@@[LENGTH_Scale]');
     vv:=AnsiReplaceStr(vv,'@@[TotalConnectedDevice]','@@[CABLE_TotalCD]');
     vv:=AnsiReplaceStr(vv,'@@[Segment]','@@[CABLE_Segment]');
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
                      end;
     if vn='HeadDShortName' then
                      begin
                           nevname:='GC_HDShortName';
                      end;
     if vn='GroupInHDevice' then
                      begin
                           nevname:='GC_HDGroup';
                      end;
     if vn='NumberInSleif' then
                      begin
                           nevname:='GC_NumberInGroup';
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
     OSnapModeControl:=AsOwner;
end;
procedure GDBObjGenericWithSubordinated.createfield;
begin
     inherited;
     //OU.init('Entity');
     //ou.InterfaceUses.add(@SysUnit);
end;
{function GDBObjGenericWithSubordinated.FindVariable;
begin
     result:=PTObjectUnit(ou.Instance)^.FindVariable(varname);
end;
function GDBObjSubordinated.FindVariable;
begin
     result:=PTObjectUnit(ou.Instance)^.FindVariable(varname);
     if result=nil then
                       if self.bp.ListPos.Owner<>nil then
                                                 result:=self.bp.ListPos.Owner.FindVariable(varname);

end;}
procedure GDBObjGenericWithSubordinated.ImEdited;
begin
end;
procedure GDBObjGenericWithSubordinated.ImSelected;
begin
end;
procedure GDBObjGenericWithSubordinated.DelSelectedSubitem;
begin
end;
begin
end.

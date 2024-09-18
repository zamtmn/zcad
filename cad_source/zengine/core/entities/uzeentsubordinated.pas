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

unit uzeentsubordinated;
{$Mode objfpc}{$H+}
{$INCLUDE zengineconfig.inc}

interface
uses strutils,uzgldrawcontext,uzeExtdrAbstractEntityExtender,uzedrawingdef,
     uzbstrproc{$IFNDEF DELPHI},LazUTF8{$ENDIF},uzctnrVectorBytes,uzegeometrytypes,uzbtypes,
     sysutils,uzestyleslayers,uzeffdxfsupport,gzctnrVectorTypes,uzecamera,uzeentbase;
type

PGDBObjExtendable=^GDBObjExtendable;
GDBObjExtendable=object(GDBObjBaseEntity)
                                 EntExtensions:TEntityExtensions;
                                 procedure AddExtension(ExtObj:TAbstractEntityExtender);
                                 procedure RemoveExtension(ExtType:TMetaEntityExtender);
                                 generic function GetExtension<GEntityExtenderType>:GEntityExtenderType;overload;
                                 function GetExtension(ExtType:TMetaEntityExtender):TAbstractEntityExtender;overload;
                                 function GetExtension(n:Integer):TAbstractEntityExtender;overload;
                                 function GetExtensionsCount:Integer;
                                 procedure CopyExtensionsTo(var Dest:GDBObjExtendable);
                                 destructor done;virtual;
end;

PGDBObjDrawable=^GDBObjDrawable;
GDBObjDrawable=object(GDBObjExtendable)
  procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
end;

PGDBObjSubordinated=^GDBObjSubordinated;
PGDBObjGenericWithSubordinated=^GDBObjGenericWithSubordinated;
GDBObjGenericWithSubordinated= object(GDBObjDrawable)
                                    procedure GoodAddObjectToObjArray(const obj:PGDBObjSubordinated);virtual;abstract;
                                    procedure GoodRemoveMiFromArray(const obj:PGDBObjSubordinated;const drawing:TDrawingDef);virtual;abstract;
                                    procedure ImEdited(pobj:PGDBObjSubordinated;pobjinarray:Integer;var drawing:TDrawingDef);virtual;
                                    procedure ImSelected(pobj:PGDBObjSubordinated;pobjinarray:Integer);virtual;
                                    procedure DelSelectedSubitem(var drawing:TDrawingDef);virtual;
                                    procedure AddMi(pobj:PGDBObjSubordinated);virtual;abstract;
                                    procedure RemoveInArray(pobjinarray:Integer);virtual;abstract;
                                    procedure createfield;virtual;
                                    //function FindVariable(varname:String):pvardesk;virtual;
                                    destructor done;virtual;
                                    function GetMatrix:PDMatrix4D;virtual;abstract;
                                    //function GetLineWeight:SmallInt;virtual;abstract;
                                    function GetLayer:PGDBLayerProp;virtual;abstract;
                                    function GetHandle:PtrInt;virtual;
                                    function GetType:PtrInt;virtual;
                                    function IsSelected:Boolean;virtual;abstract;
                                    procedure FormatAfterDXFLoad(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                                    procedure CalcGeometry;virtual;

                                    procedure Build(var drawing:TDrawingDef);virtual;


end;
TEntityAddress=record
                          Owner:PGDBObjGenericWithSubordinated;
                          SelfIndex:TArrayIndex;
              end;
TTreeAddress=record
                          Owner:Pointer;
                          SelfIndex:TArrayIndex;
              end;
GDBObjBaseProp=record
                      ListPos:TEntityAddress;
                      TreePos:TTreeAddress;
                 end;
GDBObjSubordinated= object(GDBObjGenericWithSubordinated)
                         bp:GDBObjBaseProp;
                         OSnapModeControl:TOSnapModeControl;
                         function GetOwner:PGDBObjSubordinated;virtual;abstract;
                         procedure createfield;virtual;
                         //function FindVariable(varname:String):pvardesk;virtual;
                         //function FindShellByClass(_type:TDeviceClass):PGDBObjSubordinated;virtual;
                         destructor done;virtual;
                         procedure postload(var context:TIODXFLoadContext);virtual;abstract;
         end;

procedure extractvarfromdxfstring2(_Value:String;out vn,vt,vun:String);
procedure extractvarfromdxfstring(_Value:String;out vn,vt,vv,vun:String);
procedure OldVersVarRename(var vn,vt,vv,vun:String);
procedure OldVersTextReplace(var vv:String);overload;
procedure OldVersTextReplace(var vv:TDXFEntsInternalStringType);overload;

implementation

procedure GDBObjExtendable.AddExtension(ExtObj:TAbstractEntityExtender);
begin
     if not assigned(EntExtensions) then
                                        EntExtensions:=TEntityExtensions.create;
     EntExtensions.AddExtension(ExtObj);
end;
procedure GDBObjExtendable.RemoveExtension(ExtType:TMetaEntityExtender);
begin
     if assigned(EntExtensions) then
       EntExtensions.RemoveExtension(ExtType);
end;
generic function GDBObjExtendable.GetExtension<GEntityExtenderType>:GEntityExtenderType;
begin
  {todo: тут какаято хрень с сборкой 3.2.2 на appveyor}
  if assigned(EntExtensions) then begin
    result:=self.EntExtensions.specialize GetExtensionOf<GEntityExtenderType>;
  end else
    result:=nil;
end;
function GDBObjExtendable.GetExtension(ExtType:TMetaEntityExtender):TAbstractEntityExtender;
begin
     if assigned(EntExtensions) then
                                    result:=EntExtensions.GetExtension(ExtType)
                                else
                                    result:=nil;
end;
function GDBObjExtendable.GetExtensionsCount:Integer;
begin
  if assigned(EntExtensions) then
    result:=EntExtensions.GetExtensionsCount
  else
    result:=0;
end;
function GDBObjExtendable.GetExtension(n:Integer):TAbstractEntityExtender;
begin
  if assigned(EntExtensions) then
    result:=EntExtensions.GetExtension(n)
  else
    result:=nil;
end;
destructor GDBObjExtendable.done;
begin
     if assigned(EntExtensions)then
       EntExtensions.destroy;
end;
procedure GDBObjExtendable.CopyExtensionsTo(var Dest:GDBObjExtendable);
var
  i:integer;
  SourceExt,DestExt:TAbstractEntityExtender;
begin
  for i:=0 to GetExtensionsCount-1 do begin
    SourceExt:=GetExtension(i);
    if SourceExt<>nil then begin
      DestExt:=Dest.GetExtension(TMetaEntityExtender(TypeOf(SourceExt)));
      if not Assigned(DestExt) then begin
        DestExt:=TMetaEntityExtender(SourceExt.ClassType).Create(@Dest);
        DestExt.Assign(SourceExt);
        Dest.AddExtension(DestExt);
      end else
        DestExt.Assign(SourceExt);
    end;
  end;
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
     if PTDeviceClass(pvd^.Instance)^=_type then
                                                      result:=@self;
     if result=nil then
                       if bp.ListPos.owner<>nil then
                                             result:=PGDBObjSubordinated(bp.ListPos.owner).FindShellByClass(_type);
                                                                      
end;}
function GDBObjGenericWithSubordinated.GetType:PtrInt;
begin
     result:=0;
end;
function GDBObjGenericWithSubordinated.GetHandle:PtrInt;
begin
     result:=PtrInt(@self);
end;
destructor GDBObjGenericWithSubordinated.done;
begin
     //ou.done;
     inherited;
end;
procedure GDBObjGenericWithSubordinated.FormatAfterDXFLoad(var drawing:TDrawingDef;var DC:TDrawContext);
begin
     //format;
     //CalcObjMatrix;
     //calcbb;
end;
procedure GDBObjGenericWithSubordinated.CalcGeometry;
begin

end;

procedure extractvarfromdxfstring(_Value:String;out vn,vt,vv,vun:String);
var
  i_beg:integer;
  i_end:integer=0;
begin
    i_beg:=i_end+1;
    i_end:=pos('|',_value,i_beg);
    vn:=copy(_value,i_beg,i_end-i_beg);
    i_beg:=i_end+1;
    i_end:=pos('|',_value,i_beg);
    vt:=copy(_value,i_beg,i_end-i_beg);
    i_beg:=i_end+1;
    i_end:=pos('|',_value,i_beg);
    vv:=copy(_value,i_beg,i_end-i_beg);
    i_beg:=i_end+1;
    vun:=copy(_value,i_beg,length(_value)-i_end);
end;
procedure extractvarfromdxfstring2(_Value:String;out vn,vt,vun:String);
var
  i_beg:integer;
  i_end:integer=0;
begin
    i_beg:=i_end+1;
    i_end:=pos('|',_value,i_beg);
    vn:=copy(_value,i_beg,i_end-i_beg);
    i_beg:=i_end+1;
    i_end:=pos('|',_value,i_beg);
    vt:=copy(_value,i_beg,i_end-i_beg);
    i_beg:=i_end+1;
    vun:=copy(_value,i_beg,length(_value)-i_end);
end;
function ansitoutf8ifneed(var s:String):boolean;
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
procedure OldVersTextReplace(var vv:String);
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
procedure OldVersTextReplace(var vv:TDXFEntsInternalStringType);overload;
const
  ReplaceAllIgnoreCase=[rfReplaceAll, rfIgnoreCase];
begin
     vv:=UnicodeStringReplace(vv,'@@[Name]','@@[NMO_Name]',ReplaceAllIgnoreCase);
     vv:=UnicodeStringReplace(vv,'@@[ShortName]','@@[NMO_BaseName]',ReplaceAllIgnoreCase);
     vv:=UnicodeStringReplace(vv,'@@[Name_Template]','@@[NMO_Template]',ReplaceAllIgnoreCase);
     vv:=UnicodeStringReplace(vv,'@@[Material]','@@[DB_link]',ReplaceAllIgnoreCase);
     vv:=UnicodeStringReplace(vv,'@@[HeadDevice]','@@[GC_HeadDevice]',ReplaceAllIgnoreCase);
     vv:=UnicodeStringReplace(vv,'@@[HeadDShortName]','@@[GC_HDShortName]',ReplaceAllIgnoreCase);
     vv:=UnicodeStringReplace(vv,'@@[GroupInHDevice]','@@[GC_HDGroup]',ReplaceAllIgnoreCase);
     vv:=UnicodeStringReplace(vv,'@@[NumberInSleif]','@@[GC_NumberInGroup]',ReplaceAllIgnoreCase);
     vv:=UnicodeStringReplace(vv,'@@[RoundTo]','@@[LENGTH_RoundTo]',ReplaceAllIgnoreCase);
     vv:=UnicodeStringReplace(vv,'@@[Cable_AddLength]','@@[LENGTH_Add]',ReplaceAllIgnoreCase);
     vv:=UnicodeStringReplace(vv,'@@[Cable_Scale]','@@[LENGTH_Scale]',ReplaceAllIgnoreCase);
     vv:=UnicodeStringReplace(vv,'@@[TotalConnectedDevice]','@@[CABLE_TotalCD]',ReplaceAllIgnoreCase);
     vv:=UnicodeStringReplace(vv,'@@[Segment]','@@[CABLE_Segment]',ReplaceAllIgnoreCase);
end;
procedure OldVersVarRename(var vn,vt,vv,vun:String);
var
   nevname{,nvv}:String;
   tt:string;
begin
     {ansitoutf8ifneed(vn);
     ansitoutf8ifneed(vt);}
     ansitoutf8ifneed(vv);
     ansitoutf8ifneed(vun);
     nevname:='';
     tt:=uppercase(vt);
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
     and (vt<>'String')  then
                           begin
                                vt:='String';
                           end;
     if (tt='GDBINTEGER')  then
                           begin
                                vt:='Integer';
                           end;
     if (tt='GDBDOUBLE')  then
                           begin
                                vt:='Double';
                           end;
     if (tt='GDBBOOLEAN')  then
                           begin
                                vt:='Boolean';
                           end;
     if (tt='GDBANSISTRING')  then
                           begin
                                vt:='AnsiString';
                           end;
     if (tt='GDBSTRING')  then
                           begin
                                vt:='String';
                           end;
     OldVersTextReplace(vv);
     if nevname<>'' then
                        begin
                             vn:=nevname;
                        end;

end;
procedure GDBObjGenericWithSubordinated.Build(var drawing:TDrawingDef);
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
procedure GDBObjGenericWithSubordinated.ImEdited(pobj:PGDBObjSubordinated;pobjinarray:Integer;var drawing:TDrawingDef);
begin
end;
procedure GDBObjGenericWithSubordinated.ImSelected(pobj:PGDBObjSubordinated;pobjinarray:Integer);
begin
end;
procedure GDBObjGenericWithSubordinated.DelSelectedSubitem(var drawing:TDrawingDef);
begin
end;
begin
end.

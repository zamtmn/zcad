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

unit UGDBLayerArray;
{$INCLUDE def.inc}
interface
uses gdbasetypes{,UGDBOpenArray,UGDBOpenArrayOfObjects,oglwindowdef},sysutils,gdbase, geometry,
     gl,
     varmandef,gdbobjectsconstdef,UGDBNamedObjectsArray,StrProc;
type
{EXPORT+}
PGDBLayerProp=^GDBLayerProp;
GDBLayerProp=object(GDBNamedObject)
               color:GDBByte;(*saved_to_shd*)(*'Цвет'*)
               lineweight:GDBSmallint;(*saved_to_shd*)(*'Вес линии'*)
               _on:GDBBoolean;(*saved_to_shd*)(*'Включен'*)
               _lock:GDBBoolean;(*saved_to_shd*)(*'Закрыт'*)
               _print:GDBBoolean;(*saved_to_shd*)(*'Печать'*)
               desk:GDBAnsiString;(*saved_to_shd*)(*'Коментарий'*)
               constructor Init(N:GDBString; C: GDBInteger; LW: GDBInteger;oo,ll,pp:GDBBoolean;d:GDBString);
               function GetFullName:GDBString;virtual;
         end;
PGDBLayerPropArray=^GDBLayerPropArray;
GDBLayerPropArray=array [0..0] of GDBLayerProp;
PGDBLayerArray=^GDBLayerArray;
GDBLayerArray=object(GDBNamedObjectsArray)(*OpenArrayOfData=GDBLayerProp*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    constructor initnul;

                    function addlayer(name:GDBString;color:GDBInteger;lw:GDBInteger;oo,ll,pp:GDBBoolean;d:GDBString;lm:TLoadOpt):PGDBLayerProp;virtual;
                    function GetSystemLayer:PGDBLayerProp;
                    function GetCurrentLayer:PGDBLayerProp;
              end;
{EXPORT-}
implementation
uses
    log;
constructor GDBLayerArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GDBLayerProp));
  addlayer(LNSysLayerName,CGDBWhile,lwgdbdefault,true,false,true,'',TLOLoad);
  addlayer(LNMetricLayerName,CGDBWhile,lwgdbdefault,false,false,false,'',TLOLoad);
end;
constructor GDBLayerArray.initnul;
begin
  inherited initnul;
  size:=sizeof(GDBLayerProp);
end;
constructor GDBLayerProp.Init(N:GDBString; C: GDBInteger; LW: GDBInteger;oo,ll,pp:GDBBoolean;d:GDBString);
begin
    initnul;
    SetName(n);
    color := c;
    lineweight := lw;
    _on:=oo;
    _lock:=ll;
    _print:=pp;
    desk:=d;
end;
function GDBLayerProp.GetFullName;
{const
     ls=24;}
//var ss:gdbstring;
begin
     result:=ansi2cp(getname);
     {  if _on then
                       ss:='[O'
                   else
                       ss:='[–';
       if _lock then
                       ss:=ss+'L'
                   else
                       ss:=ss+'–';
       if _print then
                       ss:=ss+'P] '
                   else
                       ss:=ss+'–] '; }
       result:={ss+}result;
end;
function GDBLayerArray.GetSystemLayer;
begin
     result:=getAddres(LNSysLayerName);
end;
function GDBLayerArray.GetCurrentLayer;
begin
     result:=getelement(sysvar.dwg.DWG_CLayer^);
end;
function GDBLayerArray.addlayer;
var
  p:PGDBLayerProp;
      //ir:itrec;
begin
     case AddItem(name,pointer(p)) of
             IsFounded:
                       begin
                            if lm=TLoadOpt.TLOLoad then
                            begin
                                 p^.color:=color;
                                 p^.lineweight:=lw;
                                 p^._on:=oo;
                                 p^._lock:=ll;
                                 p^._print:=pp;
                                 p^.desk:=d;
                            end;
                       end;
             IsCreated:
                       begin
                            p^.init(Name,Color,LW,oo,ll,pp,d);
                       end;
             IsError:
                       begin
                       end;
     end;
     result:=p;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBLayerArray.initialization');{$ENDIF}
end.

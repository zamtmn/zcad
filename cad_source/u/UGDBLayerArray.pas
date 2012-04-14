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
               color:GDBByte;(*saved_to_shd*)(*'Color'*)
               lineweight:GDBSmallint;(*saved_to_shd*)(*'Line weight'*)
               _on:GDBBoolean;(*saved_to_shd*)(*'On'*)
               _lock:GDBBoolean;(*saved_to_shd*)(*'Lock'*)
               _print:GDBBoolean;(*saved_to_shd*)(*'Print'*)
               desk:GDBAnsiString;(*saved_to_shd*)(*'Description'*)
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
                    function createlayerifneed(_source:PGDBLayerProp):PGDBLayerProp;
                    function createlayerifneedbyname(lname:GDBString;_source:PGDBLayerProp):PGDBLayerProp;
              end;
{EXPORT-}
implementation
uses
    log;
function  GDBLayerArray.createlayerifneedbyname(lname:GDBString;_source:PGDBLayerProp):PGDBLayerProp;
begin
           result:=getAddres(lname);
           if result=nil then
           begin
                if _source<>nil then
                result:=addlayer(_source.Name,
                                        _source.color,
                                        _source.lineweight,
                                        _source._on,
                                        _source._lock,
                                        _source._print,
                                        _source.desk,
                                        TLOMerge);
           end;
end;
function  GDBLayerArray.createlayerifneed(_source:PGDBLayerProp):PGDBLayerProp;
begin
           result:=createlayerifneedbyname(_source.Name,_source);
           {result:=getAddres(_source.Name);
           if result=nil then
           begin
                if _source<>nil then
                result:=addlayer(_source.Name,
                                        _source.color,
                                        _source.lineweight,
                                        _source._on,
                                        _source._lock,
                                        _source._print,
                                        _source.desk,
                                        TLOMerge);
           end;}
end;
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
                            if lm=TLOLoad then
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
                            if uppercase(name)='DEFPOINTS' then
                                                               p^.init(Name,Color,LW,oo,ll,false,d)
                            else
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

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

unit ugdbltypearray;
{$INCLUDE def.inc}
interface
uses Classes,UGDBStringArray,UGDBOpenArrayOfData,zcadsysvars,gdbasetypes{,UGDBOpenArray,UGDBOpenArrayOfObjects,oglwindowdef},sysutils,gdbase, geometry,
     gl,
     varmandef,gdbobjectsconstdef,UGDBNamedObjectsArray,StrProc;
type
{EXPORT+}
GDBDoubleArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBDouble*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
               end;
PGDBLtypeProp=^GDBLtypeProp;
GDBLtypeProp=object(GDBNamedObject)
               len:GDBDouble;(*'Length'*)
               strokesarray:GDBDoubleArray;(*'Strokes array'*)
               desk:GDBAnsiString;(*'Description'*)
               constructor init(n:GDBString);
               destructor done;virtual;
             end;
PGDBLtypePropArray=^GDBLtypePropArray;
GDBLtypePropArray=array [0..0] of GDBLtypeProp;
PGDBLtypeArray=^GDBLtypeArray;
GDBLtypeArray=object(GDBNamedObjectsArray)(*OpenArrayOfData=GDBLtypeProp*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    constructor initnul;
                    procedure LoadFromFile(fname:GDBString;lm:TLoadOpt);
                    {function addlayer(name:GDBString;color:GDBInteger;lw:GDBInteger;oo,ll,pp:GDBBoolean;d:GDBString;lm:TLoadOpt):PGDBLayerProp;virtual;
                    function GetSystemLayer:PGDBLayerProp;
                    function GetCurrentLayer:PGDBLayerProp;
                    function createlayerifneed(_source:PGDBLayerProp):PGDBLayerProp;
                    function createlayerifneedbyname(lname:GDBString;_source:PGDBLayerProp):PGDBLayerProp;}
              end;
{EXPORT-}
implementation
uses
    log;
type
    TSeek=(TSeekInterface,TSeekImplementation);
constructor GDBLtypeProp.init(n:GDBString);
begin
     inherited;
     len:=0;
     pointer(desk):=nil;
     strokesarray.init(10);
end;
destructor GDBLtypeProp.done;
begin
     strokesarray.done;
     inherited;
end;

constructor GDBLtypeArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GDBLtypeProp));
end;
constructor GDBLtypeArray.initnul;
begin
  inherited initnul;
  size:=sizeof(GDBLtypeProp);
end;
procedure GDBLtypeArray.LoadFromFile(fname:GDBString;lm:TLoadOpt);
var
   strings:TStringList=nil;
   line:GDBString;
   i:integer;
   WhatNeed:TSeek;
   LTName,LTDesk,LTClass:GDBString;
   p:PGDBLtypeProp;
function GetStr(var s: String): String;
var j:integer;
begin
     if length(s)>0 then
     begin
          if s[1]='[' then
                           begin
                                j:=pos(']',s);
                                result:=copy(s,2,j-2);
                                s:=copy(s,j+1,length(s)-j);
                                GetPredStr(s,',');
                           end
                       else
                           result:=GetPredStr(s,',');
     end
     else
        result:='';
end;

procedure CreateLineTypeFrom(var LT:GDBString;pltprop:PGDBLtypeProp);
var
   element:String;
   j:integer;
   stroke:GDBDouble;
begin
     pltprop^.init(LTName);
     element:=GetStr(LT);
     while element<>'' do
     begin
          stroke:=strtofloat(element);
          pltprop.len:=pltprop.len+abs(stroke);
          pltprop^.strokesarray.add(@stroke);
          element:=GetStr(LT);
     end;
end;

begin
     strings:=TStringList.Create;
     strings.LoadFromFile(fname);
     WhatNeed:=TSeekInterface;
     for i:=0 to strings.Count-1 do
     begin
          line:=strings.Strings[i];
          if length(line)>1 then
          case line[1] of
                         '*':begin
                                  if WhatNeed=TSeekInterface then
                                  begin
                                       LTName:=GetPredStr(line,',');
                                       LTName:=copy(LTName,2,length(LTName)-1);
                                       LTDesk:=Line;
                                       WhatNeed:=TSeekImplementation;
                                  end;
                             end;
                         'A':begin
                                  if WhatNeed=TSeekImplementation then
                                  begin
                                       LTClass:=GetPredStr(line,',');
                                       case AddItem(LTName,pointer(p)) of
                                                    IsFounded:
                                                              begin
                                                                   if lm=TLOLoad then
                                                                   begin
                                                                        {p^.color:=color;
                                                                        p^.lineweight:=lw;
                                                                        p^._on:=oo;
                                                                        p^._lock:=ll;
                                                                        p^._print:=pp;
                                                                        p^.desk:=d;}
                                                                   end;
                                                              end;
                                                    IsCreated:
                                                              begin
                                                                   CreateLineTypeFrom(line,p);
                                                                   {if uppercase(name)=LNSysDefpoints then
                                                                                                      p^.init(Name,Color,LW,oo,ll,false,d)
                                                                   else
                                                                   p^.init(Name,Color,LW,oo,ll,pp,d);}
                                                              end;
                                                    IsError:
                                                              begin
                                                              end;
                                            end;
                                       WhatNeed:=TSeekInterface;
                                  end;

                             end;
          end;
     end;

     strings.Destroy;
end;

constructor GDBDoubleArray.init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(gdbdouble));
end;
constructor GDBDoubleArray.initnul;
begin
  inherited initnul;
  size:=sizeof(gdbdouble);
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('ugdbltypearray.initialization');{$ENDIF}
end.

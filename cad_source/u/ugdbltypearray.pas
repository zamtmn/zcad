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
     UGDBTextStyleArray,UGDBOpenArrayOfObjects,
     varmandef,{gdbobjectsconstdef,}UGDBNamedObjectsArray,StrProc,shared;
const
     DefaultSHXHeight=1;
     DefaultSHXAngle=0;
     DefaultSHXX=0;
     DefaultSHXY=0;
type
{EXPORT+}
PTDashInfo=^TDashInfo;
TDashInfo=(TDIDash,TDIText,TDIShape);
TAngleDir=(TACAbs,TACRel,TACUpRight);
shxprop=packed record
                Height,Angle,X,Y:GDBDouble;
                AD:TAngleDir;
                PStyle:PGDBTextStyle;
        end;

BasicSHXDashProp=packed object(GDBaseObject)
                param:shxprop;
                constructor initnul;
          end;
PTextProp=^TextProp;
TextProp=packed object(BasicSHXDashProp)
                Text,Style:GDBString;
                //PFont:PGDBfont;
                constructor initnul;
                destructor done;virtual;
          end;
PShapeProp=^ShapeProp;
ShapeProp=packed object(BasicSHXDashProp)
                SymbolName,FontName:GDBString;
                Psymbol:PGDBsymdolinfo;
                constructor initnul;
                destructor done;virtual;
          end;
GDBDashInfoArray=packed object(GDBOpenArrayOfData)(*OpenArrayOfData=TDashInfo*)
               end;
GDBDoubleArray=packed object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBDouble*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
               end;
GDBShapePropArray=packed object(GDBOpenArrayOfObjects)(*OpenArrayOfObject=ShapeProp*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
               end;
GDBTextPropArray=packed object(GDBOpenArrayOfObjects)(*OpenArrayOfObject=TextProp*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
               end;
PGDBLtypeProp=^GDBLtypeProp;
GDBLtypeProp=packed object(GDBNamedObject)
               len:GDBDouble;(*'Length'*)
               h:GDBDouble;(*'Height'*)
               dasharray:GDBDashInfoArray;(*'DashInfo array'*)
               strokesarray:GDBDoubleArray;(*'Strokes array'*)
               shapearray:GDBShapePropArray;(*'Shape array'*)
               Textarray:GDBTextPropArray;(*'Text array'*)
               desk:GDBAnsiString;(*'Description'*)
               constructor init(n:GDBString);
               destructor done;virtual;
               procedure Format;virtual;
             end;
PGDBLtypePropArray=^GDBLtypePropArray;
GDBLtypePropArray=packed array [0..0] of GDBLtypeProp;
PGDBLtypeArray=^GDBLtypeArray;
GDBLtypeArray=packed object(GDBNamedObjectsArray)(*OpenArrayOfData=GDBLtypeProp*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    constructor initnul;
                    procedure LoadFromFile(fname:GDBString;lm:TLoadOpt);
                    function createltypeifneed(_source:PGDBLtypeProp;var _DestTextStyleTable:GDBTextStyleArray):PGDBLtypeProp;
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
procedure GDBLtypeProp.format;
var
   PSP:PShapeProp;
   PTP:PTextProp;
   {ir,}ir2:itrec;
   sh:double;
   i:integer;
   Psymbol:PGDBsymdolinfo;
   TDInfo:TTrianglesDataInfo;
begin
    h:=0;
    PSP:=shapearray.beginiterate(ir2);
                                       if PSP<>nil then
                                       repeat
                                             sh:=abs(psp^.Psymbol.SymMaxY*psp^.param.Height);
                                             if h<sh then
                                                         h:=sh;
                                             sh:=abs(psp^.Psymbol.SymMinY*psp^.param.Height);
                                             if h<sh then
                                                         h:=sh;
                                             PSP:=shapearray.iterate(ir2);
                                       until PSP=nil;
   PTP:=textarray.beginiterate(ir2);
                                      if PTP<>nil then
                                      repeat
                                            for i:=1 to length(PTP^.Text) do
                                            begin
                                                 if PTP^.param.PStyle<>nil then
                                                 begin
                                                 Psymbol:=PTP^.param.PStyle.pfont^.GetOrReplaceSymbolInfo(byte(PTP^.Text[i]),TDInfo);
                                                 sh:=abs(Psymbol.SymMaxY*PTP^.param.Height);
                                                 if h<sh then
                                                             h:=sh;
                                                 sh:=abs(Psymbol.SymMinY*PTP^.param.Height);
                                                 if h<sh then
                                                             h:=sh;
                                                 end;
                                            end;
                                            PTP:=textarray.iterate(ir2);
                                      until PTP=nil;

end;
constructor GDBLtypeProp.init(n:GDBString);
begin
     inherited;
     len:=0;
     pointer(desk):=nil;
     dasharray.init({$IFDEF DEBUGBUILD}'{9DA63ECC-B244-4EBD-A9AE-AB24F008B526}',{$ENDIF}10,sizeof(TDashInfo));
     strokesarray.init({$IFDEF DEBUGBUILD}'{70B68C69-C222-4BE5-BB48-B88F08BA7605}',{$ENDIF}10);
     shapearray.init({$IFDEF DEBUGBUILD}'{9174ED86-C17E-4683-9BD1-E1927A9F9B3E}',{$ENDIF}10);
     Textarray.init({$IFDEF DEBUGBUILD}'{0A026EC4-B78B-4973-9016-A02E4919B1C8}',{$ENDIF}10);
end;
destructor GDBLtypeProp.done;
begin
     self.desk:='';
     dasharray.done;
     strokesarray.done;
     shapearray.freeanddone;
     Textarray.freeanddone;
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
constructor TextProp.initnul;
begin
     killstring(Text);
     killstring(Style);
     param.PStyle:=nil;
     //param.PFont:=nil;
     inherited;
end;
destructor TextProp.done;
begin
     Text:='';
     Style:='';
     param.PStyle:=nil;
     //PFont:=nil;
end;
constructor BasicSHXDashProp.initnul;
begin
     param.Height:=DefaultSHXHeight;
     param.Angle:=DefaultSHXAngle;
     param.X:=DefaultSHXX;
     param.Y:=DefaultSHXY;
     param.AD:=TACRel;
     param.PStyle:=nil;
end;
constructor ShapeProp.initnul;
begin
     killstring(SymbolName);
     killstring(FontName);
     Psymbol:=nil;
     inherited;
end;
destructor ShapeProp.done;
begin
     SymbolName:='';
     FontName:='';
     Psymbol:=nil;
end;
function GDBLtypeArray.createltypeifneed(_source:PGDBLtypeProp;var _DestTextStyleTable:GDBTextStyleArray):PGDBLtypeProp;
var //p:GDBPointer;
    ir:itrec;
    psp:PShapeProp;
    sp:ShapeProp;
    ptp:PTextProp;
    tp:TextProp;
    i:integer;
begin
             result:=nil;
             if _source<>nil then
             begin
             result:=getAddres(_source.Name);
             if result=nil then
             begin
                  if _source<>nil then
                  begin
                       if AddItem(_source.Name,pointer(result))=IsCreated then
                       begin
                       result.init(_source.Name);
                       result.len:=_source.len;
                       _source.dasharray.copyto(@result.dasharray);
                       _source.strokesarray.copyto(@result.strokesarray);
                       //_source.shapearray.copyto(@result.shapearray);
                       psp:=_source.shapearray.beginiterate(ir);
                       if psp<>nil then
                       repeat
                             sp.initnul;
                             sp:=psp^;
                             i:=_DestTextStyleTable.FindStyle(sp.param.PStyle^.name,sp.param.PStyle^.UsedInLTYPE);
                             sp.param.PStyle:=_DestTextStyleTable.getelement(i);
                             sp.Psymbol:=sp.param.PStyle.pfont.GetOrCreateSymbolInfo(sp.Psymbol.Number);
                             result.shapearray.add(@sp);
                             pointer(sp.SymbolName):=nil;
                             pointer(sp.FontName):=nil;
                             psp:=_source.shapearray.iterate(ir);
                       until psp=nil;
                       ptp:=_source.textarray.beginiterate(ir);
                       if ptp<>nil then
                       repeat
                             tp.initnul;
                             tp:=ptp^;
                             i:=_DestTextStyleTable.FindStyle(tp.param.PStyle^.name,tp.param.PStyle^.UsedInLTYPE);
                             tp.param.PStyle:=_DestTextStyleTable.getelement(i);
                             //tp.Psymbol:=tp.param.PStyle.pfont.GetOrCreateSymbolInfo(tp.Psymbol.Number);
                             result.textarray.add(@tp);
                             //pointer(tp.SymbolName):=nil;
                             //pointer(tp.FontName):=nil;
                             pointer(tp.Text):=nil;
                             pointer(tp.Style):=nil;
                             ptp:=_source.textarray.iterate(ir);
                       until ptp=nil;
                       //_source.Textarray.copyto(@result.Textarray);
                       result.desk:=_source.desk;
                       end;
                  end;
             end;
             end;
end;

procedure GDBLtypeArray.LoadFromFile(fname:GDBString;lm:TLoadOpt);
var
   strings:TStringList{=nil};
   line:GDBString;
   i:integer;
   WhatNeed:TSeek;
   LTName{,LTDesk,LTClass}:GDBString;
   p:PGDBLtypeProp;
function GetStr(var s: GDBString; out dinfo:TDashInfo): String;
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
                                dinfo:=TDIText;
                           end
                       else
                           begin
                           result:=GetPredStr(s,',');
                           dinfo:=TDIDash;
                           end;
     end
     else
        result:='';
end;
procedure CreateLineTypeFrom(var LT:GDBString;pltprop:PGDBLtypeProp);
var
   element,subelement,{text_shape,font_style,}paramname:GDBString;
   j:integer;
   stroke:GDBDouble;
   dinfo:TDashInfo;
   SP:ShapeProp;
   TP:TextProp;
procedure GetParam(var SHXDashProp:BasicSHXDashProp);
begin
  subelement:=GetPredStr(element,',');
  while subelement<>'' do
  begin
       paramname:=Uppercase(GetPredStr(subelement,'='));
       stroke:=strtofloat(subelement);
       if paramname='X' then
                            SP.param.X:=stroke
  else if paramname='Y' then
                            SP.param.Y:=stroke
  else if paramname='S' then
                            SP.param.Height:=stroke
  else if paramname='A' then
                            begin
                                 SP.param.Angle:=stroke;
                                 SP.param.AD:=TACAbs;
                            end
  else if paramname='R' then
                            begin
                                 SP.param.Angle:=stroke;
                                 SP.param.AD:=TACRel;
                            end
  else if paramname='U' then
                            begin
                                 SP.param.Angle:=stroke;
                                 SP.param.AD:=TACUpRight;
                            end
  else shared.ShowError('CreateLineTypeFrom: unknow value "'+paramname+'"');
       subelement:=GetPredStr(element,',');
  end;
end;
begin
     pltprop^.init(LTName);
     element:=GetStr(LT,dinfo);
     while element<>'' do
     begin
          case dinfo of
                       TDIDash:begin
                                    stroke:=strtofloat(element);
                                    pltprop.len:=pltprop.len+abs(stroke);
                                    pltprop^.strokesarray.add(@stroke);
                               end;
                       TDIText:begin
                                    j:=pos('"',element);
                                    if j>0 then
                                               begin
                                                    TP.initnul;
                                                    TP.Text:=GetPredStr(element,',');
                                                    TP.Style:=GetPredStr(element,',');
                                                    GetParam(TP);
                                                    pltprop^.Textarray.add(@TP);
                                                    killstring(TP.Text);
                                                    killstring(TP.Style);
                                                    TP.done;
                                               end
                                           else
                                               begin
                                                    dinfo:=TDIShape;
                                                    SP.initnul;
                                                    SP.SymbolName:=GetPredStr(element,',');
                                                    SP.FontName:=GetPredStr(element,',');
                                                    GetParam(SP);
                                                    pltprop^.shapearray.add(@SP);
                                                    killstring(SP.SymbolName);
                                                    killstring(SP.FontName);
                                                    SP.done;
                                               end;
                               end;

          end;
          pltprop^.dasharray.Add(@dinfo);
          element:=GetStr(LT,dinfo);
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
                                       //LTDesk:=Line;
                                       WhatNeed:=TSeekImplementation;
                                  end;
                             end;
                         'A':begin
                                  if WhatNeed=TSeekImplementation then
                                  begin
                                       {LTClass:=}GetPredStr(line,',');
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
constructor GDBShapePropArray.init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(ShapeProp));
end;
constructor GDBTextPropArray.init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(TextProp));
end;

begin
  {$IFDEF DEBUGINITSECTION}LogOut('ugdbltypearray.initialization');{$ENDIF}
end.

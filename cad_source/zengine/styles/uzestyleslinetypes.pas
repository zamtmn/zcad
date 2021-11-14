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

unit uzestyleslinetypes;
{$INCLUDE def.inc}
interface
uses LCLProc,LazUTF8,Classes,gzctnrvectordata,uzbtypesbase,sysutils,uzbtypes,
     uzegeometry,uzestylestexts,gzctnrvectorobjects,UGDBNamedObjectsArray,
     gzctnrvectortypes,uzbstrproc;
const
     DefaultSHXHeight=1;
     DefaultSHXAngle=0;
     DefaultSHXX=0;
     DefaultSHXY=0;
type
{EXPORT+}
TLTMode=(TLTContinous,TLTByLayer,TLTByBlock,TLTLineType);
PTDashInfo=^TDashInfo;
TDashInfo=(TDIDash,TDIText,TDIShape);
TOuterDashInfo=(TODIUnknown,TODIShape,TODIPoint,TODILine,TODIBlank);
TAngleDir=(TACAbs,TACRel,TACUpRight);
{REGISTERRECORDTYPE shxprop}
shxprop=record
                Height,Angle,X,Y:GDBDouble;
                AD:TAngleDir;
                PStyle:PGDBTextStyle;
                PstyleIsHandle:GDBBoolean;
        end;
{REGISTEROBJECTTYPE BasicSHXDashProp}
BasicSHXDashProp= object(GDBaseObject)
                param:shxprop;
                constructor initnul;
          end;
PTextProp=^TextProp;
{REGISTEROBJECTTYPE TextProp}
TextProp= object(BasicSHXDashProp)
                Text,Style:GDBString;
                txtL,txtH:GDBDouble;
                //PFont:PGDBfont;
                constructor initnul;
                destructor done;virtual;
          end;
PShapeProp=^ShapeProp;
{REGISTEROBJECTTYPE ShapeProp}
ShapeProp= object(BasicSHXDashProp)
                SymbolName,FontName:GDBString;
                Psymbol:PGDBsymdolinfo;
                constructor initnul;
                destructor done;virtual;
          end;
{REGISTEROBJECTTYPE GDBDashInfoArray}
GDBDashInfoArray= object(GZVectorData{-}<TDashInfo>{//})(*OpenArrayOfData=TDashInfo*)
               end;
{REGISTEROBJECTTYPE GDBDoubleArray}
GDBDoubleArray= object(GZVectorData{-}<GDBDouble>{//})(*OpenArrayOfData=GDBDouble*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
               end;
{REGISTEROBJECTTYPE GDBShapePropArray}
GDBShapePropArray= object(GZVectorObjects{-}<ShapeProp>{//})(*OpenArrayOfObject=ShapeProp*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
               end;
{REGISTEROBJECTTYPE GDBTextPropArray}
GDBTextPropArray= object(GZVectorObjects{-}<TextProp>{//})(*OpenArrayOfObject=TextProp*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
               end;
PPGDBLtypePropObjInsp=^PGDBLtypePropObjInsp;
PGDBLtypePropObjInsp=GDBPointer;
PGDBLtypeProp=^GDBLtypeProp;
{REGISTEROBJECTTYPE GDBLtypeProp}
GDBLtypeProp= object(GDBNamedObject)
               LengthDXF,LengthFact:GDBDouble;(*'Length'*)
               h:GDBDouble;(*'Height'*)
               Mode:TLTMode;
               FirstStroke,LastStroke:TOuterDashInfo;
               WithoutLines:GDBBoolean;
               dasharray:GDBDashInfoArray;(*'DashInfo array'*)
               strokesarray:GDBDoubleArray;(*'Strokes array'*)
               shapearray:GDBShapePropArray;(*'Shape array'*)
               Textarray:GDBTextPropArray;(*'Text array'*)
               desk:GDBAnsiString;(*'Description'*)
               constructor init(n:GDBString);
               destructor done;virtual;
               procedure Format;virtual;
               function GetAsText:GDBString;
               function GetLTString:GDBString;
               procedure CreateLineTypeFrom(var LT:GDBString);
             end;
PGDBLtypePropArray=^GDBLtypePropArray;
GDBLtypePropArray=packed array [0..0] of GDBLtypeProp;
PGDBLtypeArray=^GDBLtypeArray;
{REGISTEROBJECTTYPE GDBLtypeArray}
GDBLtypeArray= object(GDBNamedObjectsArray{-}<PGDBLtypeProp,GDBLtypeProp>{//})(*OpenArrayOfData=GDBLtypeProp*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    constructor initnul;
                    procedure LoadFromFile(fname:GDBString;lm:TLoadOpt);
                    procedure ParseStrings(const ltd:tstrings; var CurrentLine:integer;out LTName,LTDesk,LTImpl:GDBString);
                    function createltypeifneed(_source:PGDBLtypeProp;var _DestTextStyleTable:GDBTextStyleArray):PGDBLtypeProp;
                    function GetSystemLT(neededtype:TLTMode):PGDBLtypeProp;
                    procedure format;virtual;
                    {function addlayer(name:GDBString;color:GDBInteger;lw:GDBInteger;oo,ll,pp:GDBBoolean;d:GDBString;lm:TLoadOpt):PGDBLayerProp;virtual;
                    function GetSystemLayer:PGDBLayerProp;
                    function GetCurrentLayer:PGDBLayerProp;
                    function createlayerifneed(_source:PGDBLayerProp):PGDBLayerProp;
                    function createlayerifneedbyname(lname:GDBString;_source:PGDBLayerProp):PGDBLayerProp;}
              end;
{EXPORT-}
implementation
//uses
//    log;
type
    TSeek=(TSeekInterface,TSeekImplementation);
procedure GDBLtypeArray.format;
var
   ir:itrec;
   pltypeprop:PGDBLtypeProp;
begin
  pltypeprop:=beginiterate(ir);
  if pltypeprop<>nil then
  repeat
        pltypeprop^.Format;

        pltypeprop:=iterate(ir);
  until pltypeprop=nil;
end;
function GDBLtypeArray.GetSystemLT(neededtype:TLTMode):PGDBLtypeProp;
var
   ir:itrec;
begin
  result:=beginiterate(ir);
  if result<>nil then
  repeat
    if result^.Mode=neededtype then
                                     exit;
    result:=iterate(ir);
  until result=nil;
end;
function getshapestring(PSP:PShapeProp):gdbstring;
begin
     result:='['+psp^.SymbolName+','+psp^.FontName;
     case psp^.param.AD of
                    TACAbs:result:=result+',A='+floattostr(psp^.param.Angle);
                    TACRel:result:=result+',R='+floattostr(psp^.param.Angle);
                TACUpRight:result:=result+',U='+floattostr(psp^.param.Angle);
     end;
     result:=result+',S='+floattostr(psp^.param.Height);
     result:=result+',X='+floattostr(psp^.param.X);
     result:=result+',Y='+floattostr(psp^.param.Y);
     result:=result+']'
end;
function gettextstring(PTP:PTextProp):gdbstring;
begin
  result:='["'+PTP^.Text+'",'+PTP^.Style;
  case ptp^.param.AD of
                 TACAbs:result:=result+',A='+floattostr(ptp^.param.Angle);
                 TACRel:result:=result+',R='+floattostr(ptp^.param.Angle);
             TACUpRight:result:=result+',U='+floattostr(ptp^.param.Angle);
  end;
  result:=result+',S='+floattostr(ptp^.param.Height);
  result:=result+',X='+floattostr(ptp^.param.X);
  result:=result+',Y='+floattostr(ptp^.param.Y);
  result:=result+']'
end;

function GDBLtypeProp.GetLTString:GDBString;
var
    TDI:PTDashInfo;
    PStroke:PGDBDouble;
    PSP:PShapeProp;
    PTP:PTextProp;
    ir2,ir3,ir4,ir5:itrec;
begin
  begin
    result:='';
    TDI:=dasharray.beginiterate(ir2);
    PStroke:=strokesarray.beginiterate(ir3);
    PSP:=shapearray.beginiterate(ir4);
    PTP:=textarray.beginiterate(ir5);
    if PStroke<>nil then
    repeat
    case TDI^ of
        TDIDash:begin
                     result:=result+','+floattostr(PStroke^);
                     PStroke:=strokesarray.iterate(ir3);
                end;
       TDIShape:begin
                     result:=result+','+getshapestring(PSP);
                     PSP:=shapearray.iterate(ir4);
                end;
        TDIText:begin
                     result:=result+','+gettextstring(PTP);
                     PTP:=textarray.iterate(ir5);
                 end;
          end;
          TDI:=dasharray.iterate(ir2);
    until TDI=nil;
end;
end;
function GDBLtypeProp.GetAsText:GDBString;
begin
     if mode<>TLTLineType then
                                   result:='This is system layer!!!'
                               else
                                   begin
                                        result:='*'+self.Name+','+self.desk+#13#10'A'+GetLTString;
                                   end;
end;

procedure GDBLtypeProp.format;
var
   PSP:PShapeProp;
   PTP:PTextProp;
   {ir,}ir2:itrec;
   sh:double;
   i:integer;
   Psymbol:PGDBsymdolinfo;
   //-ttf-//TDInfo:TTrianglesDataInfo;
   sym:integer;
procedure processH(Psymbol:PGDBsymdolinfo;param:shxprop);
begin
  if Psymbol<>nil then
  begin
  sh:=abs(param.Y+Psymbol.SymMaxY*param.Height);
  if h<sh then
              h:=sh;
  sh:=abs(param.Y+Psymbol.SymMinY*param.Height);
  if h<sh then
              h:=sh;
  sh:=abs(param.Y-Psymbol.SymMinY*param.Height);
  if h<sh then
              h:=sh;
  sh:=abs(param.Y-Psymbol.SymMinY*param.Height);
  if h<sh then
              h:=sh;
  sh:=abs(param.x+Psymbol.NextSymX*param.Height);
  if h<sh then
              h:=sh;
  end;
end;

begin
    h:=0;
    PSP:=shapearray.beginiterate(ir2);
                                       if PSP<>nil then
                                       repeat
                                             {if psp.param.PstyleIsHandle then
                                                                             begin
                                                                                  psp.Psymbol:=nil;
                                                                                  psp.param.PStyle:=nil;
                                                                             end
                                                                         else}
                                                                             processH(psp.Psymbol,psp^.param);
                                             PSP:=shapearray.iterate(ir2);
                                       until PSP=nil;
   PTP:=textarray.beginiterate(ir2);
                                      if PTP<>nil then
                                      repeat
                                            PTP.txtL:=0;
                                            PTP.txtH:=0;
                                            for i:=1 to length(PTP^.Text) do
                                            begin
                                                 if PTP^.param.PStyle<>nil then
                                                 begin
                                                      sym:=byte(PTP^.Text[i]);
                                                      if ptp.param.PStyle.pfont.font.unicode then
                                                                                                 sym:=ach2uch(sym);
                                                 Psymbol:=PTP^.param.PStyle.pfont^.GetOrReplaceSymbolInfo(byte(sym){//-ttf-//,TDInfo});
                                                 processH(Psymbol,PTP^.param);
                                                 if PTP.txtH<Psymbol.SymMaxY*PTP.param.Height then
                                                                                                  PTP.txtH:=Psymbol.SymMaxY*PTP.param.Height;
                                                 PTP.txtL:=PTP.txtL+Psymbol.NextSymX*PTP^.param.Height;
                                                 end;
                                            end;
                                            PTP.txtL:=PTP.txtL-(Psymbol.NextSymX-Psymbol.SymMaxX)*PTP^.param.Height;
                                            if h<PTP.txtL then
                                                          h:=PTP.txtL;
                                            PTP.txtH:=PTP.txtH/2;
                                            PTP.txtL:=PTP.txtL/2;
                                            PTP:=textarray.iterate(ir2);
                                      until PTP=nil;

end;
function N2TLTMode(n:GDBString):TLTMode;
begin
     n:=lowercase(n);
     if n='continuous' then
                           result:=TLTMode.TLTContinous
else if n='bylayer' then
                           result:=TLTMode.TLTByLayer
else if n='byblock' then
                           result:=TLTMode.TLTByBlock
else
    result:=TLTMode.TLTLineType;
end;

constructor GDBLtypeProp.init(n:GDBString);
begin
     inherited;
     FirstStroke:=TODIUnknown;
     LastStroke:=TODIUnknown;
     WithoutLines:=true;
     Mode:=N2TLTMode(n);
     LengthDXF:=0;
     LengthFact:=0;
     pointer(desk):=nil;
     dasharray.init({$IFDEF DEBUGBUILD}'{9DA63ECC-B244-4EBD-A9AE-AB24F008B526}',{$ENDIF}10{,sizeof(TDashInfo)});
     strokesarray.init({$IFDEF DEBUGBUILD}'{70B68C69-C222-4BE5-BB48-B88F08BA7605}',{$ENDIF}10);
     shapearray.init({$IFDEF DEBUGBUILD}'{9174ED86-C17E-4683-9BD1-E1927A9F9B3E}',{$ENDIF}10);
     Textarray.init({$IFDEF DEBUGBUILD}'{0A026EC4-B78B-4973-9016-A02E4919B1C8}',{$ENDIF}10);
end;
destructor GDBLtypeProp.done;
begin
     self.desk:='';
     dasharray.done;
     strokesarray.done;
     shapearray.done;
     Textarray.done;
     inherited;
end;

constructor GDBLtypeArray.init;
var
   plp:PGDBLtypeProp;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m);
  if AddItem('Continuous',pointer(plp))=IsCreated then
            begin
                 plp.init('Continuous');
                 plp.LengthDXF:=0;
                 plp.LengthFact:=0;
                 plp.Mode:=TLTContinous;
            end;
end;
constructor GDBLtypeArray.initnul;
begin
  inherited initnul;
  //objsizeof:=sizeof(GDBLtypeProp);
  //size:=sizeof(GDBLtypeProp);
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
                       result.LengthFact:=_source.LengthFact;
                       result.LengthDXF:=_source.LengthDXF;
                       _source.dasharray.copyto(result.dasharray);
                       _source.strokesarray.copyto(result.strokesarray);
                       //_source.shapearray.copyto(@result.shapearray);
                       psp:=_source.shapearray.beginiterate(ir);
                       if psp<>nil then
                       repeat
                             sp.initnul;
                             sp:=psp^;
                             //i:=_DestTextStyleTable.FindStyle(sp.param.PStyle^.name,sp.param.PStyle^.UsedInLTYPE);
                             sp.param.PStyle:=_DestTextStyleTable.FindStyle(sp.param.PStyle^.name,sp.param.PStyle^.UsedInLTYPE);//_DestTextStyleTable.getelement(i);
                             sp.Psymbol:=sp.param.PStyle.pfont.GetOrCreateSymbolInfo(sp.Psymbol.Number);
                             result.shapearray.PushBackData(sp);
                             pointer(sp.SymbolName):=nil;
                             pointer(sp.FontName):=nil;
                             psp:=_source.shapearray.iterate(ir);
                       until psp=nil;
                       ptp:=_source.textarray.beginiterate(ir);
                       if ptp<>nil then
                       repeat
                             tp.initnul;
                             tp:=ptp^;
                             //i:=_DestTextStyleTable.FindStyle(tp.param.PStyle^.name,tp.param.PStyle^.UsedInLTYPE);
                             tp.param.PStyle:=_DestTextStyleTable.FindStyle(tp.param.PStyle^.name,tp.param.PStyle^.UsedInLTYPE);//_DestTextStyleTable.getelement(i);
                             //tp.Psymbol:=tp.param.PStyle.pfont.GetOrCreateSymbolInfo(tp.Psymbol.Number);
                             result.textarray.PushBackData(tp);
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
procedure GDBLtypeArray.ParseStrings(const ltd:tstrings; var CurrentLine:integer;out LTName,LTDesk,LTImpl:GDBString);
var
   line:GDBString;
   i:integer;
   WhatNeed:TSeek;
begin
     LTName:='';
     LTDesk:='';
     LTImpl:='';
     WhatNeed:=TSeekInterface;
     for i:=CurrentLine-1 to ltd.Count-1 do
     begin
          line:=ltd.Strings[i];
          inc(CurrentLine);
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
                                       {LTClass:=}GetPredStr(line,',');
                                       LTImpl:=line;
                                       exit;
                                  end;

                             end;
          end;
     end;
end;
procedure GDBLtypeProp.CreateLineTypeFrom(var LT:GDBString);
var
   element,subelement,{text_shape,font_style,}paramname:GDBString;
   j:integer;
   stroke:GDBDouble;
   dinfo:TDashInfo;
   SP:ShapeProp;
   TP:TextProp;

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
procedure GetParam(var SHXDashProp:BasicSHXDashProp);
begin
  subelement:=GetPredStr(element,',');
  while subelement<>'' do
  begin
       paramname:=Uppercase(GetPredStr(subelement,'='));
       stroke:=strtofloat(subelement);
       if paramname='X' then
                            SHXDashProp.param.X:=stroke
  else if paramname='Y' then
                            SHXDashProp.param.Y:=stroke
  else if paramname='S' then
                            SHXDashProp.param.Height:=stroke
  else if paramname='A' then
                            begin
                                 SHXDashProp.param.Angle:=stroke;
                                 SHXDashProp.param.AD:=TACAbs;
                            end
  else if paramname='R' then
                            begin
                                 SHXDashProp.param.Angle:=stroke;
                                 SHXDashProp.param.AD:=TACRel;
                            end
  else if paramname='U' then
                            begin
                                 SHXDashProp.param.Angle:=stroke;
                                 SHXDashProp.param.AD:=TACUpRight;
                            end
  else
      debugln('{EH}CreateLineTypeFrom: unknow value "'+paramname+'"');
      //programlog.LogOutStr('CreateLineTypeFrom: unknow value "'+paramname+'"',lp_OldPos,LM_Error);
       //ShowError('CreateLineTypeFrom: unknow value "'+paramname+'"');
       subelement:=GetPredStr(element,',');
  end;
end;
begin
     strokesarray.Clear;
     Textarray.Clear;
     shapearray.Clear;
     dasharray.Clear;
     element:=GetStr(LT,dinfo);
     LengthFact:=0;
     LengthDXF:=0;
     stroke:=1;
     while element<>'' do
     begin
          case dinfo of
                       TDIDash:begin
                                    trystrtofloat(element,stroke);
                                    LengthFact:=LengthFact+abs(stroke);
                                    LengthDXF:=LengthDXF+abs(stroke);
                                    strokesarray.PushBackData(stroke);
                                    if stroke>eps then
                                                      begin
                                                           LastStroke:=TODILine;
                                                           WithoutLines:=false;
                                                      end
                                    else if stroke<-eps then
                                                      LastStroke:=TODIBlank
                                    else LastStroke:=TODIPoint;
                                    if FirstStroke=TODIUnknown then
                                                                   FirstStroke:=LastStroke;
                               end;
                       TDIText:begin
                                    LastStroke:=TODIShape;
                                    if FirstStroke=TODIUnknown then
                                                                   FirstStroke:=LastStroke;
                                    j:=pos('"',element);
                                    if j>0 then
                                               begin
                                                    TP.initnul;
                                                    TP.Text:=trim(GetPredStr(element,','));
                                                    if length(TP.Text)>1 then
                                                                             if TP.Text[1]='"' then
                                                                                                   TP.Text[1]:=' ';
                                                    if length(TP.Text)>1 then
                                                                             if TP.Text[length(TP.Text)]='"' then
                                                                                                                 TP.Text[length(TP.Text)]:=' ';
                                                    TP.Text:=trim(TP.Text);
                                                    TP.Style:=trim(GetPredStr(element,','));
                                                    GetParam(TP);
                                                    Textarray.PushBackData(TP);
                                                    //killstring(TP.Text);
                                                    //killstring(TP.Style);
                                                    TP.done;
                                               end
                                           else
                                               begin
                                                    dinfo:=TDIShape;
                                                    SP.initnul;
                                                    SP.SymbolName:=GetPredStr(element,',');
                                                    SP.FontName:=GetPredStr(element,',');
                                                    GetParam(SP);
                                                    shapearray.PushBackData(SP);
                                                    //killstring(SP.SymbolName);
                                                    //killstring(SP.FontName);
                                                    SP.done;
                                               end;
                               end;

          end;
          dasharray.PushBackData(dinfo);
          element:=GetStr(LT,dinfo);
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
begin
     //Переделать используя ParseStrings или выкинуть нахуй
     if fname='' then exit;
     strings:=TStringList.Create;
     strings.LoadFromFile({$IFNDEF DELPHI}utf8tosys{$ENDIF}(fname));
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
                                                                   p^.init(LTName);
                                                                   p^.CreateLineTypeFrom(line);
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
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m{,sizeof(gdbdouble)});
end;
constructor GDBShapePropArray.init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m{,sizeof(ShapeProp)});
end;
constructor GDBTextPropArray.init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m{,sizeof(TextProp)});
end;

begin
end.

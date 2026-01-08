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

unit uzestylesdim;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses
  uzepalette,uzeconsts,uzestyleslinetypes,uzestylestexts,usimplegenerics,
  uzbUnits,
  sysutils,uzegeometry,
  gzctnrVectorTypes,uzbstrproc,UGDBNamedObjectsArray,uzeffdxfsupport,
  uzeNamedObject,uzeTypes;
const
     DIMLWEDefaultValue=LnWtByBlock;
     DIMCLREDefaultValue=ClByBlock;
     DIMLWDDefaultValue=LnWtByBlock;
     DIMCLRDDefaultValue=ClByBlock;
     DIMCLRTDefaultValue=ClByBlock;
type
TDimStyleReadMode=(TDSRM_ACAD,
                   TDSRM_ACAD_DSTYLE_DIM_LINETYPE,
                   TDSRM_ACAD_DSTYLE_DIM_EXT1_LINETYPE,
                   TDSRM_ACAD_DSTYLE_DIM_EXT2_LINETYPE);
TDimArrowBlockParam=record
                     name:String;
                     width:Double;
               end;

TDimTextVertPosition=(DTVPCenters,DTVPAbove,DTVPOutside,DTVPJIS,DTVPBellov);
TArrowStyle=(TSClosedFilled,TSClosedBlank,TSClosed,TSDot,TSArchitecturalTick,TSOblique,TSOpen,TSOriginIndicator,TSOriginIndicator2,
            TSRightAngle,TSOpen30,TSDotSmall,TSDotBlank,TSDotSmallBlank,TSBox,TSBoxFilled,TSDatumTriangle,TSDatumtTriangleFilled,TSIntegral,TSUserDef);
TDimTextMove=(DTMMoveDimLine,DTMCreateLeader,DTMnothung);

TDimStyleDXFLoadingData=record
                              TextStyleName:string;
                              DIMBLK1handle,DIMBLK2handle,DIMLDRBLKhandle:TDWGHandle;
                        end;
PTDimStyleDXFLoadingData=^TDimStyleDXFLoadingData;

TGDBDimLinesProp=record
                       //выносные линии
                       DIMEXE:Double;//Extension line extension//group44
                       DIMEXO:Double;//Extension line offset//group42
                       DIMLWE:TGDBLineWeight;//DIMLWD (lineweight enum value)//group372
                       DIMCLRE:TGDBPaletteColor;//DIMCLRE//group177
                       DIMLTEX1,DIMLTEX2:PGDBLtypeProp;
                       //размерные линии
                       DIMDLE:Double;//Dimension line extension//group46
                       DIMCEN:Double;//Size of center mark/lines//group141
                       //DIMLTYPE:PGDBLtypeProp;//Size of center mark/lines//group141
                       DIMLWD:TGDBLineWeight;//DIMLWD (lineweight enum value)//group371
                       DIMCLRD:TGDBPaletteColor;//DIMCLRD//group176
                       DIMLTYPE:PGDBLtypeProp;
                 end;

TGDBDimArrowsProp=record
                       DIMASZ:Double; //Dimensioning arrow size//group41
                       DIMBLK1:TArrowStyle;//First arrow block name//group343
                       DIMBLK2:TArrowStyle;//First arrow block name//group344
                       DIMLDRBLK:TArrowStyle;//Arrow block name for leaders//group341
                  end;

TGDBDimTextProp=record
                       DIMTXT:Double; //Text size//group140
                       DIMTIH:Boolean;//Text inside horizontal if nonzero//group73
                       DIMTOH:Boolean;//Text outside horizontal if nonzero//group74
                       DIMTAD:TDimTextVertPosition;//Text above dimension line if nonzero//group77
                       DIMGAP:Double; //Dimension line gap //Смещение текста//group147
                       DIMTXSTY:PGDBTextStyle;//340 DIMTXSTY (handle of referenced STYLE)
                       DIMCLRT:TGDBPaletteColor;//DIMCLRT//group176
                 end;

TGDBDimPlacingProp=record
                       DIMTMOVE:TDimTextMove;
                 end;

TGDBDimUnitsProp=record
                       DIMLFAC:Double;//Linear measurements scale factor//group144
                       DIMLUNIT:TDimUnit;//Sets units for all dimension types except Angular://group277
                       DIMDEC:Integer;//Number of decimal places for the tolerance values of a primary units dimension//group271
                       DIMDSEP:TDimDSep;//Single-character decimal separator used when creating dimensions whose unit format is decimal//group278
                       DIMRND:Double;//Rounding value for dimension distances//group45
                       DIMPOST:AnsiString; //Dimension prefix<>suffix //group3
                       DIMSCALE:Double;//DIMSCALE//group40
                       DIMZIN:Integer;//Controls the suppression of zeros in the primary unit values//group78
                 end;

PGDBDimStyleObjInsp=Pointer;
PPGDBDimStyleObjInsp=^PGDBDimStyleObjInsp;

GDBDimStyle = object(GDBNamedObject)
                      Lines:TGDBDimLinesProp;
                      Arrows:TGDBDimArrowsProp;
                      Text:TGDBDimTextProp;
                      Placing:TGDBDimPlacingProp;
                      Units:TGDBDimUnitsProp;
                      PDXFLoadingData:PTDimStyleDXFLoadingData;
                      procedure SetDefaultValues;virtual;
                      procedure SetValueFromDxf(var mode:TDimStyleReadMode;group:Integer;value:String;var context:TIODXFLoadContext);virtual;
                      function GetDimBlockParam(nline:Integer):TDimArrowBlockParam;
                      function GetDimBlockTypeByName(bname:String):TArrowStyle;
                      procedure CreateLDIfNeed;
                      procedure ReleaseLDIfNeed;
                      procedure ResolveDXFHandles(const Handle2BlockName:TMapBlockHandle_BlockNames);
                      procedure ResolveTextstyles(const tst:TGenericNamedObjectsArray);
                      destructor Done;virtual;
             end;
PGDBDimStyle=^GDBDimStyle;



PGDBDimStyleArray=^GDBDimStyleArray;
GDBDimStyleArray= object(GDBNamedObjectsArray<PGDBDimStyle,GDBDimStyle>)
                    constructor init(m:Integer);
                    constructor initnul;
                    procedure ResolveDXFHandles(const Handle2BlockName:TMapBlockHandle_BlockNames);
                    procedure ResolveTextstyles(const tst:TGenericNamedObjectsArray);
                    procedure ResolveLineTypes(const lta:GDBLtypeArray);
              end;
TDimArrowBlockArray=array[TArrowStyle] of TDimArrowBlockParam;
var
     DimArrows:TDimArrowBlockArray=(
                                    (name:'_ClosedFilled';width:1),
                                    (name:'_ClosedBlank';width:1),
                                    (name:'_Closed';width:1),
                                    (name:'_Dot';width:0),
                                    (name:'_ArchTick';width:0),
                                    (name:'_Oblique';width:0),
                                    (name:'_Open';width:1),
                                    (name:'_Origin';width:1),
                                    (name:'_Origin2';width:1),
                                    (name:'_Open90';width:0),
                                    (name:'_Open30';width:0),
                                    (name:'_DotSmall';width:0),
                                    (name:'_DotBlank';width:1),
                                    (name:'_Small';width:0),
                                    (name:'_BoxBlank';width:1),
                                    (name:'_BoxFilled';width:1),
                                    (name:'_DatumBlank';width:1),
                                    (name:'_DatumFilled';width:1),
                                    (name:'_Integral';width:0),
                                    (name:'_ClosedFilled';width:1)
                                    );
implementation
//uses {UGDBDescriptor,}{io,}log;
destructor GDBDimStyle.Done;
begin
     units.DIMPOST:='';
     ReleaseLDIfNeed;
     inherited;
end;
procedure GDBDimStyle.ResolveTextstyles(const tst:TGenericNamedObjectsArray);
begin
     if PDXFLoadingData<>nil then
       if PDXFLoadingData.TextStyleName<>'' then
         Text.DIMTXSTY:=tst.getAddres(PDXFLoadingData.TextStyleName)
end;
procedure GDBDimStyle.ResolveDXFHandles(const Handle2BlockName:TMapBlockHandle_BlockNames);
{NEEDFIXFORDELPHI}
{$IFNDEF DELPHI}
var Iterator:TMapBlockHandle_BlockNames.TIterator;
    BlockName:string;
{$ENDIF}
begin
{$IFNDEF DELPHI}
     if PDXFLoadingData<>nil then
     begin
          if PDXFLoadingData^.DIMLDRBLKhandle<>0 then
          begin
               Iterator:=Handle2BlockName.Find(PDXFLoadingData^.DIMLDRBLKhandle);
               if  Iterator<>nil then
                                    begin
                                         BlockName:=Iterator.GetValue;
                                         Iterator.Destroy;
                                         arrows.DIMLDRBLK:=GetDimBlockTypeByName(BlockName);
                                    end;
          end;
          if PDXFLoadingData^.DIMBLK1handle<>0 then
          begin
               Iterator:=Handle2BlockName.Find(PDXFLoadingData^.DIMBLK1handle);
               if  Iterator<>nil then
                                    begin
                                         BlockName:=Iterator.GetValue;
                                         Iterator.Destroy;
                                         arrows.DIMBLK1:=GetDimBlockTypeByName(BlockName);
                                    end;
          end;
          if PDXFLoadingData^.DIMBLK2handle<>0 then
          begin
               Iterator:=Handle2BlockName.Find(PDXFLoadingData^.DIMBLK2handle);
               if  Iterator<>nil then
                                    begin
                                         BlockName:=Iterator.GetValue;
                                         Iterator.Destroy;
                                         arrows.DIMBLK2:=GetDimBlockTypeByName(BlockName);
                                    end;
          end;
     end;
{$ENDIF}
end;

procedure GDBDimStyle.CreateLDIfNeed;
begin
     if PDXFLoadingData=nil then
     begin
          Getmem(pointer(PDXFLoadingData),SizeOf(PDXFLoadingData^));
          pointer(PDXFLoadingData^.TextStyleName):=nil;
          PDXFLoadingData^.DIMBLK1handle:=0;
          PDXFLoadingData^.DIMBLK2handle:=0;
          PDXFLoadingData^.DIMLDRBLKhandle:=0;
     end;
end;
procedure GDBDimStyle.ReleaseLDIfNeed;
begin
     if PDXFLoadingData<>nil then
     begin
          PDXFLoadingData^.TextStyleName:='';
          Freemem(pointer(PDXFLoadingData));
     end;
end;
function GDBDimStyle.GetDimBlockParam(nline:Integer):TDimArrowBlockParam;
begin
     case nline of
                 0:result:=DimArrows[Arrows.DIMBLK1];
                 1:result:=DimArrows[Arrows.DIMBLK2];
                 else result:=DimArrows[Arrows.DIMLDRBLK];
     end;
end;
function GDBDimStyle.GetDimBlockTypeByName(bname:String):TArrowStyle;
var
   ias:TArrowStyle;
begin
     bname:=uppercase(bname);
     for ias:=low(TArrowStyle) to high(TArrowStyle) do
     if uppercase(DimArrows[ias].name)=bname then
                                                  begin
                                                       result:=ias;
                                                       exit;
                                                  end;
     result:=high(TArrowStyle);
end;

procedure GDBDimStyle.SetValueFromDxf(var mode:TDimStyleReadMode; group:Integer;value:String;var context:TIODXFLoadContext);
var
   temp:QWord;
begin
  if group=1001 then
                    mode:=TDSRM_ACAD;
  case mode of
    TDSRM_ACAD_DSTYLE_DIM_LINETYPE:begin
      if group=1005 then
        with context.h2p.MyGetValue(StrToQWord('$'+value)) do begin
          if &type=OT_LineType then
            Lines.DIMLTYPE:=p;
        end;
    end;
    TDSRM_ACAD_DSTYLE_DIM_EXT1_LINETYPE:begin
      if group=1005 then
        with context.h2p.MyGetValue(StrToQWord('$'+value)) do begin
          Lines.DIMLTEX1:=p;

        end;
    end;
    TDSRM_ACAD_DSTYLE_DIM_EXT2_LINETYPE:begin
      if group=1005 then
        with context.h2p.MyGetValue(StrToQWord('$'+value)) do begin
          if &type=OT_LineType then
            Lines.DIMLTEX2:=p;
        end;
    end;
  TDSRM_ACAD:
              begin
                case group of
                1001:begin
                          value:=uppercase(value);
                          if value='ACAD_DSTYLE_DIM_LINETYPE' then
                             mode:=TDSRM_ACAD_DSTYLE_DIM_LINETYPE;
                          if value='ACAD_DSTYLE_DIM_EXT1_LINETYPE' then
                             mode:=TDSRM_ACAD_DSTYLE_DIM_EXT1_LINETYPE;
                          if value='ACAD_DSTYLE_DIM_EXT2_LINETYPE' then
                             mode:=TDSRM_ACAD_DSTYLE_DIM_EXT2_LINETYPE;
                     end;
                2:
                  begin
                    self.SetName(value);
                  end;
                3:
                  begin
                       units.DIMPOST:=value;
                  end;
                40:
                  begin
                       units.DIMSCALE:=strtofloat(value);
                  end;
                41:
                  begin
                       Arrows.DIMASZ:=strtofloat(value);
                  end;
                42:
                  begin
                       Lines.DIMEXO:=strtofloat(value);
                  end;
                44:
                  begin
                       Lines.DIMEXE:=strtofloat(value);
                  end;
                45:
                  begin
                       Units.DIMRND:=strtofloat(value);
                  end;
                46:
                  begin
                       Lines.DIMDLE:=strtofloat(value);
                  end;
                73:
                  begin
                                                 if strtofloat(value)<>0 then
                                                                         Text.DIMTIH:=true
                                                                     else
                                                                         Text.DIMTIH:=false;
                  end;
                74:
                  begin
                                                 if strtofloat(value)<>0 then
                                                                         Text.DIMTOH:=true
                                                                     else
                                                                         Text.DIMTOH:=false;
                  end;
                77:
                begin
                     begin
                          group:=strtoint(value);
                          case group of
                                     0:Text.DIMTAD:=DTVPCenters;
                                     1:Text.DIMTAD:=DTVPAbove;
                                     2:Text.DIMTAD:=DTVPOutside;
                                     3:Text.DIMTAD:=DTVPJIS;
                                     4:Text.DIMTAD:=DTVPBellov;
                          end;
                     end;
                end;
                78:
                   Units.DIMZIN:=strtoint(value);
                144:
                  begin
                                         Units.DIMLFAC:=strtofloat(value);
                  end;
                140:
                  begin
                                         Text.DIMTXT:=strtofloat(value);
                  end;
                141:
                  begin
                                         Lines.DIMCEN:=strtofloat(value);
                  end;
                147:
                  begin
                       Text.DIMGAP:=strtofloat(value);
                  end;
                271:
                  begin
              Units.DIMDEC:=strtoint(value);
                  end;
                277:
                begin
                     begin
                          group:=strtoint(value);
                          case group of
                                     1:Units.DIMLUNIT:=DUScientific;
                                     2:Units.DIMLUNIT:=DUDecimal;
                                     3:Units.DIMLUNIT:=DUEngineering;
                                     4:Units.DIMLUNIT:=DUArchitectural;
                                     5:Units.DIMLUNIT:=DUFractional;
                                     6:Units.DIMLUNIT:=DUSystem;
                          end;
                     end;
                end;
                278:
                begin
                     begin
                          Units.DIMDSEP:=DDSDot;
                          group:=strtoint(value);
                          case group of
                                     44:Units.DIMDSEP:=DDSComma;
                                     32:Units.DIMDSEP:=DDSSpace;
                          end;
                     end;
                end;
                279:
                begin
                     group:=strtoint(value);
                     case group of
                                0:Placing.DIMTMOVE:=DTMMoveDimLine;
                                1:Placing.DIMTMOVE:=DTMCreateLeader;
                                2:Placing.DIMTMOVE:=DTMnothung;
                     end;
                end;
                340:
                begin
                     if TryStrToQWord('$'+value,temp) then begin
                       with context.h2p.MyGetValue(temp) do begin
                         if &type=OT_TextStyle then
                          Text.DIMTXSTY:=p;
                       end;
                     end
                     else
                       begin
                         CreateLDIfNeed;
                         PDXFLoadingData.TextStyleName:=value;
                       end;
                end;
                341:
                begin
                     if TryStrToQWord('$'+value,temp) then
                       begin
                        CreateLDIfNeed;
                        PDXFLoadingData.DIMLDRBLKhandle:=temp;
                       end;
                end;
                342:
                begin
                     CreateLDIfNeed;
                     PDXFLoadingData.DIMLDRBLKhandle:=StrToQWord('$'+value);
                     PDXFLoadingData.DIMBLK1handle:=PDXFLoadingData.DIMLDRBLKhandle;
                     PDXFLoadingData.DIMBLK2handle:=PDXFLoadingData.DIMLDRBLKhandle;
                end;
                343:
                begin
                     CreateLDIfNeed;
                     PDXFLoadingData.DIMBLK1handle:=StrToQWord('$'+value);
                end;
                344:
                begin
                     CreateLDIfNeed;
                     PDXFLoadingData.DIMBLK2handle:=StrToQWord('$'+value);
                end;
                371:
                begin
                     Lines.DIMLWD:=strtoint(value);
                end;
                372:
                begin
                     Lines.DIMLWE:=strtoint(value);
                end;
                176:
                begin
                     Lines.DIMCLRD:=NormalizePaletteColor(strtoint(value));
                end;
                177:
                begin
                     Lines.DIMCLRE:=NormalizePaletteColor(strtoint(value));
                end;
                178:
                begin
                     Text.DIMCLRT:=NormalizePaletteColor(strtoint(value));
                end;
                end;
              end;
  end;
end;
procedure GDBDimStyle.SetDefaultValues;
begin
     PDXFLoadingData:=nil;
     Lines.DIMEXE:=0.18;
     lines.DIMEXO:=0.0625;
     Lines.DIMDLE:=0;
     Lines.DIMCEN:=0.09;
     Lines.DIMLWD:=DIMLWDDefaultValue;
     Lines.DIMLWE:=DIMLWEDefaultValue;
     Lines.DIMCLRD:=DIMCLRDDefaultValue;
     Lines.DIMCLRE:=DIMCLREDefaultValue;
     Lines.DIMLTYPE:=nil;
     Lines.DIMLTEX1:=nil;
     Lines.DIMLTEX2:=nil;
     Units.DIMLFAC:=1;
     Units.DIMLUNIT:=DUDecimal;
     Units.DIMDEC:=4;
     Units.DIMRND:=0;
     Units.DIMDSEP:=DDSDot;
     Units.DIMPOST:='';
     Units.DIMZIN:=12;
     Arrows.DIMASZ:=0.18;
     text.DIMTXT:=0.18;
     text.DIMTIH:=true;
     text.DIMTOH:=true;
     text.DIMTAD:=DTVPCenters;
     text.DIMGAP:=0.625;
     text.DIMTXSTY:=nil;
     text.DIMCLRT:=DIMCLRTDefaultValue;
     Placing.DIMTMOVE:=DTMMoveDimLine;
end;
procedure GDBDimStyleArray.ResolveTextstyles(const tst:TGenericNamedObjectsArray);
var
  p:PGDBDimStyle;
  ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
    p^.ResolveTextstyles(tst);

    p:=iterate(ir);
  until p=nil;
end;
procedure GDBDimStyleArray.ResolveDXFHandles(const Handle2BlockName:TMapBlockHandle_BlockNames);
var
  p:PGDBDimStyle;
  ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
    p^.ResolveDXFHandles(Handle2BlockName);

    p:=iterate(ir);
  until p=nil;
end;
procedure GDBDimStyleArray.ResolveLineTypes(const lta:GDBLtypeArray);
var
  p:PGDBDimStyle;
  PByBlockLT:PGDBLtypeProp;
  ir:itrec;
begin
  PByBlockLT:=lta.GetSystemLT(TLTByBlock);
  p:=beginiterate(ir);
  if p<>nil then
  repeat

    if p^.lines.DIMLTEX1=nil then
                           p^.lines.DIMLTEX1:=PByBlockLT;
    if p^.lines.DIMLTEX2=nil then
                           p^.lines.DIMLTEX2:=PByBlockLT;
    if p^.lines.DIMLTYPE=nil then
                           p^.lines.DIMLTYPE:=PByBlockLT;

    p:=iterate(ir);
  until p=nil;
end;
constructor GDBDimStyleArray.initnul;
begin
  inherited initnul;
  //objsizeof:=sizeof(GDBDimStyle);
  //size:=sizeof(GDBDimStyle);
end;
constructor GDBDimStyleArray.init;
begin
  inherited init(m);
end;


begin
end.

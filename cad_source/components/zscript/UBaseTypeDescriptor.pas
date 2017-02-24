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

unit UBaseTypeDescriptor;
{$INCLUDE def.inc}
{$MODE DELPHI}
{$ASMMODE intel}
interface
uses
      LCLProc,Graphics,classes,Themes,
      uzemathutils,uzegeometry,uzbstrproc,TypeDescriptors,
      sysutils,UGDBOpenArrayOfByte,uzbtypesbase,
      USinonimDescriptor,uzedimensionaltypes,varmandef,uzbtypes,{gzctnrvectordata,}uzctnrvectorgdbstring,uzbmemman,math;
resourcestring
  rsDifferent='Different';
type
PBaseTypeDescriptor=^{BaseTypeDescriptor}TUserTypeDescriptor;
BaseTypeDescriptor<T>=object(TUserTypeDescriptor)
                         type
                          PT=^T;
                         constructor init(tname:string;pu:pointer);
                         function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                         function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;Name:GDBString;PCollapsed:GDBPointer;ownerattrib:GDBWord;var bmode:GDBInteger;var addr:GDBPointer;ValKey,ValType:GDBString):PTPropertyDeskriptorArray;virtual;
                         //function Serialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:PGDBOpenArrayOfByte;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;
                         //function DeSerialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:GDBOpenArrayOfByte;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;
                         procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                   end;
GDBBooleanDescriptor=object(BaseTypeDescriptor<boolean>)
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
TFundamentalShortIntDescriptor=object(BaseTypeDescriptor<shortint>)
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
TFundamentalByteDescriptor=object(BaseTypeDescriptor<byte>)
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
TFundamentalSmallIntDescriptor=object(BaseTypeDescriptor<smallint>)
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
TFundamentalWordDescriptor=object(BaseTypeDescriptor<word>)
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBIntegerDescriptor=object(BaseTypeDescriptor<Integer>)
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
TFundamentalLongWordDescriptor=object(BaseTypeDescriptor<Longword>)
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
TFundamentalLongIntDescriptor=object(BaseTypeDescriptor<LongInt>)
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
TFundamentalQWordDescriptor=object(BaseTypeDescriptor<qword>)
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBDoubleDescriptor=object(BaseTypeDescriptor<double>)
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          function GetFormattedValueAsString(PInstance:GDBPointer; const f:TzeUnitsFormat):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBNonDimensionDoubleDescriptor=object(GDBDoubleDescriptor)
                          function GetFormattedValueAsString(PInstance:GDBPointer; const f:TzeUnitsFormat):GDBString;virtual;
                    end;
GDBAngleDegDoubleDescriptor=object(GDBDoubleDescriptor)
                                       function GetFormattedValueAsString(PInstance:GDBPointer; const f:TzeUnitsFormat):GDBString;virtual;
                                 end;
GDBAngleDoubleDescriptor=object(GDBDoubleDescriptor)
                               function GetFormattedValueAsString(PInstance:GDBPointer; const f:TzeUnitsFormat):GDBString;virtual;
                         end;
GDBStringDescriptor=object(BaseTypeDescriptor<string>)
                          //function Serialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:PGDBOpenArrayOfByte;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;
                          //function DeSerialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:GDBOpenArrayOfByte;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure CopyInstanceTo(source,dest:pointer);virtual;
                          procedure MagicFreeInstance(PInstance:GDBPointer);virtual;
                          procedure MagicAfterCopyInstance(PInstance:GDBPointer);virtual;
                          procedure SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:GDBPointer;prefix:GDBString);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBAnsiStringDescriptor=object(GDBStringDescriptor)
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBFloatDescriptor=object(BaseTypeDescriptor<float>)
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBPointerDescriptor=object(BaseTypeDescriptor<pointer>)
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:GDBPointer;prefix:GDBString);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBPtrUIntDescriptor=object(BaseTypeDescriptor<PtrUint>)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
TEnumDataDescriptor=object(BaseTypeDescriptor<TEnumData>)
                     constructor init;
                     function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                     procedure SetValueFromString(PInstance:GDBPointer;_Value:GDBstring);virtual;
                     function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;Name:GDBString;PCollapsed:GDBPointer;ownerattrib:GDBWord;var bmode:GDBInteger;var addr:GDBPointer;ValKey,ValType:GDBString):PTPropertyDeskriptorArray;virtual;
                     destructor Done;virtual;
               end;
function MyDataToStr(data:LongInt):string;overload;
function MyDataToStr(data:boolean):string;overload;
function MyDataToStr(data:double):string;overload;
function MyDataToStr(data:float):string;overload;
function MyDataToStr(data:string):string;overload;
function MyDataToStr(data:pointer):string;overload;
//function MyDataToStr(data:TEnumData):string;overload;
//function MyDataToStr(data:PtrUInt):string;overload;

var
FundamentalDoubleDescriptorObj:GDBDoubleDescriptor;
GDBNonDimensionDoubleDescriptorObj:GDBNonDimensionDoubleDescriptor;
GDBAngleDegDoubleDescriptorObj:GDBAngleDegDoubleDescriptor;
GDBAngleDoubleDescriptorObj:GDBAngleDoubleDescriptor;
FundamentalStringDescriptorObj:GDBStringDescriptor;
FundamentalAnsiStringDescriptorObj:GDBAnsiStringDescriptor;
FundamentalWordDescriptorObj:TFundamentalWordDescriptor;
//GDBIntegerDescriptorObj:GDBIntegerDescriptor;
FundamentalLongIntDescriptorObj:TFundamentalLongIntDescriptor;
FundamentalByteDescriptorObj:TFundamentalByteDescriptor;
FundamentalSmallIntDescriptorObj:TFundamentalSmallIntDescriptor;
FundamentalLongWordDescriptorObj:TFundamentalLongWordDescriptor;
FundamentalQWordDescriptorObj:TFundamentalQWordDescriptor;
FundamentalSingleDescriptorObj:GDBFloatDescriptor;
FundamentalShortIntDescriptorObj:TFundamentalShortIntDescriptor;
FundamentalBooleanDescriptorOdj:GDBBooleanDescriptor;
FundamentalPointerDescriptorOdj:GDBPointerDescriptor;
GDBEnumDataDescriptorObj:TEnumDataDescriptor;
GDBPtrUIntDescriptorObj:GDBPtrUIntDescriptor;

AliasIntegerDescriptorOdj:GDBSinonimDescriptor;
AliasCardinalDescriptorOdj:GDBSinonimDescriptor;
implementation
function MyDataToStr(data:LongInt):string;overload;
begin
     result:=inttostr(data);
end;
function MyDataToStr(data:boolean):string;overload;
begin
     if data then
     result := 'True'
     else
     result := 'False';
end;
function MyDataToStr(data:double):string;overload;
begin
    if isnan(data) then
                             result := 'NAN'
                         else
                             begin
                                  result := floattostr(data);
                                      if pos('.',result)<1 then
                                                               result:=result+'.0';
                             end;

end;
function MyDataToStr(data:float):string;overload;
begin
    if isnan(data) then
                             result := 'NAN'
                         else
                             begin
                                  result := floattostr(data);
                                      if pos('.',result)<1 then
                                                               result:=result+'.0';
                             end;

end;
function MyDataToStr(data:string):string;overload;
begin
     result := data;
end;
function MyDataToStr(data:pointer):string;overload;
begin
     if data<>nil then
                      begin
                           result := '$' + inttohex(int64(GDBPlatformint(data)), 8);
                      end
                  else result := 'nil';
end;
{function MyDataToStr(data:TEnumData):string;overload;
begin
     if data.Selected>=data.Enums.Count then
                                            result:='ENUMERROR'
                                        else
                                            result:=data.Enums.getData(data.Selected);
end;}
function TEnumDataDescriptor.CreateProperties;
var ppd:PPropertyDeskriptor;
begin
     if VerboseLog^ then
       DebugLn('{T}[ZSCRIPT]TEnumDataDescriptor.CreateProperties(%s,ppda=%p)',[name,ppda]);
     //programlog.LogOutFormatStr('TEnumDataDescriptor.CreateProperties(%s,ppda=%p)',[name,ppda],lp_OldPos,LM_Trace);
     ppd:=GetPPD(ppda,bmode);
     if ppd^._bmode=property_build then
                                       ppd^._bmode:=bmode;
     if bmode=property_build then
                                 begin
                                      ppd^._ppda:=ppda;
                                      ppd^._bmode:=bmode;
                                 end
                             else
                                 begin
                                      if (ppd^._ppda<>ppda)
                                      //or (ppd^._bmode<>bmode)
                                                             then
                                                                 asm
                                                                    int 3;
                                                                 end;


                                 end;
     ppd^.Name:=name;
     ppd^.ValType:=valtype;
     ppd^.ValKey:=valkey;
     ppd^.PTypeManager:=@self;
     ppd^.Decorators:=Decorators;
     ppd^.FastEditor:=FastEditor;
     ppd^.Attr:=ownerattrib;
     ppd^.Collapsed:=PCollapsed;
     ppd^.valueAddres:=addr;
     ppd^.value:=GetValueAsString(addr);
     if ppd^.value='rp_21' then
                               ppd^.value:=ppd^.value;
           if ppd<>nil then
                           begin
                                //IncAddr(addr);
                                //inc(pGDBByte(addr),SizeInGDBBytes);
                                //if bmode=property_build then PPDA^.add(@ppd);
                           end;
     IncAddr(addr);
end;
constructor BaseTypeDescriptor<T>.init(tname:string;pu:pointer);
begin
     inherited init(sizeof(t),tname,pu);
end;

function BaseTypeDescriptor<T>.GetValueAsString;
begin
    //result := MyDataToStr(PT(pinstance)^);
end;

function BaseTypeDescriptor<T>.CreateProperties;
var ppd:PPropertyDeskriptor;
begin
     if VerboseLog^ then
       DebugLn('{T}[ZSCRIPT]BaseTypeDescriptor.CreateProperties(%s,ppda=%p)',[name,ppda]);
     //programlog.LogOutFormatStr('BaseTypeDescriptor.CreateProperties(%s,ppda=%p)',[name,ppda],lp_OldPos,LM_Trace);
     ppd:=GetPPD(ppda,bmode);
     if ppd^._bmode=property_build then
                                       ppd^._bmode:=bmode;
     if bmode=property_build then
                                 begin
                                      ppd^._ppda:=ppda;
                                      ppd^._bmode:=bmode;
                                 end
                             else
                                 begin
                                      {if (ppd^._ppda<>ppda)
                                      //or (ppd^._bmode<>bmode)
                                                             then
                                                                 asm
                                                                    //int 3;
                                                                 end;}


                                 end;
     ppd^.Name:=name;
     ppd^.ValKey:=valkey;
     ppd^.ValType:=valtype;
     ppd^.PTypeManager:=@self;
     ppd^.Decorators:=Decorators;
     ppd^.FastEditor:=FastEditor;
     ppd^.Attr:=ownerattrib;
     ppd^.Collapsed:=PCollapsed;
     ppd^.valueAddres:=addr;
     ppd^.mode:=mode;
     if (ppd^.Attr and FA_DIFFERENT)=0 then
                                           ppd^.value:=GetDecoratedValueAsString(addr,f)
                                       else
                                           ppd^.value:=rsDifferent;
     if ppd^.value='rp_21' then
                               ppd^.value:=ppd^.value;
           if ppd<>nil then
                           begin
                                //IncAddr(addr);
                                //inc(pGDBByte(addr),SizeInGDBBytes);
                                //if bmode=property_build then PPDA^.add(@ppd);
                           end;
     IncAddr(addr);
end;
procedure BaseTypeDescriptor<T>.SetValueFromString;
begin
end;
procedure GDBBooleanDescriptor.SetValueFromString(PInstance:GDBPointer;Value:GDBstring);
begin
     if uppercase(value)='TRUE' then
                                    PGDBboolean(pinstance)^:=true
else if uppercase(value)='FALSE' then
                                     PGDBboolean(pinstance)^:=false
else
    DebugLn('{E}GDBBooleanDescriptor.SetValueFromString('+value+') {not false\true}');
    //programlog.LogOutStr('GDBBooleanDescriptor.SetValueFromString('+value+') {not false\true}',lp_OldPos,LM_Error);
end;
function GDBBooleanDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if PGDBboolean(pleft)^<>PGDBboolean(pright)^ then
                                                      result:=CRNotEqual
                                                  else
                                                      result:=CREqual;
end;
function GDBBooleanDescriptor.GetValueAsString;
begin
     if PGDBboolean(pinstance)^ then
     result := 'True'
     else
     result := 'False';
end;
function TFundamentalLongWordDescriptor.GetValueAsString;
var
     uGDBInteger:GDBLongword;
begin
    uGDBInteger := pGDBLongword(pinstance)^;
    result := inttostr(uGDBInteger);
end;
procedure TFundamentalLongWordDescriptor.SetValueFromString;
var
     vGDBLongword:GDBLongword;
     error:integer;
begin
     val(value,vGDBLongword,error);
     if error=0 then
                    pGDBLongword(pinstance)^:=vGDBLongword;
end;
function TFundamentalLongWordDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if pGDBLongword(pleft)^<>pGDBLongword(pright)^
     then
       begin
            if pGDBLongword(pleft)^<pGDBLongword(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;
function TFundamentalQWordDescriptor.GetValueAsString;
var
     qw:GDBQWord;
begin
    qw := PGDBQWord(pinstance)^;
    result := inttostr(qw);
end;
procedure TFundamentalQWordDescriptor.SetValueFromString;
var
     qw:GDBQWord;
     //error:integer;
begin
     {$IFNDEF DELPHI}
     if TryStrToQWord(value,qw) then
                                   PGDBQWord(pinstance)^:=qw;
     {$ENDIF}
end;
function TFundamentalQWordDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if PGDBQWord(pleft)^<>PGDBQWord(pright)^
     then
       begin
            if PGDBQWord(pleft)^<PGDBQWord(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;
function GDBFloatDescriptor.GetValueAsString;
var
     uGDBFloat:GDBFloat;
begin
    uGDBFloat:=pGDBFloat(pinstance)^;
    result := floattostr(uGDBFloat);
    if pos('.',result)<1 then
                             result:=result+'.0';
end;
procedure GDBFloatDescriptor.SetValueFromString;
var
     vGDBFloat:gdbFloat;
     error:integer;
begin
     val(value,vGDBFloat,error);
     if error=0 then
                    pGDBFloat(pinstance)^:=vGDBFloat;
end;
function GDBFloatDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if IsFloatNotEqual(pGDBFloat(pleft)^,pGDBFloat(pright)^)
     then
       begin
            if pGDBFloat(pleft)^<pGDBFloat(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;
constructor GDBPtrUIntDescriptor.init;
begin
     inherited init('GDBPtrUInt',nil);
end;
function GDBPtrUIntDescriptor.GetValueAsString;
var
     UPtrUInt:PtrUInt;
begin
    UPtrUInt:=PPtrUInt(pinstance)^;
    result := inttostr(UPtrUInt);
end;
procedure GDBPtrUIntDescriptor.SetValueFromString;
var
     vPtrUInt:PtrUInt;
     error:integer;
begin
     val(value,vPtrUInt,error);
     if error=0 then
                    PPtrUInt(pinstance)^:=vPtrUInt;
end;
function GDBPtrUIntDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if PPtrUInt(pleft)^<>PPtrUInt(pright)^
     then
       begin
            if PPtrUInt(pleft)^<PPtrUInt(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;
function GDBDoubleDescriptor.GetValueAsString;
var
     uGDBDouble:GDBDouble;
begin
    uGDBDouble:=pGDBDouble(pinstance)^;
    if isnan(uGDBDouble) then
                             result := 'NAN'
                         else
                             begin
                                  result := floattostr(uGDBDouble);
                                      if pos('.',result)<1 then
                                                               result:=result+'.0';
                             end;

end;
function GDBDoubleDescriptor.GetFormattedValueAsString(PInstance:GDBPointer; const f:TzeUnitsFormat):GDBString;
begin
    result:=zeDimensionToString(PGDBDouble(PInstance)^,f);
end;

procedure GDBDoubleDescriptor.SetValueFromString;
var
     uGDBDouble:GDBDouble;
     error:integer;
begin
     val(value,ugdbdouble,error);
     if error=0 then
                    pGDBDouble(pinstance)^:=ugdbdouble;
end;
function GDBDoubleDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if IsDoubleNotEqual(PGDBDouble(pleft)^,PGDBDouble(pright)^)
     then
       begin
            if PGDBDouble(pleft)^<PGDBDouble(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;
function GDBNonDimensionDoubleDescriptor.GetFormattedValueAsString(PInstance:GDBPointer; const f:TzeUnitsFormat):GDBString;
begin
    result:=zeNonDimensionToString(PGDBNonDimensionDouble(PInstance)^,f);
end;
function GDBAngleDegDoubleDescriptor.GetFormattedValueAsString(PInstance:GDBPointer; const f:TzeUnitsFormat):GDBString;
begin
    result:=zeAngleDegToString(PGDBNonDimensionDouble(PInstance)^,f);
end;
function GDBAngleDoubleDescriptor.GetFormattedValueAsString(PInstance:GDBPointer; const f:TzeUnitsFormat):GDBString;
begin
    result:=zeAngleToString(PGDBNonDimensionDouble(PInstance)^,f);
end;
function TFundamentalWordDescriptor.GetValueAsString;
var
     uGDBWord:GDBWord;
begin
    uGDBWord := pGDBWord(pinstance)^;
    result := inttostr(uGDBWord);
end;
procedure TFundamentalWordDescriptor.SetValueFromString;
var
     vGDBWord:gdbWord;
     error:integer;
begin
     val(value,vGDBWord,error);
     if error=0 then
                    pGDBWord(pinstance)^:=vGDBWord;
end;
function TFundamentalWordDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if pGDBWord(pleft)^<>pGDBWord(pright)^
     then
       begin
            if pGDBWord(pleft)^<pGDBWord(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;

function TFundamentalLongIntDescriptor.GetValueAsString;
var
     uGDBInteger:LongInt;
begin
    uGDBInteger := pGDBInteger(pinstance)^;
    result := inttostr(uGDBInteger);
end;
procedure TFundamentalLongIntDescriptor.SetValueFromString;
var
     vGDBInteger:LongInt;
     error:integer;
begin
     val(value,vGDBInteger,error);
     if error=0 then
                    pGDBInteger(pinstance)^:=vGDBInteger;
end;
function TFundamentalLongIntDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if pLongInt(pleft)^<>pLongInt(pright)^
     then
       begin
            if pLongInt(pleft)^<pLongInt(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;


function GDBIntegerDescriptor.GetValueAsString;
var
     uGDBInteger:GDBInteger;
begin
    uGDBInteger := pGDBInteger(pinstance)^;
    result := inttostr(uGDBInteger);
end;
procedure GDBIntegerDescriptor.SetValueFromString;
var
     vGDBInteger:gdbInteger;
     error:integer;
begin
     val(value,vGDBInteger,error);
     if error=0 then
                    pGDBInteger(pinstance)^:=vGDBInteger;
end;
function GDBIntegerDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if pGDBInteger(pleft)^<>pGDBInteger(pright)^
     then
       begin
            if pGDBInteger(pleft)^<pGDBInteger(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;
function TFundamentalShortIntDescriptor.GetValueAsString;
var
     uGDBShortint:GDBShortint;
begin
    uGDBShortint := pGDBShortint(pinstance)^;
    result := inttostr(uGDBShortint);
end;
procedure TFundamentalShortIntDescriptor.SetValueFromString;
var
     vGDBShortint:gdbShortint;
     error:integer;
begin
     val(value,vGDBshortint,error);
     if error=0 then                           
                    pGDBshortint(pinstance)^:=vGDBshortint;
end;
function TFundamentalShortIntDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if pGDBshortint(pleft)^<>pGDBshortint(pright)^
     then
       begin
            if pGDBshortint(pleft)^<pGDBshortint(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;
function TFundamentalByteDescriptor.GetValueAsString;
var
     uGDBByte:GDBByte;
begin
    uGDBByte := pGDBByte(pinstance)^;
    result := inttostr(uGDBByte);
end;
procedure TFundamentalByteDescriptor.SetValueFromString;
var
     vGDBbyte:gdbbyte;
     error:integer;
begin
     val(value,vGDBbyte,error);
     if error=0 then
                    pGDBbyte(pinstance)^:=vGDBbyte;
end;
function TFundamentalByteDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if pGDBbyte(pleft)^<>pGDBbyte(pright)^
     then
       begin
            if pGDBbyte(pleft)^<pGDBbyte(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;
function TFundamentalSmallIntDescriptor.GetValueAsString;
var
     uGDBSmallint:GDBSmallint;
begin
    uGDBSmallint := pGDBSmallint(pinstance)^;
    result := inttostr(uGDBSmallint);
end;
procedure TFundamentalSmallIntDescriptor.SetValueFromString;
var
     vGDBSmallint:gdbSmallint;
     error:integer;
begin
     val(value,vGDBSmallint,error);
     if error=0 then
                    pGDBSmallint(pinstance)^:=vGDBSmallint;
end;
function TFundamentalSmallIntDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if pGDBSmallint(pleft)^<>pGDBSmallint(pright)^
     then
       begin
            if pGDBSmallint(pleft)^<pGDBSmallint(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;
procedure GDBStringDescriptor.CopyInstanceTo;
begin
     pstring(dest)^:=pstring(source)^;
end;
procedure GDBStringDescriptor.MagicFreeInstance;
begin
     pstring(Pinstance)^:='';
end;
procedure GDBStringDescriptor.MagicAfterCopyInstance;
var
   s:GDBString;
begin
     s:=pstring(Pinstance)^;
     killstring(s);
     //pointer(s):=nil;
     //KillString(pstring(Pinstance)^);
end;
procedure GDBStringDescriptor.SavePasToMem;
begin
     membuf.TXTAddGDBStringEOL(prefix+':='''+{pvd.data.PTD.}GetValueAsString(PInstance)+''';');
end;
function GDBStringDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if PGDBString(pleft)^<>PGDBString(pright)^
     then
       begin
            if PGDBString(pleft)^<PGDBString(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;
function GDBPointerDescriptor.GetValueAsString;
var
     uGDBPointer:GDBPointer;
     uGDBInteger: GDBLongword;
begin
    uGDBPointer := pGDBPointer(pinstance)^;
                if uGDBPointer<>nil then
                                             begin
                                                  uGDBInteger := GDBPlatformint(uGDBPointer);
                                                  result := '$' + inttohex(int64(uGDBInteger), 8);
                                             end
                                         else result := 'nil';
end;
procedure GDBPointerDescriptor.SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:GDBPointer;prefix:GDBString);
begin
end;
function GDBPointerDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if pGDBPointer(pleft)^<>pGDBPointer(pright)^
     then
       begin
            if pGDBPointer(pleft)^<pGDBPointer(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;

function GDBStringDescriptor.GetValueAsString;
var
     uGDBString:GDBString;
begin
    uGDBString := pGDBString(pinstance)^;
    result := uni2cp(uGDBString);
end;
procedure GDBStringDescriptor.SetValueFromString;
//var
//     vGDBLongword:gdbWord;
//     error:integer;
begin
     //val(value,vGDBLongword,error);
     //if error=0 then
                    pGDBString(pinstance)^:=cp2uni(value);//vGDBLongword;
end;
procedure GDBAnsiStringDescriptor.SetValueFromString(PInstance:GDBPointer;Value:GDBstring);
//var
//     vGDBLongword:gdbWord;
//     error:integer;
begin
     //val(value,vGDBLongword,error);
     //if error=0 then
                    pGDBString(pinstance)^:=cp2ansi(value);//vGDBLongword;
end;
function GDBAnsiStringDescriptor.GetValueAsString(pinstance:GDBPointer):GDBString;
var
     uGDBString:GDBString;
begin
    uGDBString := pGDBString(pinstance)^;
    result := ansi2cp(uGDBString);
end;
function GDBAnsiStringDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if PGDBAnsiString(pleft)^<>PGDBAnsiString(pright)^
     then
       begin
            if PGDBAnsiString(pleft)^<PGDBAnsiString(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;
destructor TEnumDataDescriptor.done;
begin
     inherited;
     {SourceValue.FreeAndDone;
     UserValue.FreeAndDone;
     value.Done;}
end;
constructor TEnumDataDescriptor.init;
begin
     inherited init('TEnumDataDescriptor',nil);
end;
procedure TEnumDataDescriptor.SetValueFromString(PInstance:GDBPointer;_Value:GDBstring);
var
    p:pgdbstring;
    ir:itrec;
begin
     _value:=uppercase(_value);
                             p:=PTEnumData(Pinstance)^.Enums.beginiterate(ir);
                             if p<>nil then
                             repeat
                             if _value=uppercase(p^)then
                             begin
                                  PTEnumData(Pinstance)^.Selected:=ir.itc;
                                  exit;
                             end;
                                   p:=PTEnumData(Pinstance)^.Enums.iterate(ir);
                             until p=nil;
end;
function TEnumDataDescriptor.GetValueAsString;
{var currval:GDBLongword;
    p:GDBPointer;
    found:GDBBoolean;
    i:GDBInteger;
    num:cardinal;}
begin
     if PTEnumData(Pinstance)^.Selected>=PTEnumData(Pinstance)^.Enums.Count then
                                                                               result:='ENUMERROR'
                                                                           else
                                                                               result:=PTEnumData(Pinstance)^.Enums.getData(PTEnumData(Pinstance)^.Selected);
     {GetNumberInArrays(pinstance,num);
     result:=UserValue.getGDBString(num)}
end;
begin
     FundamentalLongIntDescriptorObj.init('LongInt',nil);
     FundamentalLongWordDescriptorObj.init('LongWord',nil);
     FundamentalSmallIntDescriptorObj.init('SmallInt',nil);
     FundamentalByteDescriptorObj.init('Byte',nil);
     FundamentalShortIntDescriptorObj.init('ShortInt',nil);
     FundamentalWordDescriptorObj.init('Word',nil);
     FundamentalBooleanDescriptorOdj.init('Boolean',nil);
     FundamentalPointerDescriptorOdj.init('Pointer',nil);
     FundamentalQWordDescriptorObj.init('QWord',nil);

     FundamentalStringDescriptorObj.init('String',nil);
     FundamentalAnsiStringDescriptorObj.init('AnsiString',nil);

     FundamentalDoubleDescriptorObj.init('Double',nil);
     FundamentalSingleDescriptorObj.init('Single',nil);

     GDBNonDimensionDoubleDescriptorObj.init('GDBNonDimensionDouble',nil);
     GDBAngleDegDoubleDescriptorObj.init('GDBAngleDegDouble',nil);
     GDBAngleDoubleDescriptorObj.init('GDBAngleDouble',nil);

     AliasIntegerDescriptorOdj.init2(@FundamentalLongIntDescriptorObj,'Integer',nil);
     AliasCardinalDescriptorOdj.init2(@FundamentalLongWordDescriptorObj,'Cardinal',nil);

     GDBEnumDataDescriptorObj.init;
     GDBPtrUIntDescriptorObj.init;
end.

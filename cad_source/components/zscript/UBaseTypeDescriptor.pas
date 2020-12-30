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
interface
uses
      typinfo,LCLProc,Graphics,classes,Themes,
      gzctnrvectortypes,uzemathutils,uzegeometry,uzbstrproc,TypeDescriptors,
      sysutils,UGDBOpenArrayOfByte,uzbtypesbase,
      USinonimDescriptor,uzedimensionaltypes,varmandef,uzbtypes,{gzctnrvectordata,}uzctnrvectorgdbstring,uzbmemman,math;
resourcestring
  rsDifferent='Different';
type
TBaseTypeManipulator<T>=class
type
 PT=^T;
end;
TOrdinalTypeManipulator<T>=class(TBaseTypeManipulator<T>)
  class function GetValueAsString(const data:T):TInternalScriptString;
  class function GetFormattedValueAsString(const data:T; const f:TzeUnitsFormat):TInternalScriptString;
  class procedure SetValueFromString(var data:T;Value:TInternalScriptString);
  class function Compare(const left,right:T):TCompareResult;
end;
TBoolTypeManipulator<T>=class(TBaseTypeManipulator<T>)
  class function GetValueAsString(const data:T):TInternalScriptString;
  class function GetFormattedValueAsString(const data:T; const f:TzeUnitsFormat):TInternalScriptString;
  class procedure SetValueFromString(var data:T;Value:TInternalScriptString);
  class function Compare(const left,right:T):TCompareResult;
end;
TFloatTypeManipulator<T>=class(TBaseTypeManipulator<T>)
  class function GetValueAsString(const data:T):TInternalScriptString;
  class function GetFormattedValueAsString(const data:T; const f:TzeUnitsFormat):TInternalScriptString;
  class procedure SetValueFromString(var data:T;Value:TInternalScriptString);
  class function Compare(const left,right:T):TCompareResult;
end;
TStringTypeManipulator<T>=class(TBaseTypeManipulator<T>)
  class function GetValueAsString(const data:T):TInternalScriptString;
  class function GetFormattedValueAsString(const data:T; const f:TzeUnitsFormat):TInternalScriptString;
  class procedure SetValueFromString(var data:T;Value:TInternalScriptString);
  class function Compare(const left,right:T):TCompareResult;
end;
TAnsiStringTypeManipulator<T>=class(TBaseTypeManipulator<T>)
  class function GetValueAsString(const data:T):TInternalScriptString;
  class function GetFormattedValueAsString(const data:T; const f:TzeUnitsFormat):TInternalScriptString;
  class procedure SetValueFromString(var data:T;Value:TInternalScriptString);
  class function Compare(const left,right:T):TCompareResult;
end;
TPointerTypeManipulator<T>=class(TBaseTypeManipulator<T>)
  class function GetValueAsString(const data:T):TInternalScriptString;
  class function GetFormattedValueAsString(const data:T; const f:TzeUnitsFormat):TInternalScriptString;
  class procedure SetValueFromString(var data:T;Value:TInternalScriptString);
  class function Compare(const left,right:T):TCompareResult;
end;
PBaseTypeDescriptor=^{BaseTypeDescriptor}TUserTypeDescriptor;
BaseTypeDescriptor<T,TManipulator>=object(TUserTypeDescriptor)
                         type
                          PT=^T;
                         constructor init(tname:string;pu:pointer);

                         function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                         function GetFormattedValueAsString(PInstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;virtual;
                         function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;Name:TInternalScriptString;PCollapsed:Pointer;ownerattrib:Word;var bmode:Integer;const addr:Pointer;ValKey,ValType:TInternalScriptString):PTPropertyDeskriptorArray;virtual;
                         procedure SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);virtual;
                   end;
TBTM_Boolean=TBoolTypeManipulator<Boolean>;
GDBBooleanDescriptor=object(BaseTypeDescriptor<boolean,{TBoolTypeManipulator<boolean>}TBTM_Boolean>)
                    end;
TOTM_ShortInt=TOrdinalTypeManipulator<ShortInt>;
TFundamentalShortIntDescriptor=object(BaseTypeDescriptor<shortint,{TOrdinalTypeManipulator<shortint>}TOTM_ShortInt>)
                    end;
TOTM_Byte=TOrdinalTypeManipulator<Byte>;
TFundamentalByteDescriptor=object(BaseTypeDescriptor<byte,{TOrdinalTypeManipulator<byte>}TOTM_Byte>)
                    end;
TOTM_SmallInt=TOrdinalTypeManipulator<SmallInt>;
TFundamentalSmallIntDescriptor=object(BaseTypeDescriptor<smallint,{TOrdinalTypeManipulator<smallint>}TOTM_SmallInt>)
                    end;
TOTM_Word=TOrdinalTypeManipulator<Word>;
TFundamentalWordDescriptor=object(BaseTypeDescriptor<word,{TOrdinalTypeManipulator<word>}TOTM_Word>)
                    end;
TOTM_Integer=TOrdinalTypeManipulator<Integer>;
GDBIntegerDescriptor=object(BaseTypeDescriptor<Integer,{TOrdinalTypeManipulator<Integer>}TOTM_Integer>)
                    end;
TOTM_LongWord=TOrdinalTypeManipulator<LongWord>;
TFundamentalLongWordDescriptor=object(BaseTypeDescriptor<Longword,{TOrdinalTypeManipulator<Longword>}TOTM_LongWord>)
                    end;
TOTM_LongInt=TOrdinalTypeManipulator<LongInt>;
TFundamentalLongIntDescriptor=object(BaseTypeDescriptor<LongInt,{TOrdinalTypeManipulator<LongInt>}TOTM_LongInt>)
                    end;
TOTM_QWord=TOrdinalTypeManipulator<QWord>;
TFundamentalQWordDescriptor=object(BaseTypeDescriptor<qword,{TOrdinalTypeManipulator<qword>}TOTM_QWord>)
                    end;
TOTM_Int64=TOrdinalTypeManipulator<Int64>;
TFundamentalInt64Descriptor=object(BaseTypeDescriptor<Int64,{TOrdinalTypeManipulator<Int64>}TOTM_Int64>)
                    end;
TFTM_Double=TOrdinalTypeManipulator<Double>;
GDBDoubleDescriptor=object(BaseTypeDescriptor<double,{TFloatTypeManipulator<double>}TFTM_Double>)
                    end;
TFTM_float=TOrdinalTypeManipulator<float>;
GDBFloatDescriptor=object(BaseTypeDescriptor<float,{TFloatTypeManipulator<TFTM_float>}TFTM_float>)
                    end;
GDBStringGeneralDescriptor<T,TManipulator>=object(BaseTypeDescriptor<T,TManipulator>)
                          procedure CopyInstanceTo(source,dest:pointer);virtual;
                          procedure MagicFreeInstance(PInstance:Pointer);virtual;
                          procedure MagicAfterCopyInstance(PInstance:Pointer);virtual;
                    end;
TSTM_UnicodeString=TStringTypeManipulator<UnicodeString>;
GDBUnicodeStringDescriptor=object(GDBStringGeneralDescriptor<UnicodeString,TSTM_UnicodeString>)
                    end;
TSTM_String=TStringTypeManipulator<String>;
GDBStringDescriptor=object(GDBStringGeneralDescriptor<string,{TStringTypeManipulator<string>}TSTM_String>)
                          procedure SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:Pointer;prefix:TInternalScriptString);virtual;
                    end;
TASTM_String=TAnsiStringTypeManipulator<String>;
GDBAnsiStringDescriptor=object(GDBStringGeneralDescriptor<string,{TAnsiStringTypeManipulator<string>}TASTM_String>)
                          procedure SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:Pointer;prefix:TInternalScriptString);virtual;
                    end;
TPTM_Pointer=TPointerTypeManipulator<Pointer>;
PointerDescriptor=object(BaseTypeDescriptor<pointer,{TPointerTypeManipulator<Pointer>}TPTM_Pointer>)
                    end;
TOTM_PtrUint=TOrdinalTypeManipulator<PtrUint>;
TEnumDataDescriptor=object(BaseTypeDescriptor<TEnumData,{TOrdinalTypeManipulator<PtrUint>}TOTM_PtrUint>)
                     constructor init;
                     function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                     procedure SetValueFromString(PInstance:Pointer;_Value:TInternalScriptString);virtual;
                     function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;Name:TInternalScriptString;PCollapsed:Pointer;ownerattrib:Word;var bmode:Integer;const addr:Pointer;ValKey,ValType:TInternalScriptString):PTPropertyDeskriptorArray;virtual;
                     destructor Done;virtual;
               end;
(*function MyDataToStr(data:LongInt):string;overload;
function MyDataToStr(data:boolean):string;overload;
function MyDataToStr(data:double):string;overload;
function MyDataToStr(data:float):string;overload;
function MyDataToStr(data:string):string;overload;
function MyDataToStr(data:pointer):string;overload;
function MyDataToStr(data:TEnumData):string;overload;*)

var
FundamentalDoubleDescriptorObj:GDBDoubleDescriptor;
FundamentalUnicodeStringDescriptorObj:GDBUnicodeStringDescriptor;
FundamentalStringDescriptorObj:GDBStringDescriptor;
FundamentalAnsiStringDescriptorObj:GDBAnsiStringDescriptor;
FundamentalWordDescriptorObj:TFundamentalWordDescriptor;
FundamentalLongIntDescriptorObj:TFundamentalLongIntDescriptor;
FundamentalByteDescriptorObj:TFundamentalByteDescriptor;
FundamentalSmallIntDescriptorObj:TFundamentalSmallIntDescriptor;
FundamentalLongWordDescriptorObj:TFundamentalLongWordDescriptor;
FundamentalQWordDescriptorObj:TFundamentalQWordDescriptor;
FundamentalInt64Descriptor:TFundamentalInt64Descriptor;
FundamentalSingleDescriptorObj:GDBFloatDescriptor;
FundamentalShortIntDescriptorObj:TFundamentalShortIntDescriptor;
FundamentalBooleanDescriptorOdj:GDBBooleanDescriptor;
FundamentalPointerDescriptorOdj:PointerDescriptor;
GDBEnumDataDescriptorObj:TEnumDataDescriptor;

AliasIntegerDescriptorOdj:GDBSinonimDescriptor;
AliasCardinalDescriptorOdj:GDBSinonimDescriptor;
AliasDWordDescriptorOdj:GDBSinonimDescriptor;
AliasPtrUIntDescriptorOdj:GDBSinonimDescriptor;
AliasPtrIntDescriptorOdj:GDBSinonimDescriptor;
AliasUInt64DescriptorOdj:GDBSinonimDescriptor;
implementation
(*function MyDataToStr(data:LongInt):string;overload;
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
                           result := '$' + inttohex(int64(data), 8);
                      end
                  else result := 'nil';
end;
function MyDataToStr(data:TEnumData):string;overload;
begin
     if data.Selected>=data.Enums.Count then
                                            result:='ENUMERROR'
                                        else
                                            result:=data.Enums.getData(data.Selected);
end;*)
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
                                                             {$IFDEF LOUDERRORS}
                                                               //Raise Exception.Create('Something wrong');
                                                             {$ENDIF}


                                 end;
     ppd^.Name:=name;
     ppd^.ValType:=valtype;
     ppd^.ValKey:=valkey;
     ppd^.PTypeManager:=@self;
     ppd^.Decorators:=Decorators;
     convertToRunTime(FastEditors,ppd^.FastEditors);
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
     //IncAddr(addr);
end;
class function TOrdinalTypeManipulator<T>.GetValueAsString(const data:T):TInternalScriptString;
begin
     result:=data.tostring;
     //Str(data,result)
  //result:=inttostr(LongInt(data));
end;
class procedure TOrdinalTypeManipulator<T>.SetValueFromString(var data:T;Value:TInternalScriptString);
var
  td:T;
  e:integer;
begin
  val(Value,td,e);
  if e=0 then
    data:=td;
end;
class function TOrdinalTypeManipulator<T>.GetFormattedValueAsString(const data:T; const f:TzeUnitsFormat):TInternalScriptString;
begin
   result:=GetValueAsString(data);
end;
class function TOrdinalTypeManipulator<T>.Compare(const left,right:T):TCompareResult;
begin
     if left<>right
     then
       begin
            if left<right then
                              result:=CRLess
                          else
                              result:=CRGreater;
       end
     else
         result:=CREqual;
end;
class function TFloatTypeManipulator<T>.GetValueAsString(const data:T):TInternalScriptString;
begin
    //Str(data:10:10,result);
    result:=data.tostring;
    if pos('.',result)<1 then
                             result:=result+'.0';
end;
class function TFloatTypeManipulator<T>.GetFormattedValueAsString(const data:T; const f:TzeUnitsFormat):TInternalScriptString;
begin
   result:=zeDimensionToString(data,f);
end;
class procedure TFloatTypeManipulator<T>.SetValueFromString(var data:T;Value:TInternalScriptString);
var
     td:T;
     error:integer;
begin
     val(value,td,error);
     if error=0 then
                    data:=td;
end;
class function TFloatTypeManipulator<T>.Compare(const left,right:T):TCompareResult;
begin
     if left<>right
     then
       begin
            if left<right then
                              result:=CRLess
                          else
                              result:=CRGreater;
       end
     else
         result:=CREqual;
end;

class function TStringTypeManipulator<T>.GetValueAsString(const data:T):TInternalScriptString;
begin
    result:=uni2cp(data);
end;
class function TStringTypeManipulator<T>.GetFormattedValueAsString(const data:T; const f:TzeUnitsFormat):TInternalScriptString;
begin
   result:=GetValueAsString(data);
end;
class procedure TStringTypeManipulator<T>.SetValueFromString(var data:T;Value:TInternalScriptString);
begin
     data:=cp2uni(Value);
end;
class function TStringTypeManipulator<T>.Compare(const left,right:T):TCompareResult;
begin
     if left<>right
     then
       begin
            if left<right then
                              result:=CRLess
                          else
                              result:=CRGreater;
       end
     else
         result:=CREqual;
end;


class function TAnsiStringTypeManipulator<T>.GetValueAsString(const data:T):TInternalScriptString;
begin
    result:=ansi2cp(data);
end;
class function TAnsiStringTypeManipulator<T>.GetFormattedValueAsString(const data:T; const f:TzeUnitsFormat):TInternalScriptString;
begin
   result:=GetValueAsString(data);
end;
class procedure TAnsiStringTypeManipulator<T>.SetValueFromString(var data:T;Value:TInternalScriptString);
begin
     data:=cp2ansi(Value);
end;
class function TAnsiStringTypeManipulator<T>.Compare(const left,right:T):TCompareResult;
begin
     if left<>right
     then
       begin
            if left<right then
                              result:=CRLess
                          else
                              result:=CRGreater;
       end
     else
         result:=CREqual;
end;

class function TBoolTypeManipulator<T>.GetValueAsString(const data:T):TInternalScriptString;
begin
  result:=BoolToStr(data,'True','False');
end;
class procedure TBoolTypeManipulator<T>.SetValueFromString(var data:T;Value:TInternalScriptString);
begin
  data:=StrToBoolDef(Value,False);
end;
class function TBoolTypeManipulator<T>.GetFormattedValueAsString(const data:T; const f:TzeUnitsFormat):TInternalScriptString;
begin
   result:=GetValueAsString(data);
end;
class function TBoolTypeManipulator<T>.Compare(const left,right:T):TCompareResult;
begin
     if left<>right
     then
       begin
            if left<right then
                              result:=CRLess
                          else
                              result:=CRGreater;
       end
     else
         result:=CREqual;
end;
constructor BaseTypeDescriptor<T,TManipulator>.init(tname:string;pu:pointer);
begin
     inherited init(sizeof(t),tname,pu);
end;

function BaseTypeDescriptor<T,TManipulator>.GetValueAsString;
begin
  result:=TManipulator.GetValueAsString(TManipulator.PT(pinstance)^);
end;
function BaseTypeDescriptor<T,TManipulator>.GetFormattedValueAsString(PInstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;
begin
  result:=TManipulator.GetFormattedValueAsString(TManipulator.PT(pinstance)^,f);
end;
function BaseTypeDescriptor<T,TManipulator>.CreateProperties;
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
                                                               Raise Exception.Create('Something wrong');}


                                 end;
     ppd^.Name:=name;
     ppd^.ValKey:=valkey;
     ppd^.ValType:=valtype;
     ppd^.PTypeManager:=@self;
     ppd^.Decorators:=Decorators;
     convertToRunTime(FastEditors,ppd^.FastEditors);
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
     //IncAddr(addr);
end;
procedure BaseTypeDescriptor<T,TManipulator>.SetValueFromString;
begin
  TManipulator.SetValueFromString(TManipulator.pt(PInstance)^,Value);
end;
procedure GDBStringGeneralDescriptor<T,TManipulator>.CopyInstanceTo;
begin
     PT(dest)^:=PT(source)^;
end;
procedure GDBStringGeneralDescriptor<T,TManipulator>.MagicFreeInstance;
begin
     {pstring}PT(Pinstance)^:='';
end;
procedure GDBStringGeneralDescriptor<T,TManipulator>.MagicAfterCopyInstance;
var
   s:{TInternalScriptString}T;
begin
     s:=pt(Pinstance)^;
     //killstring(s);
     pointer(s):=nil;
     //KillString(pstring(Pinstance)^);
end;

class function TPointerTypeManipulator<T>.GetValueAsString(const data:T):TInternalScriptString;
begin
     if data<>nil then
                      begin
                           result := '$' + inttohex(int64(data), 8);
                      end
                  else result := 'nil';
end;
class procedure TPointerTypeManipulator<T>.SetValueFromString(var data:T;Value:TInternalScriptString);
begin
end;
class function TPointerTypeManipulator<T>.GetFormattedValueAsString(const data:T; const f:TzeUnitsFormat):TInternalScriptString;
begin
   result:=GetValueAsString(data);
end;
class function TPointerTypeManipulator<T>.Compare(const left,right:T):TCompareResult;
begin
     if left<>right
     then
       begin
            if left<right then
                              result:=CRLess
                          else
                              result:=CRGreater;
       end
     else
         result:=CREqual;
end;
procedure GDBStringDescriptor.SavePasToMem;
begin
     membuf.TXTAddGDBStringEOL(prefix+':='''+{pvd.data.PTD.}GetValueAsString(PInstance)+''';');
end;
procedure GDBAnsiStringDescriptor.SavePasToMem;
begin
     membuf.TXTAddGDBStringEOL(prefix+':='''+{pvd.data.PTD.}GetValueAsString(PInstance)+''';');
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
procedure TEnumDataDescriptor.SetValueFromString(PInstance:Pointer;_Value:TInternalScriptString);
var
    p:pstring;
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
    p:Pointer;
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
     FundamentalInt64Descriptor.init('Int64',nil);

     FundamentalStringDescriptorObj.init('String',nil);
     FundamentalUnicodeStringDescriptorObj.init('UnicodeString',nil);
     FundamentalAnsiStringDescriptorObj.init('AnsiString',nil);

     FundamentalDoubleDescriptorObj.init('Double',nil);
     FundamentalSingleDescriptorObj.init('Single',nil);

     AliasIntegerDescriptorOdj.init2(@FundamentalLongIntDescriptorObj,'Integer',nil);
     AliasCardinalDescriptorOdj.init2(@FundamentalLongWordDescriptorObj,'Cardinal',nil);
     AliasDWordDescriptorOdj.init2(@FundamentalLongWordDescriptorObj,'DWord',nil);
     AliasUInt64DescriptorOdj.init2(@FundamentalQWordDescriptorObj,'UInt64',nil);

     {$ifdef CPU64}
       AliasPtrUIntDescriptorOdj.init2(@AliasDWordDescriptorOdj,'QWord',nil);
       AliasPtrIntDescriptorOdj.init2(@FundamentalInt64Descriptor,'PtrInt',nil);
     {$endif CPU64}

     {$ifdef CPU32}
       AliasPtrUIntDescriptorOdj.init2(@AliasDWordDescriptorOdj,'PtrUInt',nil);
       AliasPtrIntDescriptorOdj.init2(@FundamentalLongIntDescriptorObj,'PtrInt',nil);
     {$endif CPU32}


     GDBEnumDataDescriptorObj.init;
end.

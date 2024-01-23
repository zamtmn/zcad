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

unit UBaseTypeDescriptor;

{$MODE DELPHI}
interface
uses
      typinfo,LCLProc,Graphics,classes,Themes,
      gzctnrVectorTypes,uzemathutils,uzegeometry,uzbstrproc,TypeDescriptors,
      sysutils,uzctnrVectorBytes,
      USinonimDescriptor,uzedimensionaltypes,varmandef,uzbtypes,
      base64,uzctnrvectorstrings,math,uzbLogIntf;
resourcestring
  rsDifferent='Different';
type
TBaseTypeManipulator<T>=class
type
 PT=^T;
 class function Compare(const left,right:T):TCompareResult;
 class procedure Initialize(var Instance:T);
end;
TOrdinalTypeManipulator<T>=class(TBaseTypeManipulator<T>)
  class function GetValueAsString(const data:T):TInternalScriptString;
  class function GetFormattedValueAsString(const data:T; const f:TzeUnitsFormat):TInternalScriptString;
  class procedure setFormattedValueAsString(var data:T; const f:TzeUnitsFormat;Value:TInternalScriptString);
  class procedure SetValueFromString(var data:T;Value:TInternalScriptString);
end;
TBoolTypeManipulator<T>=class(TBaseTypeManipulator<T>)
  class function GetValueAsString(const data:T):TInternalScriptString;
  class function GetFormattedValueAsString(const data:T; const f:TzeUnitsFormat):TInternalScriptString;
  class procedure setFormattedValueAsString(var data:T; const f:TzeUnitsFormat;Value:TInternalScriptString);
  class procedure SetValueFromString(var data:T;Value:TInternalScriptString);
end;
TFloatTypeManipulator<T>=class(TBaseTypeManipulator<T>)
  class function GetValueAsString(const data:T):TInternalScriptString;
  class function GetFormattedValueAsString(const data:T; const f:TzeUnitsFormat):TInternalScriptString;
  class procedure setFormattedValueAsString(var data:T; const f:TzeUnitsFormat;Value:TInternalScriptString);
  class procedure SetValueFromString(var data:T;Value:TInternalScriptString);
end;
TStringTypeManipulator<T>=class(TBaseTypeManipulator<T>)
  class function GetValueAsString(const data:T):TInternalScriptString;
  class function GetFormattedValueAsString(const data:T; const f:TzeUnitsFormat):TInternalScriptString;
  class procedure setFormattedValueAsString(var data:T; const f:TzeUnitsFormat;Value:TInternalScriptString);
  class procedure SetValueFromString(var data:T;Value:TInternalScriptString);
end;
TAnsiStringTypeManipulator<T>=class(TBaseTypeManipulator<T>)
  class function GetValueAsString(const data:T):TInternalScriptString;
  class function GetFormattedValueAsString(const data:T; const f:TzeUnitsFormat):TInternalScriptString;
  class procedure setFormattedValueAsString(var data:T; const f:TzeUnitsFormat;Value:TInternalScriptString);
  class procedure SetValueFromString(var data:T;Value:TInternalScriptString);
end;
TPointerTypeManipulator<T>=class(TBaseTypeManipulator<T>)
  class function GetValueAsString(const data:T):TInternalScriptString;
  class function GetFormattedValueAsString(const data:T; const f:TzeUnitsFormat):TInternalScriptString;
  class procedure setFormattedValueAsString(var data:T; const f:TzeUnitsFormat;Value:TInternalScriptString);
  class procedure SetValueFromString(var data:T;Value:TInternalScriptString);
end;
PBaseTypeDescriptor=^{BaseTypeDescriptor}TUserTypeDescriptor;
BaseTypeDescriptor<T,TManipulator>=object(TUserTypeDescriptor)
                         type
                          PT=^T;
                         constructor init(tname:string;pu:pointer);

                         function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                         function GetFormattedValueAsString(PInstance:Pointer;const f:TzeUnitsFormat):TInternalScriptString;virtual;
                         procedure SetFormattedValueFromString(PInstance:Pointer;const f:TzeUnitsFormat;Value:TInternalScriptString);virtual;
                         function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;Name:TInternalScriptString;PCollapsed:Pointer;ownerattrib:Word;var bmode:Integer;const addr:Pointer;ValKey,ValType:TInternalScriptString):PTPropertyDeskriptorArray;virtual;
                         procedure SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);virtual;
                         procedure InitInstance(PInstance:Pointer);virtual;
                         function AllocInstance:Pointer;virtual;
                   end;
TBTM_Boolean=TBoolTypeManipulator<Boolean>;
BooleanDescriptor=object(BaseTypeDescriptor<boolean,{TBoolTypeManipulator<boolean>}TBTM_Boolean>)
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
IntegerDescriptor=object(BaseTypeDescriptor<Integer,{TOrdinalTypeManipulator<Integer>}TOTM_Integer>)
                    end;
TOTM_LongWord=TOrdinalTypeManipulator<LongWord>;
TFundamentalLongWordDescriptor=object(BaseTypeDescriptor<LongWord,{TOrdinalTypeManipulator<LongWord>}TOTM_LongWord>)
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
DoubleDescriptor=object(BaseTypeDescriptor<double,{TFloatTypeManipulator<double>}TFTM_Double>)
                    end;
TFTM_float=TOrdinalTypeManipulator<float>;
FloatDescriptor=object(BaseTypeDescriptor<float,{TFloatTypeManipulator<TFTM_float>}TFTM_float>)
                    end;
StringGeneralDescriptor<T,TManipulator>=object(BaseTypeDescriptor<T,TManipulator>)
                          procedure CopyInstanceTo(source,dest:pointer);virtual;
                          procedure MagicFreeInstance(PInstance:Pointer);virtual;
                          procedure MagicAfterCopyInstance(PInstance:Pointer);virtual;
                    end;
TSTM_UnicodeString=TStringTypeManipulator<UnicodeString>;
GDBUnicodeStringDescriptor=object(StringGeneralDescriptor<UnicodeString,TSTM_UnicodeString>)
                    end;
TSTM_String=TStringTypeManipulator<String>;
StringDescriptor=object(StringGeneralDescriptor<string,{TStringTypeManipulator<string>}TSTM_String>)
                          procedure SavePasToMem(var membuf:TZctnrVectorBytes;PInstance:Pointer;prefix:TInternalScriptString);virtual;
                    end;
TASTM_String=TAnsiStringTypeManipulator<String>;
AnsiStringDescriptor=object(StringGeneralDescriptor<string,{TAnsiStringTypeManipulator<string>}TASTM_String>)
                          procedure SavePasToMem(var membuf:TZctnrVectorBytes;PInstance:Pointer;prefix:TInternalScriptString);virtual;
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

var
FundamentalDoubleDescriptorObj:DoubleDescriptor;
FundamentalUnicodeStringDescriptorObj:GDBUnicodeStringDescriptor;
FundamentalStringDescriptorObj:StringDescriptor;
FundamentalAnsiStringDescriptorObj:AnsiStringDescriptor;
FundamentalWordDescriptorObj:TFundamentalWordDescriptor;
FundamentalLongIntDescriptorObj:TFundamentalLongIntDescriptor;
FundamentalByteDescriptorObj:TFundamentalByteDescriptor;
FundamentalSmallIntDescriptorObj:TFundamentalSmallIntDescriptor;
FundamentalLongWordDescriptorObj:TFundamentalLongWordDescriptor;
FundamentalQWordDescriptorObj:TFundamentalQWordDescriptor;
FundamentalInt64Descriptor:TFundamentalInt64Descriptor;
FundamentalSingleDescriptorObj:FloatDescriptor;
FundamentalShortIntDescriptorObj:TFundamentalShortIntDescriptor;
FundamentalBooleanDescriptorOdj:BooleanDescriptor;
FundamentalPointerDescriptorOdj:PointerDescriptor;
GDBEnumDataDescriptorObj:TEnumDataDescriptor;

AliasIntegerDescriptorOdj:GDBSinonimDescriptor;
AliasCardinalDescriptorOdj:GDBSinonimDescriptor;
AliasDWordDescriptorOdj:GDBSinonimDescriptor;
AliasPtrUIntDescriptorOdj:GDBSinonimDescriptor;
AliasPtrIntDescriptorOdj:GDBSinonimDescriptor;
AliasUInt64DescriptorOdj:GDBSinonimDescriptor;
implementation
class function TBaseTypeManipulator<T>.Compare(const left,right:T):TCompareResult;
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
class procedure TBaseTypeManipulator<T>.Initialize(var Instance:T);
begin
   system.initialize(Instance);
end;

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
     zTraceLn('{T}[ZSCRIPT]TEnumDataDescriptor.CreateProperties(%s,ppda=%p)',[name,ppda]);
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
                                                             {IFDEF LOUDERRORS}
                                                               //Raise Exception.Create('Something wrong');
                                                             {ENDIF}


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
                                //inc(PByte(addr),SizeInBytes);
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
class procedure TOrdinalTypeManipulator<T>.setFormattedValueAsString(var data:T; const f:TzeUnitsFormat;Value:TInternalScriptString);
var
  td:T;
  e:integer;
begin
  val(Value,td,e);
  if e=0 then
    data:=td;
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
class procedure TFloatTypeManipulator<T>.setFormattedValueAsString(var data:T; const f:TzeUnitsFormat;Value:TInternalScriptString);
var
     td:T;
     error:integer;
begin
     val(value,td,error);
     if error=0 then
                    data:=td;
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
class procedure TStringTypeManipulator<T>.setFormattedValueAsString(var data:T; const f:TzeUnitsFormat;Value:TInternalScriptString);
begin
     data:=cp2uni(Value);
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
class procedure TAnsiStringTypeManipulator<T>.setFormattedValueAsString(var data:T; const f:TzeUnitsFormat;Value:TInternalScriptString);
begin
     data:=cp2uni(Value);
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
class procedure TBoolTypeManipulator<T>.setFormattedValueAsString(var data:T; const f:TzeUnitsFormat;Value:TInternalScriptString);
begin
  data:=StrToBoolDef(Value,False);
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
     zTraceLn('{T}[ZSCRIPT]BaseTypeDescriptor.CreateProperties(%s,ppda=%p)',[name,ppda]);
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
                                //inc(PByte(addr),SizeInBytes);
                                //if bmode=property_build then PPDA^.add(@ppd);
                           end;
     //IncAddr(addr);
end;
procedure BaseTypeDescriptor<T,TManipulator>.SetValueFromString;
begin
  TManipulator.SetValueFromString(TManipulator.pt(PInstance)^,Value);
end;
procedure BaseTypeDescriptor<T,TManipulator>.SetFormattedValueFromString(PInstance:Pointer;const f:TzeUnitsFormat;Value:TInternalScriptString);
begin
  TManipulator.setFormattedValueAsString(TManipulator.pt(PInstance)^,f,Value);
end;
procedure BaseTypeDescriptor<T,TManipulator>.InitInstance(PInstance:Pointer);
begin
  TManipulator.Initialize(TManipulator.pt(PInstance)^);
end;
function BaseTypeDescriptor<T,TManipulator>.AllocInstance:Pointer;
begin
  Getmem(result,SizeOf(T));
end;
procedure StringGeneralDescriptor<T,TManipulator>.CopyInstanceTo;
begin
     PT(dest)^:=PT(source)^;
end;
procedure StringGeneralDescriptor<T,TManipulator>.MagicFreeInstance;
begin
     {pstring}PT(Pinstance)^:='';
end;
procedure StringGeneralDescriptor<T,TManipulator>.MagicAfterCopyInstance;
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
class procedure TPointerTypeManipulator<T>.setFormattedValueAsString(var data:T; const f:TzeUnitsFormat;Value:TInternalScriptString);
begin
end;
class function TPointerTypeManipulator<T>.GetFormattedValueAsString(const data:T; const f:TzeUnitsFormat):TInternalScriptString;
begin
   result:=GetValueAsString(data);
end;
function IsNeedBase64(value:TInternalScriptString):boolean;
var
  i:integer;
begin
  for i:=1 to length(value) do
    if (ord(value[i])<32)or(value[i] in [''''])then
      exit(true);
  result:=False;
end;

procedure StringDescriptor.SavePasToMem;
var
  value:TInternalScriptString;
begin
  value:=GetValueAsString(PInstance);
  if IsNeedBase64(value)then
    membuf.TXTAddStringEOL(prefix+':=DecodeStringBase64('''+EncodeStringBase64(GetValueAsString(PInstance))+''');')
  else
    membuf.TXTAddStringEOL(prefix+':='''+GetValueAsString(PInstance)+''';')
end;
procedure AnsiStringDescriptor.SavePasToMem;
var
  value:TInternalScriptString;
begin
  value:=GetValueAsString(PInstance);
  if IsNeedBase64(value)then
    membuf.TXTAddStringEOL(prefix+':=DecodeStringBase64('''+EncodeStringBase64(GetValueAsString(PInstance))+''');')
  else
    membuf.TXTAddStringEOL(prefix+':='''+GetValueAsString(PInstance)+''';')
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
{var currval:LongWord;
    p:Pointer;
    found:Boolean;
    i:Integer;
    num:cardinal;}
begin
     if PTEnumData(Pinstance)^.Selected>=PTEnumData(Pinstance)^.Enums.Count then
                                                                               result:='ENUMERROR'
                                                                           else
                                                                               result:=PTEnumData(Pinstance)^.Enums.getData(PTEnumData(Pinstance)^.Selected);
     {GetNumberInArrays(pinstance,num);
     result:=UserValue.getString(num)}
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
       AliasPtrUIntDescriptorOdj.init2(@FundamentalQWordDescriptorObj,'PtrUInt',nil);
       AliasPtrIntDescriptorOdj.init2(@FundamentalInt64Descriptor,'PtrInt',nil);
     {$endif CPU64}

     {$ifdef CPU32}
       AliasPtrUIntDescriptorOdj.init2(@AliasDWordDescriptorOdj,'PtrUInt',nil);
       AliasPtrIntDescriptorOdj.init2(@FundamentalLongIntDescriptorObj,'PtrInt',nil);
     {$endif CPU32}


     GDBEnumDataDescriptorObj.init;
end.

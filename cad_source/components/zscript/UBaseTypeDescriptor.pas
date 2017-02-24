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
{ASMMODE intel}
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
                         function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                         function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;Name:TInternalScriptString;PCollapsed:Pointer;ownerattrib:Word;var bmode:Integer;var addr:Pointer;ValKey,ValType:TInternalScriptString):PTPropertyDeskriptorArray;virtual;
                         //function Serialize(PInstance:Pointer;SaveFlag:Word;var membuf:PGDBOpenArrayOfByte;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;
                         //function DeSerialize(PInstance:Pointer;SaveFlag:Word;var membuf:GDBOpenArrayOfByte;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;
                         procedure SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);virtual;
                   end;
GDBBooleanDescriptor=object(BaseTypeDescriptor<boolean>)
                          function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                          procedure SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
TFundamentalShortIntDescriptor=object(BaseTypeDescriptor<shortint>)
                          function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                          procedure SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
TFundamentalByteDescriptor=object(BaseTypeDescriptor<byte>)
                          function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                          procedure SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
TFundamentalSmallIntDescriptor=object(BaseTypeDescriptor<smallint>)
                          function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                          procedure SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
TFundamentalWordDescriptor=object(BaseTypeDescriptor<word>)
                          function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                          procedure SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBIntegerDescriptor=object(BaseTypeDescriptor<Integer>)
                          function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                          procedure SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
TFundamentalLongWordDescriptor=object(BaseTypeDescriptor<Longword>)
                          function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                          procedure SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
TFundamentalLongIntDescriptor=object(BaseTypeDescriptor<LongInt>)
                          function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                          procedure SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
TFundamentalQWordDescriptor=object(BaseTypeDescriptor<qword>)
                          function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                          procedure SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBDoubleDescriptor=object(BaseTypeDescriptor<double>)
                          function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                          function GetFormattedValueAsString(PInstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;virtual;
                          procedure SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBStringDescriptor=object(BaseTypeDescriptor<string>)
                          //function Serialize(PInstance:Pointer;SaveFlag:Word;var membuf:PGDBOpenArrayOfByte;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;
                          //function DeSerialize(PInstance:Pointer;SaveFlag:Word;var membuf:GDBOpenArrayOfByte;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;
                          procedure SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);virtual;
                          function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                          procedure CopyInstanceTo(source,dest:pointer);virtual;
                          procedure MagicFreeInstance(PInstance:Pointer);virtual;
                          procedure MagicAfterCopyInstance(PInstance:Pointer);virtual;
                          procedure SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:Pointer;prefix:TInternalScriptString);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBAnsiStringDescriptor=object(GDBStringDescriptor)
                          procedure SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);virtual;
                          function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBFloatDescriptor=object(BaseTypeDescriptor<float>)
                          function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                          procedure SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
PointerDescriptor=object(BaseTypeDescriptor<pointer>)
                          function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                          procedure SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:Pointer;prefix:TInternalScriptString);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBPtrUIntDescriptor=object(BaseTypeDescriptor<PtrUint>)
                          constructor init;
                          function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                          procedure SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
TEnumDataDescriptor=object(BaseTypeDescriptor<TEnumData>)
                     constructor init;
                     function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                     procedure SetValueFromString(PInstance:Pointer;_Value:TInternalScriptString);virtual;
                     function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;Name:TInternalScriptString;PCollapsed:Pointer;ownerattrib:Word;var bmode:Integer;var addr:Pointer;ValKey,ValType:TInternalScriptString):PTPropertyDeskriptorArray;virtual;
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
FundamentalPointerDescriptorOdj:PointerDescriptor;
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
                           result := '$' + inttohex(int64(data), 8);
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
procedure GDBBooleanDescriptor.SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);
begin
     if uppercase(value)='TRUE' then
                                    PBoolean(pinstance)^:=true
else if uppercase(value)='FALSE' then
                                     PBoolean(pinstance)^:=false
else
    DebugLn('{E}GDBBooleanDescriptor.SetValueFromString('+value+') {not false\true}');
    //programlog.LogOutStr('GDBBooleanDescriptor.SetValueFromString('+value+') {not false\true}',lp_OldPos,LM_Error);
end;
function GDBBooleanDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if PBoolean(pleft)^<>PBoolean(pright)^ then
                                                      result:=CRNotEqual
                                                  else
                                                      result:=CREqual;
end;
function GDBBooleanDescriptor.GetValueAsString;
begin
     if PBoolean(pinstance)^ then
     result := 'True'
     else
     result := 'False';
end;
function TFundamentalLongWordDescriptor.GetValueAsString;
var
     uGDBInteger:Longword;
begin
    uGDBInteger := pLongword(pinstance)^;
    result := inttostr(uGDBInteger);
end;
procedure TFundamentalLongWordDescriptor.SetValueFromString;
var
     vGDBLongword:Longword;
     error:integer;
begin
     val(value,vGDBLongword,error);
     if error=0 then
                    pLongword(pinstance)^:=vGDBLongword;
end;
function TFundamentalLongWordDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if pLongword(pleft)^<>pLongword(pright)^
     then
       begin
            if pLongword(pleft)^<pLongword(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;
function TFundamentalQWordDescriptor.GetValueAsString;
var
     qw:QWord;
begin
    qw := PWord(pinstance)^;
    result := inttostr(qw);
end;
procedure TFundamentalQWordDescriptor.SetValueFromString;
var
     qw:QWord;
     //error:integer;
begin
     {$IFNDEF DELPHI}
     if TryStrToQWord(value,qw) then
                                   PQWord(pinstance)^:=qw;
     {$ENDIF}
end;
function TFundamentalQWordDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if PQWord(pleft)^<>PQWord(pright)^
     then
       begin
            if PQWord(pleft)^<PQWord(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;
function GDBFloatDescriptor.GetValueAsString;
var
     uGDBFloat:Float;
begin
    uGDBFloat:=pFloat(pinstance)^;
    result := floattostr(uGDBFloat);
    if pos('.',result)<1 then
                             result:=result+'.0';
end;
procedure GDBFloatDescriptor.SetValueFromString;
var
     vGDBFloat:Float;
     error:integer;
begin
     val(value,vGDBFloat,error);
     if error=0 then
                    pFloat(pinstance)^:=vGDBFloat;
end;
function GDBFloatDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if IsFloatNotEqual(pFloat(pleft)^,pFloat(pright)^)
     then
       begin
            if pFloat(pleft)^<pFloat(pright)^ then
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
     uGDBDouble:Double;
begin
    uGDBDouble:=pDouble(pinstance)^;
    if isnan(uGDBDouble) then
                             result := 'NAN'
                         else
                             begin
                                  result := floattostr(uGDBDouble);
                                      if pos('.',result)<1 then
                                                               result:=result+'.0';
                             end;

end;
function GDBDoubleDescriptor.GetFormattedValueAsString(PInstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;
begin
    result:=zeDimensionToString(PDouble(PInstance)^,f);
end;

procedure GDBDoubleDescriptor.SetValueFromString;
var
     uGDBDouble:Double;
     error:integer;
begin
     val(value,ugdbdouble,error);
     if error=0 then
                    pDouble(pinstance)^:=ugdbdouble;
end;
function GDBDoubleDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if IsDoubleNotEqual(PDouble(pleft)^,PDouble(pright)^)
     then
       begin
            if PDouble(pleft)^<PDouble(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;
function TFundamentalWordDescriptor.GetValueAsString;
var
     uGDBWord:Word;
begin
    uGDBWord := pWord(pinstance)^;
    result := inttostr(uGDBWord);
end;
procedure TFundamentalWordDescriptor.SetValueFromString;
var
     vGDBWord:Word;
     error:integer;
begin
     val(value,vGDBWord,error);
     if error=0 then
                    pWord(pinstance)^:=vGDBWord;
end;
function TFundamentalWordDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if pWord(pleft)^<>pWord(pright)^
     then
       begin
            if pWord(pleft)^<pWord(pright)^ then
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
    uGDBInteger := pInteger(pinstance)^;
    result := inttostr(uGDBInteger);
end;
procedure TFundamentalLongIntDescriptor.SetValueFromString;
var
     vGDBInteger:LongInt;
     error:integer;
begin
     val(value,vGDBInteger,error);
     if error=0 then
                    pInteger(pinstance)^:=vGDBInteger;
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
     uGDBInteger:Integer;
begin
    uGDBInteger := pInteger(pinstance)^;
    result := inttostr(uGDBInteger);
end;
procedure GDBIntegerDescriptor.SetValueFromString;
var
     vGDBInteger:Integer;
     error:integer;
begin
     val(value,vGDBInteger,error);
     if error=0 then
                    pInteger(pinstance)^:=vGDBInteger;
end;
function GDBIntegerDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if pInteger(pleft)^<>pInteger(pright)^
     then
       begin
            if pInteger(pleft)^<pInteger(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;
function TFundamentalShortIntDescriptor.GetValueAsString;
var
     uGDBShortint:Shortint;
begin
    uGDBShortint := pShortint(pinstance)^;
    result := inttostr(uGDBShortint);
end;
procedure TFundamentalShortIntDescriptor.SetValueFromString;
var
     vGDBShortint:Shortint;
     error:integer;
begin
     val(value,vGDBshortint,error);
     if error=0 then                           
                    pshortint(pinstance)^:=vGDBshortint;
end;
function TFundamentalShortIntDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if pshortint(pleft)^<>pshortint(pright)^
     then
       begin
            if pshortint(pleft)^<pshortint(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;
function TFundamentalByteDescriptor.GetValueAsString;
var
     uGDBByte:Byte;
begin
    uGDBByte := pByte(pinstance)^;
    result := inttostr(uGDBByte);
end;
procedure TFundamentalByteDescriptor.SetValueFromString;
var
     vGDBbyte:byte;
     error:integer;
begin
     val(value,vGDBbyte,error);
     if error=0 then
                    pbyte(pinstance)^:=vGDBbyte;
end;
function TFundamentalByteDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if pbyte(pleft)^<>pbyte(pright)^
     then
       begin
            if pbyte(pleft)^<pbyte(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;
function TFundamentalSmallIntDescriptor.GetValueAsString;
var
     uGDBSmallint:Smallint;
begin
    uGDBSmallint := pSmallint(pinstance)^;
    result := inttostr(uGDBSmallint);
end;
procedure TFundamentalSmallIntDescriptor.SetValueFromString;
var
     vGDBSmallint:Smallint;
     error:integer;
begin
     val(value,vGDBSmallint,error);
     if error=0 then
                    pSmallint(pinstance)^:=vGDBSmallint;
end;
function TFundamentalSmallIntDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if pSmallint(pleft)^<>pSmallint(pright)^
     then
       begin
            if pSmallint(pleft)^<pSmallint(pright)^ then
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
   s:TInternalScriptString;
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
     if PString(pleft)^<>PString(pright)^
     then
       begin
            if PString(pleft)^<PString(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;
function PointerDescriptor.GetValueAsString;
var
     uPointer:Pointer;
     uGDBInteger: Longword;
begin
    uPointer := pPointer(pinstance)^;
                if uPointer<>nil then
                                             begin
                                                  uGDBInteger := ptrint(uPointer);
                                                  result := '$' + inttohex(int64(uGDBInteger), 8);
                                             end
                                         else result := 'nil';
end;
procedure PointerDescriptor.SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:Pointer;prefix:TInternalScriptString);
begin
end;
function PointerDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if pPointer(pleft)^<>pPointer(pright)^
     then
       begin
            if pPointer(pleft)^<pPointer(pright)^ then
                                                          result:=CRLess
                                                      else
                                                          result:=CRGreater;
       end
     else
         result:=CREqual;
end;

function GDBStringDescriptor.GetValueAsString;
var
     uGDBString:TInternalScriptString;
begin
    uGDBString := pString(pinstance)^;
    result := uni2cp(uGDBString);
end;
procedure GDBStringDescriptor.SetValueFromString;
//var
//     vGDBLongword:Word;
//     error:integer;
begin
     //val(value,vGDBLongword,error);
     //if error=0 then
                    pString(pinstance)^:=cp2uni(value);//vGDBLongword;
end;
procedure GDBAnsiStringDescriptor.SetValueFromString(PInstance:Pointer;Value:TInternalScriptString);
//var
//     vGDBLongword:Word;
//     error:integer;
begin
     //val(value,vGDBLongword,error);
     //if error=0 then
                    pString(pinstance)^:=cp2ansi(value);//vGDBLongword;
end;
function GDBAnsiStringDescriptor.GetValueAsString(pinstance:Pointer):TInternalScriptString;
var
     uGDBString:TInternalScriptString;
begin
    uGDBString := pString(pinstance)^;
    result := ansi2cp(uGDBString);
end;
function GDBAnsiStringDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if PAnsiString(pleft)^<>PAnsiString(pright)^
     then
       begin
            if PAnsiString(pleft)^<PAnsiString(pright)^ then
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

     FundamentalStringDescriptorObj.init('String',nil);
     FundamentalAnsiStringDescriptorObj.init('AnsiString',nil);

     FundamentalDoubleDescriptorObj.init('Double',nil);
     FundamentalSingleDescriptorObj.init('Single',nil);

     AliasIntegerDescriptorOdj.init2(@FundamentalLongIntDescriptorObj,'Integer',nil);
     AliasCardinalDescriptorOdj.init2(@FundamentalLongWordDescriptorObj,'Cardinal',nil);

     GDBEnumDataDescriptorObj.init;
     GDBPtrUIntDescriptorObj.init;
end.

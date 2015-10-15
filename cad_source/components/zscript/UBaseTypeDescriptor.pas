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
      zemathutils,geometry,{zcadstrconsts,}strproc,{log,}TypeDescriptors,UGDBOpenArrayOfTObjLinkRecord,sysutils,UGDBOpenArrayOfByte,gdbasetypes,
      {usupportgui,}varmandef,gdbase,UGDBOpenArrayOfData,UGDBStringArray,memman,math{,shared};
resourcestring
  rsDifferent='Different';
type
PBaseTypeDescriptor=^BaseTypeDescriptor;
BaseTypeDescriptor=object(TUserTypeDescriptor)
                         function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;Name:GDBString;PCollapsed:GDBPointer;ownerattrib:GDBWord;var bmode:GDBInteger;var addr:GDBPointer;ValKey,ValType:GDBString):PTPropertyDeskriptorArray;virtual;
                         function Serialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:PGDBOpenArrayOfByte;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;
                         function DeSerialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:GDBOpenArrayOfByte;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;
                         procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                   end;
GDBBooleanDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBShortintDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBByteDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBSmallintDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBWordDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBIntegerDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBLongwordDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBQWordDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBDoubleDescriptor=object(BaseTypeDescriptor)
                          constructor init;
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
GDBStringDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function Serialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:PGDBOpenArrayOfByte;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;
                          function DeSerialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:GDBOpenArrayOfByte;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure CopyInstanceTo(source,dest:pointer);virtual;
                          procedure MagicFreeInstance(PInstance:GDBPointer);virtual;
                          procedure MagicAfterCopyInstance(PInstance:GDBPointer);virtual;
                          procedure SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:GDBPointer;prefix:GDBString);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBAnsiStringDescriptor=object(GDBStringDescriptor)
                          constructor init;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBFloatDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBPointerDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:GDBPointer;prefix:GDBString);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
GDBPtrUIntDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function Compare(pleft,pright:pointer):TCompareResult;virtual;
                    end;
TEnumDataDescriptor=object(BaseTypeDescriptor)
                     constructor init;
                     function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                     procedure SetValueFromString(PInstance:GDBPointer;_Value:GDBstring);virtual;
                     function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;Name:GDBString;PCollapsed:GDBPointer;ownerattrib:GDBWord;var bmode:GDBInteger;var addr:GDBPointer;ValKey,ValType:GDBString):PTPropertyDeskriptorArray;virtual;
                     destructor Done;virtual;
               end;
var
GDBDoubleDescriptorObj:GDBDoubleDescriptor;
GDBNonDimensionDoubleDescriptorObj:GDBNonDimensionDoubleDescriptor;
GDBAngleDegDoubleDescriptorObj:GDBAngleDegDoubleDescriptor;
GDBAngleDoubleDescriptorObj:GDBAngleDoubleDescriptor;
GDBStringDescriptorObj:GDBStringDescriptor;
GDBAnsiStringDescriptorObj:GDBAnsiStringDescriptor;
GDBWordDescriptorObj:GDBWordDescriptor;
GDBIntegerDescriptorObj:GDBIntegerDescriptor;
GDBByteDescriptorObj:GDBByteDescriptor;
GDBSmallintDescriptorObj:GDBSmallintDescriptor;
GDBLongwordDescriptorObj:GDBLongwordDescriptor;
GDBQWordDescriptorObj:GDBQWordDescriptor;
GDBFloatDescriptorObj:GDBFloatDescriptor;
GDBShortintDescriptorObj:GDBShortintDescriptor;
GDBBooleanDescriptorOdj:GDBBooleanDescriptor;
GDBPointerDescriptorOdj:GDBPointerDescriptor;
GDBEnumDataDescriptorObj:TEnumDataDescriptor;
GDBPtrUIntDescriptorObj:GDBPtrUIntDescriptor;
implementation
function TEnumDataDescriptor.CreateProperties;
var ppd:PPropertyDeskriptor;
begin
     {$IFDEF TOTALYLOG}
     DebugLn(sysutils.Format('TEnumDataDescriptor.CreateProperties(%s,ppda=%p)',[name,ppda]));
     {$ENDIF}
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
function BaseTypeDescriptor.CreateProperties;
var ppd:PPropertyDeskriptor;
begin
     {$IFDEF TOTALYLOG}
     DebugLn(sysutils.Format('BaseTypeDescriptor.CreateProperties(%s,ppda=%p)',[name,ppda]));
     {$ENDIF}
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
                                      if (ppd^._ppda<>ppda)
                                      //or (ppd^._bmode<>bmode)
                                                             then
                                                                 asm
                                                                    //int 3;
                                                                 end;


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
function BaseTypeDescriptor.Serialize;
var s:string;
begin
     if membuf=nil then
                       begin
                            gdbgetmem({$IFDEF DEBUGBUILD}'{D569104A-E9AE-4A36-A161-9AC3BFF2B5F5}',{$ENDIF}pointer(membuf),sizeof(GDBOpenArrayOfByte));
                            membuf.init({$IFDEF DEBUGBUILD}'{1E74F150-E399-4CF9-8D34-E8F2E2AC0D85}',{$ENDIF}1000000);
                       end;
     if zcpmode=zcpbin then
                           membuf^.AddData(PInstance,SizeInGDBBytes)
                       else
                           begin
                                s:=GetValueAsString(Pinstance);
                                membuf^.AddData(pointer(s),length(s));
                                membuf^.AddData(pointer(lineend),length(lineend));
                           end;
end;
function BaseTypeDescriptor.DeSerialize;
begin
     membuf.ReadData(PInstance,SizeInGDBBytes)
end;
procedure BaseTypeDescriptor.SetValueFromString;
begin
end;
constructor GDBBooleanDescriptor.init;
begin
     inherited init(sizeof(GDBBoolean),'GDBBoolean',nil);
end;
procedure GDBBooleanDescriptor.SetValueFromString(PInstance:GDBPointer;Value:GDBstring);
begin
     if uppercase(value)='TRUE' then
                                    PGDBboolean(pinstance)^:=true
else if uppercase(value)='FALSE' then
                                     PGDBboolean(pinstance)^:=false
else
    {$IFDEF TOTALYLOG}
    DebugLn('GDBBooleanDescriptor.SetValueFromString('+value+') {not false\true}');
    {$ENDIF}
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
constructor GDBLongwordDescriptor.init;
begin
     inherited init(sizeof(GDBLongword),'GDBLongword',nil);
end;
function GDBLongwordDescriptor.GetValueAsString;
var
     uGDBInteger:GDBLongword;
begin
    uGDBInteger := pGDBLongword(pinstance)^;
    result := inttostr(uGDBInteger);
end;
procedure GDBLongwordDescriptor.SetValueFromString;
var
     vGDBLongword:GDBLongword;
     error:integer;
begin
     val(value,vGDBLongword,error);
     if error=0 then
                    pGDBLongword(pinstance)^:=vGDBLongword;
end;
function GDBLongwordDescriptor.Compare(pleft,pright:pointer):TCompareResult;
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
constructor GDBQWordDescriptor.init;
begin
     inherited init(sizeof(GDBQWord),'GDBQWord',nil);
end;
function GDBQWordDescriptor.GetValueAsString;
var
     qw:GDBQWord;
begin
    qw := PGDBQWord(pinstance)^;
    result := inttostr(qw);
end;
procedure GDBQWordDescriptor.SetValueFromString;
var
     qw:GDBQWord;
     //error:integer;
begin
     {$IFNDEF DELPHI}
     if TryStrToQWord(value,qw) then
                                   PGDBQWord(pinstance)^:=qw;
     {$ENDIF}
end;
function GDBQWordDescriptor.Compare(pleft,pright:pointer):TCompareResult;
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
constructor GDBFloatDescriptor.init;
begin
     inherited init(sizeof(GDBFloat),'GDBFloat',nil);
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
     inherited init(sizeof(GDBPointer),'GDBPtrUInt',nil);
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
constructor GDBDoubleDescriptor.init;
begin
     inherited init(sizeof(GDBDouble),'GDBDouble',nil);
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
constructor GDBWordDescriptor.init;
begin
     inherited init(sizeof(GDBWord),'GDBWord',nil);
end;
function GDBWordDescriptor.GetValueAsString;
var
     uGDBWord:GDBWord;
begin
    uGDBWord := pGDBWord(pinstance)^;
    result := inttostr(uGDBWord);
end;
procedure GDBWordDescriptor.SetValueFromString;
var
     vGDBWord:gdbWord;
     error:integer;
begin
     val(value,vGDBWord,error);
     if error=0 then
                    pGDBWord(pinstance)^:=vGDBWord;
end;
function GDBWordDescriptor.Compare(pleft,pright:pointer):TCompareResult;
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
constructor GDBIntegerDescriptor.init;
begin
     inherited init(sizeof(GDBInteger),'GDBInteger',nil);
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
constructor GDBShortintDescriptor.init;
begin
     inherited init(sizeof(GDBshortint),'GDBShortint',nil);
end;
function GDBShortintDescriptor.GetValueAsString;
var
     uGDBShortint:GDBShortint;
begin
    uGDBShortint := pGDBShortint(pinstance)^;
    result := inttostr(uGDBShortint);
end;
procedure GDBShortintDescriptor.SetValueFromString;
var
     vGDBShortint:gdbShortint;
     error:integer;
begin
     val(value,vGDBshortint,error);
     if error=0 then                           
                    pGDBshortint(pinstance)^:=vGDBshortint;
end;
function GDBShortintDescriptor.Compare(pleft,pright:pointer):TCompareResult;
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

constructor GDBByteDescriptor.init;
begin
     inherited init(sizeof(GDBByte),'GDBByte',nil);
end;
function GDBByteDescriptor.GetValueAsString;
var
     uGDBByte:GDBByte;
begin
    uGDBByte := pGDBByte(pinstance)^;
    result := inttostr(uGDBByte);
end;
procedure GDBByteDescriptor.SetValueFromString;
var
     vGDBbyte:gdbbyte;
     error:integer;
begin
     val(value,vGDBbyte,error);
     if error=0 then
                    pGDBbyte(pinstance)^:=vGDBbyte;
end;
function GDBByteDescriptor.Compare(pleft,pright:pointer):TCompareResult;
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
constructor GDBSmallintDescriptor.init;
begin
     inherited init(sizeof(GDBSmallint),'GDBSmallint',nil);
end;
function GDBSmallintDescriptor.GetValueAsString;
var
     uGDBSmallint:GDBSmallint;
begin
    uGDBSmallint := pGDBSmallint(pinstance)^;
    result := inttostr(uGDBSmallint);
end;
procedure GDBSmallintDescriptor.SetValueFromString;
var
     vGDBSmallint:gdbSmallint;
     error:integer;
begin
     val(value,vGDBSmallint,error);
     if error=0 then
                    pGDBSmallint(pinstance)^:=vGDBSmallint;
end;
function GDBSmallintDescriptor.Compare(pleft,pright:pointer):TCompareResult;
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
//var
//   s:GDBString;
begin
     {s:=pstring(Pinstance)^;
     killstring(s);
     //pointer(s):=nil;}
     RemoveOneRefCount(pstring(Pinstance)^);
end;
constructor GDBStringDescriptor.init;
begin
     inherited init(sizeof(GDBString),'GDBString',nil);
end;
constructor GDBPointerDescriptor.init;
begin
     inherited init(sizeof(GDBPointer),'GDBPointer',nil);
end;
function GDBStringDescriptor.Serialize;
var l:gdbword;
    s:gdbstring;
begin
     if membuf=nil then
                       begin
                            gdbgetmem({$IFDEF DEBUGBUILD}'{7E700EF0-5B7C-4188-A911-5CB7A22F823E}',{$ENDIF}pointer(membuf),sizeof(GDBOpenArrayOfByte));
                            membuf.init({$IFDEF DEBUGBUILD}'{D6881B13-EE4D-40A0-BC51-1D0E0CD90F71}',{$ENDIF}1000000);
                       end;
     l:=length(pstring(PInstance)^);
          if zcpmode=zcpbin then
                                begin
                                membuf^.AddData(@L,sizeof(gdbword));
                                membuf^.AddData(@pstring(PInstance)^[1],l)
                                end
                       else
                           begin
                                s:=SerializePreProcess(pstring(PInstance)^,sub);
                                l:=l+sub;
                                membuf^.AddData(@s[1],l);
                                membuf^.AddData(pointer(lineend),length(lineend));
                           end;
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

function GDBStringDescriptor.DeSerialize;
var l:gdbword;
begin
     PGDBString(PInstance)^:='';
     membuf.ReadData(@L,sizeof(gdbword));
     setlength(PGDBString(PInstance)^,l);
     membuf.ReadData(@PGDBString(PInstance)^[1],l)
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
constructor GDBAnsiStringDescriptor.init;
begin
     _init(sizeof(GDBString),'GDBAnsiString',nil);
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
     inherited init(sizeof(TEnumData),'TEnumDataDescriptor',nil);
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
                                                                               result:=PTEnumData(Pinstance)^.Enums.getGDBString(PTEnumData(Pinstance)^.Selected);
     {GetNumberInArrays(pinstance,num);
     result:=UserValue.getGDBString(num)}
end;
begin
       {$IFDEF DEBUGINITSECTION}LogOut('GDBBaseTypeDescriptor.initialization');{$ENDIF}
     //gdbgetmem({$IFDEF DEBUGBUILD}'{2A687C81-843D-4451-8663-384A625BFEBA}',{$ENDIF}pointer(GDBDoubleDescriptorObj),sizeof(GDBDoubleDescriptor));
     GDBDoubleDescriptorObj.init;
     GDBNonDimensionDoubleDescriptorObj.baseinit(sizeof(GDBNonDimensionDouble),'GDBNonDimensionDouble',nil);
     GDBAngleDegDoubleDescriptorObj.baseinit(sizeof(GDBAngleDegDouble),'GDBAngleDegDouble',nil);
     GDBAngleDoubleDescriptorObj.baseinit(sizeof(GDBAngleDouble),'GDBAngleDouble',nil);
     //gdbgetmem({$IFDEF DEBUGBUILD}'{2A687C81-843D-4451-8663-384A625BFEBA}',{$ENDIF}pointer(GDBStringDescriptorObj),sizeof(GDBStringDescriptor));
     GDBStringDescriptorObj.init;
     GDBAnsiStringDescriptorObj.init;
     //gdbgetmem({$IFDEF DEBUGBUILD}'{2A687C81-843D-4451-8663-384A625BFEBA}',{$ENDIF}pointer(GDBWordDescriptorObj),sizeof(GDBWordDescriptor));
     GDBWordDescriptorObj.init;
     //gdbgetmem({$IFDEF DEBUGBUILD}'{2A687C81-843D-4451-8663-384A625BFEBA}',{$ENDIF}pointer(GDBIntegerDescriptorObj),sizeof(GDBIntegerDescriptor));
     GDBIntegerDescriptorObj.init;
     //gdbgetmem({$IFDEF DEBUGBUILD}'{2A687C81-843D-4451-8663-384A625BFEBA}',{$ENDIF}pointer(GDBByteDescriptorObj),sizeof(GDBByteDescriptor));
     GDBByteDescriptorObj.init;
     //gdbgetmem({$IFDEF DEBUGBUILD}'{2A687C81-843D-4451-8663-384A625BFEBA}',{$ENDIF}pointer(GDBSmallintDescriptorObj),sizeof(GDBSmallintDescriptor));
     GDBSmallintDescriptorObj.init;
     //gdbgetmem({$IFDEF DEBUGBUILD}'{2A687C81-843D-4451-8663-384A625BFEBA}',{$ENDIF}pointer(GDBLongwordDescriptorObj),sizeof(GDBLongwordDescriptor));
     GDBLongwordDescriptorObj.init;
     GDBQWordDescriptorObj.init;
     //gdbgetmem({$IFDEF DEBUGBUILD}'{2A687C81-843D-4451-8663-384A625BFEBA}',{$ENDIF}pointer(GDBFloatDescriptorObj),sizeof(GDBFloatDescriptor));
     GDBFloatDescriptorObj.init;
     //gdbgetmem({$IFDEF DEBUGBUILD}'{2A687C81-843D-4451-8663-384A625BFEBA}',{$ENDIF}pointer(GDBShortintDescriptorObj),sizeof(GDBShortintDescriptor));
     GDBShortintDescriptorObj.init;
     //gdbgetmem({$IFDEF DEBUGBUILD}'{2A687C81-843D-4451-8663-384A625BFEBA}',{$ENDIF}pointer(GDBBooleanDescriptorOdj),sizeof(GDBBooleanDescriptor));
     GDBBooleanDescriptorOdj.init;
     //gdbgetmem({$IFDEF DEBUGBUILD}'{2A687C81-843D-4451-8663-384A625BFEBA}',{$ENDIF}pointer(GDBPointerDescriptorOdj),sizeof(GDBPointerDescriptor));
     GDBPointerDescriptorOdj.init;

     GDBEnumDataDescriptorObj.init;
     GDBPtrUIntDescriptorObj.init;
end.

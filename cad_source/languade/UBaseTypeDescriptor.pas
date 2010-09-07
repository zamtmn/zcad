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
interface
uses  strproc,log,TypeDescriptors,UGDBOpenArrayOfTObjLinkRecord,sysutils,UGDBOpenArrayOfByte,gdbasetypes,
      varmandef,gdbase,UGDBOpenArrayOfData,UGDBStringArray,memman,UGDBOpenArrayOfPointer,math,

      StdCtrls,shared;
type
PBaseTypeDescriptor=^BaseTypeDescriptor;
BaseTypeDescriptor=object(TUserTypeDescriptor)
                         function CreateProperties(PPDA:PTPropertyDeskriptorArray;Name:GDBString;PCollapsed:GDBPointer;ownerattrib:GDBWord;var bmode:GDBInteger;var addr:GDBPointer;ValKey,ValType:GDBString):PTPropertyDeskriptorArray;virtual;
                         function Serialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:PGDBOpenArrayOfByte;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;
                         function DeSerialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:GDBOpenArrayOfByte;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;
                         function CreateEditor(TheOwner:TPropEditorOwner;x,y,w,h:GDBInteger;pinstance:pointer;psa:PGDBGDBStringArray):TPropEditor;virtual;
                         procedure EditorChange(Sender:TObject);
                         procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                   end;
GDBBooleanDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          function CreateEditor(TheOwner:TPropEditorOwner;x,y,w,h:GDBInteger;pinstance:pointer;psa:PGDBGDBStringArray):TPropEditor;virtual;
                          procedure EditorChange(Sender:TObject;NewValue:GDBInteger);
                    end;
GDBShortintDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                    end;
GDBByteDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                    end;
GDBSmallintDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                    end;
GDBWordDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                    end;
GDBIntegerDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                    end;
GDBLongwordDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                    end;
GDBDoubleDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                    end;
GDBStringDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          function Serialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:PGDBOpenArrayOfByte;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;
                          function DeSerialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:GDBOpenArrayOfByte;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                          procedure CopyInstanceTo(source,dest:pointer);virtual;
                          procedure MagicFreeInstance(PInstance:GDBPointer);virtual;
                          procedure MagicAfterCopyInstance(PInstance:GDBPointer);virtual;
                          procedure SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:GDBPointer;prefix:GDBString);virtual;
                    end;
GDBFloatDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                          procedure SetValueFromString(PInstance:GDBPointer;Value:GDBstring);virtual;
                    end;
GDBPointerDescriptor=object(BaseTypeDescriptor)
                          constructor init;
                          function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                    end;
TEnumDataDescriptor=object(BaseTypeDescriptor)
                     constructor init;
                     procedure EditorChange(Sender:TObject;NewValue:GDBInteger);
                     function CreateEditor(TheOwner:TPropEditorOwner;x,y,w,h:GDBInteger;pinstance:pointer;psa:PGDBGDBStringArray):TPropEditor;virtual;
                     function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                     procedure SetValueFromString(PInstance:GDBPointer;_Value:GDBstring);virtual;
                     function CreateProperties(PPDA:PTPropertyDeskriptorArray;Name:GDBString;PCollapsed:GDBPointer;ownerattrib:GDBWord;var bmode:GDBInteger;var addr:GDBPointer;ValKey,ValType:GDBString):PTPropertyDeskriptorArray;virtual;
                     destructor Done;virtual;
               end;
var
GDBDoubleDescriptorObj:GDBDoubleDescriptor;
GDBStringDescriptorObj:GDBStringDescriptor;
GDBWordDescriptorObj:GDBWordDescriptor;
GDBIntegerDescriptorObj:GDBIntegerDescriptor;
GDBByteDescriptorObj:GDBByteDescriptor;
GDBSmallintDescriptorObj:GDBSmallintDescriptor;
GDBLongwordDescriptorObj:GDBLongwordDescriptor;
GDBFloatDescriptorObj:GDBFloatDescriptor;
GDBShortintDescriptorObj:GDBShortintDescriptor;
GDBBooleanDescriptorOdj:GDBBooleanDescriptor;
GDBPointerDescriptorOdj:GDBPointerDescriptor;
GDBEnumDataDescriptorObj:TEnumDataDescriptor;
implementation
//uses varman{,ZComboEdBoxsWithProc};
function TEnumDataDescriptor.CreateProperties;
var ppd:PPropertyDeskriptor;
begin
     {$IFDEF TOTALYLOG}programlog.LogOutStr('TEnumDataDescriptor.CreateProperties('+name+',ppda='+inttohex(longint(ppda),10)+')',lp_OldPos);{$ENDIF}
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
     ppd^.Attr:=ownerattrib;
     ppd^.Collapsed:=PCollapsed;
     ppd^.valueAddres:=addr;
     ppd^.value:=GetValueAsString(addr);
     if ppd^.value='rp_21' then
                               ppd^.value:=ppd^.value;
     {$IFDEF TOTALYLOG}programlog.LogOutStr(GetValueAsString(addr),lp_OldPos);{$ENDIF}

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
     {$IFDEF TOTALYLOG}programlog.LogOutStr('BaseTypeDescriptor.CreateProperties('+name+',ppda='+inttohex(longint(ppda),10)+')',lp_OldPos);{$ENDIF}
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
     ppd^.ValKey:=valkey;
     ppd^.ValType:=valtype;
     ppd^.PTypeManager:=@self;
     ppd^.Attr:=ownerattrib;
     ppd^.Collapsed:=PCollapsed;
     ppd^.valueAddres:=addr;
     if (ppd^.Attr and FA_DIFFERENT)=0 then
                                           ppd^.value:=GetValueAsString(addr)
                                       else
                                           ppd^.value:='*Разный*';
     if ppd^.value='rp_21' then
                               ppd^.value:=ppd^.value;
     {$IFDEF TOTALYLOG}programlog.LogOutStr(GetValueAsString(addr),lp_OldPos);{$ENDIF}

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
function BaseTypeDescriptor.CreateEditor;
var //num:cardinal;
   ps{,pspred}:pgdbstring;
//   s:gdbstring;
   ir:itrec;
   propeditor:TPropEditor;
   edit:TEdit;
   cbedit:TComboBox;
begin
     result:=nil;
     if psa^.count=0 then
                         begin
                               propeditor:=TPropEditor.Create(theowner,PInstance,@self);

                               edit:=TEdit.Create(propeditor);
                               edit.SetBounds(x,y,w,h);
                               edit.Text:=GetValueAsString(pinstance);
                               //edit.OnEditingDone:=propeditor.EditingDone;
                               edit.OnKeyPress:=propeditor.keyPress;
                               edit.Parent:=theowner;

                               result:=propeditor;
                               (*gdbgetmem({$IFDEF DEBUGBUILD}'{926E1599-2B34-43FF-B9D5-885F4E37F2B3}',{$ENDIF}result,sizeof(ZEditWithProcedure));
                               PZEditWithProcedure(result).initxywh('',owner,x,y,w,h,true);
                               PZEditWithProcedure(result).LincedData:=pinstance;
                               PZEditWithProcedure(result)^.onenter:=EditorChange;
                               selectobject(PZComboBoxWithProc(result)^.DC, GetStockObject(ANSI_VAR_FONT));
                               PZEditWithProcedure(result).settext(GetValueAsString(pinstance));
                               PZEditWithProcedure(result).changed:=false;*)
                         end
                     else
                         begin
                              propeditor:=TPropEditor.Create(theowner,PInstance,@self);
                              cbedit:=TComboBox.Create(propeditor);
                              cbedit.SetBounds(x,y,w,h);
                              cbedit.Text:=GetValueAsString(pinstance);
                              //cbedit.OnEditingDone:=propeditor.EditingDone;
                              cbedit.OnKeyPress:=propeditor.keyPress;
                              cbedit.OnChange:=propeditor.EditingProcess;

                              cbedit.Parent:=theowner;
                              result:=propeditor;
                              (*
                               gdbgetmem({$IFDEF DEBUGBUILD}'{926E1599-2B34-43FF-B9D5-885F4E37F2B3}',{$ENDIF}result,sizeof(ZEditWithProcedure));
                               PZComboEdBoxWithProc(result).initxywh('',owner,x,y,w,h+500,true);

                               //PZComboEdBoxWithProc(result).setstyle(0,CBS_DROPDOWNLIST);
                              //PZComboEdBoxWithProc(result).setstyle(CBS_SIMPLE,0);
                              *)
                                    ps:=psa^.beginiterate(ir);
                                     if (ps<>nil) then
                                     repeat
                                          {if uppercase(ps^)=uppercase(s) then
                                                             begin
                                                                  exit;
                                                             end;}
                                          cbedit.Items.Add(ps^);
                                          //PZComboEdBoxWithProc(result).AddLine(pansichar(ps^));
                                          ps:=psa^.iterate(ir);
                                     until ps=nil;
                               cbedit.AutoSelect:=true;
                               cbedit.DroppedDown:=true;
                               (*
                               //PZComboEdBoxWithProc(result).setitem(0);
                               PZComboEdBoxWithProc(result).LincedData:=pinstance;
                               PZComboEdBoxWithProc(result)^.onenter:=EditorChange;
                               //selectobject(PZComboBoxWithProc(result)^.DC, GetStockObject(ANSI_VAR_FONT));
                               PZComboEdBoxWithProc(result).settext(GetValueAsString(pinstance));
                               PZComboEdBoxWithProc(result).changed:=false;
                               *)
                         end;
end;
procedure BaseTypeDescriptor.EditorChange(Sender:Tobject);
begin
     //-----------------------------------------------------------------SetValueFromString(sender.LincedData,sender.text);
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
    ShowError('GDBBooleanDescriptor.SetValueFromString('+value+') {not false\true}');
end;
function GDBBooleanDescriptor.GetValueAsString;
begin
     if PGDBboolean(pinstance)^ then
     result := 'True'
     else
     result := 'False';
end;
function GDBBooleanDescriptor.CreateEditor;
var num:cardinal;
    cbedit:TComboBox;
    propeditor:TPropEditor;
    //p:EnumDescriptor;
begin
     result:=nil;


     propeditor:=TPropEditor.Create(theowner,PInstance,@self);
     cbedit:=TComboBox.Create(propeditor);
     cbedit.SetBounds(x,y,w,h);
     cbedit.Text:=GetValueAsString(pinstance);
     //cbedit.OnEditingDone:=propeditor.EditingDone;
     //cbedit.OnKeyPress:=propeditor.keyPress;
     cbedit.OnChange:=propeditor.EditingProcess;
     cbedit.ReadOnly:=true;

     cbedit.Items.Add('True');
     cbedit.Items.Add('False');

     if pgdbboolean(pinstance)^ then
                                    cbedit.ItemIndex:=0
                                else
                                    cbedit.ItemIndex:=1;
     cbedit.Parent:=theowner;
     cbedit.DroppedDown:=true;
     result:=propeditor;









     (*
     gdbgetmem({$IFDEF DEBUGBUILD}'{926E1599-2B34-43FF-B9D5-885F4E37F2B3}',{$ENDIF}result,sizeof(ZComboBoxWithProc));
     PZComboBoxWithProc(result).initxywh('',owner,x,y,w,h+100,true);
     PZComboBoxWithProc(result).LincedData:=pinstance;
     PZComboBoxWithProc(result)^.onChangeObj:=EditorChange;
     selectobject(PZComboBoxWithProc(result)^.DC, GetStockObject(ANSI_VAR_FONT));
     PZComboBoxWithProc(result).AddLine('False');
     PZComboBoxWithProc(result).AddLine('True');
     if pgdbboolean(pinstance)^ then
                                    PZComboBoxWithProc(result)^.setitem(1)
                                else
                                    PZComboBoxWithProc(result)^.setitem(0);
     *)
end;
procedure GDBBooleanDescriptor.EditorChange(Sender:Tobject;NewValue:GDBInteger);
begin
   {  case NewValue of
                      0:begin
                             PGDBBoolean(Sender^.LincedData)^:=false;
                             //currval:=pGDBByte(pinstance)^;
                        end;
                      1:begin
                             PGDBBoolean(Sender^.LincedData)^:=True;
                             //currval:=pGDBByte(pinstance)^;
                        end;

     end;  }
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
procedure GDBDoubleDescriptor.SetValueFromString;
var
     uGDBDouble:GDBDouble;
     error:integer;
begin
     val(value,ugdbdouble,error);
     if error=0 then
                    pGDBDouble(pinstance)^:=ugdbdouble;
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
     pointer(s):=nil;
end;
constructor GDBStringDescriptor.init;
begin
     inherited init(sizeof(GDBString),'GDBString',nil);
end;
function GDBStringDescriptor.GetValueAsString;
var
     uGDBString:GDBString;
begin
    uGDBString := pGDBString(pinstance)^;
    result := uGDBString;
end;
constructor GDBPointerDescriptor.init;
begin
     inherited init(sizeof(GDBPointer),'GDBPointer',nil);
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
procedure GDBStringDescriptor.SetValueFromString;
//var
//     vGDBLongword:gdbWord;
//     error:integer;
begin
     //val(value,vGDBLongword,error);
     //if error=0 then
                    pGDBString(pinstance)^:=value;//vGDBLongword;
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
function GDBStringDescriptor.DeSerialize;
var l:gdbword;
begin
     pstring(PInstance)^:='';
     membuf.ReadData(@L,sizeof(gdbword));
     setlength(pstring(PInstance)^,l);
     membuf.ReadData(@pstring(PInstance)^[1],l)
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
procedure TEnumDataDescriptor.EditorChange(Sender:TObject;NewValue:GDBInteger);
begin
     //PGDBInteger(Sender^.LincedData)^:=NewValue;
end;
function TEnumDataDescriptor.CreateEditor;
var
    cbedit:TComboBox;
    propeditor:TPropEditor;
    ir:itrec;
    number:longword;
    p:pgdbstring;
begin
     propeditor:=TPropEditor.Create(theowner,PInstance,@self);
     cbedit:=TComboBox.Create(propeditor);
     cbedit.SetBounds(x,y,w,h);
     cbedit.Text:=GetValueAsString(pinstance);
     //cbedit.OnEditingDone:=propeditor.EditingDone;
     //cbedit.OnKeyPress:=propeditor.keyPress;
     cbedit.OnChange:=propeditor.EditingProcess;
     cbedit.ReadOnly:=true;

                             p:=PTEnumData(Pinstance)^.Enums.beginiterate(ir);
                             if p<>nil then
                             repeat
                                   cbedit.Items.Add(p^);
                                   p:=PTEnumData(Pinstance)^.Enums.iterate(ir);
                             until p=nil;

     cbedit.ItemIndex:=PTEnumData(Pinstance)^.Selected;

     cbedit.Parent:=theowner;
     cbedit.DroppedDown:=true;
     result:=propeditor;
     (*
    gdbgetmem({$IFDEF DEBUGBUILD}'{926E1599-2B34-43FF-B9D5-885F4E37F2B3}',{$ENDIF}result,sizeof(ZComboBoxWithProc));
    PZComboBoxWithProc(result).initxywh('',owner,x,y,w,h+100,true);
    PZComboBoxWithProc(result).LincedData:=pinstance;
     //PZComboBoxWithProc(result)^.assigntoprocofobject(onc(self.EditorChange));
     PZComboBoxWithProc(result)^.onChangeObj:=EditorChange;
     //PZComboBoxWithProc(result)^.onChangeObj(nil,1);

     //tmethod(self.EditorChange);
     selectobject(PZComboBoxWithProc(result)^.DC, GetStockObject(ANSI_VAR_FONT));
     PTEnumData(Pinstance)^.Enums.copyto(@PZComboBoxWithProc(result)^.GDBStrings);
     PZComboBoxWithProc(result).sync;
     //num:=0;
     PZComboBoxWithProc(result)^.setitem(PTEnumData(Pinstance)^.Selected);
     *)
end;
begin
       {$IFDEF DEBUGINITSECTION}LogOut('GDBBaseTypeDescriptor.initialization');{$ENDIF}
     //gdbgetmem({$IFDEF DEBUGBUILD}'{2A687C81-843D-4451-8663-384A625BFEBA}',{$ENDIF}pointer(GDBDoubleDescriptorObj),sizeof(GDBDoubleDescriptor));
     GDBDoubleDescriptorObj.init;
     //gdbgetmem({$IFDEF DEBUGBUILD}'{2A687C81-843D-4451-8663-384A625BFEBA}',{$ENDIF}pointer(GDBStringDescriptorObj),sizeof(GDBStringDescriptor));
     GDBStringDescriptorObj.init;
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
     //gdbgetmem({$IFDEF DEBUGBUILD}'{2A687C81-843D-4451-8663-384A625BFEBA}',{$ENDIF}pointer(GDBFloatDescriptorObj),sizeof(GDBFloatDescriptor));
     GDBFloatDescriptorObj.init;
     //gdbgetmem({$IFDEF DEBUGBUILD}'{2A687C81-843D-4451-8663-384A625BFEBA}',{$ENDIF}pointer(GDBShortintDescriptorObj),sizeof(GDBShortintDescriptor));
     GDBShortintDescriptorObj.init;
     //gdbgetmem({$IFDEF DEBUGBUILD}'{2A687C81-843D-4451-8663-384A625BFEBA}',{$ENDIF}pointer(GDBBooleanDescriptorOdj),sizeof(GDBBooleanDescriptor));
     GDBBooleanDescriptorOdj.init;
     //gdbgetmem({$IFDEF DEBUGBUILD}'{2A687C81-843D-4451-8663-384A625BFEBA}',{$ENDIF}pointer(GDBPointerDescriptorOdj),sizeof(GDBPointerDescriptor));
     GDBPointerDescriptorOdj.init;

     GDBEnumDataDescriptorObj.init;
end.

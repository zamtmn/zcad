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

unit langsystem;
{$INCLUDE def.inc}
{$MODE DELPHI}
interface
uses uzbstrproc,uzbtypesbase,varmandef,UBaseTypeDescriptor,
     base64;
type
    TTypesArray=array of pointer;
var
   foneGDBString,foneGDBInteger,foneGDBDouble:TTypesArray;
const

  basicoperatorcount = 5;
  basicfunctioncount = 2;
  basicoperatorparamcount = 28;
  basicfunctionparamcount = 1;
  {foneGDBBoolean = #7;
  foneGDBByte = #8;
  foneuGDBByte = #9;
  foneGDBWord = #10;
  foneuGDBWord = #11;
  foneuGDBInteger = #13;
  foneGDBString = #15;}
type
  operandstack = record
    count: GDBByte;
    stack: array[1..10] of vardesk;
  end;
  basicoperator = function(var rez, hrez: vardesk): vardesk;
  basicfunction = function(var stack: operandstack): vardesk;
  ptfunctionparamnype = ^tfunctionparamnype;
  tfunctionparamnype = record
    count: GDBWord;
    typearray: array[0..0] of GDBByte;
  end;
  operatornam = record
    name: GDBString;
    prior: GDBByte;
  end;
  operatortype = record
    name: GDBString;
    param: pointer;
    hparam: pointer;
    addr: basicoperator;
  end;
  functiontype = record
    name: GDBString;
    param: {GDBString}TTypesArray;
    addr: basicfunction;
  end;

  functionnam = record
    name: GDBString;
                       //param:ptfunctionparamnype;
  end;

procedure initvardesk(out vd: vardesk);
procedure initoperandstack(out opstac: operandstack);

function Tnothing_plus_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBInteger_plus_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBDouble_plus_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBInteger_plus_TGDBDouble(var rez, hrez: vardesk): vardesk;
function TGDBDouble_plus_TGDBDouble(var rez, hrez: vardesk): vardesk;
function Tnothing_minus_TGDBInteger(var rez, hrez: vardesk): vardesk;
function Tnothing_minus_TGDBDouble(var rez, hrez: vardesk): vardesk;
function TGDBInteger_mul_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBInteger_div_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBInteger_div_TGDBDouble(var rez, hrez: vardesk): vardesk;
function TGDBDouble_div_TGDBDouble(var rez, hrez: vardesk): vardesk;
function TGDBDouble_div_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBDouble_let_TGDBDouble(var rez, hrez: vardesk): vardesk;
function TGDBInteger_let_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBString_let_TGDBString(var rez, hrez: vardesk): vardesk;
function TGDBAnsiString_let_TGDBString(var rez, hrez: vardesk): vardesk;
function TGDBAnsiString_let_TGDBAnsiString(var rez, hrez: vardesk): vardesk;
function TGDBByte_let_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBBoolean_let_TGDBBoolean(var rez, hrez: vardesk): vardesk;

function TGDBInteger_minus_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBInteger_minus_TGDBDouble(var rez, hrez: vardesk): vardesk;
function TGDBDouble_minus_TGDBDouble(var rez, hrez: vardesk): vardesk;
function TGDBDouble_minus_TGDBInteger(var rez, hrez: vardesk): vardesk;

function TGDBDouble_mul_TGDBInteger(var rez, hrez: vardesk): vardesk;
function TGDBInteger_mul_TGDBDouble(var rez, hrez: vardesk): vardesk;
function TGDBDouble_mul_TGDBDouble(var rez, hrez: vardesk): vardesk;

function TGDBDouble_let_TGDBInteger(var rez, hrez: vardesk): vardesk;

function TEnum_let_TIdentificator(var rez, hrez: vardesk): vardesk;


function Cos_TGDBInteger(var stack: operandstack): vardesk;
//function DecodeStringBase64_TAnsiString(var stack: operandstack): vardesk;
function DecodeStringBase64_TGBDString(var stack: operandstack): vardesk;

function itbasicoperator(expr: GDBString): GDBInteger;
function itbasicfunction(expr: GDBString): GDBInteger;
function findbasicoperator(expr: GDBString; rez, hrez: {PUserTypeDescriptor}vardesk): GDBInteger;
function findbasicfunction(name: GDBString; opstack: operandstack): GDBInteger;
const
  basicoperatorname: array[1..basicoperatorcount] of operatornam =
  (
    (name: '+'; prior: 0)
    , (name: '-'; prior: 0)
    , (name: '*'; prior: 1)
    , (name: '/'; prior: 1)
    , (name: ':='; prior: 0)
    );

  basicfunctionname: array[1..basicfunctioncount] of functionnam =
  (
    (name: 'cos')
   ,(name: 'DecodeStringBase64')
    );

  basicoperatorparam: array[1..basicoperatorparamcount] of operatortype =
  (
    (name: '+'; param: nil; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}Tnothing_plus_TGDBInteger)
    , (name: '+'; param: @FundamentalLongIntDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBInteger_plus_TGDBInteger)
    , (name: '-'; param: nil; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}Tnothing_minus_TGDBInteger)
    , (name: '*'; param: @FundamentalLongIntDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBInteger_mul_TGDBInteger)
    , (name: ':='; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_let_TGDBDouble)
    , (name: ':='; param: @FundamentalStringDescriptorObj; hparam: @FundamentalStringDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBString_let_TGDBString)
    , (name: ':='; param: @FundamentalAnsiStringDescriptorObj; hparam: @FundamentalStringDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBAnsiString_let_TGDBString)
    , (name: ':='; param: @FundamentalLongIntDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBInteger_let_TGDBInteger)
    , (name: ':='; param: @FundamentalByteDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBByte_let_TGDBInteger)
    , (name: '-'; param: nil; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}Tnothing_minus_TGDBDouble)
    , (name: ':='; param: @FundamentalBooleanDescriptorOdj; hparam: @FundamentalBooleanDescriptorOdj; addr: {$IFDEF FPC}@{$ENDIF}TGDBBoolean_let_TGDBBoolean)
    , (name: ':='; param: @GDBEnumDataDescriptorObj; hparam: @GDBEnumDataDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TEnum_let_TIdentificator)//эта шняга захардкожена в findbasicoperator по номеру
    , (name: ':='; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_let_TGDBInteger)
    , (name: '/'; param: @FundamentalLongIntDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBInteger_div_TGDBInteger)
    , (name: '/'; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_div_TGDBInteger)
    , (name: '/'; param: @FundamentalLongIntDescriptorObj; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBInteger_div_TGDBDouble)
    , (name: '/'; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_div_TGDBDouble)
    , (name: '+'; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_plus_TGDBInteger)
    , (name: '+'; param: @FundamentalLongIntDescriptorObj; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBInteger_plus_TGDBDouble)
    , (name: '+'; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_plus_TGDBDouble)
    , (name: '-'; param: @FundamentalLongIntDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBInteger_minus_TGDBInteger)
    , (name: '-'; param: @FundamentalLongIntDescriptorObj; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBInteger_minus_TGDBDouble)
    , (name: '-'; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_minus_TGDBDouble)
    , (name: '-'; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_minus_TGDBInteger)
    , (name: '*'; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_mul_TGDBInteger)
    , (name: '*'; param: @FundamentalLongIntDescriptorObj; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBInteger_mul_TGDBDouble)
    , (name: '*'; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBDouble_mul_TGDBDouble)
    , (name: ':='; param: @FundamentalAnsiStringDescriptorObj; hparam: @FundamentalAnsiStringDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TGDBAnsiString_let_TGDBAnsiString)
    );
type
TFunctionTypeArray=array of functiontype;

var
  basicfunctionparam: TFunctionTypeArray;

implementation
uses UEnumDescriptor;
function TEnum_let_TIdentificator(var rez, hrez: vardesk): vardesk;
//var
//  r: vardesk;
begin
  PEnumDescriptor(rez.data.PTD)^.SetValueFromString(rez.data.Addr.Instance,hrez.name);
  result.name:='';
  result.username:='';
  result.SetInstance(nil);
  //result.Instance:=nil;
  result.data.PTD:=nil;
end;
function funcstackequalGDBString(str: TTypesArray; opstack: operandstack): GDBBoolean;
var
  i: GDBInteger;
begin
  result := true;
  for i := 1 to opstack.count do
    if str[i-1]<>opstack.stack[i].data.PTD then
                                             begin
                                                  result := false;
                                                  exit;
                                             end;
end;

function findbasicfunction(name: GDBString; opstack: operandstack): GDBInteger;
var
  i{, j}: GDBInteger;
begin
  result := 0;
  for i :=low(basicfunctionparam) to high(basicfunctionparam) do
  begin
    if name = basicfunctionparam[i].name then
    begin
      if length(basicfunctionparam[i].param) = opstack.count then
      begin
        if funcstackequalGDBString(basicfunctionparam[i].param, opstack) then
        begin
          result := i;
          system.exit;
        end;
      end
    end;
  end;
end;

procedure initvardesk(out vd: vardesk);
begin
  vd.SetInstance(nil);
  //vd.Instance := nil;
  //vd.vartypecustom := 0;
  vd.data.ptd:=nil;
  vd.name := '';
end;

procedure initoperandstack(out opstac: operandstack);
var
  i: GDBInteger;
begin
  for i := 1 to 10 do
    initvardesk(opstac.stack[i]);
  opstac.count := 0;
end;

function Cos_TGDBInteger(var stack: operandstack): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pdouble(r.data.Addr.Instance)^ := cos(pGDBInteger(stack.stack[1].data.Addr.Instance)^);
  result := r;
end;
(*function DecodeStringBase64_TAnsiString(var stack: operandstack): vardesk;
var
  r: vardesk;
begin
  pGDBDouble(r.Instance) := nil;
  r.data.ptd:=@FundamentalAnsiStringDescriptorObj;
  r.name := '';
  Getmem(r.Instance,FundamentalAnsiStringDescriptorObj.SizeInGDBBytes);
  pAnsiString(r.Instance)^ := DecodeStringBase64(PGDBAnsiString(stack.stack[1].Instance)^);
  result := r;
end;*)
function DecodeStringBase64_TGBDString(var stack: operandstack): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalStringDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalStringDescriptorObj.AllocAndInitInstance);
  ppointer(r.data.Addr.Instance)^:=nil;
  PGDBString(r.data.Addr.Instance)^ := DecodeStringBase64(PGDBString(stack.stack[1].data.Addr.Instance)^);
  result := r;
end;
function Cos_TGDBDouble(var stack: operandstack): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pdouble(r.data.Addr.Instance)^ := cos(pGDBDouble(stack.stack[1].data.Addr.Instance)^);
  result := r;
end;


function TGDBBoolean_let_TGDBBoolean(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalBooleanDescriptorOdj;
  r.name := '';
  r.SetInstance(FundamentalBooleanDescriptorOdj.AllocAndInitInstance);
  PGDBBoolean(r.data.Addr.Instance)^ := PGDBBoolean(hrez.data.Addr.Instance)^;
  PGDBBoolean(rez.data.Addr.Instance)^ := PGDBBoolean(hrez.data.Addr.Instance)^;
  result := r;
end;

function TGDBDouble_let_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pdouble(r.data.Addr.Instance)^ := pdouble(hrez.data.Addr.Instance)^;
  pdouble(rez.data.Addr.Instance)^ := pdouble(hrez.data.Addr.Instance)^;
  result := r;
end;
function TGDBDouble_let_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pdouble(r.data.Addr.Instance)^ := pgdbinteger(hrez.data.Addr.Instance)^;
  pdouble(rez.data.Addr.Instance)^ := pgdbinteger(hrez.data.Addr.Instance)^;
  result := r;
end;


function TGDBInteger_let_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalLongIntDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalLongIntDescriptorObj.AllocAndInitInstance);
  pGDBInteger(r.data.Addr.Instance)^ := pGDBInteger(hrez.data.Addr.Instance)^;
  pGDBInteger(rez.data.Addr.Instance)^ := pGDBInteger(hrez.data.Addr.Instance)^;
  result := r;
end;
function TGDBByte_let_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalByteDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalByteDescriptorObj.AllocAndInitInstance);
  pGDBByte(r.data.Addr.Instance)^ := pGDBInteger(hrez.data.Addr.Instance)^;
  pGDBByte(rez.data.Addr.Instance)^ := pGDBInteger(hrez.data.Addr.Instance)^;
  result := r;
end;

function TGDBString_let_TGDBString(var rez, hrez: vardesk): vardesk;
begin
  result.data.ptd:=@FundamentalStringDescriptorObj;
  result.name := '';
  result.SetInstance(FundamentalStringDescriptorObj.AllocAndInitInstance);
  if rez.data.Addr.Instance=nil then begin
    rez.SetInstance(FundamentalStringDescriptorObj.AllocAndInitInstance);
  end else
     GDBString(rez.data.Addr.Instance^):='';
  GDBString(result.data.Addr.Instance^) := GDBString(hrez.data.Addr.Instance^);
  GDBString(rez.data.Addr.Instance^) := GDBString(hrez.data.Addr.Instance^);
end;
function TGDBAnsiString_let_TGDBString(var rez, hrez: vardesk): vardesk;
begin
  result.data.ptd:=@FundamentalAnsiStringDescriptorObj;
  result.name := '';
  result.SetInstance(FundamentalStringDescriptorObj.AllocAndInitInstance);
  if rez.data.Addr.Instance=nil then begin
    rez.SetInstance(FundamentalStringDescriptorObj.AllocAndInitInstance);
  end else
    GDBAnsiString(rez.data.Addr.Instance^):='';
  GDBAnsiString(result.data.Addr.Instance^) := Tria_Utf8ToAnsi(GDBString(hrez.data.Addr.Instance^));
  GDBAnsiString(rez.data.Addr.Instance^) := Tria_Utf8ToAnsi(GDBString(hrez.data.Addr.Instance^));
end;
function TGDBAnsiString_let_TGDBAnsiString(var rez, hrez: vardesk): vardesk;
begin
  result.data.ptd:=@FundamentalAnsiStringDescriptorObj;
  result.name := '';
  result.SetInstance(FundamentalAnsiStringDescriptorObj.AllocAndInitInstance);
  if rez.data.Addr.Instance=nil then
                               begin
                                 rez.SetInstance(FundamentalAnsiStringDescriptorObj.AllocAndInitInstance);
                               end
                          else
                              GDBAnsiString(rez.data.Addr.Instance^):='';
  GDBAnsiString(result.data.Addr.Instance^) := {Tria_Utf8ToAnsi}(GDBAnsiString(hrez.data.Addr.Instance^));
  GDBAnsiString(rez.data.Addr.Instance^) := {Tria_Utf8ToAnsi}(GDBAnsiString(hrez.data.Addr.Instance^));
end;
function TGDBInteger_minus_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalLongIntDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalLongIntDescriptorObj.AllocAndInitInstance);
  pGDBInteger(r.data.Addr.Instance)^ := pGDBInteger(rez.data.Addr.Instance)^-pGDBInteger(hrez.data.Addr.Instance)^;
  result := r;
end;
function TGDBInteger_minus_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  PGDBDouble(r.data.Addr.Instance)^ := PGDBInteger(rez.data.Addr.Instance)^-PGDBDouble(hrez.data.Addr.Instance)^;
  result := r;
end;
function TGDBDouble_minus_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  PGDBDouble(r.data.Addr.Instance)^ := PGDBDouble(rez.data.Addr.Instance)^-PGDBDouble(hrez.data.Addr.Instance)^;
  result := r;
end;
function TGDBDouble_minus_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  PGDBDouble(r.data.Addr.Instance)^ := PGDBDouble(rez.data.Addr.Instance)^-PGDBInteger(hrez.data.Addr.Instance)^;
  result := r;
end;
function TGDBDouble_mul_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pGDBDouble(r.data.Addr.Instance)^ := pGDBDouble(rez.data.Addr.Instance)^*pGDBInteger(hrez.data.Addr.Instance)^;
  result := r;
end;
function TGDBInteger_mul_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pGDBDouble(r.data.Addr.Instance)^ := pGDBInteger(rez.data.Addr.Instance)^ * pGDBDouble(hrez.data.Addr.Instance)^;
  result := r;
end;
function TGDBDouble_mul_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pGDBDouble(r.data.Addr.Instance)^ := pGDBDouble(rez.data.Addr.Instance)^ * pGDBDouble(hrez.data.Addr.Instance)^;
  result := r;
end;
function TGDBInteger_plus_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalLongIntDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalLongIntDescriptorObj.AllocAndInitInstance);
  pGDBInteger(r.data.Addr.Instance)^ := pGDBInteger(rez.data.Addr.Instance)^+pGDBInteger(hrez.data.Addr.Instance)^;
  result := r;
end;
function TGDBDouble_plus_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  PGDBDouble(r.data.Addr.Instance)^ := PGDBDouble(rez.data.Addr.Instance)^+PGDBInteger(hrez.data.Addr.Instance)^;
  result := r;
end;
function TGDBInteger_plus_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  PGDBDouble(r.data.Addr.Instance)^ := PGDBInteger(rez.data.Addr.Instance)^+PGDBDouble(hrez.data.Addr.Instance)^;
  result := r;
end;
function TGDBDouble_plus_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  PGDBDouble(r.data.Addr.Instance)^ := PGDBDouble(rez.data.Addr.Instance)^+PGDBDouble(hrez.data.Addr.Instance)^;
  result := r;
end;
function Tnothing_plus_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalLongIntDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalLongIntDescriptorObj.AllocAndInitInstance);
  pGDBInteger(r.data.Addr.Instance)^ := pGDBInteger(hrez.data.Addr.Instance)^;
  result := r;
end;

function Tnothing_minus_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  PGDBDouble(r.data.Addr.Instance)^ := -(pdouble(hrez.data.Addr.Instance)^);
  result := r;
end;

function Tnothing_minus_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalLongIntDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalLongIntDescriptorObj.AllocAndInitInstance);
  pGDBInteger(r.data.Addr.Instance)^ := -(pGDBInteger(hrez.data.Addr.Instance)^);
  result := r;
end;

function TGDBInteger_mul_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalLongIntDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalLongIntDescriptorObj.AllocAndInitInstance);
  pGDBInteger(r.data.Addr.Instance)^ := pGDBInteger(rez.data.Addr.Instance)^ * pGDBInteger(hrez.data.Addr.Instance)^;
  result := r;
end;
function TGDBInteger_div_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pGDBDouble(r.data.Addr.Instance)^ := pGDBInteger(rez.data.Addr.Instance)^ / pGDBInteger(hrez.data.Addr.Instance)^;
  result := r;
end;
function TGDBInteger_div_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pGDBDouble(r.data.Addr.Instance)^ := pGDBInteger(rez.data.Addr.Instance)^ / pGDBDouble(hrez.data.Addr.Instance)^;
  result := r;
end;
function TGDBDouble_div_TGDBDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pGDBDouble(r.data.Addr.Instance)^ := pGDBDouble(rez.data.Addr.Instance)^ / pGDBDouble(hrez.data.Addr.Instance)^;
  result := r;
end;
function TGDBDouble_div_TGDBInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pGDBDouble(r.data.Addr.Instance)^ := pGDBDouble(rez.data.Addr.Instance)^ / pGDBInteger(hrez.data.Addr.Instance)^;
  result := r;
end;

function itbasicoperator(expr: GDBString): GDBInteger;
var
  i: GDBInteger;
begin
  result := 0;
  for i := 1 to basicoperatorcount do
    if expr = basicoperatorname[i].name then
    begin
      result := i;
      exit;
    end
end;

function itbasicfunction(expr: GDBString): GDBInteger;
var
  i: GDBInteger;
begin
  result := 0;
  for i := 1 to basicfunctioncount do
    if expr = basicfunctionname[i].name then
    begin
      result := i;
      exit;
    end
end;

function findbasicoperator(expr: GDBString; rez, hrez: vardesk): GDBInteger;
var
  i: GDBInteger;
  rezptd,hrezptd:PUserTypeDescriptor;
begin
  result := 0;
  if rez.data.PTD<>nil then
    if ((rez.data.PTD.GetTypeAttributes and ta_enum)>0) and
       (hrez.data.ptd=nil) and
       (hrez.name<>'') then
                           begin
                                result:=12;
                                exit;
                           end;
  begin
  if rez.data.ptd<>nil then
  if rez.data.ptd.TypeName='GDBXCoordinate' then
                                                rez.data.ptd:=rez.data.ptd;
  if hrez.data.ptd<>nil then
  if hrez.data.ptd.TypeName='GDBXCoordinate' then
                                                  rez.data.ptd:=rez.data.ptd;
  if rez.data.ptd<>nil then
                           rezptd:=rez.data.ptd^.GetFactTypedef
                       else
                           rezptd:=nil;
  if hrez.data.ptd<>nil then
                            hrezptd:=hrez.data.ptd^.GetFactTypedef
                        else
                            hrezptd:=nil;
  for i := 1 to basicoperatorparamcount do
    if (rezptd = basicoperatorparam[i].param) and (hrezptd = basicoperatorparam[i].hparam) and (expr = basicoperatorparam[i].name) then
    begin
      result := i;
      exit;
    end
  end
end;
var
  tv,tv1,tv2:functiontype;
begin
     setlength(foneGDBInteger,1);foneGDBInteger[0]:=@FundamentalLongIntDescriptorObj;
     setlength(foneGDBDouble,1);foneGDBDouble[0]:=@FundamentalDoubleDescriptorObj;
     setlength(foneGDBString,1);foneGDBString[0]:=@FundamentalStringDescriptorObj;
     tv.name:='cos';tv.param:=foneGDBInteger;tv.addr:=Cos_TGDBInteger;
     tv1.name:='cos';tv1.param:=foneGDBDouble;tv1.addr:=Cos_TGDBDouble;
     tv2.name:='DecodeStringBase64';tv2.param:=foneGDBString;tv2.addr:=DecodeStringBase64_TGBDString;
     setlength(basicfunctionparam,3);
     basicfunctionparam[0]:=tv;
     basicfunctionparam[1]:=tv1;
     basicfunctionparam[2]:=tv2;
end.

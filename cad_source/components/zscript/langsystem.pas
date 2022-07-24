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

unit langsystem;

{$MODE DELPHI}
interface
uses uzbstrproc,varmandef,UBaseTypeDescriptor,
     base64;
type
    TTypesArray=array of pointer;
var
   foneString,foneInteger,foneDouble:TTypesArray;
const

  basicoperatorcount = 5;
  basicfunctioncount = 2;
  basicoperatorparamcount = 28;
  basicfunctionparamcount = 1;
  {foneBoolean = #7;
  foneByte = #8;
  foneuByte = #9;
  foneGDBWord = #10;
  foneuGDBWord = #11;
  foneuInteger = #13;
  foneString = #15;}
type
  operandstack = record
    count: Byte;
    stack: array[1..10] of vardesk;
  end;
  basicoperator = function(var rez, hrez: vardesk): vardesk;
  basicfunction = function(var stack: operandstack): vardesk;
  ptfunctionparamnype = ^tfunctionparamnype;
  tfunctionparamnype = record
    count: Word;
    typearray: array[0..0] of Byte;
  end;
  operatornam = record
    name: String;
    prior: Byte;
  end;
  operatortype = record
    name: String;
    param: pointer;
    hparam: pointer;
    addr: basicoperator;
  end;
  functiontype = record
    name: String;
    param: {String}TTypesArray;
    addr: basicfunction;
  end;

  functionnam = record
    name: String;
                       //param:ptfunctionparamnype;
  end;

procedure initvardesk(out vd: vardesk);
procedure initoperandstack(out opstac: operandstack);

function Tnothing_plus_TInteger(var rez, hrez: vardesk): vardesk;
function TInteger_plus_TInteger(var rez, hrez: vardesk): vardesk;
function TDouble_plus_TInteger(var rez, hrez: vardesk): vardesk;
function TInteger_plus_TDouble(var rez, hrez: vardesk): vardesk;
function TDouble_plus_TDouble(var rez, hrez: vardesk): vardesk;
function Tnothing_minus_TInteger(var rez, hrez: vardesk): vardesk;
function Tnothing_minus_TDouble(var rez, hrez: vardesk): vardesk;
function TInteger_mul_TInteger(var rez, hrez: vardesk): vardesk;
function TInteger_div_TInteger(var rez, hrez: vardesk): vardesk;
function TInteger_div_TDouble(var rez, hrez: vardesk): vardesk;
function TDouble_div_TDouble(var rez, hrez: vardesk): vardesk;
function TDouble_div_TInteger(var rez, hrez: vardesk): vardesk;
function TDouble_let_TDouble(var rez, hrez: vardesk): vardesk;
function TInteger_let_TInteger(var rez, hrez: vardesk): vardesk;
function TString_let_TString(var rez, hrez: vardesk): vardesk;
function TAnsiString_let_TString(var rez, hrez: vardesk): vardesk;
function TAnsiString_let_TAnsiString(var rez, hrez: vardesk): vardesk;
function TByte_let_TInteger(var rez, hrez: vardesk): vardesk;
function TBoolean_let_TBoolean(var rez, hrez: vardesk): vardesk;

function TInteger_minus_TInteger(var rez, hrez: vardesk): vardesk;
function TInteger_minus_TDouble(var rez, hrez: vardesk): vardesk;
function TDouble_minus_TDouble(var rez, hrez: vardesk): vardesk;
function TDouble_minus_TInteger(var rez, hrez: vardesk): vardesk;

function TDouble_mul_TInteger(var rez, hrez: vardesk): vardesk;
function TInteger_mul_TDouble(var rez, hrez: vardesk): vardesk;
function TDouble_mul_TDouble(var rez, hrez: vardesk): vardesk;

function TDouble_let_TInteger(var rez, hrez: vardesk): vardesk;

function TEnum_let_TIdentificator(var rez, hrez: vardesk): vardesk;


function Cos_TInteger(var stack: operandstack): vardesk;
//function DecodeStringBase64_TAnsiString(var stack: operandstack): vardesk;
function DecodeStringBase64_TGBDString(var stack: operandstack): vardesk;

function itbasicoperator(expr: String): Integer;
function itbasicfunction(expr: String): Integer;
function findbasicoperator(expr: String; rez, hrez: {PUserTypeDescriptor}vardesk): Integer;
function findbasicfunction(name: String; opstack: operandstack): Integer;
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
    (name: '+'; param: nil; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}Tnothing_plus_TInteger)
    , (name: '+'; param: @FundamentalLongIntDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TInteger_plus_TInteger)
    , (name: '-'; param: nil; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}Tnothing_minus_TInteger)
    , (name: '*'; param: @FundamentalLongIntDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TInteger_mul_TInteger)
    , (name: ':='; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TDouble_let_TDouble)
    , (name: ':='; param: @FundamentalStringDescriptorObj; hparam: @FundamentalStringDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TString_let_TString)
    , (name: ':='; param: @FundamentalAnsiStringDescriptorObj; hparam: @FundamentalStringDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TAnsiString_let_TString)
    , (name: ':='; param: @FundamentalLongIntDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TInteger_let_TInteger)
    , (name: ':='; param: @FundamentalByteDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TByte_let_TInteger)
    , (name: '-'; param: nil; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}Tnothing_minus_TDouble)
    , (name: ':='; param: @FundamentalBooleanDescriptorOdj; hparam: @FundamentalBooleanDescriptorOdj; addr: {$IFDEF FPC}@{$ENDIF}TBoolean_let_TBoolean)
    , (name: ':='; param: @GDBEnumDataDescriptorObj; hparam: @GDBEnumDataDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TEnum_let_TIdentificator)//эта шняга захардкожена в findbasicoperator по номеру
    , (name: ':='; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TDouble_let_TInteger)
    , (name: '/'; param: @FundamentalLongIntDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TInteger_div_TInteger)
    , (name: '/'; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TDouble_div_TInteger)
    , (name: '/'; param: @FundamentalLongIntDescriptorObj; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TInteger_div_TDouble)
    , (name: '/'; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TDouble_div_TDouble)
    , (name: '+'; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TDouble_plus_TInteger)
    , (name: '+'; param: @FundamentalLongIntDescriptorObj; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TInteger_plus_TDouble)
    , (name: '+'; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TDouble_plus_TDouble)
    , (name: '-'; param: @FundamentalLongIntDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TInteger_minus_TInteger)
    , (name: '-'; param: @FundamentalLongIntDescriptorObj; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TInteger_minus_TDouble)
    , (name: '-'; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TDouble_minus_TDouble)
    , (name: '-'; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TDouble_minus_TInteger)
    , (name: '*'; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalLongIntDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TDouble_mul_TInteger)
    , (name: '*'; param: @FundamentalLongIntDescriptorObj; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TInteger_mul_TDouble)
    , (name: '*'; param: @FundamentalDoubleDescriptorObj; hparam: @FundamentalDoubleDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TDouble_mul_TDouble)
    , (name: ':='; param: @FundamentalAnsiStringDescriptorObj; hparam: @FundamentalAnsiStringDescriptorObj; addr: {$IFDEF FPC}@{$ENDIF}TAnsiString_let_TAnsiString)
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
function funcstackequalString(str: TTypesArray; opstack: operandstack): Boolean;
var
  i: Integer;
begin
  result := true;
  for i := 1 to opstack.count do
    if str[i-1]<>opstack.stack[i].data.PTD then
                                             begin
                                                  result := false;
                                                  exit;
                                             end;
end;

function findbasicfunction(name: String; opstack: operandstack): Integer;
var
  i{, j}: Integer;
begin
  result := 0;
  for i :=low(basicfunctionparam) to high(basicfunctionparam) do
  begin
    if name = basicfunctionparam[i].name then
    begin
      if length(basicfunctionparam[i].param) = opstack.count then
      begin
        if funcstackequalString(basicfunctionparam[i].param, opstack) then
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
  i: Integer;
begin
  for i := 1 to 10 do
    initvardesk(opstac.stack[i]);
  opstac.count := 0;
end;

function Cos_TInteger(var stack: operandstack): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pdouble(r.data.Addr.Instance)^ := cos(PInteger(stack.stack[1].data.Addr.Instance)^);
  result := r;
end;
(*function DecodeStringBase64_TAnsiString(var stack: operandstack): vardesk;
var
  r: vardesk;
begin
  pDouble(r.Instance) := nil;
  r.data.ptd:=@FundamentalAnsiStringDescriptorObj;
  r.name := '';
  Getmem(r.Instance,FundamentalAnsiStringDescriptorObj.SizeInBytes);
  pAnsiString(r.Instance)^ := DecodeStringBase64(PAnsiString(stack.stack[1].Instance)^);
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
  PString(r.data.Addr.Instance)^ := DecodeStringBase64(PString(stack.stack[1].data.Addr.Instance)^);
  result := r;
end;
function Cos_TDouble(var stack: operandstack): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pdouble(r.data.Addr.Instance)^ := cos(pDouble(stack.stack[1].data.Addr.Instance)^);
  result := r;
end;


function TBoolean_let_TBoolean(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalBooleanDescriptorOdj;
  r.name := '';
  r.SetInstance(FundamentalBooleanDescriptorOdj.AllocAndInitInstance);
  PBoolean(r.data.Addr.Instance)^ := PBoolean(hrez.data.Addr.Instance)^;
  PBoolean(rez.data.Addr.Instance)^ := PBoolean(hrez.data.Addr.Instance)^;
  result := r;
end;

function TDouble_let_TDouble(var rez, hrez: vardesk): vardesk;
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
function TDouble_let_TInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pdouble(r.data.Addr.Instance)^ := PInteger(hrez.data.Addr.Instance)^;
  pdouble(rez.data.Addr.Instance)^ := PInteger(hrez.data.Addr.Instance)^;
  result := r;
end;


function TInteger_let_TInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalLongIntDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalLongIntDescriptorObj.AllocAndInitInstance);
  PInteger(r.data.Addr.Instance)^ := PInteger(hrez.data.Addr.Instance)^;
  PInteger(rez.data.Addr.Instance)^ := PInteger(hrez.data.Addr.Instance)^;
  result := r;
end;
function TByte_let_TInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalByteDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalByteDescriptorObj.AllocAndInitInstance);
  PByte(r.data.Addr.Instance)^ := PInteger(hrez.data.Addr.Instance)^;
  PByte(rez.data.Addr.Instance)^ := PInteger(hrez.data.Addr.Instance)^;
  result := r;
end;

function TString_let_TString(var rez, hrez: vardesk): vardesk;
begin
  result.data.ptd:=@FundamentalStringDescriptorObj;
  result.name := '';
  result.SetInstance(FundamentalStringDescriptorObj.AllocAndInitInstance);
  if rez.data.Addr.Instance=nil then begin
    rez.SetInstance(FundamentalStringDescriptorObj.AllocAndInitInstance);
  end else
     String(rez.data.Addr.Instance^):='';
  String(result.data.Addr.Instance^) := String(hrez.data.Addr.Instance^);
  String(rez.data.Addr.Instance^) := String(hrez.data.Addr.Instance^);
end;
function TAnsiString_let_TString(var rez, hrez: vardesk): vardesk;
begin
  result.data.ptd:=@FundamentalAnsiStringDescriptorObj;
  result.name := '';
  result.SetInstance(FundamentalStringDescriptorObj.AllocAndInitInstance);
  if rez.data.Addr.Instance=nil then begin
    rez.SetInstance(FundamentalStringDescriptorObj.AllocAndInitInstance);
  end else
    AnsiString(rez.data.Addr.Instance^):='';
  AnsiString(result.data.Addr.Instance^) := Tria_Utf8ToAnsi(String(hrez.data.Addr.Instance^));
  AnsiString(rez.data.Addr.Instance^) := Tria_Utf8ToAnsi(String(hrez.data.Addr.Instance^));
end;
function TAnsiString_let_TAnsiString(var rez, hrez: vardesk): vardesk;
begin
  result.data.ptd:=@FundamentalAnsiStringDescriptorObj;
  result.name := '';
  result.SetInstance(FundamentalAnsiStringDescriptorObj.AllocAndInitInstance);
  if rez.data.Addr.Instance=nil then
                               begin
                                 rez.SetInstance(FundamentalAnsiStringDescriptorObj.AllocAndInitInstance);
                               end
                          else
                              AnsiString(rez.data.Addr.Instance^):='';
  AnsiString(result.data.Addr.Instance^) := {Tria_Utf8ToAnsi}(AnsiString(hrez.data.Addr.Instance^));
  AnsiString(rez.data.Addr.Instance^) := {Tria_Utf8ToAnsi}(AnsiString(hrez.data.Addr.Instance^));
end;
function TInteger_minus_TInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalLongIntDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalLongIntDescriptorObj.AllocAndInitInstance);
  PInteger(r.data.Addr.Instance)^ := PInteger(rez.data.Addr.Instance)^-PInteger(hrez.data.Addr.Instance)^;
  result := r;
end;
function TInteger_minus_TDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  PDouble(r.data.Addr.Instance)^ := PInteger(rez.data.Addr.Instance)^-PDouble(hrez.data.Addr.Instance)^;
  result := r;
end;
function TDouble_minus_TDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  PDouble(r.data.Addr.Instance)^ := PDouble(rez.data.Addr.Instance)^-PDouble(hrez.data.Addr.Instance)^;
  result := r;
end;
function TDouble_minus_TInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  PDouble(r.data.Addr.Instance)^ := PDouble(rez.data.Addr.Instance)^-PInteger(hrez.data.Addr.Instance)^;
  result := r;
end;
function TDouble_mul_TInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pDouble(r.data.Addr.Instance)^ := pDouble(rez.data.Addr.Instance)^*PInteger(hrez.data.Addr.Instance)^;
  result := r;
end;
function TInteger_mul_TDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pDouble(r.data.Addr.Instance)^ := PInteger(rez.data.Addr.Instance)^ * pDouble(hrez.data.Addr.Instance)^;
  result := r;
end;
function TDouble_mul_TDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pDouble(r.data.Addr.Instance)^ := pDouble(rez.data.Addr.Instance)^ * pDouble(hrez.data.Addr.Instance)^;
  result := r;
end;
function TInteger_plus_TInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalLongIntDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalLongIntDescriptorObj.AllocAndInitInstance);
  PInteger(r.data.Addr.Instance)^ := PInteger(rez.data.Addr.Instance)^+PInteger(hrez.data.Addr.Instance)^;
  result := r;
end;
function TDouble_plus_TInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  PDouble(r.data.Addr.Instance)^ := PDouble(rez.data.Addr.Instance)^+PInteger(hrez.data.Addr.Instance)^;
  result := r;
end;
function TInteger_plus_TDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  PDouble(r.data.Addr.Instance)^ := PInteger(rez.data.Addr.Instance)^+PDouble(hrez.data.Addr.Instance)^;
  result := r;
end;
function TDouble_plus_TDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  PDouble(r.data.Addr.Instance)^ := PDouble(rez.data.Addr.Instance)^+PDouble(hrez.data.Addr.Instance)^;
  result := r;
end;
function Tnothing_plus_TInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalLongIntDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalLongIntDescriptorObj.AllocAndInitInstance);
  PInteger(r.data.Addr.Instance)^ := PInteger(hrez.data.Addr.Instance)^;
  result := r;
end;

function Tnothing_minus_TDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  PDouble(r.data.Addr.Instance)^ := -(pdouble(hrez.data.Addr.Instance)^);
  result := r;
end;

function Tnothing_minus_TInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalLongIntDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalLongIntDescriptorObj.AllocAndInitInstance);
  PInteger(r.data.Addr.Instance)^ := -(PInteger(hrez.data.Addr.Instance)^);
  result := r;
end;

function TInteger_mul_TInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalLongIntDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalLongIntDescriptorObj.AllocAndInitInstance);
  PInteger(r.data.Addr.Instance)^ := PInteger(rez.data.Addr.Instance)^ * PInteger(hrez.data.Addr.Instance)^;
  result := r;
end;
function TInteger_div_TInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pDouble(r.data.Addr.Instance)^ := PInteger(rez.data.Addr.Instance)^ / PInteger(hrez.data.Addr.Instance)^;
  result := r;
end;
function TInteger_div_TDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pDouble(r.data.Addr.Instance)^ := PInteger(rez.data.Addr.Instance)^ / pDouble(hrez.data.Addr.Instance)^;
  result := r;
end;
function TDouble_div_TDouble(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pDouble(r.data.Addr.Instance)^ := pDouble(rez.data.Addr.Instance)^ / pDouble(hrez.data.Addr.Instance)^;
  result := r;
end;
function TDouble_div_TInteger(var rez, hrez: vardesk): vardesk;
var
  r: vardesk;
begin
  r.data.ptd:=@FundamentalDoubleDescriptorObj;
  r.name := '';
  r.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
  pDouble(r.data.Addr.Instance)^ := pDouble(rez.data.Addr.Instance)^ / PInteger(hrez.data.Addr.Instance)^;
  result := r;
end;

function itbasicoperator(expr: String): Integer;
var
  i: Integer;
begin
  result := 0;
  for i := 1 to basicoperatorcount do
    if expr = basicoperatorname[i].name then
    begin
      result := i;
      exit;
    end
end;

function itbasicfunction(expr: String): Integer;
var
  i: Integer;
begin
  result := 0;
  for i := 1 to basicfunctioncount do
    if expr = basicfunctionname[i].name then
    begin
      result := i;
      exit;
    end
end;

function findbasicoperator(expr: String; rez, hrez: vardesk): Integer;
var
  i: Integer;
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
     setlength(foneInteger,1);foneInteger[0]:=@FundamentalLongIntDescriptorObj;
     setlength(foneDouble,1);foneDouble[0]:=@FundamentalDoubleDescriptorObj;
     setlength(foneString,1);foneString[0]:=@FundamentalStringDescriptorObj;
     tv.name:='cos';tv.param:=foneInteger;tv.addr:=Cos_TInteger;
     tv1.name:='cos';tv1.param:=foneDouble;tv1.addr:=Cos_TDouble;
     tv2.name:='DecodeStringBase64';tv2.param:=foneString;tv2.addr:=DecodeStringBase64_TGBDString;
     setlength(basicfunctionparam,3);
     basicfunctionparam[0]:=tv;
     basicfunctionparam[1]:=tv1;
     basicfunctionparam[2]:=tv2;
end.

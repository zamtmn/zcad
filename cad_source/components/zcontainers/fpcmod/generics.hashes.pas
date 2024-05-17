{
    This file is part of the Free Pascal/NewPascal run time library.
    Copyright (c) 2014 by Maciej Izak (hnb)
    member of the NewPascal development team (http://newpascal.org)

    Copyright(c) 2004-2018 DaThoX

    It contains the generics collections library

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    Acknowledgment

    Thanks to Sphere 10 Software (http://sphere10.com) for sponsoring
    many new types and major refactoring of entire library.

    Thanks to mORMot (http://synopse.info) project for the best implementations
    of hashing functions like crc32c and xxHash32 :)

 **********************************************************************}

{$IFNDEF FPC_DOTTEDUNITS}
unit Generics.Hashes;
{$ENDIF}

{$MODE DELPHI}{$H+}
{$POINTERMATH ON}
{$MACRO ON}
{$COPERATORS ON}
{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}

{$IFDEF CPUWASM}
{$DEFINE NOGOTO}
{$ENDIF}

interface

uses
{$IFDEF FPC_DOTTEDUNITS}
  System.Classes, System.SysUtils;
{$ELSE FPC_DOTTEDUNITS}
  Classes, SysUtils;
{$ENDIF FPC_DOTTEDUNITS}

{ Warning: the following set of macro code
  that decides to use assembler or normal code
  needs to stay after the _INTERFACE keyword
  because FPC_PIC macro is only set after this keyword,
  as it can be modified before by the global $PIC preprocessor directive. 
  Pierre Muller 2018/07/04 }

{$ifdef FPC_PIC}
  {$define DISABLE_X86_CPUINTEL}
{$endif FPC_PIC}

{$if defined(OPENBSD) or defined(EMX) or defined(OS2)}
  { These targets have old GNU assemblers that }
  { do not support all instructions used in assembler code below }
  {$define DISABLE_X86_CPUINTEL}
{$endif}

{$ifdef CPU64}
  {$define PUREPASCAL}
  {$ifdef CPUX64}
    {$define CPUINTEL}
    {$ASMMODE INTEL}
  {$endif CPUX64}
{$else}
  {$ifdef CPUX86}
    {$ifndef DISABLE_X86_CPUINTEL}
      {$define CPUINTEL}
      {$ASMMODE INTEL}
    {$else}
      { Assembler code uses references to static
        variables with are not PIC ready }
      {$define PUREPASCAL}
    {$endif}
  {$else CPUX86}
  {$define PUREPASCAL}
  {$endif}
{$endif CPU64}

// Original version of Bob Jenkins Hash
// http://burtleburtle.net/bob/c/lookup3.c
function HashWord(
  AKey: PLongWord;                   //* the key, an array of uint32_t values */
  ALength: SizeInt;                  //* the length of the key, in uint32_ts */
  AInitVal: UInt32): UInt32;         //* the previous hash, or an arbitrary value */
procedure HashWord2 (
  AKey: PLongWord;                   //* the key, an array of uint32_t values */
  ALength: SizeInt;                  //* the length of the key, in uint32_ts */
  var APrimaryHashAndInitVal: UInt32;                  //* IN: seed OUT: primary hash value */
  var ASecondaryHashAndInitVal: UInt32);               //* IN: more seed OUT: secondary hash value */

function HashLittle(AKey: Pointer; ALength: SizeInt; AInitVal: UInt32): UInt32;
procedure HashLittle2(
  AKey: Pointer;        //* the key to hash */
  ALength: SizeInt;     //* length of the key */
  var APrimaryHashAndInitVal: UInt32;                  //* IN: primary initval, OUT: primary hash */
  var ASecondaryHashAndInitVal: UInt32);               //* IN: secondary initval, OUT: secondary hash */

function DelphiHashLittle(AKey: Pointer; ALength: SizeInt; AInitVal: UInt32): Int32;
procedure DelphiHashLittle2(AKey: Pointer; ALength: SizeInt; var APrimaryHashAndInitVal, ASecondaryHashAndInitVal: UInt32);

// hash function from fstl
function SimpleChecksumHash(AKey: Pointer; ALength: SizeInt): UInt32;

// some other hashes
// http://stackoverflow.com/questions/14409466/simple-hash-functions
// http://www.partow.net/programming/hashfunctions/
// http://en.wikipedia.org/wiki/List_of_hash_functions
// http://www.cse.yorku.ca/~oz/hash.html

// https://code.google.com/p/hedgewars/source/browse/hedgewars/adler32.pas
function Adler32(AKey: Pointer; ALength: SizeInt): UInt32;
function sdbm(AKey: Pointer; ALength: SizeInt): UInt32;
function xxHash32(crc: cardinal; P: Pointer; len: integer): cardinal;{$IFNDEF CPUINTEL}inline;{$ENDIF}
// pure pascal implementation of xxHash32
function xxHash32Pascal(crc: cardinal; P: Pointer; len: integer): cardinal;

type
  THasher = function(crc: cardinal; buf: Pointer; len: cardinal): cardinal;

var
  crc32c: THasher;
  mORMotHasher: THasher;

implementation

{$IFDEF FPC_DOTTEDUNITS}
{$ifdef CPUINTEL}
  uses
    System.CPU;
{$endif CPUINTEL}
{$ELSE}
{$ifdef CPUINTEL}
  uses
    cpu;
{$endif CPUINTEL}
{$ENDIF}

function SimpleChecksumHash(AKey: Pointer; ALength: SizeInt): UInt32;
var
  i: Integer;
  ABuffer: PUInt8 absolute AKey;
begin
  Result := 0;
  for i := 0 to ALength - 1 do
     Inc(Result,ABuffer[i]);
end;

function Adler32(AKey: Pointer; ALength: SizeInt): UInt32;
const
  MOD_ADLER = 65521;
var
  ABuffer: PUInt8 absolute AKey;
  a: UInt32 = 1;
  b: UInt32 = 0;
  n: Integer;
begin
  for n := 0 to ALength -1 do
  begin
    a := (a + ABuffer[n]) mod MOD_ADLER;
    b := (b + a) mod MOD_ADLER;
  end;
  Result := (b shl 16) or a;
end;

function sdbm(AKey: Pointer; ALength: SizeInt): UInt32;
var
  c: PUInt8 absolute AKey;
  i: Integer;
begin
  Result := 0;
  c := AKey;
  for i := 0 to ALength - 1 do
  begin
    Result := c^ + (Result shl 6) + (Result shl 16) {%H-}- Result;
    Inc(c);
  end;
end;

{ BobJenkinsHash }

{$define mix_abc :=
  a -= c;  a := a xor (((c)shl(4)) or ((c)shr(32-(4))));  c += b;
  b -= a;  b := b xor (((a)shl(6)) or ((a)shr(32-(6))));  a += c;
  c -= b;  c := c xor (((b)shl(8)) or ((b)shr(32-(8))));  b += a;
  a -= c;  a := a xor (((c)shl(16)) or ((c)shr(32-(16))));  c += b;
  b -= a;  b := b xor (((a)shl(19)) or ((a)shr(32-(19))));  a += c;
  c -= b;  c := c xor (((b)shl(4)) or ((b)shr(32-(4))));  b += a
}

{$define final_abc :=
  c := c xor b; c -= (((b)shl(14)) or ((b)shr(32-(14))));
  a := a xor c; a -= (((c)shl(11)) or ((c)shr(32-(11))));
  b := b xor a; b -= (((a)shl(25)) or ((a)shr(32-(25))));
  c := c xor b; c -= (((b)shl(16)) or ((b)shr(32-(16))));
  a := a xor c; a -= (((c)shl(4)) or ((c)shr(32-(4))));
  b := b xor a; b -= (((a)shl(14)) or ((a)shr(32-(14))));
  c := c xor b; c -= (((b)shl(24)) or ((b)shr(32-(24))))
}

function HashWord(
  AKey: PLongWord;                   //* the key, an array of uint32_t values */
  ALength: SizeInt;               //* the length of the key, in uint32_ts */
  AInitVal: UInt32): UInt32;         //* the previous hash, or an arbitrary value */
var
  a,b,c: UInt32;
{$IFNDEF NOGOTO}
label
  Case0, Case1, Case2, Case3;
{$ENDIF}
begin
  //* Set up the internal state */
  a := $DEADBEEF + (UInt32(ALength) shl 2) + AInitVal;
  b := a;
  c := b;

  //*------------------------------------------------- handle most of the key */
  while ALength > 3 do
  begin
    a += AKey[0];
    b += AKey[1];
    c += AKey[2];
    mix_abc;
    ALength -= 3;
    AKey += 3;
  end;

  //*------------------------------------------- handle the last 3 uint32_t's */
{$IFDEF NOGOTO}
  if aLength=3 then
    c+=AKey[2];
  if aLength>=2 then
    b+=AKey[1];
  if aLength>=1 then
    a+=AKey[0];
  if aLength>0 then
    final_abc;
{$ELSE}
  case ALength of //* all the case statements fall through */
    3: goto Case3;
    2: goto Case2;
    1: goto Case1;
    0: goto Case0;
  end;
  Case3: c+=AKey[2];
  Case2: b+=AKey[1];
  Case1: a+=AKey[0];
    final_abc;
  Case0:     //* case 0: nothing left to add */
{$ENDIF}
  //*------------------------------------------------------ report the result */
  Result := c;
end;

procedure HashWord2 (
AKey: PLongWord;                   //* the key, an array of uint32_t values */
ALength: SizeInt;               //* the length of the key, in uint32_ts */
var APrimaryHashAndInitVal: UInt32;                      //* IN: seed OUT: primary hash value */
var ASecondaryHashAndInitVal: UInt32);               //* IN: more seed OUT: secondary hash value */
var
  a,b,c: UInt32;
{$IFNDEF NOGOTO}
label
  Case0, Case1, Case2, Case3;
{$ENDIF}
begin
  //* Set up the internal state */
  a := $deadbeef + (UInt32(ALength shl 2)) + APrimaryHashAndInitVal;
  b := a;
  c := b;
  c += ASecondaryHashAndInitVal;

  //*------------------------------------------------- handle most of the key */
  while ALength > 3 do
  begin
    a += AKey[0];
    b += AKey[1];
    c += AKey[2];
    mix_abc;
    ALength -= 3;
    AKey += 3;
  end;

  //*------------------------------------------- handle the last 3 uint32_t's */
{$IFDEF NOGOTO}
  if aLength=3 then
     c+=AKey[2];
  if aLength>=2 then
     b+=AKey[1];
  if aLength>=1 then
     a+=AKey[0];
  if aLength>0 then
    final_abc;
{$ELSE}
  case ALength of                     //* all the case statements fall through */
    3: goto Case3;
    2: goto Case2;
    1: goto Case1;
    0: goto Case0;
  end;
  Case3: c+=AKey[2];
  Case2: b+=AKey[1];
  Case1: a+=AKey[0];
    final_abc;
  Case0:     //* case 0: nothing left to add */
{$ENDIF}
  //*------------------------------------------------------ report the result */
  APrimaryHashAndInitVal := c;
  ASecondaryHashAndInitVal := b;
end;

function HashLittle(AKey: Pointer; ALength: SizeInt; AInitVal: UInt32): UInt32;
var
  a, b, c: UInt32;
  u: record case byte of
    0: (ptr: Pointer);
    1: (i: PtrUint);
  end absolute AKey;

  k32: ^UInt32 absolute AKey;
  k16: ^UInt16 absolute AKey;
  k8: ^UInt8 absolute AKey;

{$IFNDEF NOGOTO}
label _10, _8, _6, _4, _2;
label Case12, Case11, Case10, Case9, Case8, Case7, Case6, Case5, Case4, Case3, Case2, Case1;
{$endif}

{$IFDEF NOGOTO}
  procedure Do10; inline;

  begin
    c+=k16[4];
    b+=k16[2]+((UInt32(k16[3])) shl 16);
    a+=k16[0]+((UInt32(k16[1])) shl 16);
  end;

  procedure Do8; inline;

  begin
    b+=k16[2]+((UInt32(k16[3])) shl 16);
    a+=k16[0]+((UInt32(k16[1])) shl 16);
  end;

  procedure Do6; inline;

  begin
    b+=k16[2];
    a+=k16[0]+((UInt32(k16[1])) shl 16);
  end;

  procedure Do4; inline;

  begin
    a+=k16[0]+((UInt32(k16[1])) shl 16);
  end;

  procedure Do2; inline;
  begin
    a+=k16[0];
  end;
{$ENDIF}

begin
  a := $DEADBEEF + UInt32(ALength) + AInitVal;
  b := a;
  c := b;

{$IFDEF ENDIAN_LITTLE}
  if (u.i and $3) = 0 then
  begin
    while (ALength > 12) do
    begin
      a += k32[0];
      b += k32[1];
      c += k32[2];
      mix_abc;
      ALength -= 12;
      k32 += 3;
    end;

    case ALength of
      12: begin c += k32[2]; b += k32[1]; a += k32[0]; end;
      11: begin c += k32[2] and $ffffff; b += k32[1]; a += k32[0]; end;
      10: begin c += k32[2] and $ffff; b += k32[1]; a += k32[0]; end;
      9 : begin c += k32[2] and $ff; b += k32[1]; a += k32[0]; end;
      8 : begin b += k32[1]; a += k32[0]; end;
      7 : begin b += k32[1] and $ffffff; a += k32[0]; end;
      6 : begin b += k32[1] and $ffff; a += k32[0]; end;
      5 : begin b += k32[1] and $ff; a += k32[0]; end;
      4 : begin a += k32[0]; end;
      3 : begin a += k32[0] and $ffffff; end;
      2 : begin a += k32[0] and $ffff; end;
      1 : begin a += k32[0] and $ff; end;
      0 : Exit(c);              // zero length strings require no mixing
    end
  end
  else
  if (u.i and $1) = 0 then
  begin
    while (ALength > 12) do
    begin
      a += k16[0] + (UInt32(k16[1]) shl 16);
      b += k16[2] + (UInt32(k16[3]) shl 16);
      c += k16[4] + (UInt32(k16[5]) shl 16);
      mix_abc;
      ALength -= 12;
      k16 += 6;
    end;

    case ALength of
      12:
        begin
          c+=k16[4]+((UInt32(k16[5])) shl 16);
          b+=k16[2]+((UInt32(k16[3])) shl 16);
          a+=k16[0]+((UInt32(k16[1])) shl 16);
        end;
      11:
        begin
          c+=(UInt32(k8[10])) shl 16;     //* fall through */
{$IFDEF NOGOTO}
          do10;
{$ELSE}
          goto _10;
{$ENDIF}
        end;
      10:
        begin
{$IFDEF NOGOTO}
          do10;
{$ELSE}
          _10:
          c+=k16[4];
          b+=k16[2]+((UInt32(k16[3])) shl 16);
          a+=k16[0]+((UInt32(k16[1])) shl 16);
{$ENDIF}
        end;
      9 :
        begin
          c+=k8[8];                      //* fall through */
{$IFDEF NOGOTO}
          do8;
{$ELSE}
          goto _8;
{$ENDIF}
        end;
      8 :
        begin
{$IFDEF NOGOTO}
          do8;
{$ELSE}
          _8:
          b+=k16[2]+((UInt32(k16[3])) shl 16);
          a+=k16[0]+((UInt32(k16[1])) shl 16);
{$ENDIF}
        end;
      7 :
        begin
          b+=(UInt32(k8[6])) shl 16;      //* fall through */
{$IFDEF NOGOTO}
          Do6 ;
{$ELSE}
          goto _6;
{$ENDIF}
        end;
      6 :
        begin
{$IFDEF NOGOTO}
          Do6 ;
{$ELSE}
          _6:
          b+=k16[2];
          a+=k16[0]+((UInt32(k16[1])) shl 16);
{$ENDIF}
        end;
      5 :
        begin
          b+=k8[4];                      //* fall through */
{$IFDEF NOGOTO}
          Do4;
{$ELSE}
          goto _4;
{$ENDIF}
        end;
      4 :
        begin
{$IFDEF NOGOTO}
          Do4;
{$ELSE}
          _4:
          a+=k16[0]+((UInt32(k16[1])) shl 16);
{$ENDIF}
        end;
      3 :
        begin
          a+=(UInt32(k8[2])) shl 16;      //* fall through */
{$IFDEF NOGOTO}
          do2;
{$ELSE}
          goto _2;
{$ENDIF}
        end;
      2 :
        begin
{$IFDEF NOGOTO}
          do2;
{$ELSE}
         _2:
          a+=k16[0];
{$ENDIF}
        end;
      1 :
        begin
          a+=k8[0];
        end;
      0 : Exit(c);                     //* zero length requires no mixing */
    end;
  end
  else
{$ENDIF}
  begin
    while ALength > 12 do
    begin
      a += k8[0];
      a += (UInt32(k8[1])) shl 8;
      a += (UInt32(k8[2])) shl 16;
      a += (UInt32(k8[3])) shl 24;
      b += k8[4];
      b += (UInt32(k8[5])) shl 8;
      b += (UInt32(k8[6])) shl 16;
      b += (UInt32(k8[7])) shl 24;
      c += k8[8];
      c += (UInt32(k8[9])) shl 8;
      c += (UInt32(k8[10])) shl 16;
      c += (UInt32(k8[11])) shl 24;
      mix_abc;
      ALength -= 12;
      k8 += 12;
    end;
{$IFDEF NOGOTO}
  if Alength=0 then
    Exit(c);
  if ALength=12 then
    c+=(UInt32(k8[11])) shl 24;
  if aLength>=11 then
    c+=(UInt32(k8[10])) shl 16;
  if aLength>=10 then
    c+=(UInt32(k8[9])) shl 8;
  if aLength>=9 then
    c+=k8[8];
  if aLength>=8 then
    b+=(UInt32(k8[7])) shl 24;
  if aLength>=7 then
    b+=(UInt32(k8[6])) shl 16;
  if aLength>=6 then
    b+=(UInt32(k8[5])) shl 8;
  if aLength>=5 then
    b+=k8[4];
  if aLength>=4 then
    a+=(UInt32(k8[3])) shl 24;
  if aLength>=3 then
    a+=(UInt32(k8[2])) shl 16;
  if aLength>=2 then
    a+=(UInt32(k8[1])) shl 8;
  // case aLength=0 was handled first, so we know aLength>=1.
  a+=k8[0];
{$ELSE}
    case ALength of
      12: goto Case12;
      11: goto Case11;
      10: goto Case10;
      9 : goto Case9;
      8 : goto Case8;
      7 : goto Case7;
      6 : goto Case6;
      5 : goto Case5;
      4 : goto Case4;
      3 : goto Case3;
      2 : goto Case2;
      1 : goto Case1;
      0 : Exit(c);
    end;

    Case12: c+=(UInt32(k8[11])) shl 24;
    Case11: c+=(UInt32(k8[10])) shl 16;
    Case10: c+=(UInt32(k8[9])) shl 8;
    Case9: c+=k8[8];
    Case8: b+=(UInt32(k8[7])) shl 24;
    Case7: b+=(UInt32(k8[6])) shl 16;
    Case6: b+=(UInt32(k8[5])) shl 8;
    Case5: b+=k8[4];
    Case4: a+=(UInt32(k8[3])) shl 24;
    Case3: a+=(UInt32(k8[2])) shl 16;
    Case2: a+=(UInt32(k8[1])) shl 8;
    Case1: a+=k8[0];
{$ENDIF}
  end;

  final_abc;
  Result := c;
end;

(*
 * hashlittle2: return 2 32-bit hash values
 *
 * This is identical to hashlittle(), except it returns two 32-bit hash
 * values instead of just one.  This is good enough for hash table
 * lookup with 2^^64 buckets, or if you want a second hash if you're not
 * happy with the first, or if you want a probably-unique 64-bit ID for
 * the key.  *pc is better mixed than *pb, so use *pc first.  If you want
 * a 64-bit value do something like "*pc + (((uint64_t)*pb)<<32)".
 *)
procedure HashLittle2(
  AKey: Pointer;        //* the key to hash */
  ALength: SizeInt;    //* length of the key */
  var APrimaryHashAndInitVal: UInt32;                      //* IN: primary initval, OUT: primary hash */
  var ASecondaryHashAndInitVal: UInt32);               //* IN: secondary initval, OUT: secondary hash */
var
  a,b,c: UInt32;
  u: record case byte of
    0: (ptr: Pointer);
    1: (i: PtrUint);
  end absolute AKey;

  k32: ^UInt32 absolute AKey;
  k16: ^UInt16 absolute AKey;
  k8: ^UInt8 absolute AKey;

{$IFNDEF NOGOTO}
label _10, _8, _6, _4, _2;
label Case12, Case11, Case10, Case9, Case8, Case7, Case6, Case5, Case4, Case3, Case2, Case1;
{$ENDIF}

{$IFDEF NOGOTO}
  procedure Do10; inline;

  begin
    c+=k16[4];
    b+=k16[2]+((UInt32(k16[3])) shl 16);
    a+=k16[0]+((UInt32(k16[1])) shl 16);
  end;

  procedure Do8; inline;

  begin
    b+=k16[2]+((UInt32(k16[3])) shl 16);
    a+=k16[0]+((UInt32(k16[1])) shl 16);
  end;

  procedure Do6; inline;

  begin
    b+=k16[2];
    a+=k16[0]+((UInt32(k16[1])) shl 16);
  end;

  procedure Do4; inline;

  begin
    a+=k16[0]+((UInt32(k16[1])) shl 16);
  end;

  procedure Do2; inline;
  begin
    a+=k16[0];
  end;
{$ENDIF}

begin
  //* Set up the internal state */
  a := $DEADBEEF + UInt32(ALength) + APrimaryHashAndInitVal;
  b := a;
  c := b;
  c += ASecondaryHashAndInitVal;

{$IFDEF ENDIAN_LITTLE}
  if (u.i and $3) = 0 then
  begin
    while (ALength > 12) do
    begin
      a += k32[0];
      b += k32[1];
      c += k32[2];
      mix_abc;
      ALength -= 12;
      k32 += 3;
    end;

    case ALength of
      12: begin c += k32[2]; b += k32[1]; a += k32[0]; end;
      11: begin c += k32[2] and $ffffff; b += k32[1]; a += k32[0]; end;
      10: begin c += k32[2] and $ffff; b += k32[1]; a += k32[0]; end;
      9 : begin c += k32[2] and $ff; b += k32[1]; a += k32[0]; end;
      8 : begin b += k32[1]; a += k32[0]; end;
      7 : begin b += k32[1] and $ffffff; a += k32[0]; end;
      6 : begin b += k32[1] and $ffff; a += k32[0]; end;
      5 : begin b += k32[1] and $ff; a += k32[0]; end;
      4 : begin a += k32[0]; end;
      3 : begin a += k32[0] and $ffffff; end;
      2 : begin a += k32[0] and $ffff; end;
      1 : begin a += k32[0] and $ff; end;
      0 :
        begin
          APrimaryHashAndInitVal := c;
          ASecondaryHashAndInitVal := b;
          Exit;              // zero length strings require no mixing
        end;
    end
  end
  else
  if (u.i and $1) = 0 then
  begin
    while (ALength > 12) do
    begin
      a += k16[0] + (UInt32(k16[1]) shl 16);
      b += k16[2] + (UInt32(k16[3]) shl 16);
      c += k16[4] + (UInt32(k16[5]) shl 16);
      mix_abc;
      ALength -= 12;
      k16 += 6;
    end;

    case ALength of
      12:
        begin
          c+=k16[4]+((UInt32(k16[5])) shl 16);
          b+=k16[2]+((UInt32(k16[3])) shl 16);
          a+=k16[0]+((UInt32(k16[1])) shl 16);
        end;
      11:
        begin
          c+=(UInt32(k8[10])) shl 16;     //* fall through */
{$IFDEF NOGOTO}
          Do10;
{$ELSE}
          goto _10
{$ENDIF}
        end;
      10:
        begin
{$IFDEF NOGOTO}
         Do10;
{$ELSE}
        _10:
          c+=k16[4];
          b+=k16[2]+((UInt32(k16[3])) shl 16);
          a+=k16[0]+((UInt32(k16[1])) shl 16);
{$ENDIF}
        end;
      9 :
        begin
          c+=k8[8];                      //* fall through */
{$IFDEF NOGOTO}
          Do8;
{$ELSE}
          goto _8;
{$ENDIF}
        end;
      8 :
        begin
{$IFDEF NOGOTO}
          Do8;
{$ELSE}
        _8:
          b+=k16[2]+((UInt32(k16[3])) shl 16);
          a+=k16[0]+((UInt32(k16[1])) shl 16);
{$ENDIF}
        end;
      7 :
        begin
          b+=(UInt32(k8[6])) shl 16;      //* fall through */
{$IFDEF NOGOTO}
          Do6 ;
{$ELSE}
          goto _6;
{$ENDIF}
        end;
      6 :
        begin
{$IFDEF NOGOTO}
          Do6 ;
{$ELSE}
        _6:
          b+=k16[2];
          a+=k16[0]+((UInt32(k16[1])) shl 16);
{$ENDIF}
        end;
      5 :
        begin
          b+=k8[4];                      //* fall through */
{$IFDEF NOGOTO}
          Do4 ;
{$ELSE}
          goto _4;
{$ENDIF}
        end;
      4 :
        begin
{$IFDEF NOGOTO}
          Do4 ;
{$ELSE}
        _4:
          a+=k16[0]+((UInt32(k16[1])) shl 16);
{$ENDIF}
        end;
      3 :
        begin
          a+=(UInt32(k8[2])) shl 16;      //* fall through */
{$IFDEF NOGOTO}
          Do2 ;
{$ELSE}
          goto _2;
{$ENDIF}
        end;
      2 :
        begin
{$IFDEF NOGOTO}
          Do2;
{$ELSE}
        _2:
          a+=k16[0];
{$ENDIF}
        end;
      1 :
        begin
          a+=k8[0];
        end;
      0 :
        begin
          APrimaryHashAndInitVal := c;
          ASecondaryHashAndInitVal := b;
          Exit;              // zero length strings require no mixing
        end;
    end;
  end
  else
{$ENDIF}
  begin
    while ALength > 12 do
    begin
      a += k8[0];
      a += (UInt32(k8[1])) shl 8;
      a += (UInt32(k8[2])) shl 16;
      a += (UInt32(k8[3])) shl 24;
      b += k8[4];
      b += (UInt32(k8[5])) shl 8;
      b += (UInt32(k8[6])) shl 16;
      b += (UInt32(k8[7])) shl 24;
      c += k8[8];
      c += (UInt32(k8[9])) shl 8;
      c += (UInt32(k8[10])) shl 16;
      c += (UInt32(k8[11])) shl 24;
      mix_abc;
      ALength -= 12;
      k8 += 12;
    end;
{$IFDEF NOGOTO}
  if aLength=0 then
    begin
    APrimaryHashAndInitVal := c;
    ASecondaryHashAndInitVal := b;
    Exit;              // zero length strings require no mixing
    end;
  if aLength=12 then
    c+=(UInt32(k8[11])) shl 24;
  if aLength>=11 then
    c+=(UInt32(k8[10])) shl 16;
  if aLength>=10 then
    c+=(UInt32(k8[9])) shl 8;
  if aLength>=9 then
    c+=k8[8];
  if aLength>=8 then
    b+=(UInt32(k8[7])) shl 24;
  if aLength>=7 then
    b+=(UInt32(k8[6])) shl 16;
  if aLength>=6 then
    b+=(UInt32(k8[5])) shl 8;
  if aLength>=5 then
    b+=k8[4];
  if aLength>=4 then
    a+=(UInt32(k8[3])) shl 24;
  if aLength>=3 then
    a+=(UInt32(k8[2])) shl 16;
  if aLength>=2 then
    a+=(UInt32(k8[1])) shl 8;
  a+=k8[0];
{$ELSE}
    case ALength of
      12: goto Case12;
      11: goto Case11;
      10: goto Case10;
      9 : goto Case9;
      8 : goto Case8;
      7 : goto Case7;
      6 : goto Case6;
      5 : goto Case5;
      4 : goto Case4;
      3 : goto Case3;
      2 : goto Case2;
      1 : goto Case1;
      0 :
        begin
          APrimaryHashAndInitVal := c;
          ASecondaryHashAndInitVal := b;
          Exit;              // zero length strings require no mixing
        end;
    end;

    Case12: c+=(UInt32(k8[11])) shl 24;
    Case11: c+=(UInt32(k8[10])) shl 16;
    Case10: c+=(UInt32(k8[9])) shl 8;
    Case9: c+=k8[8];
    Case8: b+=(UInt32(k8[7])) shl 24;
    Case7: b+=(UInt32(k8[6])) shl 16;
    Case6: b+=(UInt32(k8[5])) shl 8;
    Case5: b+=k8[4];
    Case4: a+=(UInt32(k8[3])) shl 24;
    Case3: a+=(UInt32(k8[2])) shl 16;
    Case2: a+=(UInt32(k8[1])) shl 8;
    Case1: a+=k8[0];
{$ENDIF}
  end;

  final_abc;
  APrimaryHashAndInitVal := c;
  ASecondaryHashAndInitVal := b;
end;

procedure DelphiHashLittle2(AKey: Pointer; ALength: SizeInt; var APrimaryHashAndInitVal, ASecondaryHashAndInitVal: UInt32);
var
  a,b,c: UInt32;
  u: record case byte of
    0: (ptr: Pointer);
    1: (i: PtrUint);
  end absolute AKey;

  k32: ^UInt32 absolute AKey;
  k16: ^UInt16 absolute AKey;
  k8: ^UInt8 absolute AKey;

{$IFNDEF NOGOTO}
label _10, _8, _6, _4, _2;
label Case12, Case11, Case10, Case9, Case8, Case7, Case6, Case5, Case4, Case3, Case2, Case1;
{$ENDIF}

{$IFDEF NOGOTO}
  procedure Do10; inline;

  begin
    c+=k16[4];
    b+=k16[2]+((UInt32(k16[3])) shl 16);
    a+=k16[0]+((UInt32(k16[1])) shl 16);
  end;

  procedure Do8; inline;

  begin
    b+=k16[2]+((UInt32(k16[3])) shl 16);
    a+=k16[0]+((UInt32(k16[1])) shl 16);
  end;

  procedure Do6; inline;

  begin
    b+=k16[2];
    a+=k16[0]+((UInt32(k16[1])) shl 16);
  end;

  procedure Do4; inline;

  begin
    a+=k16[0]+((UInt32(k16[1])) shl 16);
  end;

  procedure Do2; inline;
  begin
    a+=k16[0];
  end;
{$ENDIF}

begin
  //* Set up the internal state */
  a := $DEADBEEF + UInt32(ALength) + APrimaryHashAndInitVal;
  b := a;
  c := b;
  c += ASecondaryHashAndInitVal;

{$IFDEF ENDIAN_LITTLE}
  if (u.i and $3) = 0 then
  begin
    while (ALength > 12) do
    begin
      a += k32[0];
      b += k32[1];
      c += k32[2];
      mix_abc;
      ALength -= 12;
      k32 += 3;
    end;

    case ALength of
      12: begin c += k32[2]; b += k32[1]; a += k32[0]; end;
      11: begin c += k32[2] and $ffffff; b += k32[1]; a += k32[0]; end;
      10: begin c += k32[2] and $ffff; b += k32[1]; a += k32[0]; end;
      9 : begin c += k32[2] and $ff; b += k32[1]; a += k32[0]; end;
      8 : begin b += k32[1]; a += k32[0]; end;
      7 : begin b += k32[1] and $ffffff; a += k32[0]; end;
      6 : begin b += k32[1] and $ffff; a += k32[0]; end;
      5 : begin b += k32[1] and $ff; a += k32[0]; end;
      4 : begin a += k32[0]; end;
      3 : begin a += k32[0] and $ffffff; end;
      2 : begin a += k32[0] and $ffff; end;
      1 : begin a += k32[0] and $ff; end;
      0 :
        begin
          APrimaryHashAndInitVal := c;
          ASecondaryHashAndInitVal := b;
          Exit;              // zero length strings require no mixing
        end;
    end
  end
  else
  if (u.i and $1) = 0 then
  begin
    while (ALength > 12) do
    begin
      a += k16[0] + (UInt32(k16[1]) shl 16);
      b += k16[2] + (UInt32(k16[3]) shl 16);
      c += k16[4] + (UInt32(k16[5]) shl 16);
      mix_abc;
      ALength -= 12;
      k16 += 6;
    end;

    case ALength of
      12:
        begin
          c+=k16[4]+((UInt32(k16[5])) shl 16);
          b+=k16[2]+((UInt32(k16[3])) shl 16);
          a+=k16[0]+((UInt32(k16[1])) shl 16);
        end;
      11:
        begin
          c+=(UInt32(k8[10])) shl 16;     //* fall through */
{$IFDEF NOGOTO}
          Do10;
{$ELSE}
          goto _10;
{$ENDIF}
        end;
      10:
        begin
{$IFDEF NOGOTO}
          Do10;
{$ELSE}
        _10:
          c+=k16[4];
          b+=k16[2]+((UInt32(k16[3])) shl 16);
          a+=k16[0]+((UInt32(k16[1])) shl 16);
{$ENDIF}
        end;
      9 :
        begin
          c+=k8[8];                      //* fall through */
{$IFDEF NOGOTO}
          Do8;
{$ELSE}
          goto _8;
{$ENDIF}
        end;
      8 :
        begin
{$IFDEF NOGOTO}
          Do8;
{$ELSE}
        _8:
          b+=k16[2]+((UInt32(k16[3])) shl 16);
          a+=k16[0]+((UInt32(k16[1])) shl 16);
{$ENDIF}
        end;
      7 :
        begin
          b+=(UInt32(k8[6])) shl 16;      //* fall through */
{$IFDEF NOGOTO}
          Do6;
{$ELSE}
          goto _6;
{$ENDIF}
        end;
      6 :
        begin
{$IFDEF NOGOTO}
          Do6;
{$ELSE}
        _6:
          b+=k16[2];
          a+=k16[0]+((UInt32(k16[1])) shl 16);
{$ENDIF}
        end;
      5 :
        begin
          b+=k8[4];                      //* fall through */
{$IFDEF NOGOTO}
          Do4;
{$ELSE}
          goto _4;
{$ENDIF}
        end;
      4 :
        begin
{$IFDEF NOGOTO}
          Do4;
{$ELSE}
        _4:
          a+=k16[0]+((UInt32(k16[1])) shl 16);
{$ENDIF}
        end;
      3 :
        begin
          a+=(UInt32(k8[2])) shl 16;      //* fall through */
{$IFDEF NOGOTO}
          Do2;
{$ELSE}
          goto _2;
{$ENDIF}
        end;
      2 :
        begin
{$IFDEF NOGOTO}
          Do2;
{$ELSE}
        _2:
          a+=k16[0];
{$ENDIF}
        end;
      1 :
        begin
          a+=k8[0];
        end;
      0 :
        begin
          APrimaryHashAndInitVal := c;
          ASecondaryHashAndInitVal := b;
          Exit;              // zero length strings require no mixing
        end;
    end;
  end
  else
{$ENDIF}
  begin
    while ALength > 12 do
    begin
      a += k8[0];
      a += (UInt32(k8[1])) shl 8;
      a += (UInt32(k8[2])) shl 16;
      a += (UInt32(k8[3])) shl 24;
      b += k8[4];
      b += (UInt32(k8[5])) shl 8;
      b += (UInt32(k8[6])) shl 16;
      b += (UInt32(k8[7])) shl 24;
      c += k8[8];
      c += (UInt32(k8[9])) shl 8;
      c += (UInt32(k8[10])) shl 16;
      c += (UInt32(k8[11])) shl 24;
      mix_abc;
      ALength -= 12;
      k8 += 12;
    end;
{$IFDEF NOGOTO}
    if aLength=0 then
      begin
      APrimaryHashAndInitVal := c;
      ASecondaryHashAndInitVal := b;
      Exit;              // zero length strings require no mixing
      end;
    if aLength=12 then
      c+=(UInt32(k8[11])) shl 24;
    if aLength>=11 then
      c+=(UInt32(k8[10])) shl 16;
    if aLength>=10 then
      c+=(UInt32(k8[9])) shl 8;
    if aLength>=9 then
      c+=k8[8];
    if aLength>=8 then
      b+=(UInt32(k8[7])) shl 24;
    if aLength>=7 then
      b+=(UInt32(k8[6])) shl 16;
    if aLength>=6 then
      b+=(UInt32(k8[5])) shl 8;
    if aLength>=5 then
      b+=k8[4];
    if aLength>=4 then
      a+=(UInt32(k8[3])) shl 24;
    if aLength>=3 then
      a+=(UInt32(k8[2])) shl 16;
    if aLength>=2 then
      a+=(UInt32(k8[1])) shl 8;
    a+=k8[0];

{$ELSE}
    case ALength of
      12: goto Case12;
      11: goto Case11;
      10: goto Case10;
      9 : goto Case9;
      8 : goto Case8;
      7 : goto Case7;
      6 : goto Case6;
      5 : goto Case5;
      4 : goto Case4;
      3 : goto Case3;
      2 : goto Case2;
      1 : goto Case1;
      0 :
        begin
          APrimaryHashAndInitVal := c;
          ASecondaryHashAndInitVal := b;
          Exit;              // zero length strings require no mixing
        end;
    end;

    Case12: c+=(UInt32(k8[11])) shl 24;
    Case11: c+=(UInt32(k8[10])) shl 16;
    Case10: c+=(UInt32(k8[9])) shl 8;
    Case9: c+=k8[8];
    Case8: b+=(UInt32(k8[7])) shl 24;
    Case7: b+=(UInt32(k8[6])) shl 16;
    Case6: b+=(UInt32(k8[5])) shl 8;
    Case5: b+=k8[4];
    Case4: a+=(UInt32(k8[3])) shl 24;
    Case3: a+=(UInt32(k8[2])) shl 16;
    Case2: a+=(UInt32(k8[1])) shl 8;
    Case1: a+=k8[0];
{$ENDIF}
  end;

  final_abc;
  APrimaryHashAndInitVal := c;
  ASecondaryHashAndInitVal := b;
end;

function DelphiHashLittle(AKey: Pointer; ALength: SizeInt; AInitVal: UInt32): Int32;
var
  a, b, c: UInt32;
  u: record case byte of
    0: (ptr: Pointer);
    1: (i: PtrUint);
  end absolute AKey;

  k32: ^UInt32 absolute AKey;
  //k16: ^UInt16 absolute AKey;
  k8: ^UInt8 absolute AKey;

{$IFNDEF NOGOTO}
label Case12, Case11, Case10, Case9, Case8, Case7, Case6, Case5, Case4, Case3, Case2, Case1;
{$ENDIF NOGOTO}

begin
  a := $DEADBEEF + UInt32(ALength) + AInitVal;
  b := a;
  c := b;

{.$IFDEF ENDIAN_LITTLE} // Delphi version don't care
  if (u.i and $3) = 0 then
  begin
    while (ALength > 12) do
    begin
      a += k32[0];
      b += k32[1];
      c += k32[2];
      mix_abc;
      ALength -= 12;
      k32 += 3;
    end;

    case ALength of
      12: begin c += k32[2]; b += k32[1]; a += k32[0]; end;
      11: begin c += k32[2] and $ffffff; b += k32[1]; a += k32[0]; end;
      10: begin c += k32[2] and $ffff; b += k32[1]; a += k32[0]; end;
      9 : begin c += k32[2] and $ff; b += k32[1]; a += k32[0]; end;
      8 : begin b += k32[1]; a += k32[0]; end;
      7 : begin b += k32[1] and $ffffff; a += k32[0]; end;
      6 : begin b += k32[1] and $ffff; a += k32[0]; end;
      5 : begin b += k32[1] and $ff; a += k32[0]; end;
      4 : begin a += k32[0]; end;
      3 : begin a += k32[0] and $ffffff; end;
      2 : begin a += k32[0] and $ffff; end;
      1 : begin a += k32[0] and $ff; end;
      0 : Exit(c);              // zero length strings require no mixing
    end
  end
  else
{.$ENDIF}
  begin
    while ALength > 12 do
    begin
      a += k8[0];
      a += (UInt32(k8[1])) shl 8;
      a += (UInt32(k8[2])) shl 16;
      a += (UInt32(k8[3])) shl 24;
      b += k8[4];
      b += (UInt32(k8[5])) shl 8;
      b += (UInt32(k8[6])) shl 16;
      b += (UInt32(k8[7])) shl 24;
      c += k8[8];
      c += (UInt32(k8[9])) shl 8;
      c += (UInt32(k8[10])) shl 16;
      c += (UInt32(k8[11])) shl 24;
      mix_abc;
      ALength -= 12;
      k8 += 12;
    end;
{$IFDEF NOGOTO}
  if aLength=0 then
    exit(c);
  if aLength=12 then
    c+=(UInt32(k8[11])) shl 24;
  if aLength>=11 then
    c+=(UInt32(k8[10])) shl 16;
  if aLength>=10 then
    c+=(UInt32(k8[9])) shl 8;
  if aLength>=9 then
    c+=k8[8];
  if aLength>=8 then
    b+=(UInt32(k8[7])) shl 24;
  if aLength>=7 then
    b+=(UInt32(k8[6])) shl 16;
  if aLength>=6 then
    b+=(UInt32(k8[5])) shl 8;
  if aLength>=5 then
    b+=k8[4];
  if aLength>=4 then
    a+=(UInt32(k8[3])) shl 24;
  if aLength>=3 then
    a+=(UInt32(k8[2])) shl 16;
  if aLength>=2 then
    a+=(UInt32(k8[1])) shl 8;
  a+=k8[0];

{$ELSE}
    case ALength of
      12: goto Case12;
      11: goto Case11;
      10: goto Case10;
      9 : goto Case9;
      8 : goto Case8;
      7 : goto Case7;
      6 : goto Case6;
      5 : goto Case5;
      4 : goto Case4;
      3 : goto Case3;
      2 : goto Case2;
      1 : goto Case1;
      0 : Exit(c);
    end;

    Case12: c+=(UInt32(k8[11])) shl 24;
    Case11: c+=(UInt32(k8[10])) shl 16;
    Case10: c+=(UInt32(k8[9])) shl 8;
    Case9: c+=k8[8];
    Case8: b+=(UInt32(k8[7])) shl 24;
    Case7: b+=(UInt32(k8[6])) shl 16;
    Case6: b+=(UInt32(k8[5])) shl 8;
    Case5: b+=k8[4];
    Case4: a+=(UInt32(k8[3])) shl 24;
    Case3: a+=(UInt32(k8[2])) shl 16;
    Case2: a+=(UInt32(k8[1])) shl 8;
    Case1: a+=k8[0];
{$ENDIF}
  end;

  final_abc;
  Result := Int32(c);
end;

{$ifdef CPUARM} // circumvent FPC issue on ARM
function ToByte(value: cardinal): cardinal; inline;
begin
  result := value and $ff;
end;
{$else}
type ToByte = byte;
{$endif}

{$ifdef CPUINTEL} // use optimized x86/x64 asm versions for xxHash32

{$ifdef CPUX86}
function xxHash32(crc: cardinal; P: Pointer; len: integer): cardinal;
asm
        xchg    edx, ecx
        push    ebp
        push    edi
        lea     ebp, [ecx+edx]
        push    esi
        push    ebx
        sub     esp, 8
        cmp     edx, 15
        mov     ebx, eax
        mov     dword ptr [esp], edx
        lea     eax, [ebx+165667B1H]
        jbe     @2
        lea     eax, [ebp-10H]
        lea     edi, [ebx+24234428H]
        lea     esi, [ebx-7A143589H]
        mov     dword ptr [esp+4H], ebp
        mov     edx, eax
        lea     eax, [ebx+61C8864FH]
        mov     ebp, edx
@1:     mov     edx, dword ptr [ecx]
        imul    edx, edx, -2048144777
        add     edi, edx
        rol     edi, 13
        imul    edi, edi, -1640531535
        mov     edx, dword ptr [ecx+4]
        imul    edx, edx, -2048144777
        add     esi, edx
        rol     esi, 13
        imul    esi, esi, -1640531535
        mov     edx, dword ptr [ecx+8]
        imul    edx, edx, -2048144777
        add     ebx, edx
        rol     ebx, 13
        imul    ebx, ebx, -1640531535
        mov     edx, dword ptr [ecx+12]
        lea     ecx, [ecx+16]
        imul    edx, edx, -2048144777
        add     eax, edx
        rol     eax, 13
        imul    eax, eax, -1640531535
        cmp     ebp, ecx
        jnc     @1
        rol     edi, 1
        rol     esi, 7
        rol     ebx, 12
        add     esi, edi
        mov     ebp, dword ptr [esp+4H]
        ror     eax, 14
        add     ebx, esi
        add     eax, ebx
@2:     lea     esi, [ecx+4H]
        add     eax, dword ptr [esp]
        cmp     ebp, esi
        jc      @4
        mov     ebx, esi
        nop
@3:     imul    edx, dword ptr [ebx-4H], -1028477379
        add     ebx, 4
        add     eax, edx
        ror     eax, 15
        imul    eax, eax, 668265263
        cmp     ebp, ebx
        jnc     @3
        lea     edx, [ebp-4H]
        sub     edx, ecx
        mov     ecx, edx
        and     ecx, 0FFFFFFFCH
        add     ecx, esi
@4:     cmp     ebp, ecx
        jbe     @6
@5:     movzx   edx, byte ptr [ecx]
        add     ecx, 1
        imul    edx, edx, 374761393
        add     eax, edx
        rol     eax, 11
        imul    eax, eax, -1640531535
        cmp     ebp, ecx
        jnz     @5
        nop
@6:     mov     edx, eax
        add     esp, 8
        shr     edx, 15
        xor     eax, edx
        imul    eax, eax, -2048144777
        pop     ebx
        pop     esi
        mov     edx, eax
        shr     edx, 13
        xor     eax, edx
        imul    eax, eax, -1028477379
        pop     edi
        pop     ebp
        mov     edx, eax
        shr     edx, 16
        xor     eax, edx
end;
{$endif CPUX86}

{$ifdef CPUX64}
function xxHash32(crc: cardinal; P: Pointer; len: integer): cardinal;
asm
        {$ifndef WIN64} // crc=rdi P=rsi len=rdx
        mov     r8, rdi
        mov     rcx, rsi
        {$else} // crc=r8 P=rcx len=rdx
        mov     r10, r8
        mov     r8, rcx
        mov     rcx, rdx
        mov     rdx, r10
        push    rsi   // Win64 expects those registers to be preserved
        push    rdi
        {$endif}
        // P=r8 len=rcx crc=rdx
        push    rbx
        lea     r10, [rcx+rdx]
        cmp     rdx, 15
        lea     eax, [r8+165667B1H]
        jbe     @2
        lea     rsi, [r10-10H]
        lea     ebx, [r8+24234428H]
        lea     edi, [r8-7A143589H]
        lea     eax, [r8+61C8864FH]
@1:     imul    r9d, dword ptr [rcx], -2048144777
        add     rcx, 16
        imul    r11d, dword ptr [rcx-0CH], -2048144777
        add     ebx, r9d
        lea     r9d, [r11+rdi]
        rol     ebx, 13
        rol     r9d, 13
        imul    ebx, ebx, -1640531535
        imul    edi, r9d, -1640531535
        imul    r9d, dword ptr [rcx-8H], -2048144777
        add     r8d, r9d
        imul    r9d, dword ptr [rcx-4H], -2048144777
        rol     r8d, 13
        imul    r8d, r8d, -1640531535
        add     eax, r9d
        rol     eax, 13
        imul    eax, eax, -1640531535
        cmp     rsi, rcx
        jnc     @1
        rol     edi, 7
        rol     ebx, 1
        rol     r8d, 12
        mov     r9d, edi
        ror     eax, 14
        add     r9d, ebx
        add     r8d, r9d
        add     eax, r8d
@2:     lea     r9, [rcx+4H]
        add     eax, edx
        cmp     r10, r9
        jc      @4
        mov     r8, r9
@3:     imul    edx, dword ptr [r8-4H], -1028477379
        add     r8, 4
        add     eax, edx
        ror     eax, 15
        imul    eax, eax, 668265263
        cmp     r10, r8
        jnc     @3
        lea     rdx, [r10-4H]
        sub     rdx, rcx
        mov     rcx, rdx
        and     rcx, 0FFFFFFFFFFFFFFFCH
        add     rcx, r9
@4:     cmp     r10, rcx
        jbe     @6
@5:     movzx   edx, byte ptr [rcx]
        add     rcx, 1
        imul    edx, edx, 374761393
        add     eax, edx
        rol     eax, 11
        imul    eax, eax, -1640531535
        cmp     r10, rcx
        jnz     @5
@6:     mov     edx, eax
        shr     edx, 15
        xor     eax, edx
        imul    eax, eax, -2048144777
        mov     edx, eax
        shr     edx, 13
        xor     eax, edx
        imul    eax, eax, -1028477379
        mov     edx, eax
        shr     edx, 16
        xor     eax, edx
        pop     rbx
        {$ifdef WIN64}
        pop     rdi
        pop     rsi
        {$endif}
end;
{$endif CPUX64}
{$else not CPUINTEL}
function xxHash32(crc: cardinal; P: Pointer; len: integer): cardinal;
begin
  result := xxHash32Pascal(crc, P, len);
end;
{$endif CPUINTEL}

const
  PRIME32_1 = 2654435761;
  PRIME32_2 = 2246822519;
  PRIME32_3 = 3266489917;
  PRIME32_4 = 668265263;
  PRIME32_5 = 374761393;

// RolDWord is an intrinsic function under FPC :)
function Rol13(value: cardinal): cardinal; inline;
begin
  result := RolDWord(value, 13);
end;

function xxHash32Pascal(crc: cardinal; P: Pointer; len: integer): cardinal;
var c1, c2, c3, c4: cardinal;
    PLimit, PEnd: PAnsiChar;
begin
  PEnd := P + len;
  if len >= 16 then begin
    PLimit := PEnd - 16;
    c3 := crc;
    c2 := c3 + PRIME32_2;
    c1 := c2 + PRIME32_1;
    c4 := c3 - PRIME32_1;
    repeat
      c1 := PRIME32_1 * Rol13(c1 + PRIME32_2 * PCardinal(P)^);
      c2 := PRIME32_1 * Rol13(c2 + PRIME32_2 * PCardinal(P+4)^);
      c3 := PRIME32_1 * Rol13(c3 + PRIME32_2 * PCardinal(P+8)^);
      c4 := PRIME32_1 * Rol13(c4 + PRIME32_2 * PCardinal(P+12)^);
      inc(P, 16);
    until not (P <= PLimit);
    result := RolDWord(c1, 1) + RolDWord(c2, 7) + RolDWord(c3, 12) + RolDWord(c4, 18);
  end else
    result := crc + PRIME32_5;
  inc(result, len);
  { Use "P + 4 <= PEnd" instead of "P <= PEnd - 4" to avoid crashes in case P = nil.
    When P = nil,
    then "PtrUInt(PEnd - 4)" is 4294967292,
    so the condition "P <= PEnd - 4" would be satisfied,
    and the code would try to access PCardinal(nil)^ causing a SEGFAULT. }
  while P + 4 <= PEnd do begin
    inc(result, PCardinal(P)^ * PRIME32_3);
    result := RolDWord(result, 17) * PRIME32_4;
    inc(P, 4);
  end;
  while P < PEnd do begin
    inc(result, PByte(P)^ * PRIME32_5);
    result := RolDWord(result, 11) * PRIME32_1;
    inc(P);
  end;
  result := result xor (result shr 15);
  result := result * PRIME32_2;
  result := result xor (result shr 13);
  result := result * PRIME32_3;
  result := result xor (result shr 16);
end;

{$ifdef CPUINTEL}

{$ifdef CPU64}
function crc32csse42(crc: cardinal; buf: PAnsiChar; len: cardinal): cardinal; nostackframe; assembler; 
asm
        mov     eax, crc
        test    len, len
        jz      @z
        test    buf, buf
        jz      @z
        not     eax
        mov     ecx, len
        shr     len, 3
        jnz     @by8 // we don't care for read alignment
@0:     test    cl, 4
        jz      @4
        crc32   eax, dword ptr [buf]
        add     buf, 4
@4:     test    cl, 2
        jz      @2
        crc32   eax, word ptr [buf]
        add     buf, 2
@2:     test    cl, 1
        jz      @1
        crc32   eax, byte ptr [buf]
@1:     not     eax
@z:     ret
        align 16
@by8:   crc32   rax, qword ptr [buf] // hash 8 bytes per loop
        add     buf, 8
        sub     len, 1
        jnz     @by8
        jmp     @0
end;
{$else}
function crc32csse42(crc: cardinal; buf: PAnsiChar; len: cardinal): cardinal; nostackframe; assembler;
asm
        // eax=crc, edx=buf, ecx=len
        not     eax
        test    ecx, ecx
        jz      @0
        test    edx, edx
        jz      @0
        jmp     @align
@a:     crc32   eax, byte ptr [edx]
        inc     edx
        dec     ecx
        jz      @0
@align: test    dl, 3
        jnz     @a
        push    ecx
        shr     ecx, 3
        jnz     @by8
@rem:   pop     ecx
        test    cl, 4
        jz      @4
        crc32   eax, dword ptr [edx]
        add     edx, 4
@4:     test    cl, 2
        jz      @2
        crc32   eax, word ptr [edx]
        add     edx, 2
@2:     test    cl, 1
        jz      @0
        crc32   eax, byte ptr [edx]
@0:     not     eax
        ret
@by8:   crc32   eax, dword ptr [edx]
        crc32   eax, dword ptr [edx + 4]
        add     edx, 8
        dec     ecx
        jnz     @by8
        jmp     @rem
end;
{$endif}

{$endif CPUINTEL}

{$ifdef CPULOONGARCH64}
function crc32cloongarch(crc: cardinal; buf: Pointer; len: cardinal): cardinal; nostackframe; assembler;
asm
  nor $a0, $zero, $a0
  beqz $a1, .Lret
  beqz $a2, .Lret
  andi $t0, $a1, 7
  beqz $t0, .Lcrc1
  xori $t0, $t0, 7
.Lcrc0:
  ld.b $t1, $a1, 0
  addi.d $a1, $a1, 1
  addi.d $t0, $t0, -1
  addi.d $a2, $a2, -1
  crcc.w.b.w $a0, $t1, $a0
  beqz $a2, .Lret
  bgez $t0, .Lcrc0
.Lcrc1:
  srli.d $t0, $a2, 3
  andi $t1, $a2, 4
  andi $t2, $a2, 2
  andi $t3, $a2, 1
  beqz $t0, .Lcrc3
.Lcrc2:
  ld.d $t4, $a1, 0
  crcc.w.d.w $a0, $t4, $a0
  addi.d $t0, $t0, -1
  addi.d $a1, $a1, 8
  bnez $t0, .Lcrc2
.Lcrc3:
  beqz $t1,.Lcrc4
  ld.w $t4, $a1, 0
  crcc.w.w.w $a0, $t4, $a0
  addi.d $a1, $a1, 4
.Lcrc4:
  beqz $t2,.Lcrc5
  ld.h $t4, $a1, 0
  crcc.w.h.w $a0, $t4, $a0
  addi.d $a1, $a1, 2
.Lcrc5:
  beqz $t3,.Lret
  ld.b $t4, $a1, 0
  crcc.w.b.w $a0, $t4, $a0
.Lret:
  nor $a0, $zero, $a0
end;
{$endif CPULOONGARCH64}

var
  crc32ctab: array[0..{$ifdef PUREPASCAL}3{$else}7{$endif},byte] of cardinal;

function crc32cfast(crc: cardinal; buf: Pointer; len: cardinal): cardinal;
{$ifdef PUREPASCAL}
begin
  result := not crc;
  if (buf<>nil) and (len>0) then begin
    repeat
      if PtrUInt(buf) and 3=0 then // align to 4 bytes boundary
        break;
      result := crc32ctab[0,ToByte(result xor cardinal(buf^))] xor (result shr 8);
      dec(len);
      inc(buf);
    until len=0;
    while len>=4 do begin
      result := result xor PCardinal(buf)^;
      inc(buf,4);
      result := crc32ctab[3,ToByte(result)] xor
                crc32ctab[2,ToByte(result shr 8)] xor
                crc32ctab[1,ToByte(result shr 16)] xor
                crc32ctab[0,result shr 24];
      dec(len,4);
    end;
    while len>0 do begin
      result := crc32ctab[0,ToByte(result xor cardinal(buf^))] xor (result shr 8);
      dec(len);
      inc(buf);
    end;
  end;
  result := not result;
end;
{$else}
// adapted from fast Aleksandr Sharahov version
asm
        test    edx, edx
        jz      @ret
        neg     ecx
        jz      @ret
        not     eax
        push    ebx
@head:  test    dl, 3
        jz      @aligned
        movzx   ebx, byte[edx]
        inc     edx
        xor     bl, al
        shr     eax, 8
        xor     eax, dword ptr[ebx * 4 + crc32ctab]
        inc     ecx
        jnz     @head
        pop     ebx
        not     eax
        ret
@ret:   rep     ret
@aligned:
        sub     edx, ecx
        add     ecx, 8
        jg      @bodydone
        push    esi
        push    edi
        mov     edi, edx
        mov     edx, eax
@bodyloop:
        mov     ebx, [edi + ecx - 4]
        xor     edx, [edi + ecx - 8]
        movzx   esi, bl
        mov     eax, dword ptr[esi * 4 + crc32ctab + 1024 * 3]
        movzx   esi, bh
        xor     eax, dword ptr[esi * 4 + crc32ctab + 1024 * 2]
        shr     ebx, 16
        movzx   esi, bl
        xor     eax, dword ptr[esi * 4 + crc32ctab + 1024 * 1]
        movzx   esi, bh
        xor     eax, dword ptr[esi * 4 + crc32ctab + 1024 * 0]
        movzx   esi, dl
        xor     eax, dword ptr[esi * 4 + crc32ctab + 1024 * 7]
        movzx   esi, dh
        xor     eax, dword ptr[esi * 4 + crc32ctab + 1024 * 6]
        shr     edx, 16
        movzx   esi, dl
        xor     eax, dword ptr[esi * 4 + crc32ctab + 1024 * 5]
        movzx   esi, dh
        xor     eax, dword ptr[esi * 4 + crc32ctab + 1024 * 4]
        add     ecx, 8
        jg      @done
        mov     ebx, [edi + ecx - 4]
        xor     eax, [edi + ecx - 8]
        movzx   esi, bl
        mov     edx, dword ptr[esi * 4 + crc32ctab + 1024 * 3]
        movzx   esi, bh
        xor     edx, dword ptr[esi * 4 + crc32ctab + 1024 * 2]
        shr     ebx, 16
        movzx   esi, bl
        xor     edx, dword ptr[esi * 4 + crc32ctab + 1024 * 1]
        movzx   esi, bh
        xor     edx, dword ptr[esi * 4 + crc32ctab + 1024 * 0]
        movzx   esi, al
        xor     edx, dword ptr[esi * 4 + crc32ctab + 1024 * 7]
        movzx   esi, ah
        xor     edx, dword ptr[esi * 4 + crc32ctab + 1024 * 6]
        shr     eax, 16
        movzx   esi, al
        xor     edx, dword ptr[esi * 4 + crc32ctab + 1024 * 5]
        movzx   esi, ah
        xor     edx, dword ptr[esi * 4 + crc32ctab + 1024 * 4]
        add     ecx, 8
        jle     @bodyloop
        mov     eax, edx
@done:  mov     edx, edi
        pop     edi
        pop     esi
@bodydone:
        sub     ecx, 8
        jl      @tail
        pop     ebx
        not     eax
        ret
@tail:  movzx   ebx, byte[edx + ecx]
        xor     bl, al
        shr     eax, 8
        xor     eax, dword ptr[ebx * 4 + crc32ctab]
        inc     ecx
        jnz     @tail
        pop     ebx
        not     eax
end;
{$endif PUREPASCAL}

procedure InitializeCrc32ctab;
var
  i, n: integer;
  crc: cardinal;
begin
  // initialize tables for crc32cfast() and SymmetricEncrypt/FillRandom
  for i := 0 to 255 do begin
    crc := i;
    for n := 1 to 8 do
      if (crc and 1)<>0 then // polynom is not the same as with zlib's crc32()
        crc := (crc shr 1) xor $82f63b78 else
        crc := crc shr 1;
    crc32ctab[0,i] := crc;
  end;
  for i := 0 to 255 do begin
    crc := crc32ctab[0,i];
    for n := 1 to high(crc32ctab) do begin
      crc := (crc shr 8) xor crc32ctab[0,ToByte(crc)];
      crc32ctab[n,i] := crc;
    end;
  end;
end;

begin
  {$ifdef CPUINTEL}
  if SSE42Support then
  begin
    crc32c := @crc32csse42;
    mORMotHasher := @crc32csse42;
  end
  else
  {$endif CPUINTEL}
  {$ifdef CPULOONGARCH64}
  if True then
  begin
    crc32c := @crc32cloongarch;
    mORMotHasher := @crc32cloongarch;
  end
  else
  {$endif CPULOONGARCH64}
  begin
    InitializeCrc32ctab;
    crc32c := @crc32cfast;
    mORMotHasher := @{$IFDEF CPUINTEL}xxHash32{$ELSE}xxHash32Pascal{$ENDIF};
  end;
end.


{ Modified by Alexey Chernobaev on the conditions of the Mozilla Public License
  which covers the original code, v.030516.
  This is an extraction of some code from Unicode.pas (to decrease the size of
  applications which don't use Classes.pas).
  Original unit "Unicode.pas" was obtained from http://www.lischke-online.de;
  see also http://www.delphi-jedi.org.  See below the original copyright. }

unit VWideStr;

interface

{$I VCheck.inc}

uses
  NLSTypes;

// Copyright (c) 1999, 2000 Mike Lischke (public@lischke-online.de)
// Portions Copyright (c) 1999, 2000 Azret Botash (az)

function StrLenW(Str: PWideChar): Cardinal;
// returns number of characters in a string excluding the null terminator
function StrEndW(Str: PWideChar): PWideChar;
// returns a pointer to the end of a null terminated string
function StrMoveW(Dest, Source: PWideChar; Count: Cardinal): PWideChar;
// Copies the specified number of characters to the destination string and returns Dest
// also as result. Dest must have enough room to store at least Count characters.
function StrCopyW(Dest, Source: PWideChar): PWideChar;
// copies Source to Dest and returns Dest
function StrECopyW(Dest, Source: PWideChar): PWideChar;
// copies Source to Dest and returns a pointer to the null character ending the string
function StrLCopyW(Dest, Source: PWideChar; MaxLen: Cardinal): PWideChar;
// copies a specified maximum number of characters from Source to Dest
function StrPCopyW(Dest: PWideChar; Source: PChar): PWideChar;
// copies an ANSI string to a null-terminated wide string
function StrPLCopyW(Dest: PWideChar; Source: PChar; MaxLen: Cardinal): PWideChar;
// copies characters from an ANSI string into a null-terminated wide string
function StrCatW(Dest, Source: PWideChar): PWideChar;
// appends a copy of Source to the end of Dest and returns the concatenated string
function StrLCatW(Dest, Source: PWideChar; MaxLen: Cardinal): PWideChar;
// appends a specified maximum number of WideCharacters to string
function StrCompW(Str1, Str2: PWideChar): Integer;
// compares Str1 to Str2 (binary comparation)
// Note: There's also an extended comparation function which uses a given language to
//       compare unicode strings.
function StrICompW(Str1, Str2: PWideChar): Integer;
// compares Str1 to Str2 without case sensitivity (binary comparation),
// Note: only ANSI characters are compared case insensitively
function StrLCompW(Str1, Str2: PWideChar; MaxLen: Cardinal): Integer;
// compares a specified maximum number of charaters in two strings
function StrLICompW(Str1, Str2: PWideChar; MaxLen: Cardinal): Integer;
// compares strings up to a specified maximum number of characters, not case sensitive
// Note: only ANSI characters are compared case insensitively
function StrNScanW(S1, S2: PWideChar): Integer;
// determines where (in S1) the first time one of the characters of S2 appear.
// The result is the length of a string part of S1 where none of the characters of
// S2 do appear (not counting the trailing #0 and starting with position 0 in S1).
function StrRNScanW(S1, S2: PWideChar): Integer;
// This function does the same as StrRNScanW but uses S1 in reverse order. This
// means S1 points to the last // character of a string, is traveresed reversely
// and terminates with a starting #0.
// This is useful for parsing strings stored in reversed macro buffers etc.
function StrScanW(Str: PWideChar; Chr: WideChar): PWideChar;
// returns a pointer to first occurrence of a specified character in a string
function StrLScanW(Str: PWideChar; Chr: WideChar; StrLen: Cardinal): PWideChar;
// returns a pointer to first occurrence of a specified character in a string
// or nil if not found
// Note: this is just a binary search for the specified character and there's
// no check for a terminating null. Instead at most StrLen characters are
// searched. This makes this function extremly fast.
//
// on enter EAX contains Str, EDX contains Chr and ECX StrLen
// on exit EAX contains result pointer or nil
function StrRScanW(Str: PWideChar; Chr: WideChar): PWideChar;
// returns a pointer to the last occurance of Chr in Str
function StrPosW(Str, SubStr: PWideChar): PWideChar;
// returns a pointer to the first occurance of SubStr in Str

procedure StrSwapByteOrder(Str: PWideChar);
// exchanges in each character of the given string the low order and high order
// byte to go from LSB to MSB and vice versa.
// EAX contains address of string

// functions involving Delphi wide strings

function WideStringOfChar(C: WideChar; Count: Cardinal): WideString;

implementation

//----------------- functions for null terminated wide strings -----------------

function StrLenW(Str: PWideChar): Cardinal;
asm
         MOV EDX, EDI
         MOV EDI, EAX
         MOV ECX, 0FFFFFFFFH
         XOR AX, AX
         REPNE SCASW
         MOV EAX, 0FFFFFFFEH
         SUB EAX, ECX
         MOV EDI, EDX
end;

//------------------------------------------------------------------------------

function StrEndW(Str: PWideChar): PWideChar;
asm
         MOV EDX, EDI
         MOV EDI, EAX
         MOV ECX, 0FFFFFFFFH
         XOR AX, AX
         REPNE SCASW
         LEA EAX, [EDI - 2]
         MOV EDI, EDX
end;

//------------------------------------------------------------------------------

function StrMoveW(Dest, Source: PWideChar; Count: Cardinal): PWideChar;
asm
         PUSH ESI
         PUSH EDI
         MOV ESI, EDX
         MOV EDI, EAX
         MOV EDX, ECX
         CMP EDI, ESI
         JG @@1
         JE @@2
         SHR ECX, 1
         REP MOVSD
         MOV ECX, EDX
         AND ECX, 1
         REP MOVSW
         JMP @@2

@@1:     LEA ESI, [ESI + 2 * ECX - 2]
         LEA EDI, [EDI + 2 * ECX - 2]
         STD
         AND ECX, 1
         REP MOVSW
         SUB EDI, 2
         SUB ESI, 2
         MOV ECX, EDX
         SHR ECX, 1
         REP MOVSD
         CLD
@@2:     POP EDI
         POP ESI
end;

//------------------------------------------------------------------------------

function StrCopyW(Dest, Source: PWideChar): PWideChar;
asm
         PUSH EDI
         PUSH ESI
         MOV ESI, EAX
         MOV EDI, EDX
         MOV ECX, 0FFFFFFFFH
         XOR AX, AX
         REPNE SCASW
         NOT ECX
         MOV EDI, ESI
         MOV ESI, EDX
         MOV EDX, ECX
         MOV EAX, EDI
         SHR ECX, 1
         REP MOVSD
         MOV ECX, EDX
         AND ECX, 1
         REP MOVSW
         POP ESI
         POP EDI
end;

//------------------------------------------------------------------------------

function StrECopyW(Dest, Source: PWideChar): PWideChar;
asm
         PUSH EDI
         PUSH ESI
         MOV ESI, EAX
         MOV EDI, EDX
         MOV ECX, 0FFFFFFFFH
         XOR AX, AX
         REPNE SCASW
         NOT ECX
         MOV EDI, ESI
         MOV ESI, EDX
         MOV EDX, ECX
         SHR ECX, 1
         REP MOVSD
         MOV ECX, EDX
         AND ECX, 1
         REP MOVSW
         LEA EAX, [EDI - 2]
         POP ESI
         POP EDI
end;

//------------------------------------------------------------------------------

function StrLCopyW(Dest, Source: PWideChar; MaxLen: Cardinal): PWideChar; 
asm
         PUSH EDI
         PUSH ESI
         PUSH EBX
         MOV ESI, EAX
         MOV EDI, EDX
         MOV EBX, ECX
         XOR AX, AX
         TEST ECX, ECX
         JZ @@1
         REPNE SCASW
         JNE @@1
         INC ECX
@@1:     SUB EBX, ECX
         MOV EDI, ESI
         MOV ESI, EDX
         MOV EDX, EDI
         MOV ECX, EBX
         SHR ECX, 1
         REP MOVSD
         MOV ECX, EBX
         AND ECX, 1
         REP MOVSW
         STOSW
         MOV EAX, EDX
         POP EBX
         POP ESI
         POP EDI
end;

//------------------------------------------------------------------------------

function StrPCopyW(Dest: PWideChar; Source: PChar): PWideChar;
begin
  Result := StrPLCopyW(Dest, Source, Length(Source));
  Result[Length(Source)] := WideNull;
end;

//------------------------------------------------------------------------------

function StrPLCopyW(Dest: PWideChar; Source: PChar; MaxLen: Cardinal): PWideChar;
asm
       PUSH EDI
       PUSH ESI
       MOV EDI, EAX
       MOV ESI, EDX
       MOV EDX, EAX
       XOR AX, AX
@@1:   LODSB
       STOSW
       DEC ECX
       JNZ @@1
       MOV EAX, EDX
       POP ESI
       POP EDI
end;

//------------------------------------------------------------------------------

function StrCatW(Dest, Source: PWideChar): PWideChar;
begin
  StrCopyW(StrEndW(Dest), Source);
  Result := Dest;
end;

//------------------------------------------------------------------------------

function StrLCatW(Dest, Source: PWideChar; MaxLen: Cardinal): PWideChar;
asm
         PUSH EDI
         PUSH ESI
         PUSH EBX
         MOV EDI, Dest
         MOV ESI, Source
         MOV EBX, MaxLen
         SHL EBX, 1
         CALL StrEndW
         MOV ECX, EDI
         ADD ECX, EBX
         SUB ECX, EAX
         JBE @@1
         MOV EDX, ESI
         SHR ECX, 1
         CALL StrLCopyW
@@1:     MOV EAX, EDI
         POP EBX
         POP ESI
         POP EDI
end;

//------------------------------------------------------------------------------

function StrCompW(Str1, Str2: PWideChar): Integer;
asm
         PUSH EDI
         PUSH ESI
         MOV EDI, EDX
         MOV ESI, EAX
         MOV ECX, 0FFFFFFFFH
         XOR EAX, EAX
         REPNE SCASW
         NOT ECX
         MOV EDI, EDX
         XOR EDX, EDX
         REPE CMPSW
         MOV AX, [ESI - 2]
         MOV DX, [EDI - 2]
         SUB EAX, EDX
         POP ESI
         POP EDI
end;

//------------------------------------------------------------------------------

function StrICompW(Str1, Str2: PWideChar): Integer;
asm
         PUSH EDI
         PUSH ESI
         MOV EDI, EDX
         MOV ESI, EAX
         MOV ECX, 0FFFFFFFFH
         XOR EAX, EAX
         REPNE SCASW
         NOT ECX
         MOV EDI, EDX
         XOR EDX, EDX
@@1:     REPE CMPSW
         JE @@4
         MOV AX, [ESI - 2]
         CMP AX, 'a'
         JB @@2
         CMP AX, 'z'
         JA @@2
         SUB AL, 20H
@@2:     MOV DX, [EDI - 2]
         CMP DX, 'a'
         JB @@3
         CMP DX, 'z'
         JA @@3
         SUB DX, 20H
@@3:     SUB EAX, EDX
         JE @@1
@@4:     POP ESI
         POP EDI
end;

//------------------------------------------------------------------------------

function StrLCompW(Str1, Str2: PWideChar; MaxLen: Cardinal): Integer;
asm
         PUSH EDI
         PUSH ESI
         PUSH EBX
         MOV EDI, EDX
         MOV ESI, EAX
         MOV EBX, ECX
         XOR EAX, EAX
         OR ECX, ECX
         JE @@1
         REPNE SCASW
         SUB EBX, ECX
         MOV ECX, EBX
         MOV EDI, EDX
         XOR EDX, EDX
         REPE CMPSW
         MOV AX, [ESI - 2]
         MOV DX, [EDI - 2]
         SUB EAX, EDX
@@1:     POP EBX
         POP ESI
         POP EDI
end;

//------------------------------------------------------------------------------

function StrLICompW(Str1, Str2: PWideChar; MaxLen: Cardinal): Integer;
asm
         PUSH EDI
         PUSH ESI
         PUSH EBX
         MOV EDI, EDX
         MOV ESI, EAX
         MOV EBX, ECX
         XOR EAX, EAX
         OR ECX, ECX
         JE @@4
         REPNE SCASW
         SUB EBX, ECX
         MOV ECX, EBX
         MOV EDI, EDX
         XOR EDX, EDX
@@1:     REPE CMPSW
         JE @@4
         MOV AX, [ESI - 2]
         CMP AX, 'a'
         JB @@2
         CMP AX, 'z'
         JA @@2
         SUB AX, 20H
@@2:     MOV DX, [EDI - 2]
         CMP DX, 'a'
         JB @@3
         CMP DX, 'z'
         JA @@3
         SUB DX, 20H
@@3:     SUB EAX, EDX
         JE @@1
@@4:     POP EBX
         POP ESI
         POP EDI
end;

//------------------------------------------------------------------------------

function StrNScanW(S1, S2: PWideChar): Integer;
var
  Run: PWideChar;
begin
  Result := -1;
  if Assigned(S1) and Assigned(S2) then
  begin
    Run := S1;
    while (Run^ <> #0) do
    begin
      if StrScanW(S2, Run^) <> nil then Break;
      Inc(Run);
    end;
    Result := Run - S1;
  end;
end;

//------------------------------------------------------------------------------

function StrRNScanW(S1, S2: PWideChar): Integer;
var
  Run: PWideChar;
begin
  Result := -1;
  if Assigned(S1) and Assigned(S2) then
  begin
    Run := S1;
    while (Run^ <> #0) do
    begin
      if StrScanW(S2, Run^) <> nil then Break;
      Dec(Run);
    end;
    Result := S1 - Run;
  end;
end;

//------------------------------------------------------------------------------

function StrScanW(Str: PWideChar; Chr: WideChar): PWideChar;
asm
         PUSH EDI
         PUSH EAX
         MOV EDI, Str
         MOV ECX, 0FFFFFFFFH
         XOR AX, AX
         REPNE SCASW
         NOT ECX
         POP EDI
         MOV AX, Chr
         REPNE SCASW
         MOV EAX, 0
         JNE @@1
         MOV EAX, EDI
         SUB EAX, 2
@@1:     POP EDI
end;

//------------------------------------------------------------------------------

function StrLScanW(Str: PWideChar; Chr: WideChar; StrLen: Cardinal): PWideChar;
asm
         TEST EAX, EAX
         JZ @@Exit // get out if the string is nil or StrLen is 0
         JCXZ @@Exit
@@Loop:
         CMP [EAX], DX // this unrolled loop is actually faster on modern
         JE @@Exit     // processors than REP SCASW
         ADD EAX, 2
         DEC ECX
         JNZ @@Loop
         XOR EAX, EAX
@@Exit:
end;

//------------------------------------------------------------------------------

function StrRScanW(Str: PWideChar; Chr: WideChar): PWideChar;
asm
         PUSH EDI
         MOV EDI, Str
         MOV ECX, 0FFFFFFFFH
         XOR AX, AX
         REPNE SCASW
         NOT ECX
         STD
         SUB EDI, 2
         MOV AX, Chr
         REPNE SCASW
         MOV EAX, 0
         JNE @@1
         MOV EAX, EDI
         ADD EAX, 2
@@1:     CLD
         POP EDI
end;

//------------------------------------------------------------------------------

function StrPosW(Str, SubStr: PWideChar): PWideChar;
asm
         PUSH EDI
         PUSH ESI
         PUSH EBX
         OR EAX, EAX
         JZ @@2
         OR EDX, EDX
         JZ @@2
         MOV EBX, EAX
         MOV EDI, EDX
         XOR AX, AX
         MOV ECX, 0FFFFFFFFH
         REPNE SCASW
         NOT ECX
         DEC ECX
         JZ @@2
         MOV ESI, ECX
         MOV EDI, EBX
         MOV ECX, 0FFFFFFFFH
         REPNE SCASW
         NOT ECX
         SUB ECX, ESI
         JBE @@2
         MOV EDI, EBX
         LEA EBX, [ESI - 1] // Note: 2 would be wrong here, we are dealing with
@@1:                        // numbers not an address
         MOV ESI, EDX
         LODSW
         REPNE SCASW
         JNE @@2
         MOV EAX, ECX
         PUSH EDI
         MOV ECX, EBX
         REPE CMPSW
         POP EDI
         MOV ECX, EAX
         JNE @@1
         LEA EAX, [EDI - 2]
         JMP @@3
@@2:     XOR EAX, EAX
@@3:     POP EBX
         POP ESI
         POP EDI
end;

//------------------------------------------------------------------------------

procedure StrSwapByteOrder(Str: PWideChar);
asm
         PUSH ESI
         PUSH EDI
         MOV ESI, EAX
         MOV EDI, ESI
         XOR EAX, EAX // clear high order byte to be able to use 32bit operand below
@@1:     LODSW
         OR EAX, EAX
         JZ @@2
         XCHG AL, AH
         STOSW
         JMP @@1
@@2:     POP EDI
         POP ESI
end;

//------------------------------------------------------------------------------

function WideStringOfChar(C: WideChar; Count: Cardinal): WideString;
var
  I: Integer;
begin
  SetLength(Result, Count);
  for I := 1 to Count do Result[I] := C;
end;

end.

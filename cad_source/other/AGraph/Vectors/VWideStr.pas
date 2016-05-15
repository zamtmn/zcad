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
function StrScanW(Str: PWideChar; Chr: WideChar): PWideChar;
// returns a pointer to first occurrence of a specified character in a string


implementation

//----------------- functions for null terminated wide strings -----------------

function StrLenW(Str: PWideChar): Cardinal;
asm
         {MOV EDX, EDI
         MOV EDI, EAX
         MOV ECX, 0FFFFFFFFH
         XOR AX, AX
         REPNE SCASW
         MOV EAX, 0FFFFFFFEH
         SUB EAX, ECX
         MOV EDI, EDX}{by zcad}
end;

//------------------------------------------------------------------------------

function StrEndW(Str: PWideChar): PWideChar;
asm
         {MOV EDX, EDI
         MOV EDI, EAX
         MOV ECX, 0FFFFFFFFH
         XOR AX, AX
         REPNE SCASW
         LEA EAX, [EDI - 2]
         MOV EDI, EDX}{by zcad}
end;


//------------------------------------------------------------------------------

function StrScanW(Str: PWideChar; Chr: WideChar): PWideChar;
asm
         {PUSH EDI
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
@@1:     POP EDI}{by zcad}
end;




end.

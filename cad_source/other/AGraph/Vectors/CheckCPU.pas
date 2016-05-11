{ Version 000922. Copyright © Alexey A.Chernobaev, 1996-2000 }

unit CheckCPU;

interface

{$I VCheck.inc}

const
  MMXCPU: Boolean = False; { Intel MMX extensions }
  Yes_3DNow: Boolean = False; { 3DNow! technology (AMD K6-2, etc.) }
{$IFDEF V_32}
{$IFDEF V_PLATFORM_I386}
  CPUString: ShortString = 'Unknown CPU ';
  { possible values: 'GenuineIntel', 'AuthenticAMD', 'CyrixInstead', etc. }
{$ENDIF}
{$ENDIF}

implementation

{$IFDEF V_32}
{$IFDEF V_PLATFORM_I386}
procedure DetectAdvanced; assembler;
asm
      push     ebx
      pushfd
      pop      eax
      mov      edx, eax
      xor      eax, 00200000h
      push     eax
      popfd
      pushfd
      pop      eax
      xor      eax, edx
      jz       @@Exit          // CPU can't run CPUID
      xor      eax, eax        // function 0
      db       0Fh, 0A2h       // CPUID instruction
      lea      eax, CPUString + 1
      mov      [eax], ebx
      mov      [eax + 4], edx
      mov      [eax + 8], ecx
      mov      eax, 1          // function 1
      db       0Fh, 0A2h
      test     edx, 00800000h  // Check IA MMX technology bit (Bit 23 of EDX)
      jz       @@Exit
      mov      MMXCPU, 1
      mov      eax, 80000001h  // extended function 1
      db       0Fh, 0A2h
      test     edx, 80000000h  // 3DNow! technology bit
      jz       @@Exit
      mov      Yes_3DNow, 1
@@Exit:
      pop      ebx
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};

initialization
  DetectAdvanced;
{$ENDIF}
{$ENDIF}
end.

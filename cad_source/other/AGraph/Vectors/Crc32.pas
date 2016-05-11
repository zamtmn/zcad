unit Crc32;
{
  This unit is based on the code mentioned below. Adaptation for Delphi and
  assembler code: A.Chernobaev, 1997-2004 (v.040621).
}

interface

{$I VCheck.inc}

uses
  ExtType;

{$R-,Q-}

function UpdateByteCrc32(CurByte: Byte; CurCrc: Int32): Int32;

function UpdateCrc32(InitCRC: Int32; const InBuf; InLen: Integer): Int32;

function GetCrc32(InitCRC: Int32; const InBuf; InLen: Integer): Int32;

(*
  This CRC-32 routine and tables were converted from code discovered
  in the DEZIP.PAS V2.0 by R. P. Byrne.  The comments there are:

  Converted to Turbo Pascal (tm) V4.0 March, 1988 by J.R.Louvau
  COPYRIGHT (C) 1986 Gary S. Brown.  You may use this program, or
  code or tables extracted from it, as desired without restriction.

  First, the polynomial itself and its table of feedback terms.  The
  polynomial is
  X^32+X^26+X^23+X^22+X^16+X^12+X^11+X^10+X^8+X^7+X^5+X^4+X^2+X^1+X^0

  Note that we take it "backwards" and put the highest-order term in
  the lowest-order bit.  The X^32 term is "implied" the LSB is the
  X^31 term, etc.  The X^0 term (usually shown as "+1") results in
  the MSB being 1.

  Note that the usual hardware shift register implementation, which
  is what we're using (we're merely optimizing it by doing eight-bit
  chunks at a time) shifts bits into the lowest-order term.  In our
  implementation, that means shifting towards the right.  Why do we
  do it this way?  Because the calculated CRC must be transmitted in
  order from highest-order term to lowest-order term.  UARTs transmit
  characters in order from LSB to MSB.  By storing the CRC this way,
  we hand it to the UART in the order low-byte to high-byte the UART
  sends each low-bit to high-bit and the result is transmission bit
  by bit from highest- to lowest-order term without requiring any bit
  shuffling on our part.  Reception works similarly.

  The feedback terms table consists of 256, 32-bit entries.  Notes:

      The table can be generated at runtime if desired code to do so
      is shown later.  It might not be obvious, but the feedback
      terms simply represent the results of eight shift/xor opera-
      tions for all combinations of data and CRC register values.

      The values must be right-shifted by eight bits by the "updcrc"
      logic the shift must be unsigned (bring in zeroes).  On some
      hardware you could probably optimize the shift in assembler by
      using byte-swap instructions.
      polynomial $edb88320

  <End of Pascal version comments>

  The Pascal logic is:

  Function UpdC32(Octet: Byte; Crc: Int32) : Int32;
  Begin
    UpdC32:=CRC_32_TAB[Byte(Crc XOR Int32(Octet))] XOR ((Crc SHR 8) AND $00FFFFFF);
  End {UpdC32};

  This routine computes the 32 bit CRC used by PKZIP and its derivatives,
  and by Chuck Forsberg's "ZMODEM" protocol.  The block CRC computation
  should start with high-values (0ffffffffh), and finish by inverting all
  bits. *)

implementation

const
  Crc32Tab: array [0..255] of {$IFDEF V_D4}Cardinal{$ELSE}Int32{$ENDIF} = (
    $000000000, $077073096, $0ee0e612c, $0990951ba,
    $0076dc419, $0706af48f, $0e963a535, $09e6495a3,
    $00edb8832, $079dcb8a4, $0e0d5e91e, $097d2d988,
    $009b64c2b, $07eb17cbd, $0e7b82d07, $090bf1d91,

    $01db71064, $06ab020f2, $0f3b97148, $084be41de,
    $01adad47d, $06ddde4eb, $0f4d4b551, $083d385c7,
    $0136c9856, $0646ba8c0, $0fd62f97a, $08a65c9ec,
    $014015c4f, $063066cd9, $0fa0f3d63, $08d080df5,

    $03b6e20c8, $04c69105e, $0d56041e4, $0a2677172,
    $03c03e4d1, $04b04d447, $0d20d85fd, $0a50ab56b,
    $035b5a8fa, $042b2986c, $0dbbbc9d6, $0acbcf940,
    $032d86ce3, $045df5c75, $0dcd60dcf, $0abd13d59,

    $026d930ac, $051de003a, $0c8d75180, $0bfd06116,
    $021b4f4b5, $056b3c423, $0cfba9599, $0b8bda50f,
    $02802b89e, $05f058808, $0c60cd9b2, $0b10be924,
    $02f6f7c87, $058684c11, $0c1611dab, $0b6662d3d,

    $076dc4190, $001db7106, $098d220bc, $0efd5102a,
    $071b18589, $006b6b51f, $09fbfe4a5, $0e8b8d433,
    $07807c9a2, $00f00f934, $09609a88e, $0e10e9818,
    $07f6a0dbb, $0086d3d2d, $091646c97, $0e6635c01,

    $06b6b51f4, $01c6c6162, $0856530d8, $0f262004e,
    $06c0695ed, $01b01a57b, $08208f4c1, $0f50fc457,
    $065b0d9c6, $012b7e950, $08bbeb8ea, $0fcb9887c,
    $062dd1ddf, $015da2d49, $08cd37cf3, $0fbd44c65,

    $04db26158, $03ab551ce, $0a3bc0074, $0d4bb30e2,
    $04adfa541, $03dd895d7, $0a4d1c46d, $0d3d6f4fb,
    $04369e96a, $0346ed9fc, $0ad678846, $0da60b8d0,
    $044042d73, $033031de5, $0aa0a4c5f, $0dd0d7cc9,

    $05005713c, $0270241aa, $0be0b1010, $0c90c2086,
    $05768b525, $0206f85b3, $0b966d409, $0ce61e49f,
    $05edef90e, $029d9c998, $0b0d09822, $0c7d7a8b4,
    $059b33d17, $02eb40d81, $0b7bd5c3b, $0c0ba6cad,

    $0edb88320, $09abfb3b6, $003b6e20c, $074b1d29a,
    $0ead54739, $09dd277af, $004db2615, $073dc1683,
    $0e3630b12, $094643b84, $00d6d6a3e, $07a6a5aa8,
    $0e40ecf0b, $09309ff9d, $00a00ae27, $07d079eb1,

    $0f00f9344, $08708a3d2, $01e01f268, $06906c2fe,
    $0f762575d, $0806567cb, $0196c3671, $06e6b06e7,
    $0fed41b76, $089d32be0, $010da7a5a, $067dd4acc,
    $0f9b9df6f, $08ebeeff9, $017b7be43, $060b08ed5,

    $0d6d6a3e8, $0a1d1937e, $038d8c2c4, $04fdff252,
    $0d1bb67f1, $0a6bc5767, $03fb506dd, $048b2364b,
    $0d80d2bda, $0af0a1b4c, $036034af6, $041047a60,
    $0df60efc3, $0a867df55, $0316e8eef, $04669be79,

    $0cb61b38c, $0bc66831a, $0256fd2a0, $05268e236,
    $0cc0c7795, $0bb0b4703, $0220216b9, $05505262f,
    $0c5ba3bbe, $0b2bd0b28, $02bb45a92, $05cb36a04,
    $0c2d7ffa7, $0b5d0cf31, $02cd99e8b, $05bdeae1d,

    $09b64c2b0, $0ec63f226, $0756aa39c, $0026d930a,
    $09c0906a9, $0eb0e363f, $072076785, $005005713,
    $095bf4a82, $0e2b87a14, $07bb12bae, $00cb61b38,
    $092d28e9b, $0e5d5be0d, $07cdcefb7, $00bdbdf21,

    $086d3d2d4, $0f1d4e242, $068ddb3f8, $01fda836e,
    $081be16cd, $0f6b9265b, $06fb077e1, $018b74777,
    $088085ae6, $0ff0f6a70, $066063bca, $011010b5c,
    $08f659eff, $0f862ae69, $0616bffd3, $0166ccf45,

    $0a00ae278, $0d70dd2ee, $04e048354, $03903b3c2,
    $0a7672661, $0d06016f7, $04969474d, $03e6e77db,
    $0aed16a4a, $0d9d65adc, $040df0b66, $037d83bf0,
    $0a9bcae53, $0debb9ec5, $047b2cf7f, $030b5ffe9,

    $0bdbdf21c, $0cabac28a, $053b39330, $024b4a3a6,
    $0bad03605, $0cdd70693, $054de5729, $023d967bf,
    $0b3667a2e, $0c4614ab8, $05d681b02, $02a6f2b94,
    $0b40bbe37, $0c30c8ea1, $05a05df1b, $02d02ef8d);

function UpdateByteCrc32(CurByte: Byte; CurCrc: Int32): Int32;
begin
  Result:=Int32(Crc32Tab[Byte(CurCrc) xor CurByte]) xor
    ((CurCrc shr 8){ and $00FFFFFF});
end;

function UpdateCrc32(InitCRC: Int32; const InBuf; InLen: Integer): Int32;
{$IFNDEF USE_ASM}
var
  I: Integer;
begin
  for I:=0 to InLen - 1 do
    InitCRC:=Int32(Crc32Tab[Byte(InitCRC) xor TUInt8Array(InBuf)[I]]) xor
      ((InitCRC shr 8){ and $00FFFFFF});
  Result:=InitCRC;
end;
{$ELSE} assembler;
asm
{$IFNDEF V_32}
         mov    ax, ds
         push   ax
         mov    es, ax
         lds    si, Inbuf
         mov    ax, word ptr InitCRC
         mov    dx, word ptr InitCRC + 2
         mov    cx, Inlen
         jcxz   @@Exit
         cld
@@Loop:  xor    bh, bh
         mov    bl, al
         lodsb
         xor    bl, al
         mov    al, ah
         mov    ah, dl
         mov    dl, dh
         xor    dh, dh
         shl    bx, 2
         xor    ax, word ptr es:[bx + Crc32Tab]
         xor    dx, word ptr es:[bx + Crc32Tab + 2]
         dec    cx
         jnz    @@Loop
@@Exit:
         pop    ds
{$ELSE}  // eax = InitCRC; edx = @InBuf; ecx = InLen
         {$IFDEF V_FREEPASCAL}
         mov    eax, InitCRC
         mov    ecx, InLen
         mov    edx, InBuf
         {$ENDIF}
         or     ecx, ecx
         jle    @@Exit
         push   edi
         push	  ebx
         mov    edi, ecx
         xor    ebx, ebx
         shr    edi, 3
         jz     @@ByteOp
         push   esi
         push   ecx
         mov    esi, edx
         mov    bl, al
@@Loop1:
         mov    edx, [esi]
         shr    eax, 8
         mov    ecx, [esi + 4]
         xor    bl, dl
         xor    eax, dword ptr [ebx * 4 + Crc32Tab] // 1

         xor    dh, al
         shr    eax, 8
         mov    bl, dh
         xor    eax, dword ptr [ebx * 4 + Crc32Tab] // 2

         shr    edx, 16
         mov    bl, al
         shr    eax, 8
         xor    bl, dl
         shr    edx, 8
         xor    eax, dword ptr [ebx * 4 + Crc32Tab] // 3

         xor    dl, al
         shr    eax, 8
         xor    eax, dword ptr [edx * 4 + Crc32Tab] // 4

         mov    bl, al
         shr    eax, 8
         xor    bl, cl
         xor    eax, dword ptr [ebx * 4 + Crc32Tab] // 5

         xor    ch, al
         shr    eax, 8
         mov    bl, ch
         xor    eax, dword ptr [ebx * 4 + Crc32Tab] // 6

         shr    ecx, 16
         mov    bl, al
         shr    eax, 8
         xor    bl, cl
         shr    ecx, 8
         xor    eax, dword ptr [ebx * 4 + Crc32Tab] // 7

         xor    cl, al
         shr    eax, 8
         xor    eax, dword ptr [ecx * 4 + Crc32Tab] // 8

         add    esi, 8
         mov    bl, al
         dec    edi
         jnz    @@Loop1
         mov    edx, esi
         pop    ecx
         pop    esi
@@ByteOp:
         and    ecx, 7
         jz     @@Done
@@Loop2:
         xor    al, [edx]
         mov    bl, al
         shr    eax, 8
         inc    edx
         xor    eax, dword ptr [ebx * 4 + Crc32Tab]
         dec    ecx
         jnz    @@Loop2
@@Done:
         pop	  ebx
         pop    edi
@@Exit:
{$ENDIF}
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function GetCrc32(InitCRC: Int32; const InBuf; InLen: Integer): Int32;
begin
  Result:=not UpdateCrc32(not InitCRC, InBuf, InLen);
end;

end.

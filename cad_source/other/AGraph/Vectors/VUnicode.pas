{ Modified by Alexey Chernobaev on the conditions of Mozilla Public License
  which covers the original code, v.050625.
  This is an extraction of some code from Unicode.pas (to decrease the size of
  applications which don't use Classes.pas).
  Original unit "Unicode.pas" was obtained from http://www.lischke-online.de;
  see also http://www.delphi-jedi.org. See below the original copyright. }

unit VUnicode;

interface

{$I VCheck.inc}

{$IFNDEF V_D4}
  {$DEFINE USE_VECTORS}
{$ENDIF}

{$IFDEF V_D6}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF}

uses
  {$IFDEF V_WIN}Windows,{$ENDIF}{$IFDEF LINUX}Libc, Types,{$ENDIF}
  SysUtils, ExtSys, {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF},
  NLSTypes, VectStr, VWideStr{$IFDEF USE_VECTORS}, UInt16v, UInt32v{$ENDIF};

// Copyright (c) 1999, 2000 Mike Lischke (public@lischke-online.de)
// Portions Copyright (c) 1999, 2000 Azret Botash (az)
//
// 01-APR-2000 ml:
//   preparation for public release
// FEB-MAR 2000 version 2.0 beta
//   - Unicode regular expressions (URE) search class (TURESearch)
//   - generic search engine base class for both the Boyer-Moore and the RE
//     search class
//   - whole word only search in UTBM, bug fixes in UTBM
//   - string decompositon (including hangul)
// OCT/99 - JAN/2000 ml: version 1.0
//   - basic Unicode implementation, more than 100 WideString/UCS2 and UCS4 core
//     functions
//   - TWideStrings and TWideStringList classes
//   - Unicode Tuned Boyer-Moore search class (TUTBMSearch)
//   - low and high level Unicode/Wide* functions
//   - low level Unicode UCS4 data import and functions
//   - helper functions
//------------------------------------------------------------------------------
// This unit contains routines and classes to manage and work with Unicode /
// WideStrings strings.
// You need Delphi 4 or higher to compile this code.
//
// Unicode encodings and wide strings:
// Currently there are several encoding schemes defined which describe (among
// others) the code size and (resulting from this) the usable value pool. Delphi
// supports the wide character data type for Unicode which corresponds to UCS2
// (UTF-16 coding scheme). This scheme uses 2 bytes to store character values
// and can therefor handle up to 65536 characters. Another scheme is UCS4
// (UTF-32 coding scheme) which uses 4 bytes per character. The first 65536 code
// points correspond directly to those of UCS2. Other code points are mainly
// used for character surrogates. To provide support for UCS2 (WideChar in
// Delphi) as well as UCS4 the library is splitted into two parts. The low level
// part accepts and returns UCS4 characters while the high level part deals
// directly with WideChar/WideString data types. Additionally, UCS2 is defined
// as being WideChar to retain maximum compatibility.
//
// Publicy available low level functions are all preceded by "Unicode..." (e.g.
// in UnicodeToUpper) while
// the high level functions use the Str... or Wide... naming scheme (e.g.
// WideUpCase and WideUpperCase).
//
//------------------------------------------------------------------------------
// Open issues:
//   - Keep in mind that this unit is still in beta state. In particular the URE
//     class does not yet work for all cases.
//   - Yet to do things in the URE class are:
//     - check all character classes if they match correctly
//     - optimize rebuild of DFA (build only when pattern changes)
//     - set flag parameter of ExecuteURE
//     - add \d     any decimal digit
//           \D     any character that is not a decimal digit
//           \s     any whitespace character
//           \S     any character that is not a whitespace character
//           \w     any "word" character
//           \W     any "non-word" character
//   - For a perfect text search both the text to be searched through as well as
//     the pattern must be normalized to allow to match, say, accented and
//     unaccented characters or the ligature fi with the letter combination fi
//     etc.
//     Normalization is usually done by decomposing the string and optionally
//     compose it again, but I had not yet the opportunity to go through the
//     composition stuff.
//   - The wide string classes still compare text with functions provided by the
//     particular system. This works usually fine under WinNT/W2K (although also
//     there are limitations like maximum text lengths). Under Win9x conversions
//     from and to MBCS are necessary which are bound to a particular locale and
//     so very limited in general use.
//     These comparisons should be changed so that the code in this unit is used.
//     This requires, though, a working composition implementation.

// low level character routines

function UnicodeToUpper(Code: UCS4): UCS4;
function UnicodeToLower(Code: UCS4): UCS4;
function UnicodeToTitle(Code: UCS4): UCS4;

// character test routines

{$IFDEF V_INLINE}
function IsProperty(Code, Mask1, Mask2: Cardinal): Boolean;
{$ENDIF}

function UnicodeIsAlpha(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character alphabetic?
function UnicodeIsDigit(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a digit?
function UnicodeIsAlphaNum(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character alphabetic or a number?
function UnicodeIsControl(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a control character?
function UnicodeIsSpace(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a spacing character?
function UnicodeIsWhiteSpace(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a white space character (same as UnicodeIsSpace plus
// tabulator, new line etc.)?
function UnicodeIsBlank(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a space separator?
function UnicodeIsPunctuation(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a punctuation mark?
function UnicodeIsGraph(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character graphical?
function UnicodeIsPrintable(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character printable?
function UnicodeIsUpper(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character already upper case?
function UnicodeIsLower(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character already lower case?
function UnicodeIsTitle(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character already title case?
function UnicodeIsHexDigit(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a hex digit?

function UnicodeIsIsoControl(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a C0 control character (< 32)?
function UnicodeIsFormatControl(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a format control character?

function UnicodeIsSymbol(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a symbol?
function UnicodeIsNumber(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a number or digit?
function UnicodeIsNonSpacing(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character non-spacing?
function UnicodeIsOpenPunctuation(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character an open/left punctuation (i.e. '[')?
function UnicodeIsClosePunctuation(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character an close/right punctuation (i.e. ']')?
function UnicodeIsInitialPunctuation(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character an initial punctuation (i.e. U+2018 LEFT SINGLE QUOTATION MARK)?
function UnicodeIsFinalPunctuation(C: UCS4): Boolean;
// Is the character a final punctuation (i.e. U+2019 RIGHT SINGLE QUOTATION MARK)?

function UnicodeIsComposite(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Can the character be decomposed into a set of other characters?
function UnicodeIsQuotationMark(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character one of the many quotation marks?
function UnicodeIsSymmetric(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character one that has an opposite form (i.e. <>)?
function UnicodeIsMirroring(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character mirroring (superset of symmetric)?
function UnicodeIsNonBreaking(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character non-breaking (i.e. non-breaking space)?

// Directionality functions

function UnicodeIsRTL(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Does the character have strong right-to-left directionality (i.e. Arabic letters)?
function UnicodeIsLTR(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Does the character have strong left-to-right directionality (i.e. Latin letters)?
function UnicodeIsStrong(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Does the character have strong directionality?
function UnicodeIsWeak(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Does the character have weak directionality (i.e. numbers)?
function UnicodeIsNeutral(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Does the character have neutral directionality (i.e. whitespace)?
function UnicodeIsSeparator(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a block or segment separator?

// Other character test functions

function UnicodeIsMark(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a mark of some kind?
function UnicodeIsModifier(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a modifier letter?
function UnicodeIsLetterNumber(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a number represented by a letter?
function UnicodeIsConnectionPunctuation(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character connecting punctuation?
function UnicodeIsDash(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a dash punctuation?
function UnicodeIsMath(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a math character?
function UnicodeIsCurrency(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a currency character?
function UnicodeIsModifierSymbol(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a modifier symbol?
function UnicodeIsNonSpacingMark(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a non-spacing mark?
function UnicodeIsSpacingMark(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a spacing mark?
function UnicodeIsEnclosing(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character enclosing (i.e. enclosing box)?
function UnicodeIsPrivate(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character from the Private Use Area?
function UnicodeIsSurrogate(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character one of the surrogate codes?
function UnicodeIsLineSeparator(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a line separator?
function UnicodeIsParagraphSeparator(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is th character a paragraph separator;

function UnicodeIsIdentifierStart(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Can the character begin an identifier?
function UnicodeIsIdentifierPart(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Can the character appear in an identifier?

function UnicodeIsDefined(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character defined (appears in one of the data files)?
function UnicodeIsUndefined(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character not defined (non-Unicode)?

function UnicodeIsHan(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a Han ideograph?
function UnicodeIsHangul(C: UCS4): Boolean; {$IFDEF V_INLINE}inline;{$ENDIF}
// Is the character a pre-composed Hangul syllable?

// functions involving Null-terminated strings
// NOTE: PWideChars as well as WideStrings are NOT managed by reference counting
// (in opposition to 8 bit strings)!

function StrUpperW(Str: PWideChar): PWideChar;
// converts Str to upper case and returns it
function StrLowerW(Str: PWideChar): PWideChar;
// converts Str to lower case and returns it
function StrTitleW(Str: PWideChar): PWideChar;
// converts Str to title case and returns it

// functions involving Delphi wide strings

function WideAdjustLineBreaks(const W: WideString): WideString;
// replaces CR/LF with CR-LF
function WideLoCase(C: WideChar): WideChar; {$IFDEF V_INLINE}inline;{$ENDIF}
function WideLowerCase(const S: WideString): WideString;
function WideQuotedStr(const S: WideString; Quote: WideChar): WideString;
// works like QuotedStr from SysUtils.pas but can insert any quotation character
function WideExtractQuotedStr(const S: WideString; Quote: WideChar): WideString;
// extracts a string enclosed in quote characters given by Quote
function WideTitleCaseChar(C: WideChar): WideChar;
function WideTitleCaseString(const S: WideString): WideString;
function WideTrim(const S: WideString): WideString;
function WideTrimLeft(const S: WideString): WideString;
function WideTrimRight(const S: WideString): WideString;
function WideUpCase(C: WideChar): WideChar; {$IFDEF V_INLINE}inline;{$ENDIF}
function WideUpperCase(const S: WideString): WideString;

// new (alexch)

function UnicodeToUpperFast(W: WideChar): WideChar;
{ fast UnicodeToUpper (by table) }
function UnicodeToLowerFast(W: WideChar): WideChar;
{ fast UnicodeToLower (by table) }
procedure WideUpperBuf(Buf: PWideChar; Count: Integer);
{ converts Buf with Count wide characters to upper case }
procedure WideLowerBuf(Buf: PWideChar; Count: Integer);
{ converts Buf with Count wide characters to lower case }
function CompareTextBufWide(PW1, PW2: PWideChar; Count1, Count2: Integer): Integer;
function CompareTextWide(const W1, W2: WideString): Integer;
{ compares strings case insensitively (i.e. converting them to uppercase) }

{$IFDEF V_WIN}
var
  SystemIndependent_lstrcmpiW: function (PW1, PW2: PWideChar): Integer; stdcall;
  SystemIndependent_CompareStringW: function (Locale: LCID; Flags: DWORD;
    PW1: PWideChar; L1: Integer; PW2: PWideChar; L2: Integer): Integer; stdcall;

function Emulate_lstrcmpiW(PW1, PW2: PWideChar): Integer; stdcall;
function Emulate_CompareStringW(Locale: LCID; Flags: DWORD;
  PW1: PWideChar; L1: Integer; PW2: PWideChar; L2: Integer): Integer; stdcall;
{ emulates lstrcmpiW and CompareStringW API functions on Win 9x systems }
{$ENDIF}

{$IFNDEF V_INLINE}
implementation
{$ENDIF}

const
  // Values that can appear in the Mask1 parameter of the IsProperty function.
  UC_MN = $00000001; // Mark, Non-Spacing
  UC_MC = $00000002; // Mark, Spacing Combining
  UC_ME = $00000004; // Mark, Enclosing
  UC_ND = $00000008; // Number, Decimal Digit
  UC_NL = $00000010; // Number, Letter
  UC_NO = $00000020; // Number, Other
  UC_ZS = $00000040; // Separator, Space
  UC_ZL = $00000080; // Separator, Line
  UC_ZP = $00000100; // Separator, Paragraph
  UC_CC = $00000200; // Other, Control
  UC_CF = $00000400; // Other, Format
  UC_OS = $00000800; // Other, Surrogate
  UC_CO = $00001000; // Other, private use
  UC_CN = $00002000; // Other, not assigned
  UC_LU = $00004000; // Letter, Uppercase
  UC_LL = $00008000; // Letter, Lowercase
  UC_LT = $00010000; // Letter, Titlecase
  UC_LM = $00020000; // Letter, Modifier
  UC_LO = $00040000; // Letter, Other
  UC_PC = $00080000; // Punctuation, Connector
  UC_PD = $00100000; // Punctuation, Dash
  UC_PS = $00200000; // Punctuation, Open
  UC_PE = $00400000; // Punctuation, Close
  UC_PO = $00800000; // Punctuation, Other
  UC_SM = $01000000; // Symbol, Math
  UC_SC = $02000000; // Symbol, Currency
  UC_SK = $04000000; // Symbol, Modifier
  UC_SO = $08000000; // Symbol, Other
  UC_L  = $10000000; // Left-To-Right
  UC_R  = $20000000; // Right-To-Left
  UC_EN = $40000000; // European Number
  UC_ES = $80000000; // European Number Separator

  // Values that can appear in the Mask2 parameter of the IsProperty function
  UC_ET = $00000001; // European Number Terminator
  UC_AN = $00000002; // Arabic Number
  UC_CS = $00000004; // Common Number Separator
  UC_B  = $00000008; // Block Separator
  UC_S  = $00000010; // Segment (unit) Separator (this includes tab and vert. tab)
  UC_WS = $00000020; // Whitespace
  UC_ON = $00000040; // Other Neutrals

  // Implementation specific character properties.
  UC_CM = $00000080; // Composite
  UC_NB = $00000100; // Non-Breaking
  UC_SY = $00000200; // Symmetric
  UC_HD = $00000400; // Hex Digit
  UC_QM = $00000800; // Quote Mark
  UC_MR = $00001000; // Mirroring
  UC_SS = $00002000; // Space, other

  UC_CP = $00004000; // Defined

  // Added for UnicodeData-2.1.3.
  UC_PI = $00008000; // Punctuation, Initial
  UC_PF = $00010000; // Punctuation, Final

{$IFDEF V_INLINE}
implementation
{$ENDIF}

{$IFDEF LINUX}
{$R VUnicode.lres}
{$ELSE}
{$R VUnicode.res}
{$ENDIF}

//----------------- support for character properties ---------------------------

type
  TUHeader = packed record
    Count: Word;
    case Boolean of
      True:
        (Bytes: Cardinal);
      False:
        (Len: array[0..1] of Word);
  end;

  {$IFNDEF USE_VECTORS}
  TWordArray = array of Word;
  TCardinalArray = array of Cardinal;
  {$ENDIF}

{$IFDEF MULTI_THREAD}
var
  // As the global data can be accessed by several threads it should be guarded
  // while the data is loaded.
  LoadInProgress: TRTLCriticalSection;
{$ENDIF}

//----------------- support for character properties ---------------------------
var
  {$IFNDEF USE_VECTORS}
  PropertyOffsets: TWordArray;
  PropertyRanges: TCardinalArray;
  {$ELSE}
  PropertyOffsets: TUInt16Vector = nil;
  PropertyRanges: TUInt32Vector = nil;
  {$ENDIF}

procedure LoadUnicodeTypeData;
// loads the character property data (as saved by the Unicode database extractor
// into the ctype.dat file)
var
  I, Size: Integer;
  Header: TUHeader;
  Stream: TVMemStream;
  HGlobal, HResInfo: THandle;
begin
  // make sure no other code is currently modifying the global data area
  {$IFDEF MULTI_THREAD}
  EnterCriticalSection(LoadInProgress);
  try
  {$ENDIF}
    // Data already loaded?
    if PropertyOffsets = nil then begin
      Stream:=TVMemStream.Create;
      try
        HResInfo:=FindResource(HInstance, 'UNI_TYPE', RT_RCDATA);
        OSCheck(HResInfo <> 0);
        HGlobal:=LoadResource(HInstance, HResInfo);
        OSCheck(HGlobal <> 0);
        try
          Stream.WriteProc(LockResource(HGlobal)^, SizeOfResource(HInstance, HResInfo));
        finally
          FreeResource(HGlobal);
        end;
        Stream.Seek(0);

        Stream.ReadProc(Header, SizeOf(Header));

        // Calculate the offset into the storage for the ranges.  The offsets
        // array is on a 4-byte boundary and one larger than the value provided
        // in the header count field. This means the offset to the ranges must
        // be calculated after aligning the count to a 4-byte boundary.
        Size:=(Header.Count + 1) * SizeOf(Word);
        if Size and 3 <> 0 then
          Inc(Size, 4 - Size and 3);

        // fill offsets array
        {$IFNDEF USE_VECTORS}
        SetLength(PropertyOffsets, Size div SizeOf(Word));
        Stream.ReadProc(PropertyOffsets[0], Size);
        {$ELSE}
        PropertyOffsets:=TUInt16Vector.Create(Size div SizeOf(Word), 0);
        Stream.ReadProc(PropertyOffsets.Memory^, Size);
        {$ENDIF}

        // Load the ranges. The number of elements is in the last array position
        // of the offsets.
        I:=PropertyOffsets[Header.Count];
        {$IFNDEF USE_VECTORS}
        SetLength(PropertyRanges, I);
        Stream.ReadProc(PropertyRanges[0], I * SizeOf(Cardinal));
        {$ELSE}
        PropertyRanges:=TUInt32Vector.Create(I, 0);
        Stream.ReadProc(PropertyRanges.Memory^, I * SizeOf(Cardinal));
        {$ENDIF}
      finally
        Stream.Free;
      end;
    end;
  {$IFDEF MULTI_THREAD}
  finally
    LeaveCriticalSection(LoadInProgress);
  end;
  {$ENDIF}
end;

//------------------------------------------------------------------------------

function PropertyLookup(Code, N: Cardinal): Boolean;
var
  L, R, M, Limit: Integer;
begin
  // load property data if not already done
  if PropertyOffsets = nil then
    LoadUnicodeTypeData;

  Result:=False;
  // There is an extra node on the end of the offsets to allow this routine
  // to work right.  If the index is 0xffff, then there are no nodes for the property.
  L:=PropertyOffsets[N];
  if L <> $FFFF then begin
    // Locate the next offset that is not 0xffff.  The sentinel at the end of
    // the array is the max index value.
    M:=1;
    {$IFNDEF USE_VECTORS}
    Limit:=High(PropertyOffsets);
    {$ELSE}
    Limit:=PropertyOffsets.Count - 1;
    {$ENDIF}
    while ((Integer(N) + M) < Limit) and
      (PropertyOffsets[Integer(N) + M] = $FFFF) do Inc(M);

    R:=PropertyOffsets[Integer(N) + M] - 1;

    while L <= R do begin
      // Determine a "mid" point and adjust to make sure the mid point is at
      // the beginning of a range pair.
      M:=(L + R) shr 1;
      Dec(M, M and 1);
      if Code > PropertyRanges[M + 1] then
        L:=M + 2
      else
        if Code < PropertyRanges[M] then
          R:=M - 2
        else
          if (Code >= PropertyRanges[M]) and (Code <= PropertyRanges[M + 1]) then
          begin
            Result:=True;
            Break;
          end;
    end;
  end;
end;

//------------------------------------------------------------------------------

function IsProperty(Code, Mask1, Mask2: Cardinal): Boolean;
var
  I, Limit: Integer;
  Mask: Cardinal;
begin
  Result:=False;
  if Mask1 <> 0 then begin
    Mask:=1;
    for I:=0 to 31 do begin
      if ((Mask1 and Mask) <> 0) and PropertyLookup(Code, Cardinal(I)) then begin
        Result:=True;
        Exit;
      end;
      Mask:=Mask shl 1;
    end;
  end;
  if Mask2 <> 0 then begin
    I:=32;
    Mask:=1;
    {$IFNDEF USE_VECTORS}
    Limit:=High(PropertyOffsets);
    {$ELSE}
    Limit:=PropertyOffsets.Count - 1;
    {$ENDIF}
    while I < Limit do begin
      if ((Mask2 and Mask) <> 0) and PropertyLookup(Code, Cardinal(I)) then begin
        Result:=True;
        Exit;
      end;
      Inc(I);
      Mask:=Mask shl 1;
    end;
  end;
end;

//----------------- support for case mapping -----------------------------------
var
  CaseMapSize: Cardinal;
  CaseLengths: array[0..1] of Word;
  {$IFNDEF USE_VECTORS}
  CaseMap: TCardinalArray;
  {$ELSE}
  CaseMap: TUInt32Vector = nil;
  {$ENDIF}

procedure LoadUnicodeCaseData;
var
  Header: TUHeader;
  Stream: TVMemStream;
  HGlobal, HResInfo: THandle;
begin
  // make sure no other code is currently modifying the global data area
  {$IFDEF MULTI_THREAD}
  EnterCriticalSection(LoadInProgress);
  try
  {$ENDIF}
    if CaseMap = nil then begin
      Stream:=TVMemStream.Create;
      try
        HResInfo:=FindResource(HInstance, 'UNI_CASE', RT_RCDATA);
        OSCheck(HResInfo <> 0);
        HGlobal:=LoadResource(HInstance, HResInfo);
        OSCheck(HGlobal <> 0);
        try
          Stream.WriteProc(LockResource(HGlobal)^, SizeOfResource(HInstance, HResInfo));
        finally
          FreeResource(HGlobal);
        end;
        Stream.Seek(0);

        Stream.ReadProc(Header, SizeOf(Header));

        // Set the node count and lengths of the upper and lower case mapping tables.
        CaseMapSize:=Header.Count * 3;
        CaseLengths[0]:=Header.Len[0] * 3;
        CaseLengths[1]:=Header.Len[1] * 3;

        // Load the case mapping table.
        {$IFNDEF USE_VECTORS}
        SetLength(CaseMap, CaseMapSize);
        Stream.ReadProc(CaseMap[0], CaseMapSize * SizeOf(Cardinal));
        {$ELSE}
        CaseMap:=TUInt32Vector.Create(CaseMapSize, 0);
        Stream.ReadProc(CaseMap.Memory^, CaseMapSize * SizeOf(Cardinal));
        {$ENDIF}
      finally
        Stream.Free;
      end;
    end;
  {$IFDEF MULTI_THREAD}
  finally
    LeaveCriticalSection(LoadInProgress);
  end;
  {$ENDIF}
end;

//------------------------------------------------------------------------------

function CaseLookup(Code: Cardinal; L, R, Field: Integer): Cardinal;
var
  M: Integer;
begin
  // load case mapping data if not already done
  if CaseMap = nil then
    LoadUnicodeCaseData;
  // Do the binary search.
  while L <= R do begin
    // Determine a "mid" point and adjust to make sure the mid point is at
    // the beginning of a case mapping triple.
    M:=(L + R) shr 1;
    Dec(M, M mod 3);
    if Code > CaseMap[M] then
      L:=M + 3
    else
      if Code < CaseMap[M] then
        R:=M - 3
      else
        if Code = CaseMap[M] then begin
          Result:=CaseMap[M + Field];
          Exit;
        end;
  end;
  Result:=Code;
end;

//------------------------------------------------------------------------------

function UnicodeToUpper(Code: UCS4): UCS4;
var
  Field,
  L, R: Integer;
begin
  // alexch 010119: try to convert ASCII and cyrillics "by hand" for efficiency
  Result:=Code;
  if Code >= Ord('a') then
    if (Code <= Ord('z')) or
      (Code <= $FE) and (Code >= $E0) and (Code <> $F7) or
      (Code >= $0430) and (Code <= $044F)
    then
      Dec(Result, $20)
    else if (Code > $80) and ((Code < $0410) or (Code > $044F)) then begin
      // original code
      // load case mapping data if not already done
      if CaseMap = nil then
        LoadUnicodeCaseData;
      if UnicodeIsUpper(Code) then
        Result:=Code
      else begin
        if UnicodeIsLower(Code) then begin
          Field:=2;
          L:=CaseLengths[0];
          R:=(L + CaseLengths[1]) - 3;
        end
        else begin
          Field:=1;
          L:=CaseLengths[0] + CaseLengths[1];
          R:=CaseMapSize - 3;
        end;
        Result:=CaseLookup(Code, L, R, Field);
      end;
    end;
end;

//------------------------------------------------------------------------------

function UnicodeToLower(Code: UCS4): UCS4;
var
  Field,
  L, R: Integer;
begin
  // alexch 010119: try to convert ASCII and cyrillics "by hand" for efficiency
  Result:=Code;
  if Code >= Ord('A') then
    if (Code <= Ord('Z')) or
      (Code <= $DE) and (Code >= $C0) and (Code <> $D7) or
      (Code >= $0410) and (Code <= $042F)
    then
      Inc(Result, $20)
    else if (Code > $80) and ((Code < $0410) or (Code > $044F)) then begin
      // original code
      if CaseMap = nil then
        LoadUnicodeCaseData;
      if UnicodeIsLower(Code) then
        Result:=Code
      else begin
        if UnicodeIsUpper(Code) then begin
          Field:=1;
          L:=0;
          R:=CaseLengths[0] - 3;
        end
        else begin
          Field:=2;
          L:=CaseLengths[0] + CaseLengths[1];
          R:=CaseMapSize - 3;
        end;
        Result:=CaseLookup(Code, L, R, Field);
      end;
    end;
end;

//------------------------------------------------------------------------------

function UnicodeToTitle(Code: UCS4): UCS4;
var
  Field,
  L, R: Integer;
begin
  // load case mapping data if not already done
  if CaseMap = nil then
    LoadUnicodeCaseData;
  if UnicodeIsTitle(Code) then
    Result:=Code
  else begin
    // The offset will always be the same for converting to title case.
    Field:=2;
    if UnicodeIsUpper(Code) then begin
      L:=0;
      R:=CaseLengths[0] - 3;
    end
    else begin
      L:=CaseLengths[0];
      R:=(L + CaseLengths[1]) - 3;
    end;
    Result:=CaseLookup(Code, L, R, Field);
  end;
end;

//----------------- character test routines ------------------------------------

function UnicodeIsAlpha(C: UCS4): Boolean;
begin Result:=IsProperty(C, UC_LU or UC_LL or UC_LM or UC_LO or UC_LT, 0); end;
function UnicodeIsDigit(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_ND, 0); end;
function UnicodeIsAlphaNum(C: UCS4): Boolean;
begin Result:=IsProperty(C, UC_LU or UC_LL or UC_LM or UC_LO or UC_LT or UC_ND, 0); end;
function UnicodeIsControl(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_CC or UC_CF, 0); end;
function UnicodeIsSpace(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_ZS or UC_SS, 0); end;
function UnicodeIsWhiteSpace(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_ZS or UC_SS, UC_WS or UC_S); end;
function UnicodeIsBlank(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_ZS, 0); end;
function UnicodeIsPunctuation(C: UCS4): Boolean;
begin Result:=IsProperty(C, UC_PD or UC_PS or UC_PE or UC_PO, UC_PI or UC_PF); end;
function UnicodeIsGraph(C: UCS4): Boolean;
begin Result:=IsProperty(C, UC_MN or UC_MC or UC_ME or UC_ND or UC_NL or UC_NO or
                           UC_LU or UC_LL or UC_LT or UC_LM or UC_LO or UC_PC or UC_PD or
                           UC_PS or UC_PE or UC_PO or UC_SM or UC_SM or UC_SC or UC_SK or
                           UC_SO, UC_PI or UC_PF); end;
function UnicodeIsPrintable(C: UCS4): Boolean;
begin Result:=IsProperty(C, UC_MN or UC_MC or UC_ME or UC_ND or UC_NL or UC_NO or
                           UC_LU or UC_LL or UC_LT or UC_LM or UC_LO or UC_PC or UC_PD or
                           UC_PS or UC_PE or UC_PO or UC_SM or UC_SM or UC_SC or UC_SK or
                           UC_SO or UC_ZS, UC_PI or UC_PF); end;
function UnicodeIsUpper(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_LU, 0); end;
function UnicodeIsLower(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_LL, 0); end;
function UnicodeIsTitle(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_LT, 0); end;
function UnicodeIsHexDigit(C: UCS4): Boolean; begin Result:=IsProperty(C, 0, UC_HD); end;

function UnicodeIsIsoControl(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_CC, 0); end;
function UnicodeIsFormatControl(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_CF, 0); end;

function UnicodeIsSymbol(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_SM or UC_SC or UC_SO or UC_SK, 0); end;
function UnicodeIsNumber(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_ND or UC_NO or UC_NL, 0); end;
function UnicodeIsNonSpacing(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_MN, 0); end;
function UnicodeIsOpenPunctuation(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_PS, 0); end;
function UnicodeIsClosePunctuation(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_PE, 0); end;
function UnicodeIsInitialPunctuation(C: UCS4): Boolean; begin Result:=IsProperty(C, 0, UC_PI); end;
function UnicodeIsFinalPunctuation(C: UCS4): Boolean; begin Result:=IsProperty(C, 0, UC_PF); end;

function UnicodeIsComposite(C: UCS4): Boolean; begin Result:=IsProperty(C, 0, UC_CM); end;
function UnicodeIsQuotationMark(C: UCS4): Boolean; begin Result:=IsProperty(C, 0, UC_QM); end;
function UnicodeIsSymmetric(C: UCS4): Boolean; begin Result:=IsProperty(C, 0, UC_SY); end;
function UnicodeIsMirroring(C: UCS4): Boolean; begin Result:=IsProperty(C, 0, UC_MR); end;
function UnicodeIsNonBreaking(C: UCS4): Boolean; begin Result:=IsProperty(C, 0, UC_NB); end;

// Directionality functions

function UnicodeIsRTL(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_R, 0); end;
function UnicodeIsLTR(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_L, 0); end;
function UnicodeIsStrong(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_L or UC_R, 0); end;
function UnicodeIsWeak(C: UCS4): Boolean; begin Result:=IsProperty(C, Cardinal(UC_EN or UC_ES), UC_ET or UC_AN or UC_CS); end;
function UnicodeIsNeutral(C: UCS4): Boolean; begin Result:=IsProperty(C, 0, UC_B or UC_S or UC_WS or UC_ON); end;
function UnicodeIsSeparator(C: UCS4): Boolean; begin Result:=IsProperty(C, 0, UC_B or UC_S); end;

// Other functions inspired by John Cowan.

function UnicodeIsMark(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_MN or UC_MC or UC_ME, 0); end;
function UnicodeIsModifier(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_LM, 0); end;
function UnicodeIsLetterNumber(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_NL, 0); end;
function UnicodeIsConnectionPunctuation(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_PC, 0); end;
function UnicodeIsDash(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_PD, 0); end;
function UnicodeIsMath(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_SM, 0); end;
function UnicodeIsCurrency(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_SC, 0); end;
function UnicodeIsModifierSymbol(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_SK, 0); end;
function UnicodeIsNonSpacingMark(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_MN, 0); end;
function UnicodeIsSpacingMark(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_MC, 0); end;
function UnicodeIsEnclosing(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_ME, 0); end;
function UnicodeIsPrivate(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_CO, 0); end;
function UnicodeIsSurrogate(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_OS, 0); end;
function UnicodeIsLineSeparator(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_ZL, 0); end;
function UnicodeIsParagraphSeparator(C: UCS4): Boolean; begin Result:=IsProperty(C, UC_ZP, 0); end;

function UnicodeIsIdentifierStart(C: UCS4): Boolean;
begin Result:=IsProperty(C, UC_LU or UC_LL or UC_LT or UC_LO or UC_NL, 0); end;
function UnicodeIsIdentifierPart(C: UCS4): Boolean;
begin Result:=IsProperty(C, UC_LU or UC_LL or UC_LT or UC_LO or UC_NL or UC_MN or
                           UC_MC or UC_ND or UC_PC or UC_CF, 0); end;

function UnicodeIsDefined(C: UCS4): Boolean; begin Result:=IsProperty(C, 0, UC_CP); end;
function UnicodeIsUndefined(C: UCS4): Boolean; begin Result:=not IsProperty(C, 0, UC_CP); end;

// Other miscellaneous character property functions.

function UnicodeIsHan(C: UCS4): Boolean;
begin Result:=((C >= $4E00) and (C <= $9FFF))  or ((C >= $F900) and (C <= $FAFF)); end;

function UnicodeIsHangul(C: UCS4): Boolean;
begin Result:=(C >= $AC00) and (C <= $D7FF); end;

//----------------- functions for null terminated wide strings -----------------

//------------------------------------------------------------------------------

function StrUpperW(Str: PWideChar): PWideChar;
begin
  Result:=Str;
  while Str^ <> WideNull do begin
    Str^:=WideChar(UnicodeToUpper(Word(Str^)));
    Inc(Str);
  end;
end;

//------------------------------------------------------------------------------

function StrLowerW(Str: PWideChar): PWideChar;
begin
  Result:=Str;
  while Str^ <> WideNull do begin
    Str^:=WideChar(UnicodeToLower(Word(Str^)));
    Inc(Str);
  end;
end;

//------------------------------------------------------------------------------

function StrTitleW(Str: PWideChar): PWideChar;
begin
  Result:=Str;
  while Str^ <> WideNull do begin
    Str^:=WideChar(UnicodeToTitle(Word(Str^)));
    Inc(Str);
  end;
end;

function WideAdjustLineBreaks(const W: WideString): WideString;
var
  Dest, Source, SourceEnd: PWideChar;
  Extra: Integer;
begin
  Source:=Pointer(W);
  SourceEnd:=Source + Length(W);
  Extra:=0;
  while Source < SourceEnd do begin
    Case Source^ of
      #10:
        Inc(Extra);
      #13:
        if Source[1] = #10 then
          Inc(Source)
        else
          Inc(Extra);
    Else
      Inc(Source);
    End;
    Inc(Source);
  end; {while}
  if Extra = 0 then
    Result:=W
  else begin
    Source:=Pointer(W);
    SetLength(Result, SourceEnd - Source + Extra);
    Dest:=Pointer(Result);
    while Source < SourceEnd do
      Case Source^ of
        #10: begin
          Dest^:=#13;
          Inc(Dest);
          Dest^:=#10;
          Inc(Dest);
          Inc(Source);
        end;
        #13: begin
          Dest^:=#13;
          Inc(Dest);
          Dest^:=#10;
          Inc(Dest);
          Inc(Source);
          if Source^ = #10 then
            Inc(Source);
        end;
      Else
        Dest^:=Source^;
        Inc(Dest);
        Inc(Source);
      End;
  end;
end;

//------------------------------------------------------------------------------

function WideQuotedStr(const S: WideString; Quote: WideChar): WideString;
var
  P, Src,
  Dest: PWideChar;
  L, AddCount: Integer;
begin
  AddCount:=0;
  P:=StrScanW(PWideChar(S), Quote);
  while P <> nil do begin
    Inc(P);
    Inc(AddCount);
    P:=StrScanW(P, Quote);
  end;
  if AddCount = 0 then
    {$IFDEF V_WIDESTRING_PLUS} // Delphi 4.0 or higher
    Result:=Quote + S + Quote
    {$ELSE} // Delphi 3.0
    begin
      L:=Length(S);
      SetLength(Result, L + 2);
      Result[1]:=Quote;
      Move(PWideChar(S)^, (PWideChar(Result) + 1)^, L * 2);
      Result[L + 2]:=Quote;
    end
    {$ENDIF}
  else begin
    SetLength(Result, Length(S) + AddCount + 2);
    Dest:=PWideChar(Result);
    Dest^:=Quote;
    Inc(Dest);
    Src:=PWideChar(S);
    P:=StrScanW(Src, Quote);
    repeat
      Inc(P);
      L:=P - Src;
      Move(Src^, Dest^, L * 2);
      Inc(Dest, L);
      Dest^:=Quote;
      Inc(Dest);
      Src:=P;
      P:=StrScanW(Src, Quote);
    until P = nil;
    L:=StrEndW(Src) - Src;
    Move(Src^, Dest^, L * 2);
    (Dest + L)^:=Quote;
  end;
end;

//------------------------------------------------------------------------------

function WideExtractQuotedStr(const S: WideString; Quote: WideChar): WideString;
var
  P, Src, Dest: PWideChar;
  L, DropCount: Integer;
begin
  Result:='';
  if (S = '') or (S[1] <> Quote) then
    Exit;
  Src:=PWideChar(S) + 1;
  DropCount:=1;
  P:=Src;
  Src:=StrScanW(Src, Quote);
  while Src <> nil do begin // count adjacent pairs of quote chars
    Inc(Src);
    if Src^ <> Quote then
      Break;
    Inc(Src);
    Inc(DropCount);
    Src:=StrScanW(Src, Quote);
  end;
  if Src = nil then
    Src:=StrEndW(P);
  if Src - P <= 1 then
    Exit;
  if DropCount = 1 then
    SetString(Result, P, Src - P - 1)
  else begin
    SetLength(Result, Src - P - DropCount);
    Dest:=PWideChar(Result);
    Src:=StrScanW(P, Quote);
    while Src <> nil do begin
      Inc(Src);
      if Src^ <> Quote then
        Break;
      L:=Src - P;
      Move(P^, Dest^, L * 2);
      Inc(Dest, L);
      Inc(Src);
      P:=Src;
      Src:=StrScanW(Src, Quote);
    end;
    if Src = nil then
      Src:=StrEndW(P);
    Move(P^, Dest^, (Src - P - 1) * 2);
  end;
end;

//------------------------------------------------------------------------------

function WideTrim(const S: WideString): WideString;
var
  I, L: Integer;
begin
  L:=Length(S);
  I:=1;
  while (I <= L) and
    (UnicodeIsWhiteSpace(Word(S[I])) or UnicodeIsControl(Word(S[I]))) do Inc(I);
  if I > L then
    Result:=''
  else begin
    while UnicodeIsWhiteSpace(Word(S[L])) or UnicodeIsControl(Word(S[L])) do Dec(L);
    Result:=Copy(S, I, L - I + 1);
  end;
end;

//------------------------------------------------------------------------------

function WideTrimLeft(const S: WideString): WideString;
var
  I, L: Integer;
begin
  L:=Length(S);
  I:=1;
  while (I <= L) and
    (UnicodeIsWhiteSpace(Word(S[I])) or UnicodeIsControl(Word(S[I]))) do Inc(I);
  Result:=Copy(S, I, Maxint);
end;

//------------------------------------------------------------------------------

function WideTrimRight(const S: WideString): WideString;
var
  I: Integer;
begin
  I:=Length(S);
  while (I > 0) and
    (UnicodeIsWhiteSpace(Word(S[I])) or UnicodeIsControl(Word(S[I]))) do Dec(I);
  Result:=Copy(S, 1, I);
end;

//------------------------------------------------------------------------------

function WideLoCase(C: WideChar): WideChar;
begin
  Result:=WideChar(UnicodeToLower(Word(C)));
end;

//------------------------------------------------------------------------------

function WideLowerCase(const S: WideString): WideString;
begin
  Result:=S;
  WideLowerBuf(PWideChar(Result), Length(Result));
end;

//------------------------------------------------------------------------------

function WideTitleCaseChar(C: WideChar): WideChar;
begin
  Result:=WideChar(UnicodeToTitle(Word(C)));
end;

//------------------------------------------------------------------------------

function WideTitleCaseString(const S: WideString): WideString;
var
  I: Integer;
begin
  Result:=S;
  for I:=1 to Length(S) do
    Result[I]:=WideChar(UnicodeToTitle(Word(Result[I])));
end;

//------------------------------------------------------------------------------

function WideUpCase(C: WideChar): WideChar;
begin
  Result:=WideChar(UnicodeToUpper(Word(C)));
end;

//------------------------------------------------------------------------------

function WideUpperCase(const S: WideString): WideString;
begin
  Result:=S;
  WideUpperBuf(PWideChar(Result), Length(Result));
end;

// new (alexch)

type
  PWideCharArray = ^TWideCharArray;
  TWideCharArray = array [Word] of WideChar;
  // FPC had a bug, so don't use "array [WideChar]"
var
  WideUpperTable: PWideCharArray = nil;
  WideLowerTable: PWideCharArray = nil;

function UnicodeToUpperFast(W: WideChar): WideChar;
begin
  if WideUpperTable = nil then
    WideUpperTable:=AllocMem(SizeOf(TWideCharArray));
  Result:=WideUpperTable^[Word(W)];
  if (Result = #0) and (W > #0) then begin
    Result:=WideChar(UnicodeToUpper(Word(W)));
    WideUpperTable^[Word(W)]:=Result;
  end;
end;

function UnicodeToLowerFast(W: WideChar): WideChar;
begin
  if WideLowerTable = nil then
    WideLowerTable:=AllocMem(SizeOf(TWideCharArray));
  Result:=WideLowerTable^[Word(W)];
  if (Result = #0) and (W > #0) then begin
    Result:=WideChar(UnicodeToLower(Word(W)));
    WideLowerTable^[Word(W)]:=Result;
  end;
end;

procedure WideUpperBuf(Buf: PWideChar; Count: Integer);
var
  W, U: WideChar;
  Limit: PWideChar;
begin
  if WideUpperTable = nil then
    WideUpperTable:=AllocMem(SizeOf(TWideCharArray));
  Limit:=Buf + Count;
  while Buf < Limit do begin
    W:=Buf^;
    U:=WideUpperTable^[Word(W)];
    if U <> W then begin
      if U = #0 then begin
        U:=WideChar(UnicodeToUpper(Word(W)));
        WideUpperTable^[Word(W)]:=U;
      end;
      Buf^:=U;
    end;
    Inc(Buf);
  end; {while}
end;

procedure WideLowerBuf(Buf: PWideChar; Count: Integer);
var
  W, U: WideChar;
  Limit: PWideChar;
begin
  if WideLowerTable = nil then
    WideLowerTable:=AllocMem(SizeOf(TWideCharArray));
  Limit:=Buf + Count;
  while Buf < Limit do begin
    W:=Buf^;
    U:=WideLowerTable^[Word(W)];
    if U <> W then begin
      if U = #0 then begin
        U:=WideChar(UnicodeToLower(Word(W)));
        WideLowerTable^[Word(W)]:=U;
      end;
      Buf^:=U;
    end;
    Inc(Buf);
  end; {while}
end;

function CompareTextBufWide(PW1, PW2: PWideChar; Count1, Count2: Integer): Integer;
var
  I, L, Delta: Integer;
begin
  L:=Count1;
  Delta:=Count1 - Count2;
  if Delta > 0 then
    L:=Count2;
  for I:=0 to L - 1 do begin
    Result:=Integer(UnicodeToUpperFast(PW1^)) - Integer(UnicodeToUpperFast(PW2^));
    if Result <> 0 then
      Exit;
    Inc(PW1);
    Inc(PW2);
  end;
  Result:=Delta;
end;

function CompareTextWide(const W1, W2: WideString): Integer;
begin
  Result:=CompareTextBufWide(PWideChar(W1), PWideChar(W2), Length(W1), Length(W2));
end;

{$IFDEF V_WIN}
function Emulate_lstrcmpiW(PW1, PW2: PWideChar): Integer;
begin
  Result:=0;
  if PW1 = PW2 then
    Exit;
  if PW1 = nil then begin
    Result:=-1;
    Exit;
  end;
  if PW2 = nil then begin
    Result:=1;
    Exit;
  end;
  while PW1^ = PW2^ do begin
    if PW1^ = #0 then
      Exit;
    Inc(PW1);
    Inc(PW2);
  end;
  if PW1^ = #0 then begin
    Result:=-1;
    Exit;
  end;
  if PW2^ = #0 then begin
    Result:=1;
    Exit;
  end;
  Result:=Emulate_CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE,
    PW1, StrLenW(PW1), PW2, StrLenW(PW2)) - 2;
end;

function Emulate_CompareStringW(Locale: LCID; Flags: DWORD;
  PW1: PWideChar; L1: Integer; PW2: PWideChar; L2: Integer): Integer;
var
  UsedDef1, UsedDef2: BOOL;
  P1, P2: PChar;
  S1, S2: String;
begin
  if (WideCharToMultiByte(0, 0, PW1, L1, nil, 0, #0, nil) <> L1) or
    (WideCharToMultiByte(0, 0, PW2, L2, nil, 0, #0, nil) <> L2) then
  begin // multi-byte compare is not emulatated
    if Flags and NORM_IGNORECASE <> 0 then
      Result:=CompareTextBufWide(PW1, PW2, L1, L2)
    else
      Result:=CompareStrBufWide(PW1, PW2, L1, L2);
  end
  else begin
    SetLength(S1, L1);
    P1:=PChar(S1);
    WideCharToMultiByte(0, 0, PW1, L1, P1, L1, #0, @UsedDef1);
    SetLength(S2, L2);
    P2:=PChar(S2);
    WideCharToMultiByte(0, 0, PW2, L2, P2, L2, #0, @UsedDef2);
    if not (UsedDef1 or UsedDef2) then
      if Flags and NORM_IGNORECASE <> 0 then
        Result:=lstrcmpi(P1, P2)
      else
        Result:=lstrcmp(P1, P2)
    else
      if Flags and NORM_IGNORECASE <> 0 then
        Result:=CompareTextBufWide(PW1, PW2, L1, L2)
      else
        Result:=CompareStrBufWide(PW1, PW2, L1, L2);
  end;
  if Result > 0 then
    Result:=3
  else if Result < 0 then
    Result:=1
  else
    Result:=2;
end;
{$ENDIF}

initialization
  {$IFDEF MULTI_THREAD}
  InitializeCriticalSection(LoadInProgress);
  {$ENDIF}
  {$IFDEF V_WIN}
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    SystemIndependent_lstrcmpiW:=lstrcmpiW;
    SystemIndependent_CompareStringW:=CompareStringW;
  end
  else begin
    SystemIndependent_lstrcmpiW:=Emulate_lstrcmpiW;
    SystemIndependent_CompareStringW:=Emulate_CompareStringW;
  end;
  {$ENDIF}
finalization
  {$IFDEF MULTI_THREAD}
  DeleteCriticalSection(LoadInProgress);
  {$ENDIF}
  {$IFDEF V_WIN}
  {$IFDEF USE_VECTORS}
  PropertyOffsets.Free;
  PropertyRanges.Free;
  CaseMap.Free;
  {$ENDIF}
  {$IFNDEF V_FREEMEM_NIL}if WideUpperTable <> nil then{$ENDIF}
    FreeMem(WideUpperTable);
  {$IFNDEF V_FREEMEM_NIL}if WideLowerTable <> nil then{$ENDIF}
    FreeMem(WideLowerTable);
  {$ENDIF} {V_WIN}
end.

{ Copyright © Alexey Chernobaev, v.041101 }

{ Some constants and type definitions are from Unicode.pas:
  Copyright (c) 1999, 2000 Mike Lischke; Portions Copyright (c) 1999, 2000 Azret
  Botash (az) - see VUnicode.pas for more information }

unit NLSTypes;

{ Types/consts for VUnicode, etc. }

interface

{$I VCheck.inc}

type
  TMIB = SmallInt;

const
{
  Assigned MIB enum Numbers
  -------------------------
  0-2         Reserved
  3-999       Set By Standards Organizations
  1000-1999   Unicode / 10646
  2000-2999   Vendor
}
{ MIBenum values corresponding to the character sets; negative values indicate
  that no MIB enum number was assigned to this character set by authorities so
  a library-specific number is used }

  mibError = 0;

  mibISOLatin1 = 4;
  mibISOLatin2 = 5;
  mibISOLatin3 = 6;
  mibISOLatin4 = 7;
  mibISOCyrillic = 8;
  mibISOArabic = 9;
  mibISOGreek = 10;
  mibISOHebrew = 11;
  mibISOLatin5 = 12;
  mibISOLatin6 = 13;
  mibISOLatin7 = 109;
  mibISOLatin8 = 110;
  mibISOLatin9 = 111;
  mibISOLatin10 = 112;
  mibKOI8R = 2084;
  mibKOI8U = 2088;
  mibWindows1250 = 2250;
  mibWindows1251 = 2251;
  mibWindows1252 = 2252;
  mibWindows1253 = 2253;
  mibWindows1254 = 2254;
  mibWindows1255 = 2255;
  mibWindows1256 = 2256;
  mibWindows1257 = 2257;
  mibWindows1258 = 2258;
  mibDOS437 = 2011;
  mibDOS737 = -737;
  mibDOS775 = 2087;
  mibDOS850 = 2009;
  mibDOS852 = 2010;
  mibDOS853 = -853;
  mibDOS860 = 2048;
  mibDOS862 = 2013;
  mibDOS863 = 2050;
  mibDOS864 = 2051;
  mibDOS865 = 2052;
  mibDOS866 = 2086;
  mibDOS866LV = -866;
  mibDOS1125 = -1125;
  mibMacRoman = -10000;
  mibMacGreek = -10006;
  mibMacCyrillic = -10007;
  mibMacCentEuro = -10029;
  mibMacTurkish = -10081;
  mibEBCDIC037 = 2028;
  mibEBCDIC273 = 2030;
  mibEBCDIC277 = 2033;
  mibEBCDIC278 = 2034;
  mibEBCDIC280 = 2035;
  mibEBCDIC284 = 2037;
  mibEBCDIC285 = 2038;
  mibEBCDIC297 = 2040;
  mibEBCDIC500 = 2044;
  mibEBCDIC880 = 2057;
  mibEBCDIC1026 = 2063;
  mibEBCDIC1047 = 2102;
  mibEBCDIC1140 = 2091;
  mibEBCDIC1141 = 2092;
  mibEBCDIC1142 = 2093;
  mibEBCDIC1143 = 2094;
  mibEBCDIC1144 = 2095;
  mibEBCDIC1145 = 2096;
  mibEBCDIC1146 = 2097;
  mibEBCDIC1147 = 2098;
  mibEBCDIC1148 = 2099;
  mibUTF8 = 106;
  mibUTF16LE = 1014;
  mibUTF16BE = 1013;
  mibUTF7 = 1012;
  {$IFDEF FAR_EAST}
  mibJapaneseShiftJIS = 17;
  mibChineseGBK = 113; { GB_2312-80: 57, GBK: 113, GB2312: 2025 }
  mibChineseBig5 = 2026;
  mibKorean = 36;
  mibJapaneseJIS = 39;
  mibChineseGB_ISO = 104;
  mibChineseGB_HZ = 2085;
  mibChineseEUC_TW = -2026;
  mibKoreanISO = 37;
  mibJapaneseEUC = 18;
  {$ENDIF}

  cfASCII    = $00000001;
  cfEBCDIC   = $00000002;

  cfOneByte  = $00000010;
  cfUnicode  = $00000020;
  cfUTF16    = $00000040;

  cfISO      = $00000100;
  cfWindows  = $00000200;
  cfDOS      = $00000400;
  cfMac      = $00000800;

  cfCyrillic = $00020000;

type
  PCharMap = ^TCharMap;
  TCharMap = array [Char] of Char;

  PTransMap = ^TTransMap;
  TTransMap = array [#$80..#$FF] of Char;

  PEBCDICCharMap = ^TEBCDICCharMap;
  TEBCDICCharMap = array [#$40..#$FF] of Char;

  PUnicodeMap = ^TUnicodeMap;
  TUnicodeMap = array [#$80..#$FF] of WideChar; { Unicode: ISO 10646 }

  PEBCDICMap = ^TEBCDICMap;
  TEBCDICMap =  array [#0..#$FF] of WideChar;

const
  LoCJK = #$21; {33}
  HiCJK = #$7E; {126}

  CJKChars = [LoCJK..HiCJK];

  LoEUC = #$A1; {161}
  HiEUC = #$FE; {254}

  EUCChars = [LoEUC..HiEUC];

  CJKRowLength = 94;

type
  // double-byte character maps are stored in DBCSMaps unit
  PDBCSMap = ^TDBCSMap;
  TDBCSMap = record
    Main: TUnicodeMap;
    // Delphi 5 can't correctly initialize WideString with characters > #$FF
    Links: array [#$80..#$FF] of String; // so using AnsiString type instead
  end;

  TCJKRange = LoCJK..HiCJK;

  PCJKMap = ^TCJKMap;
  TCJKMap = array [TCJKRange, TCJKRange] of WideChar; { 94x94 JIS table }

const
  CheckAll = $7FFFFFFF;

  CheckWindows1251   = $00000001;
  CheckDOS866        = $00000002;
  CheckKOI8R         = $00000004;
  CheckISOCyrillic   = $00000008;
  CheckRussian = CheckWindows1251 or CheckDOS866 or CheckKOI8R or CheckISOCyrillic;

  CheckWestern       = $00000100;

  CheckWindowsDBCS   = $00001000;
  CheckISO2022Family = $00002000;
  CheckEUCFamily     = $00004000;
  CheckFarEast       = $00007000;

  HighCharFlag       = $00008000;

  CheckingFromStart  = $00010000;
  CheckUTF8          = $00020000;
  CheckUTF16         = $00040000;
  UTFPrefixFlag      = $40000000;
  BigEndianFlag      = $80000000;
  CheckUnicode = CheckUTF8 or CheckUTF16;

  EnglishUpperChars = ['A'..'Z'];
  EnglishLowerChars = ['a'..'z'];
  EnglishVowels = ['A', 'E', 'I', 'O', 'U', 'Y'];
  EnglishConsonants = ['A'..'Z'] - EnglishVowels;

  StdCharsToQuotePrintable = [#0..#$20, '"', #$80..#$FF];

  RussianUpperChars1251 = [#$C0..#$DF];
  RussianLowerChars1251 = [#$E0..#$FF];

  DOSPseudoGraphics = [#$B0..#$DF];

  ESC = #27;

  UTF8_BOM = #$EF#$BB#$BF;

  { from Unicode.pas }

  // definitions of often used characters:
  // Note: Use them only for tests of a certain character not to determine character
  //       classes (like white spaces) as in Unicode are often many code points defined
  //       being in a certain class. Hence your best option is to use the various
  //       UnicodeIs* functions.
  WideNull = WideChar(#0);
  WideTabulator = WideChar(#9);
  WideSpace = WideChar(#32);

  // logical line breaks
  WideLF = WideChar(10);
  WideLineFeed = WideChar(10);
  WideVerticalTab = WideChar(11);
  WideFormFeed = WideChar(12);
  WideCR = WideChar(13);
  WideCarriageReturn = WideChar(13);

  WideLineSeparator = #$2028;
  WideParagraphSeparator = #$2029;

  WideNonBreakingHyphen = #$2011;
  WideEnDash = #$2013;
  WideEmDash = #$2014;
  WideLeftQuote = #$2018;
  WideRightQuote = #$2019;
  WideLeftDoubleQuote = #$201C;
  WideRightDoubleQuote = #$201D;
  WideBullet = #$2022;

  ASCII_SO = #14; { ASCII SO, shift out }
  ASCII_SI = #15; { ASCII SI, shift in }

  // byte order marks for strings
  // Unicode text files should contain $FFFE as first character to identify such a file clearly. Depending on the system
  // where the file was created on this appears either in big endian or little endian style.
  BOM_LSB_FIRST = WideChar($FEFF); // this is how the BOM appears on x86 systems when written by a x86 system
  BOM_MSB_FIRST = WideChar($FFFE);

  ReplacementCharacter = $0000FFFD;
  MaximumUCS2 = $0000FFFF;
  MaximumUTF16 = $0010FFFF;
  MaximumUCS4 = $7FFFFFFF;

  SurrogateHighStart = $D800;
  SurrogateHighEnd = $DBFF;
  SurrogateLowStart = $DC00;
  SurrogateLowEnd = $DFFF;

type
  // Unicode transformation formats (UTF) data types
  UTF7 = Char;
  UTF8 = Char;
  UTF16 = WideChar;
  UTF32 = Cardinal;

  // UTF conversion schemes (UCS) data types
  PUCS4 = ^UCS4;
  UCS4 = Cardinal;
  PUCS2 = PWideChar;
  UCS2 = WideChar;

{$IFNDEF BCB}
function MAKELANGID(PrimaryLangId, SubLangId: Byte): Word;
{$ENDIF}

{$IFDEF LINUX}
const
  DEFAULT_CHARSET = 1;
  EASTEUROPE_CHARSET = 238;
  RUSSIAN_CHARSET = 204;
  ANSI_CHARSET = 0;
  GREEK_CHARSET = 161;
  TURKISH_CHARSET = 162;
  HEBREW_CHARSET = 177;
  ARABIC_CHARSET = 178;
  BALTIC_CHARSET = 186;
  VIETNAMESE_CHARSET = 163;
  SHIFTJIS_CHARSET = $80;
  GB2312_CHARSET = 134;
  HANGEUL_CHARSET = 129;
  CHINESEBIG5_CHARSET = 136;

  LANG_NEUTRAL                         = $00;
  LANG_AFRIKAANS                       = $36;
  LANG_ALBANIAN                        = $1c;
  LANG_ARABIC                          = $01;
  LANG_BASQUE                          = $2d;
  LANG_BELARUSIAN                      = $23;
  LANG_BULGARIAN                       = $02;
  LANG_CATALAN                         = $03;
  LANG_CHINESE                         = $04;
  LANG_CROATIAN                        = $1a;
  LANG_CZECH                           = $05;
  LANG_DANISH                          = $06;
  LANG_DUTCH                           = $13;
  LANG_ENGLISH                         = $09;
  LANG_ESTONIAN                        = $25;
  LANG_FAEROESE                        = $38;
  LANG_FARSI                           = $29;
  LANG_FINNISH                         = $0b;
  LANG_FRENCH                          = $0c;
  LANG_GERMAN                          = $07;
  LANG_GREEK                           = $08;
  LANG_HEBREW                          = $0d;
  LANG_HUNGARIAN                       = $0e;
  LANG_ICELANDIC                       = $0f;
  LANG_INDONESIAN                      = $21;
  LANG_ITALIAN                         = $10;
  LANG_JAPANESE                        = $11;
  LANG_KOREAN                          = $12;
  LANG_LATVIAN                         = $26;
  LANG_LITHUANIAN                      = $27;
  LANG_NORWEGIAN                       = $14;
  LANG_POLISH                          = $15;
  LANG_PORTUGUESE                      = $16;
  LANG_ROMANIAN                        = $18;
  LANG_RUSSIAN                         = $19;
  LANG_SERBIAN                         = $1a;
  LANG_SLOVAK                          = $1b;
  LANG_SLOVENIAN                       = $24;
  LANG_SPANISH                         = $0a;
  LANG_SWEDISH                         = $1d;
  LANG_THAI                            = $1e;
  LANG_TURKISH                         = $1f;
  LANG_UKRAINIAN                       = $22;
  LANG_VIETNAMESE                      = $2a;
{$ENDIF}

implementation

{$IFNDEF BCB}
function MAKELANGID(PrimaryLangId, SubLangId: Byte): Word;
begin
  Result:=SubLangId shl 10 or PrimaryLangId;
end;
{$ENDIF}

end.

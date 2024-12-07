{%MainUnit freetypehdyn}
{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2003 by the Free Pascal development team

    freetype header to be included from static and dynamically loaded header.      

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
Const

{$packrecords c}

// Windows
{$ifdef windows}
  FreeTypeDLL = 'freetype.dll';
  {$define ft_found_platform}
{$endif}

// Mac OS X
{$ifdef darwin}
  freetypedll = 'libfreetype.dylib'; // Doesn't seam to matter much.
{$IFNDEF DYNAMIC}
{$linklib freetype}  // This one is the important part,
                     // but you also need to pass to fpc
                     // the following command:
                     // -k-L/usr/X11/lib
                     // or another place where it can find
                     // libfreetype.dylib
{$ENDIF}
{$define ft_found_platform}
{$endif}

// LINUX
{$if defined(UNIX) and not defined(darwin)}
  FreeTypeDLL = 'libfreetype.so';
  {$define ft_found_platform}
{$endif}
// Other platforms
{$ifndef ft_found_platform}
  FreeTypeDLL = 'freetype';
{$endif}

type
  FT_Encoding = array[0..3] of AnsiChar;

const
  FT_FACE_FLAG_SCALABLE = 1 shl 0;
  FT_FACE_FLAG_FIXED_SIZES = 1 shl 1;
  FT_FACE_FLAG_FIXED_WIDTH = 1 shl 2;
  FT_FACE_FLAG_SFNT = 1 shl 3;
  FT_FACE_FLAG_HORIZONTAL = 1 shl 4;
  FT_FACE_FLAG_VERTICAL = 1 shl 5;
  FT_FACE_FLAG_KERNING = 1 shl 6;
  FT_FACE_FLAG_FAST_GLYPHS = 1 shl 7;
  FT_FACE_FLAG_MULTIPLE_MASTERS = 1 shl 8;
  FT_FACE_FLAG_GLYPH_NAMES = 1 shl 9;
  FT_FACE_FLAG_EXTERNAL_STREAM = 1 shl 10;

  FT_STYLE_FLAG_ITALIC = 1 shl 0;
  FT_STYLE_FLAG_BOLD = 1 shl 1;

  FT_LOAD_DEFAULT =          $0000;
  FT_LOAD_NO_SCALE =         $0001;
  FT_LOAD_NO_HINTING =       $0002;
  FT_LOAD_RENDER =           $0004;
  FT_LOAD_NO_BITMAP =        $0008;
  FT_LOAD_VERTICAL_LAYOUT =  $0010;
  FT_LOAD_FORCE_AUTOHINT =   $0020;
  FT_LOAD_CROP_BITMAP =      $0040;
  FT_LOAD_PEDANTIC =         $0080;
  FT_LOAD_IGNORE_GLOBAL_ADVANCE_WIDTH = $0200;
  FT_LOAD_NO_RECURSE =       $0400;
  FT_LOAD_IGNORE_TRANSFORM = $0800;
  FT_LOAD_MONOCHROME =       $1000;
  FT_LOAD_LINEAR_DESIGN =    $2000;

  ft_glyph_format_none      = $00000000;
  ft_glyph_format_composite = $636F6D70; //comp 099 111 109 112
  ft_glyph_format_bitmap    = $62697473; //bits 098 105 116 115
  ft_glyph_format_outline   = $6F75746C; //outl 111 117 116 108
  ft_glyph_format_plotter   = $706C6F74; //plot 112 108 111 116

  FT_ENCODING_MS_SYMBOL : FT_Encoding = 'symb';
  FT_ENCODING_UNICODE : FT_Encoding = 'unic';
  FT_ENCODING_MS_SJIS : FT_Encoding = 'sjis';
  FT_ENCODING_MS_GB2312 : FT_Encoding = 'gb  ';
  FT_ENCODING_MS_BIG5 : FT_Encoding = 'big5';
  FT_ENCODING_MS_WANSUNG : FT_Encoding = 'wans';
  FT_ENCODING_MS_JOHAB : FT_Encoding = 'joha';
  FT_ENCODING_ADOBE_STANDARD : FT_Encoding = 'ADOB';
  FT_ENCODING_ADOBE_EXPERT : FT_Encoding = 'ADBE';
  FT_ENCODING_ADOBE_CUSTOM : FT_Encoding = 'ADBC';
  FT_ENCODING_ADOBE_LATIN_1 : FT_Encoding = 'lat1';
  FT_ENCODING_OLD_LATIN_2 : FT_Encoding = 'lat2';
  FT_ENCODING_APPLE_ROMAN : FT_Encoding = 'armn';

  ft_glyph_bbox_unscaled  = 0; //* return unscaled font units           */
  ft_glyph_bbox_subpixels = 0; //* return unfitted 26.6 coordinates     */
  ft_glyph_bbox_gridfit   = 1; //* return grid-fitted 26.6 coordinates  */
  ft_glyph_bbox_truncate  = 2; //* return coordinates in integer pixels */
  ft_glyph_bbox_pixels    = 3; //* return grid-fitted pixel coordinates */

  FT_KERNING_DEFAULT  = 0;
  FT_KERNING_UNFITTED = 1;
  FT_KERNING_UNSCALED = 2;

  TT_PLATFORM_APPLE_UNICODE = 0;
  TT_PLATFORM_MACINTOSH     = 1;
  TT_PLATFORM_ISO           = 2; {deprecated}
  TT_PLATFORM_MICROSOFT     = 3;
  TT_PLATFORM_CUSTOM        = 4;
  TT_PLATFORM_ADOBE         = 7; {artificial}

  TT_APPLE_ID_DEFAULT          = 0; {Unicode 1.0}
  TT_APPLE_ID_UNICODE_1_1      = 1; {specify Hangul at U+34xx}
  TT_APPLE_ID_ISO_10646        = 2; {deprecated}
  TT_APPLE_ID_UNICODE_2_0      = 3; {or later}
  TT_APPLE_ID_UNICODE_32       = 4; {2.0 or later, full repertoire}
  TT_APPLE_ID_VARIANT_SELECTOR = 5; {variation selector data}
  TT_APPLE_ID_FULL_UNICODE     = 6; {used with type 13 cmaps}

  TT_MAC_ID_ROMAN               =  0;
  TT_MAC_ID_JAPANESE            =  1;
  TT_MAC_ID_TRADITIONAL_CHINESE =  2;
  TT_MAC_ID_KOREAN              =  3;
  TT_MAC_ID_ARABIC              =  4;
  TT_MAC_ID_HEBREW              =  5;
  TT_MAC_ID_GREEK               =  6;
  TT_MAC_ID_RUSSIAN             =  7;
  TT_MAC_ID_RSYMBOL             =  8;
  TT_MAC_ID_DEVANAGARI          =  9;
  TT_MAC_ID_GURMUKHI            = 10;
  TT_MAC_ID_GUJARATI            = 11;
  TT_MAC_ID_ORIYA               = 12;
  TT_MAC_ID_BENGALI             = 13;
  TT_MAC_ID_TAMIL               = 14;
  TT_MAC_ID_TELUGU              = 15;
  TT_MAC_ID_KANNADA             = 16;
  TT_MAC_ID_MALAYALAM           = 17;
  TT_MAC_ID_SINHALESE           = 18;
  TT_MAC_ID_BURMESE             = 19;
  TT_MAC_ID_KHMER               = 20;
  TT_MAC_ID_THAI                = 21;
  TT_MAC_ID_LAOTIAN             = 22;
  TT_MAC_ID_GEORGIAN            = 23;
  TT_MAC_ID_ARMENIAN            = 24;
  TT_MAC_ID_MALDIVIAN           = 25;
  TT_MAC_ID_SIMPLIFIED_CHINESE  = 25;
  TT_MAC_ID_TIBETAN             = 26;
  TT_MAC_ID_MONGOLIAN           = 27;
  TT_MAC_ID_GEEZ                = 28;
  TT_MAC_ID_SLAVIC              = 29;
  TT_MAC_ID_VIETNAMESE          = 30;
  TT_MAC_ID_SINDHI              = 31;
  TT_MAC_ID_UNINTERP            = 32;

  TT_ISO_ID_7BIT_ASCII = 0;
  TT_ISO_ID_10646      = 1;
  TT_ISO_ID_8859_1     = 2;

  TT_MS_ID_SYMBOL_CS  =  0;
  TT_MS_ID_UNICODE_CS =  1;
  TT_MS_ID_SJIS       =  2;
  TT_MS_ID_PRC        =  3;
  TT_MS_ID_BIG_5      =  4;
  TT_MS_ID_WANSUNG    =  5;
  TT_MS_ID_JOHAB      =  6;
  TT_MS_ID_UCS_4      = 10;
  TT_MS_ID_GB2312     = TT_MS_ID_PRC;{this value is deprecated}

  TT_ADOBE_ID_STANDARD = 0;
  TT_ADOBE_ID_EXPERT   = 1;
  TT_ADOBE_ID_CUSTOM   = 2;
  TT_ADOBE_ID_LATIN_1  = 3;

  TT_MAC_LANGID_ENGLISH                     =   0;
  TT_MAC_LANGID_FRENCH                      =   1;
  TT_MAC_LANGID_GERMAN                      =   2;
  TT_MAC_LANGID_ITALIAN                     =   3;
  TT_MAC_LANGID_DUTCH                       =   4;
  TT_MAC_LANGID_SWEDISH                     =   5;
  TT_MAC_LANGID_SPANISH                     =   6;
  TT_MAC_LANGID_DANISH                      =   7;
  TT_MAC_LANGID_PORTUGUESE                  =   8;
  TT_MAC_LANGID_NORWEGIAN                   =   9;
  TT_MAC_LANGID_HEBREW                      =  10;
  TT_MAC_LANGID_JAPANESE                    =  11;
  TT_MAC_LANGID_ARABIC                      =  12;
  TT_MAC_LANGID_FINNISH                     =  13;
  TT_MAC_LANGID_GREEK                       =  14;
  TT_MAC_LANGID_ICELANDIC                   =  15;
  TT_MAC_LANGID_MALTESE                     =  16;
  TT_MAC_LANGID_TURKISH                     =  17;
  TT_MAC_LANGID_CROATIAN                    =  18;
  TT_MAC_LANGID_CHINESE_TRADITIONAL         =  19;
  TT_MAC_LANGID_URDU                        =  20;
  TT_MAC_LANGID_HINDI                       =  21;
  TT_MAC_LANGID_THAI                        =  22;
  TT_MAC_LANGID_KOREAN                      =  23;
  TT_MAC_LANGID_LITHUANIAN                  =  24;
  TT_MAC_LANGID_POLISH                      =  25;
  TT_MAC_LANGID_HUNGARIAN                   =  26;
  TT_MAC_LANGID_ESTONIAN                    =  27;
  TT_MAC_LANGID_LETTISH                     =  28;
  TT_MAC_LANGID_SAAMISK                     =  29;
  TT_MAC_LANGID_FAEROESE                    =  30;
  TT_MAC_LANGID_FARSI                       =  31;
  TT_MAC_LANGID_RUSSIAN                     =  32;
  TT_MAC_LANGID_CHINESE_SIMPLIFIED          =  33;
  TT_MAC_LANGID_FLEMISH                     =  34;
  TT_MAC_LANGID_IRISH                       =  35;
  TT_MAC_LANGID_ALBANIAN                    =  36;
  TT_MAC_LANGID_ROMANIAN                    =  37;
  TT_MAC_LANGID_CZECH                       =  38;
  TT_MAC_LANGID_SLOVAK                      =  39;
  TT_MAC_LANGID_SLOVENIAN                   =  40;
  TT_MAC_LANGID_YIDDISH                     =  41;
  TT_MAC_LANGID_SERBIAN                     =  42;
  TT_MAC_LANGID_MACEDONIAN                  =  43;
  TT_MAC_LANGID_BULGARIAN                   =  44;
  TT_MAC_LANGID_UKRAINIAN                   =  45;
  TT_MAC_LANGID_BYELORUSSIAN                =  46;
  TT_MAC_LANGID_UZBEK                       =  47;
  TT_MAC_LANGID_KAZAKH                      =  48;
  TT_MAC_LANGID_AZERBAIJANI                 =  49;
  TT_MAC_LANGID_AZERBAIJANI_CYRILLIC_SCRIPT =  49;
  TT_MAC_LANGID_AZERBAIJANI_ARABIC_SCRIPT   =  50;
  TT_MAC_LANGID_ARMENIAN                    =  51;
  TT_MAC_LANGID_GEORGIAN                    =  52;
  TT_MAC_LANGID_MOLDAVIAN                   =  53;
  TT_MAC_LANGID_KIRGHIZ                     =  54;
  TT_MAC_LANGID_TAJIKI                      =  55;
  TT_MAC_LANGID_TURKMEN                     =  56;
  TT_MAC_LANGID_MONGOLIAN                   =  57;
  TT_MAC_LANGID_MONGOLIAN_MONGOLIAN_SCRIPT  =  57;
  TT_MAC_LANGID_MONGOLIAN_CYRILLIC_SCRIPT   =  58;
  TT_MAC_LANGID_PASHTO                      =  59;
  TT_MAC_LANGID_KURDISH                     =  60;
  TT_MAC_LANGID_KASHMIRI                    =  61;
  TT_MAC_LANGID_SINDHI                      =  62;
  TT_MAC_LANGID_TIBETAN                     =  63;
  TT_MAC_LANGID_NEPALI                      =  64;
  TT_MAC_LANGID_SANSKRIT                    =  65;
  TT_MAC_LANGID_MARATHI                     =  66;
  TT_MAC_LANGID_BENGALI                     =  67;
  TT_MAC_LANGID_ASSAMESE                    =  68;
  TT_MAC_LANGID_GUJARATI                    =  69;
  TT_MAC_LANGID_PUNJABI                     =  70;
  TT_MAC_LANGID_ORIYA                       =  71;
  TT_MAC_LANGID_MALAYALAM                   =  72;
  TT_MAC_LANGID_KANNADA                     =  73;
  TT_MAC_LANGID_TAMIL                       =  74;
  TT_MAC_LANGID_TELUGU                      =  75;
  TT_MAC_LANGID_SINHALESE                   =  76;
  TT_MAC_LANGID_BURMESE                     =  77;
  TT_MAC_LANGID_KHMER                       =  78;
  TT_MAC_LANGID_LAO                         =  79;
  TT_MAC_LANGID_VIETNAMESE                  =  80;
  TT_MAC_LANGID_INDONESIAN                  =  81;
  TT_MAC_LANGID_TAGALOG                     =  82;
  TT_MAC_LANGID_MALAY_ROMAN_SCRIPT          =  83;
  TT_MAC_LANGID_MALAY_ARABIC_SCRIPT         =  84;
  TT_MAC_LANGID_AMHARIC                     =  85;
  TT_MAC_LANGID_TIGRINYA                    =  86;
  TT_MAC_LANGID_GALLA                       =  87;
  TT_MAC_LANGID_SOMALI                      =  88;
  TT_MAC_LANGID_SWAHILI                     =  89;
  TT_MAC_LANGID_RUANDA                      =  90;
  TT_MAC_LANGID_RUNDI                       =  91;
  TT_MAC_LANGID_CHEWA                       =  92;
  TT_MAC_LANGID_MALAGASY                    =  93;
  TT_MAC_LANGID_ESPERANTO                   =  94;
  TT_MAC_LANGID_WELSH                       = 128;
  TT_MAC_LANGID_BASQUE                      = 129;
  TT_MAC_LANGID_CATALAN                     = 130;
  TT_MAC_LANGID_LATIN                       = 131;
  TT_MAC_LANGID_QUECHUA                     = 132;
  TT_MAC_LANGID_GUARANI                     = 133;
  TT_MAC_LANGID_AYMARA                      = 134;
  TT_MAC_LANGID_TATAR                       = 135;
  TT_MAC_LANGID_UIGHUR                      = 136;
  TT_MAC_LANGID_DZONGKHA                    = 137;
  TT_MAC_LANGID_JAVANESE                    = 138;
  TT_MAC_LANGID_SUNDANESE                   = 139;

  {The following codes are new as of 2000-03-10}
  TT_MAC_LANGID_GALICIAN                    = 140;
  TT_MAC_LANGID_AFRIKAANS                   = 141;
  TT_MAC_LANGID_BRETON                      = 142;
  TT_MAC_LANGID_INUKTITUT                   = 143;
  TT_MAC_LANGID_SCOTTISH_GAELIC             = 144;
  TT_MAC_LANGID_MANX_GAELIC                 = 145;
  TT_MAC_LANGID_IRISH_GAELIC                = 146;
  TT_MAC_LANGID_TONGAN                      = 147;
  TT_MAC_LANGID_GREEK_POLYTONIC             = 148;
  TT_MAC_LANGID_GREELANDIC                  = 149;
  TT_MAC_LANGID_AZERBAIJANI_ROMAN_SCRIPT    = 150;

  TT_MS_LANGID_ARABIC_SAUDI_ARABIA            = $0401;
  TT_MS_LANGID_ARABIC_IRAQ                    = $0801;
  TT_MS_LANGID_ARABIC_EGYPT                   = $0C01;
  TT_MS_LANGID_ARABIC_LIBYA                   = $1001;
  TT_MS_LANGID_ARABIC_ALGERIA                 = $1401;
  TT_MS_LANGID_ARABIC_MOROCCO                 = $1801;
  TT_MS_LANGID_ARABIC_TUNISIA                 = $1C01;
  TT_MS_LANGID_ARABIC_OMAN                    = $2001;
  TT_MS_LANGID_ARABIC_YEMEN                   = $2401;
  TT_MS_LANGID_ARABIC_SYRIA                   = $2801;
  TT_MS_LANGID_ARABIC_JORDAN                  = $2C01;
  TT_MS_LANGID_ARABIC_LEBANON                 = $3001;
  TT_MS_LANGID_ARABIC_KUWAIT                  = $3401;
  TT_MS_LANGID_ARABIC_UAE                     = $3801;
  TT_MS_LANGID_ARABIC_BAHRAIN                 = $3C01;
  TT_MS_LANGID_ARABIC_QATAR                   = $4001;
  TT_MS_LANGID_BULGARIAN_BULGARIA             = $0402;
  TT_MS_LANGID_CATALAN_CATALAN                = $0403;
  TT_MS_LANGID_CHINESE_TAIWAN                 = $0404;
  TT_MS_LANGID_CHINESE_PRC                    = $0804;
  TT_MS_LANGID_CHINESE_HONG_KONG              = $0C04;
  TT_MS_LANGID_CHINESE_SINGAPORE              = $1004;
  TT_MS_LANGID_CHINESE_MACAO                  = $1404;
  TT_MS_LANGID_CZECH_CZECH_REPUBLIC           = $0405;
  TT_MS_LANGID_DANISH_DENMARK                 = $0406;
  TT_MS_LANGID_GERMAN_GERMANY                 = $0407;
  TT_MS_LANGID_GERMAN_SWITZERLAND             = $0807;
  TT_MS_LANGID_GERMAN_AUSTRIA                 = $0C07;
  TT_MS_LANGID_GERMAN_LUXEMBOURG              = $1007;
  TT_MS_LANGID_GERMAN_LIECHTENSTEIN           = $1407;
  TT_MS_LANGID_GREEK_GREECE                   = $0408;
  TT_MS_LANGID_ENGLISH_UNITED_STATES          = $0409;
  TT_MS_LANGID_ENGLISH_UNITED_KINGDOM         = $0809;
  TT_MS_LANGID_ENGLISH_AUSTRALIA              = $0C09;
  TT_MS_LANGID_ENGLISH_CANADA                 = $1009;
  TT_MS_LANGID_ENGLISH_NEW_ZEALAND            = $1409;
  TT_MS_LANGID_ENGLISH_IRELAND                = $1809;
  TT_MS_LANGID_ENGLISH_SOUTH_AFRICA           = $1C09;
  TT_MS_LANGID_ENGLISH_JAMAICA                = $2009;
  TT_MS_LANGID_ENGLISH_CARIBBEAN              = $2409;
  TT_MS_LANGID_ENGLISH_BELIZE                 = $2809;
  TT_MS_LANGID_ENGLISH_TRINIDAD               = $2C09;
  TT_MS_LANGID_ENGLISH_ZIMBABWE               = $3009;
  TT_MS_LANGID_ENGLISH_PHILIPPINES            = $3409;
  TT_MS_LANGID_ENGLISH_INDIA                  = $4009;
  TT_MS_LANGID_ENGLISH_MALAYSIA               = $4409;
  TT_MS_LANGID_ENGLISH_SINGAPORE              = $4809;
  TT_MS_LANGID_SPANISH_SPAIN_TRADITIONAL_SORT = $040A;
  TT_MS_LANGID_SPANISH_MEXICO                 = $080A;
  TT_MS_LANGID_SPANISH_SPAIN_MODERN_SORT      = $0C0A;
  TT_MS_LANGID_SPANISH_GUATEMALA              = $100A;
  TT_MS_LANGID_SPANISH_COSTA_RICA             = $140A;
  TT_MS_LANGID_SPANISH_PANAMA                 = $180A;
  TT_MS_LANGID_SPANISH_DOMINICAN_REPUBLIC     = $1C0A;
  TT_MS_LANGID_SPANISH_VENEZUELA              = $200A;
  TT_MS_LANGID_SPANISH_COLOMBIA               = $240A;
  TT_MS_LANGID_SPANISH_PERU                   = $280A;
  TT_MS_LANGID_SPANISH_ARGENTINA              = $2C0A;
  TT_MS_LANGID_SPANISH_ECUADOR                = $300A;
  TT_MS_LANGID_SPANISH_CHILE                  = $340A;
  TT_MS_LANGID_SPANISH_URUGUAY                = $380A;
  TT_MS_LANGID_SPANISH_PARAGUAY               = $3C0A;
  TT_MS_LANGID_SPANISH_BOLIVIA                = $400A;
  TT_MS_LANGID_SPANISH_EL_SALVADOR            = $440A;
  TT_MS_LANGID_SPANISH_HONDURAS               = $480A;
  TT_MS_LANGID_SPANISH_NICARAGUA              = $4C0A;
  TT_MS_LANGID_SPANISH_PUERTO_RICO            = $500A;
  TT_MS_LANGID_SPANISH_UNITED_STATES          = $540A;
  TT_MS_LANGID_FINNISH_FINLAND                = $040B;
  TT_MS_LANGID_FRENCH_FRANCE                  = $040C;
  TT_MS_LANGID_FRENCH_BELGIUM                 = $080C;
  TT_MS_LANGID_FRENCH_CANADA                  = $0C0C;
  TT_MS_LANGID_FRENCH_SWITZERLAND             = $100C;
  TT_MS_LANGID_FRENCH_LUXEMBOURG              = $140C;
  TT_MS_LANGID_FRENCH_MONACO                  = $180C;
  TT_MS_LANGID_HEBREW_ISRAEL                  = $040D;
  TT_MS_LANGID_HUNGARIAN_HUNGARY              = $040E;
  TT_MS_LANGID_ICELANDIC_ICELAND              = $040F;
  TT_MS_LANGID_ITALIAN_ITALY                  = $0410;
  TT_MS_LANGID_ITALIAN_SWITZERLAND            = $0810;
  TT_MS_LANGID_JAPANESE_JAPAN                 = $0411;
  TT_MS_LANGID_KOREAN_KOREA                   = $0412;
  TT_MS_LANGID_DUTCH_NETHERLANDS              = $0413;
  TT_MS_LANGID_DUTCH_BELGIUM                  = $0813;
  TT_MS_LANGID_NORWEGIAN_NORWAY_BOKMAL        = $0414;
  TT_MS_LANGID_NORWEGIAN_NORWAY_NYNORSK       = $0814;
  TT_MS_LANGID_POLISH_POLAND                  = $0415;
  TT_MS_LANGID_PORTUGUESE_BRAZIL              = $0416;
  TT_MS_LANGID_PORTUGUESE_PORTUGAL            = $0816;
  TT_MS_LANGID_ROMANSH_SWITZERLAND            = $0417;
  TT_MS_LANGID_ROMANIAN_ROMANIA               = $0418;
  TT_MS_LANGID_RUSSIAN_RUSSIA                 = $0419;
  TT_MS_LANGID_CROATIAN_CROATIA               = $041A;
  TT_MS_LANGID_SERBIAN_SERBIA_LATIN           = $081A;
  TT_MS_LANGID_SERBIAN_SERBIA_CYRILLIC        = $0C1A;
  TT_MS_LANGID_CROATIAN_BOSNIA_HERZEGOVINA    = $101A;
  TT_MS_LANGID_BOSNIAN_BOSNIA_HERZEGOVINA     = $141A;
  TT_MS_LANGID_SERBIAN_BOSNIA_HERZ_LATIN      = $181A;
  TT_MS_LANGID_SERBIAN_BOSNIA_HERZ_CYRILLIC   = $1C1A;
  TT_MS_LANGID_BOSNIAN_BOSNIA_HERZ_CYRILLIC   = $201A;
  TT_MS_LANGID_SLOVAK_SLOVAKIA                = $041B;
  TT_MS_LANGID_ALBANIAN_ALBANIA               = $041C;
  TT_MS_LANGID_SWEDISH_SWEDEN                 = $041D;
  TT_MS_LANGID_SWEDISH_FINLAND                = $081D;
  TT_MS_LANGID_THAI_THAILAND                  = $041E;
  TT_MS_LANGID_TURKISH_TURKEY                 = $041F;
  TT_MS_LANGID_URDU_PAKISTAN                  = $0420;
  TT_MS_LANGID_INDONESIAN_INDONESIA           = $0421;
  TT_MS_LANGID_UKRAINIAN_UKRAINE              = $0422;
  TT_MS_LANGID_BELARUSIAN_BELARUS             = $0423;
  TT_MS_LANGID_SLOVENIAN_SLOVENIA             = $0424;
  TT_MS_LANGID_ESTONIAN_ESTONIA               = $0425;
  TT_MS_LANGID_LATVIAN_LATVIA                 = $0426;
  TT_MS_LANGID_LITHUANIAN_LITHUANIA           = $0427;
  TT_MS_LANGID_TAJIK_TAJIKISTAN               = $0428;
  TT_MS_LANGID_VIETNAMESE_VIET_NAM            = $042A;
  TT_MS_LANGID_ARMENIAN_ARMENIA               = $042B;
  TT_MS_LANGID_AZERI_AZERBAIJAN_LATIN         = $042C;
  TT_MS_LANGID_AZERI_AZERBAIJAN_CYRILLIC      = $082C;
  TT_MS_LANGID_BASQUE_BASQUE                  = $042D;
  TT_MS_LANGID_UPPER_SORBIAN_GERMANY          = $042E;
  TT_MS_LANGID_LOWER_SORBIAN_GERMANY          = $082E;
  TT_MS_LANGID_MACEDONIAN_MACEDONIA           = $042F;
  TT_MS_LANGID_SETSWANA_SOUTH_AFRICA          = $0432;
  TT_MS_LANGID_ISIXHOSA_SOUTH_AFRICA          = $0434;
  TT_MS_LANGID_ISIZULU_SOUTH_AFRICA           = $0435;
  TT_MS_LANGID_AFRIKAANS_SOUTH_AFRICA         = $0436;
  TT_MS_LANGID_GEORGIAN_GEORGIA               = $0437;
  TT_MS_LANGID_FAEROESE_FAEROE_ISLANDS        = $0438;
  TT_MS_LANGID_HINDI_INDIA                    = $0439;
  TT_MS_LANGID_MALTESE_MALTA                  = $043A;
  TT_MS_LANGID_SAMI_NORTHERN_NORWAY           = $043B;
  TT_MS_LANGID_SAMI_NORTHERN_SWEDEN           = $083B;
  TT_MS_LANGID_SAMI_NORTHERN_FINLAND          = $0C3B;
  TT_MS_LANGID_SAMI_LULE_NORWAY               = $103B;
  TT_MS_LANGID_SAMI_LULE_SWEDEN               = $143B;
  TT_MS_LANGID_SAMI_SOUTHERN_NORWAY           = $183B;
  TT_MS_LANGID_SAMI_SOUTHERN_SWEDEN           = $1C3B;
  TT_MS_LANGID_SAMI_SKOLT_FINLAND             = $203B;
  TT_MS_LANGID_SAMI_INARI_FINLAND             = $243B;
  TT_MS_LANGID_IRISH_IRELAND                  = $083C;
  TT_MS_LANGID_MALAY_MALAYSIA                 = $043E;
  TT_MS_LANGID_MALAY_BRUNEI_DARUSSALAM        = $083E;
  TT_MS_LANGID_KAZAKH_KAZAKHSTAN              = $043F;
  TT_MS_LANGID_KYRGYZ_KYRGYZSTAN              = $0440; {Cyrillic}
  TT_MS_LANGID_KISWAHILI_KENYA                = $0441;
  TT_MS_LANGID_TURKMEN_TURKMENISTAN           = $0442;
  TT_MS_LANGID_UZBEK_UZBEKISTAN_LATIN         = $0443;
  TT_MS_LANGID_UZBEK_UZBEKISTAN_CYRILLIC      = $0843;
  TT_MS_LANGID_TATAR_RUSSIA                   = $0444;
  TT_MS_LANGID_BENGALI_INDIA                  = $0445;
  TT_MS_LANGID_BENGALI_BANGLADESH             = $0845;
  TT_MS_LANGID_PUNJABI_INDIA                  = $0446;
  TT_MS_LANGID_GUJARATI_INDIA                 = $0447;
  TT_MS_LANGID_ODIA_INDIA                     = $0448;
  TT_MS_LANGID_TAMIL_INDIA                    = $0449;
  TT_MS_LANGID_TELUGU_INDIA                   = $044A;
  TT_MS_LANGID_KANNADA_INDIA                  = $044B;
  TT_MS_LANGID_MALAYALAM_INDIA                = $044C;
  TT_MS_LANGID_ASSAMESE_INDIA                 = $044D;
  TT_MS_LANGID_MARATHI_INDIA                  = $044E;
  TT_MS_LANGID_SANSKRIT_INDIA                 = $044F;
  TT_MS_LANGID_MONGOLIAN_MONGOLIA             = $0450; {Cyrillic}
  TT_MS_LANGID_MONGOLIAN_PRC                  = $0850;
  TT_MS_LANGID_TIBETAN_PRC                    = $0451;
  TT_MS_LANGID_WELSH_UNITED_KINGDOM           = $0452;
  TT_MS_LANGID_KHMER_CAMBODIA                 = $0453;
  TT_MS_LANGID_LAO_LAOS                       = $0454;
  TT_MS_LANGID_GALICIAN_GALICIAN              = $0456;
  TT_MS_LANGID_KONKANI_INDIA                  = $0457;
  TT_MS_LANGID_SYRIAC_SYRIA                   = $045A;
  TT_MS_LANGID_SINHALA_SRI_LANKA              = $045B;
  TT_MS_LANGID_INUKTITUT_CANADA               = $045D;
  TT_MS_LANGID_INUKTITUT_CANADA_LATIN         = $085D;
  TT_MS_LANGID_AMHARIC_ETHIOPIA               = $045E;
  TT_MS_LANGID_TAMAZIGHT_ALGERIA              = $085F;
  TT_MS_LANGID_NEPALI_NEPAL                   = $0461;
  TT_MS_LANGID_FRISIAN_NETHERLANDS            = $0462;
  TT_MS_LANGID_PASHTO_AFGHANISTAN             = $0463;
  TT_MS_LANGID_FILIPINO_PHILIPPINES           = $0464;
  TT_MS_LANGID_DHIVEHI_MALDIVES               = $0465;
  TT_MS_LANGID_HAUSA_NIGERIA                  = $0468;
  TT_MS_LANGID_YORUBA_NIGERIA                 = $046A;
  TT_MS_LANGID_QUECHUA_BOLIVIA                = $046B;
  TT_MS_LANGID_QUECHUA_ECUADOR                = $086B;
  TT_MS_LANGID_QUECHUA_PERU                   = $0C6B;
  TT_MS_LANGID_SESOTHO_SA_LEBOA_SOUTH_AFRICA  = $046C;
  TT_MS_LANGID_BASHKIR_RUSSIA                 = $046D;
  TT_MS_LANGID_LUXEMBOURGISH_LUXEMBOURG       = $046E;
  TT_MS_LANGID_GREENLANDIC_GREENLAND          = $046F;
  TT_MS_LANGID_IGBO_NIGERIA                   = $0470;
  TT_MS_LANGID_YI_PRC                         = $0478;
  TT_MS_LANGID_MAPUDUNGUN_CHILE               = $047A;
  TT_MS_LANGID_MOHAWK_MOHAWK                  = $047C;
  TT_MS_LANGID_BRETON_FRANCE                  = $047E;
  TT_MS_LANGID_UIGHUR_PRC                     = $0480;
  TT_MS_LANGID_MAORI_NEW_ZEALAND              = $0481;
  TT_MS_LANGID_OCCITAN_FRANCE                 = $0482;
  TT_MS_LANGID_CORSICAN_FRANCE                = $0483;
  TT_MS_LANGID_ALSATIAN_FRANCE                = $0484;
  TT_MS_LANGID_YAKUT_RUSSIA                   = $0485;
  TT_MS_LANGID_KICHE_GUATEMALA                = $0486;
  TT_MS_LANGID_KINYARWANDA_RWANDA             = $0487;
  TT_MS_LANGID_WOLOF_SENEGAL                  = $0488;
  TT_MS_LANGID_DARI_AFGHANISTAN               = $048C;

  TT_NAME_ID_COPYRIGHT             =  0;
  TT_NAME_ID_FONT_FAMILY           =  1;
  TT_NAME_ID_FONT_SUBFAMILY        =  2;
  TT_NAME_ID_UNIQUE_ID             =  3;
  TT_NAME_ID_FULL_NAME             =  4;
  TT_NAME_ID_VERSION_STRING        =  5;
  TT_NAME_ID_PS_NAME               =  6;
  TT_NAME_ID_TRADEMARK             =  7;

  {the following values are from the OpenType spec}
  TT_NAME_ID_MANUFACTURER          =  8;
  TT_NAME_ID_DESIGNER              =  9;
  TT_NAME_ID_DESCRIPTION           = 10;
  TT_NAME_ID_VENDOR_URL            = 11;
  TT_NAME_ID_DESIGNER_URL          = 12;
  TT_NAME_ID_LICENSE               = 13;
  TT_NAME_ID_LICENSE_URL           = 14;
  {number 15 is reserved}
  TT_NAME_ID_TYPOGRAPHIC_FAMILY    = 16;
  TT_NAME_ID_TYPOGRAPHIC_SUBFAMILY = 17;
  TT_NAME_ID_MAC_FULL_NAME         = 18;

  {The following code is new as of 2000-01-21}
  TT_NAME_ID_SAMPLE_TEXT           = 19;

  {This is new in OpenType 1.3}
  TT_NAME_ID_CID_FINDFONT_NAME     = 20;

  {This is new in OpenType 1.5}
  TT_NAME_ID_WWS_FAMILY            = 21;
  TT_NAME_ID_WWS_SUBFAMILY         = 22;

  {This is new in OpenType 1.7}
  TT_NAME_ID_LIGHT_BACKGROUND      = 23;
  TT_NAME_ID_DARK_BACKGROUND       = 24;

  {This is new in OpenType 1.8}
  TT_NAME_ID_VARIATIONS_PREFIX     = 25;

  {these two values are deprecated}
  TT_NAME_ID_PREFERRED_FAMILY      = TT_NAME_ID_TYPOGRAPHIC_FAMILY;
  TT_NAME_ID_PREFERRED_SUBFAMILY   = TT_NAME_ID_TYPOGRAPHIC_SUBFAMILY;

type

  FT_Bool = boolean;
  FT_FWord = smallint;
  FT_UFWord = word;
  FT_Char = AnsiChar;
  FT_Byte = byte;
  FT_String = AnsiChar;
  FT_Short = smallint;
  FT_UShort = word;
  FT_Int = longint;
  FT_UInt = longword;
  {$if defined(cpu64) and not(defined(win64) and defined(cpux86_64))}
  FT_Long = int64;
  FT_ULong = qword;
  FT_Pos = int64;
  {$ELSE}
  FT_Long = longint;
  FT_ULong = longword;
  FT_Pos = longint;
  {$ENDIF}
  FT_F2Dot14 = smallint;
  FT_F26Dot6 = longint;
  FT_Fixed = FT_Long;
  FT_Error = longint;
  FT_Pointer = pointer;
  //FT_Offset = size_t;
  //FT_PtrDist = size_t;

  FT_Render_Mode = (FT_RENDER_MODE_NORMAL, FT_RENDER_MODE_LIGHT,
      FT_RENDER_MODE_MONO, FT_RENDER_MODE_LCD, FT_RENDER_MODE_LCD_V,
      FT_RENDER_MODE_MAX);

  FT_UnitVector_ = record
      x : FT_F2Dot14;
      y : FT_F2Dot14;
   end;
  FT_UnitVector = FT_UnitVector_;

  FT_Matrix = record
      xx : FT_Fixed;
      xy : FT_Fixed;
      yx : FT_Fixed;
      yy : FT_Fixed;
   end;
  PFT_Matrix = ^FT_Matrix;

  FT_Data = record
      pointer : ^FT_Byte;
      length : FT_Int;
   end;

  FT_Generic_Finalizer = procedure (AnObject:pointer);cdecl;

  FT_Generic = record
      data : pointer;
      finalizer : FT_Generic_Finalizer;
   end;

  FT_Glyph_Metrics = record
    width : FT_Pos;
    height : FT_Pos;
    horiBearingX : FT_Pos;
    horiBearingY : FT_Pos;
    horiAdvance : FT_Pos;
    vertBearingX : FT_Pos;
    vertBearingY : FT_Pos;
    vertAdvance : FT_Pos;
  end;

  FT_Bitmap_Size = record
    height : FT_Short;
    width : FT_Short;
  end;
  AFT_Bitmap_Size = array [0..1023] of FT_Bitmap_Size;
  PFT_Bitmap_Size = ^AFT_Bitmap_Size;

  FT_Vector = record
    x : FT_Pos;
    y : FT_Pos;
  end;
  PFT_Vector = ^FT_Vector;

  FT_BBox = record
    xMin, yMin : FT_Pos;
    xMax, yMax : FT_Pos;
  end;
  PFT_BBox = ^FT_BBox;

  FT_Bitmap = record
    rows : integer;
    width : integer;
    pitch : integer;
    buffer : pointer;
    num_grays : shortint;
    pixel_mode : AnsiChar;
    palette_mode : AnsiChar;
    palette : pointer;
  end;

  FT_Outline = record
    n_contours,
    n_points : smallint;
    points : PFT_Vector;
    tags : PAnsiChar;
    contours : ^smallint;
    flags : integer;
  end;
  PFT_Outline = ^FT_Outline;

  FT_Outline_MoveToFunc = function(const to_: PFT_Vector; user: Pointer): integer;
  FT_Outline_LineToFunc = function(const to_: PFT_Vector; user: Pointer): integer;
  FT_Outline_ConicToFunc = function(const control, to_: PFT_Vector; user: Pointer): integer;
  FT_Outline_CubicToFunc = function(const control1, control2, to_: PFT_Vector; user: Pointer): integer;

  FT_Outline_Funcs = record
    move_to: FT_Outline_MoveToFunc;
    line_to: FT_Outline_LineToFunc;
    conic_to: FT_Outline_ConicToFunc;
    cubic_to: FT_Outline_CubicToFunc;
    shift: integer;
    delta: FT_Pos;
  end;
  PFT_Outline_Funcs = ^FT_Outline_Funcs;

  FT_Size_Metrics = record
    x_ppem : FT_UShort;
    y_ppem : FT_UShort;
    x_scale : FT_Fixed;
    y_scale : FT_Fixed;
    ascender : FT_Pos;
    descender : FT_Pos;
    height : FT_Pos;
    max_advance : FT_Pos;
  end;


  PFT_Library = ^TFT_Library;
  //PPFT_Library = ^PFT_Library;
  PFT_Face = ^TFT_Face;
  //PPFT_Face = ^PFT_Face;
  PFT_Charmap = ^TFT_Charmap;
  PPFT_Charmap = ^PFT_Charmap;
  PFT_GlyphSlot = ^TFT_GlyphSlot;
  PFT_Subglyph = ^TFT_Subglyph;
  PFT_Size = ^TFT_Size;

  PFT_Glyph = ^TFT_Glyph;
  //PPFT_Glyph = ^PFT_Glyph;
  PFT_BitmapGlyph = ^TFT_BitmapGlyph;
  PFT_OutlineGlyph = ^TFT_OutlineGlyph;


  TFT_Library = record
  end;

  TFT_Charmap = record
    face : PFT_Face;
    encoding : FT_Encoding;
    platform_id, encoding_id : FT_UShort;
  end;

  TFT_Size = record
    face : PFT_Face;
    generic : FT_Generic;
    metrics : FT_Size_Metrics;
    //internal : FT_Size_Internal;
  end;

  TFT_Subglyph = record  // TODO
  end;

  TFT_GlyphSlot = record
    alibrary : PFT_Library;
    face : PFT_Face;
    next : PFT_GlyphSlot;
    flags : FT_UInt;
    generic : FT_Generic;
    metrics : FT_Glyph_Metrics;
    linearHoriAdvance : FT_Fixed;
    linearVertAdvance : FT_Fixed;
    advance : FT_Vector;
    format : longword;
    bitmap : FT_Bitmap;
    bitmap_left : FT_Int;
    bitmap_top : FT_Int;
    outline : FT_Outline;
    num_subglyphs : FT_UInt;
    subglyphs : PFT_SubGlyph;
    control_data : pointer;
    control_len : longint;
    other : pointer;
  end;

  TFT_Face = record
    num_faces : FT_Long;
    face_index : FT_Long;
    face_flags : FT_Long;
    style_flags : FT_Long;
    num_glyphs : FT_Long;
    family_name : PAnsiChar;
    style_name : PAnsiChar;
    num_fixed_sizes : FT_Int;
    available_sizes : PFT_Bitmap_Size;     // is array
    num_charmaps : FT_Int;
    charmaps : PPFT_CharMap;               // is array
    generic : FT_Generic;
    bbox : FT_BBox;
    units_per_EM : FT_UShort;
    ascender : FT_Short;
    descender : FT_Short;
    height : FT_Short;
    max_advance_width : FT_Short;
    max_advance_height : FT_Short;
    underline_position : FT_Short;
    underline_thickness : FT_Short;
    glyph : PFT_GlyphSlot;
    size : PFT_Size;
    charmap : PFT_CharMap;
  end;

  TFT_Glyph = record
    FTlibrary : PFT_Library;
    clazz : pointer;
    aFormat : longword;
    advance : FT_Vector;
  end;

  TFT_BitmapGlyph = record
    root : TFT_Glyph;
    left, top : FT_Int;
    bitmap : FT_Bitmap;
  end;

  TFT_OutlineGlyph = record
    root : TFT_Glyph;
    outline : FT_Outline;
  end;

  TFT_SfntName = record
    platform_id:FT_UShort;
    encoding_id:FT_UShort;
    language_id:FT_UShort;
    name_id:FT_UShort;
    aString:pbyte;        {this string is *not* null-terminated!}
    String_len:FT_UInt;   {in bytes}
  end;

  TFT_Sfnt_Tag = (FT_SFNT_HEAD, FT_SFNT_MAXP, FT_SFNT_OS2, FT_SFNT_HHEA,
    FT_SFNT_VHEA, FT_SFNT_POST, FT_SFNT_PCLT, FT_SFNT_MAX);

  PTT_Header = ^TTT_Header;
  TTT_Header = record
    Table_Version : FT_Fixed;
    Font_Revision : FT_Fixed;

    CheckSum_Adjust : FT_Long;
    Magic_Number : FT_Long;

    Flags : FT_UShort;
    Units_Per_EM : FT_UShort;

    Created : array [0..1] of FT_ULong;
    Modified : array [0..1] of FT_ULong;

    xMin : FT_Short;
    yMin : FT_Short;
    xMax : FT_Short;
    FyMax : FT_Short;

    Mac_Style : FT_UShort;
    Lowest_Rec_PPEM : FT_UShort;

    Font_Direction : FT_Short;
    Index_To_Loc_Format : FT_Short;
    Glyph_Data_Format : FT_Short;
  end;

  PTT_OS = ^TTT_OS2;
  TTT_OS2 = record
    version : FT_UShort;                {0x0001 - more or 0xFFFF}
    xAvgCharWidth : FT_Short;
    usWeightClass : FT_UShort;
    usWidthClass : FT_UShort;
    fsType : FT_UShort;
    ySubscriptXSize : FT_Short;
    ySubscriptYSize : FT_Short;
    ySubscriptXOffset : FT_Short;
    ySubscriptYOffset : FT_Short;
    ySuperscriptXSize : FT_Short;
    ySuperscriptYSize : FT_Short;
    ySuperscriptXOffset : FT_Short;
    ySuperscriptYOffset : FT_Short;
    yStrikeoutSize : FT_Short;
    yStrikeoutPosition : FT_Short;
    sFamilyClass : FT_Short;

    panose : array [0..9] of FT_Byte;

    ulUnicodeRange1 : FT_ULong;         {Bits 0-31}
    ulUnicodeRange2 : FT_ULong;         {Bits 32-63}
    ulUnicodeRange3 : FT_ULong;         {Bits 64-95}
    ulUnicodeRange4 : FT_ULong;         {Bits 96-127}

    achVendID : array [0..3]  of FT_Char;

    fsSelection : FT_UShort;
    usFirstCharIndex : FT_UShort;
    usLastCharIndex : FT_UShort;
    sTypoAscender : FT_Short;
    sTypoDescender : FT_Short;
    sTypoLineGap : FT_Short;
    usWinAscent : FT_UShort;
    usWinDescent : FT_UShort;

    {only version 1 and higher:}

    ulCodePageRange1 : FT_ULong;        {Bits 0-31}
    ulCodePageRange2 : FT_ULong;        {Bits 32-63}

    {only version 2 and higher:}

    sxHeight : FT_Short;
    sCapHeight : FT_Short;
    usDefaultChar : FT_UShort;
    usBreakChar : FT_UShort;
    usMaxContext : FT_UShort;

    {only version 5 and higher:}

    usLowerOpticalPointSize : FT_UShort;{in twips (1/20 points)}
    usUpperOpticalPointSize : FT_UShort;{in twips (1/20 points)}
  end;

  PTT_HoriHeader = ^TTT_HoriHeader;
  TTT_HoriHeader = record
    Version : FT_Fixed;
      Ascender : FT_Short;
      Descender : FT_Short;
      Line_Gap : FT_Short;

      advance_Width_Max : FT_UShort;    {advance width maximum }

      min_Left_Side_Bearing : FT_Short; {minimum left-sb}
      min_Right_Side_Bearing : FT_Short;{minimum right-sb}
      xMax_Extent : FT_Short;           {xmax extents}
      caret_Slope_Rise : FT_Short;
      caret_Slope_Run : FT_Short;
      caret_Offset : FT_Short;

      Reserved : array [0..3] of FT_Short;

      metric_Data_Format : FT_Short;
      number_Of_HMetrics : FT_UShort;

      {The following fields are not defined by the OpenType specification}
      {but they are used to connect the metrics header to the relevant}
      {'hmtx' table.}

      long_metrics : pointer;
      short_metrics : pointer;
    end;

// Macro
function FT_IS_SCALABLE(face: PFT_Face): boolean;

{$IFNDEF DYNAMIC}

//Base Interface
function FT_Done_Face(face: PFT_Face): integer; cdecl; external FreeTypeDLL Name 'FT_Done_Face';
function FT_Done_FreeType(alibrary: PFT_Library): integer; cdecl; external FreeTypeDLL Name 'FT_Done_FreeType';
function FT_Get_Char_Index(face: PFT_Face; charcode: FT_ULong): FT_UInt; cdecl; external FreeTypeDLL Name 'FT_Get_Char_Index';
function FT_Get_Kerning(face: PFT_Face; left_glyph, right_glyph, kern_mode: FT_UInt; out akerning: FT_Vector): integer; cdecl; external FreeTypeDLL Name 'FT_Get_Kerning';
function FT_Init_FreeType(var alibrary: PFT_Library): integer; cdecl; external FreeTypeDLL Name 'FT_Init_FreeType';
function FT_Load_Char(face: PFT_Face; charcode: FT_ULong; load_flags: longint): integer; cdecl; external FreeTypeDLL Name 'FT_Load_Char';
function FT_Load_Glyph(face: PFT_Face; glyph_index: FT_UInt; load_flags: longint): integer; cdecl; external FreeTypeDLL Name 'FT_Load_Glyph';
function FT_New_Face(alibrary: PFT_Library; filepathname: PAnsiChar; face_index: integer; var aface: PFT_Face): integer; cdecl; external FreeTypeDLL Name 'FT_New_Face';
function FT_Set_Char_Size(face: PFT_Face; char_width, char_height: FT_F26dot6; horz_res, vert_res: FT_UInt): integer; cdecl; external FreeTypeDLL Name 'FT_Set_Char_Size';
function FT_Set_Pixel_Sizes(face: PFT_Face; pixel_width, pixel_height: FT_UInt): integer; cdecl; external FreeTypeDLL Name 'FT_Set_Pixel_Sizes';
procedure FT_Set_Transform(face: PFT_Face; matrix: PFT_Matrix; delta: PFT_Vector); cdecl; external FreeTypeDLL Name 'FT_Set_Transform';

function FT_Get_Sfnt_Name_Count(face: PFT_Face): FT_UInt; cdecl; external FreeTypeDLL Name 'FT_Get_Sfnt_Name_Count';
function FT_Get_Sfnt_Name(face: PFT_Face; idx: FT_UInt; var aname: TFT_SfntName): integer; cdecl; external FreeTypeDLL Name 'FT_Get_Sfnt_Name';

function FT_Get_Sfnt_Table(face: PFT_Face; tag: TFT_Sfnt_Tag): pointer; cdecl; external FreeTypeDLL Name 'FT_Get_Sfnt_Table';

//Outline Processing
function FT_Outline_Decompose(outline: PFT_Outline; const func_interface: PFT_Outline_Funcs; user: Pointer): integer; cdecl; external FreeTypeDLL Name 'FT_Outline_Decompose';

//FreeType Version
procedure FT_Library_Version(alibrary: PFT_Library; var amajor, aminor, apatch: integer); cdecl; external FreeTypeDLL Name 'FT_Library_Version';

//Glyph Management
function FT_Get_Glyph(slot: PFT_GlyphSlot; out aglyph: PFT_Glyph): integer; cdecl; external FreeTypeDLL Name 'FT_Get_Glyph';
function FT_Glyph_Copy(Source: PFT_Glyph; out target: PFT_Glyph): integer; cdecl; external FreeTypeDLL Name 'FT_Glyph_Copy';
function FT_Glyph_To_Bitmap(var the_glyph: PFT_Glyph; render_mode: FT_Render_Mode; origin: PFT_Vector; Destroy: FT_Bool): integer; cdecl; external FreeTypeDLL Name 'FT_Glyph_To_Bitmap';
function FT_Glyph_Transform(glyph: PFT_Glyph; matrix: PFT_Matrix; delta: PFT_Vector): integer; cdecl; external FreeTypeDLL Name 'FT_Glyph_Transform';
procedure FT_Done_Glyph(glyph: PFT_Glyph); cdecl; external FreeTypeDLL Name 'FT_Done_Glyph';
procedure FT_Glyph_Get_CBox(glyph: PFT_Glyph; bbox_mode: FT_UInt; var acbox: FT_BBox); cdecl; external FreeTypeDLL Name 'FT_Glyph_Get_CBox';

{$ELSE}
    //Base Interface
Type
  TFT_Done_Face = function(face: PFT_Face): integer; cdecl;
  TFT_Done_FreeType = function(alibrary: PFT_Library): integer; cdecl;
  TFT_Get_Char_Index = function(face: PFT_Face; charcode: FT_ULong): FT_UInt; cdecl;
  TFT_Get_Kerning = function(face: PFT_Face; left_glyph, right_glyph, kern_mode: FT_UInt; out akerning: FT_Vector): integer; cdecl;
  TFT_Init_FreeType = function(var alibrary: PFT_Library): integer; cdecl;
  TFT_Load_Char = function(face: PFT_Face; charcode: FT_ULong; load_flags: longint): integer; cdecl;
  TFT_Load_Glyph = function(face: PFT_Face; glyph_index: FT_UInt; load_flags: longint): integer; cdecl;
  TFT_New_Face = function(alibrary: PFT_Library; filepathname: PAnsiChar; face_index: integer; var aface: PFT_Face): integer; cdecl;
  TFT_Set_Char_Size = function(face: PFT_Face; char_width, char_height: FT_F26dot6; horz_res, vert_res: FT_UInt): integer; cdecl;
  TFT_Set_Pixel_Sizes = function(face: PFT_Face; pixel_width, pixel_height: FT_UInt): integer; cdecl;
  TFT_Set_Transform = procedure(face: PFT_Face; matrix: PFT_Matrix; delta: PFT_Vector); cdecl;

  TFT_Get_Sfnt_Name_Count = function(face: PFT_Face): FT_UInt; cdecl;
  TFT_Get_Sfnt_Name = function(face: PFT_Face; idx: FT_UInt; var aname: TFT_SfntName): integer; cdecl;

  TFT_Get_Sfnt_Table = function(face: PFT_Face; tag: TFT_Sfnt_Tag): pointer; cdecl;

    //Outline Processing
  TFT_Outline_Decompose = function(outline: PFT_Outline; const func_interface: PFT_Outline_Funcs; user: Pointer): integer; cdecl;

    //FreeType Version
  TFT_Library_Version = procedure(alibrary: PFT_Library; var amajor, aminor, apatch: integer); cdecl;
  //Glyph Management
  TFT_Get_Glyph = function(slot: PFT_GlyphSlot; out aglyph: PFT_Glyph): integer; cdecl;
  TFT_Glyph_Copy = function(Source: PFT_Glyph; out target: PFT_Glyph): integer; cdecl;
  TFT_Glyph_To_Bitmap = function(var the_glyph: PFT_Glyph; render_mode: FT_Render_Mode; origin: PFT_Vector; Destroy: FT_Bool): integer; cdecl;
  TFT_Glyph_Transform = function(glyph: PFT_Glyph; matrix: PFT_Matrix; delta: PFT_Vector): integer; cdecl;
  TFT_Done_Glyph = procedure(glyph: PFT_Glyph); cdecl;
  TFT_Glyph_Get_CBox = procedure(glyph: PFT_Glyph; bbox_mode: FT_UInt; var acbox: FT_BBox); cdecl;

Var
  FT_Done_Face : TFT_Done_Face;
  FT_Done_FreeType : TFT_Done_FreeType;
  FT_Get_Char_Index : TFT_Get_Char_Index;
  FT_Get_Kerning : TFT_Get_Kerning;
  FT_Init_FreeType : TFT_Init_FreeType;
  FT_Load_Char : TFT_Load_Char;
  FT_Load_Glyph : TFT_Load_Glyph;
  FT_New_Face : TFT_New_Face;
  FT_Set_Char_Size : TFT_Set_Char_Size;
  FT_Set_Pixel_Sizes : TFT_Set_Pixel_Sizes;
  FT_Set_Transform : TFT_Set_Transform;
  FT_Get_Sfnt_Name_Count : TFT_Get_Sfnt_Name_Count;
  FT_Get_Sfnt_Name : TFT_Get_Sfnt_Name;
  FT_Get_Sfnt_Table : TFT_Get_Sfnt_Table;


  //Outline Processing
  FT_Outline_Decompose : TFT_Outline_Decompose;

  //FreeType Version
  FT_Library_Version : TFT_Library_Version;

  //Glyph Management
  FT_Get_Glyph : TFT_Get_Glyph;
  FT_Glyph_Copy : TFT_Glyph_Copy;
  FT_Glyph_To_Bitmap : TFT_Glyph_To_Bitmap;
  FT_Glyph_Transform : TFT_Glyph_Transform;
  FT_Done_Glyph : TFT_Done_Glyph;
  FT_Glyph_Get_CBox : TFT_Glyph_Get_CBox;

function InitializeFreetype(const LibraryName: UnicodeString = ''): Integer;
function  InitializeFreetype(const LibraryName: AnsiString):integer;
function TryInitializeFreetype(const LibraryName: Unicodestring = ''): Integer;
procedure ReleaseFreetype;
{$ENDIF}

implementation

function FT_IS_SCALABLE(face: PFT_Face): boolean;

begin
  Result := (face^.face_flags and FT_FACE_FLAG_SCALABLE) = 1;
end;

{$IFDEF DYNAMIC}
var
  FreetypeLibraryHandle: TLibHandle = NilHandle;
  FreetypeDefaultLibrary: String = FreeTypeDLL;
  FreetypeLoadedLibrary: UnicodeString = '';
  RefCount: Integer = 0;

resourcestring
  SErrLoadFailed     = 'Can not load Freetype library "%s". Check your installation.';
  SErrAlreadyLoaded  = 'Freetype interface already initialized from library %s.';

procedure LoadAddresses(LibHandle: TLibHandle);

begin
  pointer(FT_Done_FreeType) := GetProcedureAddress(LibHandle,'FT_Done_FreeType');
  pointer(FT_Get_Char_Index) := GetProcedureAddress(LibHandle,'FT_Get_Char_Index');
  pointer(FT_Get_Kerning) := GetProcedureAddress(LibHandle,'FT_Get_Kerning');
  pointer(FT_Init_FreeType) := GetProcedureAddress(LibHandle,'FT_Init_FreeType');
  pointer(FT_Load_Char) := GetProcedureAddress(LibHandle,'FT_Load_Char');
  pointer(FT_Load_Glyph) := GetProcedureAddress(LibHandle,'FT_Load_Glyph');
  pointer(FT_New_Face) := GetProcedureAddress(LibHandle,'FT_New_Face');
  pointer(FT_Set_Char_Size) := GetProcedureAddress(LibHandle,'FT_Set_Char_Size');
  pointer(FT_Set_Pixel_Sizes) := GetProcedureAddress(LibHandle,'FT_Set_Pixel_Sizes');
  pointer(FT_Set_Transform) := GetProcedureAddress(LibHandle,'FT_Set_Transform');
  pointer(FT_Get_Sfnt_Name_Count) := GetProcedureAddress(LibHandle,'FT_Get_Sfnt_Name_Count');
  pointer(FT_Get_Sfnt_Name) := GetProcedureAddress(LibHandle,'FT_Get_Sfnt_Name');
  pointer(FT_Get_Sfnt_Table) := GetProcedureAddress(LibHandle,'FT_Get_Sfnt_Table');
  pointer(FT_Outline_Decompose) := GetProcedureAddress(LibHandle,'FT_Outline_Decompose');
  pointer(FT_Library_Version) := GetProcedureAddress(LibHandle,'FT_Library_Version');
  pointer(FT_Get_Glyph) := GetProcedureAddress(LibHandle,'FT_Get_Glyph');
  pointer(FT_Glyph_Copy) := GetProcedureAddress(LibHandle,'FT_Glyph_Copy');
  pointer(FT_Glyph_To_Bitmap) := GetProcedureAddress(LibHandle,'FT_Glyph_To_Bitmap');
  pointer(FT_Glyph_Transform) := GetProcedureAddress(LibHandle,'FT_Glyph_Transform');
  pointer(FT_Done_Glyph) := GetProcedureAddress(LibHandle,'FT_Done_Glyph');
  pointer(FT_Glyph_Get_CBox) := GetProcedureAddress(LibHandle,'FT_Glyph_Get_CBox');
end;

procedure NilAllAddresses;

begin
  pointer(FT_Done_FreeType) := Nil;
  pointer(FT_Get_Char_Index) := Nil;
  pointer(FT_Get_Kerning) := Nil;
  pointer(FT_Init_FreeType) := Nil;
  pointer(FT_Load_Char) := Nil;
  pointer(FT_Load_Glyph) := Nil;
  pointer(FT_New_Face) := Nil;
  pointer(FT_Set_Char_Size) := Nil;
  pointer(FT_Set_Pixel_Sizes) := Nil;
  pointer(FT_Set_Transform) := Nil;
  pointer(FT_Get_Sfnt_Name_Count) := Nil;
  pointer(FT_Get_Sfnt_Name) := Nil;
  pointer(FT_Get_Sfnt_Table) := Nil;
  pointer(FT_Outline_Decompose) := Nil;
  pointer(FT_Library_Version) := Nil;
  pointer(FT_Get_Glyph) := Nil;
  pointer(FT_Glyph_Copy) := Nil;
  pointer(FT_Glyph_To_Bitmap) := Nil;
  pointer(FT_Glyph_Transform) := Nil;
  pointer(FT_Done_Glyph) := Nil;
  pointer(FT_Glyph_Get_CBox) := Nil;
end;


function TryInitializeFreetype(const LibraryName: UnicodeString): Integer;

Var
  N  : UnicodeString;
begin
  N:=LibraryName;
  if (N='') then
    N:=FreetypeDefaultLibrary;
  result:=InterlockedIncrement(RefCount);
  if result=1 then
    begin
    FreetypeLibraryHandle := LoadLibrary(N);
    if (FreetypeLibraryHandle = NilHandle) then
      begin
      RefCount:=0;
      Result:=0;
      end;
    FreetypeLoadedLibrary := N;
    LoadAddresses(FreetypeLibraryHandle);
    end;
end;

function  InitializeFreetype(const LibraryName: UnicodeString) :integer;

begin
  if (LibraryName<>'') and (FreetypeLoadedLibrary <> '') and (FreetypeLoadedLibrary <> LibraryName) then
    Raise EInoutError.CreateFmt(SErrAlreadyLoaded,[FreetypeLoadedLibrary]);
  Result:=TryInitializeFreetype(LibraryName);
  if result=0 then
    if LibraryName='' then
      Raise EInOutError.CreateFmt(SErrLoadFailed,[FreetypeDefaultLibrary])
    else
      Raise EInOutError.CreateFmt(SErrLoadFailed,[LibraryName]);
end;

function InitializeFreetype(const LibraryName: AnsiString):integer;
begin
  result:=InitializeFreetype(UnicodeString(LibraryName));
end;

procedure ReleaseFreetype;
begin
  if InterlockedDecrement(RefCount) <= 0 then
    begin
    if FreetypeLibraryHandle <> NilHandle then
      UnloadLibrary(FreetypeLibraryHandle);
    NilAllAddresses;
    FreetypeLibraryHandle := NilHandle;
    FreetypeLoadedLibrary := '';
    RefCount := 0;
    end;
end;
{$ENDIF}


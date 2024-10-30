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

unit uzefontttfpreloader;
{$INCLUDE zengineconfig.inc}

interface

uses
  sysutils,classes,bufstream,
  uzbLogIntf;

const
  maxNameID=26;

type
  TTTFFileType=(TTFTApple,TTFTMS,TTFTOther);

  TNameTableValueType=String;
  TTTFFileParams=record
    FileType:TTTFFileType;
    ValidTTFFile:boolean;
    //this from https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6name.html
    CopyrightNotice,               //{0    }Copyright notice.
    FontFamily,                    //{1    }Font Family.
    FontSubfamily,                 //{2    }Font Subfamily.
    UniqueSubfamily,               //{3    }Unique subfamily identification.
    FullName,                      //{4    }Full name of the font.
    Version,                       //{5    }Version of the name table.
    PostScriptName,                //{6    }PostScript name of the font. All PostScript names in a font must be identical. They may not be longer than 63 characters and the characters used are restricted to the set of printable ASCII characters (U+0021 through U+007E), less the ten characters '[', ']', '(', ')', '{', '}', '<', '>', '/', and '%'.
    TrademarkNotice,               //{7    }Trademark notice.
    ManufacturerName,              //{8    }Manufacturer name.
    DesignerName,                  //{9    }Designer; name of the designer of the typeface.
    Description,                   //{10   }Description; description of the typeface. Can contain revision information, usage recommendations, history, features, and so on.
    URLVendor,                     //{11   }URL of the font vendor (with procotol, e.g., http://, ftp://). If a unique serial number is embedded in the URL, it can be used to register the font.
    URLDesigner,                   //{12   }URL of the font designer (with protocol, e.g., http://, ftp://)
    LicenseDescription,            //{13   }License description; description of how the font may be legally used, or different example scenarios for licensed use. This field should be written in plain language, not legalese.
    LicenseInformationURL,         //{14   }License information URL, where additional licensing information can be found.
    Reserved,                      //{15   }Reserved
    PreferredFamily,               //{16   }Preferred Family. In Windows, the Family name is displayed in the font menu, and the Subfamily name is presented as the Style name. For historical reasons, font families have contained a maximum of four styles, but font designers may group more than four fonts to a single family. The Preferred Family and Preferred Subfamily IDs allow font designers to include the preferred family/subfamily groupings. These IDs are only present if they are different from IDs 1 and 2.
    PreferredSubfamily,            //{17   }Preferred Subfamily. In Windows, the Family name is displayed in the font menu, and the Subfamily name is presented as the Style name. For historical reasons, font families have contained a maximum of four styles, but font designers may group more than four fonts to a single family. The Preferred Family and Preferred Subfamily IDs allow font designers to include the preferred family/subfamily groupings. These IDs are only present if they are different from IDs 1 and 2.
    CompatibleFull,                //{18   }Compatible Full (macOS only). In QuickDraw, the menu name for a font is constructed using the FOND resource. This usually matches the Full Name. If you want the name of the font to appear differently than the Full Name, you can insert the Compatible Full Name in ID 18. This name is not used by macOS itself, but may be used by application developers (e.g., Adobe).
    SampleText,                    //{19   }Sample text. This can be the font name, or any other text that the designer thinks is the best sample text to show what the font looks like.
                                   //{20–24}Defined by OpenType.
    VariationsPostScriptNamePrefix //{25   }Variations PostScript Name Prefix. If present in a variable font, it may be used as the family prefix in the algorithm to generate PostScript names for variation fonts. See Adobe Technical Note #5902: “PostScript Name Generation for Variation Fonts” for details.
    :TNameTableValueType;
    FirstCharIndex:integer;//OS2Table
    LastCharIndex:integer;//OS2Table
    DefaultChar:integer;//OS2Table
  end;
function getTTFFileParams(const filename:String):TTTFFileParams;

implementation

const
  TTC_Tag = ( ord('t') shl 24 ) +
            ( ord('t') shl 16 ) +
            ( ord('c') shl 8  ) +
            ( ord(' ')        );

type

  //from TTTypes.pas
  UShort   = Word;     (* unsigned short integer, must be on 16 bits *)
  Short    = Smallint; (* signed short integer,   must be on 16 bits *)
  Long     = Longint;
  ULong    = LongWord; (* unsigned long integer, must be on 32 bits *)
  TT_Fixed = LongInt;  (* Signed Fixed 16.16 Single *)
  TStorage = array[0..16000] of Long;
  PStorage = ^TStorage;

  //not from TTTypes.pas
  uint8_t  = byte;     (* unsigned byte *)
  int8     = shortint;  (* signed byte *)


  //from TTTables.pas
  (* TrueType collection header *)
  //PTTCHeader=^TTTCHeader;
  TTTCHeader=record
    Tag            : Long;
    version        : TT_Fixed;
    DirCount       : ULong;
    TableDirectory : PStorage;
  end;

  //PTableDir=^TTableDir;
  TTableDir=record
    version        : TT_Fixed;(* should be $10000 *)
    numTables      : UShort;  (* Tables number    *)

    searchRange,              (* These parameters are only used  *)
    entrySelector,            (* for a dichotomy search in the   *)
    rangeShift     : UShort;  (* directory. We ignore them       *)
  end;

  TTableDirEntry=record
    Tag      : Long;(*        table type *)
    CheckSum : Long;(*    table Checksum *)
    Offset   : Long;(* Table file offset *)
    Length   : Long;(*      Table length *)
  end;
  TTableDirEntries=array of TTableDirEntry;

  TNameRecord  = record
    platformID : UShort;
    encodingID : UShort;
    languageID : UShort;
    nameID     : UShort;
    length     : UShort;
    offset     : UShort;
  end;
  //PNameRecord  = ^TNameRecord;
  TNameRecords = array [0..maxNameID-1] of TNameRecord;
  //PNameRecords = ^TNameRecords;


  //PNameTable = ^TNameTable;
  TNameTable = record
    format         : UShort;
    numNameRecords : UShort;
    storageOffset  : UShort;
    //names          : PNameRecords;
    //storage        : PByte;
  end;

  TPANOSE = array [0..9] of uint8_t;
  TulUnicodeRange = array [0..3] of uint32;
  TachVendID = array [0..3]  of int8;

  //POS2Table = ^TOS2Table;
  TOS2Table = record
    version:UShort;//table version number (set to 0)
    xAvgCharWidth:Short;//average weighted advance width of lower case letters and space
    usWeightClass:UShort;//visual weight (degree of blackness or thickness) of stroke in glyphs
    usWidthClass:UShort;//relative change from the normal aspect ratio (width to height ratio) as specified by a font designer for the glyphs in the font
    fsType:Short;//characteristics and properties of this font (set undefined bits to zero)
    ySubscriptXSize:Short;//recommended horizontal size in pixels for subscripts
    ySubscriptYSize:Short;//recommended vertical size in pixels for subscripts
    ySubscriptXOffset:Short;//recommended horizontal offset for subscripts
    ySubscriptYOffset:Short;//recommended vertical offset form the baseline for subscripts
    ySuperscriptXSize:Short;//recommended horizontal size in pixels for superscripts
    ySuperscriptYSize:Short;//recommended vertical size in pixels for superscripts
    ySuperscriptXOffset:Short;//recommended horizontal offset for superscripts
    ySuperscriptYOffset:Short;//recommended vertical offset from the baseline for superscripts
    yStrikeoutSize:Short;//width of the strikeout stroke
    yStrikeoutPosition:Short;//position of the strikeout stroke relative to the baseline
    sFamilyClass:Short;//classification of font-family design.
    panose:TPANOSE;//10 byte series of number used to describe the visual characteristics of a given typeface
    ulUnicodeRange:TulUnicodeRange;//Field is split into two bit fields of 96 and 36 bits each. The low 96 bits are used to specify the Unicode blocks encompassed by the font file. The high 32 bits are used to specify the character or script sets covered by the font file. Bit assignments are pending. Set to 0
    achVendID:TachVendID;//four character identifier for the font vendor
    fsSelection:UShort;//2-byte bit field containing information concerning the nature of the font patterns
    fsFirstCharIndex:UShort;//The minimum Unicode index in this font.
    fsLastCharIndex:UShort;//The maximum Unicode index in this font.
    //end apple 'OS/2' table, start OpenType version 0
    {apple AdditionalFieldsOS2Table}sTypoAscender:int16;//The typographic ascender for this font. This is not necessarily the same as the ascender value in the 'hhea' table.
    {apple AdditionalFieldsOS2Table}sTypoDescender:int16;//The typographic descender for this font. This is not necessarily the same as the descender value in the 'hhea' table.
    {apple AdditionalFieldsOS2Table}sTypoLineGap:int16;//The typographic line gap for this font. This is not necessarily the same as the line gap value in the 'hhea' table.
    {apple AdditionalFieldsOS2Table}usWinAscent:uint16;//The ascender metric for Windows. usWinAscent is computed as the yMax for all characters in the Windows ANSI character set.
    {apple AdditionalFieldsOS2Table}usWinDescent:uint16;//The descender metric for Windows. usWinDescent is computed as the -yMin for all characters in the Windows ANSI character set.
    //end OpenType version 0, start OpenType version 1..3
    {apple AdditionalFieldsOS2Table}ulCodePageRange1:uint32;//Bits 0-31
    {apple AdditionalFieldsOS2Table}ulCodePageRange2:uint32;//Bits 32-63
    //end OpenType version 0..3, start OpenType version 4
    {apple AdditionalFieldsOS2Table}sxHeight:int16;//The distance between the baseline and the approximate height of non-ascending lowercase letters measured in FUnits.
    {apple AdditionalFieldsOS2Table}sCapHeight:int16;//The distance between the baseline and the approximate height of uppercase letters measured in FUnits.
    {apple AdditionalFieldsOS2Table}usDefaultChar:uint16;//The default character displayed by Windows to represent an unsupported character. (Typically this should be 0.)
    {apple AdditionalFieldsOS2Table}usBreakChar:uint16;//The break character used by Windows.
    {apple AdditionalFieldsOS2Table}usMaxContext:uint16;//The maximum length of a target glyph OpenType context for any feature in this font.
    //end OpenType version 4, start OpenType version 5
    {apple AdditionalFieldsOS2Table}usLowerPointSize:uint16;//Proposed for version 5 The lowest size (in twentieths of a typographic point), at which the font starts to be used. This is an inclusive value.
    {apple AdditionalFieldsOS2Table}usUpperPointSize:uint16;//Proposed for version 5 The highest size (in twentieths of a typographic point), at which the font starts to be used. This is an exclusive value. Use 0xFFFFU to indicate no upper limit.
  end;

  TTTFFileStream=class({TFileStream}{TMemoryStream}TBufferedFileStream)
    public
      constructor CreateFromFile(const AFileName: string);
      function GET_ULong:ULong;
      function GET_Long:Long;
      function GET_UShort:UShort;
      function GET_Short:Short;
      function GET_u8:uint8_t;
      function GET_i8:int8;
  end;

function readTTCheader(AStream:TTTFFileStream):TTTCHeader;
begin
  result.Tag      := BEtoN(AStream.Get_ULong);
  result.version  := BEtoN(AStream.Get_Long);
  result.dirCount := BEtoN(AStream.Get_Long);
end;

function readTablreDir(AStream:TTTFFileStream):TTableDir;
begin
  (*workaround https://bugs.freepascal.org/view.php?id=38351*)
  //result.version       := BEtoN(AStream.Get_Long);
  result.numTables     := BEtoN(AStream.GET_UShort);
  result.searchRange   := BEtoN(AStream.GET_UShort);
  result.entrySelector := BEtoN(AStream.GET_UShort);
  result.rangeShift    := BEtoN(AStream.GET_UShort);
end;

function getTrueTypeTableIndex(const TableDirEntries:TTableDirEntries;aTag:string ):integer;
var
  ltag:Long;
  i:integer;
begin
  ltag:=(Long(ord(aTag[1]))shl 24)+(Long(ord(aTag[2]))shl 16) +
        (Long(ord(aTag[3]))shl 8 )+ Long(ord(aTag[4]));

  for i:=low(TableDirEntries) to high(TableDirEntries) do
    if TableDirEntries[i].Tag = lTag then
      exit(i);

  result:=-1;
end;

function isPriority(const NameRecord:TNameRecord):boolean;
begin
  result:=false;
  if ((NameRecord.platformID=1{Macintosh})and(NameRecord.languageID=0{English}))
  or ((NameRecord.platformID=3{Microsoft})and(NameRecord.languageID=$0809{United Kingdom}))
  or ((NameRecord.platformID=3{Microsoft})and(NameRecord.languageID=$0409{United States})) then
    result:=true
  else
    result:=false;
end;

function readNameRecordValue(AStream:TTTFFileStream;NameRecord:TNameRecord;StorageOffsetInFile:Long):TNameTableValueType;
const
  maxstringlength=16000;
{type
  PTBeToLeArray=^TBeToLeArray;
  TBeToLeArray=array [0..maxstringlength-1] of word;}
var
  ts:UnicodeString{array [0..maxstringlength-1] of word};
  len,i:integer;
begin
  if NameRecord.length=0 then
    result:=''
  else begin
    if NameRecord.length>maxstringlength then
      len:=maxstringlength
    else
      len:=NameRecord.length div 2;
    AStream.Seek(NameRecord.offset+StorageOffsetInFile,soBeginning);
    ts:='';
    setlength(ts,len);
    //ts:=DupeString('-',len);
    AStream.Read((@ts[1])^,len*2);
    for i:=1 to len do
      PWord(@ts[i])^:=BEtoN(PWord(@ts[i])^);
    result:=TNameTableValueType(ts);
  end;
end;

function getTTFFileParams(const filename:String):TTTFFileParams;
var
  AStream:TTTFFileStream;
  TTCHeader:TTTCHeader;
  TableDir:TTableDir;
  i,nametableindex,os2tableindex:integer;
  TableDirEntries:TTableDirEntries;
  NameTable:TNameTable;
  NameRecord:TNameRecord;
  NameRecords:TNameRecords;
  OS2Table:TOS2Table;
  StartOffs,TableLength:integer;
  StorageOffsetInFile:Long;
begin
  //result.FullName:=extractfilename(filename);
  //debugln('{E}TTFName "%s"',[result.name]);
  AStream:=TTTFFileStream.CreateFromFile(filename);

  try
    result.ValidTTFFile:=false;

    AStream.Seek(0,soBeginning);
    TTCHeader:=readTTCheader(AStream);
    if TTCHeader.Tag=TTC_Tag then begin
      zDebugln('{W}getTTFFileParams: TTFFile "%s" is collection',[filename]);
      exit;
    end;

    (*workaround https://bugs.freepascal.org/view.php?id=38351*)
    AStream.Seek({0}4,soBeginning);
    TableDir:=readTablreDir(AStream);
    ulong(TableDir.version):=TTCHeader.Tag;

    if (TableDir.version=$10000)then
      result.FileType:=TTFTMS
    else if (TableDir.version=$74727565)then
      result.FileType:=TTFTApple
    else begin
      result.FileType:=TTFTOther;
      zDebugLn('{W}getTTFFileParams: TTFFile "%s" TableDir.version=%x (not MS or MAC)',[filename,TableDir.version]);
      exit;
    end;

    setlength(TableDirEntries,TableDir.numTables);
    for i:=0 to TableDir.numTables-1 do
    begin
      TableDirEntries[i].Tag:=BEtoN(AStream.GET_ULong);
      TableDirEntries[i].Checksum:= BEtoN(AStream.GET_ULong);
      TableDirEntries[i].Offset:= BEtoN(AStream.GET_Long);
      TableDirEntries[i].Length:= BEtoN(AStream.Get_Long);
    end;

    nametableindex:=getTrueTypeTableIndex(TableDirEntries,'name');
    AStream.Seek(TableDirEntries[nametableindex].Offset,soBeginning);
    NameTable.format:=BEtoN(AStream.GET_UShort);
    NameTable.numNameRecords:=BEtoN(AStream.GET_UShort);
    StartOffs:=AStream.Seek(0,soCurrent);
    NameTable.storageOffset:=BEtoN(AStream.GET_UShort){+TableDirEntries[nametableindex].Offset};
    //debugln('{E}NameTable.numNameRecords=%d',[NameTable.numNameRecords]);

    //setlength(NameRecords,NameTable.numNameRecords);
    for i:=low(NameRecords) to high(NameRecords) do
    begin
      NameRecords[i].length:=0;
    end;

    for i:=1 to NameTable.numNameRecords do
    begin
      NameRecord.platformID:=BEtoN(AStream.GET_UShort);
      NameRecord.encodingID:=BEtoN(AStream.GET_UShort);
      NameRecord.languageID:=BEtoN(AStream.GET_UShort);
      NameRecord.nameID:=BEtoN(AStream.GET_UShort);
      NameRecord.length:=BEtoN(AStream.GET_UShort);
      NameRecord.offset:=BEtoN(AStream.GET_UShort);
      //NameRecord.offset:=NameRecord.offset+NameTable.storageOffset+TableDirEntries[nametableindex].Offset;//-3*2-6*2}+NameTable.storageOffset+TableDirEntries[nametableindex].Offset;
      //debugln('{E}i=%d; nameID=%d',[i,NameRecord.nameID]);
      if NameRecord.nameID<=maxNameID then begin
        if (NameRecords[NameRecord.nameID].length=0)or(isPriority(NameRecord)) then
          NameRecords[NameRecord.nameID]:=NameRecord
        else begin
        end;
      end;
    end;

    StorageOffsetInFile:=NameTable.storageOffset+TableDirEntries[nametableindex].Offset;

    result.CopyrightNotice:=               readNameRecordValue(AStream,NameRecords[ 0],StorageOffsetInFile);
    result.FontFamily:=                    readNameRecordValue(AStream,NameRecords[ 1],StorageOffsetInFile);
    result.FontSubfamily:=                 readNameRecordValue(AStream,NameRecords[ 2],StorageOffsetInFile);
    result.UniqueSubfamily:=               readNameRecordValue(AStream,NameRecords[ 3],StorageOffsetInFile);
    result.FullName:=                      readNameRecordValue(AStream,NameRecords[ 4],StorageOffsetInFile);
    result.Version:=                       readNameRecordValue(AStream,NameRecords[ 5],StorageOffsetInFile);
    result.PostScriptName:=                readNameRecordValue(AStream,NameRecords[ 6],StorageOffsetInFile);
    result.TrademarkNotice:=               readNameRecordValue(AStream,NameRecords[ 7],StorageOffsetInFile);
    result.ManufacturerName:=              readNameRecordValue(AStream,NameRecords[ 8],StorageOffsetInFile);
    result.DesignerName:=                  readNameRecordValue(AStream,NameRecords[ 9],StorageOffsetInFile);
    result.Description:=                   readNameRecordValue(AStream,NameRecords[10],StorageOffsetInFile);
    result.URLVendor:=                     readNameRecordValue(AStream,NameRecords[11],StorageOffsetInFile);
    result.URLDesigner:=                   readNameRecordValue(AStream,NameRecords[12],StorageOffsetInFile);
    result.LicenseDescription:=            readNameRecordValue(AStream,NameRecords[13],StorageOffsetInFile);
    result.LicenseInformationURL:=         readNameRecordValue(AStream,NameRecords[14],StorageOffsetInFile);
    result.Reserved:=                      readNameRecordValue(AStream,NameRecords[15],StorageOffsetInFile);
    result.PreferredFamily:=               readNameRecordValue(AStream,NameRecords[16],StorageOffsetInFile);
    result.PreferredSubfamily:=            readNameRecordValue(AStream,NameRecords[17],StorageOffsetInFile);
    result.CompatibleFull:=                readNameRecordValue(AStream,NameRecords[18],StorageOffsetInFile);
    result.SampleText:=                    readNameRecordValue(AStream,NameRecords[19],StorageOffsetInFile);
    result.VariationsPostScriptNamePrefix:=readNameRecordValue(AStream,NameRecords[25],StorageOffsetInFile);

    os2tableindex:=getTrueTypeTableIndex(TableDirEntries,'OS/2');
    AStream.Seek(TableDirEntries[os2tableindex].Offset,soBeginning);
    StartOffs:=TableDirEntries[os2tableindex].Offset;
    OS2Table:=default(TOS2Table);
    OS2Table.usDefaultChar:=High(OS2Table.usDefaultChar);// -1; //Range check error
    OS2Table.version:=BEtoN(AStream.GET_UShort);
    OS2Table.xAvgCharWidth:=BEtoN(AStream.GET_Short);
    OS2Table.usWeightClass:=BEtoN(AStream.GET_UShort);
    OS2Table.usWidthClass:=BEtoN(AStream.GET_UShort);
    OS2Table.fsType:=BEtoN(AStream.GET_Short);
    OS2Table.ySubscriptXSize:=BEtoN(AStream.GET_Short);
    OS2Table.ySubscriptYSize:=BEtoN(AStream.GET_Short);
    OS2Table.ySubscriptXOffset:=BEtoN(AStream.GET_Short);
    OS2Table.ySubscriptYOffset:=BEtoN(AStream.GET_Short);
    OS2Table.ySuperscriptXSize:=BEtoN(AStream.GET_Short);
    OS2Table.ySuperscriptYSize:=BEtoN(AStream.GET_Short);
    OS2Table.ySuperscriptXOffset:=BEtoN(AStream.GET_Short);
    OS2Table.ySuperscriptYOffset:=BEtoN(AStream.GET_Short);
    OS2Table.yStrikeoutSize:=BEtoN(AStream.GET_Short);
    OS2Table.yStrikeoutPosition:=BEtoN(AStream.GET_Short);
    OS2Table.sFamilyClass:=BEtoN(AStream.GET_Short);
    for i:=low(OS2Table.panose) to High(OS2Table.panose) do
      OS2Table.panose[i]:=AStream.GET_u8;
    for i:=low(OS2Table.ulUnicodeRange) to High(OS2Table.ulUnicodeRange) do
      OS2Table.ulUnicodeRange[i]:=BEtoN(AStream.GET_ULong);
    for i:=low(OS2Table.achVendID) to High(OS2Table.achVendID) do
      OS2Table.achVendID[i]:=AStream.GET_i8;
    OS2Table.fsSelection:=BEtoN(AStream.GET_UShort);
    OS2Table.fsFirstCharIndex:=BEtoN(AStream.GET_UShort);
    OS2Table.fsLastCharIndex:=BEtoN(AStream.GET_UShort);

    if result.FileType=TTFTMS then begin
      //end apple 'OS/2' table, start OpenType version 0
      OS2Table.sTypoAscender:=BEtoN(AStream.GET_Short);
      OS2Table.sTypoDescender:=BEtoN(AStream.GET_Short);
      OS2Table.sTypoLineGap:=BEtoN(AStream.GET_Short);
      OS2Table.usWinAscent:=BEtoN(AStream.GET_UShort);
      OS2Table.usWinDescent:=BEtoN(AStream.GET_UShort);
    end;


    if OS2Table.version>=1 then begin
      if result.FileType=TTFTApple then begin
        OS2Table.sTypoAscender:=BEtoN(AStream.GET_Short);
        OS2Table.sTypoDescender:=BEtoN(AStream.GET_Short);
        OS2Table.sTypoLineGap:=BEtoN(AStream.GET_Short);
        OS2Table.usWinAscent:=BEtoN(AStream.GET_UShort);
        OS2Table.usWinDescent:=BEtoN(AStream.GET_UShort);
      end;
      OS2Table.ulCodePageRange1:=BEtoN(AStream.GET_ULong);
      OS2Table.ulCodePageRange2:=BEtoN(AStream.GET_ULong);
      if OS2Table.version>=2 then begin
        OS2Table.sxHeight:=BEtoN(AStream.GET_Short);
        OS2Table.sCapHeight:=BEtoN(AStream.GET_Short);
        OS2Table.usDefaultChar:=BEtoN(AStream.GET_UShort);
        OS2Table.usBreakChar:=BEtoN(AStream.GET_UShort);
        OS2Table.usMaxContext:=BEtoN(AStream.GET_UShort);
        if OS2Table.version>=5 then begin
          OS2Table.usLowerPointSize:=BEtoN(AStream.GET_UShort);
          OS2Table.usUpperPointSize:=BEtoN(AStream.GET_UShort);
        end;
      end;
    end;

    result.FirstCharIndex:=OS2Table.fsFirstCharIndex;
    result.LastCharIndex:=OS2Table.fsLastCharIndex;
    result.DefaultChar:=OS2Table.usDefaultChar;

    TableLength:=AStream.Seek(0,soCurrent)-StartOffs;

    if TableLength<>TableDirEntries[os2tableindex].Length then begin
      zDebugLn('{W}getTTFFileParams: TTFFile "%s" OS/2 table length in file header <> fact length %d<>%d',[filename,TableDirEntries[os2tableindex].Length,TableLength]);
      exit;
    end;

    NameTable.numNameRecords:=BEtoN(AStream.GET_UShort);
    StartOffs:=AStream.Seek(0,soCurrent);

    result.ValidTTFFile:=result.FontFamily<>'';

    zDebugLn('TTFName "%s"',[filename]);
    //debugln('CopyrightNotice="%s"',[result.CopyrightNotice]);
    zDebugLn('FontFamily="%s"',[result.FontFamily]);
    zDebugLn('FontSubfamily"%s"',[result.FontSubfamily]);
    zDebugLn('UniqueSubfamily="%s"',[result.UniqueSubfamily]);
    zDebugLn('FullName="%s"',[result.FullName]);
    zDebugLn('Version="%s"',[result.Version]);
    zDebugLn('PostScriptName="%s"',[result.PostScriptName]);
    {zDebugLn('TrademarkNotice="%s"',[result.TrademarkNotice]);
    zDebugLn('ManufacturerName="%s"',[result.ManufacturerName]);
    zDebugLn('DesignerName="%s"',[result.DesignerName]);
    zDebugLn('Description="%s"',[result.Description]);
    zDebugLn('URLVendor="%s"',[result.URLVendor]);
    zDebugLn('URLDesigner="%s"',[result.URLDesigner]);
    zDebugLn('LicenseDescription="%s"',[result.LicenseDescription]);
    zDebugLn('LicenseInformationURL="%s"',[result.LicenseInformationURL]);
    zDebugLn('Reserved="%s"',[result.Reserved]);}
    zDebugLn('PreferredFamily="%s"',[result.PreferredFamily]);
    zDebugLn('PreferredSubfamily="%s"',[result.PreferredSubfamily]);
    zDebugLn('CompatibleFull="%s"',[result.CompatibleFull]);
    {zDebugLn('SampleText="%s"',[result.SampleText]);
    zDebugLn('VariationsPostScriptNamePrefix="%s"',[result.VariationsPostScriptNamePrefix]);}

  finally
    setlength(TableDirEntries,0);
    FreeAndNil(AStream);
  end;
end;

constructor TTTFFileStream.CreateFromFile(const AFileName: string);
begin
  {TFileStream}{TBufferedFileStream}
  Create(AFileName, fmOpenRead or fmShareDenyWrite);
  {TMemoryStream}
  //Create;
  //LoadFromFile(AFileName);
end;

function TTTFFileStream.GET_ULong:ULong;
begin
  result:=0;
  read(result,SizeOf(Result));
end;
function TTTFFileStream.GET_Long:Long;
begin
  result:=0;
  read(result,SizeOf(Result));
end;
function TTTFFileStream.GET_UShort:UShort;
begin
  result:=0;
  read(result,SizeOf(Result));
end;
function TTTFFileStream.GET_Short:Short;
begin
  result:=0;
  read(result,SizeOf(Result));
end;
function TTTFFileStream.GET_u8:uint8_t;
begin
  result:=0;
  read(result,SizeOf(Result));
end;
function TTTFFileStream.GET_i8:int8;
begin
  result:=0;
  read(result,SizeOf(Result));
end;
initialization
end.

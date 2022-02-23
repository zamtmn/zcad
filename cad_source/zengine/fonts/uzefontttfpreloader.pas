{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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
{$INCLUDE zcadconfig.inc}

interface

uses
  sysutils,classes,LCLProc,bufstream{,StrUtils};

const
  maxNameID=26;

type
  TNameTableValueType=String;
  TTTFFileParams=record
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
  end;
function getTTFFileParams(filename:String):TTTFFileParams;

implementation

const
  TTC_Tag = ( ord('t') shl 24 ) +
            ( ord('t') shl 16 ) +
            ( ord('c') shl 8  ) +
            ( ord(' ')        );

type

  //from TTTypes.pas
  UShort   = Word;        (* unsigned short integer, must be on 16 bits *)
  Short    = Smallint;    (* signed short integer,   must be on 16 bits *)
  Long        = Longint;
  ULong       = LongWord; (* unsigned long integer, must be on 32 bits *)
  TT_Fixed    = LongInt;  (* Signed Fixed 16.16 Single *)
  TStorage    = array[0..16000] of Long;
  PStorage    = ^TStorage;


  //from TTTables.pas
  (* TrueType collection header *)
  PTTCHeader=^TTTCHeader;
  TTTCHeader=record
    Tag            : Long;
    version        : TT_Fixed;
    DirCount       : ULong;
    TableDirectory : PStorage;
  end;

  PTableDir=^TTableDir;
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
  PNameRecord  = ^TNameRecord;
  TNameRecords = array [0..maxNameID-1] of TNameRecord;
  PNameRecords = ^TNameRecords;


  PNameTable = ^TNameTable;
  TNameTable = record
    format         : UShort;
    numNameRecords : UShort;
    storageOffset  : UShort;
    //names          : PNameRecords;
    //storage        : PByte;
  end;


  TTTFFileStream=class({TFileStream}{TMemoryStream}TBufferedFileStream)
    public
      constructor CreateFromFile(const AFileName: string);
      function GET_ULong:ULong;
      function GET_Long:Long;
      function GET_UShort:UShort;
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

function getTTFFileParams(filename:String):TTTFFileParams;
var
  AStream:TTTFFileStream;
  TTCHeader:TTTCHeader;
  TableDir:TTableDir;
  i,nametableindex:integer;
  TableDirEntries:TTableDirEntries;
  NameTable:TNameTable;
  NameRecord:TNameRecord;
  NameRecords:TNameRecords;
  t:integer;
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
      debugln('{W}getTTFFileParaC:\Windows\Fonts\Amiri-Bold.ttfms: TTFFile "%s" is collection',[filename]);
      exit;
    end;

    (*workaround https://bugs.freepascal.org/view.php?id=38351*)
    AStream.Seek({0}4,soBeginning);
    TableDir:=readTablreDir(AStream);
    ulong(TableDir.version):=TTCHeader.Tag;


    if (TableDir.version <> $10000   )(* MS fonts  *) and
       (TableDir.version <> $74727565)(* Mac fonts *) then begin
      debugln('{W}getTTFFileParams: TTFFile "%s" TableDir.version=%x (not MS or MAC)',[filename,TableDir.version]);
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
    t:=AStream.Seek(0,soCurrent);
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

    result.ValidTTFFile:=result.FontFamily<>'';

    debugln('TTFName "%s"',[filename]);
    //debugln('CopyrightNotice="%s"',[result.CopyrightNotice]);
    debugln('FontFamily="%s"',[result.FontFamily]);
    debugln('FontSubfamily"%s"',[result.FontSubfamily]);
    debugln('UniqueSubfamily="%s"',[result.UniqueSubfamily]);
    debugln('FullName="%s"',[result.FullName]);
    debugln('Version="%s"',[result.Version]);
    debugln('PostScriptName="%s"',[result.PostScriptName]);
    {debugln('TrademarkNotice="%s"',[result.TrademarkNotice]);
    debugln('ManufacturerName="%s"',[result.ManufacturerName]);
    debugln('DesignerName="%s"',[result.DesignerName]);
    debugln('Description="%s"',[result.Description]);
    debugln('URLVendor="%s"',[result.URLVendor]);
    debugln('URLDesigner="%s"',[result.URLDesigner]);
    debugln('LicenseDescription="%s"',[result.LicenseDescription]);
    debugln('LicenseInformationURL="%s"',[result.LicenseInformationURL]);
    debugln('Reserved="%s"',[result.Reserved]);}
    debugln('PreferredFamily="%s"',[result.PreferredFamily]);
    debugln('PreferredSubfamily="%s"',[result.PreferredSubfamily]);
    debugln('CompatibleFull="%s"',[result.CompatibleFull]);
    {debugln('SampleText="%s"',[result.SampleText]);
    debugln('VariationsPostScriptNamePrefix="%s"',[result.VariationsPostScriptNamePrefix]);}

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
initialization
end.

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
{$INCLUDE def.inc}

interface

uses
  sysutils,classes;

type
  TTTFFileParams=record
    ValidTTFFile:boolean;
    name:string;
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
  TT_Fixed    = LongInt;  (* Signed Fixed 16.16 Float *)
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

  TTTFFileStream=class(TFileStream)
    public
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
  result.version       := BEtoN(AStream.Get_Long);
  result.numTables     := BEtoN(AStream.GET_UShort);
  result.searchRange   := BEtoN(AStream.GET_UShort);
  result.entrySelector := BEtoN(AStream.GET_UShort);
  result.rangeShift    := BEtoN(AStream.GET_UShort);
end;

function getTTFFileParams(filename:String):TTTFFileParams;
var
  AStream:TTTFFileStream;
  TTCHeader:TTTCHeader;
  TableDir:TTableDir;
  i:integer;
  TableDirEntries:TTableDirEntries;
begin
  result.name:=extractfilename(filename);
  AStream:=TTTFFileStream.Create(filename, fmOpenRead or fmShareDenyWrite);
  try
    result.ValidTTFFile:=false;

    AStream.Seek(0,0);
    TTCHeader:=readTTCheader(AStream);
    if TTCHeader.Tag=TTC_Tag then begin
      exit;
    end;

    AStream.Seek(0,0);
    TableDir:=readTablreDir(AStream);
    if (TableDir.version <> $10000   )(* MS fonts  *) and
       (TableDir.version <> $74727565)(* Mac fonts *) then begin
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


  finally
    setlength(TableDirEntries,0);
    FreeAndNil(AStream);
  end;
end;

function TTTFFileStream.GET_ULong:ULong;
begin
  read(result,SizeOf(Result));
end;
function TTTFFileStream.GET_Long:Long;
begin
  read(result,SizeOf(Result));
end;
function TTTFFileStream.GET_UShort:UShort;
begin
  read(result,SizeOf(Result));
end;
initialization
end.

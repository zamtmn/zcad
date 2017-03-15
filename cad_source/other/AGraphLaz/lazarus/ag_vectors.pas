{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit ag_vectors;

interface

uses
  Aliasm, Aliasv, Base8v, Base16v, Base32v, Base64v, Base80v, Boolm, Boolv, 
  ChckFree, Crc16, Crc32, ExtSys, ExtType, F_PQueue, F32g, F32m, F32sv, F32v, 
  F64g, F64m, F64sv, F64v, F80g, F80m, F80sv, F80v, II64Dic, IIDic, Indexsv, 
  Indexv, Int8g, Int8m, Int8sv, Int8v, Int16g, Int16m, Int16sv, Int16v, 
  Int32g, Int32m, Int32sv, Int32v, Int64g, Int64m, Int64sv, Int64v, IPDic, 
  IQueue, ISDic, IStack, LogFile, MultiLst, NLSTypes, ParseCmd, Pointerv, 
  PQueue, PStack, RBTree, SIDic, SIQueue, SPDic, SQueue, SSDic, StrCount, 
  StrLst, UInt8g, UInt8m, UInt8sv, UInt8v, UInt16g, UInt16m, UInt16sv, 
  UInt16v, UInt32g, UInt32m, UInt32sv, UInt32v, VCLCmpt, VComUtil, VectErr, 
  Vectors, VectProc, VectStr, VFileLst, VFileSys, VFormat, VFStream, VFstTmr, 
  VStream, VStrm64, VStrmCrc, VTxtStrm, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('ag_vectors', @Register);
end.

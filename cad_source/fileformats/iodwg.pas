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

unit iodwg;
{$INCLUDE def.inc}
interface
uses zcadstrconsts,iodxf,fileutil,UGDBTextStyleArray,varman,geometry,GDBSubordinated,shared,gdbasetypes{,GDBRoot},log,GDBGenericSubEntry,SysInfo,gdbase, GDBManager, {OGLtypes,} sysutils{, strmy}, memman, UGDBDescriptor,{gdbobjectsconstdef,}
     UGDBObjBlockdefArray,UGDBOpenArrayOfTObjLinkRecord{,varmandef},UGDBOpenArrayOfByte,UGDBVisibleOpenArray,GDBEntity{,GDBBlockInsert,GDBCircle,GDBArc,GDBPoint,GDBText,GDBMtext,GDBLine,GDBPolyLine,GDBLWPolyLine},TypeDescriptors;
procedure addfromdwg(name: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt);
implementation
uses GDBBlockDef,mainwindow,UGDBLayerArray;

type
    PDWGByte=^DWGByte;
    DWGByte=byte;
    DWGLong=DWord;
    DWG2Long=QWord;

    DWGWord=word;
    pdwg2004header=^dwg2004header;
    dwg2004header=packed record
                  versionstring:packed array[1..6]of ansichar;
                  _bytes1:packed array[1..5]of DWGByte;
                  MaintenanceReleaseVersion:DWGByte;
                  _byte2:DWGByte;
                  PreviewAdress:DWGLong;
                  ApplicationDWGVersion:DWGByte;
                  ApplicationMaintenanceReleaseVersion:DWGByte;
                  CodePage:DWGWord;
                  _bytes3_000000:packed array[1..3]of DWGByte;
                  SecurityFlag:DWGLong;
                  UnknownLong1:DWGLong;
                  SummaryInfoAdress:DWGLong;
                  VBAProjectAdress:DWGLong;
                  _0x00000080:DWGLong;
                  _bytes4:packed array[1..$54]of DWGByte;
                  EncryptedData:packed array[1..$6c]of DWGByte;
                  end;
    pdwg2004headerdecrypteddata=^dwg2004headerdecrypteddata;
    dwg2004headerdecrypteddata=packed record
                      FileIDString:packed array[1..12]of ansichar;
                      _0x00:DWGLong;
                      _0x6c:DWGLong;
                      _0x04:DWGLong;
                      RootTreeNodeGap:DWGLong;
                      LowerMostLeftTreeNodeGap:DWGLong;
                      LowerMostRightTreeNodeGap:DWGLong;
                      UnknownLong1_0x01:DWGLong;
                      LastSectionPageID:DWGLong;
                      LastSectionPageEndAdress:DWG2Long;
                      SecondHeaderAdress:DWG2Long;
                      GapAmount:DWGLong;
                      SectionPageAmount:DWGLong;
                      _0x20:DWGLong;
                      _0x80:DWGLong;
                      _0x40:DWGLong;
                      SectionPageMapID:DWGLong;
                      SectionPageMapAdress:DWG2Long;
                      SectionInfoID:DWGLong;
                      SectionPageArraySize:DWGLong;
                      GAPArraySize:DWGLong;
                      CRC32:DWGLong;
                      Dummy:packed array[1..$14]of DWGByte;
                      end;
    pdwg2004systemsection=^dwg2004systemsection;
    dwg2004systemsection=packed record
                      _0x4163043b:DWGLong;
                      DecompSizeData:DWGLong;
                      CompSizeData:DWGLong;
                      CompType:DWGLong;
                      Checksum:DWGLong;
                        end;
    pdwg2004sectionmap=^dwg2004sectionmap;
    dwg2004sectionmap=packed record
                                   SectionNumber:DWGLong;
                                   SectionSize:DWGLong;
                             end;
    pdwg2004sectioninfo=^dwg2004sectioninfo;
    dwg2004sectioninfo=packed record
                                   NumDescriptions:DWGLong;
                                   _0x02:DWGLong;
                                   _0x00007400:DWGLong;
                                   _0x00:DWGLong;
                                   Unknown:DWGLong;
                              end;
    pdwg2004sectiondesc=^dwg2004sectiondesc;
    dwg2004sectiondesc=packed record
                                    SizeOfSection:DWGLong;
                                    Unknown:DWGLong;
                                    NumberOfSectionsThisType:DWGLong;
                                    MaxDecompressedSize:DWGLong;
                                    Unknown2:DWGLong;
                                    Compressed:DWGLong;
                                    SectionType:DWGLong;
                                    Encrypted:DWGLong;
                                    SectionName:packed array[1..64]of ansichar;
                             end;

    PTMyDWGSectionDesc=^TMyDWGSectionDesc;
    TMyDWGSectionDesc=record
                            Number:DWGLong;
                            Size:DWGLong;
                            Offset:DWGLong;
                      end;
    TMyDWGSectionDescArray=array of TMyDWGSectionDesc;
    bit_chain=packed object
                           chain:PDWGByte;
                           size:DWord;
                           byte:DWord;
                           bit:DWGByte;
                           constructor init(_chain:pointer;_size:DWord);
                           function readbyte_rc:DWGByte;
                     end;
constructor bit_chain.init(_chain:pointer;_size:DWord);
begin
     chain:=_chain;
     size:=_size;
     byte:=0;
     bit:=0;
end;
(*
bit_read_RC(Bit_Chain * dat)
{
  unsigned char result;
  unsigned char byte;

  byte = dat->chain[dat->byte];
  if (dat->bit == 0)
    result = byte;
  else
    {
      result = byte << dat->bit;
      if (dat->byte < dat->size - 1)
        {
          byte = dat->chain[dat->byte + 1];
          result |= byte >> (8 - dat->bit);
        }
    }

  bit_advance_position(dat, 8);
  return ((unsigned char) result);
}
*)
function bit_chain.readbyte_rc:DWGByte;
begin
     if bit=0 then
         begin
              result:=PDWGByte({DWGLong}PtrUInt(chain)+{DWGLong}(byte))^
         end
     else
        begin
             shared.ShowError('bit_chain.readbyte_rc bit<>0 not implement');
        end;
     inc(byte);
end;
(*
read_literal_length(Bit_Chain* dat, unsigned char *opcode)
{
  int total = 0;
  unsigned char byte = bit_read_RC(dat);

  *opcode = 0x00;

  if (byte >= 0x01 && byte <= 0x0F)
    return byte + 3;
  else if (byte == 0)
    {
      total = 0x0F;
      while ((byte = bit_read_RC(dat)) == 0x00)
        {
          total += 0xFF;
        }
      return total + byte + 3;
    }
  else if (byte & 0xF0)
    *opcode = byte;

  return 0;
}
*)
function read_literal_length(var bc:bit_chain;var opcode:DWGByte):integer;
var total:integer=0;
    byte:DWGByte;
begin
  //int total = 0;
  //unsigned char byte = bit_read_RC(dat);
     byte:=bc.readbyte_rc;

  //*opcode = 0x00;
  opcode:=0;

  if (byte >= $01) and (byte <= $0F) then
      begin
           result:=byte+3;
           exit;
      end
  else if (byte = 0) then
    begin
      total:=$0F;
      byte:=bc.readbyte_rc;
      while (byte=$00) do
                         begin
                          total:=total+$FF;
                          byte:=bc.readbyte_rc;
                         end;
      result:=total+byte+3;
      exit;
    end
  else if (byte and $F0)>0 then
                           opcode:=byte;
  result:=0;
end;
function read_two_byte_offset(var bc:bit_chain;var lit_length:integer):integer;
var
    firstbyte,secondbyte:DWGByte;
begin
  firstByte := bc.readbyte_rc;
  secondByte := bc.readbyte_rc;
  result := (firstByte shr 2) or (secondByte shl 6);
  lit_length := (firstByte and $03);
end;
function read_long_compression_offset(var bc:bit_chain):integer;
var
    total:integer;
    byte:DWGByte;
begin
  total:=0;
  byte := bc.readbyte_rc;
  if (byte = 0) then
    begin
      total := $FF;
     byte := bc.readbyte_rc;
      while ((byte) = $00) do
        begin
        total := total+$FF;
        byte := bc.readbyte_rc;
        end;
    end;
  result:=total + byte;
end;

function decompresssection(ptr:pbyte;csize,usize:integer):PDWGByte;
var
   bc:bit_chain;
   opcode1,opcode2:DWGByte;
   lit_length:integer;
   i:integer;
   dst,src:pbyte;
   comp_bytes,comp_offset:integer;
begin
     GDBGetMem(result,usize);
     dst:=result;
     bc.init(ptr,csize);
     lit_length:=read_literal_length(bc,opcode1);

     for i := 1  to lit_length do
     begin
         dst^:=bc.readbyte_rc;
         inc(dst);
     end;

     opcode1:=0;
     while bc.byte<csize do
     begin
          if opcode1=0 then
                           opcode1:=bc.readbyte_rc;
          if opcode1 >= $40 then
                  begin
                    shared.HistoryOutStr('1 '+format('writeln %d bytes',[ptruint(dst)-ptruint(result)]));
                    comp_bytes:=((opcode1 and $F0) shr 4) - 1;
                    opcode2 := bc.readbyte_rc;
                    comp_offset := (opcode2 shl 2) or ((opcode1 and $0C) shr 2);
                    if (opcode1 and $03)>0 then
                      begin
                        lit_length := (opcode1 and $03);
                        opcode1  := $00;
                      end
                    else
                      lit_length := read_literal_length(bc, opcode1);
                    if lit_length=0 then
                                        lit_length:=lit_length;
                    shared.HistoryOutStr('  '+format('comp_bytes=%d comp_offset=%d lit_length=%d',[comp_bytes,comp_offset,lit_length]));
                  end
          else if (opcode1 >= $21) and (opcode1 <= $3F) then
            begin
              shared.HistoryOutStr('2');
              comp_bytes  := opcode1 - $1E;
              comp_offset := read_two_byte_offset(bc, lit_length);

              if (lit_length <> 0) then
                opcode1 := $00
              else
                lit_length := read_literal_length(bc, opcode1);
            end
          else if (opcode1 = $20) then
            begin
              shared.HistoryOutStr('3');
              comp_bytes  := read_long_compression_offset(bc) + $21;
              comp_offset := read_two_byte_offset(bc, lit_length);

              if (lit_length <> 0) then
                opcode1 := $00
              else
                lit_length := read_literal_length(bc, opcode1);
            end
          else if (opcode1 >= $12) and (opcode1 <= $1F) then
            begin
              shared.HistoryOutStr('4');
              comp_bytes  := (opcode1 and $0F) + 2;
              comp_offset := read_two_byte_offset(bc, lit_length) + $3FFF;

              if (lit_length <> 0) then
                opcode1 := $00
              else
                lit_length := read_literal_length(bc, opcode1);
            end
          else if (opcode1 = $10) then
            begin
              shared.HistoryOutStr('5');
              comp_bytes  := read_long_compression_offset(bc) + 9;
              comp_offset := read_two_byte_offset(bc, lit_length) + $3FFF;

              if (lit_length <> 0)then
                opcode1 := $00
              else
                lit_length := read_literal_length(bc, opcode1);
            end
          else if (opcode1 = $11) then
              break     // Terminates the input stream, everything is ok!
          else
              exit{(1)};  // error in input stream


          //LOG_TRACE("got compressed data %d\n",comp_bytes)
          // copy "compressed data"
          {src = dst - comp_offset - 1;
          assert(src > decomp);
          for (i = 0; i < comp_bytes; ++i)
            *dst++ = *src++;}

          src:=pointer(PTRUINT(dst)-comp_offset-1);
          for i := 1  to comp_bytes do
          begin
              dst^:=src^;
              inc(dst);
              inc(src);
          end;

          // copy "literal data"
          //LOG_TRACE("got literal data %d\n",lit_length)
          {for (i = 0; i < lit_length; ++i)
            *dst++ = bit_read_RC(dat);}

          for i := 1  to lit_length do
          begin
              dst^:=bc.readbyte_rc;
              inc(dst);
          end;

     end;
end;
procedure decodeheader(ptr:pbyte;size:integer);
var
    randseed:integer;
begin
     randseed:=1;
     repeat
           randseed:=randseed * $343fd;
           randseed:=randseed  + $269ec3;
           ptr^:=ptr^ xor (byte(RorDword(randseed,16)));
           shared.HistoryOutStr(inttohex(byte(RorDword(randseed,16)),4));
           inc(ptr);
           dec(size);
     until size=0;
end;
function FindSectionByID(const sarray:TMyDWGSectionDescArray;ID:integer):PTMyDWGSectionDesc;
var
    i:integer;
begin
     for i:=low(sarray) to High(sarray) do
     if sarray[i].Number=ID then
       begin
            result:=@sarray[i];
            exit;
       end;
     result:=nil;
end;

procedure addfromdwg2004(var f:GDBOpenArrayOfByte; exitGDBString: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt);
var fh:pdwg2004header;
    fdh:dwg2004headerdecrypteddata;
    syssec,SectionMap,SectionInfo:pdwg2004systemsection;
    USectionMap,USectionInfo:pointer;
    i,a:integer;
    sm:pdwg2004sectionmap;
    sid:pdwg2004sectioninfo;
    sd:pdwg2004sectiondesc;
    sarray:TMyDWGSectionDescArray;

    FileHandle:cardinal;
begin
     fh:=f.PArray;
     fdh:=pdwg2004headerdecrypteddata(@fh.EncryptedData)^;
     i:=sizeof(dwgbyte);
     i:=sizeof(dwgword);
     i:=sizeof(dwglong);
     i:=sizeof(dwg2004header);
     i:=sizeof(dwg2004headerdecrypteddata);
     decodeheader(@fdh,$6c);
     syssec:=f.PArray;
     inc(pointer(syssec),sizeof(dwg2004header));
     fh:=f.PArray;
     syssec:=f.PArray;
     inc(pointer(syssec),sizeof(dwg2004headerdecrypteddata));
     syssec:=f.PArray;
     inc(pointer(syssec),fdh.SecondHeaderAdress);
     syssec:=f.PArray;
     inc(pointer(syssec),fdh.SectionPageMapAdress);
     inc(pointer(syssec),$100);
     SectionMap:=syssec;
     SectionInfo:=syssec;
     inc(pointer(SectionInfo),SectionMap.CompSizeData+sizeof(dwg2004systemsection));
     shared.HistoryOutStr('MAP');
     USectionMap:=decompresssection(pointer(PTRUINT(SectionMap)+sizeof(dwg2004systemsection)),SectionMap.CompSizeData,SectionMap.DecompSizeData);
     setlength(sarray,fdh.SectionPageArraySize);
     sm:=pointer(USectionMap);
     for i:=0 to {SectionMap.DecompSizeData div 8}fdh.SectionPageAmount-1 do
     begin
          sarray[i].Number:=sm.SectionNumber;
          sarray[i].Size:=sm.SectionSize;
          if i=0 then
                     sarray[i].Offset:=$100
                 else
                     sarray[i].Offset:=sarray[i-1].Offset+sarray[i-1].Size;
          shared.HistoryOutStr(format('Section %d, size %d, offset %d',[sarray[i].Number,sarray[i].Size,sarray[i].Offset]));
          inc(sm);
     end;
     SectionInfo:=f.PArray;
     inc(pointer(SectionInfo),FindSectionByID(sarray,fdh.SectionInfoID).Offset);
     shared.HistoryOutStr('INFO');
     USectionInfo:=decompresssection(pointer(PTRUINT(SectionInfo)+sizeof(dwg2004systemsection)),SectionInfo.CompSizeData,SectionInfo.DecompSizeData);

     FileHandle:=FileCreate('log/SectionInfo');
     FileWrite(FileHandle,USectionInfo^,SectionInfo.DecompSizeData);
     fileclose(FileHandle);

     sid:=USectionInfo;
     //sid:=pointer(longint(SectionInfo)+sizeof(dwg2004systemsection));
     sd:=pointer(PTRUINT(sid)+{sizeof(dwg2004sectioninfo)}+20);
     for i:=0 to {SectionMap.DecompSizeData div 8}sid.NumDescriptions-1 do
     begin
          {sarray[i].Number:=sm.SectionNumber;
          sarray[i].Size:=sm.SectionSize;
          if i=0 then
                     sarray[i].Offset:=$100
                 else
                     sarray[i].Offset:=sarray[i-1].Offset+sarray[i-1].Size;
          shared.HistoryOutStr(format('Section %d, size %d, offset %d',[sarray[i].Number,sarray[i].Size,sarray[i].Offset]));}
          //longint(sd):=longint(sd)-64+length(pchar(@sd.SectionName[1]));
          //a:=64-length(pchar(@sd.SectionName[1]);
          a:=sizeof(sd^);
          PtrUInt(sd):=PtrUInt(sd)+{sizeof(dwg2004sectiondesc}32+64;
          //inc(longword(sd),sizeof({sd^}dwg2004sectiondesc));

     end;
end;

procedure addfromdwg(name: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt);
var
  f: GDBOpenArrayOfByte;
  s: GDBString;
begin
  programlog.logoutstr('AddFromDWG',lp_IncPos);
  shared.HistoryOutStr(format(rsLoadingFile,[name]));
  f.InitFromFile(name);
  if f.Count<>0 then
  begin
    MainFormN.StartLongProcess(f.Count);
    s := f.ReadString(#0,'');
    if s = 'AC1018' then
        begin
          shared.HistoryOutStr(format(rsFileFormat,['DWG2004']));
          addfromdwg2004(f,'EOF',owner,loadmode);
        end
        else
        begin
             ShowError(rsUnknownFileFormat);
        end;
  MainFormN.EndLongProcess;
  end
     else
         shared.ShowError('IODWG.ADDFromDWG:'+format(rsUnableToOpenFile,[name]));
  f.done;
  programlog.logoutstr('end; {AddFromDWG}',lp_DecPos);
end;
begin
     {$IFDEF DEBUGINITSECTION}log.LogOut('iodwg.initialization');{$ENDIF}
end.
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

unit uzeffdwg;
{$INCLUDE zengineconfig.inc}
{$MODE OBJFPC}{$H+}
interface
uses LCLIntf,gdbentityfactory,zcadinterface,GDBLine,gdbobjectsconstdef,typinfo,
     zcadstrconsts,iodxf,fileutil,varman,uzegeometry,gdbasetypes,
     GDBGenericSubEntry,SysInfo,gdbase, GDBManager, sysutils, memman,UGDBDescriptor,
     uzctnrVectorBytes,GDBEntity,TypeDescriptors,ugdbsimpledrawing;
procedure addfromdwg(name: String;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing);
implementation
uses {GDBBlockDef,}UGDBLayerArray,fileformatsmanager;

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
    pdwg2004pageinfo=^dwg2004pageinfo;
    PTMyDWGSectionDesc=^TMyDWGSectionDesc;
    dwg2004pageinfo=packed record
                                 PageNumber:DWGLong;
                                 DataSize:DWGLong;
                                 StartOffset:DWG2Long;
                                 section:PTMyDWGSectionDesc;
                                 decompdata:pointer;
                           end;
    mypageinfoArray=array of dwg2004pageinfo;
    pdwg2004sectiondesc=^dwg2004sectiondesc;
    dwg2004sectiondesc=packed record
                                    SizeOfSection:DWG2Long;
                                    NumberOfSectionsThisType:DWGLong;
                                    MaxDecompressedSize:DWGLong;
                                    Unknown2:DWGLong;
                                    Compressed:DWGLong;
                                    SectionType:DWGLong;
                                    Encrypted:DWGLong;
                                    SectionName:packed array[1..64]of ansichar;
                             end;
    pmysectiondesc=^mysectiondesc;
    mysectiondesc=packed record
                                    SizeOfSection:DWG2Long;
                                    NumberOfSectionsThisType:DWGLong;
                                    MaxDecompressedSize:DWGLong;
                                    Unknown2:DWGLong;
                                    Compressed:DWGLong;
                                    SectionType:DWGLong;
                                    Encrypted:DWGLong;
                                    SectionName:string;
                                    pages:mypageinfoArray;
                             end;
    mysectiondescArray=array of mysectiondesc;
    TMyDWGSectionDesc=packed record
                            Number:DWGLong;
                            Size:DWGLong;
                            Offset:DWGLong;
                      end;
    TMyDWGSectionDescArray=array of TMyDWGSectionDesc;
{
#define BITCODE_DOUBLE double

#define BITCODE_RC char
#define FORMAT_RC "%2x"
#define BITCODE_MC long int
#define FORMAT_MC "%l"
#define BITCODE_MS long unsigned int
#define FORMAT_MS "%lu"
#define BITCODE_B unsigned char
#define FORMAT_B "%d"
#define BITCODE_BB unsigned char
#define FORMAT_BB "%d"
#define BITCODE_BS unsigned int
#define FORMAT_BS "%d"
#define BITCODE_RS unsigned int
#define FORMAT_RS "%d"
#define BITCODE_RL long unsigned int
#define FORMAT_RL "%lu"
#define BITCODE_RD BITCODE_DOUBLE
#define FORMAT_RD "%f"
#define BITCODE_BL long unsigned int
#define FORMAT_BL "%lu"
#define BITCODE_TV unsigned char *
#define FORMAT_TV "\"%s\""
#define BITCODE_BT BITCODE_DOUBLE
#define FORMAT_BT "%f"
#define BITCODE_DD BITCODE_DOUBLE
#define FORMAT_DD "%f"
#define BITCODE_BD BITCODE_DOUBLE
#define FORMAT_BD "%f"
#define BITCODE_BE BITCODE_3BD
#define BITCODE_CMC Dwg_Color
#define BITCODE_H Dwg_Object_Ref*
#define BITCODE_4BITS BITCODE_RC
#define FORMAT_4BITS "%1x"
}
    BITCODE_RL=LongWord;
    BITCODE_RS=word;
    BITCODE_RC=byte;
    BITCODE_MS=LongWord{word};
    BITCODE_BS=word;
    BITCODE_H=DWGLong;
    BITCODE_B=Boolean;
    BITCODE_DD=double;
    BITCODE_RD=double;
    BITCODE_BD=double;
    BITCODE_BL=LongWord{word};

    BITCODE_CMC=byte;//error--------------------------------------------
    BITCODE_TV=string;

    BITCODE_BB=byte;

    barray=array [0..100] of BITCODE_RC;
    pbarray=^barray;
    bit_chain={$IFNDEF DELPHI}packed{$ENDIF} object
                           chain:PDWGByte;
                           size:DWord;
                           byte:DWord;
                           bit:DWGByte;
                           constructor init(_chain:pointer;_size:DWord);
                           procedure setto(_chain:pointer;_size:DWord);
                           function BitRead_rc:BITCODE_RC;
                           function BitRead_rs:BITCODE_RS;
                           function BitRead_rl:BITCODE_RL;
                           function BitRead_ms:BITCODE_MS;
                           function BitRead_bb:BITCODE_BB;
                           function BitRead_bs:BITCODE_BS;
                           function BitRead_h:BITCODE_H;
                           function BitRead_b:BITCODE_B;
                           function BitRead_rd:BITCODE_rd;
                           function BitRead_bd:BITCODE_bd;
                           function BitRead_dd(default_value:BITCODE_DD):BITCODE_DD;
                           function BitRead_bl:BITCODE_BL;
                           function BitRead_CMC:BITCODE_CMC;
                           function BitRead_TV:BITCODE_TV;
                           procedure scroll(scrollbit:integer);
                     end;
    TEncryptedSectionHeader=packed record
                            case byte of
                            0:(field:packed record
                            tag:DWGLong;
                            section_type:DWGLong;
                            data_size:DWGLong;
                            section_size:DWGLong;
                            start_offset:DWGLong;
                            unknown:DWGLong;
                            checksum_1:DWGLong;
                            checksum_2:DWGLong;
                            end);
                            1:(LongData:
                            array [0..7] of DWGLong);
                            2:(ByteData:
                            array [0..31] of DWGByte);
                            end;
const
    SECTION_HEADER = $01;
    SECTION_AUXHEADER = $02;
    SECTION_CLASSES = $03;
    SECTION_HANDLES = $04;
    SECTION_TEMPLATE = $05;
    SECTION_OBJFREESPACE = $06;
    SECTION_DBOBJECTS = $07;
    SECTION_REVHISTORY = $08;
    SECTION_SUMMARYINFO = $09;
    SECTION_PREVIEW = $0a;
    SECTION_APPINFO = $0b;
    SECTION_APPINFOHISTORY = $0c;
    SECTION_FILEDEPLIST = $0d;
    //SECTION_SECURITY,      //
    //SECTION_VBAPROJECT,    // not seen
    //SECTION_SIGNATURE      //
    	{$TYPEINFO ON}
      type
      DWG_OBJECT_TYPE=(
      DWG_TYPE_UNUSED:= $00,
      DWG_TYPE_TEXT:= $01,
      DWG_TYPE_ATTRIB := $02,
      DWG_TYPE_ATTDEF := $03,
      DWG_TYPE_BLOCK := $04,
      DWG_TYPE_ENDBLK := $05,
      DWG_TYPE_SEQEND := $06,
      DWG_TYPE_INSERT := $07,
      DWG_TYPE_MINSERT := $08,
      //DWG_TYPE_<UNKNOWN> := $09,
      DWG_TYPE_VERTEX_2D := $0a,
      DWG_TYPE_VERTEX_3D := $0b,
      DWG_TYPE_VERTEX_MESH := $0c,
      DWG_TYPE_VERTEX_PFACE := $0d,
      DWG_TYPE_VERTEX_PFACE_FACE := $0e,
      DWG_TYPE_POLYLINE_2D := $0f,
      DWG_TYPE_POLYLINE_3D := $10,
      DWG_TYPE_ARC := $11,
      DWG_TYPE_CIRCLE := $12,
      DWG_TYPE_LINE := $13,
      DWG_TYPE_DIMENSION_ORDINATE := $14,
      DWG_TYPE_DIMENSION_LINEAR := $15,
      DWG_TYPE_DIMENSION_ALIGNED := $16,
      DWG_TYPE_DIMENSION_ANG3PT := $17,
      DWG_TYPE_DIMENSION_ANG2LN := $18,
      DWG_TYPE_DIMENSION_RADIUS := $19,
      DWG_TYPE_DIMENSION_DIAMETER := $1A,
      DWG_TYPE_POINT := $1b,
      DWG_TYPE__3DFACE := $1c,
      DWG_TYPE_POLYLINE_PFACE := $1d,
      DWG_TYPE_POLYLINE_MESH := $1e,
      DWG_TYPE_SOLID := $1f,
      DWG_TYPE_TRACE := $20,
      DWG_TYPE_SHAPE := $21,
      DWG_TYPE_VIEWPORT := $22,
      DWG_TYPE_ELLIPSE := $23,
      DWG_TYPE_SPLINE := $24,
      DWG_TYPE_REGION := $25,
      DWG_TYPE_3DSOLID := $26,
      DWG_TYPE_BODY := $27,
      DWG_TYPE_RAY := $28,
      DWG_TYPE_XLINE := $29,
      DWG_TYPE_DICTIONARY := $2a,
      //DWG_TYPE_<UNKNOWN> := $2b,
      DWG_TYPE_MTEXT := $2c,
      DWG_TYPE_LEADER := $2d,
      DWG_TYPE_TOLERANCE := $2e,
      DWG_TYPE_MLINE := $2f,
      DWG_TYPE_BLOCK_CONTROL := $30,
      DWG_TYPE_BLOCK_HEADER := $31,
      DWG_TYPE_LAYER_CONTROL := $32,
      DWG_TYPE_LAYER := $33,
      DWG_TYPE_SHAPEFILE_CONTROL := $34,
      DWG_TYPE_SHAPEFILE := $35,
      //DWG_TYPE_<UNKNOWN> := $36,
      //DWG_TYPE_<UNKNOWN> := $37,
      DWG_TYPE_LTYPE_CONTROL := $38,
      DWG_TYPE_LTYPE := $39,
      //DWG_TYPE_<UNKNOWN> := $3a,
      //DWG_TYPE_<UNKNOWN> := $3b,
      DWG_TYPE_VIEW_CONTROL := $3c,
      DWG_TYPE_VIEW := $3d,
      DWG_TYPE_UCS_CONTROL := $3e,
      DWG_TYPE_UCS := $3f,
      DWG_TYPE_VPORT_CONTROL := $40,
      DWG_TYPE_VPORT := $41,
      DWG_TYPE_APPID_CONTROL := $42,
      DWG_TYPE_APPID := $43,
      DWG_TYPE_DIMSTYLE_CONTROL := $44,
      DWG_TYPE_DIMSTYLE := $45,
      DWG_TYPE_VP_ENT_HDR_CONTROL := $46,
      DWG_TYPE_VP_ENT_HDR := $47,
      DWG_TYPE_GROUP := $48,
      DWG_TYPE_MLINESTYLE := $49,
      //DWG_TYPE_<UNKNOWN> := $4a
      //DWG_TYPE_<UNKNOWN> := $4b
      //DWG_TYPE_<UNKNOWN> := $4c
      DWG_TYPE_LWPLINE := $4d,
      DWG_TYPE_HATCH := $4e,
      DWG_TYPE_XRECORD := $4f,
      DWG_TYPE_PLACEHOLDER := $50,
      //DWG_TYPE_<UNKNOWN> := $51,
      DWG_TYPE_LAYOUT := $52
      );
function DWGObjectName(ot:DWG_OBJECT_TYPE):string;
begin
     result:='Unknown';
     if integer(ot)<=$52 then
     case ot of
     DWG_TYPE_UNUSED:result:='DWG_TYPE_UNUSED';
     DWG_TYPE_TEXT:result:='DWG_TYPE_TEXT';
     DWG_TYPE_ATTRIB :result:='DWG_TYPE_ATTRIB';
     DWG_TYPE_ATTDEF :result:='DWG_TYPE_ATTDEF';
     DWG_TYPE_BLOCK :result:='DWG_TYPE_BLOCK';
     DWG_TYPE_ENDBLK :result:='DWG_TYPE_ENDBLK';
     DWG_TYPE_SEQEND :result:='DWG_TYPE_SEQEND';
     DWG_TYPE_INSERT :result:='DWG_TYPE_INSERT';
     DWG_TYPE_MINSERT :result:='DWG_TYPE_MINSERT';
     //DWG_TYPE_<UNKNOWN> :result:=''; $09,
     DWG_TYPE_VERTEX_2D :result:='DWG_TYPE_VERTEX_2D';
     DWG_TYPE_VERTEX_3D :result:='DWG_TYPE_VERTEX_3D';
     DWG_TYPE_VERTEX_MESH :result:='DWG_TYPE_VERTEX_MESH';
     DWG_TYPE_VERTEX_PFACE :result:='DWG_TYPE_VERTEX_PFACE';
     DWG_TYPE_VERTEX_PFACE_FACE :result:='DWG_TYPE_VERTEX_PFACE_FACE';
     DWG_TYPE_POLYLINE_2D :result:='DWG_TYPE_POLYLINE_2D';
     DWG_TYPE_POLYLINE_3D :result:='DWG_TYPE_POLYLINE_3D';
     DWG_TYPE_ARC :result:='DWG_TYPE_ARC';
     DWG_TYPE_CIRCLE :result:='DWG_TYPE_CIRCLE';
     DWG_TYPE_LINE :result:='DWG_TYPE_LINE';
     DWG_TYPE_DIMENSION_ORDINATE :result:='DWG_TYPE_DIMENSION_ORDINATE';
     DWG_TYPE_DIMENSION_LINEAR :result:='DWG_TYPE_DIMENSION_LINEAR';
     DWG_TYPE_DIMENSION_ALIGNED :result:='DWG_TYPE_DIMENSION_ALIGNED';
     DWG_TYPE_DIMENSION_ANG3PT :result:='DWG_TYPE_DIMENSION_ANG3PT';
     DWG_TYPE_DIMENSION_ANG2LN :result:='DWG_TYPE_DIMENSION_ANG2LN';
     DWG_TYPE_DIMENSION_RADIUS :result:='DWG_TYPE_DIMENSION_RADIUS';
     DWG_TYPE_DIMENSION_DIAMETER :result:='DWG_TYPE_DIMENSION_DIAMETER';
     DWG_TYPE_POINT :result:='DWG_TYPE_POINT';
     DWG_TYPE__3DFACE :result:='DWG_TYPE__3DFACE';
     DWG_TYPE_POLYLINE_PFACE :result:='DWG_TYPE_POLYLINE_PFACE';
     DWG_TYPE_POLYLINE_MESH :result:='DWG_TYPE_POLYLINE_MESH';
     DWG_TYPE_SOLID :result:='DWG_TYPE_SOLID';
     DWG_TYPE_TRACE :result:='DWG_TYPE_TRACE';
     DWG_TYPE_SHAPE :result:='DWG_TYPE_SHAPE';
     DWG_TYPE_VIEWPORT :result:='DWG_TYPE_VIEWPORT';
     DWG_TYPE_ELLIPSE :result:='DWG_TYPE_ELLIPSE';
     DWG_TYPE_SPLINE :result:='DWG_TYPE_SPLINE';
     DWG_TYPE_REGION :result:='DWG_TYPE_REGION';
     DWG_TYPE_3DSOLID :result:='DWG_TYPE_3DSOLID';
     DWG_TYPE_BODY :result:='DWG_TYPE_BODY';
     DWG_TYPE_RAY :result:='DWG_TYPE_RAY';
     DWG_TYPE_XLINE :result:='DWG_TYPE_XLINE';
     DWG_TYPE_DICTIONARY :result:='DWG_TYPE_DICTIONARY';
     //DWG_TYPE_<UNKNOWN> :result:=''; $2b,
     DWG_TYPE_MTEXT :result:='DWG_TYPE_MTEXT';
     DWG_TYPE_LEADER :result:='DWG_TYPE_LEADER';
     DWG_TYPE_TOLERANCE :result:='DWG_TYPE_TOLERANCE';
     DWG_TYPE_MLINE :result:='DWG_TYPE_MLINE';
     DWG_TYPE_BLOCK_CONTROL :result:='DWG_TYPE_BLOCK_CONTROL';
     DWG_TYPE_BLOCK_HEADER :result:='DWG_TYPE_BLOCK_HEADER';
     DWG_TYPE_LAYER_CONTROL :result:='DWG_TYPE_LAYER_CONTROL';
     DWG_TYPE_LAYER :result:='DWG_TYPE_LAYER';
     DWG_TYPE_SHAPEFILE_CONTROL :result:='DWG_TYPE_SHAPEFILE_CONTROL';
     DWG_TYPE_SHAPEFILE :result:='DWG_TYPE_SHAPEFILE';
     //DWG_TYPE_<UNKNOWN> :result:=''; $36,
     //DWG_TYPE_<UNKNOWN> :result:=''; $37,
     DWG_TYPE_LTYPE_CONTROL :result:='DWG_TYPE_LTYPE_CONTROL';
     DWG_TYPE_LTYPE :result:='DWG_TYPE_LTYPE';
     //DWG_TYPE_<UNKNOWN> :result:=''; $3a,
     //DWG_TYPE_<UNKNOWN> :result:=''; $3b,
     DWG_TYPE_VIEW_CONTROL :result:='DWG_TYPE_VIEW_CONTROL';
     DWG_TYPE_VIEW :result:='DWG_TYPE_VIEW';
     DWG_TYPE_UCS_CONTROL :result:='DWG_TYPE_UCS_CONTROL';
     DWG_TYPE_UCS :result:='DWG_TYPE_UCS';
     DWG_TYPE_VPORT_CONTROL :result:='DWG_TYPE_VPORT_CONTROL';
     DWG_TYPE_VPORT :result:='DWG_TYPE_VPORT';
     DWG_TYPE_APPID_CONTROL :result:='DWG_TYPE_APPID_CONTROL';
     DWG_TYPE_APPID :result:='DWG_TYPE_APPID';
     DWG_TYPE_DIMSTYLE_CONTROL :result:='DWG_TYPE_DIMSTYLE_CONTROL';
     DWG_TYPE_DIMSTYLE :result:='DWG_TYPE_DIMSTYLE';
     DWG_TYPE_VP_ENT_HDR_CONTROL :result:='DWG_TYPE_VP_ENT_HDR_CONTROL';
     DWG_TYPE_VP_ENT_HDR :result:='DWG_TYPE_VP_ENT_HDR';
     DWG_TYPE_GROUP :result:='DWG_TYPE_GROUP';
     DWG_TYPE_MLINESTYLE :result:='DWG_TYPE_MLINESTYLE';
     //DWG_TYPE_<UNKNOWN> :result:=''; $4a
     //DWG_TYPE_<UNKNOWN> :result:=''; $4b
     //DWG_TYPE_<UNKNOWN> :result:=''; $4c
     DWG_TYPE_LWPLINE :result:='DWG_TYPE_LWPLINE';
     DWG_TYPE_HATCH :result:='DWG_TYPE_HATCH';
     DWG_TYPE_XRECORD :result:='DWG_TYPE_XRECORD';
     DWG_TYPE_PLACEHOLDER :result:='';
     //DWG_TYPE_<UNKNOWN> :result:=''; $51,
     DWG_TYPE_LAYOUT :result:='DWG_TYPE_LAYOUT';
     end;

end;

constructor bit_chain.init(_chain:pointer;_size:DWord);
begin
     setto(_chain,_size);
end;
procedure bit_chain.setto(_chain:pointer;_size:DWord);
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
procedure bit_chain.scroll(scrollbit:integer);
var
  endpos:integer;
begin
  endpos:=bit+scrollbit;
  if (byte>=size - 1) and (endpos > 7) then
    begin
      bit:=7;
      exit;
    end;
  bit:=endpos mod 8;
  byte:=byte+(endpos div 8);
end;

function bit_chain.BitRead_rc:BITCODE_RC;
var
   b:DWGByte;
begin
     if bit=0 then
         begin
              result:=PDWGByte(PtrUInt(chain)+(byte))^;
              inc(byte);
         end
     else
        begin
             result:=PDWGByte(PtrUInt(chain)+(byte))^ shl bit;
          if (byte < size - 1) then
            begin
              b:=PDWGByte(PtrUInt(chain)+(byte+1))^;
              result:=result or (b shr (8-bit));
            end;
             scroll(8);
        end;
end;
function bit_chain.BitRead_rl:BITCODE_RL;
var
   b1:BITCODE_RS;
   b2:BITCODE_RL;
begin
     b1:=BitRead_rs;
     b2:=BitRead_rs;
     result:=((b2 shl 16) or b1);
end;
//BITCODE_MS
//bit_read_MS(Bit_Chain * dat)
{
  int i, j;
  unsigned int word[2];
  long unsigned int result;

  result = 0;
  for (i = 1, j = 0; i > -1; i--, j += 15)
    {
      word[i] = bit_read_RS(dat);
      if (!(word[i] & 0x8000))
        {
          result |= (((long unsigned int) word[i]) << j);
          return (result);
        }
      else
        word[i] &= 0x7fff;
      result |= ((long unsigned int) word[i]) << j;
    }
  LOG_ERROR("bit_read_MS: error parsing modular short.")
  return 0; /* error... */
}

function bit_chain.BitRead_ms:BITCODE_MS;
var
   //b1:BITCODE_RS;
   //b2:BITCODE_RL;
   i, j:integer;
   w:array [0..1] of word;
   //long unsigned int result;
begin
       result:= 0;
       w[0]:=0;
       w[1]:=0;
       j:=0;
       for i:=1 downto 0 do
       //for (i = 1, j = 0; i > -1; i--, j += 15)
         begin
           w[i]:=BitRead_rs;
           if not((w[i] and $8000)>0) then
             begin
               result :=result or (LongWord(w[i]) shl j);
               exit;
             end
           else
             begin
             w[i] := w[i] and $7fff;
             result := result or (LongWord(w[i]) shl j);
             end;
             j:=j+15;
         end;
       result:=0;
end;
function bit_chain.BitRead_bb:BITCODE_BB;
var
   b:BITCODE_RC;
begin
       b:=PDWGByte(PtrUInt(chain)+(byte))^;
       if (bit<7) then
         result:=(b and ($c0 shr bit)) shr (6 - bit)
       else
         begin
           result := (b and $01) shl 1;
           if (byte < size-1) then
             begin
               b:=PDWGByte(PtrUInt(chain)+(byte+1))^;
               result :=result or ((b and $80) shr 7);
             end;
         end;
       scroll(2);
end;
function bit_chain.BitRead_bs:BITCODE_BS;
var
   two_bit_code:BITCODE_RC;
begin
  two_bit_code:= BitRead_BB;

  if (two_bit_code = 0) then
    begin
      result := BitRead_RS;
      exit;
    end
  else if (two_bit_code = 1) then
    begin
      result := BitRead_RC;
      exit;
    end
  else if (two_bit_code = 2) then
    exit(0)
  else
    // if (two_bit_code == 3) */
    exit(256);

end;

function bit_chain.BitRead_rs:BITCODE_RS;
var
   b1:BITCODE_RC;
   b2:BITCODE_RS;
begin
     b1:=BitRead_rc;
     b2:=BitRead_rc;
     result:=((b2 shl 8) or b1);
end;
{bit_read_H(Bit_Chain * dat, Dwg_Handle * handle)
{
  unsigned char *val;
  int i;

  handle->code = bit_read_RC(dat);
  handle->size = handle->code & 0x0f;
  handle->code = (handle->code & 0xf0) >> 4;

  handle->value = 0;
  if (handle->size > 4)
    {
      LOG_ERROR(
          "handle-reference is longer than 4 bytes: %i.%i.%lu",
          handle->code, handle->size, handle->value)
      handle->size = 0;
      return (-1);
    }

  val = (unsigned char *) &handle->value;
  for (i = handle->size - 1; i >= 0; i--)
    val[i] = bit_read_RC(dat);

  return (0);
}}

function bit_chain.BitRead_h:BITCODE_H;
var
   _code:BITCODE_RC;
   _size:BITCODE_RC;
   pb:pbarray;
   i:integer;
   r:BITCODE_H;
begin
     r:=0;
     _code:=BitRead_rc;
     _size:=_code and $0f;
     _code:=(_code and $f0)shr 4;
     if _size>16 then
                   begin
                        ShowError('Handle is longer than 4 bytes');
                   end
               else
                   begin
                     pointer(pb):= @r;
                     for i:=_size-1 downto 0 do
                       {pb^[i]:=}BitRead_rc;
                   end;
   result:=r;
end;

{bit_read_B(Bit_Chain * dat)
{
  unsigned char result;
  unsigned char byte;

  byte = dat->chain[dat->byte];
  result = (byte & (0x80 >> dat->bit)) >> (7 - dat->bit);

  bit_advance_position(dat, 1);
  return result;
}}
function bit_chain.BitRead_b:BITCODE_B;
var
   _byte,b2:BITCODE_RC;

begin
     _byte:=PDWGByte(PtrUInt(chain)+(byte))^;
     b2:= (_byte and ($80 shr bit))shr(7-bit);
     scroll(1);
     if b2>0 then
                 result:=true
             else
                 result:=false;
end;
function bit_chain.BitRead_rd:BITCODE_rd;
var
   i:integer;
   ba:pbarray;
   res:double;
begin
     res:=0;
     ba:=@res;
       for i:=0 to 7 do
         ba^[i]:=BitRead_rc;

       result:=res;
end;
{
  color->index = bit_read_BS(dat);
  if (dat->version >= R_2004)
    {
      color->rgb = bit_read_BL(dat);
      color->byte = bit_read_RC(dat);
      if (color->byte & 1)
        color->name = (char*)bit_read_TV(dat);
      if (color->byte & 2)
        color->book_name = (char*)bit_read_TV(dat);
    }
}

function bit_chain.BitRead_CMC:BITCODE_CMC;
var
   _byte:BITCODE_RC;
begin
  {color->index = }BitRead_BS;
  //if (dat->version >= R_2004)

      {color->rgb = }BitRead_BL;
      {color->byte = }_byte:=BitRead_RC;
      if (_byte and 1)>0 then
        {color->name = (char*)}BitRead_TV;
      if (_byte and 2)>0 then
        {color->book_name = (char*)}BitRead_TV;


end;
function bit_chain.BitRead_TV:BITCODE_TV;
var i:integer;
begin
  setlength(result,BitRead_BS);
  //chain = (unsigned char *) malloc(length + 1);
  for i:=1 to length(result) do
    begin
      pbyte(@result[i])^:=BitRead_RC;
      //if (chain[i] == 0)
      //  chain[i] = '*';
      //else if (!isprint (chain[i]))
      //  chain[i] = '~';
    end;
end;

function bit_chain.BitRead_bl:BITCODE_BL;
var
   two_bit_code:BITCODE_BB;
begin
    two_bit_code:=BitRead_BB;
    if two_bit_code=0 then
                          exit(BitRead_rl);
    if two_bit_code=1 then
                          exit(BitRead_RC and $ff);
    if two_bit_code=2 then
    begin
         exit(0);
    end;
    if two_bit_code=3 then
    begin
       ShowError('BitRead_bl: unexpected 2-bit code: "11"');
    end;
end;

function bit_chain.BitRead_dd(default_value:BITCODE_DD):BITCODE_DD;
var
   two_bit_code:BITCODE_BB;
   uchar_result:pbarray;
begin

    //unsigned char two_bit_code;
    //unsigned char *uchar_result;

    two_bit_code:=BitRead_BB;
    if two_bit_code=0 then
                          exit(default_value);
    if two_bit_code=3 then
                          exit(BitRead_RD);
    if two_bit_code=2 then
    begin
        uchar_result:=@default_value;
        uchar_result^[4]:=BitRead_RC;
        uchar_result^[5]:=BitRead_RC;
        uchar_result^[0]:=BitRead_RC;
        uchar_result^[1]:=BitRead_RC;
        uchar_result^[2]:=BitRead_RC;
        uchar_result^[3]:=BitRead_RC;

        exit(default_value);
    end;
    if two_bit_code=1 then
    begin
       uchar_result:=@default_value;
       uchar_result^[0]:=BitRead_RC;
       uchar_result^[1]:=BitRead_RC;
       uchar_result^[2]:=BitRead_RC;
       uchar_result^[3]:=BitRead_RC;

        exit(default_value);
    end;
end;
function bit_chain.BitRead_bd:BITCODE_bd;
var
   two_bit_code:BITCODE_BB;
begin
    two_bit_code:=BitRead_BB;
    if two_bit_code=0 then
                          exit(BitRead_RD);
    if two_bit_code=1 then
                          exit(1);
    if two_bit_code=2 then
                          exit(0);
    if two_bit_code=3 then
                          ShowError('BitRead_bd: unexpected 2-bit code: "11"');
//    result:=result;

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
     byte:=bc.BitRead_rc;

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
      byte:=bc.BitRead_rc;
      while (byte=$00) do
                         begin
                          total:=total+$FF;
                          byte:=bc.BitRead_rc;
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
  firstByte := bc.BitRead_rc;
  secondByte := bc.BitRead_rc;
  result := (firstByte shr 2) or (secondByte shl 6);
  lit_length := (firstByte and $03);
end;
function read_long_compression_offset(var bc:bit_chain):integer;
var
    total:integer;
    byte:DWGByte;
begin
  total:=0;
  byte := bc.BitRead_rc;
  if (byte = 0) then
    begin
      total := $FF;
     byte := bc.BitRead_rc;
      while ((byte) = $00) do
        begin
        total := total+$FF;
        byte := bc.BitRead_rc;
        end;
    end;
  result:=total + byte;
end;
function decompress(var pdecompdata:PDWGByte;ptr:pbyte;csize,usize:integer;var decompsize:integer):PDWGByte;
var
   bc:bit_chain;
   opcode1,opcode2:DWGByte;
   lit_length:integer;
   i:integer;
   dst,src:pbyte;
   comp_bytes,comp_offset:integer;
begin
  decompsize:=-1;
  result:=pdecompdata;
  dst:=result;
  bc.init(ptr,csize);
  lit_length:=read_literal_length(bc,opcode1);

  for i := 1  to lit_length do
  begin
      dst^:=bc.BitRead_rc;
      inc(dst);
  end;

  opcode1:=0;
  while bc.byte<csize do
  begin
       if opcode1=0 then
                        opcode1:=bc.BitRead_rc;
       if opcode1 >= $40 then
               begin
                 //HistoryOutStr('1 '+format('writeln %d bytes',[ptruint(dst)-ptruint(result)]));
                 comp_bytes:=((opcode1 and $F0) shr 4) - 1;
                 opcode2 := bc.BitRead_rc;
                 comp_offset := (opcode2 shl 2) or ((opcode1 and $0C) shr 2);
                 if (opcode1 and $03)>0 then
                   begin
                     lit_length := (opcode1 and $03);
                     opcode1  := $00;
                   end
                 else
                   lit_length := read_literal_length(bc, opcode1);
//                 if lit_length=0 then
//                                     lit_length:=lit_length;
                 //HistoryOutStr('  '+format('comp_bytes=%d comp_offset=%d lit_length=%d',[comp_bytes,comp_offset,lit_length]));
               end
       else if (opcode1 >= $21) and (opcode1 <= $3F) then
         begin
           //HistoryOutStr('2');
           comp_bytes  := opcode1 - $1E;
           comp_offset := read_two_byte_offset(bc, lit_length);

           if (lit_length <> 0) then
             opcode1 := $00
           else
             lit_length := read_literal_length(bc, opcode1);
         end
       else if (opcode1 = $20) then
         begin
           //HistoryOutStr('3');
           comp_bytes  := read_long_compression_offset(bc) + $21;
           comp_offset := read_two_byte_offset(bc, lit_length);

           if (lit_length <> 0) then
             opcode1 := $00
           else
             lit_length := read_literal_length(bc, opcode1);
         end
       else if (opcode1 >= $12) and (opcode1 <= $1F) then
         begin
           //HistoryOutStr('4');
           comp_bytes  := (opcode1 and $0F) + 2;
           comp_offset := read_two_byte_offset(bc, lit_length) + $3FFF;

           if (lit_length <> 0) then
             opcode1 := $00
           else
             lit_length := read_literal_length(bc, opcode1);
         end
       else if (opcode1 = $10) then
         begin
           //HistoryOutStr('5');
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
           begin
//             opcode1:=opcode1;
           exit{(1)};  // error in input stream
           end;


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
           dst^:=bc.BitRead_rc;
           inc(dst);
       end;

  end;
  decompsize:=dst-result;
  pdecompdata:=dst;
end;


function decompresssection(ptr:pbyte;csize,usize:integer;var decompsize:integer;var pdecompdata:PDWGByte):PDWGByte;
begin
     decompsize:=-1;
     if pdecompdata=nil then
                            begin
                            Getmem(result,usize);
                            pdecompdata:=result;
                            end
                         else
                             result:=pdecompdata;
     decompress(result,ptr,csize,usize,decompsize)
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
           HistoryOutStr(inttohex(byte(RorDword(randseed,16)),4));
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
function FindInfoByType(const siarray:mysectiondescArray;SectionType:DWGLong):pmysectiondesc;
var
    i:integer;
begin
     for i:=low(siarray) to High(siarray) do
     if siarray[i].SectionType=SectionType then
       begin
            result:=@siarray[i];
            exit;
       end;
     result:=nil;
end;

procedure addfromdwg2004(var f:TZctnrVectorBytes; exitString: String;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt);
var fh:pdwg2004header;
    fdh:dwg2004headerdecrypteddata;
    syssec,SectionMap,SectionInfo:pdwg2004systemsection;
    USectionMap,USectionInfo,objsection:pointer;
    i,j,jj,a,extdatasize,NumberOfSectionsThisType:integer;
    psize:dwglong;
    tb:boolean;
    sm:pdwg2004sectionmap;
    sid:pdwg2004sectioninfo;
    sd:pdwg2004sectiondesc;
    pi:pdwg2004pageinfo;
    sarray:TMyDWGSectionDescArray;
    siarray:mysectiondescArray;

    objinfo:pmysectiondesc;

    FileHandle:cardinal;

    address:integer;
    bc,objbitreader:bit_chain;
    es:TEncryptedSectionHeader;
    sec_mask:DWGLong;
    decompsize:integer;
    ot:DWG_OBJECT_TYPE;
    ziszero:boolean;
    v1,v2:gdbvertex;

    nolink:boolean;
    color_mode:boolean;
    index:word;
    flags:word;

    pobj:PGDBObjEntity;
begin
     fh:=f.PArray;
     fdh:=pdwg2004headerdecrypteddata(@fh^.EncryptedData)^;
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
     inc(pointer(SectionInfo),SectionMap^.CompSizeData+sizeof(dwg2004systemsection));
     HistoryOutStr('MAP');
     USectionMap:=nil;
     decompresssection(pointer(PTRUINT(SectionMap)+sizeof(dwg2004systemsection)),SectionMap^.CompSizeData,SectionMap^.DecompSizeData,decompsize,USectionMap);
     setlength(sarray,fdh.SectionPageArraySize);
     sm:=pointer(USectionMap);
     for i:=0 to {SectionMap.DecompSizeData div 8}fdh.SectionPageAmount-1 do
     begin
          sarray[i].Number:=sm^.SectionNumber;
          sarray[i].Size:=sm^.SectionSize;
          if i=0 then
                     sarray[i].Offset:=$100
                 else
                     sarray[i].Offset:=sarray[i-1].Offset+sarray[i-1].Size;
          HistoryOutStr(format('Section %d, size %d, offset %d',[sarray[i].Number,sarray[i].Size,sarray[i].Offset]));
          inc(sm);
     end;
     SectionInfo:=f.PArray;
     inc(pointer(SectionInfo),FindSectionByID(sarray,fdh.SectionInfoID)^.Offset);
     HistoryOutStr('INFO');
     USectionInfo:=nil;
     decompresssection(pointer(PTRUINT(SectionInfo)+sizeof(dwg2004systemsection)),SectionInfo^.CompSizeData,SectionInfo^.DecompSizeData,decompsize,USectionInfo);

     {FileHandle:=FileCreate('log/SectionInfo');
     FileWrite(FileHandle,USectionInfo^,SectionInfo.DecompSizeData);
     fileclose(FileHandle);}

     sid:=USectionInfo;
     //sid:=pointer(longint(SectionInfo)+sizeof(dwg2004systemsection));
     sd:=pointer(PTRUINT(sid)+sizeof(dwg2004sectioninfo){+20});
     setlength(siarray,sid^.NumDescriptions);
     for i:=0 to {SectionMap.DecompSizeData div 8}sid^.NumDescriptions-1 do
     begin
                                   {SizeOfSection:DWG2Long;
                                    NumberOfSectionsThisType:DWGLong;
                                    MaxDecompressedSize:DWGLong;
                                    Unknown2:DWGLong;
                                    Compressed:DWGLong;
                                    SectionType:DWGLong;
                                    Encrypted:DWGLong;
                                    SectionName:packed array[1..64]of ansichar;}
          HistoryOutStr('Section name: '+ pchar(@sd^.SectionName));
          HistoryOutStr(format(' SizeOfSection: %d, NumberOfSectionsThisType: %d, MaxDecompressedSize: %d, Unknown2: %d, Compressed: %d, SectionType: %d, Encrypted: %d',
                                    [sd^.SizeOfSection,  sd^.NumberOfSectionsThisType,  sd^.MaxDecompressedSize,  sd^.Unknown2,  sd^.Compressed,  sd^.SectionType,  sd^.Encrypted]));
          siarray[i].SizeOfSection:=sd^.SizeOfSection;
          siarray[i].NumberOfSectionsThisType:=sd^.NumberOfSectionsThisType;
          siarray[i].MaxDecompressedSize:=sd^.MaxDecompressedSize;
          siarray[i].Unknown2:=sd^.Unknown2;
          siarray[i].Compressed:=sd^.Compressed;
          siarray[i].SectionType:=sd^.SectionType;
          siarray[i].Encrypted:=sd^.Encrypted;
          siarray[i].SectionName:=pchar(@sd^.SectionName);
          setlength(siarray[i].pages,sd^.NumberOfSectionsThisType);
          NumberOfSectionsThisType:=sd^.NumberOfSectionsThisType;
          PtrUInt(sd):=PtrUInt(sd)+sizeof(dwg2004sectiondesc){32+64}{+16*sd.NumberOfSectionsThisType};
          pi:=pointer(sd);
          for a:=0 to NumberOfSectionsThisType-1 do
          begin
               siarray[i].pages[a].PageNumber:=pi^.PageNumber;
               siarray[i].pages[a].DataSize:=pi^.DataSize;
               siarray[i].pages[a].StartOffset:=pi^.StartOffset;
               siarray[i].pages[a].section:=FindSectionByID(sarray,pi^.PageNumber);
//               if siarray[i].pages[a].section=nil then
//                                                      pi:=pi;
               HistoryOutStr(format(' Page: %d, DataSize: %d, StartOffset: %d,',
                                           [pi^.PageNumber, pi^.DataSize,pi^.StartOffset]));
               PtrUInt(pi):=PtrUInt(pi)+{sizeof(dwg2004pageinfo)}16;
          end;
          sd:=pointer(pi);
          //inc(LongWord(sd),sizeof({sd^}dwg2004sectiondesc));
     end;
     HistoryOutStr('Prepare AcDb:AcDbObjects section');
     objinfo:=FindInfoByType(siarray,SECTION_DBOBJECTS);
     Getmem(objsection,objinfo^.MaxDecompressedSize*objinfo^.NumberOfSectionsThisType);
      bc.setto(f.PArray,f.size);
     for i:=0 to objinfo^.NumberOfSectionsThisType-1 do
       begin
         address:=objinfo^.pages[i].section^.Offset;
         bc.byte:=address;
         for j:= 0 to $20-1 do
           es.ByteData[j]:= bc.BitRead_rc;

         sec_mask:= $4164536b xor address;
         for j:= 0 to 7 do
           es.LongData[j]:=es.LongData[j] xor sec_mask;
         objinfo^.pages[i].decompdata:=objsection;
         objsection:=decompresssection(pointer(PtrUInt(bc.chain)+bc.byte),es.field.data_size,  $7400,decompsize,objsection);
         HistoryOutStr(format(' Page: %d, tag: %d, section_type: %d, data_size: %d, section_size: %d, start_offset: %d',
                                             [i, es.field.tag,es.field.section_type,es.field.data_size,es.field.section_size,es.field.start_offset]));
         HistoryOutStr(format(' Total decompressed size: %d',
                                             [decompsize]));
       end;
               FileHandle:=FileCreate('log/objsecmy2');
     FileWrite(FileHandle,objinfo^.pages[0].decompdata^,objinfo^.MaxDecompressedSize*objinfo^.NumberOfSectionsThisType);
     fileclose(FileHandle);

         objbitreader.init(objinfo^.pages[0].decompdata,objinfo^.MaxDecompressedSize*objinfo^.NumberOfSectionsThisType);
         HistoryOutStr(format(' 0x0dca: %x',[objbitreader.BitRead_rl]));

         while objbitreader.byte<objbitreader.size do
         begin
         //18.1  Common non-entity object format
         a:=objbitreader.BitRead_ms;//Size in bytes of object, not including the CRC
         //HistoryOutStr(format(' Size in bytes: %d',[a]));
         a:=objbitreader.byte+a;
         ot:=DWG_OBJECT_TYPE(objbitreader.BitRead_bs);//Object type
         //HistoryOutStr(format(' Object type: %x(%d), Name: %s',[ot,ot,DWGObjectName(ot)]));
         if ot=DWG_TYPE_LINE then
         begin
         objbitreader.BitRead_rl;//Size of object data in bits (number of bits before the handles), or the “endbit” of the pre-handles section.
         objbitreader.BitRead_h;//Object’s handle
         extdatasize:=objbitreader.BitRead_bs;//Size of extended object data, if any
         while extdatasize<>0 do
         begin
         if extdatasize<>0 then
                               begin
                               objbitreader.BitRead_h;
//                               extdatasize:=extdatasize;
                               for jj:=1 to extdatasize do
                               objbitreader.BitRead_rc;
                               end;
         extdatasize:=objbitreader.BitRead_bs;//Size of extended object data, if any
         end;
         tb:=objbitreader.BitRead_b;//1 if a graphic is present
         if tb then
                   begin
                   psize:=objbitreader.BitRead_rl;
                   for jj:=1 to psize do
                   objbitreader.BitRead_rc;
                   end;

         {objbitreader.BitRead_b;
         objbitreader.BitRead_bs;
         objbitreader.BitRead_bd;
         objbitreader.BitRead_bb;
         objbitreader.BitRead_bb;
         objbitreader.BitRead_bs;
         objbitreader.BitRead_rc;}


         {common}
         {objbitreader.BitRead_ms;
         objbitreader.BitRead_bs;
         objbitreader.BitRead_rl;
         objbitreader.BitRead_h;
         objbitreader.BitRead_bs;}
         //objbitreader.BitRead_b;//1 if a graphic is present

         objbitreader.BitRead_bb;//entity mode
         objbitreader.BitRead_bl;//number of persistent reactors attached to this object
         objbitreader.BitRead_b;//If 1, no XDictionary handle is stored for this object, otherwise XDictionary handle is stored as in R2000 and earlier.
         nolink:=objbitreader.BitRead_b;//1 if major links are assumed +1, -1, else 0 For R2004+ this always has value 1 (links are not used)


         //objbitreader.BitRead_cmc;//color
         //objbitreader.BitRead_bs;//color

           //SINCE(R_2004)
    {
      char color_mode = 0;
      unsigned char index;
      unsigned int flags;}

      if nolink=false then
        begin
          color_mode:=objbitreader.BitRead_b;

          if (color_mode) then
            index:= objbitreader.BitRead_RC  // color index
          else
            begin
              flags := objbitreader.BitRead_RS;

              if (flags and $8000)>0 then
                begin
                  //unsigned char c1, c2, c3, c4;
                  //char *name=0;

                  //c1 = bit_read_RC(dat);  // rgb color
                 // c2 = bit_read_RC(dat);
                  //c3 = bit_read_RC(dat);
                  //c4 = bit_read_RC(dat);
                  objbitreader.BitRead_RC;
                  objbitreader.BitRead_RC;
                  objbitreader.BitRead_RC;
                  objbitreader.BitRead_RC;

                  objbitreader.BitRead_TV;
                end;

//              if (flags and $4000)>0then
//                flags:=flags;   // has AcDbColor reference (handle)

              if (flags and $2000)>0 then
                begin
                  objbitreader.BitRead_BL;
                end;
            end
        end
      else
        begin
          objbitreader.BitRead_B;
        end;




         objbitreader.BitRead_bd;//Ltype scale
         objbitreader.BitRead_bb;//00 = bylayer, 01 = byblock, 10 = continous, 11 =linetype handle present at end of object
         objbitreader.BitRead_bb;//00 = bylayer, 01 = byblock, 11 = plotstyle handle present at end of object
         objbitreader.BitRead_bs;//Invisibility
         objbitreader.BitRead_rc;//Lineweight

              ziszero:=objbitreader.BitRead_b;
              //if (objbitreader.byte div $7400)=1 then
              begin
              if ziszero then begin
                                   v1.x:=objbitreader.BitRead_rd;
                                   v2.x:=objbitreader.BitRead_dd(v1.x);
                                   v1.y:=objbitreader.BitRead_rd;
                                   v2.y:=objbitreader.BitRead_dd(v1.y);
                                   v1.z:=0;
                                   v2.z:=0;

                              end
                         else
                             begin
                             v1.x:=objbitreader.BitRead_rd;
                             v2.x:=objbitreader.BitRead_dd(v1.x);
                             v1.y:=objbitreader.BitRead_rd;
                             v2.y:=objbitreader.BitRead_dd(v1.y);
                             v1.z:=objbitreader.BitRead_rd;
                             v2.z:=objbitreader.BitRead_dd(v1.z);
                             end;
                             //if (oneVertexlength(v1)<1000000)and(oneVertexlength(v2)<1000000)then
                             begin
                             pobj := CreateInitObjFree(GDBLineID,nil);
                             PGDBObjLine(pobj)^.CoordInOCS.lBegin:=v1;
                             PGDBObjLine(pobj)^.CoordInOCS.lEnd:=v2;
                             PGDBObjLine(pobj)^.vp.Layer:=gdb.GetCurrentDWG^.LayerTable.GetSystemLayer;
                             gdb.GetCurrentRoot^.AddMi(@pobj);
                             PGDBObjEntity(pobj)^.BuildGeometry(gdb.GetCurrentDWG^);
                             PGDBObjEntity(pobj)^.formatEntity(gdb.GetCurrentDWG^);
                             end;
              end;

         end;


         objbitreader.byte:=a;
         objbitreader.bit:=0;
         {HistoryOutStr(format(' CRC: %x',[}objbitreader.BitRead_rs{]))};
         end;
end;

procedure addfromdwg(name: String;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing);
var
  f: TZctnrVectorBytes;
  s: String;
begin
  DebugLn('{D+}AddFromDWG');
  //programlog.logoutstr('AddFromDWG',lp_IncPos);
  HistoryOutStr(format(rsLoadingFile,[name]));
  f.InitFromFile(name);
  if f.Count<>0 then
  begin
    if assigned(StartLongProcessProc) then
                                           StartLongProcessProc(f.Count,'Load DWG file');
    s := f.ReadString(#0,'');
    if s = 'AC1018' then
        begin
          HistoryOutStr(format(rsFileFormat,['DWG2004']));
          addfromdwg2004(f,'EOF',owner,loadmode);
        end
        else
        begin
             ShowError(rsUnknownFileFormat);
        end;
    if assigned(EndLongProcessProc) then
                                        EndLongProcessProc;
  end
     else
         ShowError('IODWG.ADDFromDWG:'+format(rsUnableToOpenFile,[name]));
  f.done;
  DebugLn('{D-}end; {AddFromDWG}');
  //programlog.logoutstr('end; {AddFromDWG}',lp_DecPos);
end;
begin
     Ext2LoadProcMap.RegisterExt('dwg','AutoCAD DWG files (*.dwg)',@addfromdwg);
end.

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
uses iodxf,fileutil,UGDBTextStyleArray,varman,geometry,GDBSubordinated,shared,gdbasetypes{,GDBRoot},log,GDBGenericSubEntry,SysInfo,gdbase, GDBManager, {OGLtypes,} sysutils{, strmy}, memman, UGDBDescriptor,{gdbobjectsconstdef,}
     UGDBObjBlockdefArray,UGDBOpenArrayOfTObjLinkRecord{,varmandef},UGDBOpenArrayOfByte,UGDBVisibleOpenArray,GDBEntity{,GDBBlockInsert,GDBCircle,GDBArc,GDBPoint,GDBText,GDBMtext,GDBLine,GDBPolyLine,GDBLWPolyLine},TypeDescriptors;
procedure addfromdwg(name: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt);
implementation
uses GDBBlockDef,mainwindow,UGDBLayerArray;

type
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
                      SectionMapID:DWGLong;
                      SectionPageArraySize:DWGLong;
                      GAPArraySize:DWGLong;
                      CRC32:DWGLong;
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

procedure addfromdwg2004(var f:GDBOpenArrayOfByte; exitGDBString: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt);
var fh:pdwg2004header;
    fdh:dwg2004headerdecrypteddata;
    i:integer;
begin
     fh:=f.PArray;
     fdh:=pdwg2004headerdecrypteddata(@fh.EncryptedData)^;
     i:=sizeof(dwgbyte);
     i:=sizeof(dwgword);
     i:=sizeof(dwglong);
     i:=sizeof(dwg2004header);
     i:=sizeof(dwg2004headerdecrypteddata);
     decodeheader(@fdh,$6c);
     fh:=f.PArray;
end;

procedure addfromdwg(name: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt);
var
  f: GDBOpenArrayOfByte;
  s: GDBString;
begin
  programlog.logoutstr('AddFromDWG',lp_IncPos);
  shared.HistoryOutStr('Loading file '+name+';');
  f.InitFromFile(name);
  if f.Count<>0 then
  begin
    MainFormN.StartLongProcess(f.Count);
    s := f.ReadString(#0,'');
    if s = 'AC1018' then
        begin
          shared.HistoryOutStr('DWG2004 fileformat;');
          addfromdwg2004(f,'EOF',owner,loadmode);
        end
        else
        begin
             ShowError('Uncnown fileformat '+s);
        end;
  MainFormN.EndLongProcess;
  end
     else
         shared.ShowError('IODXF.ADDFromDWG: Не могу открыть файл: '+name);
  f.done;
  programlog.logoutstr('end; {AddFromDWG}',lp_DecPos);
end;
begin
     {$IFDEF DEBUGINITSECTION}log.LogOut('iodwg.initialization');{$ENDIF}
end.

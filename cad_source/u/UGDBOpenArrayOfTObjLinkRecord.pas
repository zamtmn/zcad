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

unit UGDBOpenArrayOfTObjLinkRecord;
{$INCLUDE def.inc}
interface
uses gdbasetypes,sysutils,uGDBOpenArrayofdata,memman,gdbase;
type
{Export+}
TGenLincMode=(EnableGen,DisableGen);
PGDBOpenArrayOfTObjLinkRecord=^GDBOpenArrayOfTObjLinkRecord;
GDBOpenArrayOfTObjLinkRecord={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=TObjLinkRecord*)
                      GenLinkMode:TGenLincMode;
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      constructor initnul;
                      procedure CreateLinkRecord(PObj:GDBPointer;FilePos:GDBLongword;Mode:TObjLinkRecordMode);
                      function FindByOldAddres(pobj:GDBPointer):PTObjLinkRecord;
                      function FindByTempAddres(Addr:GDBLongword):PTObjLinkRecord;
                      function SetGenMode(Mode:TGenLincMode):TGenLincMode;
                      procedure Minimize;
                   end;
{Export-}
implementation
uses
    log;
constructor GDBOpenArrayOfTObjLinkRecord.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(TObjLinkRecord));
  GenLinkMode:=DisableGen;
end;
constructor GDBOpenArrayOfTObjLinkRecord.initnul;
begin
  inherited initnul;
  size:=sizeof(TObjLinkRecord);
  GenLinkMode:=DisableGen;
end;
procedure GDBOpenArrayOfTObjLinkRecord.minimize;
var temp:GDBOpenArrayOfTObjLinkRecord;
    pd:PTObjLinkRecord;
        ir:itrec;
begin
  temp.init({$IFDEF DEBUGBUILD}'A67C6A01-B166-4BBE-B29F-388D2FC94D5B}',{$ENDIF}count);
  pd:=beginiterate(ir);
  if pd<>nil then
  repeat
        if pd^.LinkCount>0 then
                               temp.add(pd);
        pd:=iterate(ir);
  until pd=nil;
  gdbfreemem(parray);
  self:=temp;
  temp.PArray:=nil;
  temp.done;
end;

function GDBOpenArrayOfTObjLinkRecord.SetGenMode;
begin
     result:=GenLinkMode;
     GenLinkMode:=mode;
end;
function GDBOpenArrayOfTObjLinkRecord.FindByOldAddres;
var
   p:PTObjLinkRecord;
       ir:itrec;
begin
     result:=nil;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        if p^.OldAddr=ptruint(pobj) then
                                            begin
                                                 result:=p;
                                            end;
        p:=iterate(ir);
  until p=nil;
end;
function GDBOpenArrayOfTObjLinkRecord.FindByTempAddres;
var
   p:PTObjLinkRecord;
    ir:itrec;
begin
     result:=nil;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        if p^.TempAddr=addr then
                                begin
                                     result:=p;
                                end;
        p:=iterate(ir);
  until p=nil;
end;
procedure GDBOpenArrayOfTObjLinkRecord.CreateLinkRecord;
var linkdata:TObjLinkRecord;
    p:PTObjLinkRecord;
begin
     if GenLinkMode=EnableGen then
     begin
          linkdata.Mode:=mode;
          case Mode of
                      OBT,OFT:
                              begin
                                   fillchar(linkdata,sizeof(linkdata),0);
                                   linkdata.OldAddr:=GDBPlatformint(PObj);
                                   linkdata.TempAddr:=filepos;
                                   add(@linkdata);
                              end;
                      UBR:begin
                               p:=FindByOldAddres(pobj);
                               if p<>nil then
                                             begin
                                                  inc(p^.LinkCount)
                                             end
                                         else
                                             begin
                                                  fillchar(linkdata,sizeof(linkdata),0);
                                                  linkdata.OldAddr:=GDBPlatformint(PObj);
                                                  linkdata.TempAddr:={filepos}0;
                                                  add(@linkdata);
                                             end;
                          end;
          end;
     end;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBOpenArrayOfTObjLinkRecord.initialization');{$ENDIF}
end.

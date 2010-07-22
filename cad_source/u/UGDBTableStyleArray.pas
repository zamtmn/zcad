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

unit UGDBTableStyleArray;
{$INCLUDE def.inc}
interface
uses gdbasetypes{,UGDBOpenArray,UGDBOpenArrayOfObjects,oglwindowdef},sysutils,gdbase, geometry,
     gl,
     {varmandef,gdbobjectsconstdef,}UGDBNamedObjectsArray,UGDBOpenArrayOfData;
type
{EXPORT+}
TCellJustify=(jcl(*'ВерхЛево'*),
              jcm(*'ВерхЦентр'*),
              jcr(*'ВерхПраво'*));
TGDBTableCellStyle=record
                          Width,TextWidth:GDBDouble;
                          CF:TCellJustify;
                    end;
GDBCellFormatArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=TGDBTableCellStyle*)
                   end;
PTGDBTableStyle=^TGDBTableStyle;
TGDBTableStyle=object(GDBNamedObject)
                     rowheight:gdbinteger;
                     textheight:gdbdouble;
                     tblformat:GDBCellFormatArray;
                     HeadBlockName:GDBString;
                     constructor Init(n:GDBString);
                     destructor Done;virtual;
               end;
GDBTableStyleArray=object(GDBNamedObjectsArray)(*OpenArrayOfData=TGDBTableStyle*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    constructor initnul;
                    function AddStyle(name:GDBString):PTGDBTableStyle;
              end;
{EXPORT-}
implementation
uses
    log;
constructor GDBTableStyleArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(TGDBTableStyle));
  //addlayer(LNSysLayerName,CGDBWhile,lwgdbdefault,true,false,true);
end;
constructor GDBTableStyleArray.initnul;
begin
  inherited initnul;
  size:=sizeof(TGDBTableStyle);
end;
constructor TGDBTableStyle.Init;
begin
    inherited;
    tblformat.init({$IFDEF DEBUGBUILD}'{3FD7CFC7-3885-4C97-9BEE-BA27E83862BB}',{$ENDIF}10,sizeof(TGDBTableCellStyle));
end;
destructor TGDBTableStyle.Done;
begin
    inherited;
    tblformat.Done;
    HeadBlockName:='';
end;
function GDBTableStyleArray.AddStyle;
var
  p:PTGDBTableStyle;
begin
     case AddItem(name,pointer(p)) of
             IsFounded:
                       begin
                       end;
             IsCreated:
                       begin
                            p^.init(Name);
                       end;
             IsError:
                       begin
                       end;
     end;
     result:=p;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBTableAtyleArray.initialization');{$ENDIF}
end.

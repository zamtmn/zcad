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

unit uzestylestables;
{$INCLUDE def.inc}
interface
uses uzbtypesbase,sysutils,uzbtypes,uzegeometry,
     UGDBNamedObjectsArray,UGDBOpenArrayOfData;
type
{TCellJustify=(jcl(*'ВерхЛево'*),
              jcm(*'ВерхЦентр'*),
              jcr(*'ВерхПраво'*));}
{EXPORT+}
TTableCellJustify=(jcl(*'TopLeft'*),
              jcc(*'TopCenter'*),
              jcr(*'TopRight'*));
PTGDBTableCellStyle=^TGDBTableCellStyle;
TGDBTableCellStyle=packed record
                          Width,TextWidth:GDBDouble;
                          CF:TTableCellJustify;
                    end;
GDBCellFormatArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=TGDBTableCellStyle*)
                   end;
PTGDBTableStyle=^TGDBTableStyle;
TGDBTableStyle={$IFNDEF DELPHI}packed{$ENDIF} object(GDBNamedObject)
                     rowheight:gdbinteger;
                     textheight:gdbdouble;
                     tblformat:GDBCellFormatArray;
                     HeadBlockName:GDBString;
                     constructor Init(n:GDBString);
                     destructor Done;virtual;
               end;
PGDBTableStyleArray=^GDBTableStyleArray;
GDBTableStyleArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBNamedObjectsArray)(*OpenArrayOfData=TGDBTableStyle*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    constructor initnul;
                    function AddStyle(name:GDBString):PTGDBTableStyle;
              end;
{EXPORT-}
var
  PTempTableStyle:PTGDBTableStyle;
implementation
//uses
//    log;
constructor GDBTableStyleArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(TGDBTableStyle));
  //addlayer(LNSysLayerName,CGDBWhile,lwgdbdefault,true,false,true);
end;
constructor GDBTableStyleArray.initnul;
begin
  inherited initnul;
  objsizeof:=sizeof(TGDBTableStyle);
  //size:=sizeof(TGDBTableStyle);
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
end.

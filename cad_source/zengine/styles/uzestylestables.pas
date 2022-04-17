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
{$INCLUDE zengineconfig.inc}
interface
uses sysutils,uzbtypes,uzegeometry,
     UGDBNamedObjectsArray,gzctnrVector;
type
{EXPORT+}
TTableCellJustify=(jcl(*'TopLeft'*),
              jcc(*'TopCenter'*),
              jcr(*'TopRight'*));
PTGDBTableCellStyle=^TGDBTableCellStyle;
{REGISTERRECORDTYPE TGDBTableCellStyle}
TGDBTableCellStyle=record
                          Width,TextWidth:Double;
                          CF:TTableCellJustify;
                    end;
{REGISTEROBJECTTYPE GDBCellFormatArray}
GDBCellFormatArray= object(GZVector{-}<TGDBTableCellStyle>{//})(*OpenArrayOfData=TGDBTableCellStyle*)
                   end;
PTGDBTableStyle=^TGDBTableStyle;
{REGISTEROBJECTTYPE TGDBTableStyle}
TGDBTableStyle= object(GDBNamedObject)
                     rowheight:Integer;
                     textheight:Double;
                     tblformat:GDBCellFormatArray;
                     HeadBlockName:String;
                     constructor Init(n:String);
                     destructor Done;virtual;
               end;
PGDBTableStyleArray=^GDBTableStyleArray;
{REGISTEROBJECTTYPE GDBTableStyleArray}
GDBTableStyleArray= object(GDBNamedObjectsArray{-}<PTGDBTableStyle,TGDBTableStyle>{//})(*OpenArrayOfData=TGDBTableStyle*)
                    constructor init(m:Integer);
                    constructor initnul;
                    function AddStyle(name:String):PTGDBTableStyle;
              end;
{EXPORT-}
var
  PTempTableStyle:PTGDBTableStyle;
implementation
//uses
//    log;
constructor GDBTableStyleArray.init;
begin
  inherited init(m);
  //addlayer(LNSysLayerName,CGDBWhile,lwgdbdefault,true,false,true);
end;
constructor GDBTableStyleArray.initnul;
begin
  inherited initnul;
  //objsizeof:=sizeof(TGDBTableStyle);
  //size:=sizeof(TGDBTableStyle);
end;
constructor TGDBTableStyle.Init;
begin
    inherited;
    tblformat.init(10);
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

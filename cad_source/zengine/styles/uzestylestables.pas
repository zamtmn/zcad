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

unit uzestylestables;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses sysutils,uzegeometry,
     UGDBNamedObjectsArray,gzctnrVector,uzeNamedObject;
type

  TTableCellJustify=(jcl(*'TopLeft'*),
    jcc(*'TopCenter'*),
    jcr(*'TopRight'*));
  PTGDBTableCellStyle=^TGDBTableCellStyle;

  TGDBTableCellStyle=record
    Width,TextWidth:double;
    CF:TTableCellJustify;
  end;

  GDBCellFormatArray=GZVector<TGDBTableCellStyle>;

  TGDBTableStyle=object(GDBNamedObject)
    rowheight:integer;
    textheight:double;
    tblformat:GDBCellFormatArray;
    HeadBlockName:string;
    constructor Init(const n:string);
    destructor Done;virtual;
  end;
  PTGDBTableStyle=^TGDBTableStyle;




PGDBTableStyleArray=^GDBTableStyleArray;
GDBTableStyleArray= object(GDBNamedObjectsArray<PTGDBTableStyle,TGDBTableStyle>)
                    constructor init(m:Integer);
                    constructor initnul;
                    function AddStyle(const name:String):PTGDBTableStyle;
              end;
var
  PTempTableStyle:PTGDBTableStyle;
implementation

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

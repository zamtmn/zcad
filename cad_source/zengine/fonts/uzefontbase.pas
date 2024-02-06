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

unit uzefontbase;
{$INCLUDE zengineconfig.inc}
interface
uses uzgprimitives,uzglvectorobject,uzbstrproc,uzctnrVectorBytes,
     gzctnrVectorTypes,gzctnrVector,sysutils,uzbtypes,uzegeometrytypes,uzegeometry;
type
{EXPORT+}
TSymbolInfoArray=packed array [0..255] of GDBsymdolinfo;
TGDBUNISymbolInfoVector=GZVector{-}<GDBUNISymbolInfo>{//};
PBASEFont=^BASEFont;
{REGISTEROBJECTTYPE BASEFont}
BASEFont= object(GDBaseObject)
              unicode:Boolean;
              symbolinfo:TSymbolInfoArray;
              unisymbolinfo:{GDBOpenArrayOfData}TGDBUNISymbolInfoVector;
              //----//SHXdata:TZctnrVectorBytes;
              FontData:ZGLVectorObject;
              constructor init;
              destructor done;virtual;
              //----//function GetSymbolDataAddr(offset:integer):pointer;virtual;
              //function GetTriangleDataAddr(offset:integer):PGDBFontVertex2D;virtual;

              function GetOrCreateSymbolInfo(symbol:Integer):PGDBsymdolinfo;virtual;
              function GetOrReplaceSymbolInfo(symbol:Integer{//-ttf-//; var TrianglesDataInfo:TTrianglesDataInfo}):PGDBsymdolinfo;virtual;
              function findunisymbolinfo(symbol:Integer):PGDBsymdolinfo;
              function findunisymbolinfos(symbolname:String):PGDBsymdolinfo;
              function IsCanSystemDraw:Boolean;virtual;
              procedure SetupSymbolLineParams(const matr:DMatrix4D; var SymsParam:TSymbolSParam);virtual;
        end;
{EXPORT-}
implementation
//uses log;
procedure BASEFont.SetupSymbolLineParams(const matr:DMatrix4D; var SymsParam:TSymbolSParam);
begin
end;
function BASEFont.IsCanSystemDraw:Boolean;
begin
     result:=false;
end;

constructor BASEFont.init;
var
   i:integer;
begin
     inherited;
     for i:=0 to 255 do
     begin
      symbolinfo[i].LLPrimitiveStartIndex:=-1;
      symbolinfo[i].LLPrimitiveCount:=0;
      symbolinfo[i].LatestCreate:=false;
     end;
     unicode:=false;
     unisymbolinfo.init(1000);
     //----//SHXdata.init(1024);
     FontData.init();
end;
destructor BASEFont.done;
var i:integer;
    pobj:PGDBUNISymbolInfo;
    ir:itrec;
begin
     inherited;
     for i:=0 to 255 do
     begin
      symbolinfo[i].Name:='';
     end;

     pobj:=unisymbolinfo.beginiterate(ir);
     if pobj<>nil then
     repeat
           pobj^.symbolinfo.Name:='';
           pobj:=unisymbolinfo.iterate(ir);
     until pobj=nil;
     unisymbolinfo.{FreeAnd}Done;
     //----//SHXdata.done;
     FontData.done;
end;
function BASEFont.GetOrReplaceSymbolInfo(symbol:Integer{//-ttf-//; var TrianglesDataInfo:TTrianglesDataInfo}):PGDBsymdolinfo;
//var
   //usi:GDBUNISymbolInfo;
begin
     //-ttf-//TrianglesDataInfo.TrianglesAddr:=0;
     //-ttf-//TrianglesDataInfo.TrianglesSize:=0;
//     if symbol=49 then
//                        symbol:=symbol;
     if symbol<256 then
                       begin
                       result:=@symbolinfo[symbol];
                       if result^.LLPrimitiveStartIndex=-1 then
                                        result:=@symbolinfo[ord('?')];
                       end
                   else
                       //result:=@self.symbolinfo[ord('?')]
                       begin
                            result:=findunisymbolinfo(symbol);
                            //result:=@symbolinfo[ord('?')];
                            //usi.symbolinfo:=result^;;
                            if result=nil then
                            begin
                                 result:=@symbolinfo[ord('?')];
                                 exit;
                            end;
                            if result^.LLPrimitiveStartIndex=-1 then
                                             result:=@symbolinfo[ord('?')];

                       end;
end;
{function BASEFont.GetTriangleDataAddr(offset:integer):PGDBFontVertex2D;
begin
     result:=nil;
end;}
//----//function BASEFont.GetSymbolDataAddr(offset:integer):pointer;
//----//begin
//----//     result:=SHXdata.getelement(offset);
//----//end;
function BASEFont.GetOrCreateSymbolInfo(symbol:Integer):PGDBsymdolinfo;
var
   usi:GDBUNISymbolInfo;
begin
     if symbol<256 then
                       result:=@symbolinfo[symbol]
                   else
                       //result:=@self.symbolinfo[0]
                       begin
                            result:=findunisymbolinfo(symbol);
                            if result=nil then
                            begin
                                 usi.symbol:=symbol;
                                 usi.symbolinfo.LLPrimitiveStartIndex:=-1;
                                 usi.symbolinfo.NextSymX:=0;
                                 usi.symbolinfo.SymMaxY:=0;
                                 usi.symbolinfo.h:=0;
                                 usi.symbolinfo.LLPrimitiveCount:=0;
                                 usi.symbolinfo.w:=0;
                                 usi.symbolinfo.SymMinY:=0;
                                 usi.symbolinfo.LatestCreate:=false;
                                 killstring(usi.symbolinfo.Name);
                                 unisymbolinfo.PushBackData(usi);

                                 result:=@(PGDBUNISymbolInfo(unisymbolinfo.getDataMutable(unisymbolinfo.Count-1))^.symbolinfo);
                            end;
                       end;
end;
function BASEFont.findunisymbolinfo(symbol:Integer):PGDBsymdolinfo;
var
   pobj:PGDBUNISymbolInfo;
   ir:itrec;
   //debug:Integer;
begin
     pobj:=unisymbolinfo.beginiterate(ir);
     if pobj<>nil then
     repeat
           //debug:=pobj^.symbol;
           //debug:=pobj^.symbolinfo.addr;
           if pobj^.symbol=symbol then
                                      begin
                                           result:=@pobj^.symbolinfo;
                                           exit;
                                      end;
           pobj:=unisymbolinfo.iterate(ir);
     until pobj=nil;
     result:=nil;
end;
function BASEFont.findunisymbolinfos(symbolname:String):PGDBsymdolinfo;
var
   pobj:PGDBUNISymbolInfo;
   ir:itrec;
   i:integer;
   //debug:Integer;
begin
     symbolname:=uppercase(symbolname);

     for i:=0 to 255 do
     begin
          if uppercase(symbolinfo[i].Name)=symbolname then
          begin
               result:=@symbolinfo[i];
               exit;
          end;
     end;
     pobj:=unisymbolinfo.beginiterate(ir);
     if pobj<>nil then
     repeat
           if uppercase(pobj^.symbolinfo.Name)=symbolname then
                                      begin
                                           result:=@pobj^.symbolinfo;
                                           exit;
                                      end;
           pobj:=unisymbolinfo.iterate(ir);
     until pobj=nil;
     result:=nil;
end;
end.

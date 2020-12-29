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

unit uzefontbase;
{$INCLUDE def.inc}
interface
uses uzgprimitives,uzglvectorobject,uzbmemman,uzbstrproc,UGDBOpenArrayOfByte,
     gzctnrvectortypes,uzbtypesbase,gzctnrvectordata,sysutils,uzbtypes,uzbgeomtypes,uzegeometry;
type
{EXPORT+}
TGDBUNISymbolInfoVector=GZVectorData{-}<GDBUNISymbolInfo>{//};
PBASEFont=^BASEFont;
{REGISTEROBJECTTYPE BASEFont}
BASEFont= object(GDBaseObject)
              unicode:GDBBoolean;
              symbolinfo:TSymbolInfoArray;
              unisymbolinfo:{GDBOpenArrayOfData}TGDBUNISymbolInfoVector;
              //----//SHXdata:GDBOpenArrayOfByte;
              FontData:ZGLVectorObject;
              constructor init;
              destructor done;virtual;
              //----//function GetSymbolDataAddr(offset:integer):pointer;virtual;
              //function GetTriangleDataAddr(offset:integer):PGDBFontVertex2D;virtual;

              function GetOrCreateSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;virtual;
              function GetOrReplaceSymbolInfo(symbol:GDBInteger{//-ttf-//; var TrianglesDataInfo:TTrianglesDataInfo}):PGDBsymdolinfo;virtual;
              function findunisymbolinfo(symbol:GDBInteger):PGDBsymdolinfo;
              function findunisymbolinfos(symbolname:GDBString):PGDBsymdolinfo;
              function IsCanSystemDraw:GDBBoolean;virtual;
              procedure SetupSymbolLineParams(const matr:DMatrix4D; var SymsParam:TSymbolSParam);virtual;
        end;
{EXPORT-}
implementation
//uses log;
procedure BASEFont.SetupSymbolLineParams(const matr:DMatrix4D; var SymsParam:TSymbolSParam);
begin
end;
function BASEFont.IsCanSystemDraw:GDBBoolean;
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
     unisymbolinfo.init({$IFDEF DEBUGBUILD}'{700B6312-B792-4FFE-B514-2F2CD4B47CC2}',{$ENDIF}1000{,sizeof(GDBUNISymbolInfo)});
     //----//SHXdata.init({$IFDEF DEBUGBUILD}'{700B6312-B792-4FFE-B514-2F2CD4B47CC2}',{$ENDIF}1024);
     FontData.init({$IFDEF DEBUGBUILD}'BASEFont.init'{$ENDIF});
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
function BASEFont.GetOrReplaceSymbolInfo(symbol:GDBInteger{//-ttf-//; var TrianglesDataInfo:TTrianglesDataInfo}):PGDBsymdolinfo;
//var
   //usi:GDBUNISymbolInfo;
begin
     //-ttf-//TrianglesDataInfo.TrianglesAddr:=0;
     //-ttf-//TrianglesDataInfo.TrianglesSize:=0;
     if symbol=49 then
                        symbol:=symbol;
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
function BASEFont.GetOrCreateSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
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
function BASEFont.findunisymbolinfo(symbol:GDBInteger):PGDBsymdolinfo;
var
   pobj:PGDBUNISymbolInfo;
   ir:itrec;
   //debug:GDBInteger;
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
function BASEFont.findunisymbolinfos(symbolname:GDBString):PGDBsymdolinfo;
var
   pobj:PGDBUNISymbolInfo;
   ir:itrec;
   i:integer;
   //debug:GDBInteger;
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

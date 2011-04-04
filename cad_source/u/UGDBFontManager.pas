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

unit UGDBFontManager;
{$INCLUDE def.inc}
interface
uses UGDBSHXFont,gdbasetypes,SysInfo,memman,UGDBOpenArrayOfData, {oglwindowdef,}sysutils,gdbase, geometry,
     gl,
     UGDBNamedObjectsArray;
type
{Export+}
  PGDBFontRecord=^GDBFontRecord;
  GDBFontRecord = record
    Name: GDBString;
    Pfont: GDBPointer;
  end;
PGDBFontManager=^GDBFontManager;
GDBFontManager=object({GDBOpenArrayOfData}GDBNamedObjectsArray)(*OpenArrayOfData=GDBfont*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);

                    function addFonf(FontPathName:GDBString):PGDBfont;
                    //function FindFonf(FontName:GDBString):GDBPointer;
                    {procedure freeelement(p:GDBPointer);virtual;}
              end;
{Export-}
implementation
uses io,log;
constructor GDBFontManager.init;
begin
  //Size := sizeof(GDBFontManager);
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof({GDBFontRecord}GDBfont));
  //addlayer('0',cgdbwhile,lwgdbdefault);
end;
{procedure GDBFontManager.freeelement;
begin
  PGDBFontRecord(p).Name:='';
  PGDBfont(PGDBFontRecord(p).Pfont)^.fontfile:='';
  PGDBfont(PGDBFontRecord(p).Pfont)^.name:='';
  GDBFreeMem(PGDBFontRecord(p).Pfont);
end;}
(*function GDBFontManager.addFonf(FontName:GDBString):GDBInteger;
var
  fr:GDBFontRecord;
  ft:string;
begin
  if FindFonf(Fontname)=nil then
  begin
  fr.Name:=FontName;
  ft:=uppercase(ExtractFileExt(fontname));
  //if ft='.SHP' then fr.Pfont:=createnewfontfromshp(sysparam.programpath+'fonts/'+FontName);
  if ft='.SHX' then fr.Pfont:=createnewfontfromshx(sysparam.programpath+'fonts/'+FontName);
  add(@fr);
  GDBPointer(fr.Name):=nil;
  end;
end;*)
function GDBFontManager.addFonf(FontPathName:GDBString):PGDBfont;
var
  p:PGDBfont;
  FontName:GDBString;
      //ir:itrec;
begin
     FontName:=ExtractFileName(FontPathName);
          if FontName='_mipgost.shx' then
                                    fontname:=FontName;
     case AddItem(FontName,pointer(p)) of
             IsFounded:
                       begin
                       end;
             IsCreated:
                       begin
                            programlog.logoutstr('Loading font '+FontPathName,lp_IncPos);
                            if (FontPathName<>'')and(createnewfontfromshx(FontPathName,p)) then
                            begin
                                 programlog.logoutstr('OK',lp_DecPos)
                            end
                            else
                            begin
                                 programlog.logoutstr('unknown format',lp_DecPos);
                                 dec(self.Count);
                                 //p^.Name:='ERROR ON LOAD';
                                 p:=nil;
                            end;
                            //p^.init(FontPathName,Color,LW,oo,ll,pp);
                       end;
             IsError:
                       begin
                       end;
     end;
     result:=p;
end;
{function GDBFontManager.FindFonf;
var
  pfr:pGDBFontRecord;
  i:GDBInteger;
begin
  result:=nil;
  if count=0 then exit;
  pfr:=parray;
  for i:=0 to count-1 do
  begin
       if pfr^.Name=fontname then begin
                                       result:=pfr^.Pfont;
                                       exit;
                                  end;
       inc(pfr);
  end;
end;}

{function GDBLayerArray.CalcCopactMemSize2;
var i:GDBInteger;
    tlp:PGDBLayerProp;
begin
     result:=0;
     objcount:=count;
     if count=0 then exit;
     result:=result;
     tlp:=parray;
     for i:=0 to count-1 do
     begin
          result:=result+sizeof(GDBByte)+sizeof(GDBSmallint)+sizeof(GDBWord)+length(tlp^.name);
          inc(tlp);
     end;
end;
function GDBLayerArray.SaveToCompactMemSize2;
var i:GDBInteger;
    tlp:PGDBLayerProp;
begin
     result:=0;
     if count=0 then exit;
     tlp:=parray;
     for i:=0 to count-1 do
     begin
          PGDBByte(pmem)^:=tlp^.color;
          inc(PGDBByte(pmem));
          PGDBSmallint(pmem)^:=tlp^.lineweight;
          inc(PGDBSmallint(pmem));
          PGDBWord(pmem)^:=length(tlp^.name);
          inc(PGDBWord(pmem));
          Move(GDBPointer(tlp.name)^, pmem^,length(tlp.name));
          inc(PGDBByte(pmem),length(tlp.name));
          inc(tlp);
     end;
end;
function GDBLayerArray.LoadCompactMemSize2;
begin
     {inherited LoadCompactMemSize(pmem);
     Coord:=PGDBLineProp(pmem)^;
     inc(PGDBLineProp(pmem));
     PProjPoint:=nil;
     format;}
//end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBFontManager.initialization');{$ENDIF}
end.

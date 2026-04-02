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
unit uzeffDxfOut;
{$INCLUDE zengineconfig.inc}
{$MODE delphi}{$H+}
interface
uses
  uzbpaths,uzbstrproc,uzgldrawcontext,usimplegenerics,uzestylesdim,uzeentityfactory,
  {$IFNDEF DELPHI}LazUTF8,{$ENDIF}uzbUnits,
  UGDBNamedObjectsArray,uzestyleslinetypes,uzedrawingsimple,uzelongprocesssupport,
  gzctnrVectorTypes,uzglviewareadata,uzeffdxfsupport,uzestrconsts,uzestylestexts,
  uzegeometry,uzeentsubordinated,uzeentgenericsubentry,uzeTypes,
  uzegeometrytypes,sysutils,uzeconsts,UGDBObjBlockdefArray,
  uzctnrVectorBytesStream,UGDBVisibleOpenArray,uzeentity,uzeblockdef,uzestyleslayers,
  uzeffmanager,uzbLogIntf,uzeLogIntf,
  uzMVSMemoryMappedFile,uzMVReader,uzbBaseUtils;

function savedxf2000(const SavedFileName:String; const TemplateFileName:String;var drawing:TSimpleDrawing;codepage:integer):boolean;

implementation

procedure RegisterAcadAppInDXF(const appname:String; outstream: PTZctnrVectorBytes;var handle: TDWGHandle);
begin
  outstream^.TXTAddStringEOL(dxfGroupCode(0));
  outstream^.TXTAddStringEOL('APPID');

  outstream^.TXTAddStringEOL(dxfGroupCode(5));
  outstream^.TXTAddStringEOL(inttohex(handle, 0));
  inc(handle);

  outstream^.TXTAddStringEOL(dxfGroupCode(100));
  outstream^.TXTAddStringEOL('AcDbSymbolTableRecord');
  outstream^.TXTAddStringEOL(dxfGroupCode(100));
  outstream^.TXTAddStringEOL('AcDbRegAppTableRecord');
  outstream^.TXTAddStringEOL(dxfGroupCode(2));
  outstream^.TXTAddStringEOL(appname);
  outstream^.TXTAddStringEOL(dxfGroupCode(70));
  outstream^.TXTAddStringEOL('0');
  {
  0
  APPID
  5
  12
  >>330
  >>9
  100
  AcDbSymbolTableRecord
  100
  AcDbRegAppTableRecord
  2
  ACAD
  70
  0
  }
end;


procedure saveentitiesdxf2000(pva: PGDBObjEntityOpenArray; var outStream:TZctnrVectorBytes;var drawing:TSimpleDrawing;var IODXFContext:TIODXFSaveContext);
var
  pv:pgdbobjEntity;
  ir:itrec;
  lph:TLPSHandle;
begin
  lph:=lps.StartLongProcess('saveentitiesdxf2000',@outStream,pva^.Count);
  pv:=pva^.beginiterate(ir);
  if pv<>nil then
    repeat
      lps.ProgressLongProcess(lph,ir.itc);
      IODXFContext.LocalEntityFlags:=DefaultLocalEntityFlags;
      pv^.DXFOut(outStream,drawing,IODXFContext);
      pv:=pva^.iterate(ir);
    until pv=nil;
  lps.EndLongProcess(lph);
end;

procedure MakeVariablesDict(VarsDict:TString2StringDictionary; var drawing:TSimpleDrawing);
var
   pcurrtextstyle:PGDBTextStyle;
   pcurrentdimstyle:PGDBDimStyle;
begin
    VarsDict.Add('$CLAYER',drawing.GetCurrentLayer^.Name);
    VarsDict.Add('$CELTYPE',drawing.GetCurrentLType^.Name);
    VarsDict.Add('$DWGCODEPAGE',ZCCP2Str(drawing.DXFCodePage));

    pcurrtextstyle:=drawing.GetCurrentTextStyle;
    if pcurrtextstyle<>nil then
                               VarsDict.Add('$TEXTSTYLE',drawing.GetCurrentTextStyle^.Name)
                           else
                               VarsDict.Add('$TEXTSTYLE',TSNStandardStyleName);
    pcurrentdimstyle:=drawing.GetCurrentDimStyle;
    if pcurrentdimstyle<>nil then
                                 VarsDict.Add('$DIMSTYLE',pcurrentdimstyle^.Name)
                             else
                                 VarsDict.Add('$DIMSTYLE','Standatd');

    //if assigned(sysvar.DWG.DWG_CLinew) then
                                           VarsDict.Add('$CELWEIGHT',inttostr({sysvar.DWG.DWG_CLinew^}drawing.CurrentLineW));
                                       //else
                                       //    VarsDict.insert('$CELWEIGHT',inttostr(-1));

    //if assigned(sysvar.DWG.DWG_LTScale) then
                                            VarsDict.Add('$LTSCALE',floattostr({sysvar.DWG.DWG_LTScale^}drawing.LTScale));
                                        //else
                                        //    VarsDict.insert('$LTSCALE',floattostr(1.0));

    //if assigned(sysvar.DWG.DWG_CLTScale) then
                                             VarsDict.Add('$CELTSCALE',floattostr({sysvar.DWG.DWG_CLTScale^}drawing.CLTScale));
                                         //else
                                         //    VarsDict.insert('$CELTSCALE',floattostr(1.0));

    //if assigned(sysvar.DWG.DWG_CColor) then
                                           VarsDict.Add('$CECOLOR',inttostr({sysvar.DWG.DWG_CColor^}drawing.CColor));
                                       //else
                                           //VarsDict.insert('$CECOLOR',inttostr(256));


    //if assigned(sysvar.DWG.DWG_DrawMode) then
                                             begin
                                                  if {sysvar.DWG.DWG_DrawMode^}drawing.LWDisplay then
                                                                                  VarsDict.Add('$LWDISPLAY',inttostr(1))
                                                                              else
                                                                                  VarsDict.Add('$LWDISPLAY',inttostr(0));
                                             end;
                                         //else
                                         //    VarsDict.insert('$LWDISPLAY',inttostr(0));
   VarsDict.Add('$HANDSEED','FUCK OFF!');

   //if assigned(sysvar.DWG.DWG_LUnits) then
                                        VarsDict.Add('$LUNITS',inttostr(ord({sysvar.DWG.DWG_LUnits^}drawing.LUnits)+1));
   //if assigned(sysvar.DWG.DWG_LUPrec) then
                                        VarsDict.Add('$LUPREC',inttostr(ord({sysvar.DWG.DWG_LUPrec^}drawing.LUPrec)));
   //if assigned(sysvar.DWG.DWG_AUnits) then
                                        VarsDict.Add('$AUNITS',inttostr(ord({sysvar.DWG.DWG_AUnits^}drawing.AUnits)));
   //if assigned(sysvar.DWG.DWG_AUPrec) then
                                        VarsDict.Add('$AUPREC',inttostr(ord({sysvar.DWG.DWG_AUPrec^}drawing.AUPrec)));
   //if assigned(sysvar.DWG.DWG_AngDir) then
                                        VarsDict.Add('$ANGDIR',inttostr(ord({sysvar.DWG.DWG_AngDir^}drawing.AngDir)));
   //if assigned(sysvar.DWG.DWG_AngBase) then
                                        VarsDict.Add('$ANGBASE',floattostr({sysvar.DWG.DWG_AngBase^}drawing.AngBase));
   //if assigned(sysvar.DWG.DWG_UnitMode) then
                                        VarsDict.Add('$UNITMODE',inttostr(ord({sysvar.DWG.DWG_UnitMode^}drawing.UnitMode)));
   //if assigned(sysvar.DWG.DWG_InsUnits) then
                                           VarsDict.Add('$INSUNITS',inttostr(ord({sysvar.DWG.DWG_InsUnits^}drawing.InsUnits)));
   //if assigned(sysvar.DWG.DWG_TextSize) then
                                           VarsDict.Add('$TEXTSIZE',floattostr({sysvar.DWG.DWG_TextSize^}drawing.TextSize));
end;


function savedxf2000(const SavedFileName:String; const TemplateFileName:String;var drawing:TSimpleDrawing;codepage:integer):boolean;
var
  sysfilename:RawByteString;
  templatefile: TZctnrVectorBytes;
  outstream:TZctnrVectorBytes;
  groups,values,ts: String;
  groupi,valuei,intable,attr: Integer;
  temphandle,temphandle2,lasthandle,vporttablehandle,plottablefansdle,dimtablehandle: TDWGHandle;
  i: integer;
  OldHandele2NewHandle:TMapHandleToHandle;

  inlayertable, inblocksec, inblocktable, inlttypetable, indimstyletable, inappidtable: Boolean;
  handlepos:integer;
  ignoredsource:boolean;
  instyletable:boolean;
  invporttable:boolean;

  pltp:PGDBLtypeProp;
  plp:PGDBLayerProp;
  pdsp:PGDBDimStyle;
  ir,ir2,ir3,ir4,ir5:itrec;
  TDI:PTDashInfo;
  PStroke:PDouble;
  PSP:PShapeProp;
  PTP:PTextProp;
  p:pointer;
  IODXFContext:TIODXFSaveContext;
  laststrokewrited:boolean;
  pcurrtextstyle:PGDBTextStyle;
  variablenotprocessed:boolean;
  processedvarscount:integer;
  lph:TLPSHandle;
begin
  intable:=0;
  IODXFContext.InitRec;
  IODXFContext.Header.Version:=AC1015;
  IODXFContext.Header.iVersion:=1015;

  IODXFContext.Header.DWGCodePage:=SysCP2ACCP(codepage);
  IODXFContext.Header.iDWGCodePage:=codepage;

  DefaultFormatSettings.DecimalSeparator := '.';
  outstream.init(10*1024*1024);
  begin
    lph:=lps.StartLongProcess('Save DXF file',@outstream,drawing.pObjRoot^.ObjArray.Count);
  OldHandele2NewHandle:=TMapHandleToHandle.Create;
  templatefile.InitFromFile(TemplateFileName);
  inlayertable := false;
  inblocksec := false;
  inblocktable := false;
  instyletable := false;
  ignoredsource:=false;
  invporttable:=false;
  inlttypetable:=false;
  indimstyletable:=false;
  inappidtable:=false;
  MakeVariablesDict(IODXFContext.VarsDict,drawing);
  processedvarscount:=IODXFContext.VarsDict.count;
  while templatefile.notEOF do
  begin
    groups := templatefile.readString;
    values := templatefile.readString;
    //ucvalues:=uppercase(values);
    groupi := strtoint(groups);
    variablenotprocessed:=true;
    if (groupi = 9)and(processedvarscount>0) then
    begin
      variablenotprocessed:=false;
      if IODXFContext.VarsDict.mygetvalue(values,ts) then
        begin
             outstream.TXTAddStringEOL(groups);
             outstream.TXTAddStringEOL(values);
             groups := templatefile.readString;
             {values := }templatefile.readString;
             outstream.TXTAddStringEOL(groups);
             if values='$HANDSEED' then
                                       handlepos:=outstream.Count;
             outstream.TXTAddStringEOL(dxfEnCodeString(ts,IODXFContext.Header));
             dec(processedvarscount);
        end
      else variablenotprocessed:=true;
    end
    {else};if variablenotprocessed then
      if (groupi = 5)
      or (groupi = 320)
      or (groupi = 330)
      or (groupi = 340)
      or (groupi = 350)
      or (groupi = 1005)
      or (groupi = 390)
      or (groupi = 360)
      or (groupi = 105) then
      begin
        valuei := strtoint('$' + values);
                          {if valuei<>0 then
                                       begin}
        if valuei=0 then begin
          if not ignoredsource then begin
            outstream.TXTAddStringEOL(groups);
            outstream.TXTAddStringEOL('0');
          end;
        end else begin
        if inlayertable and (groupi=390) then
                                             plottablefansdle:={handle-1}intable;  {поймать плоттабле}
        intable :=OldHandele2NewHandle.MyGetValue(valuei);
        //intable :=GetNewHandle(valuei);
        //intable := {}getnevhandle(phandlea, valuei){}{valuei};
        if {}intable >0{}{true} then
        begin
          if not ignoredsource then
          begin
          outstream.TXTAddStringEOL(groups);
          outstream.TXTAddStringEOL(inttohex(intable, 0));
          end;
          lasthandle:=intable;
        end
        else
        begin
          OldHandele2NewHandle.Add(valuei, IODXFContext.handle);
          //pushhandle(phandlea, valuei, handle);
          if not ignoredsource then
          begin
          outstream.TXTAddStringEOL(groups);
          outstream.TXTAddStringEOL(inttohex(IODXFContext.handle, 0));
          end;
          lasthandle:=IODXFContext.handle;
          inc(IODXFContext.handle);
        end;
        if inlayertable and (groupi=390) then
                                             plottablefansdle:=lasthandle;  {поймать плоттабле}
        if indimstyletable and (groupi=5) then
                                             dimtablehandle:=lasthandle;  {поймать dimtable}
        (*{if instyletable and (groupi=5) then
                                             standartstylehandle:=lasthandle;{intable;}  {поймать standart}*)
        end
      end
      else
        if (groupi = 2) and (values = 'ENTITIES') then
        begin
          outstream.TXTAddStringEOL(groups);
          //WriteString_EOL(outstream, groups);
          outstream.TXTAddStringEOL(values);
          //WriteString_EOL(outstream, values);
          //historyoutstr('Entities start here_______________________________________________________');
          saveentitiesdxf2000(@{p}drawing.pObjRoot^.ObjArray, outstream,drawing,IODXFContext);
        end
        else
          if (groupi = 2) and (values = 'BLOCKS') then
          begin
            outstream.TXTAddStringEOL(groups);
            outstream.TXTAddStringEOL(values);
            //WriteString_EOL(outstream, groups);
            //WriteString_EOL(outstream, values);
            inblocksec := true;
          end
          else
            if (inblocksec) and ((groupi = 0) and (values = dxfName_ENDSEC)) then
            begin
              //historyoutstr('Blockdefs start here_______________________________________________________');
              if {p}drawing.BlockDefArray.count>0 then
              for i := 0 to {p}drawing.BlockDefArray.count - 1 do
              begin
                zDebugLn('{D}[DXF_CONTENTS]write BlockDef '+PBlockdefArray({p}drawing.BlockDefArray.parray)^[i].name);
                outstream.TXTAddStringEOL(dxfGroupCode(0));
                outstream.TXTAddStringEOL('BLOCK');

                //GetOrCreateHandle(@(PBlockdefArray(drawing.BlockDefArray.parray)^[i]),handle,temphandle);
                //
                outstream.TXTAddStringEOL(dxfGroupCode(5));
                outstream.TXTAddStringEOL(inttohex(IODXFContext.handle{temphandle}, 0));
                inc(IODXFContext.handle);
                outstream.TXTAddStringEOL(dxfGroupCode(100));
                outstream.TXTAddStringEOL(dxfName_AcDbEntity);
                outstream.TXTAddStringEOL(dxfGroupCode(8));
                outstream.TXTAddStringEOL('0');
                outstream.TXTAddStringEOL(dxfGroupCode(100));
                outstream.TXTAddStringEOL('AcDbBlockBegin');
                outstream.TXTAddStringEOL(dxfGroupCode(2));
                outstream.TXTAddStringEOL(dxfEnCodeString(PBlockdefArray(drawing.BlockDefArray.parray)^[i].name,IODXFContext.Header));
                outstream.TXTAddStringEOL(dxfGroupCode(70));
                outstream.TXTAddStringEOL('2');
                outstream.TXTAddStringEOL(dxfGroupCode(10));
                outstream.TXTAddStringEOL(floattostr(PBlockdefArray({p}drawing.BlockDefArray.parray)^[i].base.x));
                outstream.TXTAddStringEOL(dxfGroupCode(20));
                outstream.TXTAddStringEOL(floattostr(PBlockdefArray({p}drawing.BlockDefArray.parray)^[i].base.y));
                outstream.TXTAddStringEOL(dxfGroupCode(30));
                outstream.TXTAddStringEOL(floattostr(PBlockdefArray({p}drawing.BlockDefArray.parray)^[i].base.z));
                outstream.TXTAddStringEOL(dxfGroupCode(3));
                outstream.TXTAddStringEOL(PBlockdefArray({p}drawing.BlockDefArray.parray)^[i].name);
                outstream.TXTAddStringEOL(dxfGroupCode(1));
                outstream.TXTAddStringEOL('');

                saveentitiesdxf2000(@PBlockdefArray(drawing.BlockDefArray.parray)^[i].ObjArray, outstream,drawing,IODXFContext);

                outstream.TXTAddStringEOL(dxfGroupCode(0));
                outstream.TXTAddStringEOL('ENDBLK');
                outstream.TXTAddStringEOL(dxfGroupCode(5));
                outstream.TXTAddStringEOL(inttohex(IODXFContext.handle, 0));
                inc(IODXFContext.handle);
                outstream.TXTAddStringEOL(dxfGroupCode(100));
                outstream.TXTAddStringEOL(dxfName_AcDbEntity);
                outstream.TXTAddStringEOL(dxfGroupCode(8));
                outstream.TXTAddStringEOL('0');
                outstream.TXTAddStringEOL(dxfGroupCode(100));
                outstream.TXTAddStringEOL('AcDbBlockEnd');

                dxfStringWithoutEncodeOut(outstream,1001,ZCADAppNameInDXF);
                dxfStringWithoutEncodeOut(outstream,1002,'{');
                if assigned(PBlockdefArray(drawing.BlockDefArray.parray)^[i].EntExtensions) then
                  PBlockdefArray(drawing.BlockDefArray.parray)^[i].EntExtensions.RunSaveToDxf(outstream,@PBlockdefArray(drawing.BlockDefArray.parray)^[i],IODXFContext);
                dxfStringWithoutEncodeOut(outstream,1002,'}');


              end;

              outstream.TXTAddStringEOL(dxfGroupCode(0));
              outstream.TXTAddStringEOL(dxfName_ENDSEC);


              inblocksec := false;
            end
            else if (invporttable) and ((groupi = 0) and (values = dxfName_ENDTAB)) then
            begin
               invporttable:=false;
               ignoredsource:=false;

               outstream.TXTAddStringEOL(dxfGroupCode(5));
               outstream.TXTAddStringEOL(inttohex(IODXFContext.handle,0));
               vporttablehandle:=IODXFContext.handle;
               inc(IODXFContext.handle);

               outstream.TXTAddStringEOL(dxfGroupCode(330));
               outstream.TXTAddStringEOL('0');
               outstream.TXTAddStringEOL(dxfGroupCode(100));
               outstream.TXTAddStringEOL('AcDbSymbolTable');
               outstream.TXTAddStringEOL(dxfGroupCode(70));
               outstream.TXTAddStringEOL('1');
               outstream.TXTAddStringEOL(dxfGroupCode(0));
               outstream.TXTAddStringEOL('VPORT');
               outstream.TXTAddStringEOL(dxfGroupCode(5));
               outstream.TXTAddStringEOL(inttohex(IODXFContext.handle,0));
               inc(IODXFContext.handle);
               outstream.TXTAddStringEOL(dxfGroupCode(330));
               outstream.TXTAddStringEOL(inttohex(vporttablehandle,0));

               outstream.TXTAddStringEOL(dxfGroupCode(100));
               outstream.TXTAddStringEOL('AcDbSymbolTableRecord');
               outstream.TXTAddStringEOL(dxfGroupCode(100));
               outstream.TXTAddStringEOL('AcDbViewportTableRecord');

               outstream.TXTAddStringEOL(dxfGroupCode(2));
               outstream.TXTAddStringEOL('*Active');
               outstream.TXTAddStringEOL(dxfGroupCode(70));
               outstream.TXTAddStringEOL('0');

               outstream.TXTAddStringEOL(dxfGroupCode(10));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(20));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(11));
               outstream.TXTAddStringEOL('1.0');
               outstream.TXTAddStringEOL(dxfGroupCode(21));
               outstream.TXTAddStringEOL('1.0');

               if assigned(drawing.wa)and(drawing.wa.getviewcontrol<>nil) then
                                                        begin
                                                             outstream.TXTAddStringEOL(dxfGroupCode(12));
                                                             outstream.TXTAddStringEOL(floattostr(drawing.wa.param.CPoint.x));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(22));
                                                             outstream.TXTAddStringEOL(floattostr(drawing.wa.param.CPoint.y));
                                                        end
                                                    else
                                                        begin
                                                             outstream.TXTAddStringEOL(dxfGroupCode(12));
                                                             outstream.TXTAddStringEOL('0');
                                                             outstream.TXTAddStringEOL(dxfGroupCode(22));
                                                             outstream.TXTAddStringEOL('0');
                                                        end;
               outstream.TXTAddStringEOL(dxfGroupCode(13));
               outstream.TXTAddStringEOL(floattostr({sysvar.DWG.DWG_Snap^.Base.x}drawing.Snap.Base.x));
               outstream.TXTAddStringEOL(dxfGroupCode(23));
               outstream.TXTAddStringEOL(floattostr({sysvar.DWG.DWG_Snap^.Base.y}drawing.Snap.Base.y));
               outstream.TXTAddStringEOL(dxfGroupCode(14));
               outstream.TXTAddStringEOL(floattostr({sysvar.DWG.DWG_Snap^.Spacing.x}drawing.Snap.Spacing.x));
               outstream.TXTAddStringEOL(dxfGroupCode(24));
               outstream.TXTAddStringEOL(floattostr({sysvar.DWG.DWG_Snap^.Spacing.y}drawing.Snap.Spacing.y));
               outstream.TXTAddStringEOL(dxfGroupCode(15));
               outstream.TXTAddStringEOL(floattostr({sysvar.DWG.DWG_GridSpacing^.x}drawing.GridSpacing.x));
               outstream.TXTAddStringEOL(dxfGroupCode(25));
               outstream.TXTAddStringEOL(floattostr({sysvar.DWG.DWG_GridSpacing^.y}drawing.GridSpacing.y));
               outstream.TXTAddStringEOL(dxfGroupCode(16));
               outstream.TXTAddStringEOL(floattostr(-drawing.pcamera^.prop.look.x));
               outstream.TXTAddStringEOL(dxfGroupCode(26));
               outstream.TXTAddStringEOL(floattostr(-drawing.pcamera^.prop.look.y));
               outstream.TXTAddStringEOL(dxfGroupCode(36));
               outstream.TXTAddStringEOL(floattostr(-drawing.pcamera^.prop.look.z));
               outstream.TXTAddStringEOL(dxfGroupCode(17));
               outstream.TXTAddStringEOL(floattostr(0));
               outstream.TXTAddStringEOL(dxfGroupCode(27));
               outstream.TXTAddStringEOL(floattostr(0));
               outstream.TXTAddStringEOL(dxfGroupCode(37));
               outstream.TXTAddStringEOL(floattostr(0));
               outstream.TXTAddStringEOL(dxfGroupCode(40));
               if assigned(drawing.wa)and(drawing.wa.getviewcontrol<>nil) then
                                                        outstream.TXTAddStringEOL(floattostr(drawing.wa.param.ViewHeight))
                                                    else
                                                        outstream.TXTAddStringEOL(inttostr(500));
               outstream.TXTAddStringEOL(dxfGroupCode(41));
               if assigned(drawing.wa)and(drawing.wa.getviewcontrol<>nil) then
                                                        outstream.TXTAddStringEOL(floattostr(drawing.wa.getviewcontrol.ClientWidth/drawing.wa.getviewcontrol.ClientHeight))
                                                    else
                                                        outstream.TXTAddStringEOL(inttostr(1));
               outstream.TXTAddStringEOL(dxfGroupCode(42));
               outstream.TXTAddStringEOL('50.0');
               outstream.TXTAddStringEOL(dxfGroupCode(43));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(44));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(50));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(51));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(71));
               outstream.TXTAddStringEOL('0');
               outstream.TXTAddStringEOL(dxfGroupCode(72));
               outstream.TXTAddStringEOL('1000');
               outstream.TXTAddStringEOL(dxfGroupCode(73));
               outstream.TXTAddStringEOL('1');
               outstream.TXTAddStringEOL(dxfGroupCode(74));
               outstream.TXTAddStringEOL('3');
               outstream.TXTAddStringEOL(dxfGroupCode(75));
               //if sysvar.DWG.DWG_SnapGrid<>nil then
                                                   begin
                                                        if {sysvar.DWG.DWG_SnapGrid^}drawing.SnapGrid then
                                                                                        outstream.TXTAddStringEOL('1')
                                                                                    else
                                                                                        outstream.TXTAddStringEOL('0');
                                                   end;
                                               //else
                                               //    outstream.TXTAddStringEOL('0');
               outstream.TXTAddStringEOL(dxfGroupCode(76));
               //if sysvar.DWG.DWG_DrawGrid<>nil then
                                                     begin
                                                          if {sysvar.DWG.DWG_DrawGrid^}drawing.DrawGrid then
                                                                                          outstream.TXTAddStringEOL('1')
                                                                                      else
                                                                                          outstream.TXTAddStringEOL('0');
                                                     end;
                                                 //else
                                                 //    outstream.TXTAddStringEOL('0');
               outstream.TXTAddStringEOL(dxfGroupCode(77));
               outstream.TXTAddStringEOL('0');
               outstream.TXTAddStringEOL(dxfGroupCode(78));
               outstream.TXTAddStringEOL('0');
               outstream.TXTAddStringEOL(dxfGroupCode(281));
               outstream.TXTAddStringEOL('0');
               outstream.TXTAddStringEOL(dxfGroupCode(65));
               outstream.TXTAddStringEOL('1');
               outstream.TXTAddStringEOL(dxfGroupCode(110));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(120));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(130));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(111));
               outstream.TXTAddStringEOL('1.0');
               outstream.TXTAddStringEOL(dxfGroupCode(121));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(131));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(112));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(122));
               outstream.TXTAddStringEOL('1.0');
               outstream.TXTAddStringEOL(dxfGroupCode(132));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(79));
               outstream.TXTAddStringEOL('0');
               outstream.TXTAddStringEOL(dxfGroupCode(146));
               outstream.TXTAddStringEOL('0.0');
               //outstream.TXTAddStringEOL(dxfGroupCode(1001));
               //outstream.TXTAddStringEOL('ACAD_NAV_VCDISPLAY');
               //outstream.TXTAddStringEOL(dxfGroupCode(1070));
               //outstream.TXTAddStringEOL('3');
               outstream.TXTAddStringEOL(dxfGroupCode(0));
               outstream.TXTAddStringEOL('ENDTAB');

            end
            else if (inblocktable) and ((groupi = 0) and (values = dxfName_ENDTAB)) then
            begin
              inblocktable := false;
              if {p}drawing.BlockDefArray.count>0 then

              for i := 0 to {p}drawing.BlockDefArray.count - 1 do
              begin
                outstream.TXTAddStringEOL(dxfGroupCode(0));
                outstream.TXTAddStringEOL(dxfName_BLOCK_RECORD);

                IODXFContext.p2h.MyGetOrCreateValue(@(PBlockdefArray(drawing.BlockDefArray.parray)^[i]),IODXFContext.handle,temphandle);
                //GetOrCreateHandle(@(PBlockdefArray(drawing.BlockDefArray.parray)^[i]),handle,temphandle);

                outstream.TXTAddStringEOL(dxfGroupCode(5));
                outstream.TXTAddStringEOL(inttohex(temphandle, 0));
                outstream.TXTAddStringEOL(dxfGroupCode(100));
                outstream.TXTAddStringEOL(dxfName_AcDbSymbolTableRecord);
                outstream.TXTAddStringEOL(dxfGroupCode(100));
                outstream.TXTAddStringEOL('AcDbBlockTableRecord');
                outstream.TXTAddStringEOL(dxfGroupCode(2));
                outstream.TXTAddStringEOL(dxfEnCodeString(PBlockdefArray(drawing.BlockDefArray.parray)^[i].name,IODXFContext.Header));

              end;
              outstream.TXTAddStringEOL(dxfGroupCode(0));
              outstream.TXTAddStringEOL(dxfName_ENDTAB);
            end

            else
              if (inlayertable) and ((groupi = 0) and (values = dxfName_ENDTAB)) then
              begin
                inlayertable := false;
                ignoredsource:=false;
                plp:=drawing.layertable.beginiterate(ir);
                if plp<>nil then
                repeat
                //for i := 0 to drawing.layertable.count - 1 do
                begin
                  //if PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[pltp].name <> '0' then
                  begin
                    outstream.TXTAddStringEOL(dxfGroupCode(0));
                    outstream.TXTAddStringEOL(dxfName_Layer);
                    outstream.TXTAddStringEOL(dxfGroupCode(5));
                    outstream.TXTAddStringEOL(inttohex(IODXFContext.handle, 0));
                    inc(IODXFContext.handle);
                    outstream.TXTAddStringEOL(dxfGroupCode(100));
                    outstream.TXTAddStringEOL(dxfName_AcDbSymbolTableRecord);
                    outstream.TXTAddStringEOL(dxfGroupCode(100));
                    outstream.TXTAddStringEOL('AcDbLayerTableRecord');
                    outstream.TXTAddStringEOL(dxfGroupCode(2));
                    outstream.TXTAddStringEOL(dxfEnCodeString(plp^.name,IODXFContext.Header));
                    attr:=0;
                    if plp^._lock then
                                     attr:=attr + 4;
                    outstream.TXTAddStringEOL(dxfGroupCode(70));
                    outstream.TXTAddStringEOL(inttostr(attr));
                    outstream.TXTAddStringEOL(dxfGroupCode(62));
                    if plp^._on
                     then
                         outstream.TXTAddStringEOL(inttostr(plp^.color))
                     else
                         outstream.TXTAddStringEOL(inttostr(-plp^.color));
                    outstream.TXTAddStringEOL(dxfGroupCode(6));
                    outstream.TXTAddStringEOL(dxfEnCodeString(GetLTName(plp^.LT),IODXFContext.Header));
                    {if assigned(plp^.LT) then
                                             outstream.TXTAddStringEOL(PGDBLtypeProp(plp^.LT)^.Name)
                                         else
                                             outstream.TXTAddStringEOL('Continuous');}
                    outstream.TXTAddStringEOL(dxfGroupCode(290));
                    if plp^._print then
                    //if uppercase(PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[pltp].name) <> 'DEFPOINTS' then
                      outstream.TXTAddStringEOL('1')
                    else
                      outstream.TXTAddStringEOL('0');
                    outstream.TXTAddStringEOL(dxfGroupCode(370));
                    outstream.TXTAddStringEOL(inttostr(plp^.lineweight));
                    //WriteString_EOL(outstream, '-3');
                    outstream.TXTAddStringEOL(dxfGroupCode(390));
                    outstream.TXTAddStringEOL(inttohex(plottablefansdle,0));

                    if plp^.desk<>''then
                    begin
                         outstream.TXTAddStringEOL(dxfGroupCode(1001));
                         outstream.TXTAddStringEOL('AcAecLayerStandard');
                         outstream.TXTAddStringEOL(dxfGroupCode(1000));
                         outstream.TXTAddStringEOL('');
                         outstream.TXTAddStringEOL(dxfGroupCode(1000));
                         outstream.TXTAddStringEOL(dxfEnCodeString(plp^.desk,IODXFContext.Header));
                    end;
                  end;
                end;
                plp:=drawing.layertable.iterate(ir);
                until plp=nil;

                outstream.TXTAddStringEOL(groups);
                outstream.TXTAddStringEOL(values);
              end


            else
              if (inlttypetable) and ((groupi = 0) and (values = dxfName_ENDTAB)) then
              begin
                   inlttypetable := false;
                   ignoredsource:=false;
                   temphandle:=IODXFContext.handle-1;
                   pltp:=drawing.LTypeStyleTable.beginiterate(ir);
                   if pltp<>nil then
                   repeat
                         zDebugLn('{D}[DXF_CONTENTS]write linetype '+pltp^.Name);
                         outstream.TXTAddStringEOL(dxfGroupCode(0));
                         outstream.TXTAddStringEOL(dxfName_LTYPE);
                         IODXFContext.p2h.MyGetOrCreateValue(pltp,IODXFContext.handle,temphandle);
                         outstream.TXTAddStringEOL(dxfGroupCode(5));
                         outstream.TXTAddStringEOL(inttohex(temphandle, 0));
                         {outstream.TXTAddStringEOL(inttohex(handle, 0));
                         inc(handle);}
                         outstream.TXTAddStringEOL(dxfGroupCode(330));
                         outstream.TXTAddStringEOL(inttohex(temphandle, 0));
                         outstream.TXTAddStringEOL(dxfGroupCode(100));
                         outstream.TXTAddStringEOL(dxfName_AcDbSymbolTableRecord);
                         outstream.TXTAddStringEOL(dxfGroupCode(100));
                         outstream.TXTAddStringEOL('AcDbLinetypeTableRecord');
                         outstream.TXTAddStringEOL(dxfGroupCode(2));
                         outstream.TXTAddStringEOL(dxfEnCodeString(pltp^.Name,IODXFContext.Header));
                         outstream.TXTAddStringEOL(dxfGroupCode(70));
                         outstream.TXTAddStringEOL('0');
                         outstream.TXTAddStringEOL(dxfGroupCode(3));
                         outstream.TXTAddStringEOL(dxfEnCodeString(pltp^.desk,IODXFContext.Header));
                         outstream.TXTAddStringEOL(dxfGroupCode(72));
                         outstream.TXTAddStringEOL('65');
                         i:=pltp^.strokesarray.GetRealCount;
                         outstream.TXTAddStringEOL(dxfGroupCode(73));
                         outstream.TXTAddStringEOL(inttostr(i));
                         outstream.TXTAddStringEOL(dxfGroupCode(40));
                         outstream.TXTAddStringEOL(floattostr(pltp^.LengthDXF));
                         if i>0 then
                         begin
                              TDI:=pltp^.dasharray.beginiterate(ir2);
                              PStroke:=pltp^.strokesarray.beginiterate(ir3);
                              PSP:=pltp^.shapearray.beginiterate(ir4);
                              PTP:=pltp^.textarray.beginiterate(ir5);
                              laststrokewrited:=false;
                              if PStroke<>nil then
                              repeat
                                    case TDI^ of
                                                TDIDash:begin
                                                             if laststrokewrited then
                                                                                     begin
                                                                                     outstream.TXTAddStringEOL(dxfGroupCode(74));
                                                                                     outstream.TXTAddStringEOL('0');
                                                                                     end;
                                                             outstream.TXTAddStringEOL(dxfGroupCode(49));
                                                             outstream.TXTAddStringEOL(floattostr(PStroke^));
                                                             {outstream.TXTAddStringEOL(dxfGroupCode(74));
                                                             outstream.TXTAddStringEOL('0');}
                                                             PStroke:=pltp^.strokesarray.iterate(ir3);
                                                             laststrokewrited:=true;
                                                        end;
                                               TDIShape:if PSP^.param.PStyle<>nil then
                                                        begin
                                                             laststrokewrited:=false;
                                                             outstream.TXTAddStringEOL(dxfGroupCode(74));
                                                             outstream.TXTAddStringEOL('4');
                                                             outstream.TXTAddStringEOL(dxfGroupCode(75));
                                                             outstream.TXTAddStringEOL(inttostr(PSP^.ShapeNum));

                                                             IODXFContext.p2h.MyGetOrCreateValue(PSP^.param.PStyle,IODXFContext.handle,temphandle);
                                                             //GetOrCreateHandle(PSP^.param.PStyle,handle,temphandle);

                                                             outstream.TXTAddStringEOL(dxfGroupCode(340));
                                                             outstream.TXTAddStringEOL(inttohex(temphandle,0));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(46));
                                                             outstream.TXTAddStringEOL(floattostr(PSP^.param.Height));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(50));
                                                             outstream.TXTAddStringEOL(floattostr(PSP^.param.Angle));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(44));
                                                             outstream.TXTAddStringEOL(floattostr(PSP^.param.X));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(45));
                                                             outstream.TXTAddStringEOL(floattostr(PSP^.param.Y));
                                                             PSP:=pltp^.shapearray.iterate(ir4);
                                                        end;
                                               TDIText:begin
                                                             laststrokewrited:=false;
                                                             outstream.TXTAddStringEOL(dxfGroupCode(74));
                                                             outstream.TXTAddStringEOL('2');
                                                             outstream.TXTAddStringEOL(dxfGroupCode(75));
                                                             outstream.TXTAddStringEOL('0');

                                                             IODXFContext.p2h.MyGetOrCreateValue(PTP^.param.PStyle,IODXFContext.handle,temphandle);
                                                             //GetOrCreateHandle(PTP^.param.PStyle,handle,temphandle);

                                                             {else
                                                                 temphandle:=standartstylehandle;}
                                                             outstream.TXTAddStringEOL(dxfGroupCode(340));
                                                             outstream.TXTAddStringEOL(inttohex(temphandle,0));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(46));
                                                             outstream.TXTAddStringEOL(floattostr(PTP^.param.Height));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(50));
                                                             outstream.TXTAddStringEOL(floattostr(PTP^.param.Angle));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(44));
                                                             outstream.TXTAddStringEOL(floattostr(PTP^.param.X));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(45));
                                                             outstream.TXTAddStringEOL(floattostr(PTP^.param.Y));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(9));
                                                             outstream.TXTAddStringEOL(PTP^.TEXT);
                                                             PTP:=pltp^.textarray.iterate(ir5);
                                                        end;
                                    end;
                                    TDI:=pltp^.dasharray.iterate(ir2);
                              until {PStroke}TDI=nil;
                              if laststrokewrited then
                                                       begin
                                                       outstream.TXTAddStringEOL(dxfGroupCode(74));
                                                       outstream.TXTAddStringEOL('0');
                                                       end;

                         end;


                         pltp:=drawing.LTypeStyleTable.iterate(ir);
                   until pltp=nil;
                   outstream.TXTAddStringEOL(groups);
                   outstream.TXTAddStringEOL(values);
              end
            else
              if (indimstyletable) and ((groupi = 0) and (values = dxfName_ENDTAB)) then
              begin
                { TODO :  надо писать заголовок таблицы руками, а не из шаблона DXF, т.к. там есть перечень стилей который проебывается}
                indimstyletable:=false;
                ignoredsource:=false;
                //temphandle3:=handle-1;
                //temphandle4:=handle-3;
                //дальше идут стили
                pdsp:=drawing.DimStyleTable.beginiterate(ir);
                if pdsp<>nil then
                repeat
                      outstream.TXTAddStringEOL(dxfGroupCode(0));
                      outstream.TXTAddStringEOL('DIMSTYLE');
                      outstream.TXTAddStringEOL(dxfGroupCode(105));
                      outstream.TXTAddStringEOL(inttohex({temphandle3}IODXFContext.handle, 0));
                      inc(IODXFContext.handle);

                      outstream.TXTAddStringEOL(dxfGroupCode(330));
                      outstream.TXTAddStringEOL(inttohex({temphandle4}{temphandle3}dimtablehandle, 0));

                      outstream.TXTAddStringEOL(dxfGroupCode(100));
                      outstream.TXTAddStringEOL('AcDbSymbolTableRecord');
                      outstream.TXTAddStringEOL(dxfGroupCode(100));
                      outstream.TXTAddStringEOL('AcDbDimStyleTableRecord');
                      outstream.TXTAddStringEOL(dxfGroupCode(2));
                      outstream.TXTAddStringEOL({pdsp^.Name}dxfEncodeString(pdsp^.Name,IODXFContext.Header));
                      outstream.TXTAddStringEOL(dxfGroupCode(3));
                      outstream.TXTAddStringEOL(pdsp^.Units.DIMPOST);
                      outstream.TXTAddStringEOL(dxfGroupCode(70));
                      outstream.TXTAddStringEOL('0');

                      //тут сами настройки
                      outstream.TXTAddStringEOL(dxfGroupCode(40));
                      outstream.TXTAddStringEOL(floattostr(pdsp^.Units.DIMSCALE));
                      outstream.TXTAddStringEOL(dxfGroupCode(44));
                      outstream.TXTAddStringEOL(floattostr(pdsp^.Lines.DIMEXE));
                      outstream.TXTAddStringEOL(dxfGroupCode(42));
                      outstream.TXTAddStringEOL(floattostr(pdsp^.Lines.DIMEXO));
                      outstream.TXTAddStringEOL(dxfGroupCode(46));
                      outstream.TXTAddStringEOL(floattostr(pdsp^.Lines.DIMDLE));

                      outstream.TXTAddStringEOL(dxfGroupCode(41));
                      outstream.TXTAddStringEOL(floattostr(pdsp^.Arrows.DIMASZ));

                      outstream.TXTAddStringEOL(dxfGroupCode(173));
                      if pdsp^.Arrows.DIMBLK1<>pdsp^.Arrows.DIMBLK2 then
                                                                        begin
                                                                             outstream.TXTAddStringEOL('1');
                                                                         end
                                           else
                                               begin
                                                    outstream.TXTAddStringEOL('0');
                                               end;

                      if pdsp^.Arrows.DIMLDRBLK<>TSClosedFilled then
                      begin
                           IODXFContext.p2h.MyGetOrCreateValue(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(-1).name),IODXFContext.handle,temphandle);
                           //GetOrCreateHandle(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(-1).name),handle,temphandle);
                           outstream.TXTAddStringEOL(dxfGroupCode(341));
                           outstream.TXTAddStringEOL(inttohex(temphandle,0));
                      end;


                      if pdsp^.Arrows.DIMBLK1<>pdsp^.Arrows.DIMBLK2 then
                                                                        begin
                                                                             if pdsp^.Arrows.DIMBLK1<>TSClosedFilled then
                                                                             begin
                                                                                   IODXFContext.p2h.MyGetOrCreateValue(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(0).name),IODXFContext.handle,temphandle);
                                                                                   //GetOrCreateHandle(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(0).name),handle,temphandle);
                                                                                   if temphandle<>0 then
                                                                                   begin
                                                                                         outstream.TXTAddStringEOL(dxfGroupCode(343));
                                                                                         outstream.TXTAddStringEOL(inttohex(temphandle,0));
                                                                                   end;
                                                                             end;
                                                                             if pdsp^.Arrows.DIMBLK2<>TSClosedFilled then
                                                                             begin
                                                                                   IODXFContext.p2h.MyGetOrCreateValue(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(1).name),IODXFContext.handle,temphandle);
                                                                                   //GetOrCreateHandle(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(1).name),handle,temphandle);
                                                                                   if temphandle<>0 then
                                                                                   begin
                                                                                         outstream.TXTAddStringEOL(dxfGroupCode(344));
                                                                                         outstream.TXTAddStringEOL(inttohex(temphandle,0));
                                                                                   end;
                                                                             end;
                                                                         end
                                           else
                                               begin
                                                    if pdsp^.Arrows.DIMBLK1<>TSClosedFilled then
                                                    begin
                                                    IODXFContext.p2h.MyGetOrCreateValue(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(0).name),IODXFContext.handle,temphandle);
                                                    //GetHandle(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(0).name),temphandle);
                                                    if temphandle<>0 then
                                                    begin
                                                    outstream.TXTAddStringEOL(dxfGroupCode(342));
                                                    outstream.TXTAddStringEOL(inttohex(temphandle,0));
                                                    end;
                                                    end;
                                               end;

                      //GetOrCreateHandle(@(PBlockdefArray(drawing.BlockDefArray.parray)^[i]),handle,temphandle);

                       (*
                       TGDBDimArrowsProp=packed record
                                              DIMBLK1:TArrowStyle;//First arrow block name//group343
                                              DIMBLK2:TArrowStyle;//First arrow block name//group344
                                              DIMLDRBLK:TArrowStyle;//Arrow block name for leaders//group341
                                         end;
                       *)
                       outstream.TXTAddStringEOL(dxfGroupCode(140));
                       outstream.TXTAddStringEOL(floattostr(pdsp^.Text.DIMTXT));

                       outstream.TXTAddStringEOL(dxfGroupCode(141));
                       outstream.TXTAddStringEOL(floattostr(pdsp^.Lines.DIMCEN));

                       outstream.TXTAddStringEOL(dxfGroupCode(73));
                       if pdsp^.Text.DIMTIH then
                                                outstream.TXTAddStringEOL('1')
                                            else
                                                outstream.TXTAddStringEOL('0');
                       outstream.TXTAddStringEOL(dxfGroupCode(74));
                       if pdsp^.Text.DIMTOH then
                                                outstream.TXTAddStringEOL('1')
                                            else
                                                outstream.TXTAddStringEOL('0');
                       outstream.TXTAddStringEOL(dxfGroupCode(147));
                       outstream.TXTAddStringEOL(floattostr(pdsp^.Text.DIMGAP));

                       outstream.TXTAddStringEOL(dxfGroupCode(77));
                       case pdsp^.Text.DIMTAD of
                                  DTVPCenters:outstream.TXTAddStringEOL('0');
                                    DTVPAbove:outstream.TXTAddStringEOL('1');
                                  DTVPOutside:outstream.TXTAddStringEOL('2');
                                      DTVPJIS:outstream.TXTAddStringEOL('3');
                                   DTVPBellov:outstream.TXTAddStringEOL('4');
                       end;{case}

                       outstream.TXTAddStringEOL(dxfGroupCode(144));
                       outstream.TXTAddStringEOL(floattostr(pdsp^.Units.DIMLFAC));
                       outstream.TXTAddStringEOL(dxfGroupCode(271));
                       outstream.TXTAddStringEOL(inttostr(pdsp^.Units.DIMDEC));
                       outstream.TXTAddStringEOL(dxfGroupCode(45));
                       outstream.TXTAddStringEOL(floattostr(pdsp^.Units.DIMRND));

                       outstream.TXTAddStringEOL(dxfGroupCode(277));
                       case pdsp^.Units.DIMLUNIT of
                                   DUScientific:outstream.TXTAddStringEOL('1');
                                      DUDecimal:outstream.TXTAddStringEOL('2');
                                  DUEngineering:outstream.TXTAddStringEOL('3');
                                DUArchitectural:outstream.TXTAddStringEOL('4');
                                   DUFractional:outstream.TXTAddStringEOL('5');
                                       DUSystem:outstream.TXTAddStringEOL('6');
                       end;{case}
                       outstream.TXTAddStringEOL(dxfGroupCode(278));
                       case pdsp^.Units.DIMDSEP of
                                   DDSDot:outstream.TXTAddStringEOL('46');
                                 DDSComma:outstream.TXTAddStringEOL('44');
                                 DDSSpace:outstream.TXTAddStringEOL('32');
                       end;{case}
                       outstream.TXTAddStringEOL(dxfGroupCode(279));
                       case pdsp^.Placing.DIMTMOVE of
                                   DTMMoveDimLine:outstream.TXTAddStringEOL('0');
                                 DTMCreateLeader:outstream.TXTAddStringEOL('1');
                                 DTMnothung:outstream.TXTAddStringEOL('2');
                       end;{case}

                       if pdsp^.Lines.DIMLWD<>DIMLWDDefaultValue then
                       begin
                        //dxfIntegerout(outhandle,371,pdsp^.Lines.DIMLWD);
                        outstream.TXTAddStringEOL(dxfGroupCode(371));
                        outstream.TXTAddStringEOL(inttostr(pdsp^.Lines.DIMLWD));
                       end;
                       if pdsp^.Lines.DIMLWE<>DIMLWEDefaultValue then
                       begin
                        //dxfIntegerout(outhandle,372,pdsp^.Lines.DIMLWE);
                        outstream.TXTAddStringEOL(dxfGroupCode(372));
                        outstream.TXTAddStringEOL(inttostr(pdsp^.Lines.DIMLWE));
                       end;

                       if pdsp^.Lines.DIMCLRD<>DIMCLRDDefaultValue then
                       begin
                        outstream.TXTAddStringEOL(dxfGroupCode(176));
                        outstream.TXTAddStringEOL(inttostr(pdsp^.Lines.DIMCLRD));
                       end;
                       if pdsp^.Lines.DIMCLRE<>DIMCLREDefaultValue then
                       begin
                        outstream.TXTAddStringEOL(dxfGroupCode(177));
                        outstream.TXTAddStringEOL(inttostr(pdsp^.Lines.DIMCLRE));
                       end;
                       if pdsp^.Text.DIMCLRT<>DIMCLRTDefaultValue then
                       begin
                        outstream.TXTAddStringEOL(dxfGroupCode(178));
                        outstream.TXTAddStringEOL(inttostr(pdsp^.Text.DIMCLRT));
                       end;

                      outstream.TXTAddStringEOL(dxfGroupCode(340));
                      p:=pdsp^.Text.DIMTXSTY{drawing.TextStyleTable.FindStyle('Standard',false)};

                      IODXFContext.p2h.MyGetOrCreateValue(p,IODXFContext.handle,temphandle);
                      //GetOrCreateHandle(p,handle,temphandle);

                      outstream.TXTAddStringEOL(inttohex(temphandle, 0));

                      pltp:=drawing.LTypeStyleTable.GetSystemLT(TLTByBlock);
                      if (pdsp^.Lines.DIMLTYPE<>pltp)and(pdsp^.Lines.DIMLTYPE<>nil)then
                      begin
                           outstream.TXTAddStringEOL(dxfGroupCode(1001));
                           outstream.TXTAddStringEOL('ACAD_DSTYLE_DIM_LINETYPE');
                           outstream.TXTAddStringEOL(dxfGroupCode(1070));
                           outstream.TXTAddStringEOL('380');
                           outstream.TXTAddStringEOL(dxfGroupCode(1005));
                           IODXFContext.p2h.MyGetOrCreateValue(pdsp^.Lines.DIMLTYPE,IODXFContext.handle,temphandle);
                           outstream.TXTAddStringEOL(inttohex(temphandle,0));
                      end;
                      if (pdsp^.Lines.DIMLTEX1<>pltp)and(pdsp^.Lines.DIMLTEX1<>nil)then
                      begin
                           outstream.TXTAddStringEOL(dxfGroupCode(1001));
                           outstream.TXTAddStringEOL('ACAD_DSTYLE_DIM_EXT1_LINETYPE');
                           outstream.TXTAddStringEOL(dxfGroupCode(1070));
                           outstream.TXTAddStringEOL('381');
                           outstream.TXTAddStringEOL(dxfGroupCode(1005));
                           IODXFContext.p2h.MyGetOrCreateValue(pdsp^.Lines.DIMLTEX1,IODXFContext.handle,temphandle);
                           outstream.TXTAddStringEOL(inttohex(temphandle,0));
                      end;
                      if (pdsp^.Lines.DIMLTEX2<>pltp)and(pdsp^.Lines.DIMLTEX2<>nil)then
                      begin
                           outstream.TXTAddStringEOL(dxfGroupCode(1001));
                           outstream.TXTAddStringEOL('ACAD_DSTYLE_DIM_EXT2_LINETYPE');
                           outstream.TXTAddStringEOL(dxfGroupCode(1070));
                           outstream.TXTAddStringEOL('382');
                           outstream.TXTAddStringEOL(dxfGroupCode(1005));
                           IODXFContext.p2h.MyGetOrCreateValue(pdsp^.Lines.DIMLTEX2,IODXFContext.handle,temphandle);
                           outstream.TXTAddStringEOL(inttohex(temphandle,0));
                      end;

                      pdsp:=drawing.DimStyleTable.iterate(ir);
                until pdsp=nil;
                outstream.TXTAddStringEOL(groups);
                outstream.TXTAddStringEOL(values);
{0
DIMSTYLE
105
2EE
330
2ED
100
AcDbSymbolTableRecord
100
AcDbDimStyleTableRecord
  2
Standard
 70
     0
340
2DC
  0
ENDTAB}

              end
            else if (groupi = 0) and (values = dxfName_ENDTAB)and inappidtable then
                begin
                  inappidtable := false;
                  ignoredsource:=false;

                  RegisterAcadAppInDXF('ACAD',@outstream,IODXFContext.handle);
                  RegisterAcadAppInDXF('ACAD_PSEXT',@outstream,IODXFContext.handle);
                  RegisterAcadAppInDXF('AcAecLayerStandard',@outstream,IODXFContext.handle);
                  RegisterAcadAppInDXF(ZCADAppNameInDXF,@outstream,IODXFContext.handle);
                  //RegisterAcadAppInDXF('ACAD_NAV_VCDISPLAY',@outstream,handle);
                  RegisterAcadAppInDXF('ACAD_DSTYLE_DIM_LINETYPE',@outstream,IODXFContext.handle);
                  RegisterAcadAppInDXF('ACAD_DSTYLE_DIM_EXT1_LINETYPE',@outstream,IODXFContext.handle);
                  RegisterAcadAppInDXF('ACAD_DSTYLE_DIM_EXT2_LINETYPE',@outstream,IODXFContext.handle);

                  outstream.TXTAddStringEOL(dxfGroupCode(0));
                  outstream.TXTAddStringEOL('ENDTAB');
                end
            else
              if (instyletable) and ((groupi = 0) and (values = dxfName_ENDTAB)) then
              begin
                instyletable := false;
                ignoredsource:=false;
                temphandle2:=IODXFContext.handle-2;
                if drawing.TextStyleTable.GetRealCount>0 then
                begin
                pcurrtextstyle:=drawing.TextStyleTable.beginiterate(ir);
                if pcurrtextstyle<>nil then
                //for i := 0 to drawing.TextStyleTable.count - 1 do
                repeat
                  //if PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[i].name <> '0' then
                  if {drawing.TextStyleTable.getelement(i))}pcurrtextstyle^.UsedInLTYPE then
                  begin
                  outstream.TXTAddStringEOL(dxfGroupCode(0));
                  outstream.TXTAddStringEOL(dxfName_Style);
                  p:={drawing.TextStyleTable.getelement(i))}pcurrtextstyle;

                  IODXFContext.p2h.MyGetOrCreateValue({drawing.TextStyleTable.getelement(i))}pcurrtextstyle,IODXFContext.handle,temphandle);
                  //GetOrCreateHandle(drawing.TextStyleTable.getelement(i),handle,temphandle);

                  outstream.TXTAddStringEOL(dxfGroupCode(5));
                  outstream.TXTAddStringEOL(inttohex({handle}temphandle, 0));
                  inc(IODXFContext.handle);
                  outstream.TXTAddStringEOL(dxfGroupCode(330));
                  outstream.TXTAddStringEOL(inttohex(temphandle2, 0));
                  outstream.TXTAddStringEOL(dxfGroupCode(100));
                  outstream.TXTAddStringEOL(dxfName_AcDbSymbolTableRecord);
                  outstream.TXTAddStringEOL(dxfGroupCode(100));
                  outstream.TXTAddStringEOL('AcDbTextStyleTableRecord');
                  outstream.TXTAddStringEOL(dxfGroupCode(2));
                  outstream.TXTAddStringEOL('');
                  outstream.TXTAddStringEOL(dxfGroupCode(70));
                  outstream.TXTAddStringEOL('1');

                  outstream.TXTAddStringEOL(dxfGroupCode(40));
                  outstream.TXTAddStringEOL(floattostr({drawing.TextStyleTable.getelement(i))}pcurrtextstyle^.prop.size));

                  outstream.TXTAddStringEOL(dxfGroupCode(41));
                  outstream.TXTAddStringEOL(floattostr({drawing.TextStyleTable.getelement(i))}pcurrtextstyle^.prop.wfactor));

                  outstream.TXTAddStringEOL(dxfGroupCode(50));
                  outstream.TXTAddStringEOL(floattostr(pcurrtextstyle^.prop.oblique*180/pi));

                  outstream.TXTAddStringEOL(dxfGroupCode(71));
                  outstream.TXTAddStringEOL('0');

                  outstream.TXTAddStringEOL(dxfGroupCode(42));
                  outstream.TXTAddStringEOL('2.5');

                  outstream.TXTAddStringEOL(dxfGroupCode(3));
                  outstream.TXTAddStringEOL({drawing.TextStyleTable.getelement(i))}pcurrtextstyle^.FontFile);

                  outstream.TXTAddStringEOL(dxfGroupCode(4));
                  outstream.TXTAddStringEOL('');

                  end
                  else
                  begin
                    outstream.TXTAddStringEOL(dxfGroupCode(0));
                    outstream.TXTAddStringEOL(dxfName_Style);
                    outstream.TXTAddStringEOL(dxfGroupCode(5));
                    //if uppercase(PGDBTextStyle(drawing.TextStyleTable.getelement(i))^.name)<>TSNStandardStyleName then
                    begin
                    p:={drawing.TextStyleTable.getelement(i))}pcurrtextstyle;

                    IODXFContext.p2h.MyGetOrCreateValue(p,IODXFContext.handle,temphandle);
                    //GetOrCreateHandle(p,handle,temphandle);

                    outstream.TXTAddStringEOL(inttohex(temphandle, 0));
                    //inc(handle);
                    end;
                    {else
                        outstream.TXTAddStringEOL(inttohex(standartstylehandle, 0));}
                  outstream.TXTAddStringEOL(dxfGroupCode(330));
                  outstream.TXTAddStringEOL(inttohex(temphandle2, 0));
                    outstream.TXTAddStringEOL(dxfGroupCode(100));
                    outstream.TXTAddStringEOL(dxfName_AcDbSymbolTableRecord);
                    outstream.TXTAddStringEOL(dxfGroupCode(100));
                    outstream.TXTAddStringEOL('AcDbTextStyleTableRecord');
                    outstream.TXTAddStringEOL(dxfGroupCode(2));
                    outstream.TXTAddStringEOL({pcurrtextstyle^.name}dxfEncodeString(pcurrtextstyle^.name,IODXFContext.Header));
                    outstream.TXTAddStringEOL(dxfGroupCode(70));
                    outstream.TXTAddStringEOL('0');

                    outstream.TXTAddStringEOL(dxfGroupCode(40));
                    outstream.TXTAddStringEOL(floattostr({drawing.TextStyleTable.getelement(i))}pcurrtextstyle^.prop.size));

                    outstream.TXTAddStringEOL(dxfGroupCode(41));
                    outstream.TXTAddStringEOL(floattostr({drawing.TextStyleTable.getelement(i))}pcurrtextstyle^.prop.wfactor));

                    outstream.TXTAddStringEOL(dxfGroupCode(50));
                    outstream.TXTAddStringEOL(floattostr({drawing.TextStyleTable.getelement(i))}pcurrtextstyle^.prop.oblique*180/pi));

                    outstream.TXTAddStringEOL(dxfGroupCode(71));
                    outstream.TXTAddStringEOL('0');

                    outstream.TXTAddStringEOL(dxfGroupCode(42));
                    outstream.TXTAddStringEOL('2.5');

                    outstream.TXTAddStringEOL(dxfGroupCode(3));
                    outstream.TXTAddStringEOL({drawing.TextStyleTable.getelement(i))}pcurrtextstyle^.FontFile);

                    outstream.TXTAddStringEOL(dxfGroupCode(4));
                    outstream.TXTAddStringEOL('');
                    if pcurrtextstyle^.FontFamily<>'' then begin
                      outstream.TXTAddStringEOL(dxfGroupCode(1001));
                      outstream.TXTAddStringEOL('ACAD');
                      outstream.TXTAddStringEOL(dxfGroupCode(1000));
                      outstream.TXTAddStringEOL(pcurrtextstyle^.FontFamily);
                    end;
                  end;
                pcurrtextstyle:=drawing.TextStyleTable.iterate(ir);
                until pcurrtextstyle=nil;
                end;
                outstream.TXTAddStringEOL(groups);
                outstream.TXTAddStringEOL(values);
              end


              else
                if (groupi = 0) and (values = dxfName_TABLE) then
                begin
                  outstream.TXTAddStringEOL(groups);
                  outstream.TXTAddStringEOL(values);
                  groups := templatefile.readString;
                  values := templatefile.readString;
                  groupi := strtoint(groups);
                  outstream.TXTAddStringEOL(groups);
                  outstream.TXTAddStringEOL(values);
                  if (groupi = 2) and (values = dxfName_Layer) then
                  begin
                    inlayertable := true;
                  end
                  else if (groupi = 2) and (values = dxfName_BLOCK_RECORD) then
                  begin
                    inblocktable := true;
                  end
                  else if (groupi = 2) and (values = dxfName_Style) then
                  begin
                    instyletable := true;
                  end
                  else if (groupi = 2) and (values = dxfName_LType) then
                  begin
                    inlttypetable := true;
                  end
                  else if (groupi = 2) and (values = 'DIMSTYLE') then
                  begin
                    indimstyletable := true;
                  end
                  else if (groupi = 2) and (values = 'APPID') then
                  begin
                    inappidtable := true;
                  end
                  else if (groupi = 2) and (values = 'VPORT') then
                  begin
                    invporttable := true;
                    IgnoredSource := true;
                  end;

                end

              else if (groupi = 0) and (values = dxfName_Layer)and inlayertable then
                  begin
                    IgnoredSource := true;
                  end
              else if (groupi = 0) and (values = 'APPID')and inappidtable then
                  begin
                    IgnoredSource := true;
                  end
              else if (groupi = 0) and (values = dxfName_Style)and instyletable then
                  begin
                    IgnoredSource := true;
                  end
              else if (groupi = 0) and (values = dxfName_LType)and inlttypetable then
                  begin
                    IgnoredSource := true;
                  end
              else if (groupi = 0) and (values = dxfName_DIMSTYLE)and indimstyletable then
                  begin
                    IgnoredSource := true;
                  end
                else
                begin
                  if not ignoredsource then
                  begin
                  outstream.TXTAddStringEOL(groups);
                  outstream.TXTAddStringEOL(values);
                  end;
                  //val('$' + values, i, cod);
                end;
    //s := readspace(s);
  end;
  //templatefileclose;

  i:=outstream.Count;
  outstream.Count:=handlepos;
  outstream.TXTAddStringEOL(inttohex(IODXFContext.handle+$100000000,9){'100000013'});
  outstream.Count:=i;

  //-------------FileSeek(outstream,handlepos,0);
  //-------------WriteString_EOL(outstream,inttohex(handle+1,8));
  //-------------fileclose(outstream);


  //Freemem(Pointer(phandlea));
  OldHandele2NewHandle.Destroy;
  templatefile.done;

  sysfilename:={$IFNDEF DELPHI}utf8tosys{$ENDIF}(SavedFileName);
  if FileExists(sysfilename) then begin
    deletefile(sysfilename+'.bak');
    if not renamefile(sysfilename,sysfilename+'.bak') then
      zDebugLn('{WH}'+rsUnableRenameFileToBak,[SavedFileName]);
  end;

  if outstream.SaveToFile({expandpath}(SavedFileName))<=0 then
                                       begin
                                       //ShowError(format(rsUnableToWriteFile,[SavedFileName]));
                                       zDebugLn('{EM}'+rsUnableToWriteFile,[SavedFileName]);
                                       result:=false;
                                       end
                                   else
                                       result:=true;
  {if assigned(EndLongProcessProc)then
  EndLongProcessProc;}
  lps.EndLongProcess(lph);

  end;
  outstream.done;
  (*!!!if @SetCurrentDWGProc<>nil
                           then
                               if olddwg<>nil then
                                                  SetCurrentDWGProc(olddwg);*)
  IODXFContext.done;
end;
begin
end.

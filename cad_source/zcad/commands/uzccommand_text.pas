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
{$MODE OBJFPC}{$H+}
unit uzccommand_text;
{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  gzctnrVectorTypes,
  uzgldrawcontext,
  
  uzbtypes,
  uzcdrawings,
  uzeutils,uzcutils,
  URecordDescriptor,typedescriptors,uzeentityfactory,uzegeometry,Varman,
  uzccommandsabstract,uzccmdfloatinsert,uzeentabstracttext,uzeenttext,uzeentmtext,
  uzcinterface,uzcstrconsts,uzccommandsmanager,
  uzeentity,uzcLog,uzctnrvectorstrings,uzestylestexts,uzeconsts,uzcsysvars,uzctextenteditor;
type
{EXPORT+}
  {REGISTEROBJECTTYPE TextInsert_com}
  TextInsert_com= object(FloatInsert_com)
                       pt:PGDBObjText;
                       //procedure Build(Operands:pansichar); virtual;
                       procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
                       procedure CommandEnd(const Context:TZCADCommandContext); virtual;
                       procedure Command(Operands:TCommandOperands); virtual;
                       procedure BuildPrimitives; virtual;
                       procedure Format;virtual;
                       function DoEnd(pdata:Pointer):Boolean;virtual;
  end;
{EXPORT-}
TIMode=(
        TIM_Text(*'Text'*),
        TIM_MText(*'MText'*)
       );
PTTextInsertParams=^TTextInsertParams;
TTextInsertParams=record
                   mode:TIMode;(*'Entity'*)
                   Style:TEnumData;(*'Style'*)
                   justify:TTextJustify;(*'Justify'*)
                   h:Double;(*'Height'*)
                   WidthFactor:Double;(*'Width factor'*)
                   Oblique:Double;(*'Oblique'*)
                   Width:Double;(*'Width'*)
                   LineSpace:Double;(*'Line space factor'*)
                   text:TDXFEntsInternalStringType;(*'Text'*)
                   runtexteditor:Boolean;(*'Run text editor'*)
             end;

implementation
var
  TextInsertParams:TTextInsertParams;
  TextInsert:TextInsert_com;
procedure TextInsert_com.BuildPrimitives;
begin
     if drawings.GetCurrentDWG^.TextStyleTable.GetRealCount>0 then
     begin
     drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
     case TextInsertParams.mode of
           TIM_Text:
           begin
             PRecordDescriptor(TextInsert.commanddata.PTD)^.SetAttrib('Oblique',0,FA_READONLY);
             PRecordDescriptor(TextInsert.commanddata.PTD)^.SetAttrib('WidthFactor',0,FA_READONLY);

             PRecordDescriptor(TextInsert.commanddata.PTD)^.SetAttrib('Width',FA_READONLY,0);
             PRecordDescriptor(TextInsert.commanddata.PTD)^.SetAttrib('LineSpace',FA_READONLY,0);

                pt := Pointer(AllocEnt(GDBTextID));
                pt^.init(@drawings.GetCurrentDWG^.ConstructObjRoot,drawings.GetCurrentDWG^.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,'',nulvertex,2.5,0,1,0,jstl);
                zcSetEntPropFromCurrentDrawingProp(pt);
           end;
           TIM_MText:
           begin
                PRecordDescriptor(TextInsert.commanddata.PTD)^.SetAttrib('Oblique',FA_READONLY,0);
                PRecordDescriptor(TextInsert.commanddata.PTD)^.SetAttrib('WidthFactor',FA_READONLY,0);

                PRecordDescriptor(TextInsert.commanddata.PTD)^.SetAttrib('Width',0,FA_READONLY);
                PRecordDescriptor(TextInsert.commanddata.PTD)^.SetAttrib('LineSpace',0,FA_READONLY);

                pt := Pointer(AllocEnt(GDBMTextID));
                pgdbobjmtext(pt)^.init(@drawings.GetCurrentDWG^.ConstructObjRoot,drawings.GetCurrentDWG^.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,
                                  '',nulvertex,2.5,0,1,0,jstl,10,1);
                zcSetEntPropFromCurrentDrawingProp(pt);
           end;

     end;
     drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.AddPEntity(pt^);
     end;
end;
procedure TextInsert_com.CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
begin
     inherited;
     if drawings.GetCurrentDWG^.TextStyleTable.GetRealCount<1 then
     begin
          ZCMsgCallBackInterface.TextMessage(rscmInDwgTxtStyleNotDeffined,TMWOShowError);
          commandmanager.executecommandend;
     end;
end;
procedure TextInsert_com.CommandEnd(const Context:TZCADCommandContext);
begin

end;

function GetStyleNames(var BDefNames:TZctnrVectorStrings;selname:String):Integer;
var pb:PGDBTextStyle;
    ir:itrec;
    i:Integer;
begin
     result:=-1;
     i:=0;
     selname:=uppercase(selname);
     pb:=drawings.GetCurrentDWG^.TextStyleTable.beginiterate(ir);
     if pb<>nil then
     repeat
           if uppercase(pb^.name)=selname then
                                              result:=i;

           BDefNames.PushBackData(pb^.name);
           pb:=drawings.GetCurrentDWG^.TextStyleTable.iterate(ir);
           inc(i);
     until pb=nil;
end;

procedure TextInsert_com.Command(Operands:TCommandOperands);
var
   s:string;
   i:integer;
begin
       if drawings.GetCurrentDWG^.TextStyleTable.GetRealCount>0 then
     begin
     if TextInsertParams.Style.Selected>=TextInsertParams.Style.Enums.Count then
                                                                                begin
                                                                                     s:=drawings.GetCurrentDWG^.GetCurrentTextStyle^.Name;
                                                                                end
                                                                            else
                                                                                begin
                                                                                     s:=TextInsertParams.Style.Enums.getData(TextInsertParams.Style.Selected);
                                                                                end;
      //TextInsertParams.Style.Enums.Clear;
      TextInsertParams.Style.Enums.free;
      i:=GetStyleNames(TextInsertParams.Style.Enums,s);
      if i<0 then
                 TextInsertParams.Style.Selected:=0;
      ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
      BuildPrimitives;
     drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
     format;
     end;
end;
function TextInsert_com.DoEnd(pdata:Pointer):Boolean;
begin
     result:=false;
     dec(self.mouseclic);
     zcRedrawCurrentDrawing;
     if TextInsertParams.runtexteditor then
                                           RunTextEditor(pdata,drawings.GetCurrentDWG^);
     //redrawoglwnd;
     build('');
end;

procedure TextInsert_com.Format;
var
   DC:TDrawContext;
begin
     if ((pt^.GetObjType=GDBTextID)and(TextInsertParams.mode=TIM_MText))
     or ((pt^.GetObjType=GDBMTextID)and(TextInsertParams.mode=TIM_Text)) then
                                                                        BuildPrimitives;
     pt^.vp.Layer:=drawings.GetCurrentDWG^.GetCurrentLayer;
     pt^.vp.LineWeight:=sysvar.dwg.DWG_CLinew^;
     //pt^.TXTStyleIndex:=drawings.GetCurrentDWG^.TextStyleTable.getMutableData(TextInsertParams.Style.Selected);
     pt^.TXTStyleIndex:=drawings.GetCurrentDWG^.TextStyleTable.FindStyle(pString(TextInsertParams.Style.Enums.getDataMutable(TextInsertParams.Style.Selected))^,false);
     pt^.textprop.size:=TextInsertParams.h;
     pt^.Content:='';
     pt^.Template:=(TextInsertParams.text);

     case TextInsertParams.mode of
     TIM_Text:
              begin
                   pt^.textprop.oblique:=TextInsertParams.Oblique;
                   pt^.textprop.wfactor:=TextInsertParams.WidthFactor;
                   byte(pt^.textprop.justify):=byte(TextInsertParams.justify);
              end;
     TIM_MText:
              begin
                   pgdbobjmtext(pt)^.width:=TextInsertParams.Width;
                   pgdbobjmtext(pt)^.linespace:=TextInsertParams.LineSpace;

                   if TextInsertParams.LineSpace<0 then
                                               pgdbobjmtext(pt)^.linespacef:=(-TextInsertParams.LineSpace*3/5)/TextInsertParams.h
                                           else
                                               pgdbobjmtext(pt)^.linespacef:=TextInsertParams.LineSpace;

                   //linespace := textprop.size * linespacef * 5 / 3;

                   byte(pt^.textprop.justify):=byte(TextInsertParams.justify);
              end;

     end;
     dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
     pt^.FormatEntity(drawings.GetCurrentDWG^,dc);
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  SysUnit^.RegisterType(TypeInfo(PTTextInsertParams));//регистрируем тип данных в зкадном RTTI
  //SysUnit^.RegisterType(TypeInfo(TTextInsertParams));
  SysUnit^.SetTypeDesk(TypeInfo(TTextInsertParams),['mode','Style','justify','h','WidthFactor','Oblique','Width','LineSpace','text','runtexteditor']);//Даем програмные имена параметрам, по идее это должно быть в ртти, но ненашел
  SysUnit^.SetTypeDesk(TypeInfo(TIMode),['TIM_Text','TIM_MText']);//Даем человечьи имена параметрам

  TextInsert.init('Text',0,0);
  TextInsertParams.Style.Enums.init(10);
  TextInsertParams.Style.Selected:=0;
  TextInsertParams.h:=2.5;
  TextInsertParams.Oblique:=0;
  TextInsertParams.WidthFactor:=1;
  TextInsertParams.justify:=uzeentabstracttext.jstl;
  TextInsertParams.text:='text';
  TextInsertParams.runtexteditor:=false;
  TextInsertParams.Width:=100;
  TextInsertParams.LineSpace:=1;
  TextInsert.SetCommandParam(@TextInsertParams,'PTTextInsertParams');
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  TextInsertParams.Style.Enums.done;
end.

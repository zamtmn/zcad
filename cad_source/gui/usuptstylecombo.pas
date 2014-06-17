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

unit usuptstylecombo;
{$INCLUDE def.inc}

interface

uses
  gdbasetypes,usupportgui,StdCtrls,UGDBDescriptor,zcadstrconsts,Controls,Classes,UGDBTextStyleArray,strproc,zcadsysvars,commandline,zcadinterface;

type
  TSupportTStyleCombo = class
                             class procedure DropDownTStyle(Sender:Tobject);
                             class procedure CloseUpTStyle(Sender:Tobject);
                             class procedure FillLTStyle(cb:TCustomComboBox);
                             class procedure DrawItemTStyle(Control: TWinControl; Index: Integer; ARect: TRect;
                                                              State: TOwnerDrawState);
                             class procedure ChangeLType(Sender:Tobject);
  end;

implementation
uses
  mainwindow;
class procedure TSupportTStyleCombo.DropDownTStyle(Sender:Tobject);
var
  i:integer;
  ptt:PGDBTextStyleArray;
  pts:PGDBTextStyle;
begin
  //Correct items count
  ptt:=@gdb.GetCurrentDWG.TextStyleTable;
  SetcomboItemsCount(tcombobox(Sender),ptt.Count);

  //Correct items
  for i:=0 to ptt.Count-1 do
  begin
       pts:=gdb.GetCurrentDWG.TextStyleTable.getelement(i);
       tcombobox(Sender).Items.Objects[i]:=tobject(pts);
  end;
  tcombobox(Sender).ItemIndex:=-1;
end;
class procedure TSupportTStyleCombo.CloseUpTStyle(Sender:Tobject);
var
  i:integer;
begin
     tcombobox(Sender).ItemIndex:=0;
end;
class procedure TSupportTStyleCombo.FillLTStyle(cb:TCustomComboBox);
begin
  cb.items.AddObject('', TObject(0));
end;
class procedure TSupportTStyleCombo.DrawItemTStyle(Control: TWinControl; Index: Integer; ARect: TRect;
                                                     State: TOwnerDrawState);
var
  pts:PGDBTextStyle;
   ll:integer;
   s:string;
begin
    if gdb.GetCurrentDWG=nil then
                                 exit;
    if gdb.GetCurrentDWG.LTypeStyleTable.Count=0 then
                                 exit;
    ComboBoxDrawItem(Control,ARect,State);

    if TComboBox(Control).DroppedDown then
                                          pts:=PGDBTextStyle(tcombobox(Control).items.Objects[Index])
                                      else
                                          pts:=IVars.CTStyle;
    if pts<>nil then
                   begin
                        s:=Tria_AnsiToUtf8(pts^.Name);
                        ll:=0;
                   end
               else
                   begin
                       s:=rsDifferent;
                       ll:=0;
                   end;

    ARect.Left:=ARect.Left+2;
    TComboBox(Control).Canvas.TextRect(ARect,ARect.Left,(ARect.Top+ARect.Bottom-TComboBox(Control).Canvas.TextHeight(s)) div 2,s);
end;
class procedure TSupportTStyleCombo.ChangeLType(Sender:Tobject);
var
   index:Integer;
   CLTSave,pts:PGDBTextStyle;
   mr:integer;
begin
     index:=tcombobox(Sender).ItemIndex;
     pts:=PGDBTextStyle(tcombobox(Sender).items.Objects[index]);
     if pts=nil then
                         exit;


     if gdb.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0
     then
     begin
          SysVar.dwg.DWG_CTStyle^:=pts;
     end
     else
     begin
          CLTSave:=SysVar.dwg.DWG_CTStyle^;
          SysVar.dwg.DWG_CTStyle^:={TSIndex}pts;
          commandmanager.ExecuteCommand('SelObjChangeTstyleToCurrent',gdb.GetCurrentDWG,gdb.GetCurrentOGLWParam);
          SysVar.dwg.DWG_CTStyle^:=CLTSave;
     end;
     if assigned(SetVisuaProplProc) then SetVisuaProplProc;
     //setnormalfocus(nil);
end;


end.
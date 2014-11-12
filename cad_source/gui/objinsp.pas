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

unit Objinsp;
{$INCLUDE def.inc}

interface

uses
  LCLIntf,zcadstrconsts,usupportgui,GDBRoot,UGDBOpenArrayOfUCommands,StdCtrls,strutils,ugdbsimpledrawing,zcadinterface,ucxmenumgr,//umytreenode,
  Themes,
  {$IFDEF LCLGTK2}
  x,xlib,{x11,}{xutil,}
  gtk2,gdk2,{gdk2x,}
  {$ENDIF}
  {$IFDEF WINDOWS}win32proc,{$endif}
  strproc,types,graphics,
  ExtCtrls,Controls,Classes,menus,Forms,lcltype,fileutil,

  gdbasetypes,SysUtils,shared,zcadsysvars,
  gdbase,varmandef,UGDBDrawingdef,
  memman,TypeDescriptors;
const
  alligmentall=2;
  alligmentarrayofarray=64;
  fastEditorOffset={$IFDEF LCLQT}2{$ELSE}2{$ENDIF} ;
  spliterhalfwidth=4;
  subtab=8;
  PlusMinusDetailArray: array[Boolean,Boolean] of TThemedTreeview =
  (
    (ttGlyphClosed,
    ttHotGlyphClosed),
    (ttGlyphOpened,
    ttHotGlyphOpened)
  );
type
  arrindop=record
    currnum,currcount,num,count:GDBInteger;
  end;
  arrayarrindop=array[0..10] of arrindop;
  parrayarrindop=^arrayarrindop;
  TEditorContext=record
                       ppropcurrentedit:PPropertyDeskriptor;
                       UndoStack:PGDBObjOpenArrayOfUCommands;
                       UndoCommand:PTTypedChangeCommand;
                 end;

  TGDBobjinsp=class({TPanel}tform)
    public
    GDBobj:GDBBoolean;
    EDContext:TEditorContext;

    PStoredObj:GDBPointer;
    StoredObjGDBType:PUserTypeDescriptor;
    pStoredContext:GDBPointer;

    pcurrobj,pdefaultobj:GDBPointer;
    currobjgdbtype,defaultobjgdbtype:PUserTypeDescriptor;
    pcurcontext,pdefaultcontext:GDBPointer;
    PEditor:TPropEditor;
    PDA:TPropertyDeskriptorArray;
    namecol:GDBInteger;
    contentheigth:GDBInteger;
    OLDPP:PPropertyDeskriptor;
    OnMousePP:PPropertyDeskriptor;

    MResplit:boolean;

    procedure draw; virtual;
    procedure mypaint(sender:tobject);
    procedure drawprop(PPA:PTPropertyDeskriptorArray; var y,sub:GDBInteger;miny:GDBInteger;arect:trect);
    procedure calctreeh(PPA:PTPropertyDeskriptorArray; var y:GDBInteger);
    function gettreeh:GDBInteger; virtual;
    procedure BeforeInit; virtual;
    procedure _onresize(sender:tobject);virtual;
    procedure updateeditorBounds;virtual;
    procedure buildproplist(exttype:PUserTypeDescriptor; bmode:GDBInteger; var addr:GDBPointer);
    procedure SetCurrentObjDefault;
    procedure ReturnToDefault;
    procedure rebuild;
    procedure Notify(Sender: TObject;Command:TMyNotifyCommand); virtual;
    procedure createpda;
    destructor Destroy; Override;
    procedure createscrollbars;virtual;
    procedure AfterConstruction; override;
    procedure CalcRowHeight;
    procedure EraseBackground(DC: HDC); override;

    procedure FreeEditor;
    procedure StoreAndFreeEditor;
    procedure ClearEDContext;
    procedure AsyncFreeEditorAndSelectNext(Data: PtrInt);
    procedure AsyncFreeEditor(Data: PtrInt);
    function IsMouseOnSpliter(pp:PPropertyDeskriptor; X,Y:Integer):GDBBoolean;

    procedure createeditor(pp:PPropertyDeskriptor);
    function CurrObjIsEntity:boolean;
    function IsEntityInCurrentContext:boolean;

    function IsHeadersEnabled:boolean;
    function HeadersHeight:integer;

    {LCL}
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);override;
    procedure MouseLeave;override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer);override;
    procedure MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);override;
    procedure UpdateObjectInInsp;
    private
    procedure setptr(exttype:PUserTypeDescriptor; addr,context:GDBPointer);
    procedure updateinsp;
    protected
    procedure ScrollbarHandler(ScrollKind: TScrollBarKind; OldPosition: Integer);override;
    public
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: integer); override;
    procedure GetPreferredSize(var PreferredWidth, PreferredHeight: integer;
                                   Raw: boolean = false;
                                   WithThemeSpace: boolean = true); override;
    procedure DoSendBoundsToInterface; override; // called by RealizeBounds
    procedure DoAllAutoSize; override;

    procedure FormHide(Sender: TObject);
  end;

procedure SetGDBObjInsp(exttype:PUserTypeDescriptor; addr,context:GDBPointer);
procedure StoreAndSetGDBObjInsp(exttype:PUserTypeDescriptor; addr,context:GDBPointer);
function ReStoreGDBObjInsp:GDBBoolean;
procedure UpdateObjInsp;
procedure ReturnToDefault;
procedure rebuild;
procedure SetCurrentObjDefault;
function  GetCurrentObj:Pointer;
procedure ClrarIfItIs(addr:GDBPointer);
procedure SetNameColWidth(w:integer);
function GetNameColWidth:integer;
function CreateObjInspInstance:TForm;
function GetPeditor:TComponent;
procedure FreEditor;

var
  GDBobjinsp:TGDBobjinsp;
  typecount:GDBWord;
  proptreeptr:propdeskptr;
  rowh:integer;
  ty:integer;
  DefaultDetails: TThemedElementDetails;

implementation

uses UObjectDescriptor,GDBEntity,UGDBStringArray,log;

function PlusMinusDetail(Collapsed,hot:boolean):TThemedTreeview;
begin
     {$IFDEF WINDOWS}
     if WindowsVersion < wvVista then
                                    hot:=false;
     {$endif}
     result:=PlusMinusDetailArray[Collapsed,hot];
end;
procedure TGDBobjinsp.FormHide(Sender: TObject);
begin
     proptreeptr:=proptreeptr;
end;

procedure TGDBobjinsp.DoAllAutoSize;
begin
     inherited;
end;
procedure TGDBobjinsp.DoSendBoundsToInterface;
begin
     inherited;
end;
procedure TGDBobjinsp.GetPreferredSize(var PreferredWidth, PreferredHeight: integer;
                               Raw: boolean = false;
                               WithThemeSpace: boolean = true);
begin
     inherited;
     //height
     //PreferredWidth:=0;
     //PreferredHeight:=1;
end;
function IsWgiteBackground:boolean;
begin
     if assigned(SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_WhiteBackground)
     then
         result:=SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_WhiteBackground^
     else
         result:=false;
end;

function TGDBobjinsp.IsHeadersEnabled:boolean;
begin
    if assigned(SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowHeaders)
    then
        result:=SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowHeaders^
    else
        result:=true;
end;
function TGDBobjinsp.HeadersHeight:integer;
begin
     if IsHeadersEnabled then
                             result:=rowh
                         else
                             result:=0;
end;
function NeedShowSeparator:boolean;
begin
    if assigned(SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowSeparator) then
       begin
            if assigned(SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_OldStyleDraw) then
               begin
                 if SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_OldStyleDraw^ then
                    result:=false
                 else
                    result:=SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowSeparator^
               end
            else
               result:=SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowSeparator^
       end
    else
       result:=false;
end;
function isOldStyleDraw:boolean;
begin
    if assigned(SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_OldStyleDraw) then
       result:=SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_OldStyleDraw^
    else
       result:=false;
end;
function NeedDrawFasteditor(OnMouseProp:boolean):boolean;
begin
    if assigned(SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowFastEditors) then
    begin
         if SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowFastEditors^ then
         begin
              if assigned(SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowOnlyHotFastEditors) then
              begin
                   if SysVar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_ShowOnlyHotFastEditors^ then
                   result:=OnMouseProp
                   else
                       result:=true;
              end
              else
                  result:=true;
         end
         else
             result:=false;
    end
    else
        result:=true;
end;

procedure TGDBobjinsp.SetBounds(ALeft, ATop, AWidth, AHeight: integer);
begin
     if aheight=41 then
                       aheight:=aheight;
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
end;
function ReStoreGDBObjInsp:GDBBoolean;
begin
     result:=false;
     if assigned(GDBobjinsp)then
     begin
     if (GDBobjinsp.PStoredObj=nil) then
                                    else
                                    begin
                                         GDBobjinsp.setptr(GDBobjinsp.StoredObjGDBType,GDBobjinsp.PStoredObj,GDBobjinsp.pStoredContext);
                                         GDBobjinsp.PStoredObj:=nil;
                                         GDBobjinsp.StoredObjGDBType:=nil;
                                         GDBobjinsp.pStoredContext:=nil;

                                         {GDBobjinsp.pcurrobj:=GDBobjinsp.PStoredObj;
                                         GDBobjinsp.currobjgdbtype:=GDBobjinsp.StoredObjGDBType;
                                         GDBobjinsp.SetGDBObjInsp(exttype:PUserTypeDescriptor; addr:GDBPointer);}
                                         result:=true;
                                    end;
     end;
end;
procedure StoreAndSetGDBObjInsp(exttype:PUserTypeDescriptor; addr,context:GDBPointer);
begin
     if assigned(GDBobjinsp)then
     begin
     if (GDBobjinsp.PStoredObj=nil) then
                             begin
                                  GDBobjinsp.PStoredObj:=GDBobjinsp.pcurrobj;
                                  GDBobjinsp.StoredObjGDBType:=GDBobjinsp.currobjgdbtype;
                                  GDBobjinsp.pStoredContext:=GDBobjinsp.pcurcontext;
                             end;
     GDBobjinsp.setptr(exttype,addr,context);
     end;
end;

procedure SetGDBObjInsp(exttype:PUserTypeDescriptor; addr,context:GDBPointer);
begin
     if assigned(GDBobjinsp)then
                                begin
                                     GDBobjinsp.setptr(exttype,addr,context);
                                end;
end;
procedure UpdateObjInsp;
begin
     if assigned(GDBobjinsp)then
                                begin
                                     GDBobjinsp.updateinsp;
                                end;
end;
procedure ClrarIfItIs(addr:GDBPointer);
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       if GDBobjinsp.pcurrobj=addr then
                                       GDBobjinsp.ReturnToDefault;
                                  end;
end;
procedure SetNameColWidth(w:integer);
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.namecol:=w;
                                  end;
end;
function CreateObjInspInstance:TForm;
begin
     GDBobjinsp:=TGDBObjInsp(TGDBObjInsp.NewInstance);
     result:=GDBobjinsp;
end;
function GetPeditor:TComponent;
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       result:=GDBobjinsp.peditor;
                                  end
                               else
                                   result:=nil;
end;
procedure StoreAndFreeEditor;
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.StoreAndFreeEditor;
                                  end
end;

procedure FreEditor;
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.freeeditor;
                                  end
end;

function GetNameColWidth:integer;
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       result:=GDBobjinsp.namecol;
                                  end
                               else
                                   result:=0;
end;
procedure ReturnToDefault;
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.PStoredObj:=nil;
                                       GDBobjinsp.StoredObjGDBType:=nil;
                                       GDBobjinsp.ReturnToDefault;
                                  end;
end;
procedure SetCurrentObjDefault;
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.SetCurrentObjDefault;
                                  end;
end;
function  GetCurrentObj:Pointer;
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       result:=GDBobjinsp.pcurrobj;
                                  end
                              else
                                  result:=nil;
end;
procedure ReBuild;
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.ReBuild;
                                  end;
end;

procedure TGDBobjinsp.EraseBackground(DC: HDC);
begin
     inherited;
end;
procedure TGDBobjinsp.CalcRowHeight;
begin
  rowh:=21;
  if assigned(sysvar.INTF.INTF_DefaultControlHeight) then
                                                         rowh:=sysvar.INTF.INTF_DefaultControlHeight^;
  if assigned(sysvar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_RowHeight.Enable) then
  if sysvar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_RowHeight.Enable^ then
  if assigned(sysvar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_RowHeight.Value) then
  if sysvar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_RowHeight.Value^>0 then
     rowh:=sysvar.INTF.INTF_OBJINSP_Properties.INTF_ObjInsp_RowHeight.Value^
end;

procedure TGDBobjinsp.AfterConstruction;
begin
     inherited;
     rowh:=21;
     CalcRowHeight;

     onresize:=_onresize;
     onhide:=FormHide;
     onpaint:=mypaint;
     self.DoubleBuffered:=true;
     self.BorderStyle:=bsnone;
     self.BorderWidth:=0;

     pcurrobj:=nil;
     peditor:=nil;
     currobjgdbtype:=nil;
     createpda;
  EDContext.ppropcurrentedit:=nil;

  MResplit:=false;
  namecol:=clientwidth div 2;
end;

procedure TGDBobjinsp.SetCurrentObjDefault;
begin
  pdefaultobj:=pcurrobj;
  defaultobjgdbtype:=currobjgdbtype;
  pdefaultcontext:=pcurcontext;
end;

procedure TGDBobjinsp.ReturnToDefault;
begin
  if assigned(peditor)then
                          begin
                          self.StoreAndFreeEditor;
                          end;
  setptr(defaultobjgdbtype,pdefaultobj,pdefaultcontext);
end;

procedure TGDBobjinsp.createpda;
begin
  pda.init({$IFDEF DEBUGBUILD}'{ED044410-8C08-4113-B2FB-3259017CBF04}',{$ENDIF}100);
end;

destructor TGDBobjinsp.Destroy;
begin
    if peditor<>nil then
    begin
         peditor.Free;
    end;
  inherited;
  pda.cleareraseobj;
  pda.done;
end;

function addindex(pindex:parrayarrindop; n:GDBInteger):GDBBoolean;
begin
  inc(pindex[n].currnum);
  dec(pindex[n].currcount);
  if pindex[n].currcount=0 then
  begin
    pindex[n].currcount:=pindex[n].count;
    pindex[n].currnum:=pindex[n].num;
    if n>0 then
      result:=addindex(pindex,n-1)
    else
      result:=true;
  end
  else
    result:=false;
end;

procedure TGDBobjinsp.buildproplist;
begin
  if exttype<>nil then
  PTUserTypeDescriptor(exttype)^.CreateProperties(PDM_Field,@PDA,'root',field_no_attrib,0,bmode,addr,'','');
end;

procedure TGDBobjinsp.calctreeh;
var
  ppd:PPropertyDeskriptor;
      ir:itrec;
      last:boolean;
begin
  if ppa^.Count=0 then exit;
  ppd:=ppa^.beginiterate(ir);
  if ppd<>nil then
    repeat
      last:=false;
      if (ppd^.IsVisible) then
      begin
        if ppd^.SubNode<>nil
          then
        begin
          y:=y++rowh;
          if not ppd^.Collapsed^ then
            begin
            calctreeh(GDBPointer(ppd.SubNode),y);
            y:=y+rowh;
            last:=true;
            end;
        end
        else
        begin
          y:=y++rowh;
        end;
      end;
      ppd:=ppa^.iterate(ir);
    until ppd=nil;
  if last then
              y:=y-rowh;
end;
procedure drawfasteditor(ppd:PPropertyDeskriptor;canvas:tcanvas;var r:trect);
var
   fer:trect;
   FESize:TSize;
   temp:integer;
begin
     if assigned(ppd.FastEditor.OnGetPrefferedFastEditorSize) then
     begin
           FESize:=ppd.FastEditor.OnGetPrefferedFastEditorSize(ppd^.valueAddres);
           if FESize.cX>0 then
           if (r.Right-r.Left-1)>FESize.cX then
           begin
                fer:=r;
                fer.Left:=fer.Right-FESize.cX-fastEditorOffset;
                fer.Right:=fer.Right-fastEditorOffset;
                if FESize.cy>0 then
                begin
                fer.Top:=fer.Top-3;
                temp:=(fer.Bottom+fer.Top)div 2;
                fer.Top:=temp-FESize.cy div 2;
                fer.Bottom:=fer.Top+FESize.cy;
                end
                else
                begin
                fer.Top:=fer.Top-3;
                end;
                ppd.FastEditor.OnDrawFastEditor(canvas,fer,ppd^.valueAddres,ppd.FastEditorState,r);
                r.Right:=fer.Left;
                ppd.FastEditorDrawed:=true;
           end;
     end;
end;
procedure drawheader(Canvas:tcanvas;ppd:PPropertyDeskriptor;r:trect;name:string;onm:boolean;TextDetails: TThemedElementDetails);
function GetSizeTreeIcon(Minus,hot: Boolean):TSize;
var
  Details: TThemedElementDetails;
begin
  Details := ThemeServices.GetElementDetails(PlusMinusDetail(Minus,hot));
  result := ThemeServices.GetDetailSize(Details);
end;
procedure DrawTreeIcon(X, Y: Integer; Minus, hot: Boolean);
var
  Details: TThemedElementDetails;
  Size: TSize;
begin
  Details := ThemeServices.GetElementDetails(PlusMinusDetail(Minus,hot));
  Size := ThemeServices.GetDetailSize(Details);
  ThemeServices.DrawElement(Canvas.Handle, Details, Rect(X, Y, X + Size.cx, Y + Size.cy), {nil}@r);
end;
var
   Size: TSize;
   temp:integer;
begin
  if not ppd^.Collapsed^ then
                             ppd^.Collapsed^:=ppd^.Collapsed^;
  size:=GetSizeTreeIcon(not ppd^.Collapsed^,onm);
  temp:=(r.bottom-r.top-size.cy)div 3;
  if (r.Right-r.Left)>size.cx then
  DrawTreeIcon({Canvas,}r.left,r.top+temp,not ppd^.Collapsed^,onm);
  inc(r.left,size.cx+1);
  ppd.FastEditorDrawed:=false;
  if NeedDrawFasteditor(onm) then
  if assigned(ppd.FastEditor.OnGetPrefferedFastEditorSize) then
  drawfasteditor(ppd,canvas,r);
  {canvas.Font.Italic:=true;
  if onm then
             begin
             //canvas.Font.Bold:=true;
             canvas.Font.Underline:=true;
             end;}
  if (r.Right-r.Left)>1 then
  ThemeServices.DrawText(Canvas,TextDetails,name,r,DT_END_ELLIPSIS,0);
  {//canvas.TextRect(r,r.Left,r.Top,(name));
  canvas.Font.Italic:=false;
  if onm then
             begin
             //canvas.Font.Bold:=false;
             canvas.Font.Underline:=false;
             end;
  dec(r.left,size.cx+1);}
end;
function drawrect(cnvs:tcanvas;r:trect;active:boolean;onmouse:boolean;readonly:boolean): TThemedElementDetails;
var
   tc:tcolor;
begin
  result:=defaultdetails;
  if (not ThemeServices.ThemesAvailable)or isOldStyleDraw then
  begin
  if onmouse and ThemeServices.ThemesAvailable then
                 result := ThemeServices.GetElementDetails(ttItemHot);
  tc:=cnvs.Brush.Color;
  if active then
                begin
                     cnvs.Brush.Color := clHighlight{clBtnHiLight};
                     cnvs.Pen.Style:=psDot;
                     inflaterect(r,0,-1);
                     cnvs.Rectangle(r);
                     cnvs.Pen.Style:=psSolid;
                end
            else
                begin
                     if IsWgiteBackground then
                                              cnvs.Brush.Color := clWindow
                                          else
                                              cnvs.Brush.Color := clBtnFace;
                     if isOldStyleDraw then
                     cnvs.Rectangle(r);
                end;
  cnvs.Brush.Color:=tc;
  end
  else
  begin
       if active then
                     begin
                     result := ThemeServices.GetElementDetails(ttItemSelected);
                     ThemeServices.DrawElement(cnvs.Handle, result, r, nil);
                     end
                 else
                     if readonly then
                     begin
                     if isOldStyleDraw then
                     begin
                       result := {ThemeServices.GetElementDetails(ttItemNormal)}DefaultDetails;
                       ThemeServices.DrawElement(cnvs.Handle, result, r, nil);
                     end;
                     result := ThemeServices.GetElementDetails(ttItemDisabled);
                     end
                     else
                     if onmouse then
                     begin
                     result := ThemeServices.GetElementDetails(ttItemHot);
                     {$IFDEF WINDOWS}
                     if ((WindowsVersion >= wvVista)and ThemeServices.ThemesEnabled) then
                                                                                         ThemeServices.DrawElement(cnvs.Handle, result, r, nil)
                                                                                     else
                                                                                         if isOldStyleDraw then
                                                                                         ThemeServices.DrawElement(cnvs.Handle, ThemeServices.GetElementDetails(ttItemNormal), r, nil)
                     {$ENDIF}
                     {$IFNDEF WINDOWS}
                     ThemeServices.DrawElement(cnvs.Handle, result, r, nil);
                     {$ENDIF}
                     end
                     else
                     begin
                     {if assigned(sysvar.INTF.INTF_ShowLinesInObjInsp) then
                     if sysvar.INTF.INTF_ShowLinesInObjInsp^ then}
                     if isOldStyleDraw then
                     begin
                     result := {ThemeServices.GetElementDetails(ttItemNormal)}DefaultDetails;
                     ThemeServices.DrawElement(cnvs.Handle, result, r, nil);
                     end;
                     end;
                     {$IFDEF WINDOWS}
                     if (WindowsVersion < wvVista)or(not ThemeServices.ThemesEnabled) then
                     {$ENDIF}
                     if isOldStyleDraw then
                     begin
                        cnvs.Line(r.Left,r.Top,r.Right,r.Top);
                        cnvs.Line(r.Right,r.Top,r.Right,r.Bottom);
                        cnvs.Line(r.Right,r.Bottom,r.Left,r.Bottom);
                        cnvs.Line(r.Left,r.Bottom,r.Left,r.Top);
                     end;
  end;
end;
procedure drawstring(cnvs:tcanvas;r:trect;L,T:integer;s:string;TextDetails: TThemedElementDetails);
{const
  maxsize=200;
var
   s2:string;}
begin
     if (r.Right-r.Left)>1 then
     ThemeServices.DrawText(cnvs,TextDetails,s,r,DT_END_ELLIPSIS,0)
     {if length(s)<maxsize then
                          //cnvs.TextRect(r,L,T,s)
                          ThemeServices.DrawText(cnvs,TextDetails,s,r,DT_END_ELLIPSIS,0)
                      else
                          begin
                               s2:=copy(s,1,maxsize)+'...';
                               //cnvs.TextRect(r,L,T,s2);
                               ThemeServices.DrawText(cnvs,TextDetails,s2,r,DT_END_ELLIPSIS,0);
                          end;}
end;
procedure drawvalue(ppd:PPropertyDeskriptor;canvas:tcanvas;fulldraw:boolean;TextDetails: TThemedElementDetails; onm:boolean);
var
   r:trect;
   tempcolor:TColor;
begin
     if (ppd^.Attr and FA_HIDDEN_IN_OBJ_INSP)<>0 then
     begin
           canvas.Font.Italic:=true;
     end;
  r:=ppd.rect;
  if fulldraw then
  drawrect(canvas,r,false,false,false);
  r.Top:=r.Top+3;
  r.Left:=r.Left+3;
  r.Right:=r.Right-1;
  if (ppd^.Attr and FA_READONLY)<>0 then
  begin
    tempcolor:=canvas.Font.Color;
    //canvas.Font.Color:=clGrayText;
    if fulldraw then
    if (assigned(ppd.Decorators.OnDrawProperty) and(ppd^.valueAddres<>nil)) then
                                       ppd.Decorators.OnDrawProperty(canvas,r,ppd^.valueAddres)
                                   else
                                       drawstring(canvas,r,r.Left,r.Top,(ppd^.value),DefaultDetails);
    canvas.Font.Color:=tempcolor;
  end
  else
    begin
         ppd.FastEditorDrawed:=false;
         if NeedDrawFasteditor(onm) then
         drawfasteditor(ppd,canvas,r);
    if fulldraw then
    if (assigned(ppd.Decorators.OnDrawProperty) and(ppd^.valueAddres<>nil)) then
                                                   ppd.Decorators.OnDrawProperty(canvas,r,ppd^.valueAddres)
                                               else
                                                   drawstring(canvas,r,r.Left,r.Top,(ppd^.value),DefaultDetails);
    end;

if (ppd^.Attr and FA_HIDDEN_IN_OBJ_INSP)<>0 then
begin
      canvas.Font.Italic:=false;
end;

end;

procedure TGDBobjinsp.drawprop(PPA:PTPropertyDeskriptorArray; var y,sub:GDBInteger;miny:GDBInteger;arect:TRect);
var
  s:GDBString;
  ppd:PPropertyDeskriptor;
  r:trect;
  tempcolor:TColor;
  ir:itrec;
  visible:boolean;
  OnMouseProp:boolean;
  TextDetails: TThemedElementDetails;
  TextStyle: TTextStyle;

begin
  ppd:=ppa^.beginiterate(ir);
  if ppd<>nil then
    repeat
      if (ppd^.IsVisible) then
      begin
        OnMouseProp:=(ppd=onmousepp);
        r.Left:=arect.Left+2+subtab*sub{arect.Left};
        r.Top:=y;
        if NeedShowSeparator then
                                 r.Right:=namecol-spliterhalfwidth
                             else
                                 r.Right:=namecol;
        r.Bottom:=y+rowh+1;
         if miny<=r.Bottom then
                                                 visible:=true
                                             else
                                                 visible:=false;
        begin
        if ppd^.SubNode<>nil then
                                  begin
                                     if visible then
                                     begin
                                    s:=ppd^.Name;
                                    if not NeedShowSeparator then
                                                             r.Right:=arect.Right-1;
                                    TextDetails:=drawrect(canvas,r,false,OnMouseProp,(ppd^.Attr and FA_READONLY)<>0);
                                    r.Left:={r.Left+3}arect.Left+5+subtab*sub;
                                    r.Top:=r.Top+3;
                                    if (ppd^.Attr and FA_READONLY)<>0 then
                                                                          begin
                                                                            tempcolor:=canvas.Font.Color;
                                                                            canvas.Font.Color:=clGrayText;

                                                                            drawheader(canvas,ppd,r,s,OnMouseProp,TextDetails);

                                                                            canvas.Font.Color:=tempcolor;
                                                                          end
                                                                      else
                                                                          begin
                                                                            drawheader(canvas,ppd,r,s,OnMouseProp,TextDetails);
                                                                          end;
                                    ppd.rect:=r;
                                    end;
                                    inc(sub);
                                    y:=y+rowh;
                                    if not ppd^.Collapsed^ then
                                      drawprop(GDBPointer(ppd.SubNode),y,sub,miny,arect);
                                    dec(sub);
                                  end
        else
        begin
          if visible then
          begin
          TextDetails:=drawrect(canvas,r,(ppd=EDContext.ppropcurrentedit),OnMouseProp,(ppd^.Attr and FA_READONLY)<>0);

          if (ppd^.Attr and FA_HIDDEN_IN_OBJ_INSP)<>0 then
          begin
                canvas.Font.Italic:=true;
          end;
          r.Left:=r.Left+2;
          r.Top:=r.Top+3;
          if ((ppd^.Attr and FA_READONLY)<>0)or((ppd^.Attr and FA_HIDDEN_IN_OBJ_INSP)<>0) then
          begin
            tempcolor:=canvas.Font.Color;
            TextStyle:=canvas.TextStyle;
            TextStyle.EndEllipsis:=true;
            TextStyle.WordBreak:=false;
            canvas.Font.Color:=clGrayText;
            //DrawText(canvas.Handle, @ppd^.Name[1],length(ppd^.Name),R,DT_END_ELLIPSIS);
            if (r.Right-r.Left)>1 then
            canvas.TextRect(r,r.Left,r.Top,ppd^.Name,TextStyle);
            canvas.Font.Color:=tempcolor;
          end
          else
              begin
                   {if OnMouseProp then
                                      begin
                                      //canvas.Font.bold:=true;
                                      canvas.Font.underline:=true;
                                      end;
                   if (ppd=EDContext.ppropcurrentedit) then
                                      begin
                                           tempcolor:=canvas.Font.Color;
                                           canvas.Font.Color:=clHighlightText;
                                      end;}
                   //canvas.TextRect(r,r.Left,r.Top,(ppd^.Name));
                   if (r.Right-r.Left)>1 then
                   ThemeServices.DrawText(Canvas,TextDetails,ppd^.Name,r,DT_END_ELLIPSIS,0);
                   {if OnMouseProp then
                                      begin
                                      //canvas.Font.bold:=false;
                                      canvas.Font.underline:=false;
                                      end;
                   if (ppd=EDContext.ppropcurrentedit) then
                                      begin
                                           canvas.Font.Color:=tempcolor;
                                      end;}
              end;
          r.Top:=r.Top-3;
          if NeedShowSeparator then
                                   r.Left:=r.Right-1+spliterhalfwidth
                               else
                                   r.Left:=r.Right-1;
          r.Right:=arect.Right-1;

          ppd.rect:=r;
          drawvalue(ppd,canvas,true,TextDetails,onmouseprop);

          {if (ppd^.Attr and FA_HIDDEN_IN_OBJ_INSP)<>0 then
          begin
                canvas.Font.Italic:=false;
          end;}
          end;

          y:=y++rowh;
        end;
      end;
      end;
      ppd:=ppa^.iterate(ir);
      if self.VertScrollBar.Position+self.ClientHeight<=(y) then
                                                                       system.break;
    until ppd=nil;

    y:=y+rowh;
end;

function TGDBobjinsp.gettreeh;
begin
  result:=0;
  calctreeh(@pda,result);
end;
procedure TGDBobjinsp.ScrollbarHandler(ScrollKind: TScrollBarKind; OldPosition: Integer);
begin
    if peditor<>nil then
    begin
       if (EDContext.ppropcurrentedit.rect.Top<HeadersHeight+VertScrollBar.ScrollPos-1)
       or (EDContext.ppropcurrentedit.rect.Top>clientheight+VertScrollBar.ScrollPos-1)then
       begin
          Application.QueueAsyncCall(AsyncFreeEditor,0);
          peditor.geteditor.Hide;
       end;
    end;
     ty:=OldPosition;
     invalidate;
     inherited;
     ty:=VertScrollBar.ScrollPos;
end;
procedure TGDBobjinsp.mypaint;
begin
     //inherited;
     draw;
end;
procedure TGDBobjinsp.draw;
var
  y:GDBInteger;
  sub:GDBInteger;
  arect,hrect:trect;
  tc:tcolor;
  {ts:TTextStyle;}
begin
CalcRowHeight;
ARect := GetClientRect;
InflateRect(ARect, -BorderWidth, -BorderWidth);
ARect.Top:=ARect.Top+VertScrollBar.ScrollPos;
ARect.Bottom:=ARect.Bottom+VertScrollBar.ScrollPos;
{$IFDEF WINDOWS}
if WindowsVersion < wvVista then
                                DefaultDetails := ThemeServices.GetElementDetails(tbPushButtonNormal)
                            else
                                DefaultDetails := ThemeServices.GetElementDetails(tmPopupCheckBackgroundDisabled){trChevronVertHot}{ttbThumbDisabled}{tlListViewRoot};
{$endif}
{$IFDEF LCLGTK2}DefaultDetails := ThemeServices.GetElementDetails(ttbDropDownButtonPressed){$endif}
{$IFDEF LCLQT}DefaultDetails := ThemeServices.GetElementDetails({ttpane}thHeaderDontCare){$endif};
if IsWgiteBackground then
                         Canvas.FillRect(ARect)
                     else
                         begin
                              if isOldStyleDraw then
                              begin
                                  tc:=Canvas.Brush.Color;
                                  Canvas.Brush.Color:=clBtnFace;
                                  Canvas.FillRect(ARect);
                                  Canvas.Brush.Color:=tc;
                              end
                              else
                                  ThemeServices.DrawElement(Canvas.Handle, DefaultDetails, ARect, nil);
                         end;

{ts:=canvas.TextStyle;
ts.Alignment:=taCenter;
ts.Layout:=tlCenter;}

hrect:=ARect;
{$IFDEF WINDOWS}
if WindowsVersion>=wvVista then
{$endif}
InflateRect(hrect, -1, -1);


y:=HeadersHeight+BorderWidth;
sub:=0;
drawprop(@pda,y,sub,hrect.Top+HeadersHeight+1,{arect}hrect);

hrect.Bottom:=hrect.Top+HeadersHeight-1{+1};
{$IFDEF WINDOWS}hrect.Top:=hrect.Top;{$ENDIF}
{$IFNDEF WINDOWS}hrect.Top:=hrect.Top+2;{$ENDIF}

if IsHeadersEnabled then
begin
    hrect.Left:=hrect.Left+2;
    hrect.Right:=namecol;

    DefaultDetails := ThemeServices.GetElementDetails(thHeaderItemNormal);
    ThemeServices.DrawElement(Canvas.Handle, DefaultDetails, hrect, nil);
    ThemeServices.DrawText(Canvas,DefaultDetails,rsProperty,hrect,DT_END_ELLIPSIS or DT_CENTER or DT_VCENTER,0);

    DefaultDetails := ThemeServices.GetElementDetails(thHeaderItemRightNormal);
    hrect.Left:=hrect.right;
    {$IFDEF WINDOWS}hrect.right:=ARect.Right-1;{$ENDIF}
    {$IFNDEF WINDOWS}hrect.right:=ARect.Right-2;{$ENDIF}
    ThemeServices.DrawElement(Canvas.Handle, DefaultDetails, hrect, nil);
    ThemeServices.DrawText(Canvas,DefaultDetails,rsValue,hrect,DT_END_ELLIPSIS or DT_CENTER or DT_VCENTER,0);
end;
if NeedShowSeparator then
begin
     hrect.Left:=namecol-2;
     hrect.right:=namecol+{$IFNDEF WINDOWS}2{$ENDIF}{$IFDEF WINDOWS}1{$ENDIF};
     hrect.Top:= hrect.Bottom;
     hrect.Bottom:=contentheigth+HeadersHeight;
     if hrect.Bottom>ARect.Bottom then
                                      hrect.Bottom:=ARect.Bottom{height};
     if ThemeServices.ThemesEnabled then
     begin
          {$IFNDEF WINDOWS}DefaultDetails := ThemeServices.GetElementDetails(ttbSeparatorNormal);{$ENDIF}
          {$IFDEF WINDOWS}
          if WindowsVersion < wvVista then
                                          DefaultDetails := ThemeServices.GetElementDetails(ttbSeparatorNormal)
                                      else
                                          DefaultDetails := ThemeServices.GetElementDetails(tsPane);
          {$ENDIF}
          ThemeServices.DrawElement(Canvas.Handle, DefaultDetails, hrect, nil);
     end
     else
     begin
          hrect.Left:=(hrect.Left+hrect.Right)div 2;
          tc:=Canvas.Pen.Color;
          Canvas.Pen.Color:=cl3DDkShadow;
          canvas.Line(hrect.Left,hrect.Top,hrect.Left,hrect.Bottom);
          Canvas.Pen.Color:=tc;
     end;
end;
end;
function findnext(psubtree:PTPropertyDeskriptorArray;current:PPropertyDeskriptor):PPropertyDeskriptor;
var
  curr:PPropertyDeskriptor;
      ir:itrec;
begin
  result:=nil;
  curr:=psubtree^.beginiterate(ir);
  if curr<>nil then
    repeat
      if curr^.IsVisible then
      begin
        if curr=current then
        begin
          result:=psubtree^.iterate(ir);
          if result<>nil then
           if result^.SubNode<>nil then
              result:=nil;
          exit;
        end;
        if (curr^.SubNode<>nil)and(not curr^.Collapsed^) then result:=findnext(GDBPointer(curr^.SubNode),current);
        if result<>nil then exit;
      end;
      curr:=psubtree^.iterate(ir);
    until curr=nil;
end;

function mousetoprop(psubtree:PTPropertyDeskriptorArray; mx,my:GDBInteger; var y:GDBInteger):PPropertyDeskriptor;
var
  curr:PPropertyDeskriptor;
  dy:integer;
  ir:itrec;
begin
  result:=nil;
  if my<0 then exit;
  curr:=psubtree^.beginiterate(ir);
  if curr<>nil then
    repeat
      if curr^.IsVisible then
      begin
        dy:=my-y;
        if (dy<rowh)and(dy>0) then
        begin
          result:=curr;
          exit;
        end;
        inc(y,rowh);
        if (curr^.SubNode<>nil)and(not curr^.Collapsed^) then result:=mousetoprop(GDBPointer(curr^.SubNode),mx,my,y);
        if result<>nil then exit;
      end;
      curr:=psubtree^.iterate(ir);
    until curr=nil;
    y:=y+rowh;
end;
procedure TGDBobjinsp.ClearEDContext;
begin
     EDContext.ppropcurrentedit:=nil;
     EDContext.UndoCommand:=0;
     EDContext.UndoStack:=nil;
end;

procedure TGDBobjinsp.FreeEditor;
begin
     if EDContext.UndoCommand<>nil then
                                       EDContext.UndoStack.KillLastCommand;
     ClearEDContext;
     if peditor<>nil then
     begin
           peditor.geteditor.OnExit:=nil;
           peditor.geteditor.Hide;
           peditor.Destroy;
           peditor:=nil;
     end;
     freeandnil(peditor);
     invalidate;
     if assigned(shared.cmdedit) then
     if shared.cmdedit.IsVisible then
                                     shared.cmdedit.SetFocus;
end;
procedure TGDBobjinsp.StoreAndFreeEditor;
begin
    if peditor<>nil then
                      begin
                           peditor.EditingDone2(peditor.geteditor);
                           freeeditor;
                      end;
end;
procedure TGDBobjinsp.AsyncFreeEditorAndSelectNext;
var
      next:PPropertyDeskriptor;
begin
     next:=findnext(@pda,pointer(Data));
     freeeditor;
     if next<>nil then
     createeditor(next);
end;
procedure TGDBobjinsp.AsyncFreeEditor;
begin
     freeeditor;
end;

procedure TGDBobjinsp.Notify;
var
   pld:GDBPointer;
   saveppropcurrentedit:PPropertyDeskriptor;
begin
  if sender=peditor then
  begin
    saveppropcurrentedit:=EDContext.ppropcurrentedit;
    if pcurcontext<>nil then
    begin
         PTDrawingDef(pcurcontext).ChangeStampt(true);
    end;

    if EDContext.UndoCommand<>nil then
                                      begin
                                           if peditor.changed then
                                                                  EDContext.UndoCommand.ComitFromObj
                                                              else
                                                                  EDContext.UndoStack.KillLastCommand;
                                           ClearEDContext;
                                      end;

    pld:=peditor.PInstance;

    if (Command=TMNC_RunFastEditor) then
                                        EDContext.ppropcurrentedit.FastEditor.OnRunFastEditor(pld);
    if peditor.changed then
                           UpdateObjectInInsp;
   if (Command=TMNC_RunFastEditor)or(Command=TMNC_EditingDoneLostFocus) then
                                      begin
                                           Application.QueueAsyncCall(AsyncFreeEditor,0);
                                      end;
   if (Command=TMNC_EditingDoneEnterKey) then
                                      Application.QueueAsyncCall(AsyncFreeEditorAndSelectNext,ptruint(saveppropcurrentedit));
  end;
end;
procedure TGDBobjinsp.UpdateObjectInInsp;
begin
  if GDBobj then
                begin
                     if EDContext.ppropcurrentedit<>nil then
                     begin
                     if EDContext.ppropcurrentedit^.mode=PDM_Property then
                                                             begin
                                                               PObjectDescriptor(currobjgdbtype)^.SimpleRunMetodWithArg(EDContext.ppropcurrentedit^.w,pcurrobj,EDContext.ppropcurrentedit^.valueAddres);
                                                             end;
                    end;
                    if CurrObjIsEntity then
                                           begin
                                               PGDBObjEntity(pcurrobj)^.FormatEntity(PTDrawingDef(pcurcontext)^);
                                               if IsEntityInCurrentContext
                                               then
                                                   PGDBObjEntity(pcurrobj).YouChanged(PTDrawingDef(pcurcontext)^)
                                               else
                                                   PGDBObjRoot(PTDrawingDef(pcurcontext)^.GetCurrentRootSimple)^.FormatAfterEdit(PTDrawingDef(pcurcontext)^);
                                           end
                                       else
                                        begin
                                           PGDBaseObject(pcurrobj)^.FormatAfterFielfmod(EDContext.ppropcurrentedit^.valueAddres,self.currobjgdbtype);
                                        end;

                end;
  if assigned(resetoglwndproc) then resetoglwndproc;
  if assigned(redrawoglwndproc) then redrawoglwndproc;
  self.updateinsp;
  if assigned(UpdateVisibleProc) then UpdateVisibleProc;
end;
procedure TGDBobjinsp.createscrollbars;
var
   changed:boolean;
   ch:integer;
begin
     //ебаный скролинг работает везде по разному, или я туплю... переписывать надо эту хрень
     ch:=contentheigth+HeadersHeight;
     if (VertScrollBar.Range=ch)or(VertScrollBar.Position=0) then
                                              changed:=false
                                          else
                                              changed:=true;
     self.VertScrollBar.Range:=ch;
     self.VertScrollBar.page:=height;
     self.VertScrollBar.Tracking:=true;
     self.VertScrollBar.Smooth:=true;
     if ch<height  then
                                 begin
                                      {$IFNDEF LCLQt}
                                      ScrollBy(0,-VertScrollBar.Position);
                                      {$ENDIF}
                                      VertScrollBar.Position:=0;
                                      self.VertScrollBar.page:=height;
                                      self.VertScrollBar.Range:=height;
                                      self.VertScrollBar.Tracking:=false;
                                      self.VertScrollBar.Smooth:=false;
                                      UpdateScrollbars;
                                 end;
     //Нихуя не понял нахуя это сделано... пока уберу
     //{$IFNDEF LCLWIN32}
     //if ((VertScrollBar.Position>0) and (VertScrollBar.Position<contentheigth-height))or changed then
     //begin
     //VertScrollBar.Position:=VertScrollBar.Position-1;
     //VertScrollBar.Position:=VertScrollBar.Position+1;
     //end;
     //{$ENDIF}
     UpdateScrollbars;
end;
function TGDBobjinsp.IsMouseOnSpliter(pp:PPropertyDeskriptor; X,Y:Integer):GDBBoolean;
var
   my:integer;
   canresplit:boolean;
begin
  result:=false;
  my:=y-self.VertScrollBar.Position;
  if IsHeadersEnabled then
  begin
  if (my>0)and(my<HeadersHeight) then
                                     canresplit:=true
                                 else
                                     canresplit:=false;
  end
     else
         canresplit:=true;

  if canresplit then
  if (abs(x-namecol)<spliterhalfwidth) then
                                           result:=true;
end;
procedure TGDBobjinsp.MouseLeave;
begin
     if OnMousePP<>nil then
                           begin
                                OnMousePP.FastEditorState:=TFES_Default;
                                OnMousePP:=nil;
                                invalidate;
                           end;
     inherited;
end;

procedure TGDBobjinsp.MouseMove(Shift: TShiftState; X, Y: Integer);
//procedure TGDBobjinsp.Pre_MouseMove(fwkeys:longint; x,y:GDBSmallInt; var r:HandledMsg);
var
  my:GDBInteger;
  pp:PPropertyDeskriptor;
//  tb:GDBBoolean;
//  pb:PGDBBoolean;
  tp:pointer;
  tempstr:gdbstring;
  FESize:TSize;
  needredraw:boolean;
begin
    needredraw:=false;
    if mresplit then
                  begin
                       if namecol<subtab then
                                             begin
                                                  if x>namecol then namecol:=x;
                                             end
                  else if namecol>clientwidth-subtab then
                                                         begin
                                                              if x<namecol then namecol:=x;
                                                         end
                  else namecol:=x;
                       repaint;
                       updateeditorBounds;
                       exit;
                  end;
  y:=y+VertScrollBar.scrollpos-self.BorderWidth;
  //application.HintPause:=1;
  //application.HintShortPause:=10;
  my:=HeadersHeight;
  pp:=mousetoprop(@pda,x,y,my);
  if OnMousePP<>pp then
                       begin
                            needredraw:=true;
                            if OnMousePP<>nil then
                                                  OnMousePP.FastEditorState:=TFES_Default;
                            OnMousePP:=pp;
                       end;
  if IsMouseOnSpliter(pp,X,Y) then
                                self.Cursor:=crHSplit
                            else
                                self.Cursor:=crDefault;

  if (pp=nil)or(EDContext.ppropcurrentedit=pp) then
  begin
        self.Hint:='';
        self.ShowHint:=false;
       oldpp:=pp;
       if needredraw then
                    invalidate;
       exit;
  end;

  if assigned(pp.FastEditor.OnGetPrefferedFastEditorSize) then
  begin
  fesize:=pp.FastEditor.OnGetPrefferedFastEditorSize(pp.valueAddres);
  if (fesize.cx>0)and((pp.rect.Right-x-fastEditorOffset-1)<=fesize.cx) then
                                                                           begin
                                                                                if ssLeft in Shift then
                                                                                                       pp.FastEditorState:=TFES_Pressed
                                                                                                   else
                                                                                                       pp.FastEditorState:=TFES_Hot
                                                                           end
                                                                       else
                                                                           pp.FastEditorState:=TFES_Default;

  //drawvalue(pp,canvas,false);
  needredraw:=true;
  end;

  if oldpp<>pp then
  begin
       if oldpp<>nil then
                         begin
                         oldpp.FastEditorState:=TFES_Default;
                         //drawvalue(oldpp,canvas,false);
                         needredraw:=true;
                         end;
(*  TI.cbSize := SizeOf(TOOLINFO);
  TI.uFlags := TTF_SUBCLASS;
  TI.uId := 0;
  TI.hwnd := Handle;
  TI.lpszText:=nil;
  SendMessage(MainFormN.hToolTip, {TTM_GETTOOLINFO}TTM_DELTOOL, 0, LPARAM(@ti));

  TI.cbSize := SizeOf(TOOLINFO);
  TI.uFlags := TTF_SUBCLASS;
  TI.uId := 0;
  TI.hwnd := Handle;
  tempstr:=pp^.Name;
  if pp^.ValKey<>'' then
                       tempstr:=tempstr+'   '+pp^.ValKey+':'+pp^.ValType;
  if pp^.Value<>'' then
                       tempstr:=tempstr+':='+pp^.Value;
  TI.lpszText := @tempstr[1];
  TI.Rect.Left:=pp^.x1;
  TI.Rect.Top:=pp^.y1;
  TI.Rect.Right:=pp^.x2;
  TI.Rect.Bottom:=pp^.y2;
  Windows.GetClientRect(Handle, TI.Rect);*)
    Application.CancelHint;
    tempstr:=pp^.Name;
    if pp^.ValKey<>'' then
                         tempstr:=tempstr+'   '+pp^.ValKey+':'+pp^.ValType;
    if pp^.Value<>'' then
                         tempstr:=tempstr+':='+pp^.Value;
    tempstr:=ReplaceStr(tempstr,'|',';');
  self.Hint:=tempstr;
  self.ShowHint:=true;

  //SendMessage(MainFormN.hToolTip, TTM_ADDTOOL, 0, LPARAM(@ti));
  end
  else
  Application.ActivateHint(ClientToScreen(Point(X, Y)));


  if needredraw then
                    invalidate;

  oldpp:=pp;
  if (pp^.Attr and FA_READONLY)<>0 then exit;

  exit;

  if pp^.PTypeManager<>nil then
  begin
    if peditor<>nil then
    begin
      tp:=pcurrobj;
      GDBobjinsp.buildproplist(currobjgdbtype,property_correct,tp);
      //-----------------------------------------------------------------peditor^.done;
      //-----------------------------------------------------------------gdbfreemem(pointer(peditor));
      EDContext.ppropcurrentedit:=pp;
    end;
    PEditor:=pp^.PTypeManager^.CreateEditor(@self,pp.rect,pp^.valueAddres,nil,false).Editor;
    if PEditor<>nil then
    begin
      //-----------------------------------------------------------------PEditor^.show;
    end;
  end;
end;
//procedure TGDBobjinsp.pre_mousedown;
procedure TGDBobjinsp.MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);
var
  pp:PPropertyDeskriptor;
  my:GDBInteger;
  FESize:TSize;
begin
     inherited;
     if (button=mbLeft)
    and (mresplit=true) then
                                    begin
                                    mresplit:=false;
                                    exit;
                                    end;
     if peditor<>nil then
     if peditor.geteditor.Visible=false then
                                            begin
                                                 peditor.geteditor.Visible:=true;
                                                 peditor.geteditor.setfocus;
                                                 if  peditor.geteditor is  TComboBox then
                                                 if  (peditor.geteditor as  TComboBox).ReadOnly then
                                                 TComboBox(peditor.geteditor).DroppedDown:=true;//автооткрытие комбика мещает вводу, открываем только те что без возможности ввода значений
                                                 exit;
                                            end;
     if (button=mbLeft) then
                            begin
                                 y:=y+VertScrollBar.scrollpos-self.BorderWidth;
                                 my:=HeadersHeight;
                                 pp:=mousetoprop(@pda,x,y,my);
                                 if pp=nil then
                                               exit;
                                 if assigned(pp.FastEditor.OnGetPrefferedFastEditorSize) then
                                 begin
                                 fesize:=pp.FastEditor.OnGetPrefferedFastEditorSize(pp.valueAddres);
                                 if (fesize.cx>0)and((pp.rect.Right-x-fastEditorOffset-1)<=fesize.cx) then
                                 if pp.FastEditorState=TFES_Pressed then
                                                                                      begin
                                                                                           pp.FastEditorState:=TFES_Default;
                                                                                           if assigned(pp.FastEditor.OnRunFastEditor)then
                                                                                           begin
                                                                                           freeeditor;
                                                                                           EDContext.ppropcurrentedit:=pp;
                                                                                           //pp.FastEditor.OnRunFastEditor(pp.valueAddres)
                                                                                           if pp.FastEditor.UndoInsideFastEditor then
                                                                                                                                     pp.FastEditor.OnRunFastEditor(pp.valueAddres)
                                                                                                                                 else
                                                                                                                                     begin
                                                                                                                                     if CurrObjIsEntity then
                                                                                                                                     begin
                                                                                                                                     EDContext.UndoStack:=GetUndoStack;
                                                                                                                                     EDContext.UndoCommand:=EDContext.UndoStack.PushCreateTTypedChangeCommand(pp^.valueAddres,pp^.PTypeManager);
                                                                                                                                     EDContext.UndoCommand.PEntity:=pcurrobj;

                                                                                                                                     pp.FastEditor.OnRunFastEditor(pp.valueAddres);
                                                                                                                                     EDContext.UndoCommand.ComitFromObj;

                                                                                                                                     EDContext.UndoStack:=nil;
                                                                                                                                     EDContext.UndoCommand:=nil;
                                                                                                                                     end
                                                                                                                                     else
                                                                                                                                         begin
                                                                                                                                         pp.FastEditor.OnRunFastEditor(pp.valueAddres);
                                                                                                                                         end;
                                                                                                                                     end;
                                                                                           end;
                                                                                           UpdateObjectInInsp;
                                                                                           EDContext.ppropcurrentedit:=nil;
                                                                                           invalidate;
                                                                                      end
                            end;
                            end;

end;
function TGDBobjinsp.CurrObjIsEntity;
begin
result:=false;
            if GDBobj then
            if PGDBaseObject(pcurrobj)^.IsEntity then
            //if PGDBObjEntity(pcurrobj).bp.ListPos.Owner=PTDrawingDef(pcurcontext)^.GetCurrentRootSimple then
                                                     result:=true;
end;
function TGDBobjinsp.IsEntityInCurrentContext;
begin
     if PGDBObjEntity(pcurrobj).bp.ListPos.Owner=PTDrawingDef(pcurcontext)^.GetCurrentRootSimple
     then
         result:=true
    else
         result:=false;
end;

procedure TGDBobjinsp.createeditor(pp:PPropertyDeskriptor);
var
  //my:GDBInteger;

  //pedipor:pzbasic;
//  tb:GDBBoolean;
//  pb:PGDBBoolean;
  tp:pointer;
  pobj:pGDBObjEntity;
  pv:pvardesk;
  vv:gdbstring;
  vsa:GDBGDBStringArray;
  ir:itrec;
  TED:TEditorDesc;
  editorcontrol:TWinControl;
  tr:TRect;
begin
     if pp^.SubNode<>nil then
     begin
       StoreAndFreeEditor;
       if pGDBByte(pp^.Collapsed)^<>0 then pGDBByte(pp^.Collapsed)^:=1;
                                           pp^.Collapsed^:=not(pp^.Collapsed^);
       updateinsp;
       //draw;
       //exit;
     end
   else
   begin
      if (pp^.Attr and FA_READONLY)<>0 then exit;
      if pp^.PTypeManager<>nil then
     begin
       if peditor<>nil then
       begin
         tp:=pcurrobj;
         GDBobjinsp.buildproplist(currobjgdbtype,property_correct,tp);
         StoreAndFreeEditor;
       end;
       vsa.init(50);
       if (pp^.valkey<>'')and(self.pcurcontext<>nil) then
       begin
            pobj:=PTSimpleDrawing(pcurcontext).GetCurrentROOT.ObjArray.beginiterate(ir);
            if pobj<>nil then
            repeat
                  if self.GDBobj then
                  if (pobj^.GetObjType=pgdbobjentity(pcurrobj)^.GetObjType)or(pgdbobjentity(pcurrobj)^.GetObjType=0) then
                  begin
                       pv:=pobj.OU.FindVariable(pp^.valkey);
                       if pv<>nil then
                       begin
                            vv:=pv.data.PTD.GetValueAsString(pv.data.Instance);
                            if vv<>'' then

                            vsa.addnodouble(@vv);
                       end;
                  end;
                  pobj:=PTSimpleDrawing(pcurcontext).GetCurrentROOT.ObjArray.iterate(ir);
            until pobj=nil;
            vsa.sort;
       end;
       if assigned(pp^.valueAddres) then
       begin
         tr:=pp^.rect;
       if assigned(pp^.Decorators.OnCreateEditor) then
                                                      TED:=pp^.Decorators.OnCreateEditor(self,tr,pp^.valueAddres,@vsa,false,pp^.PTypeManager)
                                                  else
                                                      TED:=pp^.PTypeManager^.CreateEditor(self,tr,pp^.valueAddres,@vsa,{false}true);
     case ted.Mode of
                     TEM_Integrate:begin
                                       editorcontrol:=TED.Editor.geteditor;
                                       editorcontrol.SetBounds(tr.Left+2,tr.Top,tr.Right-tr.Left-2,tr.Bottom-tr.Top);
                                       if (editorcontrol is TCombobox) then
                                                                           begin
                                                                                {$IFDEF LINUX}
                                                                                editorcontrol.Visible:=false;
                                                                                {$ENDIF}
                                                                                editorcontrol.Parent:=self;
                                                                                SetComboSize(editorcontrol as TCombobox);
                                                                                //(editorcontrol as TCombobox).itemheight:=pp^.rect.Bottom-pp^.rect.Top-6;
                                                                                if editorcontrol is TCombobox then
                                                                                if (editorcontrol as TCombobox).ReadOnly then
                                                                                (editorcontrol as TCombobox).droppeddown:=true;//автооткрытие комбика мещает вводу, открываем только те что без возможности ввода значений
                                                                           end
                                                                       else
                                                                           editorcontrol.Parent:=self;
                                       PEditor:=TED.Editor;
                                  end;
     end;
     end;
       vsa.done;
       if assigned(PEditor){<>nil} then
       begin
            //GetUndoStack;
            EDContext.ppropcurrentedit:=pp;
            EDContext.UndoStack:=GetUndoStack;

            if CurrObjIsEntity then
            begin
                 EDContext.UndoCommand:=EDContext.UndoStack.PushCreateTTypedChangeCommand(EDContext.ppropcurrentedit^.valueAddres,EDContext.ppropcurrentedit^.PTypeManager);
                 EDContext.UndoCommand.PEntity:=pcurrobj;
            end;

            peditor.OwnerNotify:=self.Notify;
            if peditor.geteditor.Visible then
                                             peditor.geteditor.setfocus;
         //-----------------------------------------------------------------PEditor^.SetFocus;
         //-----------------------------------------------------------------PEditor^.show;
         //-----------------------------------------------------------------PEditor^.SetFocus;
       end;
     end;
end;
end;

procedure TGDBobjinsp.MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer);
var
  my:GDBInteger;
  pp:PPropertyDeskriptor;
  menu:TPopupMenu;
  fesize:tsize;
  clickonheader:boolean;
begin
  inherited;
  if (y<0)or(y>clientheight)or(x<0)or(x>clientwidth) then
  begin
       StoreAndFreeEditor;
       exit;
  end;
  if (y<HeadersHeight) then
  begin
       if button<>mbLeft then
                             StoreAndFreeEditor;
       clickonheader:=true;
  end
  else
      clickonheader:=false;
  y:=y+VertScrollBar.scrollpos-self.BorderWidth;
  //if proptreeptr=nil then exit;
  my:=HeadersHeight;
  pp:=mousetoprop(@pda,x,y,my);

  if (button=mbLeft)
  and (IsMouseOnSpliter(pp,X,Y)) then
                                    begin
                                    mresplit:=true;
                                    exit;
                                    end;
  if (pp=nil)and(button=mbLeft) then
                exit;
  if (button=mbLeft) then
                         begin
                               if not clickonheader then
                               begin
                              if assigned(pp.FastEditor.OnGetPrefferedFastEditorSize)and(pp.FastEditorDrawed) then
                              begin
                              fesize:=pp.FastEditor.OnGetPrefferedFastEditorSize(pp.valueAddres);
                              if (fesize.cx>0)and((pp.rect.Right-x-fastEditorOffset-1)<=fesize.cx) then
                                                                                   begin
                                                                                        pp.FastEditorState:=TFES_Pressed;
                                                                                        {pp.FastEditor.OnRunFastEditor(pp.valueAddres);
                                                                                        if GDBobj then
                                                                                        if PGDBaseObject(pcurrobj)^.IsEntity then
                                                                                                                            PGDBObjEntity(pcurrobj)^.FormatEntity(PTDrawingDef(pcurcontext)^);
                                                                                        if assigned(resetoglwndproc) then resetoglwndproc;
                                                                                        if assigned(redrawoglwndproc) then redrawoglwndproc;
                                                                                        self.updateinsp;
                                                                                        if assigned(UpdateVisibleProc) then UpdateVisibleProc;}
                                                                                   end
                                                                             else
                                                                                 createeditor(pp)
                              end
                                 else
                                     createeditor(pp)
                               end;
                         end
                     else
                         begin
                              begin
                                   menu:=nil;
                                   if (clickonheader)or(pp=nil) then
                                   menu:=TPopupMenu(application.FindComponent(MenuNameModifier+'OBJINSPHEADERCXMENU'))
                              else if pp^.valkey<>''then
                                   menu:=TPopupMenu(application.FindComponent(MenuNameModifier+'OBJINSPVARCXMENU'))
                              else if pp^.Value<>''then
                                   menu:=TPopupMenu(application.FindComponent(MenuNameModifier+'OBJINSPCXMENU'))
                              else
                                   menu:=TPopupMenu(application.FindComponent(MenuNameModifier+'OBJINSPHEADERCXMENU'));
                                   if menu<>nil then
                                   begin
                                   currpd:=pp;
                                   menu.PopUp;
                                   end;
                                   //cxmenumgr.PopUpMenu(menu);
                              end;
                         end;

  contentheigth:=gettreeh;
  createscrollbars;
  self.Invalidate;
  //draw;
end;

procedure TGDBobjinsp.updateinsp;
begin
  //exit;
  setptr(currobjgdbtype,pcurrobj,pcurcontext);
end;


procedure TGDBobjinsp.rebuild;
var
   tp:gdbpointer;
begin
    pda.cleareraseobj;
    if peditor<>nil then
    begin
      //--MultiSelectEditor not work with this----------self.freeeditor;
    end;
    //currobjgdbtype:=exttype;
    //pcurrobj:=addr;
    if (currobjgdbtype.GetTypeAttributes and TA_OBJECT)<>0 then
      GDBobj:=true
    else
      GDBobj:=false;
    tp:=pcurrobj;
    GDBobjinsp.buildproplist(currobjgdbtype,property_build,tp);
    contentheigth:=gettreeh;
    if currobjgdbtype^.OIP.ci=self.Height then
                                                begin
                                                     VertScrollBar.Position:=currobjgdbtype^.OIP.barpos;
                                                end
                                             else
                                                 begin
                                                      VertScrollBar.Position:=0;
                                                 end;

    createscrollbars;
    draw;
end;
procedure TGDBobjinsp.setptr;
begin
  if (pcurrobj<>addr)or(currobjgdbtype<>exttype) then
  begin
    {Objinsp.}currpd:=nil;
    if peditor<>nil then
    begin
         self.freeeditor;
    end;
    if assigned(currobjgdbtype) then
    begin
    currobjgdbtype^.OIP.ci:=self.Height;
    currobjgdbtype^.OIP.barpos:=VertScrollBar.Position;
    end;
    pda.cleareraseobj;
    currobjgdbtype:=exttype;
    pcurrobj:=addr;
    pcurcontext:=context;
    oldpp:=nil;
    if (exttype.GetTypeAttributes and TA_OBJECT)<>0 then
      GDBobj:=true
    else
      GDBobj:=false;
    GDBobjinsp.buildproplist(exttype,property_build,addr);
    contentheigth:=gettreeh;
    createscrollbars;
    if currobjgdbtype^.OIP.ci=self.Height then
                                                begin
                                                     VertScrollBar.Position:=currobjgdbtype^.OIP.barpos;
                                                end
                                             else
                                                 begin
                                                      VertScrollBar.Position:=0;
                                                 end;

  end
  else
  begin
    GDBobjinsp.buildproplist(exttype,property_correct,addr);
    contentheigth:=gettreeh;
    createscrollbars;
  end;
  //draw;
  self.Refresh;
  //self.Invalidate;
  //self.update;
end;

procedure TGDBobjinsp.beforeinit;
begin

  PStoredObj:=nil;
  StoredObjGDBType:=nil;

  pcurrobj:=nil;
  peditor:=nil;
  EDContext.ppropcurrentedit:=nil;

  MResplit:=false;
  namecol:=50;
end;
procedure TGDBobjinsp.updateeditorBounds;
begin
  if peditor<>nil then
  peditor.geteditor.SetBounds(namecol+1,EDContext.ppropcurrentedit.rect.Top,clientwidth-namecol-2,EDContext.ppropcurrentedit.rect.Bottom-EDContext.ppropcurrentedit.rect.Top+1);
end;
procedure TGDBobjinsp._onresize(sender:tobject);
//var x,xn:integer;
{$IFDEF LCLGTK2}var Widget: PGtkWidget;{$ENDIF}
begin
     if namecol>clientwidth-subtab then
                                       namecol:=clientwidth-subtab;
     if namecol<subtab then
                           namecol:=clientwidth div 2;
  {$IFDEF LCLGTK2}
  //Widget:=PGtkWidget(PtrUInt(Handle));
  //gtk_widget_add_events (Widget,GDK_POINTER_MOTION_HINT_MASK);
  {$ENDIF}
  createscrollbars;
  updateeditorBounds;
  {x:=width;
  xn:=namecol;
  inherited;
  namecol:=self.clientwidth div 2;
  if namecol<50 then namecol:=50;
  if namecol>155 then
    namecol:=155;}
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('objinsp.initialization');{$ENDIF}
  proptreeptr:=nil;
  {Objinsp.}currpd:=nil;
  SetGDBObjInspProc:=TSetGDBObjInsp(SetGDBObjInsp);
  StoreAndSetGDBObjInspProc:=TStoreAndSetGDBObjInsp(StoreAndSetGDBObjInsp);
  ReStoreGDBObjInspProc:=ReStoreGDBObjInsp;
  UpdateObjInspProc:=UpdateObjInsp;
  ReturnToDefaultProc:=ReturnToDefault;
  ClrarIfItIsProc:=ClrarIfItIs;
  ReBuildProc:=ReBuild;
  SetCurrentObjDefaultProc:=SetCurrentObjDefault;
  GetCurrentObjProc:=GetCurrentObj;
  SetNameColWidthProc:=SetNameColWidth;
  GetNameColWidthProc:=GetNameColWidth;
  CreateObjInspInstanceProc:=CreateObjInspInstance;
  GetPeditorProc:=GetPeditor;
  FreEditorProc:=FreEditor;
  StoreAndFreeEditorProc:=StoreAndFreeEditor;
end.


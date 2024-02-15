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

unit zcobjectinspector;

{$MODE DELPHI}

interface

uses
  Classes,SysUtils,strutils,
  {$IFDEF LCLGTK2}gtk2,{$ENDIF}
  {$IFDEF LCLWIN32}win32proc,{$endif}
  Types,Graphics,Themes,LCLIntf,LCLType,
  ExtCtrls,Controls,Menus,Forms,
  StdCtrls,
  usupportgui,
  zeundostack,zebaseundocommands,

  uzedimensionaltypes,
  varmandef,
  TypeDescriptors,
  gzctnrVectorTypes,uzctnrvectorstrings;
const
  fastEditorOffset={$IFDEF LCLQT}2{$ELSE}2{$ENDIF} ;
  spliterhalfwidth=4;
  subtab=1;
  PlusMinusDetailArray: array[Boolean,Boolean] of TThemedTreeview =
  (
    (ttGlyphClosed,
    ttHotGlyphClosed),
    (ttGlyphOpened,
    ttHotGlyphOpened)
  );
type
  TIsCurrObjInUndoContext=function(_GDBobj:boolean;_pcurrobj:pointer):boolean;
  arrindop=record
    currnum,currcount,num,count:integer;
  end;
  arrayarrindop=array[0..10] of arrindop;
  parrayarrindop=^arrayarrindop;
  TEditorContext=record
                       ppropcurrentedit:PPropertyDeskriptor;
                       UndoStack:PTZctnrVectorUndoCommands;
                       UndoCommand:TTypedChangeCommand;
                 end;

  TOnGetOtherValues=procedure(var vsa:TZctnrVectorStrings;const valkey:string;const pcurcontext:pointer;const pcurrobj:pointer;const GDBobj:boolean);
  TOnUpdateObjectInInsp=procedure(const EDContext:TEditorContext;const currobjgdbtype:PUserTypeDescriptor;const pcurcontext:pointer;const pcurrobj:pointer;const GDBobj:boolean);
  TOnNotify=procedure(const pcurcontext:pointer);
  TMyNotifyEvent=procedure(sender:tobject);

  TObjInspCustom=TScrollBox;

  TNameColumnWidthCorrector=record
   LastClientWidth,LastNameColumnWidth:integer;
  end;

  TGDBobjinsp=class(TObjInspCustom)
    public
    currpd:PPropertyDeskriptor;
    GDBobj:boolean;
    EDContext:TEditorContext;

    PStoredObj:pointer;
    StoredObjGDBType:PUserTypeDescriptor;
    StoredUndoStack:PTZctnrVectorUndoCommands;
    pStoredContext:pointer;

    CurrUnitsFormat:TzeUnitsFormat;
    StoredUnitsFormat:TzeUnitsFormat;
    CurrPObj,pdefaultobj:pointer;
    CurrObjGDBType,defaultobjgdbtype:PUserTypeDescriptor;
    DefaultUndoStack:PTZctnrVectorUndoCommands;

    CurrContext,pdefaultcontext:pointer;
    PEditor:TPropEditor;
    PDA:TPropertyDeskriptorArray;
    NameColumnWidth:integer;
    NameColumnWidthCorrector:TNameColumnWidthCorrector;

    contentheigth:integer;
    OLDPP:PPropertyDeskriptor;
    OnMousePP:PPropertyDeskriptor;

    MResplit:boolean;
    _IsCurrObjInUndoContext:TIsCurrObjInUndoContext;
    property OnContextPopup;

    procedure draw; virtual;
    procedure mypaint(sender:tobject);
    procedure drawprop(PPA:PTPropertyDeskriptorArray;arect:trect);
    procedure InternalDrawprop(PPA:PTPropertyDeskriptorArray; var y,sub:integer;miny:integer;arect:trect;var LastPropAddFreespace:Boolean);
    procedure calctreeh(PPA:PTPropertyDeskriptorArray; var y:integer);
    function gettreeh:integer; virtual;
    //procedure BeforeInit; virtual;
    procedure _onresize(sender:tobject);virtual;
    procedure updateeditorBounds;virtual;
    procedure buildproplist(const UndoStack:PTZctnrVectorUndoCommands;const f:TzeUnitsFormat;exttype:PUserTypeDescriptor; bmode:integer; var addr:pointer);
    procedure SetCurrentObjDefault;
    procedure ReturnToDefault;
    procedure rebuild;
    procedure Notify(Sender: TObject;Command:TMyNotifyCommand); virtual;
    procedure createpda;
    destructor Destroy; Override;
    procedure createscrollbars;virtual;
    procedure ScrollBy(DeltaX, DeltaY: Integer); override;
    procedure AfterConstruction; override;
    procedure CalcRowHeight;
    procedure EraseBackground(DC: HDC); override;

    procedure FreeEditor;
    procedure StoreAndFreeEditor;
    procedure ClearEDContext;
    procedure AsyncFreeEditorAndSelectNext(Data: PtrInt);
    procedure AsyncFreeEditor(Data: PtrInt);
    function IsMouseOnSpliter(pp:PPropertyDeskriptor; X,Y:Integer):boolean;

    procedure createeditor(pp:PPropertyDeskriptor);
    function IsCurrObjInUndoContext(_GDBobj:boolean;_pcurrobj:pointer):boolean;
    constructor Create(AOwner: TComponent); override;

    function IsHeadersEnabled:boolean;
    function HeadersHeight:integer;

    {LCL}
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);override;
    procedure MouseLeave;override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer);override;
    procedure MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);override;
    procedure UpdateObjectInInsp;
    procedure setptr(const UndoStack:PTZctnrVectorUndoCommands;const f:TzeUnitsFormat;exttype:PUserTypeDescriptor; addr,context:pointer);
    procedure updateinsp;
    private
    protected
    //procedure ScrollbarHandler(ScrollKind: TScrollBarKind; OldPosition: Integer);//override;
    //procedure WMVScroll(var Message : TLMVScroll); message LM_VScroll;
    public
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: integer); override;
    procedure GetPreferredSize(var PreferredWidth, PreferredHeight: integer;
                                   Raw: boolean = false;
                                   WithThemeSpace: boolean = true); override;
    procedure DoSendBoundsToInterface; override; // called by RealizeBounds
    procedure DoAllAutoSize; override;

    procedure FormHide(Sender: TObject);

    procedure myKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;

//procedure SetGDBObjInsp(const UndoStack:PTZctnrVectorUndoCommands;const f:TzeUnitsFormat;exttype:PUserTypeDescriptor; addr,context:pointer:);
procedure StoreAndSetGDBObjInsp(const UndoStack:PTZctnrVectorUndoCommands;const f:TzeUnitsFormat;exttype:PUserTypeDescriptor; addr,context:pointer;popoldpos:boolean=false);
//function ReStoreGDBObjInsp:boolean;
function  GetCurrentObj:Pointer;
//procedure ClrarIfItIs(addr:pointer);
procedure SetNameColWidth(w:integer);
procedure SetLastClientWidth(w:integer);
function GetNameColWidth:integer;
function GetOIWidth:integer;
function GetPeditor:TComponent;
procedure Register;
var
  GDBobjinsp:TGDBobjinsp;
  //proptreeptr:propdeskptr;
  rowh:integer;
  DefaultDetails: TThemedElementDetails;

  INTFObjInspWhiteBackground:boolean=false;
  INTFObjInspShowHeaders:boolean=true;
  INTFObjInspShowSeparator:boolean=true;
  INTFObjInspOldStyleDraw:boolean=false;
  INTFObjInspShowFastEditors:boolean=true;
  INTFObjInspShowOnlyHotFastEditors:boolean=true;
  INTFDefaultControlHeight:integer=21;
  LocalRowHeight:integer=21;
  LocalRowHeightOverride:boolean=false;
  PRowHeight:PInteger;
  PRowHeightOverride:PBoolean;
  //INTFObjInspRowHeight:TIntegerOverrider;
  INTFObjInspSpaceHeight:integer=0;
  INTFObjInspShowEmptySections:boolean=false;

  PropertyRowName:string='Property';
  ValueRowName:string='Value';
  DifferentName:string='Different';

  onGetOtherValues:TOnGetOtherValues=nil;
  onUpdateObjectInInsp:TOnUpdateObjectInInsp=nil;
  onNotify:TOnNotify=nil;
  onAfterFreeEditor:TMyNotifyEvent=nil;
implementation
procedure TGDBobjinsp.myKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Peditor<>nil then
    begin
      if key=VK_ESCAPE then
        begin
          freeeditor;
          key:=0;
          exit;
        end;
    end;
  if PStoredObj<>nil then
    if key=VK_ESCAPE then
      begin
        setptr(GDBobjinsp.StoredUndoStack,GDBobjinsp.StoredUnitsFormat,GDBobjinsp.StoredObjGDBType,GDBobjinsp.PStoredObj,GDBobjinsp.pStoredContext);
        PStoredObj:=nil;
        StoredObjGDBType:=nil;
        pStoredContext:=nil;
        StoredUndoStack:=nil;
        key:=0;
        exit;
      end;
end;

function PlusMinusDetail(Collapsed,hot:boolean):TThemedTreeview;
begin
     {$IFDEF LCLWIN32}
     if WindowsVersion < wvVista then
                                    hot:=false;
     {$endif}
     result:=PlusMinusDetailArray[Collapsed,hot];
end;
procedure TGDBobjinsp.FormHide(Sender: TObject);
begin
     //proptreeptr:=proptreeptr;
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
     result:=INTFObjInspWhiteBackground;
end;

function TGDBobjinsp.IsHeadersEnabled:boolean;
begin
     result:=INTFObjInspShowHeaders;
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
     if INTFObjInspOldStyleDraw then
        result:=false
     else
        result:=INTFObjInspShowSeparator;
end;
function isOldStyleDraw:boolean;
begin
       result:=INTFObjInspOldStyleDraw;
end;
function NeedDrawFasteditor(OnMouseProp:boolean):boolean;
begin
     if INTFObjInspShowFastEditors then
     begin
         if INTFObjInspShowOnlyHotFastEditors then
         result:=OnMouseProp
         else
             result:=true;
     end
     else
         result:=false;
end;

procedure TGDBobjinsp.SetBounds(ALeft, ATop, AWidth, AHeight: integer);
begin
//     if aheight=41 then
//                       aheight:=aheight;
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
end;
{function ReStoreGDBObjInsp:boolean;
begin
     result:=false;
     if assigned(GDBobjinsp)then
     begin
     if (GDBobjinsp.PStoredObj=nil) then
                                    else
                                    begin
                                         GDBobjinsp.setptr(GDBobjinsp.StoredUndoStack,GDBobjinsp.StoredUnitsFormat,GDBobjinsp.StoredObjGDBType,GDBobjinsp.PStoredObj,GDBobjinsp.pStoredContext);
                                         GDBobjinsp.PStoredObj:=nil;
                                         GDBobjinsp.StoredObjGDBType:=nil;
                                         GDBobjinsp.pStoredContext:=nil;
                                         GDBobjinsp.StoredUndoStack:=nil;
                                         result:=true;
                                    end;
     end;
end;}
procedure StoreAndSetGDBObjInsp(const UndoStack:PTZctnrVectorUndoCommands;const f:TzeUnitsFormat;exttype:PUserTypeDescriptor; addr,context:pointer;popoldpos:boolean=false);
begin
     if assigned(GDBobjinsp)then
     begin
     if popoldpos then
     if (GDBobjinsp.PStoredObj=nil) then
                             begin
                                  GDBobjinsp.PStoredObj:=GDBobjinsp.CurrPObj;
                                  GDBobjinsp.StoredObjGDBType:=GDBobjinsp.CurrObjGDBType;
                                  GDBobjinsp.pStoredContext:=GDBobjinsp.CurrContext;
                                  GDBobjinsp.StoredUndoStack:=GDBobjinsp.EDContext.UndoStack;
                                  GDBobjinsp.StoredUnitsFormat:=GDBobjinsp.CurrUnitsFormat;
                             end;
     GDBobjinsp.setptr(UndoStack,f,exttype,addr,context);
     end;
end;

{procedure SetGDBObjInsp(const UndoStack:PTZctnrVectorUndoCommands;const f:TzeUnitsFormat;exttype:PUserTypeDescriptor; addr,context:pointer);
begin
     if assigned(GDBobjinsp)then
                                begin
                                     GDBobjinsp.setptr(UndoStack,f,exttype,addr,context);
                                end;
end;}
{procedure ClrarIfItIs(addr:pointer);
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       if GDBobjinsp.CurrPObj=addr then
                                       GDBobjinsp.ReturnToDefault;
                                  end;
end;}
procedure SetNameColWidth(w:integer);
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.NameColumnWidth:=w;
                                       GDBobjinsp.NameColumnWidthCorrector.LastNameColumnWidth:=w;
                                  end;
end;

procedure SetLastClientWidth(w:integer);
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       GDBobjinsp.NameColumnWidthCorrector.LastClientWidth:=w;
                                  end;
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

function GetNameColWidth:integer;
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       result:=GDBobjinsp.NameColumnWidth;
                                  end
                               else
                                   result:=0;
end;
function GetOIWidth:integer;
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       result:=GDBobjinsp.ClientWidth;
                                  end
                               else
                                   result:=0;
end;
function  GetCurrentObj:Pointer;
begin
       if assigned(GDBobjinsp)then
                                  begin
                                       result:=GDBobjinsp.CurrPObj;
                                  end
                              else
                                  result:=nil;
end;
procedure TGDBobjinsp.EraseBackground(DC: HDC);
begin
     inherited;
end;
procedure TGDBobjinsp.CalcRowHeight;
begin
  //spaceh:=5;
  rowh:=INTFDefaultControlHeight;

  if {INTFObjInspRowHeight.Enable}PRowHeightOverride^ then
  if {INTFObjInspRowHeight.Value}PRowHeight^>0 then
                                      rowh:={INTFObjInspRowHeight.Value}PRowHeight^;
   //spaceh:=INTFObjInspSpaceHeight;
end;

procedure TGDBobjinsp.AfterConstruction;
begin
     inherited;
     rowh:=21;
     //spaceh:=5;
     CalcRowHeight;

     onresize:=_onresize;
     //onhide:=FormHide;
     onpaint:=mypaint;
     self.DoubleBuffered:=true;
     self.BorderStyle:=bsnone;
     self.BorderWidth:=0;

     CurrPObj:=nil;
     peditor:=nil;
     CurrObjGDBType:=nil;
     createpda;
  EDContext.ppropcurrentedit:=nil;

  MResplit:=false;
  NameColumnWidth:=clientwidth div 2;
  NameColumnWidthCorrector.LastNameColumnWidth:=NameColumnWidth;
  NameColumnWidthCorrector.LastClientWidth:=clientwidth;
end;

procedure TGDBobjinsp.SetCurrentObjDefault;
begin
  pdefaultobj:=CurrPObj;
  defaultobjgdbtype:=CurrObjGDBType;
  pdefaultcontext:=CurrContext;
  DefaultUndoStack:=EDContext.UndoStack;
end;

procedure TGDBobjinsp.ReturnToDefault;
begin
  if assigned(peditor)then
                          begin
                          self.StoreAndFreeEditor;
                          end;
  setptr(DefaultUndoStack,CurrUnitsFormat,defaultobjgdbtype,pdefaultobj,pdefaultcontext);
end;

procedure TGDBobjinsp.createpda;
begin
  pda.init(100);
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

function addindex(pindex:parrayarrindop; n:integer):boolean;
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
  PTUserTypeDescriptor(exttype)^.CreateProperties(f,PDM_Field,@PDA,'root',field_no_attrib,0,bmode,addr,'','');
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
        y:=y++rowh;
        if ppd^.SubNode<>nil
          then
        begin
          if not ppd^.Collapsed^ then
            begin
            calctreeh(pointer(ppd.SubNode),y);
            y:=y+INTFObjInspSpaceHeight;
            last:=true;
            end;
        end;
      end;
      ppd:=ppa^.iterate(ir);
    until ppd=nil;
  if last then
              y:=y-INTFObjInspSpaceHeight;
end;
procedure drawfasteditor(ppd:PPropertyDeskriptor;canvas:tcanvas;var FastEditorRT:TFastEditorRunTimeData;var r:trect);
var
   fer:trect;
   FESize:TSize;
   temp:integer;
begin
     if assigned(FastEditorRT.Procs.OnGetPrefferedFastEditorSize) then
     begin
           FESize:=FastEditorRT.Procs.OnGetPrefferedFastEditorSize(ppd^.valueAddres,r);
           temp:=r.Bottom-r.Top-2;
           if temp<2 then temp:=2;
           if FESize.cy>temp then
           begin
                FESize.cy:=temp;
           end;
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
                FastEditorRT.Procs.OnDrawFastEditor(canvas,fer,ppd^.valueAddres,FastEditorRT.FastEditorState,r);
                FastEditorRT.FastEditorRect:=fer;
                r.Right:=fer.Left;
                FastEditorRT.FastEditorDrawed:=true;
           end;
     end;
end;

procedure drawfasteditors(ppd:PPropertyDeskriptor;canvas:tcanvas;var r:trect);
var
   fer:trect;
   FESize:TSize;
   temp:integer;
   i:integer;
begin
     if assigned(ppd.FastEditors)then
     for i:=0 to ppd.FastEditors.Size-1 do
      drawfasteditor(ppd,canvas,ppd.FastEditors.Mutable[i]^,r);
end;
function GetSizeTreeIcon(Minus,hot: Boolean):TSize;
var
  Details: TThemedElementDetails;
begin
  Details := ThemeServices.GetElementDetails(PlusMinusDetail(Minus,hot));
  result := ThemeServices.GetDetailSize(Details);
end;
procedure drawheader(Canvas:tcanvas;ppd:PPropertyDeskriptor;r:trect;name:string;onm:boolean;TextDetails: TThemedElementDetails);
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
  clearRTd(ppd.FastEditors);
  //ppd.FastEditorDrawed:=false;
  if NeedDrawFasteditor(onm) then
  if assigned(ppd.FastEditors) then
  drawfasteditors(ppd,canvas,r);
  {canvas.Font.Italic:=true;
  if onm then
             begin
             //canvas.Font.Bold:=true;
             canvas.Font.Underline:=true;
             end;}
  if (r.Right-r.Left)>1 then
  ThemeServices.DrawText(Canvas,TextDetails,name,r,DT_END_ELLIPSIS or DT_NOPREFIX,0);
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
  if active and ThemeServices.ThemesAvailable then
                 result := ThemeServices.GetElementDetails(ttItemSelected);
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
                     {$IFDEF LCLWIN32}
                     if ((WindowsVersion >= wvVista)and ThemeServices.ThemesEnabled) then
                                                                                         ThemeServices.DrawElement(cnvs.Handle, result, r, nil)
                                                                                     else
                                                                                         if isOldStyleDraw then
                                                                                         ThemeServices.DrawElement(cnvs.Handle, ThemeServices.GetElementDetails(ttItemNormal), r, nil)
                     {$ENDIF}
                     {$IFNDEF LCLWIN32}
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
                     {$IFDEF LCLWIN32}
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
procedure drawstring(cnvs:tcanvas;r:trect;{L,T:integer;}s:string;TextDetails: TThemedElementDetails);
{const
  maxsize=200;
var
   s2:string;}
begin
     if (r.Right-r.Left)>1 then
     ThemeServices.DrawText(cnvs,TextDetails,s,r,DT_END_ELLIPSIS or DT_SINGLELINE or DT_NOPREFIX,0)
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
   value:string;
begin
     if (ppd^.Attr and FA_HIDDEN_IN_OBJ_INSP)<>0 then
     begin
           canvas.Font.Italic:=true;
     end;
     if (ppd^.Attr and FA_APPROXIMATELY)<>0 then
                                              value:='≈'+ppd^.value
                                          else
                                              value:=ppd^.value;

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
    if (ppd^.Attr and FA_COLORED1)<>0 then
    begin
          canvas.Font.StrikeThrough:=true;
    end;
    if fulldraw then
    if (assigned(ppd.Decorators.OnDrawProperty) and(ppd^.valueAddres<>nil)and((ppd^.Attr and FA_DIFFERENT)=0)) then
                                       ppd.Decorators.OnDrawProperty(canvas,r,ppd^.valueAddres)
                                   else
                                       drawstring(canvas,r,{r.Left,r.Top,}(value),DefaultDetails);
    canvas.Font.Color:=tempcolor;
  end
  else
    begin
         clearRTd(ppd.FastEditors);
         //ppd.FastEditorDrawed:=false;
         if NeedDrawFasteditor(onm) then
         drawfasteditors(ppd,canvas,r);
     if (ppd^.Attr and FA_COLORED1)<>0 then
     begin
           canvas.Font.StrikeThrough:=true;
     end;
    if fulldraw then
    if (assigned(ppd.Decorators.OnDrawProperty) and(ppd^.valueAddres<>nil)and((ppd^.Attr and FA_DIFFERENT)=0)) then
                                                   ppd.Decorators.OnDrawProperty(canvas,r,ppd^.valueAddres)
                                               else
                                                   drawstring(canvas,r,{r.Left,r.Top,}(value),DefaultDetails);
    end;

if (ppd^.Attr and FA_HIDDEN_IN_OBJ_INSP)<>0 then
begin
      canvas.Font.Italic:=false;
end;
if (ppd^.Attr and FA_COLORED1)<>0 then
begin
      canvas.Font.StrikeThrough:=false;
end;


end;
procedure TGDBobjinsp.drawprop(PPA:PTPropertyDeskriptorArray;arect:trect);
var
   lpafs:boolean;
   y,sub:integer;
   miny:integer;
begin
     lpafs:=false;
     y:=HeadersHeight+BorderWidth;
     sub:=0;
     miny:=arect.Top+HeadersHeight+1;
     InternalDrawprop(PPA,y,sub,miny,arect,lpafs);
end;

procedure TGDBobjinsp.InternalDrawprop(PPA:PTPropertyDeskriptorArray; var y,sub:integer;miny:integer;arect:TRect;var LastPropAddFreespace:Boolean);
var
  s:String;
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
      LastPropAddFreespace:=false;
      if (ppd^.IsVisible) then
      begin
        OnMouseProp:=(ppd=onmousepp);
        if assigned(ppd^.Collapsed)then
          r.Left:=arect.Left+{2+}(subtab+GetSizeTreeIcon(not ppd^.Collapsed^,false).cx)*sub
        else
          r.Left:=arect.Left+{2+}(subtab+GetSizeTreeIcon(true,false).cx)*sub;
        r.Top:=y;
        if NeedShowSeparator then
                                 r.Right:=NameColumnWidth-spliterhalfwidth
                             else
                                 r.Right:=NameColumnWidth;
        r.Bottom:=y+rowh+1;
         if miny<=r.Bottom then
                                                 visible:=true
                                             else
                                                 visible:=false;
        begin
        if ppd^.SubNode<>nil then
                                  begin
                                     if (ppd^.SubNode^.Count>0)or INTFObjInspShowEmptySections then
                                     begin
                                     if visible then
                                     begin
                                    s:=ppd^.Name;
                                    if not NeedShowSeparator then
                                                             r.Right:=arect.Right-1;
                                    TextDetails:=drawrect(canvas,r,false,OnMouseProp,(ppd^.Attr and FA_READONLY)<>0);
                                    //r.Left:={r.Left+3}arect.Left+5+subtab*sub;
                                    r.Left:=arect.Left+{2+}(subtab+GetSizeTreeIcon(not ppd^.Collapsed^,false).cx)*sub;
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
                                      InternalDrawprop(pointer(ppd.SubNode),y,sub,miny,arect,LastPropAddFreespace);
                                    dec(sub);
                                     end;
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
                   ThemeServices.DrawText(Canvas,TextDetails,ppd^.Name,r,DT_END_ELLIPSIS or DT_NOPREFIX,0);
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
    if not LastPropAddFreespace then
                                    begin
                                      y:=y+INTFObjInspSpaceHeight;
                                      LastPropAddFreespace:=true;
                                    end;
end;

function TGDBobjinsp.gettreeh;
begin
  result:=1;
  calctreeh(@pda,result);
end;
{procedure TGDBobjinsp.WMVScroll(var Message : TLMVScroll);
var
  NewPos: Longint;
begin
  if VertScrollbar.IsScrollBarVisible then
  case Message.ScrollCode of
    SB_THUMBPOSITION:
      begin
        NewPos := VertScrollbar.Position;
        NewPos := NewPos + sign(Message.Pos - NewPos) * VertScrollbar.page div 3;
        if NewPos < 0 then
          NewPos := 0;
        if NewPos > VertScrollbar.Range then
          NewPos := VertScrollbar.Range;
        VertScrollbar.Position:= NewPos;
        exit;
      end;
  end;
  inherited;
end;}
{procedure TGDBobjinsp.ScrollbarHandler(ScrollKind: TScrollBarKind; OldPosition: Integer);
var
  ty:integer;
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
end;}
procedure TGDBobjinsp.mypaint;
begin
     //inherited;
     draw;
end;
procedure TGDBobjinsp.draw;
var
  arect,hrect:trect;
  tc:tcolor;
  {ts:TTextStyle;}
begin
CalcRowHeight;
ARect := GetClientRect;
InflateRect(ARect, -BorderWidth, -BorderWidth);
ARect.Top:=ARect.Top+VertScrollBar.ScrollPos;
ARect.Bottom:=ARect.Bottom+VertScrollBar.ScrollPos;
{$IFDEF LCLWIN32}
if WindowsVersion < wvVista then
                                DefaultDetails := ThemeServices.GetElementDetails(tbPushButtonNormal)
                            else
                                DefaultDetails := ThemeServices.GetElementDetails(tmPopupCheckBackgroundDisabled){trChevronVertHot}{ttbThumbDisabled}{tlListViewRoot};
{$endif}
{$IFDEF LCLGTK2}DefaultDetails := ThemeServices.GetElementDetails(ttbody){$endif}
{$IFDEF LCLQT}DefaultDetails := ThemeServices.GetElementDetails({ttpane}thHeaderDontCare){$endif};
{$IFDEF LCLQT5}DefaultDetails := ThemeServices.GetElementDetails(ttPane){$endif};
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
{$IFDEF LCLWIN32}
if WindowsVersion>=wvVista then
{$endif}
InflateRect(hrect, -1, -1);


drawprop(@pda,{arect}hrect);

hrect.Bottom:=hrect.Top+HeadersHeight-1{+1};
{$IFDEF WINDOWS}hrect.Top:=hrect.Top;{$ENDIF}
{$IFNDEF WINDOWS}hrect.Top:=hrect.Top+2;{$ENDIF}

if IsHeadersEnabled then
begin
    hrect.Left:=hrect.Left+2;
    hrect.Right:=NameColumnWidth;

    DefaultDetails := ThemeServices.GetElementDetails(thHeaderItemNormal);
    ThemeServices.DrawElement(Canvas.Handle, DefaultDetails, hrect, nil);
    ThemeServices.DrawText(Canvas,DefaultDetails,PropertyRowName,hrect,DT_END_ELLIPSIS or DT_CENTER or DT_VCENTER or DT_NOPREFIX,0);

    DefaultDetails := ThemeServices.GetElementDetails(thHeaderItemRightNormal);
    hrect.Left:=hrect.right;
    {$IFDEF WINDOWS}hrect.right:=ARect.Right-1;{$ENDIF}
    {$IFNDEF WINDOWS}hrect.right:=ARect.Right-2;{$ENDIF}
    ThemeServices.DrawElement(Canvas.Handle, DefaultDetails, hrect, nil);
    ThemeServices.DrawText(Canvas,DefaultDetails,ValueRowName,hrect,DT_END_ELLIPSIS or DT_CENTER or DT_VCENTER or DT_NOPREFIX,0);
end;
if NeedShowSeparator then
begin
     hrect.Left:=NameColumnWidth-2;
     hrect.right:=NameColumnWidth+{$IFNDEF WINDOWS}2{$ENDIF}{$IFDEF WINDOWS}1{$ENDIF};
     hrect.Top:= hrect.Bottom;
     hrect.Bottom:=contentheigth+HeadersHeight;
     if hrect.Bottom>ARect.Bottom then
                                      hrect.Bottom:=ARect.Bottom{height};
     if ThemeServices.ThemesEnabled then
     begin
          {$IFNDEF LCLWIN32}DefaultDetails := ThemeServices.GetElementDetails(ttbSeparatorNormal);{$ENDIF}
          {$IFDEF LCLWIN32}
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
        if (curr^.SubNode<>nil)and(not curr^.Collapsed^) then result:=findnext(pointer(curr^.SubNode),current);
        if result<>nil then exit;
      end;
      curr:=psubtree^.iterate(ir);
    until curr=nil;
end;
function InternalMousetoprop(psubtree:PTPropertyDeskriptorArray; mx,my:integer; var y:integer;var LastPropAddFreeSpace:boolean):PPropertyDeskriptor;
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
      LastPropAddFreeSpace:=false;
      if curr^.IsVisible then
      if (not((curr^.SubNode<>nil)and(curr^.SubNode.count=0)))or INTFObjInspShowEmptySections then
      begin
        dy:=my-y;
        if (dy<rowh)and(dy>0) then
        begin
          result:=curr;
          exit;
        end;
        inc(y,rowh);
        if (curr^.SubNode<>nil)and(not curr^.Collapsed^) then result:=InternalMousetoprop(pointer(curr^.SubNode),mx,my,y,LastPropAddFreeSpace);
        if result<>nil then exit;
      end;
      curr:=psubtree^.iterate(ir);
    until curr=nil;
    if not LastPropAddFreeSpace then
    begin
    y:=y+INTFObjInspSpaceHeight;
    LastPropAddFreeSpace:=true;
    end;
end;
function mousetoprop(psubtree:PTPropertyDeskriptorArray; mx,my:integer; var y:integer):PPropertyDeskriptor;
var
   lpafs:boolean;
begin
     lpafs:=false;
     result:=InternalMousetoprop(psubtree,mx,my,y,lpafs);
end;
procedure TGDBobjinsp.ClearEDContext;
begin
     EDContext.ppropcurrentedit:=nil;
     EDContext.UndoCommand:=nil;
     //EDContext.UndoStack:=nil;
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
     if assigned(onAfterFreeEditor) then
                                        onAfterFreeEditor(self);
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
   pld:pointer;
   saveppropcurrentedit:PPropertyDeskriptor;
begin
  if sender=peditor then
  begin
    saveppropcurrentedit:=EDContext.ppropcurrentedit;
    if assigned(onNotify)then
                             onNotify(CurrContext);

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
                                        EDContext.ppropcurrentedit.FastEditors[0].Procs.OnRunFastEditor(pld);
    if peditor.changed then
                           UpdateObjectInInsp;
   if (Command=TMNC_RunFastEditor)or(Command=TMNC_EditingDoneLostFocus){or(Command=TMNC_EditingDoneDoNothing)} then
{
or(Command=TMNC_EditingDoneDoNothing)
Revision: 1130
Author: zamtmn
Date: 13 декабря 2014 г. 4:59:54
Message:
Close selectable editors after selecting in object inspector
----
Modified : /trunk/cad_source/gui/objinsp.pas
Modified : /trunk/cad_source/languade/UBaseTypeDescriptor.pas
Modified : /trunk/cad_source/languade/varmandef.pas

но помоему оно тут ненужно, т.к. закрывает открываемый едитор
}
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
                     {propertysupport if EDContext.ppropcurrentedit^.mode=PDM_Property then
                                                             begin
                                                               PObjectDescriptor(CurrObjGDBType)^.SimpleRunMetodWithArg(EDContext.ppropcurrentedit^.w,CurrPObj,EDContext.ppropcurrentedit^.valueAddres);
                                                             end;}
                    end;
                end;
  if assigned(onUpdateObjectInInsp)then
     onUpdateObjectInInsp(EDContext,CurrObjGDBType,CurrContext,CurrPObj,GDBobj);

  self.updateinsp;
end;
procedure TGDBobjinsp.ScrollBy(DeltaX, DeltaY: Integer);
var
   r:trect;
begin
  {$IFNDEF WINDOWS}
  inherited;
  {$ENDIF}
  {$IFDEF WINDOWS}
  r:=ClientRect;
  r.Top:=r.Bottom;
  ScrollWindowEx(Handle, DeltaX, DeltaY, nil, {nil}@r, 0, nil, {SW_INVALIDATE or SW_ERASE}SW_SCROLLCHILDREN);
  {$ENDIF}
  if peditor<>nil then
  begin
     //peditor.geteditor.SetBounds(NameColumnWidth+1,EDContext.ppropcurrentedit.rect.Top+DeltaY,clientwidth-NameColumnWidth-2,EDContext.ppropcurrentedit.rect.Bottom-EDContext.ppropcurrentedit.rect.Top+1);
     //peditor.geteditor.Invalidate;
     if (EDContext.ppropcurrentedit.rect.Top<HeadersHeight+VertScrollBar.ScrollPos-1)
     or (EDContext.ppropcurrentedit.rect.Top>clientheight+VertScrollBar.ScrollPos-1)then
     begin
        Application.QueueAsyncCall(AsyncFreeEditor,0);
        peditor.geteditor.Hide;
     end;
  end;
   //UpdateScrollbars;
   invalidate;
end;

procedure TGDBobjinsp.createscrollbars;
var
   //changed:boolean;
   ch:integer;
begin

     //ебаный скролинг работает везде по разному, или я туплю... переписывать надо эту хрень
     ch:=contentheigth+HeadersHeight;
     {if (VertScrollBar.Range=ch)or(VertScrollBar.Position=0) then
                                              changed:=false
                                          else
                                              changed:=true;}
     self.VertScrollBar.Range:=ch;
     self.VertScrollBar.page:=height;
     self.VertScrollBar.Tracking:=true;
     self.VertScrollBar.Smooth:=true;
     self.VertScrollBar.Increment:=200;
     if ch<height  then
                                 begin
                                      {$IFNDEF LCLQt}
                                      //ScrollBy(0,-VertScrollBar.Position);
                                      {$ENDIF}
                                      VertScrollBar.Position:=0;
                                      self.VertScrollBar.page:=height;
                                      self.VertScrollBar.Range:=height;
                                      self.VertScrollBar.Tracking:=false;
                                      self.VertScrollBar.Smooth:=false;
                                      self.VertScrollBar.Increment:=200;
                                 end;
     UpdateScrollbars;
end;
function TGDBobjinsp.IsMouseOnSpliter(pp:PPropertyDeskriptor; X,Y:Integer):boolean;
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
  if (abs(x-NameColumnWidth)<spliterhalfwidth) then
                                           result:=true;
end;
procedure TGDBobjinsp.MouseLeave;
begin
     if OnMousePP<>nil then
                           begin
                                clearRTstate(OnMousePP.FastEditors);
                                //OnMousePP.FastEditorState:=TFES_Default;
                                OnMousePP:=nil;
                                invalidate;
                           end;
     inherited;
end;

procedure TGDBobjinsp.MouseMove(Shift: TShiftState; X, Y: Integer);
//procedure TGDBobjinsp.Pre_MouseMove(fwkeys:longint; x,y:SmallInt; var r:HandledMsg);
var
  my:integer;
  pp:PPropertyDeskriptor;
//  tb:boolean;
//  pb:Pboolean;
  tp:pointer;
  tempstr:string;
  FESize:TSize;
  needredraw:boolean;
  i:integer;
  currstate:TFastEditorState;
begin
    needredraw:=false;
    if mresplit then
                  begin
                       if NameColumnWidth<subtab then
                                             begin
                                                  if x>NameColumnWidth then begin
                                                    NameColumnWidth:=x;
                                                    NameColumnWidthCorrector.LastNameColumnWidth:=NameColumnWidth;
                                                    NameColumnWidthCorrector.LastClientWidth:=clientwidth;
                                                  end
                                             end
                  else if NameColumnWidth>clientwidth-subtab then
                                                         begin
                                                              if x<NameColumnWidth then begin
                                                                NameColumnWidth:=x;
                                                                NameColumnWidthCorrector.LastNameColumnWidth:=NameColumnWidth;
                                                                NameColumnWidthCorrector.LastClientWidth:=clientwidth;
                                                              end;
                                                         end
                  else begin
                         NameColumnWidth:=x;
                         NameColumnWidthCorrector.LastNameColumnWidth:=NameColumnWidth;
                         NameColumnWidthCorrector.LastClientWidth:=clientwidth;
                       end;
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
                                                  clearRTstate(OnMousePP.FastEditors);
                                                  //OnMousePP.FastEditorState:=TFES_Default;
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

  if assigned(pp.FastEditors) then
  begin
   if ssLeft in Shift then
                          currstate:=TFES_Pressed
                      else
                          currstate:=TFES_Hot;
   for i:=0 to pp.FastEditors.Size-1 do
   begin
     if pp.FastEditors.Mutable[i]^.FastEditorDrawed then
     begin
       if PtInRect(pp.FastEditors[i].FastEditorRect,Point(x, y)) then
                                                                     pp.FastEditors.Mutable[i]^.FastEditorState:=currstate
                                                                 else
                                                                     pp.FastEditors.Mutable[i]^.FastEditorState:=TFES_Default;
     end;
   end;
  needredraw:=true;
  end;

  if oldpp<>pp then
  begin
       if oldpp<>nil then
                         begin
                         clearRTstate(oldpp.FastEditors);
                         //oldpp.FastEditorState:=TFES_Default;
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
    //tempstr:=ReplaceStr(tempstr,'|',';');
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
      tp:=CurrPObj;
      GDBobjinsp.buildproplist(EDContext.UndoStack,CurrUnitsFormat,CurrObjGDBType,property_correct,tp);
      //peditor^.done;
      //Freemem(pointer(peditor));
      EDContext.ppropcurrentedit:=pp;
    end;
    PEditor:=pp^.PTypeManager^.CreateEditor(@self,pp.rect,pp^.valueAddres,nil,false,'этого не должно тут быть',rowh,CurrUnitsFormat).Editor;
    if PEditor<>nil then
    begin
      //PEditor^.show;
    end;
  end;
end;
//procedure TGDBobjinsp.pre_mousedown;
procedure TGDBobjinsp.MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);
var
  pp:PPropertyDeskriptor;
  my:integer;
  FESize:TSize;
  i:integer;
  needexit:boolean;
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
                                                 if  (peditor.geteditor as  TComboBox).Style in [csDropDownList,csOwnerDrawFixed,csOwnerDrawVariable] then
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
                                 if assigned(pp.FastEditors)then
                                 begin
                                  needexit:=false;
                                  for i:=0 to pp.FastEditors.size-1 do
                                  if pp.FastEditors[i].FastEditorDrawed then
                                  if PtInRect(pp.FastEditors[i].FastEditorRect,point(x,y)) then
                                  if pp.FastEditors[i].FastEditorState=TFES_Pressed then
                                  begin
                                  pp.FastEditors.Mutable[i]^.FastEditorState:=TFES_Default;
                                  if assigned(pp.FastEditors[i].Procs.OnRunFastEditor)then
                                  begin
                                  StoreAndFreeEditor;;
                                  EDContext.ppropcurrentedit:=pp;
                                  //pp.FastEditor.OnRunFastEditor(pp.valueAddres)
                                  if pp.FastEditors[i].Procs.UndoInsideFastEditor then
                                                                            begin
                                                                            pp.FastEditors[i].Procs.OnRunFastEditor(pp.valueAddres);
                                                                            needexit:=true;
                                                                            end
                                                                        else
                                                                            begin
                                                                            if IsCurrObjInUndoContext(GDBobj,CurrPObj) then
                                                                            begin
                                                                            //EDContext.UndoStack:=GetUndoStack;
                                                                            EDContext.UndoCommand:=EDContext.UndoStack.PushCreateTTypedChangeCommand(pp^.valueAddres,pp^.PTypeManager);
                                                                            EDContext.UndoCommand.PDataOwner:=CurrPObj;

                                                                            pp.FastEditors[i].Procs.OnRunFastEditor(pp.valueAddres);
                                                                            EDContext.UndoCommand.ComitFromObj;

                                                                            //EDContext.UndoStack:=nil;
                                                                            EDContext.UndoCommand:=nil;
                                                                            needexit:=true;
                                                                            end
                                                                            else
                                                                                begin
                                                                                pp.FastEditors[i].Procs.OnRunFastEditor(pp.valueAddres);
                                                                                needexit:=true;
                                                                                end;
                                                                            end;
                                  end;
                                  UpdateObjectInInsp;
                                  EDContext.ppropcurrentedit:=nil;
                                  invalidate;
                                  if needexit then system.break;
                                  end;
                                 end

                                 (*-----if assigned(pp.FastEditor.OnGetPrefferedFastEditorSize) then
                                 begin
                                 fesize:=pp.FastEditor.OnGetPrefferedFastEditorSize(pp.valueAddres);
                                 if (fesize.cx>0)and((pp.rect.Right-x-fastEditorOffset-1)<=fesize.cx) then
                                 if pp.FastEditorState=TFES_Pressed then
                                                                                      begin
                                                                                           pp.FastEditorState:=TFES_Default;
                                                                                           if assigned(pp.FastEditor.OnRunFastEditor)then
                                                                                           begin
                                                                                           StoreAndFreeEditor;;
                                                                                           EDContext.ppropcurrentedit:=pp;
                                                                                           //pp.FastEditor.OnRunFastEditor(pp.valueAddres)
                                                                                           if pp.FastEditor.UndoInsideFastEditor then
                                                                                                                                     pp.FastEditor.OnRunFastEditor(pp.valueAddres)
                                                                                                                                 else
                                                                                                                                     begin
                                                                                                                                     if IsCurrObjInUndoContext(GDBobj,CurrPObj) then
                                                                                                                                     begin
                                                                                                                                     //EDContext.UndoStack:=GetUndoStack;
                                                                                                                                     EDContext.UndoCommand:=EDContext.UndoStack.PushCreateTTypedChangeCommand(pp^.valueAddres,pp^.PTypeManager);
                                                                                                                                     EDContext.UndoCommand.PDataOwner:=CurrPObj;

                                                                                                                                     pp.FastEditor.OnRunFastEditor(pp.valueAddres);
                                                                                                                                     EDContext.UndoCommand.ComitFromObj;

                                                                                                                                     //EDContext.UndoStack:=nil;
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
                            end;*)
                            end;

end;
function TGDBobjinsp.IsCurrObjInUndoContext;
begin
  if assigned(_IsCurrObjInUndoContext) then
    result:=_IsCurrObjInUndoContext(_GDBobj,_pcurrobj)
  else
    result:=false;
end;
constructor TGDBobjinsp.Create(AOwner: TComponent);
begin
     inherited;
     _IsCurrObjInUndoContext:=nil;
end;

procedure TGDBobjinsp.createeditor(pp:PPropertyDeskriptor);
var
  tp:pointer;
  vsa:TZctnrVectorStrings;
  TED:TEditorDesc;
  editorcontrol:TWinControl;
  tr:TRect;
  initialvalue:String;
begin
     if pp^.SubNode<>nil then
     begin
       StoreAndFreeEditor;
       if pByte(pp^.Collapsed)^<>0 then pByte(pp^.Collapsed)^:=1;
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
         tp:=CurrPObj;
         {GDBobjinsp.}buildproplist(EDContext.UndoStack,CurrUnitsFormat,CurrObjGDBType,property_correct,tp);
         StoreAndFreeEditor;
       end;
       vsa.init(50);

       if assigned(onGetOtherValues) then
          onGetOtherValues(vsa,pp^.valkey,CurrContext,CurrPObj,GDBobj);

       if assigned(pp^.valueAddres) then
       begin
         if (pp^.Attr and FA_DIFFERENT)<>0 then
                                               initialvalue:=DifferentName
                                           else
                                               initialvalue:='';
         tr:=pp^.rect;
       if assigned(pp^.Decorators.OnCreateEditor) then
                                                      TED:=pp^.Decorators.OnCreateEditor(self,tr,pp^.valueAddres,@vsa,false,pp^.PTypeManager)
                                                  else
                                                      TED:=pp^.PTypeManager^.CreateEditor(self,tr,pp^.valueAddres,@vsa,{false}true,initialvalue,rowh,CurrUnitsFormat);
     case ted.Mode of
                     TEM_Integrate:begin
                                       TED.Editor.SetEditorBounds(pp,INTFObjInspShowOnlyHotFastEditors);
                                       editorcontrol:=TED.Editor.geteditor;
                                       //editorcontrol.SetBounds(tr.Left+2,tr.Top,tr.Right-tr.Left-2,tr.Bottom-tr.Top);
                                       if (editorcontrol is TCombobox) then
                                                                           begin
                                                                                {$IFNDEF LCLWIN32}
                                                                                editorcontrol.Visible:=false;
                                                                                {$ENDIF}
                                                                                editorcontrol.Parent:=self;
                                                                                SetComboSize(editorcontrol as TCombobox,rowh-6,CBDoNotTouch);
                                                                                //(editorcontrol as TCombobox).itemheight:=pp^.rect.Bottom-pp^.rect.Top-6;
                                                                                if (editorcontrol as TCombobox).Style in [csDropDownList,csOwnerDrawFixed,csOwnerDrawVariable] then
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
            //EDContext.UndoStack:=GetUndoStack;

            if IsCurrObjInUndoContext(GDBobj,CurrPObj) then
            if EDContext.UndoStack<>nil then
            begin
                 EDContext.UndoCommand:=EDContext.UndoStack.PushCreateTTypedChangeCommand(EDContext.ppropcurrentedit^.valueAddres,EDContext.ppropcurrentedit^.PTypeManager);
                 EDContext.UndoCommand.PDataOwner:=CurrPObj;
            end;

            peditor.OwnerNotify:=self.Notify;
            if peditor.geteditor.Visible then
                                             peditor.geteditor.setfocus;
         //PEditor^.SetFocus;
         //PEditor^.show;
         //PEditor^.SetFocus;
       end;
     end;
end;
end;

procedure TGDBobjinsp.MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer);
var
  my:integer;
  pp:PPropertyDeskriptor;
  //menu:TPopupMenu;
  fesize:tsize;
  clickonheader:boolean;
  i,count:integer;
  handled:boolean;
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
                                  if assigned(pp.FastEditors)then
                                  begin
                                  count:=0;
                                  for i:=0 to pp.FastEditors.size-1 do
                                  if pp.FastEditors[i].FastEditorDrawed then
                                  if PtInRect(pp.FastEditors[i].FastEditorRect,point(x,y)) then
                                                                                               begin
                                                                                                    pp.FastEditors.Mutable[i]^.FastEditorState:=TFES_Pressed;
                                                                                                    inc(count);
                                                                                               end;
                                  if count=0 then
                                                 createeditor(pp);
                                  end
                                  else
                                      createeditor(pp);
                                  (*if assigned(pp.FastEditor.OnGetPrefferedFastEditorSize)and(pp.FastEditorDrawed) then
                                  begin
                                  fesize:=pp.FastEditor.OnGetPrefferedFastEditorSize(pp.valueAddres);
                                  if (fesize.cx>0)and((pp.rect.Right-x-fastEditorOffset-1)<=fesize.cx) then
                                                                                       begin
                                                                                            pp.FastEditorState:=TFES_Pressed;
                                                                                            {pp.FastEditor.OnRunFastEditor(pp.valueAddres);
                                                                                            if GDBobj then
                                                                                            if PGDBaseObject(CurrPObj)^.IsEntity then
                                                                                                                                PGDBObjEntity(CurrPObj)^.FormatEntity(PTDrawingDef(CurrContext)^);
                                                                                            if assigned(resetoglwndproc) then resetoglwndproc;
                                                                                            if assigned(redrawoglwndproc) then redrawoglwndproc;
                                                                                            self.updateinsp;
                                                                                            if assigned(UpdateVisibleProc) then UpdateVisibleProc;}
                                                                                       end
                                                                                 else
                                                                                     createeditor(pp)
                                  end
                                     else
                                         createeditor(pp)*)
                               end;
                         end
                     else
                         begin
                              begin
                                   currpd:=pp;
                                   if assigned(OnContextPopup) then
                                     OnContextPopup(self,point(X,Y),handled);
                                   (*menu:=nil;
                                   if (clickonheader)or(pp=nil) then
                                   menu:=TPopupMenu(application.FindComponent({MenuNameModifier}'MENU_'+'OBJINSPHEADERCXMENU'))
                              else if pp^.valkey<>''then
                                   menu:=TPopupMenu(application.FindComponent({MenuNameModifier}'MENU_'+'OBJINSPVARCXMENU'))
                              else if pp^.Value<>''then
                                   menu:=TPopupMenu(application.FindComponent({MenuNameModifier}'MENU_'+'OBJINSPCXMENU'))
                              else
                                   menu:=TPopupMenu(application.FindComponent({MenuNameModifier}'MENU_'+'OBJINSPHEADERCXMENU'));
                                   if menu<>nil then
                                   begin
                                   currpd:=pp;
                                   menu.PopUp;
                                   end;*)
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
  setptr(EDContext.UndoStack,CurrUnitsFormat,CurrObjGDBType,CurrPObj,CurrContext);
end;


procedure TGDBobjinsp.rebuild;
var
   tp:pointer;
begin
    pda.cleareraseobj;
    if peditor<>nil then
    begin
      //--MultiSelectEditor not work with this self.freeeditor;
    end;
    //CurrObjGDBType:=exttype;
    //CurrPObj:=addr;
    if (CurrObjGDBType.GetTypeAttributes and TA_OBJECT)<>0 then
      GDBobj:=true
    else
      GDBobj:=false;
    tp:=CurrPObj;
    GDBobjinsp.buildproplist(GDBobjinsp.EDContext.UndoStack,CurrUnitsFormat,CurrObjGDBType,property_build,tp);
    contentheigth:=gettreeh;
    if CurrObjGDBType^.OIP.ci=self.Height then
                                                begin
                                                     VertScrollBar.Position:=CurrObjGDBType^.OIP.barpos;
                                                end
                                             else
                                                 begin
                                                      VertScrollBar.Position:=0;
                                                 end;

    createscrollbars;
    draw;
end;
procedure TGDBobjinsp.setptr(const UndoStack:PTZctnrVectorUndoCommands;const f:TzeUnitsFormat;exttype:PUserTypeDescriptor; addr,context:pointer);
begin
  EDContext.UndoStack:=undostack;
  if (CurrPObj<>addr)or(CurrObjGDBType<>exttype) then
  begin
    OnMousePP:=nil;
    {Objinsp.}currpd:=nil;
    if peditor<>nil then
    begin
         self.freeeditor;
    end;
    if assigned(CurrObjGDBType) then
    begin
    CurrObjGDBType^.OIP.ci:=self.Height;
    CurrObjGDBType^.OIP.barpos:=VertScrollBar.Position;
    end;
    pda.cleareraseobj;
    CurrObjGDBType:=exttype;
    CurrPObj:=addr;
    CurrContext:=context;
    CurrUnitsFormat:=f;
    oldpp:=nil;
    if (exttype.GetTypeAttributes and TA_OBJECT)<>0 then
      GDBobj:=true
    else
      GDBobj:=false;
    {GDBobjinsp.}buildproplist(UndoStack,f,exttype,property_build,addr);
    contentheigth:=gettreeh;
    createscrollbars;
    if CurrObjGDBType^.OIP.ci=self.Height then
                                                begin
                                                     VertScrollBar.Position:=CurrObjGDBType^.OIP.barpos;
                                                end
                                             else
                                                 begin
                                                      VertScrollBar.Position:=0;
                                                 end;

  end
  else
  begin
    {GDBobjinsp.}buildproplist(UndoStack,CurrUnitsFormat,exttype,property_correct,addr);
    contentheigth:=gettreeh;
    createscrollbars;
  end;
  //draw;
  self.Refresh;
  //self.Invalidate;
  //self.update;
end;

{procedure TGDBobjinsp.beforeinit;
begin

  PStoredObj:=nil;
  StoredObjGDBType:=nil;

  CurrPObj:=nil;
  peditor:=nil;
  EDContext.ppropcurrentedit:=nil;

  MResplit:=false;
  NameColumnWidth:=50;
  NameColumnWidthCorrector.LastNameColumnWidth:=NameColumnWidth;
  NameColumnWidthCorrector.LastClientWidth:=clientwidth;
end;}
procedure TGDBobjinsp.updateeditorBounds;
begin
  if (peditor<>nil)and(EDContext.ppropcurrentedit<>nil) then
    pEditor.SetEditorBounds(EDContext.ppropcurrentedit,INTFObjInspShowOnlyHotFastEditors);
end;
procedure TGDBobjinsp._onresize(sender:tobject);
var x,xn:integer;
   v:boolean;
{$IFDEF LCLGTK2}var Widget: PGtkWidget;{$ENDIF}
begin
  x:=clientwidth;
  v:=isVisible;
     if NameColumnWidthCorrector.LastClientWidth>0 then
       NameColumnWidth:=round(NameColumnWidthCorrector.LastNameColumnWidth*(clientwidth/NameColumnWidthCorrector.LastClientWidth));
     if NameColumnWidth>clientwidth-subtab then
                                       NameColumnWidth:=clientwidth-subtab;
     if NameColumnWidth<subtab then
                           NameColumnWidth:=clientwidth div 2;
  {$IFDEF LCLGTK2}
  //Widget:=PGtkWidget(PtrUInt(Handle));
  //gtk_widget_add_events (Widget,GDK_POINTER_MOTION_HINT_MASK);
  {$ENDIF}
  createscrollbars;
  updateeditorBounds;
end;
procedure Register;
begin
  RegisterComponents('zcadcontrols',[TGDBobjinsp]);
end;
initialization
  PRowHeight:=@LocalRowHeight;
  PRowHeightOverride:=@LocalRowHeightOverride;
end.


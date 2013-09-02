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
  strutils,ugdbsimpledrawing,zcadinterface,ucxmenumgr,//umytreenode,
  Themes,
  {$IFDEF LCLGTK2}
  x,xlib,{x11,}{xutil,}
  gtk2,gdk2,{gdk2x,}
  {$ENDIF}
  strproc,{umytreenode,}types,graphics,
  {StdCtrls,}ExtCtrls,{ComCtrls,}Controls,Classes,menus,Forms,lcltype,fileutil,

  gdbasetypes,SysUtils,shared,
  gdbase{OGLtypes,} {io}{,UGDBOpenArrayOfByte,varman},varmandef,{UGDBDescriptor}UGDBDrawingdef{,UGDBOpenArrayOfPV},
  {zforms,ZComboBoxsWithProc,ZEditsWithProcedure,log,gdbcircle,}memman{,zbasicvisible,zguisct},TypeDescriptors{,commctrl};
const
  rowh=21;
  alligmentall=2;
  alligmentarrayofarray=64;
  fastEditorOffset=0;
type
  arrindop=record
    currnum,currcount,num,count:GDBInteger;
  end;
  arrayarrindop=array[0..10] of arrindop;
  parrayarrindop=^arrayarrindop;
  TGDBobjinsp=class({TPanel}{TScrollBox}tform)
    public
    GDBobj:GDBBoolean;
    ppropcurrentedit:PPropertyDeskriptor;

    PStoredObj:GDBPointer;
    StoredObjGDBType:PUserTypeDescriptor;
    pStoredContext:GDBPointer;

    pcurrobj,pdefaultobj:GDBPointer;
    currobjgdbtype,defaultobjgdbtype:PUserTypeDescriptor;
    pcurcontext,pdefaultcontext:GDBPointer;
    PEditor:TPropEditor;
    PDA:TPropertyDeskriptorArray;
    namecol{,mmnamecol}:GDBInteger;
    contentheigth,startdrawy:GDBInteger;

    //TI: TOOLINFO;
    OLDPP:PPropertyDeskriptor;

    MResplit:boolean;

    procedure draw; virtual;
    procedure mypaint(sender:tobject);
    function getstyle:DWord; virtual;
    procedure drawprop(PPA:PTPropertyDeskriptorArray; var y,sub:GDBInteger);
    procedure calctreeh(PPA:PTPropertyDeskriptorArray; var y:GDBInteger);
    function gettreeh:GDBInteger; virtual;
    //procedure FormResize;
    procedure BeforeInit; virtual;
    procedure _onresize(sender:tobject);virtual;
    procedure updateeditorBounds;virtual;
    //procedure BuildPDA(ExtType:GDBWord; var addr:GDBPointer);
    procedure buildproplist(exttype:PUserTypeDescriptor; bmode:GDBInteger; var addr:GDBPointer);
    procedure SetCurrentObjDefault;
    procedure ReturnToDefault;
    procedure rebuild;
    procedure Notify(Sender: TObject;Command:TMyNotifyCommand); virtual;
    procedure createpda;
    destructor Destroy; Override;
    procedure createscrollbars;virtual;
    procedure scroll;virtual;
    procedure AfterConstruction; override;
    procedure EraseBackground(DC: HDC); override;

    procedure freeeditor;
    procedure asyncfreeeditor(Data: PtrInt);
    function IsMouseOnSpliter(pp:PPropertyDeskriptor; X:Integer):GDBBoolean;

    procedure createeditor(pp:PPropertyDeskriptor);

    {LCL}
  //procedure Pre_MouseMove(fwkeys:longint; x,y:GDBSmallInt; var r:HandledMsg); virtual;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);override;

  //procedure Pre_MouseDown(fwkeys:longint; x,y:GDBInteger; var r:HandledMsg); virtual;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer);override;
    procedure MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);override;
    private
    procedure setptr(exttype:PUserTypeDescriptor; addr,context:GDBPointer);
    procedure updateinsp;
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
  //temp: GDBPointer;
  proptreeptr:propdeskptr;

implementation

uses UObjectDescriptor,GDBEntity,UGDBStringArray,log;
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
procedure TGDBobjinsp.AfterConstruction;
begin
     inherited;
     onresize:=_onresize;
     onhide:=FormHide;
     onpaint:=mypaint;
     self.DoubleBuffered:=true;
     self.BorderStyle:=bsnone;
     self.BorderWidth:=1;

     pcurrobj:=nil;
     peditor:=nil;
     currobjgdbtype:=nil;
     createpda;
  ppropcurrentedit:=nil;
  startdrawy:=0;

  MResplit:=false;
  namecol:=clientwidth div 2;
  //mmnamecol:=namecol;

end;

procedure TGDBobjinsp.SetCurrentObjDefault;
begin
  pdefaultobj:=pcurrobj;
  defaultobjgdbtype:=currobjgdbtype;
  pdefaultcontext:=pcurcontext;
end;

procedure TGDBobjinsp.ReturnToDefault;
begin
  self.freeeditor;
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

function TGDBobjinsp.getstyle;
begin
  result:=WS_CLIPCHILDREN
                 //or WS_MAXIMIZEBOX
                 //or WS_MINIMIZEBOX
                 //or WS_OVERLAPPED
  or WS_Border
                 //or WS_VSCROLL
  or WS_CHILD;
end;

procedure incaligment(var a:GDBPointer; size:GDBLongword);
//var
//  test:GDBLongword;
begin
  inc(pGDBByte(a),size);
end;

procedure aligment(var a:GDBPointer; al:GDBInteger);
begin
     //if (GDBLongword(a)and (al-1))<>0 then a:=GDBPointer((GDBLongword(a)and (not(al-1)))+al);
     //while (GDBLongword(a)and 3)<>0 do inc(pGDBByte(a));
end;

procedure TGDBobjinsp.buildproplist;
//var
//  PEPD:PUserTypeDescriptor;
begin
    //PEPD:=PUserTypeDescriptor(Types.exttype.getelement(exttype)^);
    //PTUserTypeDescriptor(PEPD)^.CreateProperties(@PDA,'root',field_no_attrib,0,bmode,addr);
    //PD:=PUserTypeDescriptor(Types.exttype.getelement(exttype)^);
  if exttype<>nil then
  PTUserTypeDescriptor(exttype)^.CreateProperties(PDM_Field,@PDA,'root',field_no_attrib,0,bmode,addr,'','');
end;

procedure TGDBobjinsp.calctreeh;
var
//  curr:propdeskptr;
//  s:GDBString;
  ppd:PPropertyDeskriptor;
//  r,rr:trect;
//  colorn,coloro:tCOLORREF;
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

procedure TGDBobjinsp.drawprop(PPA:PTPropertyDeskriptorArray; var y,sub:GDBInteger);
var
//  curr:propdeskptr;
  s:GDBString;
  ppd:PPropertyDeskriptor;
  fer,r{,rr}:trect;
  //colorn,coloro:tCOLORREF;
  tempcolor:TColor;
  ir:itrec;
  temp:integer;
  Size: TSize;
  FESize:TSize;
  procedure DrawTreeIcon(X, Y: Integer; Minus: Boolean);
  const
    PlusMinusDetail: array[Boolean] of TThemedTreeview =
    (
      ttGlyphClosed,
      ttGlyphOpened
    );
  var
    Details: TThemedElementDetails;
    Size: TSize;
  begin
    Details := ThemeServices.GetElementDetails(PlusMinusDetail[Minus]);
    Size := ThemeServices.GetDetailSize(Details);
    ThemeServices.DrawElement(Canvas.Handle, Details, Rect(X, Y, X + Size.cx, Y + Size.cy), nil);
  end;
  function GetSizeTreeIcon(Minus: Boolean):TSize;
  const
    PlusMinusDetail: array[Boolean] of TThemedTreeview =
    (
      ttGlyphClosed,
      ttGlyphOpened
    );
  var
    Details: TThemedElementDetails;
  begin
    Details := ThemeServices.GetElementDetails(PlusMinusDetail[Minus]);
    result := ThemeServices.GetDetailSize(Details);
    //ThemeServices.DrawElement(Canvas.Handle, Details, Rect(X, Y, X + result.cx, Y + result.cy), nil);
  end;
procedure drawstring(cnvs:tcanvas;r:trect;L,T:integer;s:string);
const
  maxsize=200;
var
   s2:string;
begin
     if length(s)<maxsize then
                          cnvs.TextRect(r,L,T,s)
                      else
                          begin
                               s2:=copy(s,1,maxsize)+'...';
                               cnvs.TextRect(r,L,T,s2);
                          end;
end;
begin
  //colorn:=windows.RGB(150,150,150);

 { if ppa^.Count=0 then
                      begin
                           y:=y+rowh;
                           exit;
                      end; }

  ppd:=ppa^.beginiterate(ir);
  if ppd<>nil then
    repeat
      if (ppd^.IsVisible) then
      begin
        r.Left:=2+8*sub;
        r.Top:=y{ * rowh};
        r.Right:=namecol{-5};  //--------------------------------------------------
        r.Bottom:=y{ * rowh}+rowh+1;
        {ppd.x1:=r.Left;
        ppd.y1:=r.Top;
        ppd.x2:=r.Right;
        ppd.y2:=r.Bottom;}
        if ppd^.SubNode<>nil
          then
        begin
          {if not ppd^.Collapsed^ then
            s:='–'+ppd^.Name
          else
            s:='+'+ppd^.Name;}s:=ppd^.Name;
          r.Right:=clientwidth-2;
                                 {c:=GetBkColor(cdc);
                                 SetBkColor(cdc,0);
                                 SetBkMode(cdc,OPAQUE);}
                                 //FillRect(cdc,r,0);
          //selectobject({cdc}dc,GetStockObject(LTGRAY_BRUSH));
          //Rectangle({cdc}dc,r.Left,r.Top,r.Right,r.Bottom);

          //canvas.Brush.Style := bsSolid;
          canvas.Brush.Color := clBtnFace;
          canvas.Rectangle(r);
          //canvas.Frame3d(r,1,{bvRaised}bvSpace);

          r.Left:=r.Left+3;
          r.Top:=r.Top+3;
          if (ppd^.Attr and FA_READONLY)<>0 then
          begin
            //coloro:=SetTextColor({cdc}dc,colorn);

            tempcolor:=canvas.Font.Color;
            canvas.Font.Color:=clGrayText;
            size:=GetSizeTreeIcon(not ppd^.Collapsed^);
            temp:=(r.bottom-r.top-size.cy)div 3;
            DrawTreeIcon(r.left,r.top+temp,not ppd^.Collapsed^);
            inc(r.left,size.cx+1);
            canvas.TextRect(r,r.Left,r.Top,(s));
            dec(r.left,size.cx+1);
            //drawtextA({cdc}dc,GDBPointer(s),length(s),r,DT_left);
            canvas.Font.Color:=tempcolor;
            //SetTextColor({cdc}dc,coloro);
          end
          else
              begin
              //drawtextA({cdc}dc,GDBPointer(s),length(s),r,DT_left);
              //canvas.Font.Color:=clYellow;    dfg
                size:=GetSizeTreeIcon(not ppd^.Collapsed^);
                temp:=(r.bottom-r.top-size.cy)div 3;
              DrawTreeIcon(r.left,r.top+temp,not ppd^.Collapsed^);
              inc(r.left,size.cx+1);
              canvas.TextRect(r,r.Left,r.Top,(s));

              dec(r.left,size.cx+1);
              end;
          inc(sub);
          y:=y+rowh;
          if not ppd^.Collapsed^ then
            drawprop(GDBPointer(ppd.SubNode),y,sub);
          dec(sub);
        end
        else
        begin

          canvas.Brush.Color := {clWhite}{clAppWorkspace}clBtnFace;
          canvas.Rectangle(r);

          //selectobject({cdc}dc,GetStockObject(WHITE_BRUSH));
          //Rectangle({cdc}dc,{2} r.left,r.Top,r.Right,r.Bottom);
          r.Left:=r.Left+2;
          r.Top:=r.Top+3;
          if (ppd^.Attr and FA_READONLY)<>0 then
          begin
            tempcolor:=canvas.Font.Color;
            canvas.Font.Color:=clGrayText;
            canvas.TextRect(r,r.Left,r.Top,(ppd^.Name));
            canvas.Font.Color:=tempcolor;

          //  coloro:=SetTextColor({cdc}dc,colorn);
          //  drawtextA({cdc}dc,GDBPointer(ppd^.Name),length(ppd^.Name),r,DT_left);
          //  SetTextColor({cdc}dc,coloro);
          end
          else
              canvas.TextRect(r,r.Left,r.Top,(ppd^.Name));
              //drawtextA({cdc}dc,GDBPointer(ppd^.Name),length(ppd^.Name),r,DT_left);
          r.Top:=r.Top-3;
          r.Left:=r.Right-1;
          r.Right:=clientwidth-2;
          //Rectangle({cdc}dc,r.Left,r.Top,r.Right,r.Bottom);
          canvas.Brush.Color := {clWhite}{clAppWorkspace}clWindow;
          canvas.Rectangle(r);
        ppd.x1:=r.Left;
        ppd.y1:=r.Top;
        ppd.x2:=r.Right;
        ppd.y2:=r.Bottom-1;
          r.Top:=r.Top+3;
          r.Left:=r.Left+3;
          r.Right:=r.Right-1;
          if (ppd^.Attr and FA_READONLY)<>0 then
          begin
            tempcolor:=canvas.Font.Color;
            canvas.Font.Color:=clGrayText;
            drawstring(canvas,r,r.Left,r.Top,(ppd^.value));
            //canvas.TextRect(r,r.Left,r.Top,(ppd^.value));
            canvas.Font.Color:=tempcolor;

//            coloro:=SetTextColor({cdc}dc,colorn);
//            drawtextA({cdc}dc,GDBPointer(ppd^.value),length(ppd^.value),r,DT_left);
//            SetTextColor({cdc}dc,coloro);
          end
          else
            //drawtextA({cdc}dc,GDBPointer(ppd^.value),length(ppd^.value),r,DT_left);
            begin
            if ppd.PTypeManager<>nil then
            begin
            FESize:=ppd.PTypeManager.GetPrefferedFastEditorSize(ppd^.valueAddres);
            if FESize.cX>0 then
            begin
                 fer:=r;
                 fer.Left:=fer.Right-FESize.cX-fastEditorOffset;
                 fer.Right:=fer.Right-fastEditorOffset;
                 fer.Top:=fer.Top-3;
                 r.Right:=fer.Left;
                 ppd.PTypeManager.DrawFastEditor(canvas,fer,ppd^.valueAddres);
            end;
            end;
            drawstring(canvas,r,r.Left,r.Top,(ppd^.value));
            //canvas.TextRect(r,r.Left,r.Top,(ppd^.value));
                                 //TextOut(cdc, namecol, y * rowh, GDBPointer(ppd^.value), length(ppd^.value));
            end;
          y:=y++rowh;
        end;
      end;
      ppd:=ppa^.iterate(ir);
    until ppd=nil;

    y:=y+rowh;
end;

function TGDBobjinsp.gettreeh;
begin
  result:=0;
  calctreeh(@pda,result);
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
  arect:trect;
begin
ARect := GetClientRect;
InflateRect(ARect, -BorderWidth, -BorderWidth);

//canvas.Brush.Color := clBtnFace;
//canvas.FillRect(ARect);

y:=startdrawy;
sub:=0;
drawprop(@pda,y,sub);
end;

{procedure TGDBobjinsp.formresize;
begin
     halt(0);
end;}
function findnext(psubtree:PTPropertyDeskriptorArray;current:PPropertyDeskriptor):PPropertyDeskriptor;
var
  {rez,}curr:PPropertyDeskriptor;
      ir:itrec;
begin
  result:=nil;
  //rez:=nil;
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
  {rez,}curr:PPropertyDeskriptor;
      ir:itrec;
begin
  result:=nil;
  //rez:=nil;
  curr:=psubtree^.beginiterate(ir);
  if curr<>nil then
    repeat
      if curr^.IsVisible then
      begin
        if (my-y)<rowh then
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
  {curr := subtree;
  repeat
    if (((y + 1) * rowh) - my) > 0 then
    begin
      result := curr;
      exit;
    end;
    y := y + 1;
    if (curr^.sub <> nil)and curr^.drawsub then
    begin
      rez := mousetoprop(curr^.sub, mx, my, y);
      result := rez;
      if rez <> nil then
        exit;
    end;
    curr := curr.next;
  until (curr = nil);}
end;
procedure TGDBobjinsp.freeeditor;
begin
     freeandnil(peditor);
     if assigned(shared.cmdedit) then
                                     shared.cmdedit.SetFocus;
end;

procedure TGDBobjinsp.asyncfreeeditor;
var
      next:PPropertyDeskriptor;
begin
     next:=findnext(@pda,ppropcurrentedit);
     freeeditor;
     if next<>nil then
     createeditor(next);
end;

procedure TGDBobjinsp.Notify;
var
   pld:GDBPointer;
   //pdwg:PTDrawing;
begin
  if sender=peditor then
  begin   //fghfgh

    //pdwg:=ptdrawing(gdb.GetCurrentDWG);
    if pcurcontext<>nil then
    begin
         PTDrawingDef(pcurcontext).ChangeStampt(true);
    end;
    pld:=peditor.PInstance;
    if GDBobj then
                  begin
                       if ppropcurrentedit^.mode=PDM_Field then
                                                               begin
                                                               //PGDBaseObject(pcurrobj)^.FormatAfterFielfmod(pld,self.currobjgdbtype);
                                                               if PGDBaseObject(pcurrobj)^.IsEntity then
                                                                                                        PGDBObjEntity(pcurrobj)^.FormatEntity(PTDrawingDef(pcurcontext)^)
                                                                                                    else
                                                                                                        PGDBaseObject(pcurrobj)^.FormatAfterFielfmod(pld,self.currobjgdbtype);
                                                               end

                                                           else
                                                               begin
                                                                 PObjectDescriptor(currobjgdbtype)^.SimpleRunMetodWithArg(ppropcurrentedit^.w,pcurrobj,ppropcurrentedit^.valueAddres);
                                                                 //PGDBaseObject(pcurrobj)^.FormatAfterFielfmod(nil,self.currobjgdbtype)
                                                                 if PGDBaseObject(pcurrobj)^.IsEntity then
                                                                                                          PGDBObjEntity(pcurrobj)^.FormatEntity(PTDrawingDef(pcurcontext)^)
                                                                                                      else
                                                                                                          PGDBaseObject(pcurrobj)^.FormatAfterFielfmod(nil,self.currobjgdbtype);
                                                               end;

                  end;
    if Command=TMNC_EditingDone then
                                    Application.QueueAsyncCall(asyncfreeeditor, 0);

    if assigned(redrawoglwndproc) then redrawoglwndproc;
    self.updateinsp;
    if assigned(UpdateVisibleProc) then UpdateVisibleProc;
    //MainForm.ReloadLayer(@gdb.GetCurrentDWG.LayerTable);
  end;
end;
procedure TGDBobjinsp.scroll;
//var si:scrollinfo;
begin
     {
     si.cbSize:=sizeof(scrollinfo);
     si.fMask:=SIF_ALL;
     GetScrollInfo(handle,SB_VERT,si);
     if peditor<>nil then
                         begin
                              peditor^.setxywh(peditor.wndx,peditor.wndy-(startdrawy+si.nTrackPos),peditor.wndw,peditor.wndh);
                         end;
     startdrawy:=-si.nTrackPos;
     si.nPos:=si.nTrackPos;
     si.fMask:=SIF_ALL;// сведения о полученных атрибутах
     si.nMin:=0;// нижняя граница диапазона
     si.nMax:=contentheigth;// верхняя граница диапазона
     si.nPage:=clientheight;// размер страницы
     draw;
     SetScrollInfo(handle,SB_VERT,si,true);
     }
end;
procedure TGDBobjinsp.createscrollbars;
//var //si:scrollinfo;
    //a:integer;
begin
     self.VertScrollBar.Range:=contentheigth;
     self.VertScrollBar.page:={clientheight}height;
     {IFNDEF LINUX}self.VertScrollBar.Tracking:=true;{ENDIF}
     self.VertScrollBar.Smooth:=true;

     //if contentheigth>clientheight
     //                             then application.MessageBox('1','2',1);

{  if contentheigth>self.clientheight then
                                    begin
                                         if (style and ws_vscroll)=0 then
                                         setstyle(WS_VSCROLL,0);
                                         si.cbSize:=sizeof(scrollinfo);
                                         si.fMask:=SIF_ALL;// сведения о полученных атрибутах
                                         si.nMin:=0;// нижняя граница диапазона
                                         si.nMax:=contentheigth;// верхняя граница диапазона
                                         si.nPage:=clientheight;// размер страницы
                                         si.nPos:=-startdrawy;// позиция ползунка
                                         SetScrollInfo(handle,SB_VERT,si,true);

                                    end
                                else
                                    begin
                                         if (style and ws_vscroll)<>0 then
                                         setstyle(0,WS_VSCROLL);
                                         startdrawy:=0;
                                    end;
                                    }
end;
function TGDBobjinsp.IsMouseOnSpliter(pp:PPropertyDeskriptor; X:Integer):GDBBoolean;
begin
  result:=false;
  if (pp<>nil) then
  if (pp^.SubNode=nil) then
  if (abs(x-namecol)<2) then
                          result:=true;
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
begin
    if mresplit then
                  begin
                       //mmnamecol:=x;
                       namecol:=x;
                       repaint;
                       exit;
                  end;

  y:=y+self.VertScrollBar.Position;
  //application.HintPause:=1;
  //application.HintShortPause:=10;
  my:=startdrawy;
  pp:=mousetoprop(@pda,x,y,my);

  if IsMouseOnSpliter(pp,X) then
                                self.Cursor:=crHSplit
                            else
                                self.Cursor:=crDefault;

  if (pp=nil)or(ppropcurrentedit=pp) then
  begin
        self.Hint:='';
        self.ShowHint:=false;
       oldpp:=pp;
       exit;
  end;

  if oldpp<>pp then
  begin

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
      ppropcurrentedit:=pp;
    end;
    PEditor:=pp^.PTypeManager^.CreateEditor(@self,{namecol-6}pp^.x1,{my}pp^.y1,{clientwidth-namecol+3}pp^.x2-pp^.x1,{rowh}pp^.y2-pp^.y1,pp^.valueAddres,nil,false);
    if PEditor<>nil then
    begin
      //-----------------------------------------------------------------PEditor^.show;
    end;
  end;
end;
//procedure TGDBobjinsp.pre_mousedown;
procedure TGDBobjinsp.MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);
begin
     inherited;
     if (button=mbLeft)
    and (mresplit=true) then
                                    begin
                                    mresplit:=false;
                                    exit;
                                    end;
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
begin
     if pp^.SubNode<>nil then
     begin
       if peditor<>nil then
                           begin
                             freeandnil(peditor);
                           //-----------------------------------------------------------------peditor^.done;
                           //-----------------------------------------------------------------gdbfreemem(pointer(peditor));
                           end;

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

         freeandnil(peditor);
         //-----------------------------------------------------------------peditor^.done;
         //-----------------------------------------------------------------gdbfreemem(pointer(peditor));
         //ppropcurrentedit:=pp;
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
       PEditor:=pp^.PTypeManager^.CreateEditor(self,{namecol-6}pp^.x1,{my}pp^.y1,{clientwidth-namecol+3}pp^.x2-pp^.x1,{rowh}pp^.y2-pp^.y1+1,pp^.valueAddres,@vsa,false);
       vsa.done;
       if assigned(PEditor){<>nil} then
       begin
            ppropcurrentedit:=pp;
            peditor.OwnerNotify:=self.Notify;
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
  //pedipor:pzbasic;
//  tb:GDBBoolean;
//  pb:PGDBBoolean;
  //tp:pointer;
  //pobj:pGDBObjEntity;
  //pv:pvardesk;
  //vv:gdbstring;
  //vsa:GDBGDBStringArray;
  //ir:itrec;

  menu:TPopupMenu;
  fesize:tsize;

begin
  inherited;
  if (y<0)or(y>clientheight)or(x<0)or(x>clientwidth) then
  begin
       freeeditor;
       exit;
  end;
  y:=y+self.VertScrollBar.Position;
  //if proptreeptr=nil then exit;
  my:=startdrawy;
  pp:=mousetoprop(@pda,x,y,my);

  if (button=mbLeft)
  and (IsMouseOnSpliter(pp,X)) then
                                    begin
                                    mresplit:=true;
                                    exit;
                                    end;
  if pp=nil then
                exit;
  if (button=mbLeft) then
                         begin
                              if pp.PTypeManager<>nil then
                              begin
                              fesize:=pp.PTypeManager.GetPrefferedFastEditorSize(pp.valueAddres);
                              if (fesize.cx>0)and(({clientwidth}pp.x2-x-fastEditorOffset-1)<=fesize.cx) then
                                                                                   begin
                                                                                        pp.PTypeManager.RunFastEditor(pp.valueAddres);
                                                                                        if GDBobj then
                                                                                        if PGDBaseObject(pcurrobj)^.IsEntity then
                                                                                                                            PGDBObjEntity(pcurrobj)^.FormatEntity(PTDrawingDef(pcurcontext)^);
                                                                                        if assigned(redrawoglwndproc) then redrawoglwndproc;
                                                                                        self.updateinsp;
                                                                                        if assigned(UpdateVisibleProc) then UpdateVisibleProc;
                                                                                   end
                                                                             else
                                                                                 createeditor(pp)
                              end
                                 else
                                     createeditor(pp)
                         end
                     else
                         begin
                              begin
                                   menu:=nil;
                                   if pp^.valkey<>''then
                                   menu:=TPopupMenu(application.FindComponent(MenuNameModifier+'OBJINSPVARCXMENU'))
                              else if pp^.Value<>''then
                                   menu:=TPopupMenu(application.FindComponent(MenuNameModifier+'OBJINSPCXMENU'));
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
  ppropcurrentedit:=nil;
  startdrawy:=0;

  MResplit:=false;
  namecol:=50;
  //---------------TI.cbSize := SizeOf(TOOLINFO);
  //---------------TI.uFlags := TTF_SUBCLASS;
  //---------------TI.uId := 0;
  //---------------TI.hwnd := Handle;
  //---------------TI.lpszText := @'123123123'[1];
  //---------------Windows.GetClientRect(Handle, TI.Rect);

  //----------------SendMessage(MainFormN.hToolTip, TTM_ADDTOOL, 0, LPARAM(@ti));
end;
procedure TGDBobjinsp.updateeditorBounds;
begin
  if peditor<>nil then
  peditor.geteditor.SetBounds(namecol-1,ppropcurrentedit.y1,clientwidth-namecol-1,ppropcurrentedit.y2-ppropcurrentedit.y1+1);
end;
procedure TGDBobjinsp._onresize(sender:tobject);
//var x,xn:integer;
{$IFDEF LCLGTK2}var Widget: PGtkWidget;{$ENDIF}
begin
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
end.


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
{**
Project tree form
@author(Andrey Zubarev <zamtmn@yandex.ru>)
}
unit uzcfprojecttree;
{$INCLUDE zengineconfig.inc}
interface
uses
 uzcsysparams,uzcsysvars,uzctranslations,uzcenitiesvariablesextender,uzcdrawing,uzbpaths,
 uzctnrvectorstrings,uzeconsts,uzcstrconsts,uzcctrlcontextmenu,uzbstrproc,
 uzctreenode,menus, {$IFDEF FPC}lcltype,{$ENDIF}
 Classes,FileUtil,Forms,stdctrls,Controls,ComCtrls,
 uzcdevicebaseabstract,SysUtils,uzcdrawings,varman,
 varmandef,uzccommandsimpl,uzccommandsabstract,
 uztoolbarsmanager,
 gzctnrVectorTypes,uzeblockdef,UBaseTypeDescriptor,uzcinterface,UUnitManager,uzcLog,uzmenusmanager;
const
  uncat='UNCAT';
  uncat_='UNCAT_';
type
      {**@abstract(Node represents a block definition)
         Modified TTreeNode}
      TBlockTreeNode=class(TmyTreeNode)
               public
                    FBlockName:String;{**<Block(Device) name}
                    procedure Select;override;
                    function GetParams:Pointer;override;
               end;
      {**Modified TTreeNode}
      TEqTreeNode=class(TBlockTreeNode)
               public
                    ptd:THardTypedData;
                    //FBlockName:String;{**<Block(Device) name}
                    procedure Select;override;
                    function GetParams:Pointer;override;
               end;

  {**@abstract(Project tree class)
      Project tree class desk}
  TProjectTreeForm = class(TFreedForm)
    PT_PageControl:TmyPageControl;{**<??}
    PT_P_ProgramDB:TTabSheet;{**<Чтото там для описания}
    PT_P_ProjectDB:TTabSheet;

    T_ProgramDB:TmyTreeView;
    T_ProjectDB:TmyTreeView;

    BlockNodeUnCatN,DeviceNodeUnCatN,BlockNodeN,DeviceNodeN,ProgramEquipmentN,ProjectEquipmentN:TmyTreeNode;

    procedure AfterConstruction; override;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction); override;
    private
    procedure BuildTreeByEQ(var BuildNode:TmyTreeNode;PDBUNIT:PTUnit;pcm:TPopupMenu);
    procedure ChangePage(Sender: TObject);
  end;
var
  ProjectTreeForm:TProjectTreeForm;{<Дерево проекта}
  BlockCategory,EqCategory:TZctnrVectorStrings;

  //ProgramDBContextMenuN,ProjectDBContextMenuN,ProgramDEVContextMenuN:TmyPopupMenu;

implementation
function TBlockTreeNode.GetParams;
begin
     result:=@FBlockName;
end;
procedure TBlockTreeNode.Select;
var
                  TypeDesk:PUserTypeDescriptor;
                  Instance:Pointer;

begin
     TypeDesk:=sysunit.TypeName2PTD('GDBObjBlockdef');
     Instance:=drawings.GetCurrentDWG.BlockDefArray.getblockdef(FBlockName);
     if instance<>nil then
                          begin
                            ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,TypeDesk,Instance,drawings.GetCurrentDWG)
                          end
                      else
                          ZCMsgCallBackInterface.TextMessage(format(rscmNoBlockDefInDWGCXMenu,[FBlockName]),TMWOShowError);
end;


procedure TEqTreeNode.Select;
begin
     ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,ptd.PTD,ptd.Instance,drawings.GetCurrentDWG);
end;
function TEqTreeNode.GetParams;
begin
     result:=@ptd;
end;
{function GDBBlockNode.GetNodeName;
begin
     result:=Name;
end;}
function Cat2UserNameCat(category:String; const catalog:TZctnrVectorStrings):String;
var
   ps{,pspred}:pString;
//   s:String;
   ir:itrec;
begin
     ps:=catalog.beginiterate(ir);
     if (ps<>nil) then
     repeat
          if length(ps^)>length(category) then

          if (copy(ps^,1,length(category))=category)
          and(ps^[length(category)+1]='_') then
                                              begin
                                                    result:=copy(ps^,length(category)+2,length(ps^)-length(category)-1);
                                                    exit;
                                              end;
          ps:=catalog.iterate(ir);
     until ps=nil;
     result:=category;
end;

procedure TProjectTreeForm.ChangePage;
begin
     if sender is TmyPageControl then
     if TmyPageControl(sender).ActivePageIndex=1 then
                       begin
                            T_ProjectDB.Selected:=nil;
                            self.ProjectEquipmentN.DeleteChildren;
                            BuildTreeByEQ(ProjectEquipmentN,PTZCADDrawing(drawings.GetCurrentDWG).DWGUnits.findunit(GetSupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName),MenusManager.GetPopupMenu('PROJECTDBCXMENU',nil));
                            (*
                            ProjectEquipmentNodeN.free;
                            Getmem(pointer(ProjectEquipmentNode.SubNode),sizeof(TGDBTree));
                            ProjectEquipmentNode.SubNode.init(10);
                            BuildTreeByEQ(ProjectEquipmentNode,drawings.GetCurrentDWG.DWGUnits.findunit(DrawingDeviceBaseUnitName),ProjectDBContextMenu);
                            ProjectDB.Sync;
                            *)
                       end;

end;
procedure BuildBranchN(var CurrNode:TmyTreeNode;var TreePos:String; const catalog:TZctnrVectorStrings);
var
    i:integer;
    CurrFindNode{,tn}:TmyTreeNode;
    category:String;
begin
     TmyTreeView(CurrNode.TreeView).NodeType:=TmyTreeNode;
     i:=pos('_',treepos);
     if i>0 then
     repeat
     category:=uppercase(copy(treepos,1,i-1));
     treepos:=copy(treepos,i+1,length(treepos)-i+1);

     CurrFindNode:=iteratefind(CurrNode,IterateFindCategoryN,@category,false);
     if CurrFindNode<>nil then
                                 CurrNode:=CurrFindNode
                             else
                                 begin
                                      CurrNode:=TmyTreeNode(TmyTreeView(CurrNode.TreeView).Items.addchild(CurrNode,(Cat2UserNameCat(category,catalog))));
                                      TmyTreeNode(CurrNode).fcategory:=category;
                                 end;

     i:=pos('_',treepos);
     until (i=0)or(category=uncat);
end;
procedure TProjectTreeForm.BuildTreeByEQ(var BuildNode:TmyTreeNode;PDBUNIT:PTUnit;pcm:TPopupMenu);
var
   pvdeq:pvardesk;
   ir:itrec;
   offset:Integer;
   tc:PUserTypeDescriptor;
   treepos,treesuperpos{,category,s}:String;
   i:integer;
   CurrNode{,CurrFindNode,tn}:TmyTreeNode;
   eqnode:TEqTreeNode;
   //s:AnsiString;
begin
  pvdeq:=PDBUNIT^.InterfaceVariables.vardescarray.beginiterate(ir);
  if pvdeq<>nil then
  repeat
        if pos('_EQ',pvdeq^.name)=1 then

        begin
         offset:=0;
         pvdeq^.data.PTD^.ApplyOperator('.','TreeCoord',offset,tc);
         if (offset<>0)and(tc^.GetFactTypedef=@FundamentalStringDescriptorObj) then
         begin
              treesuperpos:=pString(ptruint(pvdeq^.data.Addr.Instance) + offset)^;
         end
         else
             treesuperpos:='';
         if treesuperpos='' then
                            treesuperpos:=uncat_+pvdeq^.name;
         repeat
         i:=pos('|',treesuperpos);
         if i=0 then i:=length(treesuperpos)+1;

         treepos:=copy(treesuperpos,1,i-1);
         treesuperpos:=copy(treesuperpos,i+1,length(treesuperpos)-i);

         //treepos:=treesuperpos;


         CurrNode:=BuildNode;

         buildbranchn(CurrNode,treepos,EqCategory);

         //Getmem(pointer(eqnode),sizeof(GDBEqNode));
         //if PDBUNIT<>DBUnit then
         //                       s:=PDbBaseObject(pvdeq^.data.Addr.Instance)^.NameShort+' из '
         //                   else
         //                       s:='';
         TmyTreeView(CurrNode.TreeView).NodeType:=TEqTreeNode;
         if treepos=uncat then
                                begin
                                     eqnode:=TEqTreeNode({tree}TmyTreeView(BuildNode.TreeView).Items.addchild(CurrNode,(treepos)));
                                     eqnode.fBlockName:=pvdeq^.name;
                                     eqnode.FPopupMenu:=pcm;
                                     eqnode.ptd.PTD:=pvdeq^.data.PTD;
                                     eqnode.ptd.Instance:=pvdeq^.data.Addr.Instance;

                                     //eqnode.init(s+pvdeq^.name,pvdeq^.name,pvdeq^.data.PTD,pvdeq^.Instance,pcm)
                                end
                             else
                                 begin
                                      eqnode:=TEqTreeNode({tree}TmyTreeView(BuildNode.TreeView).Items.addchild(CurrNode,(PDbBaseObject(pvdeq^.data.Addr.Instance)^.NameShort)+' ('+pvdeq^.name+') '+' из '+treepos));
                                      eqnode.fBlockName:=pvdeq^.name;
                                      eqnode.FPopupMenu:=pcm;
                                      eqnode.ptd.PTD:=pvdeq^.data.PTD;
                                      eqnode.ptd.Instance:=pvdeq^.data.Addr.Instance;

                                 //eqnode.init(s+treepos,pvdeq^.name,pvdeq^.data.PTD,pvdeq^.Instance,pcm);
                                 end;
         //CurrNode.SubNode.AddNode(eqnode);
         until treesuperpos='';

        end;
        pvdeq:=PDBUNIT^.InterfaceVariables.vardescarray.iterate(ir);
  until pvdeq=nil;
end;
procedure TProjectTreeForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  inherited;
  if CloseAction=caFree then
                            StoreBoundsToSavedUnit('ProjectTreeWND',self.BoundsRect);
end;

procedure TProjectTreeForm.AfterConstruction;
var
   //tnode:TTreeNode;
   pb:PGDBObjBlockdef;
    ir:itrec;
    i:integer;
    CurrNode:TTreeNode;
    pvd{,pvd2}:pvardesk;
    treepos{,treesuperpos,category}:String;
    //pmenuitem:pzmenuitem;

    BlockNode:TBlockTreeNode;
    pentvarext:TVariablesExtender;
begin
  inherited;
  //self.Position:=poScreenCenter;
  self.BoundsRect:=GetBoundsFromSavedUnit('ProjectTreeWND',SysParam.notsaved.ScreenX,SysParam.notsaved.Screeny);
  caption:=rsProjectTree;
  self.borderstyle:=bsSizeToolWin;

  PT_PageControl:=TmyPageControl.create(self);
  PT_PageControl.align:=alClient;
  PT_PageControl.OnChange:=self.ChangePage;

  PT_P_ProgramDB:=TTabSheet.create(PT_PageControl);
  PT_P_ProgramDB.Caption:=rsProgramDB;
  T_ProgramDB:=TmyTreeView.create(PT_P_ProgramDB);
  T_ProgramDB.ReadOnly:=true;
  BlockNodeN:=TmyTreeNode(T_ProgramDB.Items.add(nil,(rsBlocks)));
  BlockNodeUnCatN:=TmyTreeNode(T_ProgramDB.Items.addchild(BlockNodeN,(rsUncategorized)));
  BlockNodeUnCatN.fcategory:=uncat;
  DeviceNodeN:=TmyTreeNode(T_ProgramDB.Items.add(nil,(rsDevices)));
  DeviceNodeUnCatN:=TmyTreeNode(T_ProgramDB.Items.addchild(DeviceNodeN,(rsUncategorized)));
  DeviceNodeUnCatN.fcategory:=uncat;
  ProgramEquipmentN:=TmyTreeNode(T_ProgramDB.Items.add(nil,(rsEquipment)));



  T_ProgramDB.align:=alClient;
  T_ProgramDB.scrollbars:=ssAutoBoth;
  T_ProgramDB.Parent:=PT_P_ProgramDB;

  PT_P_ProgramDB.Parent:=PT_PageControl;

  PT_P_ProjectDB:=TTabSheet.create(PT_PageControl);
  PT_P_ProjectDB.Caption:=rsProjectDB;
  T_ProjectDB:=TmyTreeView.create(PT_P_ProjectDB);
  T_ProjectDB.ReadOnly:=true;
  ProjectEquipmentN :=TmyTreeNode(T_ProjectDB.Items.add(nil,(rsEquipment)));
  T_ProjectDB.align:=alClient;
  T_ProjectDB.scrollbars:=ssAutoBoth;
  T_ProjectDB.Parent:=PT_P_ProjectDB;

  PT_P_ProjectDB.Parent:=PT_PageControl;

  PT_PageControl.Parent:=self;

  begin
  pb:=BlockBaseDWG.BlockDefArray.beginiterate(ir);
  if pb<>nil then
  repeat
        i:=pos(DevicePrefix,pb^.name);
        if i=0 then
                   begin
                        CurrNode:=BlockNodeN;
                   end
               else
                   begin
                        CurrNode:=DeviceNodeN;
                   end;
        treepos:=uncat_+pb^.name;
        pentvarext:=pb.GetExtension<TVariablesExtender>;
        pvd:=pentvarext.entityunit.FindVariable('BTY_TreeCoord');
        if pvd<>nil then
        if pvd^.data.Addr.Instance<>nil then
                                        treepos:=pstring(pvd^.data.Addr.Instance)^;
        //log.programlog.LogOutStr(treepos,0);


        BuildBranchN(TmyTreeNode(CurrNode),treepos,BlockCategory);

        TmyTreeView(CurrNode.TreeView).NodeType:=TBlockTreeNode;
        BlockNode:=TBlockTreeNode(T_ProgramDB.Items.addchild(CurrNode,(treepos)));
        BlockNode.fBlockName:=pb^.name;
        BlockNode.FPopupMenu:=MenusManager.GetPopupMenu('PROGRAMBLOCKSCXMENU',nil);

        pb:=BlockBaseDWG.BlockDefArray.iterate(ir);
  until pb=nil;
  end;

  BuildTreeByEQ(ProgramEquipmentN,DBUnit,MenusManager.GetPopupMenu('PROGRAMDBCXMENU',nil));
  if drawings.GetCurrentDWG<>nil then
  BuildTreeByEQ(ProjectEquipmentN,PTZCADDrawing(drawings.GetCurrentDWG).DWGUnits.findunit(GetSupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName),MenusManager.GetPopupMenu('PROJECTDBCXMENU',nil));

end;
function ProjectTree_com(const Context:TZCADCommandContext;Operands:pansichar):Integer;
begin
  if not assigned(ProjectTreeForm) then
                                  ProjectTreeForm:=TProjectTreeForm.mycreate(Application,@ProjectTreeForm);
  ProjectTreeForm.Show;
  result:=cmd_ok;
end;
initialization
begin
  ProjectTreeForm:=nil;
  BlockCategory.init(100);
  EqCategory.init(100);
  BlockCategory.loadfromfile(expandpath('*rtl/BlockCategory.cat'));
  EqCategory.loadfromfile(expandpath('*rtl/EqCategory.cat'));
  CreateZCADCommand(@ProjectTree_com,'ProjectTree',CADWG,0);
end;
finalization
begin
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  {FreeAndNil(ProgramDBContextMenuN);
  FreeAndNil(ProjectDBContextMenuN);
  FreeAndNil(ProgramDEVContextMenuN);}
  BlockCategory.Done;
  EqCategory.Done;
end;
end.

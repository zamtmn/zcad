(*----------------------------------------------------------------------------*)
(*                  Copyright (c) 2004-2010 Antrey Zubarev                    *)
(*----------------------------------------------------------------------------*)
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit uzccomelectrical;
{$IFDEF FPC}
  {$CODEPAGE UTF8}
{$endif}
{$INCLUDE zengineconfig.inc}

interface
uses
  gzctnrVectorTypes,uzglviewareageneral,uzcTranslations,gzundoCmdChgMethods,
  zcmultiobjectcreateundocommand,uzeentitiesmanager,uzedrawingdef,
  uzcenitiesvariablesextender,uzgldrawcontext,uzcdrawing,uzcvariablesutils,
  uzcstrconsts,UGDBSelectedObjArray,uzeentityfactory,uzcsysvars,
  csvdocument,
  UGDBOpenArrayOfPV,uzeentblockinsert,{devices,}{UGDBTree,}uzcdrawings,
  uzccommandsmanager,uzccomdraw,uzcentelleader,
  uzccommandsabstract,
  uzccommandsimpl,
  uzegeometrytypes,uzbtypes,
  uzcutils,
  sysutils,
  {fileutil}LazUTF8,
  varmandef,
  uzglviewareadata,
  uzcinterface,
  uzegeometry,

  uzeconsts,
  uzeentity,uzeentline,
  uzcentnet,
  uzeentsubordinated,uzcentcable,varman,uzcdialogsfiles,uunitmanager,
  uzcbillofmaterial,uzccablemanager,uzeentdevice,uzeenttable,
  uzbpaths,uzctnrvectorstrings,math,Masks,uzbstrproc,
  uzeentabstracttext,uzeentmtext,uzeblockdef,UGDBPoint3DArray,uzcdevicebaseabstract,
  uzelongprocesssupport,uzcLog,
  generics.Collections,
  uzccommand_treestat,uzccommand_line2,uzccmdfloatinsert,uzcregother,uzcfcommandline,
  uzeparsercmdprompt,uzctnrvectorpgdbaseobjects,uzeSnap;
type
{Export+}
  TFindType=(
               TFT_Obozn(*'**обозначении'*),
               TFT_DBLink(*'**материале'*),
               TFT_DESC_MountingDrawing(*'**сокращенноммонтажномчертеже'*),
               TFT_variable(*'??указанной переменной'*)
             );
PTBasicFinter=^TBasicFinter;
{REGISTERRECORDTYPE TBasicFinter}
TBasicFinter=record
                   IncludeCable:Boolean;(*'Include filter'*)
                   IncludeCableMask:String;(*'Include mask'*)
                   ExcludeCable:Boolean;(*'Exclude filter'*)
                   ExcludeCableMask:String;(*'Exclude mask'*)
             end;
  PTFindDeviceParam=^TFindDeviceParam;
  {REGISTERRECORDTYPE TFindDeviceParam}
  TFindDeviceParam=record
                        FindType:TFindType;(*'Find in'*)
                        FindMethod:Boolean;(*'Use symbols *, ?'*)
                        FindString:String;(*'Text'*)
                    end;
  {REGISTERRECORDTYPE GDBLine}
     GDBLine=record
                  lBegin,lEnd:GDBvertex;
              end;
  PTELCableComParam=^TELCableComParam;
  {REGISTERRECORDTYPE TELCableComParam}
  TELCableComParam=record
                        Traces:TEnumData;(*'Trace'*)
                        PCable:{PGDBObjCable}Pointer;(*'Cabel'*)
                        PTrace:{PGDBObjNet}Pointer;(*'Trace (pointer)'*)
                   end;
  {REGISTERRECORDTYPE TELLeaderComParam}
  TELLeaderComParam=record
                        Scale:Double;(*'Scale'*)
                        Size:Integer;(*'Size'*)
                        twidth:Double;(*'Width'*)
                   end;
{Export-}
  El_Wire_com = object(CommandRTEdObject)
    New_line: PGDBObjLine;
    FirstOwner,SecondOwner,OldFirstOwner:PGDBObjNet;
    constructor init(cn:String;SA,DA:TCStartAttr);
    procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
    procedure CommandCancel(const Context:TZCADCommandContext); virtual;
    function BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer; virtual;
    function AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer; virtual;
  end;

  {EM_SRBUILD_com = object(FloatInsert_com)
    procedure Command(Operands:TCommandOperands); virtual;
  end;
  EM_SEPBUILD_com = object(FloatInsertWithParams_com)
    procedure Command(Operands:TCommandOperands); virtual;
    procedure BuildDM(Operands:TCommandOperands); virtual;
  end;}
  KIP_CDBuild_com=object(FloatInsert_com)
    procedure Command(Operands:TCommandOperands); virtual;
  end;

  KIP_LugTableBuild_com=object(FloatInsert_com)
    procedure Command(Operands:TCommandOperands); virtual;
  end;


    (*PGDBEmSEPDeviceNode=^GDBEmSEPDeviceNode;
    GDBEmSEPDeviceNode=object(GDBVisNode)
                              NodeName:String;
                              upcable:PTCableDesctiptor;
                              dev,shell:PGDBObjDevice;
                              function GetNodeName:String;virtual;
                       end;*)
   TBGMode=(BGAvtomat,DG1J,BGComm,DG2J,BGNagr);
var
   Wire:El_Wire_com;
   p3dpl:PGDBObjCable;

   //pco:pCommandRTEdObjectPlugin;
   FindDeviceParam:TFindDeviceParam;

   CableManager:TCableManager;

   pcabcom,pfindcom:pCommandRTEdObjectPlugin;
   cabcomparam:TELCableComParam;
   csel:pCommandFastObjectPlugin;
   MainSpecContentFormat:TZctnrVectorStrings;

   //EM_SRBUILD:EM_SRBUILD_com;
   //EM_SEPBUILD:EM_SEPBUILD_com;
   em_sepbuild_params:TBasicFinter;
   KIP_CDBuild:KIP_CDBuild_com;
   KIP_LugTableBuild:KIP_LugTableBuild_com;

   //treecontrol:ZTreeViewGeneric;
   //zf:zform;
   ELLeaderComParam:TELLeaderComParam;

{procedure startup;
procedure finalize;}
procedure Cable2CableMark(pcd:PTCableDesctiptor;pv:pGDBObjDevice);
function RegenZEnts_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
implementation
function GetCableMaterial(pcd:PTCableDesctiptor):String;
var
   {pvn,}{pvm,}pvmc{,pvl}:pvardesk;
   line:String;
   eq:pvardesk;
begin
                                        pvmc:=FindVariableInEnt(pcd^.StartSegment,'DB_link');
                                        if pvmc<>nil then
                                        begin
                                        line:=pstring(pvmc^.data.Addr.Instance)^;
                                        eq:=DWGDBUnit.FindVariable(line);
                                        if eq=nil then
                                                      result:='(!)'+line
                                                  else
                                                      begin
                                                           result:=PDbBaseObject(eq^.data.Addr.Instance)^.NameShort;
                                                      end;
                                        end
                                        else
                                            result:=rsNotSpecified;
end;
procedure Cable2CableMark(pcd:PTCableDesctiptor;pv:pGDBObjDevice);
var
   {pvn,}pvm,{pvmc,}pvl:pvardesk;
   //line:String;
   //eq:pvardesk;
   pentvarext:TVariablesExtender;
begin
     pentvarext:=pv^.GetExtension<TVariablesExtender>;
     pvm:=pentvarext.entityunit.FindVariable('CableMaterial');
                        if pvm<>nil then
                                    begin
                                         pstring(pvm^.data.Addr.Instance)^:={Tria_Utf8ToAnsi}( GetCableMaterial(pcd));
                                        {pvmc:=pcd^.StartSegment^.FindVariable('DB_link');
                                        if pvmc<>nil then
                                        begin
                                        line:=pstring(pvmc^.Instance)^;
                                        eq:=DWGDBUnit.FindVariable(line);
                                        if eq=nil then
                                                      pstring(pvm^.Instance)^:='(!)'+line
                                                  else
                                                      begin
                                                           pstring(pvm^.Instance)^:=PDbBaseObject(eq^.Instance)^.NameShort;
                                                      end;
                                        end
                                        else
                                            pString(pvm^.Instance)^:='Не определен';}
                                    end;
                       pvl:=pentvarext.entityunit.FindVariable('CableLength');
                       if pvl<>nil then
                                       pDouble(pvl^.data.Addr.Instance)^:=pcd^.length;
end;
{function GDBEmSEPDeviceNode.GetNodeName:String;
begin
     result:=nodename;
end;}
(*
procedure IP(pnode:PGDBBaseNode;PProcData:Pointer);
//var
//   pvd:pvardesk;
begin
     if PGDBEmSEPDeviceNode(pnode)^.upcable<>nil then
     begin
          pvd:=PGDBEmSEPDeviceNode(pnode)^.upcable^.StartSegment.OU.FindVariable('GC_HDGroup');
          if pvd<>nil then
          if PInteger(pvd^.Instance)^>PInteger(Pprocdata)^ then
             PInteger(Pprocdata)^:=PInteger(pvd^.Instance)^;
     end;
end;
*)
(*function icf (pnode:PGDBBaseNode;PExpr:Pointer):Boolean;
//var
//   pvd:pvardesk;
begin
     result:=false;
     if PGDBEmSEPDeviceNode(pnode)^.upcable<>nil then
     begin
          pvd:=PGDBEmSEPDeviceNode(pnode)^.upcable^.StartSegment.OU.FindVariable('GC_HDGroup');
          if pvd<>nil then
          if PInteger(pvd^.Instance)^=PInteger(PExpr)^ then
             result:=true;
     end;
end;*)
function g2x(g:Integer):Integer;
begin
     result:=30*g;
end;
function TBGMode2y(bgm:TBGMode):Double;
begin
     case bgm of
       BGAvtomat:
                 result:=0;
       DG1J:
            result:=-40;
       BGComm:
              result:=-57.5;
       DG2J:
            result:=-75;
       BGNagr:
              result:=-121.5;
     end;
end;
function insertblock(bname:String;obozn:TDXFEntsInternalStringType;p:gdbVertex):TBoundingBox;
var
   pgdbins:pgdbobjblockinsert;
   pbdef:PGDBObjBlockdef;
   ptext:PGDBObjMText;
   DC:TDrawContext;
begin
          pbdef:=drawings.CurrentDWG^.BlockDefArray.getblockdef(bname);
          dc:=drawings.GetCurrentDWG^.CreateDrawingRC;

          pbdef^.getonlyoutbound(dc);
          //pbdef^.calcbb;
          result:=pbdef.vp.BoundingBox;

          pointer(pgdbins):=drawings.CurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBBlockInsertID,@drawings.CurrentDWG.ConstructObjRoot);
          pgdbins^.name:=bname;
          pgdbins^.Local.P_insert:=p;
          pgdbins^.BuildGeometry(drawings.GetCurrentDWG^);
          pgdbins^.FormatEntity(drawings.GetCurrentDWG^,dc);

          //pointer(ptext):=drawings.CurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBMtextID,@drawings.CurrentDWG.ConstructObjRoot);

          if obozn<>'' then
          begin
          ptext:=pointer(AllocEnt(GDBMtextID));
          ptext^.init(@drawings.CurrentDWG.ConstructObjRoot,drawings.GetCurrentDWG.LayerTable.getAddres('TEXT'),sysvar.dwg.DWG_CLinew^,obozn,CreateVertex(p.x+pbdef.vp.BoundingBox.LBN.x-1,p.y,p.z),2.5,0,0.65,RightAngle,jsbc,1,1);
          drawings.CurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(ptext^);
          ptext^.FormatEntity(drawings.GetCurrentDWG^,dc);
          end;

end;
procedure drawlineandtext(pcabledesk:PTCableDesctiptor;p1,p2:GDBVertex);
var
   pl:pgdbobjline;
   a:Double;
   ptext:PGDBObjMText;
   v:gdbvertex;
   DC:TDrawContext;
begin
     pl:=pointer(AllocEnt(GDBLineID));
     pl^.init(@drawings.CurrentDWG.ConstructObjRoot,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,p1,p2);
     drawings.CurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pl^);
     dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
     pl^.Formatentity(drawings.GetCurrentDWG^,dc);
     if pcabledesk<>nil then
     begin
          v:=vertexsub(p1,p2);
          v:=normalizevertex(v);
          if (abs (v.x) < 1/64) and (abs (v.y) < 1/64) then
                                                                    v:=CrossVertex(YWCS,v)
                                                                else
                                                                    v:=CrossVertex(ZWCS,v);
          if {v.x*}v.y<0 then
                          begin
                               {a:=v.x;
                               v.x:=v.y;
                               v.y:=a;}
                               v:=uzegeometry.VertexMulOnSc(v,-1);
                               a:=vertexangle(PGDBVertex2d(@p1)^,PGDBVertex2d(@p2)^)*180/pi;
                          end
                          else
                              a:=180+vertexangle(PGDBVertex2d(@p1)^,PGDBVertex2d(@p2)^)*180/pi;

          ptext:=pointer(AllocEnt(GDBMtextID));
          ptext^.init(@drawings.CurrentDWG.ConstructObjRoot,drawings.GetCurrentDWG.LayerTable.getAddres('TEXT'),sysvar.dwg.DWG_CLinew^,TDXFEntsInternalStringType(GetCableMaterial(pcabledesk)+' L='+floattostr(pcabledesk^.length)+'m'),vertexadd(Vertexmorph(p1,p2,0.5),v),2.5,0,0.65,a,jsbc,vertexlength(p1,p2),1);
          drawings.CurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(ptext^);
          ptext^.Formatentity(drawings.GetCurrentDWG^,dc);

          ptext:=pointer(AllocEnt(GDBMtextID));
          ptext^.init(@drawings.CurrentDWG.ConstructObjRoot,drawings.GetCurrentDWG.LayerTable.getAddres('TEXT'),sysvar.dwg.DWG_CLinew^,TDXFEntsInternalStringType(pcabledesk^.Name),vertexsub(Vertexmorph(p1,p2,0.5),v),2.5,0,0.65,a,jstc,vertexlength(p1,p2),1);
          drawings.CurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(ptext^);
          ptext^.Formatentity(drawings.GetCurrentDWG^,dc);

     end;
     
end;
procedure drawcable(pcabledesk:PTCableDesctiptor;p1,p2:GDBVertex;g1,g2:TBoundingBox;bgm1,bgm2:TBGMode);
//var
//   pl:pgdbobjline;
begin
     if abs(p1.x-p2.x)<eps then
                               drawlineandtext(pcabledesk,createvertex(p1.x,p1.y+g1.LBN.y,p1.z),createvertex(p2.x,p2.y+g2.RTF.y,p2.z))
else if ({bgm1=bgm2}abs(p1.y-p2.y)<eps)and(bgm1=BGNagr) then
                           begin
                                drawlineandtext(nil,createvertex(p1.x,p1.y+g1.RTF.y,p1.z),createvertex(p1.x+2,p1.y+g1.RTF.y+10,p1.z));
                                drawlineandtext(pcabledesk,createvertex(p1.x+2,p1.y+g1.RTF.y+10,p1.z),createvertex(p2.x-2,p1.y+g1.RTF.y+10,p2.z));
                                drawlineandtext(nil,createvertex(p2.x,p2.y+g2.RTF.y,p2.z),createvertex(p2.x-2,p1.y+g1.RTF.y+10,p2.z));
                           end
else if bgm1=bgm2 then
                           begin
                                if abs(p1.y-p2.y)<eps then
                                                          drawlineandtext(pcabledesk,createvertex(p1.x+g1.RTF.x,p1.y,p1.z),createvertex(p2.x+g2.LBN.x,p2.y,p2.z))
                                                      else
                                begin
                                     drawlineandtext(pcabledesk,createvertex(p1.x+g1.rtf.x,p1.y,p1.z),createvertex(p2.x,p1.y,p1.z));
                                     drawlineandtext(nil,createvertex(p2.x,p1.y,p1.z),createvertex(p2.x,p2.y+g2.RTF.y,p2.z));
                                end;
                           end

else if bgm1<bgm2 then
                           begin
                                drawlineandtext(nil,createvertex(p1.x,p1.y+g1.LBN.y,p1.z),createvertex(p1.x+1,p1.y+g1.LBN.y-1,p1.z));
                                drawlineandtext(pcabledesk,createvertex(p1.x+1,p1.y+g1.LBN.y-1,p1.z),createvertex(p2.x,p1.y+g1.LBN.y-1,p1.z));
                                drawlineandtext(nil,createvertex(p2.x,p1.y+g1.LBN.y-1,p1.z),createvertex(p2.x,p2.y+g2.RTF.y,p2.z));
                           end;

end;
//TBGMode=(BGAvtomat,DG1J,BGComm,DG2J,BGNagr);
(*procedure EM_SEP_build_group(const cman:TCableManager;const node:PGDBEmSEPDeviceNode;var group:Integer;P1:GDBVertex;var BGM:TBGMode;oldgabarit:GDBBoundingBbox);
var
   pvd:pvardesk;
   tempbgm,newBGM,nextBGM,TnextBGM:TBGMode;
   ir:itrec;
   subnode:PGDBEmSEPDeviceNode;
   tempgroup,maxgroup:Integer;
   pgdbins:pgdbobjblockinsert;
   name:String;
   gabarit:GDBBoundingBbox;
   y:Double;
   p:gdbvertex;
begin
          drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'EM_PSRS_HEAD');
          drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'DEVICE_EM_PSRS_EL');
          pointer(pgdbins):=drawings.CurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBBlockInsertID,@drawings.CurrentDWG.ConstructObjRoot);
          pgdbins^.name:='EM_PSRS_HEAD';
          pgdbins^.Local.P_insert:=createvertex(-15,0,0);
          pgdbins^.BuildGeometry;
          pgdbins^.Format;

     pvd:=node.shell.OU.FindVariable('Device_Type');
     if pvd<>nil then
     case
         PTDeviceType(pvd^.Instance)^ of
         TDT_SilaPotr,TDT_SilaIst:begin
                                       nextBGM:=BGNagr;
                                  end;
         TDT_Junction:begin
                             if bgm=BGAvtomat then
                                                  nextBGM:=DG1J
                                              else
                                                  nextBGM:=DG2J;
                      end;
         TDT_SilaComm:begin
                           nextBGM:=BGComm;
                      end;
     end;
     tnextBGM:=nextBGM;
     if node.SubNode=nil then
                             nextBGM:=BGNagr;

     newBGM:=NextBGM;
     tempgroup:=group;

          if node.shell<>nil then
          begin
          name:='';
          pvd:=node.shell.ou.FindVariable('NMO_Name');
                         if pvd<>nil then
                                         name:=pString(pvd.Instance)^;
          //y:=TBGMode2y(nextBGM);
          p:=createvertex(g2x(group),TBGMode2y(nextBGM),0);
          gabarit:=insertblock(node.shell.Name,name,p);
          drawcable(node.upcable,p1,p,oldgabarit,gabarit,bgm,tnextbgm);
          y:=y+gabarit.lbn.y;

          if nextBGM=BGNagr then
          begin
          pgdbins:=addblockinsert(@drawings.CurrentDWG.ConstructObjRoot,@drawings.CurrentDWG.ConstructObjRoot.ObjArray,createvertex(g2x(group),-128,0),1,0,'DEVICE_EM_PSRS_EL');
          node.shell.Format;
          node.shell.OU.CopyTo(@pgdbins.OU);
          // pointer(pgdbins):=drawings.CurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBBlockInsertID,@drawings.CurrentDWG.ConstructObjRoot);
          // pgdbins^.name:='DEVICE_EM_PSRS_EL';
          // pgdbins^.Local.P_insert:=createvertex(g2x(group),-128,0);
          pgdbins^.BuildGeometry;
          pgdbins^.Format;
          end;

          if (NextBGM=BGNagr){or(NextBGM<=BGM)} then
                                  inc(tempgroup);
          end;

     if node.SubNode<>nil then
     begin
          node.SubNode.Invert;
          subnode:=node.SubNode^.beginiterate(ir);
          if subnode<>nil then
          repeat
                tempbgm:=nextbgm;

               //                 if {(nextBGM=BGNagr)and}(tempBGM=BGNagr) then
               //                                          inc(tempgroup);

                EM_SEP_build_group(cman,subnode,tempgroup,p,tempbgm,gabarit);

                subnode:=node.SubNode^.iterate(ir);
          until subnode=nil;
          node.SubNode.Invert;
     end;
     group:=tempgroup;
     bgm:=NextBGM;
          end;

procedure EM_SEP_build_graphix(const cman:TCableManager;const tree:PTGDBTree);
var
   group,groupmax,dg:Integer;
   pgroupnode:PGDBEmSEPDeviceNode;
   BGM:TBGMode;
   gabarit:GDBBoundingBbox;
begin
     groupmax:=0;
     dg:=0;
     tree^.IterateProc(@ip,false,@groupmax);
     for group := 1 to groupmax do
       begin
            gabarit.LBN:=nulvertex;
            gabarit.RTF:=nulvertex;
            pointer(pgroupnode):=tree^.IterateFind(@icf,@group,false);
            if pgroupnode<>nil then
                                   begin
                                        BGM:=BGAvtomat;
                                        EM_SEP_build_group(cman,pgroupnode,dg,createvertex(g2x(dg),0,0),BGM,gabarit);
                                   end;
       end;
end;
procedure EM_SEP_build_tree(const cman:TCableManager;var tree:PTGDBTree;pobj: pGDBObjEntity);
var
   ir2,ir3:itrec;
   pcabledesk:PTCableDesctiptor;
   root2:PGDBEmSEPDeviceNode;
   sd:PGDBObjDevice;
   pvd:pvardesk;
   name:String;
   pendobj: pGDBObjEntity;
   dev,shell:PGDBObjDevice;
   oldtree:PTGDBTree;
   ptree:^PTGDBTree;
   firstseg:boolean;
begin
              oldtree:=nil;
              ptree:=@tree;
              pcabledesk:=cman.beginiterate(ir2);
              if pcabledesk<>nil then
              repeat
                    sd:=pointer(pcabledesk^.StartDevice^.FindShellByClass(TDC_Shell));
                    if sd<>nil then
                    if sd=pointer(pobj) then
                    begin
                         if tree=nil then
                         begin
                              Getmem(pointer(tree),sizeof(TGDBTree));
                              tree.init(10);
                              ptree:=@tree;
                              if oldtree=nil then
                              begin
                              oldtree:=tree;
                              end;
                         end;
                         firstseg:=true;
                         dev:=pcabledesk^.Devices.beginiterate(ir3);
                         dev:=pcabledesk^.Devices.iterate(ir3);
                         if dev<>nil then
                         repeat
                               shell:=pointer(dev^.FindShellByClass(TDC_Shell));


                         Getmem(pointer(root2),sizeof(GDBEmSEPDeviceNode));
                         root2^.initnul;
                         pvd:=shell.ou.FindVariable('NMO_Name');
                         if pvd<>nil then
                                         name:=pString(pvd.Instance)^;
                         //if name= then
                         

                         root2^.NodeName:=name;
                         root2^.upcable:=nil;
                         root2^.shell:=shell;
                         if firstseg then
                         begin
                         root2^.NodeName:=root2^.NodeName+'-('+pcabledesk^.Name+')';
                         root2^.upcable:=pcabledesk;
                         firstseg:=false;
                         end;

                         if ptree^=nil then
                         begin
                              Getmem(pointer(ptree^),sizeof(TGDBTree));
                              ptree^.init(10);
                         end;

                         ptree^^.AddNode(root2);

                         tree:=root2.SubNode;
                         ptree:=@root2.SubNode;

                         if shell<>nil then
                                           EM_SEP_build_tree(cman,root2.SubNode,shell);


                               dev:=pcabledesk^.Devices.iterate(ir3);
                         until dev=nil;

                         tree:=oldtree;
                         ptree:=@tree;
                    end;


                    pcabledesk:=cman.iterate(ir2);
              until pcabledesk=nil;
end;
*)
{procedure EM_SEPBUILD_com.BuildDM(Operands:TCommandOperands);
begin
    //commandmanager.DMAddProcedure('test1','подсказка1',nil);
    commandmanager.DMAddMethod('Разместить','подсказка3',run);
    commandmanager.DMAddMethod('Разместить','подсказка3',run);
    commandmanager.DMAddMethod('Разместить','подсказка3',run);
    commandmanager.DMShow;
end;}
{procedure EM_SEPBUILD_com.Command(Operands:TCommandOperands);
begin

end;}

(*procedure EM_SEPBUILD_com.Command(Operands:pansichar);
var
      pobj: pGDBObjEntity;
      ir:itrec;
      counter:integer;
      //tcd:TCopyObjectDesc;
      pvd:pvardesk;
      name:String;
      cman:TCableManager;

      root:PGDBEmSEPDeviceNode;
begin

commandmanager.DMShow;

  cman.init;
  cman.build;
  drawings.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));



  counter:=0;
  cman.init;
  cman.build;
             drawings.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));

  pobj:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pobj<>nil then
  begin
  repeat
    if pobj.selected then
    if pobj.GetObjType=GDBDeviceID then
    begin
         pvd:=pobj^.ou.FindVariable('Device_Type');
         if pvd<>nil then
         if PTDeviceType(pvd^.Instance)^=TDT_SilaIst then
         begin
              inc(counter);


              pvd:=pobj^.ou.FindVariable('NMO_Name');
              if pvd<>nil then
                              name:=pString(pvd.Instance)^;
              zf.initxywh('EMTREE',@mainformn,100,100,500,500,false);
              treecontrol.initxywh('asas',@zf,500,0,500,45,false);
              treecontrol.align:=al_client;

              Getmem(pointer(root),sizeof(GDBEmSEPDeviceNode));
              root^.initnul;
              root^.NodeName:=name;


              EM_SEP_build_tree(cman,root^.SubNode,pobj);
              treecontrol.tree.AddNode(root);

              treecontrol.Sync;
              treecontrol.Show;zf.Show;



         end;
    end;
  pobj:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until (pobj=nil)or(counter<>0);
  end;

  if counter=0 then
                   TMWOHistoryOut('Выбери объект(ы) источник энергии!')
               else
                   EM_SEP_build_graphix(cman,root^.SubNode);
  cman.done;
  //treecontrol.done;
end;*)
procedure KIP_CDBuild_com.Command(Operands:TCommandOperands);
var
  psd:PSelectedObjDesc;
  ir:itrec;
  pnevdev:PGDBObjDevice;
  PBH:PGDBObjBlockdef;
  currentcoord:GDBVertex;
  t_matrix:DMatrix4D;
  pobj,pcobj:PGDBObjEntity;
  ir2:itrec;
  pvd:pvardesk;
  dn:tdevname;
  dna:devnamearray;
  i:integer;
  DC:TDrawContext;
  entvarext,delvarext:TVariablesExtender;
  extensionssave:pointer;
  pu:PTSimpleUnit;
begin
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;

  //добавляем определение блока HEAD_CONNECTIONDIAGRAM в чечтеж если надо
  drawings.GetCurrentDWG^.AddBlockFromDBIfNeed('HEAD_CONNECTIONDIAGRAM');

  //получаеи указатель на него
  PBH:=drawings.GetCurrentDWG^.BlockDefArray.getblockdef('HEAD_CONNECTIONDIAGRAM');

  //такого блок в библиотеке нет, водим
  //TODO: надо добавить ругань
  if pbh=nil then
                exit;
  if not PBH.Formated then
                         PBH.FormatEntity(drawings.GetCurrentDWG^,dc);

  //создаем массив ИмяУстройств+АдресУстройства
  dna:=devnamearray.Create;
  //заполняем массив устройствами попавшими в выделение
  //TODO: тут нужно учитывать централизацию
  psd:=drawings.GetCurrentDWG^.SelObjArray.beginiterate(ir);
  if psd<>nil then
  repeat
       if psd^.objaddr^.GetObjType=GDBDeviceID then
       begin
            entvarext:=psd^.objaddr^.GetExtension<TVariablesExtender>;
            //pvd:=PTEntityUnit(psd^.objaddr^.ou.Instance)^.FindVariable('DESC_MountingSite');
            pvd:=entvarext.entityunit.FindVariable({'DESC_MountingSite'}'NMO_Name');
            if pvd<>nil then
                            dn.name:=pvd.data.PTD.GetValueAsString(pvd.data.Addr.Instance)
                        else
                            dn.name:='';
            dn.pdev:=pointer(psd^.objaddr);
            dna.PushBack(dn);
       end;
       psd:=drawings.GetCurrentDWG^.SelObjArray.iterate(ir);
  until psd=nil;

  if dna.Size=0 then
    //ругаемся если устройств в выделениии не оказалось
    ZCMsgCallBackInterface.TextMessage(rscmSelDevsBeforeComm,TMWOHistoryOut)
  else begin
    //устройства в выделениии присутствуют, сортируем по именам
    //это нужно только чтоб вставить рыбу в упорядоченной по именам последовательности
    devnamesort.Sort(dna,dna.Size);
    //создаем матрицу для перемещения по оси У на +15
    t_matrix:=uzegeometry.CreateTranslationMatrix(createvertex(0,15,0));
    //ищем модуль с переменными дефолтными переменными для представителя устройства
    pu:=units.findunit(GetSupportPath,InterfaceTranslate,'uentrepresentation');
    //эта команда работает после указания пользователем точки вставки
    //смещение первого вставляемого элемента nulvertex
    currentcoord:=nulvertex;
    //побежали по массиву сортированных имен
    for i:=0 to dna.Size-1 do begin
      dn:=dna[i];

      //временно выключаем все расширители примитива чтоб они не скопировались
      //в клон
      extensionssave:=dn.pdev^.EntExtensions;
      dn.pdev^.EntExtensions:=nil;
      //клонируем устройство в конструкторской области
      pointer(pnevdev):=dn.pdev^.Clone(@drawings.GetCurrentDWG.ConstructObjRoot);
      //возвращаем расширители
      dn.pdev^.EntExtensions:=extensionssave;

      entvarext:=dn.pdev^.GetExtension<TVariablesExtender>;
      //добавляем клону расширение с переменными
      pnevdev^.AddExtension(TVariablesExtender.Create(pnevdev));
      delvarext:=pnevdev^.GetExtension<TVariablesExtender>;
      //добавляем устройству клона как представителя
      entvarext.addDelegate(pnevdev,delvarext);

      //копируем клону типичный набор переменных представителя
      if pu<>nil then
        delvarext.entityunit.CopyFrom(pu);

      //снова получаем расширение с переменными клона
      //оно такто уже получено
      //TODO: убрать
      delvarext:=pnevdev^.GetExtension<TVariablesExtender>;

      //выставляем клону точку вставки, ориентируем по осям, вращаем
      pnevdev.Local.P_insert:=currentcoord;
      pnevdev.Local.Basis.oz:=xy_Z_Vertex;
      pnevdev.Local.Basis.ox:=_X_yzVertex;
      pnevdev.Local.Basis.oy:=x_Y_zVertex;
      pnevdev.rotate:=0;

      //форматируем клон
      //TODO: убрать, форматировать клон надо в конце
      pnevdev^.formatEntity(drawings.GetCurrentDWG^,dc);

      //бежим по определению блока HEAD_CONNECTIONDIAGRAM
      pobj:=PBH.ObjArray.beginiterate(ir2);
      if pobj<>nil then
        repeat
          //клонируем примитивы из HEAD_CONNECTIONDIAGRAM к себе в клон
          pcobj:=pobj.Clone(pnevdev);
          //переносим их Y+15
          pcobj.transformat(pobj,@t_matrix);
          //форматируем
          pcobj^.FormatEntity(drawings.GetCurrentDWG^,dc);
          //в наш клон в динамическую часть
          pnevdev^.VarObjArray.AddPEntity(pcobj^);

          pobj:=PBH.ObjArray.iterate(ir2);
        until pobj=nil;

      //в этом меесте мы имеем клон исходного устройства с добавленым в динамическую часть
      //содержимым блока HEAD_CONNECTIONDIAGRAM

      //форматируем
      pnevdev^.formatEntity(drawings.GetCurrentDWG^,dc);
      //добавляем в чертеж
      drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.AddPEntity(pnevdev^);
      //смещаем для следующего устройства
      currentcoord.x:=currentcoord.x+45;
    end;
  end;
  dna.Destroy;
end;

procedure KIP_LugTableBuild_com.Command(Operands:TCommandOperands);
var
    psd:PSelectedObjDesc;
    ir:itrec;
    {pdev,}pnevdev:PGDBObjDevice;
    PBH:PGDBObjBlockdef;
    currentcoord:GDBVertex;
    t_matrix:DMatrix4D;
    pobj,pcobj:PGDBObjEntity;
    ir2:itrec;
    pvd:pvardesk;
    dn:tdevname;
    dna:devnamearray;
    i:integer;
    DC:TDrawContext;
    pentvarext:TVariablesExtender;
begin
     currentcoord:=nulvertex;
     dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
     drawings.GetCurrentDWG^.AddBlockFromDBIfNeed('KIP_LUGTABLEELEMENT');
     PBH:=drawings.GetCurrentDWG^.BlockDefArray.getblockdef('KIP_LUGTABLEELEMENT');
     if pbh=nil then
                    exit;
     if not PBH.Formated then
                             PBH.FormatEntity(drawings.GetCurrentDWG^,dc);
     dna:=devnamearray.Create;
     psd:=drawings.GetCurrentDWG^.SelObjArray.beginiterate(ir);
     if psd<>nil then
     repeat
           if psd^.objaddr^.GetObjType=GDBDeviceID then
           begin
                pentvarext:=psd^.objaddr^.GetExtension<TVariablesExtender>;
                //pvd:=PTEntityUnit(psd^.objaddr^.ou.Instance)^.FindVariable('DESC_MountingSite');
                pvd:=pentvarext.entityunit.FindVariable({'DESC_MountingSite'}'NMO_Name');
                if pvd<>nil then
                                dn.name:=pvd.data.PTD.GetValueAsString(pvd.data.Addr.Instance)
                            else
                                dn.name:='';
                dn.pdev:=pointer(psd^.objaddr);
                dna.PushBack(dn);
           end;
           psd:=drawings.GetCurrentDWG^.SelObjArray.iterate(ir);
     until psd=nil;

     if dna.Size=0 then
     begin
          ZCMsgCallBackInterface.TextMessage(rscmSelDevsBeforeComm,TMWOHistoryOut);
     end
     else
     begin
     devnamesort.Sort(dna,dna.Size);
     t_matrix:=uzegeometry.CreateTranslationMatrix(createvertex(50,12,0));


     for i:=0 to dna.Size-1 do
       begin
            dn:=dna[i];

            pointer(pnevdev):=dn.pdev^.Clone(@drawings.GetCurrentDWG.ConstructObjRoot);

            pnevdev.Local.P_insert:=currentcoord;
            pnevdev.Local.Basis.oz:=xy_Z_Vertex;
            pnevdev.Local.Basis.ox:=_X_yzVertex;
            pnevdev.Local.Basis.oy:=x_Y_zVertex;
            pnevdev.rotate:=0;

            //pnevdev^.BuildGeometry(drawings.GetCurrentDWG^);
            //pnevdev^.BuildVarGeometry(drawings.GetCurrentDWG^);
            pnevdev^.formatEntity(drawings.GetCurrentDWG^,dc);

            //PBH^.ObjArray.clonetransformedentityto(@pnevdev^.VarObjArray,pnevdev,t_matrix);
                 pobj:=PBH.ObjArray.beginiterate(ir2);
                 if pobj<>nil then
                 repeat
                       pcobj:=pobj.Clone(pnevdev);
                       //pobj.FormatEntity(drawings.GetCurrentDWG^);
                       pcobj.transformat(pobj,@t_matrix);
                       //pcobj.ReCalcFromObjMatrix;
                       if pcobj^.IsHaveLCS then
                                             pcobj^.FormatEntity(drawings.GetCurrentDWG^,dc);
                       pcobj^.FormatEntity(drawings.GetCurrentDWG^,dc);
                       pnevdev^.VarObjArray.AddPEntity(pcobj^);
                       pobj:=PBH.ObjArray.iterate(ir2);
                 until pobj=nil;



            pnevdev^.formatEntity(drawings.GetCurrentDWG^,dc);

            drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.AddPEntity(pnevdev^);
            currentcoord.y:=currentcoord.y-24;

            //drawings.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeTreeBB(pb);


       end;
     {psd:=drawings.GetCurrentDWG^.SelObjArray.beginiterate(ir);
     if psd<>nil then
     repeat
           if psd^.objaddr^.GetObjType=GDBDeviceID then
           begin
                pointer(pnevdev):=psd^.objaddr^.Clone(@drawings.GetCurrentDWG.ConstructObjRoot);

                pnevdev.Local.P_insert:=currentcoord;
                pnevdev.Local.Basis.oz:=xy_Z_Vertex;

                pnevdev^.BuildGeometry(drawings.GetCurrentDWG^);
                pnevdev^.BuildVarGeometry(drawings.GetCurrentDWG^);
                pnevdev^.formatEntity(drawings.GetCurrentDWG^);

                //PBH^.ObjArray.clonetransformedentityto(@pnevdev^.VarObjArray,pnevdev,t_matrix);
                     pobj:=PBH.ObjArray.beginiterate(ir2);
                     if pobj<>nil then
                     repeat
                           pcobj:=pobj.Clone(pnevdev);
                           //pobj.FormatEntity(drawings.GetCurrentDWG^);
                           pcobj.transformat(pobj,@t_matrix);
                           //pcobj.ReCalcFromObjMatrix;
                           if pcobj^.IsHaveLCS then
                                                 pcobj^.FormatEntity(drawings.GetCurrentDWG^);
                           pcobj^.FormatEntity(drawings.GetCurrentDWG^);
                           pnevdev^.VarObjArray.add(@pcobj);
                           pobj:=PBH.ObjArray.iterate(ir2);
                     until pobj=nil;



                pnevdev^.formatEntity(drawings.GetCurrentDWG^);

                drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.add(addr(pnevdev));
                currentcoord.x:=currentcoord.x+45;

                //drawings.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeTreeBB(pb);

           end;
     psd:=drawings.GetCurrentDWG^.SelObjArray.iterate(ir);
     until psd=nil;}

     end;
     dna.Destroy;
end;
(*
procedure EM_SRBUILD_com.Command(Operands:TCommandOperands);
var
      pobj: pGDBObjEntity;
      pgroupdev:pGDBObjDevice;
      ir,ir2,ir_inNodeArray:itrec;
      counter:integer;
      //tcd:TCopyObjectDesc;
      pvd:pvardesk;
      name,{material,}potrname{,potrmaterial}:String;
      p,pust,i,iust,cosf:PDouble;
      potrpust,potriust,potrpr,potrir,potrpv,potrp,potri,potrks,potrcos,sumpcos,sumpotrp,sumpotri:Double;
      cman:TCableManager;
      pcabledesk:PTCableDesctiptor;
      node:PGDBObjDevice;
      pt:PGDBObjTable;
      psl,psfirstline:PTZctnrVectorStrings;
      //first:boolean;
      s:String;
      TCP:TCodePage;
      DC:TDrawContext;
      pentvarext,pgroupdevvarext,pcablevarext:TVariablesExtender;
begin
    TCP:=CodePage;
    CodePage:=CP_win;
  counter:=0;
  cman.init;
  cman.build;
             drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));

  pobj:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pobj<>nil then
  begin
  repeat
    if pobj.selected then
    if pobj.GetObjType=GDBDeviceID then
    begin
         pentvarext:=pobj^.GetExtension<TVariablesExtender>;
         //pvd:=PTEntityUnit(pobj^.ou.Instance)^.FindVariable('Device_Type');
         pvd:=pentvarext.entityunit.FindVariable('Device_Type');
         if pvd<>nil then
         if PTDeviceType(pvd^.data.Addr.Instance)^=TDT_SilaIst then
         begin


              inc(counter);

              name:='Без имени';
              //material:='Без имени';
              pvd:=pentvarext.entityunit.FindVariable('NMO_Name');
              if pvd<>nil then
                              name:=pString(pvd.data.Addr.Instance)^;
              pvd:=pentvarext.entityunit.FindVariable('DB_link');
              //if pvd<>nil then
              //                material:=pString(pvd.Instance)^;
              ZCMsgCallBackInterface.TextMessage('Найден объект источник энергии "'+name+'"',TMWOHistoryOut);

              p:=nil;pust:=nil;i:=nil;iust:=nil;cosf:=nil;
              sumpcos:=0;

              pvd:=pentvarext.entityunit.FindVariable('Power');
              if pvd<>nil then
                              p:=pvd.data.Addr.Instance;
              pvd:=pentvarext.entityunit.FindVariable('PowerUst');
              if pvd<>nil then
                              pust:=pvd.data.Addr.Instance;
              pvd:=pentvarext.entityunit.FindVariable('Current');
              if pvd<>nil then
                              i:=pvd.data.Addr.Instance;
              pvd:=pentvarext.entityunit.FindVariable('CurrentUst');
              if pvd<>nil then
                              iust:=pvd.data.Addr.Instance;
              pvd:=pentvarext.entityunit.FindVariable('CosPHI');
              if pvd<>nil then
                              cosf:=pvd.data.Addr.Instance;
              if (p<>nil)and(pust<>nil)and(i<>nil)and(iust<>nil) then
              begin

                     Getmem(pointer(pt),sizeof(GDBObjTable));
                     pt^.initnul;
                     pt^.ptablestyle:=drawings.GetCurrentDWG.TableStyleTable.getAddres('ShRaspr');
                     pt^.tbl.free;
                     //first:=true;
                     {$ifndef GenericsContainerNotFinished}psfirstline:=pointer(pt^.tbl.CreateObject);{$endif}
                     psfirstline.init(16);

                   ZCMsgCallBackInterface.TextMessage('Текущие значения Pрасч='+floattostr(p^)+'; Iрасч='+floattostr(i^)+'; Pуст='+floattostr(pust^)+'; Iуст='+floattostr(iust^)+' будут пересчитаны',TMWOHistoryOut);
                   p^:=0;
                   pust^:=0;
                   i^:=0;
                   iust^:=0;
                   pcabledesk:=cman.beginiterate(ir2);
                   if pcabledesk<>nil then
                   repeat
                         sumpotrp:=0;
                         sumpotri:=0;
                         potrname:='';
                         if pcabledesk^.StartDevice.bp.ListPos.Owner=pointer(pobj) then
                         begin
                              ZCMsgCallBackInterface.TextMessage('  Найдена групповая линия "'+pcabledesk^.Name+'"',TMWOHistoryOut);

                              potrpust:=0;
                              potriust:=0;

                              {node:=}pcabledesk^.Devices.beginiterate(ir_inNodeArray);
                              node:=pcabledesk^.Devices.iterate(ir_inNodeArray);
                              if node<>nil then
                              repeat
                                    pgroupdev:=pointer(node.bp.ListPos.Owner);
                                    if pgroupdev<>nil then
                                    begin
                                         pgroupdevvarext:=pgroupdev^.GetExtension<TVariablesExtender>;
                                         pvd:=pgroupdevvarext.entityunit.FindVariable('Device_Type');
                                         if pvd<>nil then
                                         begin
                                              case PTDeviceType(pvd^.data.Addr.Instance)^ of
                                                   TDT_SilaPotr:
                                                                begin
                                                                      //potrmaterial:='Без имени';
                                                                      pvd:=pgroupdevvarext.entityunit.FindVariable('NMO_Name');
                                                                      if pvd<>nil then
                                                                                      begin
                                                                                           if potrname='' then
                                                                                                              potrname:=Uni2CP(pString(pvd.data.Addr.Instance)^)
                                                                                                          else
                                                                                                              potrname:=potrname+'+ '+Uni2CP(pString(pvd.data.Addr.Instance)^);
                                                                                      end;
                                                                      pvd:=pgroupdevvarext.entityunit.FindVariable('DB_link');
                                                                      //if pvd<>nil then
                                                                      //                potrmaterial:=pString(pvd.Instance)^;
                                                                      potrpv:=1;
                                                                      pvd:=pgroupdevvarext.entityunit.FindVariable('PV');
                                                                      if pvd<>nil then
                                                                                      potrpv:=pDouble(pvd.data.Addr.Instance)^;
                                                                      potrp:=0;
                                                                      pvd:=pgroupdevvarext.entityunit.FindVariable('Power');
                                                                      if pvd<>nil then
                                                                                      potrp:=pDouble(pvd.data.Addr.Instance)^;
                                                                      potri:=0;
                                                                      pvd:=pgroupdevvarext.entityunit.FindVariable('Current');
                                                                      if pvd<>nil then
                                                                                      potri:=pDouble(pvd.data.Addr.Instance)^;
                                                                      potrks:=1;
                                                                      pvd:=pgroupdevvarext.entityunit.FindVariable('Ks');
                                                                      if pvd<>nil then
                                                                                      potrks:=pDouble(pvd.data.Addr.Instance)^;
                                                                      potrcos:=1;
                                                                      pvd:=pgroupdevvarext.entityunit.FindVariable('CosPHI');
                                                                      if pvd<>nil then
                                                                                      potrcos:=pDouble(pvd.data.Addr.Instance)^;

                                                                      pust^:=pust^+potrp;
                                                                      iust^:=iust^+potri;

                                                                      sumpcos:=sumpcos+potrp*potrcos;

                                                                      potrpust:=potrpust+potrp;
                                                                      potriust:=potriust+potri;

                                                                      potrp:=potrp*potrks*sqrt(potrpv);
                                                                      potri:=potri*potrks*sqrt(potrpv);

                                                                      sumpotrp:=sumpotrp+potrp;
                                                                      sumpotri:=sumpotri+potri;

                                                                      p^:=p^+potrp;
                                                                      i^:=i^+potri;
                                                                      ZCMsgCallBackInterface.TextMessage('    Найден объект потребитель энергии "'+potrname+'"; Pрасч='+floattostr(potrp)+'; Iрасч='+floattostr(potri),TMWOHistoryOut);




//                                                                      psl:=pointer(pt^.tbl.CreateObject);
//                                                                      psl.init(16);
//                                                                      if first then
//                                                                                   begin
//                                                                                        s:=name;
//                                                                                        psl.add(@s);
//                                                                                        first:=false;
//                                                                                   end
//                                                                               else
//                                                                                   begin
//                                                                                        s:='';
//                                                                                        psl.add(@s);
//                                                                                   end;
//                                                                      s:='';
//                                                                      psl.add(@s);
//                                                                      psl.add(@s);
//                                                                      psl.add(@s);
//                                                                      psl.add(@s);
//                                                                      s:='1';
//                                                                      psl.add(@s);
//                                                                      s:=pcabledesk^.Name;
//                                                                      psl.add(@s);
//                                                                      s:='';
//                                                                      psl.add(@s);
//                                                                      s:='qwer';
//                                                                      pvd:=pcabledesk^.StartSegment^.ou.FindVariable('DB_link');
//                                                                      if pvd<>nil then
//                                                                                      s:=pString(pvd.Instance)^;
//                                                                      pvd:=pgroupdev^.ou.FindVariable('DB_link');
//                                                                      psl.add(@s);
//                                                                      s:=floattostr(pcabledesk^.length);
//                                                                      psl.add(@s);
//                                                                      s:='';
//                                                                      psl.add(@s);
//                                                                      s:='';
//                                                                      psl.add(@s);
//                                                                      s:=potrname;
//                                                                      psl.add(@s);
//                                                                      s:=floattostr(roundto(sumpotrp,-2));
//                                                                      psl.add(@s);
//                                                                      s:=floattostr(roundto(sumpotri,-2));
//                                                                      psl.add(@s);
//                                                                      s:='название';
//                                                                      psl.add(@s);

                                                                end;
                                                   TDT_SilaIst:
                                                                begin
                                                                      //potrmaterial:='Без имени';
                                                                      pvd:=pgroupdevvarext.entityunit.FindVariable('NMO_Name');
                                                                      if pvd<>nil then
                                                                                      begin
                                                                                           if potrname='' then
                                                                                                              potrname:=Uni2CP(pString(pvd.data.Addr.Instance)^)
                                                                                                          else
                                                                                                              potrname:=potrname+'+ '+Uni2CP(pString(pvd.data.Addr.Instance)^);
                                                                                      end;
                                                                      pvd:=pgroupdevvarext.entityunit.FindVariable('DB_link');
                                                                      //if pvd<>nil then
                                                                      //                potrmaterial:=pString(pvd.Instance)^;
                                                                      potrp:=0;
                                                                      pvd:=pgroupdevvarext.entityunit.FindVariable('PowerUst');
                                                                      if pvd<>nil then
                                                                                      potrp:=pDouble(pvd.data.Addr.Instance)^;
                                                                      potri:=0;
                                                                      pvd:=pgroupdevvarext.entityunit.FindVariable('CurrentUst');
                                                                      if pvd<>nil then
                                                                                      potri:=pDouble(pvd.data.Addr.Instance)^;
                                                                      potrpr:=0;
                                                                      pvd:=pgroupdevvarext.entityunit.FindVariable('Power');
                                                                      if pvd<>nil then
                                                                                      potrpr:=pDouble(pvd.data.Addr.Instance)^;
                                                                      potrir:=0;
                                                                      pvd:=pgroupdevvarext.entityunit.FindVariable('Current');
                                                                      if pvd<>nil then
                                                                                      potrir:=pDouble(pvd.data.Addr.Instance)^;
                                                                      potrcos:=1;
                                                                      pvd:=pgroupdevvarext.entityunit.FindVariable('CosPHI');
                                                                      if pvd<>nil then
                                                                                      potrcos:=pDouble(pvd.data.Addr.Instance)^;

                                                                      pust^:=pust^+potrp;
                                                                      iust^:=iust^+potri;

                                                                      sumpcos:=sumpcos+potrp*potrcos;

                                                                      potrp:=potrpr;
                                                                      potri:=potrir;

                                                                      potrpust:=potrpust+potrp;
                                                                      potriust:=potriust+potri;

                                                                      sumpotrp:=sumpotrp+potrp;
                                                                      sumpotri:=sumpotri+potri;

                                                                      p^:=p^+potrp;
                                                                      i^:=i^+potri;
                                                                      ZCMsgCallBackInterface.TextMessage('    Найден объект распределитель энергии "'+potrname+'"; Pрасч='+floattostr(potrp)+'; Iрасч='+floattostr(potri),TMWOHistoryOut);
                                                                 end;
                                              end;
                                         end;
                                         {pv:=1;
                                         pvd:=pobj^.ou.FindVariable('PV');
                                         if pvd<>nil then
                                         pv:=pDouble(pvd.Instance)^;}
                                    end;



                                    node:=pcabledesk^.Devices.iterate(ir_inNodeArray);
                              until node=nil;
                  {$ifndef GenericsContainerNotFinished} psl:=pointer(pt^.tbl.CreateObject);{$endif}
                  psl.init(16);
                  {if first then
                               begin
                                    s:=name;
                                    psl.add(@s);
                                    first:=false;
                               end
                           else}
                               begin
                                    s:='';
                                    psl.PushBackData(s);
                               end;
                  s:='';
                  psl.PushBackData(s);
                  psl.PushBackData(s);
                  psl.PushBackData(s);
                  psl.PushBackData(s);
                  s:='1';
                  psl.PushBackData(s);
                  s:=Uni2CP(pcabledesk^.Name);
                  psl.PushBackData(s);
                  s:='';
                  psl.PushBackData(s);
                  s:='qwer';
                  pcablevarext:=pcabledesk^.StartSegment^.GetExtension<TVariablesExtender>;
                  pvd:=pcablevarext.entityunit.FindVariable('DB_link');
                  if pvd<>nil then
                                  s:=Uni2CP(pString(pvd.data.Addr.Instance)^);
                  //pvd:=pgroupdev^.ou.FindVariable('DB_link');
                  psl.PushBackData(s);
                  s:=floattostr(pcabledesk^.length);
                  psl.PushBackData(s);
                  s:='';
                  psl.PushBackData(s);
                  s:='';
                  psl.PushBackData(s);
                  s:=potrname;
                  psl.PushBackData(s);
                  s:=floattostr(roundto({sumpotrp}potrpust,-2));
                  psl.PushBackData(s);
                  s:=floattostr(roundto({sumpotri}potriust,-2));
                  psl.PushBackData(s);
                  s:=Uni2CP('Потребитель');
                  psl.PushBackData(s);

                         end;

                        pcabledesk:=cman.iterate(ir2);
                   until pcabledesk=nil;


              if cosf<>nil then
              cosf^:=sumpcos/pust^;

                  s:=Uni2CP(name);
                  psfirstline.PushBackData(s);
                  s:='';
                  psfirstline.PushBackData(s);
                  psfirstline.PushBackData(s);
                  psfirstline.PushBackData(s);
                  psfirstline.PushBackData(s);
                  s:='1';
                  psfirstline.PushBackData(s);
                  s:='';
                  psfirstline.PushBackData(s);
                  s:='';
                  psfirstline.PushBackData(s);
                  //s:='qwer';
                  psfirstline.PushBackData(s);
                  //s:=floattostr(pcabledesk^.length);
                  psfirstline.PushBackData(s);
                  s:='';
                  psfirstline.PushBackData(s);
                  s:='';
                  psfirstline.PushBackData(s);
                  //s:=potrname;
                  psfirstline.PushBackData(s);
                  s:=floattostr(roundto(p^,-2));
                  psfirstline.PushBackData(s);
                  s:=floattostr(roundto(i^,-2));
                  psfirstline.PushBackData(s);
                  s:=Uni2CP('Ввод');
                  psfirstline.PushBackData(s);


              drawings.CurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pt^);
              pt^.Build(drawings.GetCurrentDWG^);
              dc:=drawings.CurrentDWG.CreateDrawingRC;
              pt^.FormatEntity(drawings.GetCurrentDWG^,dc);
              end;

         end;
    end;
  pobj:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pobj=nil;
  end;
  if counter=0 then
                   ZCMsgCallBackInterface.TextMessage('Выбери объект(ы) источник энергии!',TMWOHistoryOut);
  cman.done;
  CodePage:=TCP;
end;*)
constructor El_Wire_com.init;
begin
  inherited init(cn,sa,da);
  dyn:=false;
end;

procedure El_Wire_com.CommandStart;
begin
  inherited CommandStart(context,'');;
  FirstOwner:=nil;
  SecondOwner:=nil;
  OldFirstOwner:=nil;
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  Prompt('Начало цепи:');
end;

procedure El_Wire_com.CommandCancel;
begin
end;

function El_Wire_com.BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer;
var //po:PGDBObjSubordinated;
    Objects:GDBObjOpenArrayOfPV;
    DC:TDrawContext;
begin
  result:=0;
  Objects.init(10);
  if drawings.GetCurrentROOT.FindObjectsInPoint(wc,Objects) then
  begin
       FirstOwner:=pointer(drawings.FindOneInArray(Objects,GDBNetID,true));
  end;
  Objects.Clear;
  Objects.Done;
  (*if osp<>nil then
  begin
       if (PGDBObjEntity(osp^.PGDBObject)<>nil)and(osp^.PGDBObject<>FirstOwner)
       then
       begin
            PGDBObjEntity(osp^.PGDBObject)^.format;
            TMWOHistoryOut(Pointer(PGDBObjline(osp^.PGDBObject)^.ObjToString('Found: ','')));
            po:=PGDBObjEntity(osp^.PGDBObject)^.getowner;
            //FirstOwner:=Pointer(po);
       end
  end {else FirstOwner:=oldfirstowner};*)
  if (button and MZW_LBUTTON)<>0 then
  begin
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    Prompt('Вторая точка:');
    New_line := PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,
                                            drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,LnWtByLayer,ClByLayer,
                                            wc,wc));
    zcSetEntPropFromCurrentDrawingProp(New_line);
    //New_line := Pointer(drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBLineID{,drawings.GetCurrentROOT}));
    //GDBObjLineInit(drawings.GetCurrentROOT,New_line,drawings.GetCurrentDWG.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,wc,wc);
    New_line^.Formatentity(drawings.GetCurrentDWG^,dc);
  end
end;

function El_Wire_com.AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer;
var //po:PGDBObjSubordinated;
    mode:Integer;
    TempNet:PGDBObjNet;
    //nn:String;
    pvd{,pvd2}:pvardesk;
    nni:Integer;
    Objects:GDBObjOpenArrayOfPV;
    DC:TDrawContext;
    ptempnetvarext,pfirstownervarext,psecondownervarext:TVariablesExtender;
begin
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  New_line^.vp.Layer :=drawings.GetCurrentDWG.GetCurrentLayer;
  drawings.standardization(New_line,GDBNetID);
  New_line^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
  New_line.CoordInOCS.lEnd:= wc;
  New_line^.Formatentity(drawings.GetCurrentDWG^,dc);
  //po:=nil;
//  if (button and MZW_LBUTTON)<>0 then
//                                     button:=button;
  Objects.init(10);
  if drawings.GetCurrentROOT.FindObjectsInPoint(wc,Objects) then
  begin
       SecondOwner:=pointer(drawings.FindOneInArray(Objects,GDBNetID,true));
  end;
  Objects.Clear;
  Objects.Done;

  if osp<>nil then
  begin
       if (PGDBObjEntity(osp^.PGDBObject)<>nil)and(osp^.PGDBObject<>SecondOwner)
       then
       begin
            PGDBObjEntity(osp^.PGDBObject)^.formatentity(drawings.GetCurrentDWG^,dc);
            ZCMsgCallBackInterface.TextMessage(PGDBObjline(osp^.PGDBObject)^.ObjToString('Found: ',''),TMWOHistoryOut);
            //po:=PGDBObjEntity(osp^.PGDBObject)^.getowner;
            //SecondOwner:=Pointer(po);
       end
  end {else SecondOwner:=nil};
  //pl^.RenderFeedback;
  if (button and MZW_LBUTTON)<>0 then
  begin
    New_line^.RenderFeedback(drawings.GetCurrentDWG.pcamera^.POSCOUNT,drawings.GetCurrentDWG.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
    if FirstOwner<>nil then
    begin
         if FirstOwner^.EubEntryType<>se_ElectricalWires then FirstOwner:=nil;
    end;
    if SecondOwner<>nil then
    begin
         if SecondOwner^.EubEntryType<>se_ElectricalWires then SecondOwner:=nil;
    end;
    mode:=0;
    if (FirstOwner=nil) and (SecondOwner=nil) then mode:=0
    else if (FirstOwner<>nil) and (SecondOwner<>nil) then begin if FirstOwner<>SecondOwner then mode:=2 else begin mode:=1;SecondOwner:=nil; end;end
    else if (FirstOwner<>nil) then mode:=1
    else if (SecondOwner<>nil) then begin mode:=1; FirstOwner:=SecondOwner;SecondOwner:=nil; end;
    repeat
    case mode of
          0:begin
                 TempNet:=nil;
                 Getmem(Pointer(TempNet),sizeof(GDBObjNet));
                 TempNet^.initnul(nil);
                 zcSetEntPropFromCurrentDrawingProp(TempNet);
                 drawings.standardization(TempNet,GDBNetID);
                 ptempnetvarext:=TempNet^.GetExtension<TVariablesExtender>;
                 ptempnetvarext.entityunit.copyfrom(units.findunit(GetSupportPath,InterfaceTranslate,'trace'));
                 pvd:=ptempnetvarext.entityunit.FindVariable('NMO_Suffix');
                 pstring(pvd^.data.Addr.Instance)^:=inttostr(drawings.GetCurrentDWG.numerator.getnumber(UNNAMEDNET,SysVar.DSGN.DSGN_TraceAutoInc^));
                 pvd:=ptempnetvarext.entityunit.FindVariable('NMO_Prefix');
                 pstring(pvd^.data.Addr.Instance)^:='@';
                 pvd:=ptempnetvarext.entityunit.FindVariable('NMO_BaseName');
                 pstring(pvd^.data.Addr.Instance)^:=UNNAMEDNET;
                 //TempNet^.name:=drawings.numerator.getnamenumber(el_unname_prefix);
                 New_line^.bp.ListPos.Owner:=TempNet;
                 TempNet^.ObjArray.AddPEntity(New_line^);
                 TempNet^.Formatentity(drawings.GetCurrentDWG^,dc);
                 drawings.GetCurrentROOT.AddObjectToObjArray{ObjArray.add}(@TempNet);
                 firstowner:=TempNet;
                 mode:=-1;
            end;
          1:begin
                 New_line^.bp.ListPos.Owner:=FirstOwner;
                 FirstOwner^.ObjArray.AddPEntity(New_line^);
                 //FirstOwner^.Formatentity(drawings.GetCurrentDWG^);
                 FirstOwner.YouChanged(drawings.GetCurrentDWG^);
                 mode:=-1;
            end;
          2:begin
                 //pvd:=SecondOwner.ou.FindVariable('NMO_Name');
                 //pvd2:=firstowner.ou.FindVariable('NMO_Name');
                 nni:=SecondOwner.CalcNewName(SecondOwner,firstowner{pstring(pvd^.Instance)^,pstring(pvd2^.Instance)^});
                 if {nn<>''}nni<>0 then
                 begin
                 SecondOwner^.MigrateTo(FirstOwner);

                 if nni=1 then
                 begin
                      pfirstownervarext:=FirstOwner^.GetExtension<TVariablesExtender>;
                      pfirstownervarext.entityunit.free;
                      psecondownervarext:=secondowner^.GetExtension<TVariablesExtender>;
                      psecondownervarext.entityunit.CopyTo(@pfirstownervarext.entityunit);
                      //FirstOwner^.Name:=nn;
                 end;

                 New_line^.bp.ListPos.Owner:=FirstOwner;
                 FirstOwner^.ObjArray.AddPEntity(New_line^);
                 //FirstOwner^.Formatentity(drawings.GetCurrentDWG^);
                 FirstOwner.YouChanged(drawings.GetCurrentDWG^);
                 mode:=-1;

                 SecondOwner^.YouDeleted(drawings.GetCurrentDWG^);
                 end
                    else mode:=0;
            end;
    end;
    until mode=-1;
    drawings.GetCurrentROOT.calcbb(dc);
    drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.Count := 0;
    oldfirstowner:=firstowner;
    drawings.GetCurrentDWG.wa.param.lastonmouseobject:=nil;

    drawings.GetCurrentDWG.OnMouseObj.Clear;
    {if assigned( ClrarIfItIsProc)then
    ClrarIfItIsProc(SecondOwner);}

    zcRedrawCurrentDrawing;
    if mode= 2 then commandmanager.executecommandend
               else beforeclick(context,wc,mc,button,osp);
  end;
  result:=cmd_ok;
end;
function GetEntName(pu:PGDBObjGenericWithSubordinated):String;
var
   pvn:pvardesk;
   pentvarext:TVariablesExtender;
begin
     result:='';
     pentvarext:=pu^.GetExtension<TVariablesExtender>;
     pvn:=pentvarext.entityunit.FindVariable('NMO_Name');
     if (pvn<>nil) then
                                      begin
                                           result:=pstring(pvn^.data.Addr.Instance)^;
                                      end;
end;
procedure cabcomformat;
var
   s:String;
   ir_inGDB:itrec;
   currentobj:PGDBObjNet;
begin
  cabcomparam.Traces.Enums.free;
  cabcomparam.PTrace:=nil;

  CurrentObj:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir_inGDB);
  if (CurrentObj<>nil) then
     repeat
           if CurrentObj^.GetObjType=GDBNetID then
           begin
                s:=getentname(CurrentObj);
                if s<>'' then
                begin
                     cabcomparam.Traces.Enums.PushBackData(s);
                     if cabcomparam.Traces.Selected=cabcomparam.Traces.Enums.Count-1 then
                                                                                         cabcomparam.PTrace:=CurrentObj;


                end;
           end;
           CurrentObj:=drawings.GetCurrentROOT.ObjArray.iterate(ir_inGDB);
     until CurrentObj=nil;

  s:='**Напрямую**';
  cabcomparam.Traces.Enums.PushBackData(s);
end;
function _Cable_com_CommandStart(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   s:String;
   ir_inGDB:itrec;
   currentobj:PGDBObjNet;
begin
  p3dpl:=nil;
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));

  cabcomparam.Pcable:=nil;
  cabcomparam.PTrace:=nil;
  cabcomparam.Traces.Enums.free;
  //cabcomparam.Traces.Selected:=-1;
  CurrentObj:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir_inGDB);
  if (CurrentObj<>nil) then
     repeat
           if CurrentObj^.GetObjType=GDBNetID then
           begin
                s:=getentname(CurrentObj);
                if s<>'' then
                begin
                     cabcomparam.Traces.Enums.PushBackData(s);
                     if CurrentObj^.Selected then
                     begin
                          cabcomparam.Traces.Selected:=cabcomparam.Traces.Enums.Count-1;
                     end;

                     if cabcomparam.Traces.Selected=cabcomparam.Traces.Enums.Count-1 then
                                                                                         cabcomparam.PTrace:=CurrentObj;


                end;
           end;
           CurrentObj:=drawings.GetCurrentROOT.ObjArray.iterate(ir_inGDB);
     until CurrentObj=nil;

  s:='**Напрямую**';
  cabcomparam.Traces.Enums.PushBackData(s);
  zcShowCommandParams(SysUnit.TypeName2PTD('CommandRTEdObject'),pcabcom);



  ZCMsgCallBackInterface.TextMessage('Первая точка:',TMWOHistoryOut);
  result:=cmd_ok;
end;
Procedure _Cable_com_CommandEnd(const Context:TZCADCommandContext;_self:pointer);
begin
  if p3dpl<>nil then
  begin
  PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.PushEndMarker;
  if p3dpl^.VertexArrayInOCS.Count<2 then
                                         begin
                                              ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
                                              p3dpl^.YouDeleted(drawings.GetCurrentDWG^);
                                              PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.KillLastCommand;
                                         end;
  end;
  cabcomparam.PCable:=nil;
  cabcomparam.PTrace:=nil;
  //Freemem(pointer(p3dpl));
end;
function _Cable_com_BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
var
   pvd:pvardesk;
   domethod,undomethod:tmethod;
   DC:TDrawContext;
   pcablevarext:TVariablesExtender;
begin
  result:=mclick;
  if (button and MZW_LBUTTON)<>0 then
  begin
    if p3dpl=nil then
    begin
      dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    p3dpl := Pointer(drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBCableID,drawings.GetCurrentROOT));
    //p3dpl := Pointer(drawings.GetCurrentROOT.ObjArray.CreateinitObj(GDBCableID,drawings.GetCurrentROOT));
    zcSetEntPropFromCurrentDrawingProp(p3dpl);
    drawings.standardization(p3dpl,GDBCableID);
    //p3dpl^.init(@drawings.GetCurrentDWG.ObjRoot,drawings.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^);

    //uunitmanager.units.loadunit(expandpath('*blocks\el\cable.pas'),@p3dpl^.ou);
    pcablevarext:=p3dpl^.GetExtension<TVariablesExtender>;
    pcablevarext.entityunit.copyfrom(units.findunit(GetSupportPath,InterfaceTranslate,'cable'));
    //pvd:=p3dpl^.ou.FindVariable('DB_link');
    //pstring(pvd^.Instance)^:='Кабель ??';

    {pvd:=p3dpl.ou.FindVariable('NMO_BaseName');
    pstring(pvd^.Instance)^:=drawings.numerator.getnamenumber('К');}
    //pvd:=p3dpl.ou.FindVariable('NMO_Prefix');
    //pstring(pvd^.Instance)^:='';

    //pvd:=p3dpl.ou.FindVariable('NMO_BaseName');
    //pstring(pvd^.Instance)^:='@';

    pvd:=pcablevarext.entityunit.FindVariable('NMO_Suffix');
    pstring(pvd^.data.Addr.Instance)^:=inttostr(drawings.GetCurrentDWG.numerator.getnumber('CableNum',true));
    //p3dpl^.bp.Owner:=@drawings.GetCurrentDWG.ObjRoot;
    //drawings.GetCurrentDWG.ObjRoot.ObjArray.add(addr(p3dpl));
    //GDBobjinsp.setptr(SysUnit.TypeName2PTD('GDBObjCable'),p3dpl);
    p3dpl^.AddVertex(wc);
    p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);

    PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.PushStartMarker('Create cable');
    SetObjCreateManipulator(domethod,undomethod);
    with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG).UndoStack,tmethod(domethod),tmethod(undomethod),1) do
    begin
         AddObject(p3dpl);
         comit;
    end;
    PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.PushStone;
    drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.Count:=0;

    //drawings.GetCurrentROOT.ObjArray.ObjTree.{AddObjectToNodeTree(p3dpl)}CorrectNodeTreeBB(p3dpl);

    cabcomparam.Pcable:=p3dpl;
    //GDBobjinsp.setptr(SysUnit.TypeName2PTD('GDBObjCable'),p3dpl);
    end;
  end
end;
procedure AddPolySegmentFromConnIfZnotMatch(const PrevPoint,NextPoint:GDBVertex;cable:PGDBObjCable);
begin
  if IsDoubleNotEqual(PrevPoint.z,NextPoint.z) then begin
    cable^.AddVertex(CreateVertex(NextPoint.x,NextPoint.y,PrevPoint.z));
    cable^.AddVertex(NextPoint);
  end else
    cable^.AddVertex(NextPoint);
end;
procedure AddPolySegmentToConnIfZnotMatch(const PrevPoint,NextPoint:GDBVertex;cable:PGDBObjCable);
begin
  if IsDoubleNotEqual(PrevPoint.z,NextPoint.z) then begin
    cable^.AddVertex(CreateVertex(PrevPoint.x,PrevPoint.y,NextPoint.z));
    cable^.AddVertex(NextPoint);
  end else
    cable^.AddVertex(NextPoint);
end;
procedure AddPolySegmentIfZnotMatch(const PrevPoint,NextPoint:GDBVertex;cable:PGDBObjCable);
var
  MidPoint:GDBVertex;
begin
  if IsDoubleNotEqual(PrevPoint.z,NextPoint.z) then begin
    MidPoint:=Vertexmorph(PrevPoint,NextPoint,0.5);
    cable^.AddVertex(CreateVertex(MidPoint.x,MidPoint.y,PrevPoint.z));
    cable^.AddVertex(CreateVertex(MidPoint.x,MidPoint.y,NextPoint.z));
    cable^.AddVertex(NextPoint);
  end else
    cable^.AddVertex(NextPoint);
end;

procedure rootbytrace(firstpoint,lastpoint:GDBVertex;PTrace:PGDBObjNet;cable:PGDBObjCable;addfirstpoint:Boolean);
var //po:PGDBObjSubordinated;
    //plastw:pgdbvertex;
    tw1,tw2:gdbvertex;
    l1,l2:pgdbobjline;
    pa:GDBPoint3dArray;
    //prevpoint:GDBVertex;
    //polydata:tpolydata;
    //domethod,undomethod:tmethod;
begin
  if ptrace<>nil then begin
    pointer(l1):=PTrace.GetNearestLine(firstpoint);
    pointer(l2):=PTrace.GetNearestLine(lastpoint);
    tw1:=NearestPointOnSegment(firstpoint,l1.CoordInWCS.lBegin,l1.CoordInWCS.lEnd);
    if l1=l2 then
                 begin
                      if addfirstpoint then
                        cable^.AddVertex(firstpoint);
                      if not IsPointEqual(tw1,firstpoint,sqreps) then
                        AddPolySegmentFromConnIfZnotMatch(firstpoint,tw1,cable);
                      tw2:=NearestPointOnSegment(lastpoint,l1.CoordInWCS.lBegin,l1.CoordInWCS.lEnd);
                      cable^.AddVertex(tw2);
                      if not IsPointEqual(tw2,lastpoint,sqreps) then
                        AddPolySegmentToConnIfZnotMatch(tw2,lastpoint,cable);
                 end
             else
                 begin
                      tw2:=NearestPointOnSegment(lastpoint,l2.CoordInWCS.lBegin,l2.CoordInWCS.lEnd);
                      PTrace.BuildGraf(drawings.GetCurrentDWG^);
                      pa.init(100);
                      PTrace.graf.FindPath(tw1,tw2,l1,l2,pa);
                      if addfirstpoint then
                      cable^.AddVertex(firstpoint);
                      if not IsPointEqual(tw1,firstpoint,sqreps) then
                        AddPolySegmentFromConnIfZnotMatch(firstpoint,tw1,cable);
                                                          //cable^.AddVertex(tw1);
                      pa.copyto(cable.VertexArrayInOCS);
                      //firstpoint:=pgdbvertex(cable^.VertexArrayInWCS.getDataMutable(cable^.VertexArrayInWCS.Count-1))^;
                      //if not IsPointEqual(tw2,firstpoint) then
                        cable^.AddVertex(tw2);
                      if not IsPointEqual(tw2,lastpoint,sqreps) then
                        AddPolySegmentToConnIfZnotMatch(tw2,lastpoint,cable);
                                                     //cable^.AddVertex(lastpoint);
                      pa.done;
                 end;

  end else begin
    if addfirstpoint then
      cable^.AddVertex(firstpoint);
    AddPolySegmentIfZnotMatch(firstpoint,lastpoint,cable);
  end;
end;
function RootByMultiTrace(firstpoint,lastpoint:GDBVertex;PTrace:PGDBObjNet;cable:PGDBObjCable;addfirstpoint:Boolean):TZctnrVectorPGDBaseObjects;
var //po:PGDBObjSubordinated;
    //plastw:pgdbvertex;
    tw1,tw2:gdbvertex;
    l1,l2:pgdbobjline;
    pa:GDBPoint3dArray;
    pv:pGDBVertex;
    ir:itrec;
    tcable:PGDBObjCable;
    pvd:pvardesk;
    cablecount:integer;
    //polydata:tpolydata;
    //domethod,undomethod:tmethod;
    ptcablevarext,pcablevarext:TVariablesExtender;
begin
  pointer(l1):=PTrace.GetNearestLine(firstpoint);
  pointer(l2):=PTrace.GetNearestLine(lastpoint);
  tw1:=NearestPointOnSegment(firstpoint,l1.CoordInWCS.lBegin,l1.CoordInWCS.lEnd);
  result.init(100);
  if l1=l2 then
               begin
                 if addfirstpoint then
                   cable^.AddVertex(firstpoint);
                 if not IsPointEqual(tw1,firstpoint,sqreps) then
                   AddPolySegmentFromConnIfZnotMatch(firstpoint,tw1,cable);
                 tw2:=NearestPointOnSegment(lastpoint,l1.CoordInWCS.lBegin,l1.CoordInWCS.lEnd);
                 cable^.AddVertex(tw2);
                 if not IsPointEqual(tw2,lastpoint,sqreps) then
                   AddPolySegmentToConnIfZnotMatch(tw2,lastpoint,cable);
               end
           else
               begin
                    tw2:=NearestPointOnSegment(lastpoint,l2.CoordInWCS.lBegin,l2.CoordInWCS.lEnd);
                    PTrace.BuildGraf(drawings.GetCurrentDWG^);
                    pa.init(100);
                    PTrace.graf.FindPath(tw1,tw2,l1,l2,pa);
                    if addfirstpoint then
                    cable^.AddVertex(firstpoint);
                    if not IsPointEqual(tw1,firstpoint,sqreps) then
                      AddPolySegmentFromConnIfZnotMatch(firstpoint,tw1,cable);

                    //pa.copyto(@cable.VertexArrayInOCS);
                    tcable:=cable;
  cablecount:=1;
  pv:=pa.beginiterate(ir);
  if pv<>nil then
  repeat
        if pv^.x<>infinity then
                               tcable.VertexArrayInOCS.PushBackData(pv^)
                           else
                               begin
                                    tcable := AllocCable;
                                    tcable.init(drawings.GetCurrentROOT,nil,0);
                                    //tcable := Pointer(drawings.GetCurrentROOT.ObjArray.CreateinitObj(GDBCableID,drawings.GetCurrentROOT));
                                    ptcablevarext:=tcable^.GetExtension<TVariablesExtender>;
                                    pcablevarext:=cable^.GetExtension<TVariablesExtender>;
                                    ptcablevarext.entityunit.copyfrom(@pcablevarext.entityunit);
                                    drawings.standardization(tcable,GDBCableID);
                                    pvd:=ptcablevarext.entityunit.FindVariable('CABLE_Segment');
                                    if pvd<>nil then
                                    PInteger(pvd^.data.Addr.Instance)^:=PInteger(pvd^.data.Addr.Instance)^+cablecount;
                                    inc(cablecount);
                                    result.PushBackData(tcable);
                               end;
        pv:=pa.iterate(ir);
  until pv=nil;


                    //firstpoint:=pgdbvertex(cable^.VertexArrayInWCS.getDataMutable(cable^.VertexArrayInWCS.Count-1))^;
                    //if not IsPointEqual(tw2,firstpoint) then
                      tcable^.AddVertex(tw2);
                    if not IsPointEqual(tw2,lastpoint,sqreps) then
                      AddPolySegmentToConnIfZnotMatch(tw2,lastpoint,tcable);
                    pa.done;
               end;
end;


function _Cable_com_AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
var //po:PGDBObjSubordinated;
    plastw:pgdbvertex;
    //tw1,tw2:gdbvertex;
    //l1,l2:pgdbobjline;
    //pa:GDBPoint3dArray;
    polydata:tpolydata;
    domethod,undomethod:tmethod;
    DC:TDrawContext;
begin
  result:=mclick;
  p3dpl^.vp.Layer :=drawings.GetCurrentDWG.GetCurrentLayer;
  p3dpl^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
  drawings.standardization(p3dpl,GDBCableID);
  //p3dpl^.CoordInOCS.lEnd:= wc;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  if (button and MZW_LBUTTON)<>0 then
  begin
    if cabcomparam.PTrace=nil then
    begin
         {polydata.nearestvertex:=p3dpl^.VertexArrayInWCS.Count;
         polydata.nearestline:=p3dpl^.VertexArrayInWCS.Count;
         polydata.dir:=1;}
         polydata.index:=p3dpl^.VertexArrayInWCS.Count;
         polydata.wc:=wc;
         tmethod(domethod).Code:=pointer(p3dpl.InsertVertex);
         tmethod(domethod).Data:=p3dpl;
         tmethod(undomethod).Code:=pointer(p3dpl.DeleteVertex);
         tmethod(undomethod).Data:=p3dpl;
         with GUCmdChgMethods<TPolyData>.CreateAndPush(polydata,domethod,undomethod,(PTZCADDrawing(drawings.GetCurrentDWG).UndoStack),drawings.AfterAutoProcessGDB) do
         begin
              comit;
         end;
          {p3dpl^.AddVertex(wc);}
          p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
          p3dpl^.RenderFeedback(drawings.GetCurrentDWG.pcamera^.POSCOUNT,drawings.GetCurrentDWG.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
          drawings.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeBoundingBox(p3dpl^);
    end
else begin
          plastw:=p3dpl^.VertexArrayInWCS.getDataMutable(p3dpl^.VertexArrayInWCS.Count-1);

          rootbytrace(plastw^,wc,cabcomparam.PTrace,p3dpl,false);

          (*pointer(l1):=cabcomparam.PTrace.GetNearestLine(plastw^);
          pointer(l2):=cabcomparam.PTrace.GetNearestLine(wc);
          tw1:=NearestPointOnSegment(plastw^,l1.CoordInWCS.lBegin,l1.CoordInWCS.lEnd);
          if l1=l2 then
                       begin
                            if not IsPointEqual(tw1,plastw^) then
                                                                p3dpl^.AddVertex(tw1);
                            tw1:=NearestPointOnSegment(wc,l1.CoordInWCS.lBegin,l1.CoordInWCS.lEnd);
                            if not IsPointEqual(tw1,wc) then
                                                           p3dpl^.AddVertex(tw1);
                            p3dpl^.AddVertex(wc);
                            //l1:=l2;
                       end
                   else
                       begin
                            tw2:=NearestPointOnSegment(wc,l2.CoordInWCS.lBegin,l2.CoordInWCS.lEnd);
                            cabcomparam.PTrace.BuildGraf;
                            pa.init(100);
                            cabcomparam.PTrace.graf.FindPath(tw1,tw2,l1,l2,pa);
                            if not IsPointEqual(tw1,plastw^) then
                                                                p3dpl^.AddVertex(tw1);
                            pa.copyto(@p3dpl.VertexArrayInOCS);
                            plastw:=p3dpl^.VertexArrayInWCS.getDataMutable(p3dpl^.VertexArrayInWCS.Count-1);
                            if not IsPointEqual(tw2,plastw^) then
                                                                p3dpl^.AddVertex(tw2);
                            if not IsPointEqual(tw2,wc) then
                                                           p3dpl^.AddVertex(wc);
                            pa.done;
                       end;*)
        p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
        p3dpl^.RenderFeedback(drawings.GetCurrentDWG.pcamera^.POSCOUNT,drawings.GetCurrentDWG.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
        drawings.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeBoundingBox(p3dpl^);
     end;
    drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.Count := 0;
    result:=1;
    zcRedrawCurrentDrawing;
  end;
end;
function _Cable_com_Hd(mclick:Integer):TCommandResult;
begin
     //mclick:=mclick;//        asdf
     result:=cmd_ok;
end;
//function _Cable_com_Legend(Operands:pansichar):Integer;
//var i: Integer;
//    pv:pGDBObjEntity;
//    ir,irincable,ir_inNodeArray:itrec;
//    filename,cablename,CableMaterial,CableLength,devstart,devend: String;
//    handle:cardinal;
//    pvd,pvds,pvdal:pvardesk;
//    nodeend,nodestart:PTNodeProp;
//
//    line:String;
//    firstline:boolean;
//    cman:TCableManager;
//begin
//  cman.init;
//  cman.build;
//  cman.done;
//  //exit;
//  if SaveFileDialog(filename,'CSV',CSVFileFilter,'','Сохранить данные...') then
//  begin
//  handle:=FileCreate(filename,fmOpenWrite);
//  line:='Обозначение'+';'+'Материал'+';'+'Длина'+';'+'Начало'+';'+'Конец'+#13#10;
//  FileWrite(handle,line[1],length(line));
//  pv:=drawings.GetCurrentDWG.ObjRoot.ObjArray.beginiterate(ir);
//  if pv<>nil then
//  repeat
//    //if pv^.Selected then
//    if pv^.GetObjType=GDBCableID then
//    begin
//         line:='';
//         pvd:=pv^.ou.FindVariable('NMO_Name');
//         cablename:=pstring(pvd^.Instance)^;
//
//         pvd:=pv^.ou.FindVariable('DB_link');
//         CableMaterial:=pstring(pvd^.Instance)^;
//
//         pvd:=pv^.ou.FindVariable('AmountD');
//         CableLength:=floattostr(pDouble(pvd^.Instance)^);
//
//          firstline:=true;
//          devstart:='Не присоединено';
//          nodestart:=pgdbobjcable(pv)^.NodePropArray.beginiterate(ir_inNodeArray);
//          if nodestart^.DevLink<>nil then
//                                         begin
//                                              pvd:=nodestart^.DevLink^.FindVariable('NMO_Name');
//                                              if pvd<>nil then
//                                                              devstart:=pstring(pvd^.Instance)^;
//                                         end;
//          nodeend:=pgdbobjcable(pv)^.NodePropArray.iterate(ir_inNodeArray);
//          repeat
//                devend:='Не присоединено';
//                repeat
//                            if nodeend=nil then system.break;
//                            //nodeend:=pgdbobjcable(pv)^.NodePropArray.iterate(ir_inNodeArray);
//                            if nodeend^.DevLink=nil then
//                            repeat
//                                  nodeend:=pgdbobjcable(pv)^.NodePropArray.iterate(ir_inNodeArray);
//                                  if nodeend=nil then system.break;
//                            until nodeend^.DevLink<>nil;
//                            if nodeend=nil then system.break;
//                            pvd:=nodeend^.DevLink^.FindVariable('NMO_Name');
//                            if pvd=nil then
//                                           nodeend:=pgdbobjcable(pv)^.NodePropArray.iterate(ir_inNodeArray);
//                until pvd<>nil;
//                if nodeend<>nil then
//                                    devend:=pstring(pvd^.Instance)^;
//                if firstline then
//                                 line:=cablename+';'+CableMaterial+';'+CableLength+';'+devstart+';'+devend+#13#10
//                             else
//                                 line:={cablename+}';'+{CableMaterial+}';'+{CableLength+}';'+devstart+';'+devend+#13#10;
//                FileWrite(handle,line[1],length(line));
//                firstline:=false;
//                devstart:=devend;
//                nodeend:=pgdbobjcable(pv)^.NodePropArray.iterate(ir_inNodeArray);
//          until nodeend=nil;
//         ZCMsgCallBackInterface.TextMessage(cablename+' '+CableMaterial+' '+CableLength);
//
//
//    end;
//  pv:=drawings.GetCurrentDWG.ObjRoot.ObjArray.iterate(ir);
//  until pv=nil;
//  redrawoglwnd;
//  FileClose(handle);
//  end;
//  result:=cmd_ok;
//end;
function _Cable_com_Legend(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var //i: Integer;
    pv:PTCableDesctiptor;
    ir,{irincable,}ir_inNodeArray:itrec;
    filename,cablename,CableMaterial,CableLength,devstart,devend,puredevstart: String;
    handle:cardinal;
    pvd{,pvds,pvdal}:pvardesk;
    nodeend,nodestart:PGDBObjDevice;

    line,s:String;
    firstline:boolean;
    cman:TCableManager;
    pt:PGDBObjTable;
    psl{,psfirstline}:PTZctnrVectorStrings;

    eq:pvardesk;
    DC:TDrawContext;
    pstartsegmentvarext:TVariablesExtender;
begin
  filename:='';
  if SaveFileDialog(filename,'CSV',CSVFileFilter,'','Сохранить данные...') then
  begin
  DefaultFormatSettings.DecimalSeparator := ',';
  cman.init;
  cman.build;
  handle:=FileCreate(UTF8ToSys(filename),fmOpenWrite);
  line:=Tria_Utf8ToAnsi('Обозначение'+';'+'Материал'+';'+'Длина'+';'+'Начало'+';'+'Конец'+#13#10);
  FileWrite(handle,line[1],length(line));
  pv:=cman.beginiterate(ir);
  if pv<>nil then
  begin
                     Getmem(pointer(pt),sizeof(GDBObjTable));
                     pt^.initnul;
                     zcSetEntPropFromCurrentDrawingProp(pt);
                     pt^.ptablestyle:=drawings.GetCurrentDWG.TableStyleTable.getAddres('KZ');
                     pt^.tbl.free;
  repeat
    begin
         cablename:=pv^.Name;

//         if cablename='RS' then
//                               cablename:=cablename;

         pstartsegmentvarext:=pv^.StartSegment^.GetExtension<TVariablesExtender>;
         pvd:=pstartsegmentvarext.entityunit.FindVariable('DB_link');
         CableMaterial:=pstring(pvd^.data.Addr.Instance)^;

                                        eq:=DWGDBUnit.FindVariable(CableMaterial);
                                        if eq<>nil then
                                                      begin
                                                           CableMaterial:=PDbBaseObject(eq^.data.Addr.Instance)^.NameShort;
                                                      end;
         CableLength:=floattostr(pv^.length);

          firstline:=true;
          devstart:='Не присоединено';
          nodestart:=pv^.Devices.beginiterate(ir_inNodeArray);
          if pv^.StartDevice<>nil then
                                         begin
                                              pvd:=FindVariableInEnt(pv^.StartDevice,'NMO_Name');
                                              if pvd<>nil then
                                                              devstart:=pstring(pvd^.data.Addr.Instance)^;
                                              nodeend:=pv^.Devices.iterate(ir_inNodeArray);
                                         end
                                  else
                                      nodeend:=nodestart;
          puredevstart:=devstart;
                psl:=pt^.tbl.CreateObject;
                psl.init(12);
          repeat
                devend:='Не присоединено';
                repeat
                            if nodeend=nil then system.break;
                            pvd:=FindVariableInEnt(nodeend,'NMO_Name');
                            if pvd=nil then
                                           nodeend:=pv^.Devices.iterate(ir_inNodeArray);
                until pvd<>nil;
                if nodeend<>nil then
                                    devend:=pstring(pvd^.data.Addr.Instance)^;
                {psl:=pointer(pt^.tbl.CreateObject);
                psl.init(12);}
                if firstline then
                                 begin
                                 line:='`'+cablename+';'+CableMaterial+';'+CableLength+';'+devstart+';'+devend+#13#10;
                                 s:='';
                                 psl.PushBackData(Tria_Utf8ToAnsi(cablename));
                                 psl.PushBackData(Tria_Utf8ToAnsi(devstart));
                                 {psl.add(@devend);
                                 psl.add(@s);
                                 psl.add(@s);
                                 psl.add(@s);
                                 psl.add(@s);
                                 psl.add(@CableMaterial);
                                 psl.add(@CableLength);}
                                 end
                             else
                                 begin
                                 line:={cablename+}';'+{CableMaterial+}';'+{CableLength+}';'+devstart+';'+devend+#13#10;
                                 {s:='';
                                 psl.add(@s);
                                 psl.add(@devstart);
                                 psl.add(@devend);
                                 psl.add(@s);
                                 psl.add(@s);
                                 psl.add(@s);
                                 psl.add(@s);
                                 psl.add(@s);
                                 psl.add(@s);}
                                 end;
                line:=Tria_Utf8ToAnsi(line);
                FileWrite(handle,line[1],length(line));
                firstline:=false;
                devstart:=devend;
                nodeend:=pv^.Devices.iterate(ir_inNodeArray);
          until nodeend=nil;
                                 s:='';
                                 psl.PushBackData(Tria_Utf8ToAnsi(devend));
                                 psl.PushBackData(Tria_Utf8ToAnsi(s));
                                 psl.PushBackData(Tria_Utf8ToAnsi(s));
                                 psl.PushBackData(Tria_Utf8ToAnsi(s));
                                 psl.PushBackData(Tria_Utf8ToAnsi(s));
                                 psl.PushBackData(Tria_Utf8ToAnsi(CableMaterial));
                                 psl.PushBackData(Tria_Utf8ToAnsi(CableLength));
                                 psl.PushBackData(Tria_Utf8ToAnsi(s));
                                 psl.PushBackData(Tria_Utf8ToAnsi(s));
                                 s:='';
                                 psl.PushBackData(Tria_Utf8ToAnsi(s));

         //ZCMsgCallBackInterface.TextMessage('Cable "'+pv^.Name+'", segments '+inttostr(pv^.Segments.Count)+', материал "'+CableMaterial+'", начало: '+puredevstart+' конец: '+devend,TMWOHistoryOut);
         ZCMsgCallBackInterface.TextMessage(format('Cable %s, %d segments, %s, from: %s to: %s',[pv^.Name,pv^.Segments.Count,CableMaterial,puredevstart,devend]),TMWOHistoryOut);


    end;
  pv:=cman.iterate(ir);
  until pv=nil;

  drawings.GetCurrentROOT.AddObjectToObjArray{ObjArray.add}(@pt);
  pt^.Build(drawings.GetCurrentDWG^);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pt^.FormatEntity(drawings.GetCurrentDWG^,dc);
  end;
  zcRedrawCurrentDrawing;
  FileClose(handle);
  cman.done;
  DefaultFormatSettings.DecimalSeparator := '.';
  end;
  result:=cmd_ok;
end;
function _Material_com_Legend(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var //i: Integer;
    pv:pGDBObjEntity;
    ir,{irincable,ir_inNodeArray,}ir_inscf:itrec;
    s,filename{,cablename,CableMaterial,CableLength,devstart}: String;
    currentgroup:PString;
    handle:cardinal;
    pvad,pvai,pvm:pvardesk;
    //nodeend,nodestart:PTNodeProp;

    line:String;
    //firstline:boolean;

    bom:GDBBbillOfMaterial;
    PBOMITEM:PGDBBOMItem;

    pt:PGDBObjTable;
    psl{,psfirstline}:PTZctnrVectorStrings;

    pdbu:ptunit;
    pdbv:pvardesk;
    pdbi:PDbBaseObject;

    cman:TCableManager;
    pcd:PTCableDesctiptor;
    DC:TDrawContext;
    pcablevarext,pstartsegmentvarext:TVariablesExtender;
begin
  filename:='';
  if SaveFileDialog(filename,'CSV',CSVFileFilter,'','Сохранить данные...') then
  begin
  bom.init(1000);
  handle:=FileCreate(UTF8ToSys(filename),fmOpenWrite);
  line:=Tria_Utf8ToAnsi('Материал'+';'+'Количество'+';'+'Устройства'+#13#10);
  FileWrite(handle,line[1],length(line));
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.GetObjType<>GDBCableID then
    begin
    pcablevarext:=pv^.GetExtension<TVariablesExtender>;
    if pcablevarext<>nil then
    begin
         pvm:=pcablevarext.entityunit.FindVariable('DB_link');
         if pvm<>nil then
         begin
              pvad:=pcablevarext.entityunit.FindVariable('AmountD');
              pvai:=pcablevarext.entityunit.FindVariable('AmountI');
              //if (pvad<>nil)or(pvai<>nil) then
              begin
                   pbomitem:=bom.findorcreate(pstring(pvm^.data.Addr.Instance)^);
                   if pbomitem<>nil then
                   begin
                        if (pvad<>nil) then
                                           pbomitem.Amount:=pbomitem.Amount+pDouble(pvad^.data.Addr.Instance)^
                   else if (pvai<>nil) then
                                           pbomitem.Amount:=pbomitem.Amount+PInteger(pvai^.data.Addr.Instance)^
                   else
                       pbomitem.Amount:=pbomitem.Amount+1;
                        pvm:=pcablevarext.entityunit.FindVariable('NMO_Name');
                        if (pvm<>nil) then
                                           if pbomitem.Names<>'' then
                                                                     pbomitem.Names:=pbomitem.Names+','+pstring(pvm^.data.Addr.Instance)^
                                                                 else
                                                                     pbomitem.Names:=pstring(pvm^.data.Addr.Instance)^;


                   end;
              end;
         end;
    end;
    end;
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;

  cman.init;
  cman.build;

  pcd:=cman.beginiterate(ir);
  if pcd<>nil then
  repeat


  if pcd.StartSegment<>nil then
  begin
  pstartsegmentvarext:=pcd.StartSegment^.GetExtension<TVariablesExtender>;
  pvm:=pstartsegmentvarext.entityunit.FindVariable('DB_link');
  if pvm<>nil then
  begin
       begin
            pbomitem:=bom.findorcreate(pstring(pvm^.data.Addr.Instance)^);
            if pbomitem<>nil then
            begin
                 pbomitem.Amount:=pbomitem.Amount+pcd.length;
            end;
       end;
  end;
  end;


  pcd:=cman.iterate(ir);
  until pcd=nil;

  cman.done;

  DefaultFormatSettings.DecimalSeparator := ',';
  PBOMITEM:=bom.beginiterate(ir);
  if PBOMITEM<>nil then
  repeat
          line:=pbomitem.Material+';'+floattostr(pbomitem.Amount)+';'+pbomitem.Names+#13#10;
          line:=Tria_Utf8ToAnsi(line);
          FileWrite(handle,line[1],length(line));

        PBOMITEM:=bom.iterate(ir);
  until PBOMITEM=nil ;
  DefaultFormatSettings.DecimalSeparator := '.';
  FileClose(handle);


                     Getmem(pointer(pt),sizeof(GDBObjTable));
                     pt^.initnul;
                     zcSetEntPropFromCurrentDrawingProp(pt);
                     pt^.ptablestyle:=drawings.GetCurrentDWG.TableStyleTable.getAddres('Spec');
                     pt^.tbl.free;

  pdbu:=PTZCADDrawing(drawings.GetCurrentDWG).DWGUnits.findunit(GetSupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName);
  currentgroup:=MainSpecContentFormat.beginiterate(ir_inscf);
  if currentgroup<>nil then
  if length(currentgroup^)>1 then
  repeat
  if currentgroup^[1]='!' then
              begin
                   psl:=pt^.tbl.CreateObject;
                   //psl:=pointer(pt^.tbl.CreateObject);
                   psl.init(2);

                   s:='';
                   psl.PushBackData(s);

                   s:=Tria_Utf8ToAnsi(currentgroup^);
                   s:='  '+system.copy(s,2,length(s)-1);
                   //s:='  '+system.copy(currentgroup^,2,length(currentgroup^)-1);
                   psl.PushBackData(s);
            end

  else
      begin
        PBOMITEM:=bom.beginiterate(ir);
        if PBOMITEM<>nil then
        repeat
              pdbv:=pdbu^.FindVariable(PBOMITEM^.Material);
              if pdbv<>nil then
              if not(PBOMITEM.processed) then

              begin
                   pdbi:=pdbv^.data.Addr.Instance;
                   if MatchesMask(pdbi^.Group,currentgroup^) then

                   begin
                   PBOMITEM.processed:=true;
                   psl:=pt^.tbl.CreateObject;
                   psl.init(9);

                   s:=pdbi^.Position;
                   psl.PushBackData(Tria_Utf8ToAnsi(s));

                   s:=' '+pdbi^.NameFull;
                   psl.PushBackData(Tria_Utf8ToAnsi(s));

                   s:=pdbi^.NameShort+' '+pdbi^.Standard;
                   psl.PushBackData(Tria_Utf8ToAnsi(s));

                   s:=pdbi^.OKP;
                   psl.PushBackData(Tria_Utf8ToAnsi(s));

                   s:=pdbi^.Manufacturer;
                   psl.PushBackData(Tria_Utf8ToAnsi(s));

                   s:='??';
                   case pdbi^.EdIzm of
                                      _sht:s:='шт.';
                                      _m:s:='м';
                   end;
                   psl.PushBackData(Tria_Utf8ToAnsi(s));

                   s:=floattostr(PBOMITEM^.Amount);
                   psl.PushBackData(s);

                   s:='';
                   psl.PushBackData(Tria_Utf8ToAnsi(s));
                   psl.PushBackData(Tria_Utf8ToAnsi(s));
                   end;


              end;
                line:=pbomitem.Material+';'+floattostr(pbomitem.Amount)+';'+pbomitem.Names+#13#10;
                FileWrite(handle,line[1],length(line));

              PBOMITEM:=bom.iterate(ir);
        until PBOMITEM=nil;
      end;

        currentgroup:=MainSpecContentFormat.iterate(ir_inscf);
  until currentgroup=nil;

  drawings.GetCurrentROOT.AddObjectToObjArray{ObjArray.add}(@pt);
  pt^.Build(drawings.GetCurrentDWG^);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pt^.FormatEntity(drawings.GetCurrentDWG^,dc);


  zcRedrawCurrentDrawing;
  bom.done;
  end;
  result:=cmd_ok;
end;
function _Cable_com_Select(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var //i: Integer;
    pv:pGDBObjEntity;
    ir,irnpa:itrec;
    ptn{,ptnfirst,ptnfirst2,ptnlast,ptnlast2}:PTNodeProp;
    currentobj{,CurrentSubObj,CurrentSubObj2,ptd}:PGDBObjDevice;
begin
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
    if pv^.GetObjType=GDBCableID then
    begin
             ptn:=PGDBObjCable(pv)^.NodePropArray.beginiterate(irnpa);
             if ptn<>nil then
                repeat
                    if ptn^.DevLink<>nil then
                    begin
                    CurrentObj:=pointer(ptn^.DevLink^.bp.ListPos.owner);
                    if CurrentObj<>nil then
                                           CurrentObj^.select(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.selector);
                    end;

                    ptn:=PGDBObjCable(pv)^.NodePropArray.iterate(irnpa);
                until ptn=nil;
    end;
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;
{
function _Ren_n_to_0n_com(Operands:pansichar):Integer;
var len: Integer;
    pv:pGDBObjEntity;
    ir:itrec;
    pvd:pvardesk;
    name:String;
begin
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.GetObjType=GDBCableID then
    begin
         pvd:=pv^.ou.FindVariable('NMO_Name');
         if pvd<>nil then
                         begin
                              name:=pString(pvd.Instance)^;
                              len:=length(name);
                              if len=3 then
                              if name[len] in ['0'..'9'] then
                              if not(name[len-1] in ['0'..'9']) then
                              begin
                                   name:=system.copy(name,1,len-1)+'0'+system.copy(name,len,1);
                                   pString(pvd.Instance)^:=name;
                                   ZCMsgCallBackInterface.TextMessage('Переименован кабель '+name);
                              end
                         end;
    end;
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
end;
}
function VarReport_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var pv:pGDBObjEntity;
    ir:itrec;
    pvd:pvardesk;
    name,content:String;
    VarContents:TZctnrVectorStrings;
    ps{,pspred}:pString;
    pentvarext:TVariablesExtender;
begin
  if operands<>''then
  begin
  VarContents.init(100);
  name:=Operands;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
    begin
    pentvarext:=pv^.GetExtension<TVariablesExtender>;
    pvd:=pentvarext.entityunit.FindVariable(name);
    if pvd<>nil then
    begin
         content:=pvd.data.PTD.GetValueAsString(pvd.data.Addr.Instance);
    end
       else
           begin
                content:='Переменной в описании примитива не обнаружено';
           end;
    VarContents.PushBackData(content);
    end;
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  VarContents.sort;

  ps:=VarContents.beginiterate(ir);
  if (ps<>nil) then
  repeat
       ZCMsgCallBackInterface.TextMessage(ps^,TMWOHistoryOut);
       ps:=VarContents.iterate(ir);
  until ps=nil;

  VarContents.Done;
  end
  else
      ZCMsgCallBackInterface.TextMessage('Имя переменной должно быть задано в параметре команды',TMWOHistoryOut);
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;

function _Cable_com_Invert(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var //i: Integer;
    pv:pGDBObjEntity;
    ir:itrec;
    DC:TDrawContext;
begin
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
    if pv^.GetObjType=GDBCableID then
    begin
         PGDBObjCable(pv)^.VertexArrayInOCS.invert;
         pv^.Formatentity(drawings.GetCurrentDWG^,dc);
         ZCMsgCallBackInterface.TextMessage('Направление изменено',TMWOHistoryOut);
    end;
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;
function _Cable_com_Join(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var //i: Integer;
    pv:pGDBObjEntity;
    pc1,pc2:PGDBObjCable;
    pv11,pv12,pv21,pv22:Pgdbvertex;
    ir:itrec;
    DC:TDrawContext;
begin
  pc1:=nil;
  pc2:=nil;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
    if pv^.GetObjType=GDBCableID then
    begin
         if pc1=nil then
                        pc1:=pointer(pv)
    else if pc2=nil then
                        pc2:=pointer(pv)
    else begin
              ZCMsgCallBackInterface.TextMessage('Выбрано больше 2х кабелей!',TMWOHistoryOut);
              exit;
         end;
    end;
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  if pc2=nil then
                 begin
                      ZCMsgCallBackInterface.TextMessage('Выбери 2 кабеля!',TMWOHistoryOut);
                      exit;
                 end;
  pv11:=pc1.VertexArrayInWCS.getDataMutable(0);
  pv12:=pc1.VertexArrayInWCS.getDataMutable(pc1.VertexArrayInWCS.Count-1);
  pv21:=pc2.VertexArrayInWCS.getDataMutable(0);
  pv22:=pc2.VertexArrayInWCS.getDataMutable(pc2.VertexArrayInWCS.Count-1);

     if uzegeometry.Vertexlength(pv11^,pv21^)<eps then
                                                   begin
                                                        pc1.VertexArrayInOCS.Invert;
                                                        pc2.VertexArrayInOCS.deleteelement(0);
                                                        pc2.VertexArrayInOCS.copyto(pc1.VertexArrayInOCS);
                                                        pc2.YouDeleted(drawings.GetCurrentDWG^);
                                                   end
else if uzegeometry.Vertexlength(pv12^,pv21^)<eps then
                                                   begin
                                                        pc2.VertexArrayInOCS.deleteelement(0);
                                                        pc2.VertexArrayInOCS.copyto(pc1.VertexArrayInOCS);
                                                        pc2.YouDeleted(drawings.GetCurrentDWG^);
                                                   end
else if uzegeometry.Vertexlength(pv11^,pv22^)<eps then
                                                   begin
                                                        pc1.VertexArrayInOCS.deleteelement(0);
                                                        pc1.VertexArrayInOCS.copyto(pc2.VertexArrayInOCS);
                                                        pc1.YouDeleted(drawings.GetCurrentDWG^);
                                                        pc1:=pc2
                                                   end
else if uzegeometry.Vertexlength(pv12^,pv22^)<eps then
                                                   begin
                                                        pc2.VertexArrayInOCS.Invert;
                                                        pc2.VertexArrayInOCS.deleteelement(0);
                                                        pc2.VertexArrayInOCS.copyto(pc1.VertexArrayInOCS);
                                                        pc2.YouDeleted(drawings.GetCurrentDWG^);
                                                   end
else
                                                   begin
                                                        ZCMsgCallBackInterface.TextMessage('Кабели не соединены!',TMWOHistoryOut);
                                                        exit;
                                                   end;



  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pc1.formatentity(drawings.GetCurrentDWG^,dc);
  drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount:=0;
  drawings.GetCurrentDWG.wa.param.seldesc.OnMouseObject:=nil;
  drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject:=nil;
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
  clearcp;

  //redrawoglwnd;
  result:=cmd_ok;
end;
function Find_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
//var i: Integer;
   // pv:pGDBObjEntity;
   // ir:itrec;
begin
  zcShowCommandParams(SysUnit.TypeName2PTD('CommandRTEdObject'),pfindcom);
  drawings.GetCurrentDWG.SelObjArray.Free;
  drawings.GetCurrentROOT.ObjArray.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.GetCurrentDWG^.deselector);
  result:=cmd_ok;
  zcRedrawCurrentDrawing;
end;
procedure commformat;
var pv,pvlast:pGDBObjEntity;
    v:pvardesk;
    varvalue,sourcestr,varname:String;
    ir:itrec;
    count:integer;
    //a:HandledMsg;
    tpz{, glx1, gly1}: Double;
  {fv1,}{tp,}wcsLBN,wcsRTF,dcsLBN,dcsRTF: GDBVertex;
    findvarvalue:Boolean;
    DC:TDrawContext;
    pentvarext:TVariablesExtender;
begin
  drawings.GetCurrentDWG.SelObjArray.Free;
  drawings.GetCurrentROOT.ObjArray.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.GetCurrentDWG^.deselector);
   case FindDeviceParam.FindType of
      TFT_Obozn:begin
                     varname:=('NMO_Name');
                end;
      TFT_DBLink:begin
                     varname:=('DB_link');
                end;
      TFT_DESC_MountingDrawing:begin
                     varname:=('DESC_MountingDrawing');
                end;
      TFT_variable:;//заглушка для warning
   end;

  sourcestr:=uppercase(FindDeviceParam.FindString);

  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  count:=0;
  if pv<>nil then
  repeat
        pentvarext:=pv^.GetExtension<TVariablesExtender>;
        if pentvarext<>nil then
        begin
        findvarvalue:=false;
        v:=pentvarext.entityunit.FindVariable(varname);
        if v<>nil then
        begin
             varvalue:=uppercase(v^.data.PTD.GetValueAsString(v^.data.Addr.Instance));
             findvarvalue:=true;
        end;

        if findvarvalue then
        begin

              case FindDeviceParam.FindMethod of
                   true:begin
                              if MatchesMask(varvalue,sourcestr) then
                                                                     findvarvalue:=true
                                                                 else
                                                                     findvarvalue:=false;
                        end;
                   false:
                         begin
                              if sourcestr=varvalue then
                                                        findvarvalue:=true
                                                    else
                                                        findvarvalue:=false;
                         end;
               end;

               if findvarvalue then
               begin
                  pv^.select(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.selector);
                  pvlast:=pv;
                  inc(count);
               end;
        end;
        end;

  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;



  if count=1 then
  begin
        dcsLBN:=InfinityVertex;
        dcsRTF:=MinusInfinityVertex;
        wcsLBN:=InfinityVertex;
        wcsRTF:=MinusInfinityVertex;
        {tp:=}drawings.getcurrentdwg.wa.ProjectPoint(pvlast^.vp.BoundingBox.LBN.x,pvlast^.vp.BoundingBox.LBN.y,pvlast^.vp.BoundingBox.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
        {tp:=}drawings.getcurrentdwg.wa.ProjectPoint(pvlast^.vp.BoundingBox.RTF.x,pvlast^.vp.BoundingBox.LBN.y,pvlast^.vp.BoundingBox.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
        {tp:=}drawings.getcurrentdwg.wa.ProjectPoint(pvlast^.vp.BoundingBox.RTF.x,pvlast^.vp.BoundingBox.RTF.y,pvlast^.vp.BoundingBox.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
        {tp:=}drawings.getcurrentdwg.wa.ProjectPoint(pvlast^.vp.BoundingBox.LBN.x,pvlast^.vp.BoundingBox.RTF.y,pvlast^.vp.BoundingBox.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
        {tp:=}drawings.getcurrentdwg.wa.ProjectPoint(pvlast^.vp.BoundingBox.LBN.x,pvlast^.vp.BoundingBox.LBN.y,pvlast^.vp.BoundingBox.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
        {tp:=}drawings.getcurrentdwg.wa.ProjectPoint(pvlast^.vp.BoundingBox.RTF.x,pvlast^.vp.BoundingBox.LBN.y,pvlast^.vp.BoundingBox.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
        {tp:=}drawings.getcurrentdwg.wa.ProjectPoint(pvlast^.vp.BoundingBox.RTF.x,pvlast^.vp.BoundingBox.RTF.y,pvlast^.vp.BoundingBox.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
        {tp:=}drawings.getcurrentdwg.wa.ProjectPoint(pvlast^.vp.BoundingBox.LBN.x,pvlast^.vp.BoundingBox.RTF.y,pvlast^.vp.BoundingBox.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
  drawings.GetCurrentDWG.pcamera^.prop.point.x:=-(wcsLBN.x+(wcsRTF.x-wcsLBN.x)/2);
  drawings.GetCurrentDWG.pcamera^.prop.point.y:=-(wcsLBN.y+(wcsRTF.y-wcsLBN.y)/2);


  drawings.GetCurrentDWG.pcamera^.prop.zoom:=(wcsRTF.x-wcsLBN.x)/drawings.GetCurrentDWG.wa.getviewcontrol.clientwidth;
  tpz:=(wcsRTF.y-wcsLBN.y)/drawings.GetCurrentDWG.wa.getviewcontrol.clientheight;

  if tpz>drawings.GetCurrentDWG.pcamera^.prop.zoom then drawings.GetCurrentDWG.pcamera^.prop.zoom:=tpz;

  drawings.GetCurrentDWG.wa.CalcOptimalMatrix;
  drawings.GetCurrentDWG.wa.mouseunproject(drawings.GetCurrentDWG.wa.param.md.mouse.x, drawings.GetCurrentDWG.wa.param.md.mouse.y);
  drawings.GetCurrentDWG.wa.reprojectaxis;
  //OGLwindow1.param.firstdraw := true;
  //drawings.GetCurrentDWG.pcamera^.getfrustum(@drawings.GetCurrentDWG.pcamera^.modelMatrix,@drawings.GetCurrentDWG.pcamera^.projMatrix,drawings.GetCurrentDWG.pcamera^.clipLCS,drawings.GetCurrentDWG.pcamera^.frustum);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  drawings.GetCurrentROOT.FormatEntity(drawings.GetCurrentDWG^,dc);
  //drawings.GetCurrentDWG.ObjRoot.calcvisible;
  //drawings.GetCurrentDWG.ConstructObjRoot.calcvisible;
  end;
  zcRedrawCurrentDrawing;
  //ZCMsgCallBackInterface.TextMessage('Найдено '+inttostr(count)+' объектов',TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage(format('Founded %d entities',[count]),TMWOHistoryOut);
end;
function _Cable_mark_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var //i: Integer;
    pv:pGDBObjDevice;
    ir{,irincable,ir_inNodeArray}:itrec;
    //filename,cablename,CableMaterial,CableLength,devstart,devend: String;
    //handle:cardinal;
    pvn{,pvm,pvmc,pvl}:pvardesk;
    //nodeend,nodestart:PTNodeProp;

    //line:String;
    cman:TCableManager;
    pcd:PTCableDesctiptor;
    DC:TDrawContext;
    pentvarext:TVariablesExtender;
begin
  cman.init;
  cman.build;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    begin
         if pv^.GetObjType=GDBDeviceID then
         if pv^.Name='CABLE_MARK' then
         begin
              pentvarext:=pv^.GetExtension<TVariablesExtender>;
              pvn:=pentvarext.entityunit.FindVariable('CableName');
              if (pvn<>nil) then
              begin
                   pcd:=cman.Find(pstring(pvn^.data.Addr.Instance)^);
                   if pcd<>nil then
                   begin
                        Cable2CableMark(pcd,pv);
                        {pvm:=pv^.ou.FindVariable('CableMaterial');
                        if pvm<>nil then
                                    begin
                                        pvmc:=pcd^.StartSegment^.FindVariable('DB_link');
                                        if pvmc<>nil then
                                        begin
                                        line:=pstring(pvmc^.Instance)^;
                                        pstring(pvm^.Instance)^:=line;
                                        end
                                        else
                                            pString(pvm^.Instance)^:='Не определен';
                                    end;
                       pvl:=pv^.ou.FindVariable('CableLength');
                       if pvl<>nil then
                                       pDouble(pvl^.Instance)^:=pcd^.length;}
                       pv^.Formatentity(drawings.GetCurrentDWG^,dc);
                   end
                      else
                          //ZCMsgCallBackInterface.TextMessage('Кабель "'+pstring(pvn^.data.Addr.Instance)^+'" на плане не найден',TMWOHistoryOut);
                          ZCMsgCallBackInterface.TextMessage(format('Cable %s not found on plan',[pstring(pvn^.data.Addr.Instance)^]),TMWOHistoryOut);
              end;
         end;
    end;
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;

  zcRedrawCurrentDrawing;
  cman.done;
  result:=cmd_ok;
end;
function El_Leader_com_AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
var //po:PGDBObjSubordinated;
    pleader:PGDBObjElLeader;
    domethod,undomethod:tmethod;
    DC:TDrawContext;
    pcablevarext:TVariablesExtender;
begin
  //result:=Line_com_AfterClick(wc,mc,button,osp,mclick);
  result:=mclick;
  PCreatedGDBLine^.vp.Layer :=drawings.GetCurrentDWG.GetCurrentLayer;
  PCreatedGDBLine^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
  PCreatedGDBLine^.CoordInOCS.lEnd:= wc;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  PCreatedGDBLine^.Formatentity(drawings.GetCurrentDWG^,dc);
  //po:=nil;
  if osp<>nil then
  begin
       if (PGDBObjEntity(osp^.PGDBObject)<>nil)and(osp^.PGDBObject<>pold)
       then
       begin
            PGDBObjEntity(osp^.PGDBObject)^.formatentity(drawings.GetCurrentDWG^,dc);
            //PGDBObjEntity(osp^.PGDBObject)^.ObjToString('Found: ','');
            ZCMsgCallBackInterface.TextMessage(PGDBObjline(osp^.PGDBObject)^.ObjToString('Found: ',''),TMWOHistoryOut);
            //po:=PGDBObjEntity(osp^.PGDBObject)^.getowner;
            pold:=osp^.PGDBObject;
       end
  end else pold:=nil;
  //pl^.RenderFeedback;
  if (button and MZW_LBUTTON)<>0 then
  begin
    begin
    PCreatedGDBLine^.bp.ListPos.Owner:=drawings.GetCurrentROOT;

  Getmem(pointer(pleader),sizeof(GDBObjElLeader));
  pleader^.initnul;
  //pleader^.ou.copyfrom(units.findunit('_riser'));
  pleader^.scale:=ELLeaderComParam.Scale;
  pleader^.size:=ELLeaderComParam.Size;
  pleader^.twidth:=ELLeaderComParam.twidth;

  pcablevarext:=pleader^.GetExtension<TVariablesExtender>;
  if pcablevarext<>nil then
    pcablevarext.entityunit.copyfrom(units.findunit(GetSupportPath,InterfaceTranslate,'elleader'));

  zcSetEntPropFromCurrentDrawingProp(pleader);
  drawings.standardization(pleader,GDBELleaderID);
  pleader.MainLine.CoordInOCS.lBegin:=PCreatedGDBLine^.CoordInOCS.lBegin;
  pleader.MainLine.CoordInOCS.lEnd:=PCreatedGDBLine^.CoordInOCS.lEnd;


  SetObjCreateManipulator(domethod,undomethod);
  with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG).UndoStack,tmethod(domethod),tmethod(undomethod),1) do
  begin
       AddObject(pleader);
       comit;
  end;

  //drawings.GetCurrentROOT.AddObjectToObjArray{ObjArray.add}(@pleader);
  pleader^.Formatentity(drawings.GetCurrentDWG^,dc);
  //pleader.BuildGeometry;

    end;
    drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.free;
    result:=-1;
    zcRedrawCurrentDrawing;
  end;
end;
function ElLeaser_com_CommandStart(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  pold:=nil;
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  sysvarDWGOSMode:=sysvarDWGOSMode or osm_nearest;
  zcShowCommandParams(SysUnit.TypeName2PTD('TELLeaderComParam'),@ELLeaderComParam);
  ZCMsgCallBackInterface.TextMessage('Первая точка:',TMWOHistoryOut);
  result:=cmd_ok;
end;
function _Cable_com_Manager(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
//var i: Integer;
    //pv:pGDBObjEntity;
    //ir:itrec;
begin
        CableManager.init;
        CableManager.build;
        zcShowCommandParams(SysUnit.TypeName2PTD('TCableManager'),@CableManager);
        result:=cmd_ok;
end;
function _Ren_n_to_0n_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var {i,}len: Integer;
    pv:pGDBObjEntity;
    ir:itrec;
    pvd{,pvn,pvm,pvmc,pvl}:pvardesk;
    name:String;
    pentvarext:TVariablesExtender;
begin
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.GetObjType=GDBCableID then
    begin
         pentvarext:=pv^.GetExtension<TVariablesExtender>;
         pvd:=pentvarext.entityunit.FindVariable('NMO_Name');
         if pvd<>nil then
                         begin
                              name:=pString(pvd.data.Addr.Instance)^;
                              len:=length(name);
                              if len=3 then
                              if name[len] in ['0'..'9'] then
                              if not(name[len-1] in ['0'..'9']) then
                              begin
                                   name:=system.copy(name,1,len-1)+'0'+system.copy(name,len,1);
                                   pString(pvd.data.Addr.Instance)^:=name;
                                   //ZCMsgCallBackInterface.TextMessage('Переименован кабель '+name,TMWOHistoryOut);
                                   ZCMsgCallBackInterface.TextMessage(format('Cable %s renamed',[name]),TMWOHistoryOut);
                              end
                                 {else
                                     ZCMsgCallBackInterface.TextMessage(name);;}
                         end;
    end;
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  result:=cmd_ok;
end;
function _SelectMaterial_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var //i,len: Integer;
    pv:pGDBObjEntity;
    ir:itrec;
    pvd{,pvn,pvm,pvmc,pvl}:pvardesk;
    mat:String;
    pentvarext:TVariablesExtender;
begin
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if (pv^.GetObjType=GDBCableID)
    or (pv^.GetObjType=GDBCableID) then
    begin
         pentvarext:=pv^.GetExtension<TVariablesExtender>;
         pvd:=pentvarext.entityunit.FindVariable('DB_link');
         if pvd<>nil then
                         begin
                              mat:=pString(pvd.data.Addr.Instance)^;
                              if uppercase(mat)=uppercase(operands) then
                                                                        begin
                                                                        //pv^.Select;
                                                                        pString(pvd.data.Addr.Instance)^:='ТППэП 20х2х0.5';
                                                                        end;
                         end;
    end;
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  result:=cmd_ok;
  //commandmanager.executecommandend;
  //OGLwindow1.SetObjInsp;
      //updatevisible;
end;
function findconnector(CurrentObj:PGDBObjDevice):PGDBObjDevice;
var
    CurrentSubObj:PGDBObjDevice;
    {ir_inGDB,ir_inVertexArray,ir_inNodeArray,}ir_inDevice:itrec;
begin
     result:=nil;
CurrentSubObj:=CurrentObj^.VarObjArray.beginiterate(ir_inDevice);
if (CurrentSubObj<>nil) then
repeat
      if (CurrentSubObj^.GetObjType=GDBDeviceID) then
      begin
      if CurrentSubObj^.BlockDesc.BType=BT_Connector then
                                                         begin
                                                              result:=CurrentSubObj;
                                                              exit;
                                                         end;
      end;
      CurrentSubObj:=CurrentObj^.VarObjArray.iterate(ir_inDevice);
until CurrentSubObj=nil;
end;
function CreateCable(name,mater:String):PGDBObjCable;
var
    //vd,pvn,pvn2: pvardesk;
    pvd{,pvd2}:pvardesk;
    pentvarext:TVariablesExtender;
begin
  result := AllocCable;
  result.init(drawings.GetCurrentROOT,nil,0);
  //result := Pointer(drawings.GetCurrentROOT.ObjArray.CreateInitObj(GDBCableID,drawings.GetCurrentROOT));
  pentvarext:=result^.GetExtension<TVariablesExtender>;
  pentvarext.entityunit.copyfrom(units.findunit(GetSupportPath,InterfaceTranslate,'cable'));
  pvd:=pentvarext.entityunit.FindVariable('NMO_Suffix');
  pstring(pvd^.data.Addr.Instance)^:='';
  pvd:=pentvarext.entityunit.FindVariable('NMO_Prefix');
  pstring(pvd^.data.Addr.Instance)^:='';
  pvd:=pentvarext.entityunit.FindVariable('NMO_BaseName');
  pstring(pvd^.data.Addr.Instance)^:='';
  pvd:=pentvarext.entityunit.FindVariable('NMO_Template');
  pstring(pvd^.data.Addr.Instance)^:='';
  pvd:=pentvarext.entityunit.FindVariable('NMO_Name');
  pstring(pvd^.data.Addr.Instance)^:=name;
  pvd:=pentvarext.entityunit.FindVariable('DB_link');
  pstring(pvd^.data.Addr.Instance)^:=mater;

  pvd:=pentvarext.entityunit.FindVariable('CABLE_AutoGen');
  pBoolean(pvd^.data.Addr.Instance)^:=true;
  zcSetEntPropFromCurrentDrawingProp(result);
  drawings.standardization(result,GDBCableID);
end;

function _El_ExternalKZ_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
    FDoc: TCSVDocument;
    isload:boolean;
    s: String;
    row,col:integer;
    startdev,enddev,riser,riser2:PGDBObjDevice;
    supernet,net,net2:PGDBObjNet;
    cable:PGDBObjCable;
    pvd,pvd2:pvardesk;
    netarray,riserarray,linesarray:TZctnrVectorPGDBaseObjects;
    processednets:TZctnrVectorPGDBaseObjects;
    segments:TZctnrVectorPGDBaseObjects;

    ir_net,ir_net2,ir_riser,ir_riser2:itrec;
    nline,new_line:pgdbobjline;
    np:GDBVertex;
    //net2processed:boolean;
    vd,pvn,pvn2: pvardesk;
    supernetsarray:GDBObjOpenArrayOfPV;
    DC:TDrawContext;
    priservarext,priser2varext,psupernetvarext,pnetvarext,plinevarext:TVariablesExtender;
    lph:TLPSHandle;
procedure GetStartEndPin(startdevname,enddevname:String);
begin
  PGDBObjEntity(startdev):=drawings.FindEntityByVar(GDBDeviceID,'NMO_Name',startdevname);
  PGDBObjEntity(enddev):=drawings.FindEntityByVar(GDBDeviceID,'NMO_Name',enddevname);
  if startdev=nil then
                      //ZCMsgCallBackInterface.TextMessage('В строке '+inttostr(row)+' не найдено стартовое устройство '+startdevname,TMWOHistoryOut)
                      ZCMsgCallBackInterface.TextMessage(format('In row %d startdevice "%s" not found',[row,startdevname]),TMWOHistoryOut)
                  else
                      begin
                      startdev:=findconnector(startdev);
                      if startdev=nil then
                                          //ZCMsgCallBackInterface.TextMessage('В строке '+inttostr(row)+' не найден коннектор стартового устройства '+startdevname,TMWOHistoryOut);
                                          ZCMsgCallBackInterface.TextMessage(format('In row %d startdevice "%s" connector not found',[row,startdevname]),TMWOHistoryOut)
                      end;
  if enddev=nil then
                    //ZCMsgCallBackInterface.TextMessage('В строке '+inttostr(row)+' не найдено конечное устройство '+enddevname,TMWOHistoryOut)
                    ZCMsgCallBackInterface.TextMessage(format('In row %d enddevice "%s" not found',[row,enddevname]),TMWOHistoryOut)
                  else
                      begin
                      enddev:=findconnector(enddev);
                      if enddev=nil then
                                        //ZCMsgCallBackInterface.TextMessage('В строке '+inttostr(row)+' не найден коннектор конечного устройства '+enddevname,TMWOHistoryOut);
                                        ZCMsgCallBackInterface.TextMessage(format('In row %d enddevice "%s" connector not found',[row,enddevname]),TMWOHistoryOut);

                      end;
end;
procedure LinkRisersToNets;
begin
  drawings.FindMultiEntityByVar2(GDBDeviceID,'RiserName',riserarray);
  supernet:=nil;
  net:=netarray.beginiterate(ir_net);
  if (net<>nil) then
  repeat
        net.riserarray.Clear;
        riser:=riserarray.beginiterate(ir_riser);
        if (riser<>nil) then
        repeat
              pointer(nline):=net.GetNearestLine(riser.P_insert_in_WCS);
              np:=NearestPointOnSegment(riser.P_insert_in_WCS,nline.CoordInWCS.lBegin,nline.CoordInWCS.lEnd);
              if IsPointEqual(np,riser.P_insert_in_WCS,sqreps)then
              begin
                   net.riserarray.PushBackData(riser);
              end;
              riser:=riserarray.iterate(ir_riser);
        until riser=nil;
        net:=netarray.iterate(ir_net);
  until net=nil;
end;

begin
  linesarray.init(10);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  if length(operands)=0 then
                     begin
                          isload:=OpenFileDialog(s,'csv',CSVFileFilter,'','Открыть журнал...');
                          if not isload then
                                            begin
                                                 result:=cmd_cancel;
                                                 exit;
                                            end
                                        else
                                            begin

                                            end;

                     end
                 else
                 begin
                                           begin
                                           s:=ExpandPath(operands);
                                           s:=FindInSupportPath(GetSupportPath,operands);
                                           end;
                 end;
  isload:=FileExists(utf8tosys(s));
  if isload then
  begin
       processednets.init(100);
       supernetsarray.init(100);
       FDoc:=TCSVDocument.Create;
       FDoc.Delimiter:=';';
       FDoc.LoadFromFile(utf8tosys(s));
       lph:=lps.StartLongProcess('Create cables',nil,FDoc.RowCount);
       netarray.init(100);
       for row:=0 to FDoc.RowCount-1 do
       begin
            if FDoc.ColCount[row]>4 then
            begin
            netarray.Clear;
            drawings.FindMultiEntityByVar(GDBNetID,'NMO_Name',FDoc.Cells[3,row],netarray);

                 GetStartEndPin(FDoc.Cells[1,row],FDoc.Cells[2,row]);
                 if (startdev<>nil)and(enddev<>nil) then
                 if netarray.Count=1 then
                 begin
                  PGDBaseObject(net):=netarray.getDataMutable(0);
                 if net=nil then
                                //ZCMsgCallBackInterface.TextMessage('В строке '+inttostr(row)+' не найдена трасса '+FDoc.Cells[3,row],TMWOHistoryOut);
                                ZCMsgCallBackInterface.TextMessage(format('In row %d trace "%s" not found',[row,FDoc.Cells[3,row]]),TMWOHistoryOut);
                 if (net<>nil) then
                 begin
                 if (startdev<>nil)and(enddev<>nil) then
                 begin
                 cable:=CreateCable(FDoc.Cells[0,row],FDoc.Cells[4,row]);
                 rootbytrace(startdev.P_insert_in_WCS,enddev.P_insert_in_WCS,net,Cable,true);
                 zcAddEntToCurrentDrawingWithUndo(Cable);
                 Cable^.Formatentity(drawings.GetCurrentDWG^,dc);
                 Cable^.RenderFeedback(drawings.GetCurrentDWG.pcamera^.POSCOUNT,drawings.GetCurrentDWG.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
                 end;

                 end;
                 end
                 else
                     begin
                          if netarray.Count>1 then
                          begin
                          supernet:=PGDBObjNet(FindEntityByVar(supernetsarray,GDBNetID,'NMO_Name',FDoc.Cells[3,row]));

                          if supernet=nil then
                          begin
                          riserarray.init(100);
                          drawings.FindMultiEntityByVar2(GDBDeviceID,'RiserName',riserarray);

                          LinkRisersToNets;
                          processednets.Clear;
                          net:=netarray.beginiterate(ir_net);
                          if (net<>nil) then
                          repeat
                                pnetvarext:=net^.GetExtension<TVariablesExtender>;
                                net2:=netarray.beginiterate(ir_net2);

                                if (net2<>nil) then
                                repeat
                                      if net<>net2 then
                                      begin
                                      riser:=net.riserarray.beginiterate(ir_riser);
                                      if (riser<>nil) then
                                      repeat
                                            priservarext:=riser^.GetExtension<TVariablesExtender>;
                                            riser2:=net2.riserarray.beginiterate(ir_riser2);
                                            if (riser2<>nil) then
                                            repeat
                                                  if not uzegeometry.vertexeq(riser2.P_insert_in_WCS,riser.P_insert_in_WCS) then
                                                  begin
                                                  priser2varext:=riser2^.GetExtension<TVariablesExtender>;
                                                  pvd:=priservarext.entityunit.FindVariable('RiserName');
                                                  pvd2:=priser2varext.entityunit.FindVariable('RiserName');
                                                  if (pvd<>nil)and(pvd2<>nil) then
                                                  begin
                                                       if pstring(pvd^.data.Addr.Instance)^=pstring(pvd2^.data.Addr.Instance)^then
                                                       begin
                                                            if supernet=nil then
                                                            begin
                                                                 Getmem(supernet,sizeof(GDBObjNet));
                                                                 supernet.initnul(nil);
                                                                 psupernetvarext:=supernet.GetExtension<TVariablesExtender>;
                                                                 psupernetvarext.entityunit.copyfrom(@pnetvarext.entityunit);
                                                            end;
                                                            if not processednets.IsDataExist(net)<>-1 then
                                                            begin
                                                                 net.objarray.copyto(supernet.ObjArray);
                                                                 processednets.PushBackData(net);
                                                            end;

                                                            if not processednets.IsDataExist(net2)<>-1 then
                                                            begin
                                                                 net2.objarray.copyto(supernet.ObjArray);
                                                                 processednets.PushBackData(net2);
                                                            end;

                                                                New_line:=PGDBObjLine(ENTF_CreateLine(drawings.GetCurrentROOT,nil,
                                                                                                      drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,LnWtByLayer,ClByLayer,
                                                                                                      riser.P_insert_in_WCS,riser2.P_insert_in_WCS));
                                                                zcSetEntPropFromCurrentDrawingProp(New_line);
                                                                plinevarext:=New_line^.GetExtension<TVariablesExtender>;
                                                                if plinevarext=nil then
                                                                                       plinevarext:=AddVariablesToEntity(New_line);
                                                                plinevarext.entityunit.copyfrom(units.findunit(GetSupportPath,InterfaceTranslate,'_riserlink'));
                                                                vd:=plinevarext.entityunit.FindVariable('LengthOverrider');

                                                                pvn :=FindVariableInEnt(riser,'Elevation');
                                                                pvn2:=FindVariableInEnt(riser,'Elevation');
                                                                if (pvn<>nil)and(pvn2<>nil)and(vd<>nil)then
                                                                begin
                                                                     pDouble(vd^.data.Addr.Instance)^:=abs(pDouble(pvn^.data.Addr.Instance)^-pDouble(pvn2^.data.Addr.Instance)^);
                                                                end;
                                                                New_line^.Formatentity(drawings.GetCurrentDWG^,dc);
                                                                supernet^.ObjArray.AddPEntity(New_line^);
                                                                linesarray.PushBackData(New_line);
//                                                            pvd:=pvd;
                                                       end;
                                                  end;
                                                  end;

                                                 riser2:=net2.riserarray.iterate(ir_riser2);
                                            until riser2=nil;


                                           riser:=net.riserarray.iterate(ir_riser);
                                      until riser=nil;

                                end;
                                net2:=netarray.iterate(ir_net2);
                                until net2=nil;

                                net:=netarray.iterate(ir_net);
                          until (net=nil);
                          riserarray.Clear;
                          riserarray.Done;
                          if supernet<>nil then
                                          supernetsarray.PushBackData(supernet);
                          end;
//                             else
//                                 supernet:=supernet;

                          if supernet<>nil then
                          begin
                          cable:=CreateCable(FDoc.Cells[0,row],FDoc.Cells[4,row]);

                          segments:=rootbymultitrace(startdev.P_insert_in_WCS,enddev.P_insert_in_WCS,supernet,Cable,true);
                          zcAddEntToCurrentDrawingWithUndo(Cable);
                          zcSetEntPropFromCurrentDrawingProp(Cable);
                          drawings.standardization(Cable,GDBCableID);
                          Cable^.Formatentity(drawings.GetCurrentDWG^,dc);
                          Cable^.RenderFeedback(drawings.GetCurrentDWG.pcamera^.POSCOUNT,drawings.GetCurrentDWG.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);

                          cable:=segments.beginiterate(ir_net);
                          if (cable<>nil) then
                          repeat
                                zcAddEntToCurrentDrawingWithUndo(Cable);
                                zcSetEntPropFromCurrentDrawingProp(Cable);
                                drawings.standardization(Cable,GDBCableID);
                                Cable^.Formatentity(drawings.GetCurrentDWG^,dc);
                                Cable^.RenderFeedback(drawings.GetCurrentDWG.pcamera^.POSCOUNT,drawings.GetCurrentDWG.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);

                          cable:=segments.iterate(ir_net);
                          until cable=nil;
                          segments.Clear;
                          segments.done;
                          end
                          else
                              //ZCMsgCallBackInterface.TextMessage('В строке '+inttostr(row)+' обнаружено несколько не связанных трасс "'+FDoc.Cells[3,row],TMWOShowError);
                              ZCMsgCallBackInterface.TextMessage(format('In row %d several unlinced traces "%s" found',[row,FDoc.Cells[3,row]]),TMWOHistoryOut);
                          end
                          else begin
                            if uppercase(FDoc.Cells[3,row])='DIRECTLY' then begin
                              cable:=CreateCable(FDoc.Cells[0,row],FDoc.Cells[4,row]);
                              rootbytrace(startdev.P_insert_in_WCS,enddev.P_insert_in_WCS,nil,Cable,true);
                              zcAddEntToCurrentDrawingWithUndo(Cable);
                              Cable^.Formatentity(drawings.GetCurrentDWG^,dc);
                              Cable^.RenderFeedback(drawings.GetCurrentDWG.pcamera^.POSCOUNT,drawings.GetCurrentDWG.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
                            end else
                              //ZCMsgCallBackInterface.TextMessage('В строке "'+inttostr(row)+'" обнаружена трасса "'+FDoc.Cells[3,row]+'" отсутствующая в чертеже((',TMWOShowError);
                              ZCMsgCallBackInterface.TextMessage(format('In row %d trace "%s" not found in drawing',[row,FDoc.Cells[3,row]]),TMWOHistoryOut);
                            end;
                          end;

            end
            else
                begin
                //ZCMsgCallBackInterface.TextMessage('В строке '+inttostr(row)+'мало параметров',TMWOHistoryOut);
                ZCMsgCallBackInterface.TextMessage(format('In row %d too few parameters',[row]),TMWOHistoryOut);
                for col:=0 to FDoc.ColCount[row] do
                ZCMsgCallBackInterface.TextMessage(FDoc.Cells[col,row],TMWOHistoryOut);
                end;
       lps.ProgressLongProcess(lph,row);
       end;
       netarray.Clear;
       netarray.Done;

       FDoc.Destroy;
       processednets.Clear;
       processednets.Done;

       net:=supernetsarray.beginiterate(ir_net);
       if (net<>nil) then
       repeat
            net.objarray.Clear;
            net.riserarray.clear;
            net:=supernetsarray.iterate(ir_net);
       until net=nil;
       supernetsarray.done;
       linesarray.done;


       lps.EndLongProcess(lph)
  end
            else
     //ZCMsgCallBackInterface.TextMessage('GDBCommandsElectrical.El_ExternalKZ: Не могу открыть файл: '+s+'('+Operands+')',TMWOShowError);
     ZCMsgCallBackInterface.TextMessage(format('GDBCommandsElectrical.El_ExternalKZ: can''t open file: "%s"("%s")',[s,Operands]),TMWOShowError);
end;
function _AutoGenCableRemove_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var //i,len: Integer;
    pv:pGDBObjEntity;
    ir:itrec;
    pvd{,pvn,pvm,pvmc,pvl}:pvardesk;
    //mat:String;
begin
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if (pv^.GetObjType=GDBCableID) then
    begin
         //pvd:=PTEntityUnit(pv^.ou.Instance)^.FindVariable('CABLE_AutoGen');
         pvd:=FindVariableInEnt(pv,'CABLE_AutoGen');
         if pvd<>nil then
                         begin
                              if pBoolean(pvd^.data.Addr.Instance)^ then
                                                                        begin
                                                                        pv^.YouDeleted(drawings.GetCurrentDWG^);
                                                                        end;
                         end;
    end;
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount:=0;
  drawings.GetCurrentDWG.wa.param.seldesc.OnMouseObject:=nil;
  drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject:=nil;
  drawings.GetCurrentDWG.wa.param.lastonmouseobject:=nil;
  drawings.GetCurrentDWG.SelObjArray.Clear;
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
  clearcp;
  result:=cmd_ok;
end;

function _test_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
    p:GDBVertex;
    pet:CMDLinePromptParser.TGeneralParsedText;
    //ts:utf8string;
    gr:TGetResult;
begin
     ZCMsgCallBackInterface.TextMessage('Тест производительности. запасаемя терпением',TMWOHistoryOut);
     //ts:='$<"йцу",Keys[1],Id[1]> Let $<"&[S]ave (&[v])",Keys[S,V],Id[100]> or $<"&[Q]uit",Keys[Q],Id[101]>';
     //ts:='$<"123",Keys[1],Id[1]>';
     pet:=CMDLinePromptParser.GetTokens('<$<"Команда&[1]",Keys[1],Id[1]>/$<"Команда&[2]",Keys[2],Id[2]>/$<"Команда&[3]",Keys[3],Id[3]>> [$<"&[М]олча𤭢123",Keys[М],Id[4]>]');
     //pet:=CMDLinePromptParser.GetTokens('$<"12&[3]",Keys[1],Id[1]>');
     //pet:=CMDLinePromptParser.GetTokens('фs "ёба" йs "2ёба2" йцу12');
     commandmanager.SetPrompt(pet);
     commandmanager.ChangeInputMode([IPEmpty],[]);
     pet.Free;
     repeat
       gr:=commandmanager.Get3DPoint('ага',p);
       case gr of
             GRId:ZCMsgCallBackInterface.TextMessage('Id:'+inttostr(commandmanager.GetLastId),TMWOHistoryOut);
         GRNormal:ZCMsgCallBackInterface.TextMessage('Normal',TMWOHistoryOut);
          GRInput:ZCMsgCallBackInterface.TextMessage('Input:'+commandmanager.GetLastInput,TMWOHistoryOut);
          GRCancel:ZCMsgCallBackInterface.TextMessage('Cancel',TMWOHistoryOut);
       end;
     until gr=GRCancel;
     //for i:=0 to 10000 do
     //       drawings.GetCurrentDWG.wa.getonmouseobject(@drawings.GetCurrentROOT.ObjArray);
     ZCMsgCallBackInterface.TextMessage('Конец теста. выходим, смотрим результаты в конце лога.',TMWOHistoryOut);
     //quit_com('');
     result:=cmd_ok;
end;

function RegenZEnts_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
    pv:pGDBObjEntity;
        ir:itrec;
    drawing:PTDrawingDef;
    DC:TDrawContext;
    lph:TLPSHandle;
begin
  lph:=lps.StartLongProcess('Regenerate ZCAD entities',nil,drawings.GetCurrentROOT.ObjArray.count);
  drawing:=drawings.GetCurrentDwg;
  dc:=drawings.GetCurrentDwg^.CreateDrawingRC;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if (pv^.GetObjType>=GDBZCadEntsMinID)and(pv^.GetObjType<=GDBZCadEntsMaxID)then
                                                                        pv^.FormatEntity(drawing^,dc);
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  lps.ProgressLongProcess(lph,ir.itc);
  until pv=nil;
  drawings.GetCurrentROOT.getoutbound(dc);
  lps.EndLongProcess(lph);

  drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount:=0;
  drawings.GetCurrentDWG.wa.param.seldesc.OnMouseObject:=nil;
  drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject:=nil;
  drawings.GetCurrentDWG.wa.param.lastonmouseobject:=nil;
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
  clearcp;
  //redrawoglwnd;
  result:=cmd_ok;
end;

function Connection2Dot_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  cman:TCableManager;
  pv:PTCableDesctiptor;
  segment:PGDBObjCable;
  node:PTNodeProp;
  nodeend,nodestart:PGDBObjDevice;
  ir,ir2,ir_inNodeArray:itrec;
  pvd,pvd2:pvardesk;
  startnodename,endnodename,startnodelabel,endnodelabel:string;

  alreadywrite:TDictionary<pointer,integer>;
  inriser:boolean;
begin
  cman.init;
  cman.build;
  alreadywrite:=TDictionary<pointer,integer>.create;

  ZCMsgCallBackInterface.TextMessage('DiGraph Classes {',TMWOHistoryOut);

  pv:=cman.beginiterate(ir);
  if pv<>nil then
  begin
    repeat
    inriser:=false;
    segment:=pv^.Segments.beginiterate(ir2);
    if segment<>nil then
    repeat
    begin
      node:=segment^.NodePropArray.beginiterate(ir_inNodeArray);
      if node<>nil then begin
        if not inriser then
          nodestart:=node.DevLink;
        node:=segment^.NodePropArray.iterate(ir_inNodeArray);
        if (node<>nil)and(nodestart<>nil) then
        repeat
          nodeend:=node.DevLink;
          if nodeend<>nil then begin
          pvd:=FindVariableInEnt(nodestart,'NMO_Name');
          pvd2:=FindVariableInEnt(nodeend,'NMO_Name');
          if pvd2=nil then begin
             if FindVariableInEnt(nodeend,'RiserName')<>nil then
                inriser:=true;
          end else
            inriser:=false;
          if (pvd<>nil)and(pvd2<>nil) then begin
            startnodename:=PointerToNodeName(nodestart);
            endnodename:=PointerToNodeName(nodeend);
            startnodelabel:=pstring(pvd^.data.Addr.Instance)^;
            endnodelabel:=pstring(pvd2^.data.Addr.Instance)^;

            if not alreadywrite.ContainsKey(nodestart) then begin
              ZCMsgCallBackInterface.TextMessage(format(' %s [label="%s"]',[startnodename,startnodelabel]),TMWOHistoryOut);
              alreadywrite.add(nodestart,1);
            end;
            if not alreadywrite.ContainsKey(nodeend) then begin
              ZCMsgCallBackInterface.TextMessage(format(' %s [label="%s"]',[endnodename,endnodelabel]),TMWOHistoryOut);
              alreadywrite.add(nodeend,1);
            end;
            ZCMsgCallBackInterface.TextMessage(format(' %s->%s [label="%s"]',[startnodename,endnodename,pv^.Name]),TMWOHistoryOut);
            nodestart:=nodeend;
          end;
          end;
          {if pvd=nil then
            nodestart:=nodeend;}
        node:=segment^.NodePropArray.iterate(ir_inNodeArray);
      until node=nil;
      end;
    end;
    segment:=pv^.Segments.iterate(ir2);
    until segment=nil;
  pv:=cman.iterate(ir);
  until pv=nil;

  ZCMsgCallBackInterface.TextMessage('}',TMWOHistoryOut);
  cman.done;
  alreadywrite.free;
  result:=cmd_ok;
end;

end;

procedure startup;
//var
  // s:String;
begin
  MainSpecContentFormat.init(100);
  MainSpecContentFormat.loadfromfile(FindInSupportPath(GetSupportPath,'main.sf'));
  CreateZCADCommand(@RegenZEnts_com,'RegenZEnts',CADWG,0);
  Wire.init('El_Wire',0,0);
  commandmanager.CommandRegister(@Wire);
  pcabcom:=CreateCommandRTEdObjectPlugin(@_Cable_com_CommandStart, _Cable_com_CommandEnd,nil,@cabcomformat,@_Cable_com_BeforeClick,@_Cable_com_AfterClick,@_Cable_com_Hd,nil,'EL_Cable',0,0);

  pcabcom^.SetCommandParam(@cabcomparam,'PTELCableComParam');
  cabcomparam.Traces.Enums.init(10);
  cabcomparam.PTrace:=nil;

  CreateZCADCommand(@_Cable_com_Invert,'El_Cable_Invert',CADWG,0);
  CreateZCADCommand(@_Cable_com_Manager,'El_CableMan',CADWG,0);
  CreateZCADCommand(@_Cable_com_Legend,'El_Cable_Legend',CADWG,0);
  CreateZCADCommand(@_Cable_com_Join,'El_Cable_Join',CADWG,0);
  csel:=CreateZCADCommand(@_Cable_com_Select,'El_Cable_Select',CADWG,0);
  csel.CEndActionAttr:=[];
  CreateZCADCommand(@_Material_com_Legend,'El_Material_Legend',CADWG,0);
  CreateZCADCommand(@_Cable_mark_com,'KIP_Cable_Mark',CADWG,0);

  CreateZCADCommand(@_Ren_n_to_0n_com,'El_Cable_RenN_0N',CADWG,0);
  CreateZCADCommand(@_SelectMaterial_com,'SelMat',CADWG,0);
  CreateZCADCommand(@_test_com,'test',CADWG,0);
  CreateZCADCommand(@_El_ExternalKZ_com,'El_ExternalKZ',CADWG,0);
  CreateZCADCommand(@_AutoGenCableRemove_com,'EL_AutoGen_Cable_Remove',CADWG,0);
  CreateZCADCommand(@Connection2Dot_com,'Connection2Dot',CADWG,0);

  //EM_SRBUILD.init('EM_SRBUILD',CADWG,0);
  //EM_SEPBUILD.init('EM_SEPBUILD',CADWG,0);
  KIP_CDBuild.init('KIP_CDBuild',CADWG,0);
  KIP_LugTableBuild.init('KIP_LugTableBuild',CADWG,0);

  //EM_SEPBUILD.SetCommandParam(@em_sepbuild_params,'PTBasicFinter');

  CreateCommandRTEdObjectPlugin(@ElLeaser_com_CommandStart,@Line_com_CommandEnd,nil,nil,@Line_com_BeforeClick,@El_Leader_com_AfterClick,nil,nil,'El_Leader',0,0);
  pfindcom:=CreateCommandRTEdObjectPlugin(@Find_com,nil,nil,@commformat,nil,nil,nil,nil,'El_Find',0,0);
  pfindcom.CEndActionAttr:=[];
  pfindcom^.SetCommandParam(@FindDeviceParam,'PTFindDeviceParam');

  FindDeviceParam.FindType:=tft_obozn;
  FindDeviceParam.FindString:='';
  ELLeaderComParam.Scale:=1;
  ELLeaderComParam.Size:=1;

  CreateZCADCommand(@VarReport_com,'VarReport',CADWG,0);
end;

procedure finalize;
begin
     MainSpecContentFormat.Done;
end;
initialization
  startup;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  finalize;
end.


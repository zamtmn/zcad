(*----------------------------------------------------------------------------*)
(*                  Copyright (c) 2004-2010 Antrey Zubarev                    *)
(*----------------------------------------------------------------------------*)
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit GDBCommandsElectrical;
{$INCLUDE def.inc}

interface
uses
  UGDBOpenArrayOfPV,GDBBlockInsert{,ZGUIsCT,zforms},devices{,ZComboBoxsWithProc,ZTreeViewsGeneric},UGDBTree,ugdbdescriptor,gdbasetypes,commandline,GDBCommandsDraw,GDBElLeader,
  plugins,
  commandlinedef,
  commanddefinternal,
  gdbase,
  GDBManager,
  sysutils,
  fileutil,
  varmandef,
  oglwindowdef,
  //OGLtypes,
  //UGDBOpenArrayOfByte,
  //iodxf,
  //optionswnd,
  objinsp,
  //cmdline,
  geometry,
  memman,
  gdbobjectsconstdef,
  {UGDBVisibleOpenArray,}gdbEntity{,GDBCircle},GDBLine,
  {GDBGenericSubEntry,}GDBNet,
  shared,sharedgdb,GDBSubordinated,gdbCable,varman,WindowsSpecific,uunitmanager,
  UGDBBillOfMaterial,UCableManager,GDBDevice,GDBTable,UGDBStringArray,math,{strutils,}Masks,log,GDBCommandsBase,strproc;
type
{Export+}
  TFindType=(
               TFT_Obozn(*'обозначении'*),
               TFT_DBLink(*'материале'*),
               TFT_variable(*'??указанной переменной'*)
             );
PTBasicFinter=^TBasicFinter;
TBasicFinter=record
                   IncludeCable:GDBBoolean;(*'Фильтр включения'*)
                   IncludeCableMask:GDBString;(*'Маска включения'*)
                   ExcludeCable:GDBBoolean;(*'Фильтр исключения'*)
                   ExcludeCableMask:GDBString;(*'Маска исключения'*)
             end;
  TFindDeviceParam=record
                        FindType:TFindType;(*'Искать в'*)
                        FindMethod:GDBBoolean;(*'Применять символы *, ?'*)
                        FindString:GDBString;(*'Текст'*)
                    end;
     GDBLine=record
                  lBegin,lEnd:GDBvertex;
              end;
  TELCableComParam=record
                        Traces:TEnumData;(*'Трасса'*)
                        PCable:PGDBObjCable;(*'Кабель'*)
                        PTrace:PGDBObjNet;(*'Трасса(указатель)'*)
                   end;
  TELLeaderComParam=record
                        Scale:GDBDouble;(*'Масштаб'*)
                        Size:GDBInteger;(*'Размер'*)
                   end;
{Export-}
  El_Wire_com = object(CommandRTEdObject)
    New_line: PGDBObjLine;
    FirstOwner,SecondOwner,OldFirstOwner:PGDBObjNet;
    constructor init(cn:GDBString;SA,DA:TCStartAttr);
    procedure CommandStart(Operands:pansichar); virtual;
    procedure CommandCancel; virtual;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;

  EM_SRBUILD_com = object(FloatInsert_com)
    procedure Command(Operands:pansichar); virtual;
  end;
  EM_SEPBUILD_com = object(FloatInsertWithParams_com)
    //procedure Command(Operands:pansichar); virtual;
    procedure BuildDM(Operands:pansichar); virtual;
  end;

    (*PGDBEmSEPDeviceNode=^GDBEmSEPDeviceNode;
    GDBEmSEPDeviceNode=object(GDBVisNode)
                              NodeName:GDBString;
                              upcable:PTCableDesctiptor;
                              dev,shell:PGDBObjDevice;
                              function GetNodeName:GDBString;virtual;
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
   MainSpecContentFormat:GDBGDBStringArray;

   EM_SRBUILD:EM_SRBUILD_com;
   EM_SEPBUILD:EM_SEPBUILD_com;
   em_sepbuild_params:TBasicFinter;

   //treecontrol:ZTreeViewGeneric;
   //zf:zform;
   ELLeaderComParam:TELLeaderComParam;

{procedure startup;
procedure finalize;}
procedure Cable2CableMark(pcd:PTCableDesctiptor;pv:pGDBObjDevice);
implementation
uses {ZButtonsGeneric,}GDBMText,GDBBlockDef,mainwindow,oglwindow,{ZGUIsCT,}UGDBPoint3DArray,DeviceBase;
function GetCableMaterial(pcd:PTCableDesctiptor):GDBString;
var
   {pvn,}pvm,pvmc,pvl:pvardesk;
   line:gdbstring;
   eq:pvardesk;
begin
                                        pvmc:=pcd^.StartSegment^.FindVariable('DB_link');
                                        if pvmc<>nil then
                                        begin
                                        line:=pstring(pvmc^.data.Instance)^;
                                        eq:=DWGDBUnit.FindVariable(line);
                                        if eq=nil then
                                                      result:='(!)'+line
                                                  else
                                                      begin
                                                           result:=PDbBaseObject(eq^.data.Instance)^.NameShort;
                                                      end;
                                        end
                                        else
                                            result:='Не определен';
end;
procedure Cable2CableMark(pcd:PTCableDesctiptor;pv:pGDBObjDevice);
var
   {pvn,}pvm,pvmc,pvl:pvardesk;
   line:gdbstring;
   eq:pvardesk;
begin
                        pvm:=pv^.ou.FindVariable('CableMaterial');
                        if pvm<>nil then
                                    begin
                                         pstring(pvm^.data.Instance)^:={Tria_Utf8ToAnsi}( GetCableMaterial(pcd));
                                        {pvmc:=pcd^.StartSegment^.FindVariable('DB_link');
                                        if pvmc<>nil then
                                        begin
                                        line:=pstring(pvmc^.data.Instance)^;
                                        eq:=DWGDBUnit.FindVariable(line);
                                        if eq=nil then
                                                      pstring(pvm^.data.Instance)^:='(!)'+line
                                                  else
                                                      begin
                                                           pstring(pvm^.data.Instance)^:=PDbBaseObject(eq^.data.Instance)^.NameShort;
                                                      end;
                                        end
                                        else
                                            pgdbstring(pvm^.data.Instance)^:='Не определен';}
                                    end;
                       pvl:=pv^.ou.FindVariable('CableLength');
                       if pvl<>nil then
                                       pgdbdouble(pvl^.data.Instance)^:=pcd^.length;
end;
{function GDBEmSEPDeviceNode.GetNodeName:GDBString;
begin
     result:=nodename;
end;}
procedure IP(pnode:PGDBBaseNode;PProcData:Pointer);
var
   pvd:pvardesk;
begin
(*     if PGDBEmSEPDeviceNode(pnode)^.upcable<>nil then
     begin
          pvd:=PGDBEmSEPDeviceNode(pnode)^.upcable^.StartSegment.OU.FindVariable('GC_HDGroup');
          if pvd<>nil then
          if PGDBInteger(pvd^.data.Instance)^>PGDBInteger(Pprocdata)^ then
             PGDBInteger(Pprocdata)^:=PGDBInteger(pvd^.data.Instance)^;
     end; *)
end;
function icf (pnode:PGDBBaseNode;PExpr:GDBPointer):GDBBoolean;
var
   pvd:pvardesk;
begin
 (*    result:=false;
     if PGDBEmSEPDeviceNode(pnode)^.upcable<>nil then
     begin
          pvd:=PGDBEmSEPDeviceNode(pnode)^.upcable^.StartSegment.OU.FindVariable('GC_HDGroup');
          if pvd<>nil then
          if PGDBInteger(pvd^.data.Instance)^=PGDBInteger(PExpr)^ then
             result:=true;
     end; *)
end;
function g2x(g:gdbinteger):GDBInteger;
begin
     result:=30*g;
end;
function TBGMode2y(bgm:TBGMode):GDBDouble;
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
function insertblock(bname,obozn:GDBString;p:gdbVertex):GDBBoundingBbox;
var
   pgdbins:pgdbobjblockinsert;
   pbdef:PGDBObjBlockdef;
   ptext:PGDBObjMText;
begin
          pbdef:=gdb.CurrentDWG^.BlockDefArray.getblockdef(bname);

          pbdef^.getonlyoutbound;
          //pbdef^.calcbb;
          result:=pbdef.vp.BoundingBox;

          pointer(pgdbins):=gdb.CurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBBlockInsertID,@gdb.CurrentDWG.ConstructObjRoot);
          pgdbins^.name:=bname;
          pgdbins^.Local.P_insert:=p;
          pgdbins^.BuildGeometry;
          pgdbins^.Format;

          //pointer(ptext):=gdb.CurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBMtextID,@gdb.CurrentDWG.ConstructObjRoot);

          if obozn<>'' then
          begin
          ptext:=pointer(CreateObjFree(GDBMtextID));
          ptext^.init(@gdb.CurrentDWG.ConstructObjRoot,gdb.GetCurrentDWG.LayerTable.getAddres('TEXT'),sysvar.dwg.DWG_CLinew^,obozn,CreateVertex(p.x+pbdef.vp.BoundingBox.LBN.x-1,p.y,p.z),2.5,0,0.65,90,jsbc,1,1);
          gdb.CurrentDWG.ConstructObjRoot.ObjArray.add(@ptext);
          ptext^.Format;
          end;

end;
procedure drawlineandtext(pcabledesk:PTCableDesctiptor;p1,p2:GDBVertex);
var
   pl:pgdbobjline;
   a:gdbdouble;
   ptext:PGDBObjMText;
   v:gdbvertex;
begin
     pl:=pointer(CreateObjFree(GDBLineID));
     pl^.init(@gdb.CurrentDWG.ConstructObjRoot,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,p1,p2);
     gdb.CurrentDWG.ConstructObjRoot.ObjArray.add(@pl);
     pl^.Format;
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
                               v:=geometry.VertexMulOnSc(v,-1);
                               a:=vertexangle(PGDBVertex2d(@p1)^,PGDBVertex2d(@p2)^)*180/pi;
                          end
                          else
                              a:=180+vertexangle(PGDBVertex2d(@p1)^,PGDBVertex2d(@p2)^)*180/pi;

          ptext:=pointer(CreateObjFree(GDBMtextID));
          ptext^.init(@gdb.CurrentDWG.ConstructObjRoot,gdb.GetCurrentDWG.LayerTable.getAddres('TEXT'),sysvar.dwg.DWG_CLinew^,GetCableMaterial(pcabledesk)+' L='+floattostr(pcabledesk^.length)+'м',vertexadd(Vertexmorph(p1,p2,0.5),v),2.5,0,0.65,a,jsbc,vertexlength(p1,p2),1);
          gdb.CurrentDWG.ConstructObjRoot.ObjArray.add(@ptext);
          ptext^.Format;

          ptext:=pointer(CreateObjFree(GDBMtextID));
          ptext^.init(@gdb.CurrentDWG.ConstructObjRoot,gdb.GetCurrentDWG.LayerTable.getAddres('TEXT'),sysvar.dwg.DWG_CLinew^,pcabledesk^.Name,vertexsub(Vertexmorph(p1,p2,0.5),v),2.5,0,0.65,a,jstm,vertexlength(p1,p2),1);
          gdb.CurrentDWG.ConstructObjRoot.ObjArray.add(@ptext);
          ptext^.Format;

     end;
     
end;
procedure drawcable(pcabledesk:PTCableDesctiptor;p1,p2:GDBVertex;g1,g2:GDBBoundingBbox;bgm1,bgm2:TBGMode);
var
   pl:pgdbobjline;
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
(*procedure EM_SEP_build_group(const cman:TCableManager;const node:PGDBEmSEPDeviceNode;var group:GDBInteger;P1:GDBVertex;var BGM:TBGMode;oldgabarit:GDBBoundingBbox);
var
   pvd:pvardesk;
   tempbgm,newBGM,nextBGM,TnextBGM:TBGMode;
   ir:itrec;
   subnode:PGDBEmSEPDeviceNode;
   tempgroup,maxgroup:gdbinteger;
   pgdbins:pgdbobjblockinsert;
   name:GDBString;
   gabarit:GDBBoundingBbox;
   y:GDBDouble;
   p:gdbvertex;
begin
          GDB.AddBlockFromDBIfNeed(gdb.GetCurrentDWG,'EM_PSRS_HEAD');
          GDB.AddBlockFromDBIfNeed(gdb.GetCurrentDWG,'DEVICE_EM_PSRS_EL');
          pointer(pgdbins):=gdb.CurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBBlockInsertID,@gdb.CurrentDWG.ConstructObjRoot);
          pgdbins^.name:='EM_PSRS_HEAD';
          pgdbins^.Local.P_insert:=createvertex(-15,0,0);
          pgdbins^.BuildGeometry;
          pgdbins^.Format;

     pvd:=node.shell.OU.FindVariable('Device_Type');
     if pvd<>nil then
     case
         PTDeviceType(pvd^.data.Instance)^ of
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
                                         name:=pgdbstring(pvd.data.Instance)^;
          //y:=TBGMode2y(nextBGM);
          p:=createvertex(g2x(group),TBGMode2y(nextBGM),0);
          gabarit:=insertblock(node.shell.Name,name,p);
          drawcable(node.upcable,p1,p,oldgabarit,gabarit,bgm,tnextbgm);
          y:=y+gabarit.lbn.y;

          if nextBGM=BGNagr then
          begin
          pgdbins:=addblockinsert(@gdb.CurrentDWG.ConstructObjRoot,@gdb.CurrentDWG.ConstructObjRoot.ObjArray,createvertex(g2x(group),-128,0),1,0,'DEVICE_EM_PSRS_EL');
          node.shell.Format;
          node.shell.OU.CopyTo(@pgdbins.OU);
          // pointer(pgdbins):=gdb.CurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBBlockInsertID,@gdb.CurrentDWG.ConstructObjRoot);
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
   group,groupmax,dg:GDBInteger;
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
   name:GDBString;
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
                              gdbgetmem({$IFDEF DEBUGBUILD}'{E1158636-E1BD-49B8-BFB2-25723FC26625}',{$ENDIF}pointer(tree),sizeof(TGDBTree));
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


                         gdbgetmem({$IFDEF DEBUGBUILD}'{E1158636-E1BD-49B8-BFB2-25723FC26625}',{$ENDIF}pointer(root2),sizeof(GDBEmSEPDeviceNode));
                         root2^.initnul;
                         pvd:=shell.ou.FindVariable('NMO_Name');
                         if pvd<>nil then
                                         name:=pgdbstring(pvd.data.Instance)^;
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
                              gdbgetmem({$IFDEF DEBUGBUILD}'{E1158636-E1BD-49B8-BFB2-25723FC26625}',{$ENDIF}pointer(ptree^),sizeof(TGDBTree));
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
procedure EM_SEPBUILD_com.BuildDM(Operands:pansichar);
begin
    //commandmanager.DMAddProcedure('test1','подсказка1',nil);
    //commandmanager.DMAddMethod('Разместить','подсказка3',run);
    //commandmanager.DMShow;
end;
(*procedure EM_SEPBUILD_com.Command(Operands:pansichar);
var
      pobj: pGDBObjEntity;
      ir:itrec;
      counter:integer;
      //tcd:TCopyObjectDesc;
      pvd:pvardesk;
      name:GDBString;
      cman:TCableManager;

      root:PGDBEmSEPDeviceNode;
begin

commandmanager.DMShow;

  cman.init;
  cman.build;
  GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));



  counter:=0;
  cman.init;
  cman.build;
             GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));

  pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pobj<>nil then
  begin
  repeat
    if pobj.selected then
    if pobj.vp.ID=GDBDeviceID then
    begin
         pvd:=pobj^.ou.FindVariable('Device_Type');
         if pvd<>nil then
         if PTDeviceType(pvd^.data.Instance)^=TDT_SilaIst then
         begin
              inc(counter);


              pvd:=pobj^.ou.FindVariable('NMO_Name');
              if pvd<>nil then
                              name:=pgdbstring(pvd.data.Instance)^;
              zf.initxywh('EMTREE',@mainformn,100,100,500,500,false);
              treecontrol.initxywh('asas',@zf,500,0,500,45,false);
              treecontrol.align:=al_client;

              gdbgetmem({$IFDEF DEBUGBUILD}'{E1158636-E1BD-49B8-BFB2-25723FC26625}',{$ENDIF}pointer(root),sizeof(GDBEmSEPDeviceNode));
              root^.initnul;
              root^.NodeName:=name;


              EM_SEP_build_tree(cman,root^.SubNode,pobj);
              treecontrol.tree.AddNode(root);

              treecontrol.Sync;
              treecontrol.Show;zf.Show;



         end;
    end;
  pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until (pobj=nil)or(counter<>0);
  end;

  if counter=0 then
                   historyout('Выбери объект(ы) источник энергии!')
               else
                   EM_SEP_build_graphix(cman,root^.SubNode);
  cman.done;
  //treecontrol.done;
end;*)
procedure EM_SRBUILD_com.Command(Operands:pansichar);
var
      pobj: pGDBObjEntity;
      pgroupdev:pGDBObjDevice;
      ir,ir2,ir_inNodeArray:itrec;
      counter:integer;
      //tcd:TCopyObjectDesc;
      pvd:pvardesk;
      name,material,potrname,potrmaterial:GDBString;
      p,pust,i,iust,cosf:PGDBDouble;
      potrpust,potriust,potrpr,potrir,potrpv,potrp,potri,potrks,potrcos,sumpcos,sumpotrp,sumpotri:GDBDouble;
      cman:TCableManager;
      pcabledesk:PTCableDesctiptor;
      node:PGDBObjDevice;
      pt:PGDBObjTable;
      psl,psfirstline:PGDBGDBStringArray;
      //first:boolean;
      s:gdbstring;
begin
  counter:=0;
  cman.init;
  cman.build;
             GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));

  pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pobj<>nil then
  begin
  repeat
    if pobj.selected then
    if pobj.vp.ID=GDBDeviceID then
    begin
         pvd:=pobj^.ou.FindVariable('Device_Type');
         if pvd<>nil then
         if PTDeviceType(pvd^.data.Instance)^=TDT_SilaIst then
         begin


              inc(counter);

              name:='Без имени';
              material:='Без имени';
              pvd:=pobj^.ou.FindVariable('NMO_Name');
              if pvd<>nil then
                              name:=pgdbstring(pvd.data.Instance)^;
              pvd:=pobj^.ou.FindVariable('DB_link');
              if pvd<>nil then
                              material:=pgdbstring(pvd.data.Instance)^;
              historyoutstr('Найден объект источник энергии "'+name+'"');

              p:=nil;pust:=nil;i:=nil;iust:=nil;cosf:=nil;
              sumpcos:=0;

              pvd:=pobj^.ou.FindVariable('Power');
              if pvd<>nil then
                              p:=pvd.data.Instance;
              pvd:=pobj^.ou.FindVariable('PowerUst');
              if pvd<>nil then
                              pust:=pvd.data.Instance;
              pvd:=pobj^.ou.FindVariable('Current');
              if pvd<>nil then
                              i:=pvd.data.Instance;
              pvd:=pobj^.ou.FindVariable('CurrentUst');
              if pvd<>nil then
                              iust:=pvd.data.Instance;
              pvd:=pobj^.ou.FindVariable('CosPHI');
              if pvd<>nil then
                              cosf:=pvd.data.Instance;
              if (p<>nil)and(pust<>nil)and(i<>nil)and(iust<>nil) then
              begin

                     GDBGetMem({$IFDEF DEBUGBUILD}'{76F46B7D-CAFA-4509-8B65-8759292D8709}',{$ENDIF}pointer(pt),sizeof(GDBObjTable));
                     pt^.initnul;
                     pt^.ptablestyle:=gdb.GetCurrentDWG.TableStyleTable.getAddres('ShRaspr');
                     pt^.tbl.cleareraseobj;
                     //first:=true;
                     psfirstline:=pointer(pt^.tbl.CreateObject);
                     psfirstline.init(16);

                   historyoutstr('Текущие значения Pрасч='+floattostr(p^)+'; Iрасч='+floattostr(i^)+'; Pуст='+floattostr(pust^)+'; Iуст='+floattostr(iust^)+' будут пересчитаны');
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
                              historyoutstr('  Найдена групповая линия "'+pcabledesk^.Name+'"');

                              potrpust:=0;
                              potriust:=0;

                              {node:=}pcabledesk^.Devices.beginiterate(ir_inNodeArray);
                              node:=pcabledesk^.Devices.iterate(ir_inNodeArray);
                              if node<>nil then
                              repeat
                                    pgroupdev:=pointer(node.bp.ListPos.Owner);
                                    if pgroupdev<>nil then
                                    begin
                                         pvd:=pgroupdev^.ou.FindVariable('Device_Type');
                                         if pvd<>nil then
                                         begin
                                              case PTDeviceType(pvd^.data.Instance)^ of
                                                   TDT_SilaPotr:
                                                                begin
                                                                      potrmaterial:='Без имени';
                                                                      pvd:=pgroupdev^.ou.FindVariable('NMO_Name');
                                                                      if pvd<>nil then
                                                                                      begin
                                                                                           if potrname='' then
                                                                                                              potrname:=pgdbstring(pvd.data.Instance)^
                                                                                                          else
                                                                                                              potrname:=potrname+'+ '+pgdbstring(pvd.data.Instance)^;
                                                                                      end;
                                                                      pvd:=pgroupdev^.ou.FindVariable('DB_link');
                                                                      if pvd<>nil then
                                                                                      potrmaterial:=pgdbstring(pvd.data.Instance)^;
                                                                      potrpv:=1;
                                                                      pvd:=pgroupdev^.ou.FindVariable('PV');
                                                                      if pvd<>nil then
                                                                                      potrpv:=pgdbdouble(pvd.data.Instance)^;
                                                                      potrp:=0;
                                                                      pvd:=pgroupdev^.ou.FindVariable('Power');
                                                                      if pvd<>nil then
                                                                                      potrp:=pgdbdouble(pvd.data.Instance)^;
                                                                      potri:=0;
                                                                      pvd:=pgroupdev^.ou.FindVariable('Current');
                                                                      if pvd<>nil then
                                                                                      potri:=pgdbdouble(pvd.data.Instance)^;
                                                                      potrks:=1;
                                                                      pvd:=pgroupdev^.ou.FindVariable('Ks');
                                                                      if pvd<>nil then
                                                                                      potrks:=pgdbdouble(pvd.data.Instance)^;
                                                                      potrcos:=1;
                                                                      pvd:=pgroupdev^.ou.FindVariable('CosPHI');
                                                                      if pvd<>nil then
                                                                                      potrcos:=pgdbdouble(pvd.data.Instance)^;

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
                                                                      historyoutstr('    Найден объект потребитель энергии "'+potrname+'"; Pрасч='+floattostr(potrp)+'; Iрасч='+floattostr(potri));




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
//                                                                                      s:=pgdbstring(pvd.data.Instance)^;
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
                                                                      potrmaterial:='Без имени';
                                                                      pvd:=pgroupdev^.ou.FindVariable('NMO_Name');
                                                                      if pvd<>nil then
                                                                                      begin
                                                                                           if potrname='' then
                                                                                                              potrname:=pgdbstring(pvd.data.Instance)^
                                                                                                          else
                                                                                                              potrname:=potrname+'+ '+pgdbstring(pvd.data.Instance)^;
                                                                                      end;
                                                                      pvd:=pgroupdev^.ou.FindVariable('DB_link');
                                                                      if pvd<>nil then
                                                                                      potrmaterial:=pgdbstring(pvd.data.Instance)^;
                                                                      potrp:=0;
                                                                      pvd:=pgroupdev^.ou.FindVariable('PowerUst');
                                                                      if pvd<>nil then
                                                                                      potrp:=pgdbdouble(pvd.data.Instance)^;
                                                                      potri:=0;
                                                                      pvd:=pgroupdev^.ou.FindVariable('CurrentUst');
                                                                      if pvd<>nil then
                                                                                      potri:=pgdbdouble(pvd.data.Instance)^;
                                                                      potrpr:=0;
                                                                      pvd:=pgroupdev^.ou.FindVariable('Power');
                                                                      if pvd<>nil then
                                                                                      potrpr:=pgdbdouble(pvd.data.Instance)^;
                                                                      potrir:=0;
                                                                      pvd:=pgroupdev^.ou.FindVariable('Current');
                                                                      if pvd<>nil then
                                                                                      potrir:=pgdbdouble(pvd.data.Instance)^;
                                                                      potrcos:=1;
                                                                      pvd:=pgroupdev^.ou.FindVariable('CosPHI');
                                                                      if pvd<>nil then
                                                                                      potrcos:=pgdbdouble(pvd.data.Instance)^;

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
                                                                      historyoutstr('    Найден объект распределитель энергии "'+potrname+'"; Pрасч='+floattostr(potrp)+'; Iрасч='+floattostr(potri));
                                                                 end;
                                              end;
                                         end;
                                         {pv:=1;
                                         pvd:=pobj^.ou.FindVariable('PV');
                                         if pvd<>nil then
                                         pv:=pgdbdouble(pvd.data.Instance)^;}
                                    end;



                                    node:=pcabledesk^.Devices.iterate(ir_inNodeArray);
                              until node=nil;
                  psl:=pointer(pt^.tbl.CreateObject);
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
                                    psl.add(@s);
                               end;
                  s:='';
                  psl.add(@s);
                  psl.add(@s);
                  psl.add(@s);
                  psl.add(@s);
                  s:='1';
                  psl.add(@s);
                  s:=pcabledesk^.Name;
                  psl.add(@s);
                  s:='';
                  psl.add(@s);
                  s:='qwer';
                  pvd:=pcabledesk^.StartSegment^.ou.FindVariable('DB_link');
                  if pvd<>nil then
                                  s:=pgdbstring(pvd.data.Instance)^;
                  //pvd:=pgroupdev^.ou.FindVariable('DB_link');
                  psl.add(@s);
                  s:=floattostr(pcabledesk^.length);
                  psl.add(@s);
                  s:='';
                  psl.add(@s);
                  s:='';
                  psl.add(@s);
                  s:=potrname;
                  psl.add(@s);
                  s:=floattostr(roundto({sumpotrp}potrpust,-2));
                  psl.add(@s);
                  s:=floattostr(roundto({sumpotri}potriust,-2));
                  psl.add(@s);
                  s:='Потребитель';
                  psl.add(@s);

                         end;

                        pcabledesk:=cman.iterate(ir2);
                   until pcabledesk=nil;


              if cosf<>nil then
              cosf^:=sumpcos/pust^;

                  s:=name;
                  psfirstline.add(@s);
                  s:='';
                  psfirstline.add(@s);
                  psfirstline.add(@s);
                  psfirstline.add(@s);
                  psfirstline.add(@s);
                  s:='1';
                  psfirstline.add(@s);
                  s:='';
                  psfirstline.add(@s);
                  s:='';
                  psfirstline.add(@s);
                  //s:='qwer';
                  psfirstline.add(@s);
                  //s:=floattostr(pcabledesk^.length);
                  psfirstline.add(@s);
                  s:='';
                  psfirstline.add(@s);
                  s:='';
                  psfirstline.add(@s);
                  //s:=potrname;
                  psfirstline.add(@s);
                  s:=floattostr(roundto(p^,-2));
                  psfirstline.add(@s);
                  s:=floattostr(roundto(i^,-2));
                  psfirstline.add(@s);
                  s:='Ввод';
                  psfirstline.add(@s);


              gdb.CurrentDWG.ConstructObjRoot.ObjArray.add(@pt);
              pt^.Build;
              pt^.Format;
              end;

         end;
    end;
  pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pobj=nil;
  end;
  if counter=0 then
                   historyout('Выбери объект(ы) источник энергии!');
  cman.done;
end;
constructor El_Wire_com.init;
begin
  inherited init(cn,sa,da);
  dyn:=false;
end;

procedure El_Wire_com.CommandStart;
begin
  inherited CommandStart('');;
  FirstOwner:=nil;
  SecondOwner:=nil;
  OldFirstOwner:=nil;
  gdb.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  historyout('Начало цепи:');
end;

procedure El_Wire_com.CommandCancel;
begin
end;

function El_Wire_com.BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
var po:PGDBObjSubordinated;
    Objects:GDBObjOpenArrayOfPV;
begin
  Objects.init({$IFDEF DEBUGBUILD}'{8BE71BAA-507B-4D6B-BE2C-63693022090C}',{$ENDIF}10);
  if gdb.GetCurrentROOT.FindObjectsInPoint(wc,Objects) then
  begin
       FirstOwner:=pointer(GDB.FindOneInArray(Objects,GDBNetID,true));
  end;
  Objects.ClearAndDone;
  if osp<>nil then
  begin
       if (PGDBObjEntity(osp^.PGDBObject)<>nil)and(osp^.PGDBObject<>FirstOwner)
       then
       begin
            PGDBObjEntity(osp^.PGDBObject)^.format;
            historyout(GDBPointer(PGDBObjline(osp^.PGDBObject)^.ObjToGDBString('Found: ','')));
            po:=PGDBObjEntity(osp^.PGDBObject)^.getowner;
            //FirstOwner:=GDBPointer(po);
       end
  end {else FirstOwner:=oldfirstowner};
  if (button and MZW_LBUTTON)<>0 then
  begin
    historyout('Вторая точка:');
    New_line := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBLineID,gdb.GetCurrentROOT));
    GDBObjLineInit(gdb.GetCurrentROOT,New_line,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,wc,wc);
    New_line^.Format;
  end
end;

function El_Wire_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
var po:PGDBObjSubordinated;
    mode:GDBInteger;
    TempNet:PGDBObjNet;
    //nn:GDBString;
    pvd{,pvd2}:pvardesk;
    nni:gdbinteger;
    Objects:GDBObjOpenArrayOfPV;
begin
  New_line^.vp.Layer :=gdb.GetCurrentDWG.LayerTable.GetCurrentLayer;
  New_line^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
  New_line.CoordInOCS.lEnd:= wc;
  New_line^.Format;
  //po:=nil;
  if (button and MZW_LBUTTON)<>0 then
                                     button:=button;
  Objects.init({$IFDEF DEBUGBUILD}'{8BE71BAA-507B-4D6B-BE2C-63693022090C}',{$ENDIF}10);
  if gdb.GetCurrentROOT.FindObjectsInPoint(wc,Objects) then
  begin
       SecondOwner:=pointer(GDB.FindOneInArray(Objects,GDBNetID,true));
  end;
  Objects.ClearAndDone;

  if osp<>nil then
  begin
       if (PGDBObjEntity(osp^.PGDBObject)<>nil)and(osp^.PGDBObject<>SecondOwner)
       then
       begin
            PGDBObjEntity(osp^.PGDBObject)^.format;
            historyout(GDBPointer(PGDBObjline(osp^.PGDBObject)^.ObjToGDBString('Found: ','')));
            po:=PGDBObjEntity(osp^.PGDBObject)^.getowner;
            //SecondOwner:=GDBPointer(po);
       end
  end {else SecondOwner:=nil};
  //pl^.RenderFeedback;
  if (button and MZW_LBUTTON)<>0 then
  begin
    New_line^.RenderFeedback;
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
                 GDBGetMem({$IFDEF DEBUGBUILD}'{C92353C3-EA26-48A9-A47F-89F7723E3D16}',{$ENDIF}GDBPointer(TempNet),sizeof(GDBObjNet));
                 TempNet^.initnul(nil);
                 TempNet^.ou.copyfrom(units.findunit('trace'));
                 pvd:=TempNet.ou.FindVariable('NMO_Suffix');
                 pstring(pvd^.data.Instance)^:=inttostr(gdb.GetCurrentDWG.numerator.getnumber(UNNAMEDNET,SysVar.DSGN.DSGN_TraceAutoInc^));
                 pvd:=TempNet.ou.FindVariable('NMO_Prefix');
                 pstring(pvd^.data.Instance)^:='@';
                 pvd:=TempNet.ou.FindVariable('NMO_BaseName');
                 pstring(pvd^.data.Instance)^:=UNNAMEDNET;
                 //TempNet^.name:=gdb.numerator.getnamenumber(el_unname_prefix);
                 New_line^.bp.ListPos.Owner:=TempNet;
                 TempNet^.ObjArray.add(addr(New_line));
                 TempNet^.Format;
                 gdb.GetCurrentROOT.AddObjectToObjArray{ObjArray.add}(@TempNet);
                 firstowner:=TempNet;
                 mode:=-1;
            end;
          1:begin
                 New_line^.bp.ListPos.Owner:=FirstOwner;
                 FirstOwner^.ObjArray.add(addr(New_line));
                 FirstOwner^.Format;
                 mode:=-1;
            end;
          2:begin
                 //pvd:=SecondOwner.ou.FindVariable('NMO_Name');
                 //pvd2:=firstowner.ou.FindVariable('NMO_Name');
                 nni:=SecondOwner.CalcNewName(SecondOwner,firstowner{pstring(pvd^.data.Instance)^,pstring(pvd2^.data.Instance)^});
                 if {nn<>''}nni<>0 then
                 begin
                 SecondOwner^.MigrateTo(FirstOwner);

                 if nni=1 then
                 begin
                      FirstOwner^.OU.free;
                      secondowner.OU.CopyTo(@FirstOwner^.OU);
                      //FirstOwner^.Name:=nn;
                 end;

                 New_line^.bp.ListPos.Owner:=FirstOwner;
                 FirstOwner^.ObjArray.add(addr(New_line));
                 FirstOwner^.Format;
                 mode:=-1;

                 SecondOwner^.YouDeleted;
                 end
                    else mode:=0;
            end;
    end;
    until mode=-1;
    gdb.GetCurrentROOT.calcbb;
    gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.Count := 0;
    oldfirstowner:=firstowner;
    redrawoglwnd;
    if mode= 2 then commandmanager.executecommandend
               else beforeclick(wc,mc,button,osp);
  end;
end;
procedure cabcomformat;
var
   s:gdbstring;
   ir_inGDB:itrec;
   currentobj:PGDBObjNet;
begin
  cabcomparam.Traces.Enums.free;
  cabcomparam.PTrace:=nil;

  CurrentObj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir_inGDB);
  if (CurrentObj<>nil) then
     repeat
           if CurrentObj^.vp.ID=GDBNetID then
           begin
                s:=getentname(CurrentObj);
                if s<>'' then
                begin
                     cabcomparam.Traces.Enums.add(@s);
                     if cabcomparam.Traces.Selected=cabcomparam.Traces.Enums.Count-1 then
                                                                                         cabcomparam.PTrace:=CurrentObj;


                end;
           end;
           CurrentObj:=gdb.GetCurrentROOT.ObjArray.iterate(ir_inGDB);
     until CurrentObj=nil;

  s:='**Напрямую**';
  cabcomparam.Traces.Enums.add(@s);
end;
function _Cable_com_CommandStart(operands:pansichar):GDBInteger;
var
   s:gdbstring;
   ir_inGDB:itrec;
   currentobj:PGDBObjNet;
begin
  p3dpl:=nil;
  gdb.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));

  cabcomparam.Pcable:=nil;
  cabcomparam.PTrace:=nil;
  cabcomparam.Traces.Enums.free;
  //cabcomparam.Traces.Selected:=-1;
  CurrentObj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir_inGDB);
  if (CurrentObj<>nil) then
     repeat
           if CurrentObj^.vp.ID=GDBNetID then
           begin
                s:=getentname(CurrentObj);
                if s<>'' then
                begin
                     cabcomparam.Traces.Enums.add(@s);
                     if CurrentObj^.Selected then
                     begin
                          cabcomparam.Traces.Selected:=cabcomparam.Traces.Enums.Count-1;
                     end;

                     if cabcomparam.Traces.Selected=cabcomparam.Traces.Enums.Count-1 then
                                                                                         cabcomparam.PTrace:=CurrentObj;


                end;
           end;
           CurrentObj:=gdb.GetCurrentROOT.ObjArray.iterate(ir_inGDB);
     until CurrentObj=nil;

  s:='**Напрямую**';
  cabcomparam.Traces.Enums.add(@s);
  SetGDBObjInsp(SysUnit.TypeName2PTD('CommandRTEdObject'),pcabcom);



  historyout('Первая точка:');
end;
Procedure _Cable_com_CommandEnd;
begin
  if p3dpl<>nil then
  if p3dpl^.VertexArrayInOCS.Count<2 then
                                         begin
                                              {objinsp.GDBobjinsp.}ReturnToDefault;
                                              p3dpl^.YouDeleted;
                                         end;
  cabcomparam.PCable:=nil;
  cabcomparam.PTrace:=nil;
  //gdbfreemem(pointer(p3dpl));
end;
function _Cable_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var
   pvd:pvardesk;
begin
  result:=mclick;
  if (button and MZW_LBUTTON)<>0 then
  begin
    if p3dpl=nil then
    begin
    p3dpl := GDBPointer(gdb.GetCurrentROOT.ObjArray.CreateinitObj(GDBCableID,gdb.GetCurrentROOT));
    //p3dpl^.init(@gdb.GetCurrentDWG.ObjRoot,gdb.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^);

    //uunitmanager.units.loadunit(expandpath('*blocks\el\cable.pas'),@p3dpl^.ou);
    p3dpl^.ou.copyfrom(units.findunit('cable'));
    //pvd:=p3dpl^.ou.FindVariable('DB_link');
    //pstring(pvd^.data.Instance)^:='Кабель ??';

    {pvd:=p3dpl.ou.FindVariable('NMO_BaseName');
    pstring(pvd^.data.Instance)^:=gdb.numerator.getnamenumber('К');}
    //pvd:=p3dpl.ou.FindVariable('NMO_Prefix');
    //pstring(pvd^.data.Instance)^:='';

    //pvd:=p3dpl.ou.FindVariable('NMO_BaseName');
    //pstring(pvd^.data.Instance)^:='@';

    pvd:=p3dpl.ou.FindVariable('NMO_Suffix');
    pstring(pvd^.data.Instance)^:=inttostr(gdb.GetCurrentDWG.numerator.getnumber('К',true));
    //p3dpl^.bp.Owner:=@gdb.GetCurrentDWG.ObjRoot;
    //gdb.GetCurrentDWG.ObjRoot.ObjArray.add(addr(p3dpl));
    //GDBobjinsp.setptr(SysUnit.TypeName2PTD('GDBObjCable'),p3dpl);
    p3dpl^.AddVertex(wc);
    p3dpl^.Format;
    gdb.GetCurrentROOT.ObjArray.ObjTree.{AddObjectToNodeTree(p3dpl)}CorrectNodeTreeBB(p3dpl);

    cabcomparam.Pcable:=p3dpl;
    //GDBobjinsp.setptr(SysUnit.TypeName2PTD('GDBObjCable'),p3dpl);
    end;
  end
end;

function _Cable_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var //po:PGDBObjSubordinated;
    plastw:pgdbvertex;
    tw1,tw2:gdbvertex;
    l1,l2:pgdbobjline;
    pa:GDBPoint3dArray;
    polydata:tpolydata;
    domethod,undomethod:tmethod;
begin
  result:=mclick;
  p3dpl^.vp.Layer :=gdb.GetCurrentDWG.LayerTable.GetCurrentLayer;
  p3dpl^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
  //p3dpl^.CoordInOCS.lEnd:= wc;
  if (button and MZW_LBUTTON)<>0 then
  begin
    if cabcomparam.PTrace=nil then
    begin
         polydata.nearestvertex:=p3dpl^.VertexArrayInWCS.Count;
         polydata.nearestline:=p3dpl^.VertexArrayInWCS.Count;
         polydata.dir:=1;
         polydata.wc:=wc;
         tmethod(domethod).Code:=pointer(p3dpl.InsertVertex);
         tmethod(domethod).Data:=p3dpl;
         tmethod(undomethod).Code:=pointer(p3dpl.DeleteVertex);
         tmethod(undomethod).Data:=p3dpl;
         with gdb.GetCurrentDWG.UndoStack.PushCreateTGObjectChangeCommand2(polydata,tmethod(domethod),tmethod(undomethod))^ do
         begin
              comit;
         end;
          {p3dpl^.AddVertex(wc);}
          p3dpl^.Format;
          p3dpl^.RenderFeedback;
          gdb.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeTreeBB(p3dpl);
    end
else begin
          plastw:=p3dpl^.VertexArrayInWCS.getelement(p3dpl^.VertexArrayInWCS.Count-1);

          pointer(l1):=cabcomparam.PTrace.GetNearestLine(plastw^);
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
                            pa.init({$IFDEF DEBUGBUILD}'{FE5DE449-60C7-4D92-9BA5-FEB937820B96}',{$ENDIF}100);
                            cabcomparam.PTrace.graf.FindPath(tw1,tw2,l1,l2,pa);
                            if not IsPointEqual(tw1,plastw^) then
                                                                p3dpl^.AddVertex(tw1);
                            pa.copyto(@p3dpl.VertexArrayInOCS);
                            plastw:=p3dpl^.VertexArrayInWCS.getelement(p3dpl^.VertexArrayInWCS.Count-1);
                            if not IsPointEqual(tw2,plastw^) then
                                                                p3dpl^.AddVertex(tw2);
                            if not IsPointEqual(tw2,wc) then
                                                           p3dpl^.AddVertex(wc);
                            pa.done;
                       end;
        p3dpl^.Format;
        p3dpl^.RenderFeedback;
        gdb.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeTreeBB(p3dpl);
     end;
    gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.Count := 0;
    result:=1;
    redrawoglwnd;
  end;
end;
function _Cable_com_Hd(mclick:GDBInteger):GDBInteger;
begin
     //mclick:=mclick;//        asdf
end;
//function _Cable_com_Legend(Operands:pansichar):GDBInteger;
//var i: GDBInteger;
//    pv:pGDBObjEntity;
//    ir,irincable,ir_inNodeArray:itrec;
//    filename,cablename,CableMaterial,CableLength,devstart,devend: GDBString;
//    handle:cardinal;
//    pvd,pvds,pvdal:pvardesk;
//    nodeend,nodestart:PTNodeProp;
//
//    line:gdbstring;
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
//  pv:=gdb.GetCurrentDWG.ObjRoot.ObjArray.beginiterate(ir);
//  if pv<>nil then
//  repeat
//    //if pv^.Selected then
//    if pv^.vp.ID=GDBCableID then
//    begin
//         line:='';
//         pvd:=pv^.ou.FindVariable('NMO_Name');
//         cablename:=pstring(pvd^.data.Instance)^;
//
//         pvd:=pv^.ou.FindVariable('DB_link');
//         CableMaterial:=pstring(pvd^.data.Instance)^;
//
//         pvd:=pv^.ou.FindVariable('AmountD');
//         CableLength:=floattostr(pgdbdouble(pvd^.data.Instance)^);
//
//          firstline:=true;
//          devstart:='Не присоединено';
//          nodestart:=pgdbobjcable(pv)^.NodePropArray.beginiterate(ir_inNodeArray);
//          if nodestart^.DevLink<>nil then
//                                         begin
//                                              pvd:=nodestart^.DevLink^.FindVariable('NMO_Name');
//                                              if pvd<>nil then
//                                                              devstart:=pstring(pvd^.data.Instance)^;
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
//                                    devend:=pstring(pvd^.data.Instance)^;
//                if firstline then
//                                 line:=cablename+';'+CableMaterial+';'+CableLength+';'+devstart+';'+devend+#13#10
//                             else
//                                 line:={cablename+}';'+{CableMaterial+}';'+{CableLength+}';'+devstart+';'+devend+#13#10;
//                FileWrite(handle,line[1],length(line));
//                firstline:=false;
//                devstart:=devend;
//                nodeend:=pgdbobjcable(pv)^.NodePropArray.iterate(ir_inNodeArray);
//          until nodeend=nil;
//         historyoutstr(cablename+' '+CableMaterial+' '+CableLength);
//
//
//    end;
//  pv:=gdb.GetCurrentDWG.ObjRoot.ObjArray.iterate(ir);
//  until pv=nil;
//  redrawoglwnd;
//  FileClose(handle);
//  end;
//  result:=cmd_ok;
//end;
function _Cable_com_Legend(Operands:pansichar):GDBInteger;
var //i: GDBInteger;
    pv:PTCableDesctiptor;
    ir,{irincable,}ir_inNodeArray:itrec;
    filename,cablename,CableMaterial,CableLength,devstart,devend,puredevstart: GDBString;
    handle:cardinal;
    pvd{,pvds,pvdal}:pvardesk;
    nodeend,nodestart:PGDBObjDevice;

    line,s:gdbstring;
    firstline:boolean;
    cman:TCableManager;
    pt:PGDBObjTable;
    psl{,psfirstline}:PGDBGDBStringArray;

    eq:pvardesk;
begin
  if SaveFileDialog(filename,'CSV',CSVFileFilter,'','Сохранить данные...') then
  begin
  DecimalSeparator := ',';
  cman.init;
  cman.build;
  handle:=FileCreate(UTF8ToSys(filename),fmOpenWrite);
  line:=Tria_Utf8ToAnsi('Обозначение'+';'+'Материал'+';'+'Длина'+';'+'Начало'+';'+'Конец'+#13#10);
  FileWrite(handle,line[1],length(line));
  pv:=cman.beginiterate(ir);
  if pv<>nil then
  begin
                     GDBGetMem({$IFDEF DEBUGBUILD}'{9F4AB2A7-1093-4FFB-8053-E8885D691B85}',{$ENDIF}pointer(pt),sizeof(GDBObjTable));
                     pt^.initnul;
                     pt^.ptablestyle:=gdb.GetCurrentDWG.TableStyleTable.getAddres('KZ');
                     pt^.tbl.cleareraseobj;
  repeat
    begin
         cablename:=pv^.Name;

         if cablename='RS' then
                               cablename:=cablename;


         pvd:=pv^.StartSegment.ou.FindVariable('DB_link');
         CableMaterial:=pstring(pvd^.data.Instance)^;

                                        eq:=DWGDBUnit.FindVariable(CableMaterial);
                                        if eq<>nil then
                                                      begin
                                                           CableMaterial:=PDbBaseObject(eq^.data.Instance)^.NameShort;
                                                      end;
         CableLength:=floattostr(pv^.length);

          firstline:=true;
          devstart:='Не присоединено';
          nodestart:=pv^.Devices.beginiterate(ir_inNodeArray);
          if pv^.StartDevice<>nil then
                                         begin
                                              pvd:=pv^.StartDevice^.FindVariable('NMO_Name');
                                              if pvd<>nil then
                                                              devstart:=pstring(pvd^.data.Instance)^;
                                              nodeend:=pv^.Devices.iterate(ir_inNodeArray);
                                         end
                                  else
                                      nodeend:=nodestart;
          puredevstart:=devstart;
                psl:=pointer(pt^.tbl.CreateObject);
                psl.init(12);
          repeat
                devend:='Не присоединено';
                repeat
                            if nodeend=nil then system.break;
                            pvd:=nodeend^.FindVariable('NMO_Name');
                            if pvd=nil then
                                           nodeend:=pv^.Devices.iterate(ir_inNodeArray);
                until pvd<>nil;
                if nodeend<>nil then
                                    devend:=pstring(pvd^.data.Instance)^;
                {psl:=pointer(pt^.tbl.CreateObject);
                psl.init(12);}
                if firstline then
                                 begin
                                 line:='`'+cablename+';'+CableMaterial+';'+CableLength+';'+devstart+';'+devend+#13#10;
                                 s:='';
                                 psl.addutoa(@(cablename));
                                 psl.addutoa(@devstart);
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
                FileWrite(handle,(line)[1],length((line)));
                firstline:=false;
                devstart:=devend;
                nodeend:=pv^.Devices.iterate(ir_inNodeArray);
          until nodeend=nil;
                                 s:='';
                                 psl.addutoa(@devend);
                                 psl.addutoa(@s);
                                 psl.addutoa(@s);
                                 psl.addutoa(@s);
                                 psl.addutoa(@s);
                                 psl.addutoa(@CableMaterial);
                                 psl.addutoa(@CableLength);
                                 psl.addutoa(@s);
                                 psl.addutoa(@s);
                                 s:='';
                                 psl.addutoa(@s);

         //historyoutstr(cablename+' '+CableMaterial+' '+CableLength);
         HistoryOutStr('Кабель "'+pv^.Name+'", сегментов '+inttostr(pv^.Segments.Count)+', материал "'+CableMaterial+'", начало: '+puredevstart+' конец: '+devend);


    end;
  pv:=cman.iterate(ir);
  until pv=nil;

  gdb.GetCurrentROOT.AddObjectToObjArray{ObjArray.add}(@pt);
  pt^.Build;
  pt^.Format;
  end;
  redrawoglwnd;
  FileClose(handle);
  cman.done;
  DecimalSeparator := '.';
  end;
  result:=cmd_ok;
end;
function _Material_com_Legend(Operands:pansichar):GDBInteger;
var //i: GDBInteger;
    pv:pGDBObjEntity;
    ir,{irincable,ir_inNodeArray,}ir_inscf:itrec;
    s,filename{,cablename,CableMaterial,CableLength,devstart}: GDBString;
    currentgroup:PGDBString;
    handle:cardinal;
    pvad,pvai,pvm:pvardesk;
    //nodeend,nodestart:PTNodeProp;

    line:gdbstring;
    //firstline:boolean;

    bom:GDBBbillOfMaterial;
    PBOMITEM:PGDBBOMItem;

    pt:PGDBObjTable;
    psl{,psfirstline}:PGDBGDBStringArray;

    pdbu:ptunit;
    pdbv:pvardesk;
    pdbi:PDbBaseObject;
begin
  if SaveFileDialog(filename,'CSV',CSVFileFilter,'','Сохранить данные...') then
  begin
  bom.init(1000);
  handle:=FileCreate(UTF8ToSys(filename),fmOpenWrite);
  line:=Tria_Utf8ToAnsi('Материал'+';'+'Количество'+';'+'Устройства'+#13#10);
  FileWrite(handle,line[1],length(line));
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    begin
         pvm:=pv^.ou.FindVariable('DB_link');
         if pvm<>nil then
         begin
              pvad:=pv^.ou.FindVariable('AmountD');
              pvai:=pv^.ou.FindVariable('AmountI');
              //if (pvad<>nil)or(pvai<>nil) then
              begin
                   pbomitem:=bom.findorcreate(pstring(pvm^.data.Instance)^);
                   if pbomitem<>nil then
                   begin
                        if (pvad<>nil) then
                                           pbomitem.Amount:=pbomitem.Amount+pgdbdouble(pvad^.data.Instance)^
                   else if (pvai<>nil) then
                                           pbomitem.Amount:=pbomitem.Amount+pgdbinteger(pvai^.data.Instance)^
                   else
                       pbomitem.Amount:=pbomitem.Amount+1;
                        pvm:=pv^.ou.FindVariable('NMO_Name');
                        if (pvm<>nil) then
                                           if pbomitem.Names<>'' then
                                                                     pbomitem.Names:=pbomitem.Names+','+pstring(pvm^.data.Instance)^
                                                                 else
                                                                     pbomitem.Names:=pstring(pvm^.data.Instance)^;


                   end;
              end;
         end;
    end;
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  DecimalSeparator := ',';
  PBOMITEM:=bom.beginiterate(ir);
  if PBOMITEM<>nil then
  repeat
          line:=pbomitem.Material+';'+floattostr(pbomitem.Amount)+';'+pbomitem.Names+#13#10;
          line:=Tria_Utf8ToAnsi(line);
          FileWrite(handle,line[1],length(line));

        PBOMITEM:=bom.iterate(ir);
  until PBOMITEM=nil ;
  DecimalSeparator := '.';
  FileClose(handle);


                     GDBGetMem({$IFDEF DEBUGBUILD}'{76882CEC-39E7-459C-9CCB-F596DE17539A}',{$ENDIF}pointer(pt),sizeof(GDBObjTable));
                     pt^.initnul;
                     pt^.ptablestyle:=gdb.GetCurrentDWG.TableStyleTable.getAddres('Spec');
                     pt^.tbl.cleareraseobj;

  pdbu:=gdb.GetCurrentDWG.DWGUnits.findunit('drawingdevicebase');
  currentgroup:=MainSpecContentFormat.beginiterate(ir_inscf);
  if currentgroup<>nil then
  if length(currentgroup^)>1 then
  repeat
  if currentgroup^[1]='!' then
              begin
                   psl:=pointer(pt^.tbl.CreateObject);
                   psl.init(2);

                   s:='';
                   psl.add(@s);

                   s:=Tria_Utf8ToAnsi(currentgroup^);
                   s:='  '+system.copy(s,2,length(s)-1);
                   //s:='  '+system.copy(currentgroup^,2,length(currentgroup^)-1);
                   psl.add(@s);
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
                   pdbi:=pdbv^.data.Instance;
                   if MatchesMask(pdbi^.Group,currentgroup^) then

                   begin
                   PBOMITEM.processed:=true;
                   psl:=pointer(pt^.tbl.CreateObject);
                   psl.init(9);

                   s:=pdbi^.Position;
                   psl.addutoa(@s);

                   s:=' '+pdbi^.NameFull;
                   psl.addutoa(@s);

                   s:=pdbi^.NameShort+' '+pdbi^.Standard;
                   psl.addutoa(@s);

                   s:=pdbi^.OKP;
                   psl.addutoa(@s);

                   s:=pdbi^.Manufacturer;
                   psl.addutoa(@s);

                   s:='??';
                   case pdbi^.EdIzm of
                                      _sht:s:='шт.';
                                      _m:s:='м';
                   end;
                   psl.addutoa(@s);

                   s:=floattostr(PBOMITEM^.Amount);
                   psl.add(@s);

                   s:='';
                   psl.addutoa(@s);
                   psl.addutoa(@s);
                   end;


              end;
                line:=pbomitem.Material+';'+floattostr(pbomitem.Amount)+';'+pbomitem.Names+#13#10;
                FileWrite(handle,line[1],length(line));

              PBOMITEM:=bom.iterate(ir);
        until PBOMITEM=nil;
      end;

        currentgroup:=MainSpecContentFormat.iterate(ir_inscf);
  until currentgroup=nil;

  gdb.GetCurrentROOT.AddObjectToObjArray{ObjArray.add}(@pt);
  pt^.Build;
  pt^.Format;


  redrawoglwnd;
  bom.done;
  end;
  result:=cmd_ok;
end;
function _Cable_com_Select(Operands:pansichar):GDBInteger;
var //i: GDBInteger;
    pv:pGDBObjEntity;
    ir,irnpa:itrec;
    ptn{,ptnfirst,ptnfirst2,ptnlast,ptnlast2}:PTNodeProp;
    currentobj{,CurrentSubObj,CurrentSubObj2,ptd}:PGDBObjDevice;
begin
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
    if pv^.vp.ID=GDBCableID then
    begin
             ptn:=PGDBObjCable(pv)^.NodePropArray.beginiterate(irnpa);
             if ptn<>nil then
                repeat
                    if ptn^.DevLink<>nil then
                    begin
                    CurrentObj:=pointer(ptn^.DevLink^.bp.ListPos.owner);
                    CurrentObj^.select;
                    end;

                    ptn:=PGDBObjCable(pv)^.NodePropArray.iterate(irnpa);
                until ptn=nil;
    end;
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  redrawoglwnd;
  result:=cmd_ok;
end;
function _Cable_com_Invert(Operands:pansichar):GDBInteger;
var //i: GDBInteger;
    pv:pGDBObjEntity;
    ir:itrec;
begin
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
    if pv^.vp.ID=GDBCableID then
    begin
         PGDBObjCable(pv)^.VertexArrayInOCS.invert;
         pv^.Format;
         historyoutstr('Направление изменено');
    end;
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  redrawoglwnd;
  result:=cmd_ok;
end;
function _Cable_com_Join(Operands:pansichar):GDBInteger;
var //i: GDBInteger;
    pv:pGDBObjEntity;
    pc1,pc2:PGDBObjCable;
    pv11,pv12,pv21,pv22:Pgdbvertex;
    ir:itrec;
begin
  pc1:=nil;
  pc2:=nil;
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
    if pv^.vp.ID=GDBCableID then
    begin
         if pc1=nil then
                        pc1:=pointer(pv)
    else if pc2=nil then
                        pc2:=pointer(pv)
    else begin
              historyoutstr('Выбрано больше 2х кабелей!');
              exit;
         end;
    end;
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  if pc2=nil then
                 begin
                      historyoutstr('Выбери 2 кабеля!');
                      exit;
                 end;
  pv11:=pc1.VertexArrayInWCS.getelement(0);
  pv12:=pc1.VertexArrayInWCS.getelement(pc1.VertexArrayInWCS.Count-1);
  pv21:=pc2.VertexArrayInWCS.getelement(0);
  pv22:=pc2.VertexArrayInWCS.getelement(pc2.VertexArrayInWCS.Count-1);

     if geometry.Vertexlength(pv11^,pv21^)<eps then
                                                   begin
                                                        pc1.VertexArrayInOCS.Invert;
                                                        pc2.VertexArrayInOCS.deleteelement(0);
                                                        pc2.VertexArrayInOCS.copyto(@pc1.VertexArrayInOCS);
                                                        pc2.YouDeleted;
                                                   end
else if geometry.Vertexlength(pv12^,pv21^)<eps then
                                                   begin
                                                        pc2.VertexArrayInOCS.deleteelement(0);
                                                        pc2.VertexArrayInOCS.copyto(@pc1.VertexArrayInOCS);
                                                        pc2.YouDeleted;
                                                   end
else if geometry.Vertexlength(pv11^,pv22^)<eps then
                                                   begin
                                                        pc1.VertexArrayInOCS.deleteelement(0);
                                                        pc1.VertexArrayInOCS.copyto(@pc2.VertexArrayInOCS);
                                                        pc1.YouDeleted;
                                                        pc1:=pc2
                                                   end
else if geometry.Vertexlength(pv12^,pv22^)<eps then
                                                   begin
                                                        pc2.VertexArrayInOCS.Invert;
                                                        pc2.VertexArrayInOCS.deleteelement(0);
                                                        pc2.VertexArrayInOCS.copyto(@pc1.VertexArrayInOCS);
                                                        pc2.YouDeleted;
                                                   end
else
                                                   begin
                                                        historyoutstr('Кабели не соединены!');
                                                        exit;
                                                   end;




  pc1.format;
  gdb.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount:=0;
  gdb.GetCurrentDWG.OGLwindow1.param.seldesc.OnMouseObject:=nil;
  gdb.GetCurrentDWG.OGLwindow1.param.seldesc.LastSelectedObject:=nil;
  {objinsp.GDBobjinsp.}ReturnToDefault;
  clearcp;

  redrawoglwnd;
  result:=cmd_ok;
end;
function Find_com(Operands:pansichar):GDBInteger;
//var i: GDBInteger;
   // pv:pGDBObjEntity;
   // ir:itrec;
begin
  SetGDBObjInsp(SysUnit.TypeName2PTD('CommandRTEdObject'),pfindcom);
  gdb.GetCurrentDWG.SelObjArray.clearallobjects;
  gdb.GetCurrentROOT.ObjArray.DeSelect;
  result:=cmd_ok;
  redrawoglwnd;
end;
procedure commformat;
var pv,pvlast:pGDBObjEntity;
    v:pvardesk;
    varvalue,sourcestr,varname:gdbstring;
    ir:itrec;
    count:integer;
    //a:HandledMsg;
    tpz{, glx1, gly1}: GDBDouble;
  {fv1,}tp,wcsLBN,wcsRTF,dcsLBN,dcsRTF: GDBVertex;
    findvarvalue:gdbboolean;
begin
  gdb.GetCurrentDWG.SelObjArray.clearallobjects;
  gdb.GetCurrentROOT.ObjArray.DeSelect;
   case FindDeviceParam.FindType of
      tft_obozn:begin
                     varname:=('NMO_Name');
                end;
      TFT_DBLink:begin
                     varname:=('DB_link');
                end;
   end;

  sourcestr:=uppercase(FindDeviceParam.FindString);

  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  count:=0;
  if pv<>nil then
  repeat
        findvarvalue:=false;
        v:=pv^.OU.FindVariable(varname);
        if v<>nil then
        begin
             varvalue:=uppercase(v^.data.PTD.GetValueAsString(v^.data.Instance));
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
                  pv^.select;
                  pvlast:=pv;
                  inc(count);
               end;
        end;

  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;



  if count=1 then
  begin
        dcsLBN:=InfinityVertex;
        dcsRTF:=MinusInfinityVertex;
        wcsLBN:=InfinityVertex;
        wcsRTF:=MinusInfinityVertex;
        tp:=ProjectPoint(pvlast^.vp.BoundingBox.LBN.x,pvlast^.vp.BoundingBox.LBN.y,pvlast^.vp.BoundingBox.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
        tp:=ProjectPoint(pvlast^.vp.BoundingBox.RTF.x,pvlast^.vp.BoundingBox.LBN.y,pvlast^.vp.BoundingBox.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
        tp:=ProjectPoint(pvlast^.vp.BoundingBox.RTF.x,pvlast^.vp.BoundingBox.RTF.y,pvlast^.vp.BoundingBox.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
        tp:=ProjectPoint(pvlast^.vp.BoundingBox.LBN.x,pvlast^.vp.BoundingBox.RTF.y,pvlast^.vp.BoundingBox.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
        tp:=ProjectPoint(pvlast^.vp.BoundingBox.LBN.x,pvlast^.vp.BoundingBox.LBN.y,pvlast^.vp.BoundingBox.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
        tp:=ProjectPoint(pvlast^.vp.BoundingBox.RTF.x,pvlast^.vp.BoundingBox.LBN.y,pvlast^.vp.BoundingBox.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
        tp:=ProjectPoint(pvlast^.vp.BoundingBox.RTF.x,pvlast^.vp.BoundingBox.RTF.y,pvlast^.vp.BoundingBox.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
        tp:=ProjectPoint(pvlast^.vp.BoundingBox.LBN.x,pvlast^.vp.BoundingBox.RTF.y,pvlast^.vp.BoundingBox.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
  gdb.GetCurrentDWG.pcamera^.prop.point.x:=-(wcsLBN.x+(wcsRTF.x-wcsLBN.x)/2);
  gdb.GetCurrentDWG.pcamera^.prop.point.y:=-(wcsLBN.y+(wcsRTF.y-wcsLBN.y)/2);


  gdb.GetCurrentDWG.pcamera^.prop.zoom:=(wcsRTF.x-wcsLBN.x)/gdb.GetCurrentDWG.OGLwindow1.clientwidth;
  tpz:=(wcsRTF.y-wcsLBN.y)/gdb.GetCurrentDWG.OGLwindow1.clientheight;

  if tpz>gdb.GetCurrentDWG.pcamera^.prop.zoom then gdb.GetCurrentDWG.pcamera^.prop.zoom:=tpz;

  gdb.GetCurrentDWG.OGLwindow1.CalcOptimalMatrix;
  gdb.GetCurrentDWG.OGLwindow1.mouseunproject(gdb.GetCurrentDWG.OGLwindow1.param.md.mouse.x, gdb.GetCurrentDWG.OGLwindow1.param.md.mouse.y);
  gdb.GetCurrentDWG.OGLwindow1.reprojectaxis;
  //OGLwindow1.param.firstdraw := true;
  //gdb.GetCurrentDWG.pcamera^.getfrustum(@gdb.GetCurrentDWG.pcamera^.modelMatrix,@gdb.GetCurrentDWG.pcamera^.projMatrix,gdb.GetCurrentDWG.pcamera^.clipLCS,gdb.GetCurrentDWG.pcamera^.frustum);
  gdb.GetCurrentROOT.Format;
  //gdb.GetCurrentDWG.ObjRoot.calcvisible;
  //gdb.GetCurrentDWG.ConstructObjRoot.calcvisible;
  end;
  redrawoglwnd;
  historyoutstr('Найдено '+inttostr(count)+' объектов');
end;
function _Cable_mark_com(Operands:pansichar):GDBInteger;
var //i: GDBInteger;
    pv:pGDBObjDevice;
    ir{,irincable,ir_inNodeArray}:itrec;
    //filename,cablename,CableMaterial,CableLength,devstart,devend: GDBString;
    //handle:cardinal;
    pvn{,pvm,pvmc,pvl}:pvardesk;
    //nodeend,nodestart:PTNodeProp;

    //line:gdbstring;
    cman:TCableManager;
    pcd:PTCableDesctiptor;
begin
  cman.init;
  cman.build;
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    begin
         if pv^.vp.ID=GDBDeviceID then
         if pv^.Name='CABLE_MARK' then
         begin
              pvn:=pv^.ou.FindVariable('CableName');
              if (pvn<>nil) then
              begin
                   pcd:=cman.Find(pstring(pvn^.data.Instance)^);
                   if pcd<>nil then
                   begin
                        Cable2CableMark(pcd,pv);
                        {pvm:=pv^.ou.FindVariable('CableMaterial');
                        if pvm<>nil then
                                    begin
                                        pvmc:=pcd^.StartSegment^.FindVariable('DB_link');
                                        if pvmc<>nil then
                                        begin
                                        line:=pstring(pvmc^.data.Instance)^;
                                        pstring(pvm^.data.Instance)^:=line;
                                        end
                                        else
                                            pgdbstring(pvm^.data.Instance)^:='Не определен';
                                    end;
                       pvl:=pv^.ou.FindVariable('CableLength');
                       if pvl<>nil then
                                       pgdbdouble(pvl^.data.Instance)^:=pcd^.length;}
                       pv^.Format;
                   end
                      else
                          historyoutstr('Кабель "'+pstring(pvn^.data.Instance)^+'" на плане не найден');
              end;
         end;
    end;
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;

  redrawoglwnd;
  cman.done;
  result:=cmd_ok;
end;
function El_Leader_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var //po:PGDBObjSubordinated;
    pleader:PGDBObjElLeader;
begin
  //result:=Line_com_AfterClick(wc,mc,button,osp,mclick);
  result:=mclick;
  PCreatedGDBLine^.vp.Layer :=gdb.GetCurrentDWG.LayerTable.GetCurrentLayer;
  PCreatedGDBLine^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
  PCreatedGDBLine^.CoordInOCS.lEnd:= wc;
  PCreatedGDBLine^.Format;
  //po:=nil;
  if osp<>nil then
  begin
       if (PGDBObjEntity(osp^.PGDBObject)<>nil)and(osp^.PGDBObject<>pold)
       then
       begin
            PGDBObjEntity(osp^.PGDBObject)^.format;
            //PGDBObjEntity(osp^.PGDBObject)^.ObjToGDBString('Found: ','');
            historyout(GDBPointer(PGDBObjline(osp^.PGDBObject)^.ObjToGDBString('Found: ','')));
            //po:=PGDBObjEntity(osp^.PGDBObject)^.getowner;
            pold:=osp^.PGDBObject;
       end
  end else pold:=nil;
  //pl^.RenderFeedback;
  if (button and MZW_LBUTTON)<>0 then
  begin
    begin
    PCreatedGDBLine^.bp.ListPos.Owner:=gdb.GetCurrentROOT;

  GDBGetMem({$IFDEF DEBUGBUILD}'{33202D9B-6197-4A09-8BC8-1D24AA3053DA}',{$ENDIF}pointer(pleader),sizeof(GDBObjElLeader));
  pleader^.initnul;
  pleader^.scale:=ELLeaderComParam.Scale;
  pleader^.size:=ELLeaderComParam.Size;
  pleader^.vp.Layer:=gdb.GetCurrentDWG.LayerTable.GetCurrentLayer;
  pleader.MainLine.CoordInOCS.lBegin:=PCreatedGDBLine^.CoordInOCS.lBegin;
  pleader.MainLine.CoordInOCS.lEnd:=PCreatedGDBLine^.CoordInOCS.lEnd;

  gdb.GetCurrentROOT.AddObjectToObjArray{ObjArray.add}(@pleader);
  pleader^.Format;

    end;
    gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
    result:=-1;
    redrawoglwnd;
  end;
end;
function ElLeaser_com_CommandStart(operands:pansichar):GDBInteger;
begin
  pold:=nil;
  GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  sysvar.dwg.DWG_OSMode^:=sysvar.dwg.DWG_OSMode^ or osm_nearest;
  SetGDBObjInsp(SysUnit.TypeName2PTD('TELLeaderComParam'),@ELLeaderComParam);
  historyout('Первая точка:');
end;
function _Cable_com_Manager(Operands:pansichar):GDBInteger;
//var i: GDBInteger;
    //pv:pGDBObjEntity;
    //ir:itrec;
begin
        CableManager.init;
        CableManager.build;

        SetGDBObjInsp(SysUnit.TypeName2PTD('TCableManager'),@CableManager);


end;
function _Ren_n_to_0n_com(Operands:pansichar):GDBInteger;
var {i,}len: GDBInteger;
    pv:pGDBObjEntity;
    ir:itrec;
    pvd{,pvn,pvm,pvmc,pvl}:pvardesk;
    name:gdbstring;
begin
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.vp.ID=GDBCableID then
    begin
         pvd:=pv^.ou.FindVariable('NMO_Name');
         if pvd<>nil then
                         begin
                              name:=pgdbstring(pvd.data.Instance)^;
                              len:=length(name);
                              if len=3 then
                              if name[len] in ['0'..'9'] then
                              if not(name[len-1] in ['0'..'9']) then
                              begin
                                   name:=system.copy(name,1,len-1)+'0'+system.copy(name,len,1);
                                   pgdbstring(pvd.data.Instance)^:=name;
                                   historyoutstr('Переименован кабель '+name);
                              end
                                 {else
                                     historyoutstr(name);;}
                         end;
    end;
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
end;
function _SelectMaterial_com(Operands:pansichar):GDBInteger;
var //i,len: GDBInteger;
    pv:pGDBObjEntity;
    ir:itrec;
    pvd{,pvn,pvm,pvmc,pvl}:pvardesk;
    mat:gdbstring;
begin
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if (pv^.vp.ID=GDBCableID)
    or (pv^.vp.ID=GDBCableID) then
    begin
         pvd:=pv^.ou.FindVariable('DB_link');
         if pvd<>nil then
                         begin
                              mat:=pgdbstring(pvd.data.Instance)^;
                              if uppercase(mat)=uppercase(operands) then
                                                                        begin
                                                                        //pv^.Select;
                                                                        pgdbstring(pvd.data.Instance)^:='ТППэП 20х2х0.5';
                                                                        end;
                         end;
    end;
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  //commandmanager.executecommandend;
  //OGLwindow1.SetObjInsp;
      //updatevisible;
end;

function _test_com(Operands:pansichar):GDBInteger;
var i: GDBInteger;
    pv:pGDBObjEntity;
    ir:itrec;
    pvd{,pvn,pvm,pvmc,pvl}:pvardesk;
    mat:gdbstring;
begin
     historyout('Тест производительности. запасаемя терпением');
     {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('тест производительности - getonmouseobject*10000',lp_IncPos);{$ENDIF}
     for i:=0 to 10000 do
            gdb.GetCurrentDWG.OGLwindow1.getonmouseobject(@gdb.GetCurrentROOT.ObjArray);
     {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('тест производительности',lp_DecPos);{$ENDIF}
     historyout('Конец теста. выходим, смотрим результаты в конце лога.');
     quit_com('');
end;


procedure startup;
//var
  // s:gdbstring;
begin
  MainSpecContentFormat.init(100);
  MainSpecContentFormat.loadfromfile(FindInSupportPath('main.sf'));
  Wire.init('El_Wire',0,0);
  commandmanager.CommandRegister(@Wire);
  pcabcom:=CreateCommandRTEdObjectPlugin(@_Cable_com_CommandStart, _Cable_com_CommandEnd,nil,@cabcomformat,@_Cable_com_BeforeClick,@_Cable_com_AfterClick,@_Cable_com_Hd,'EL_Cable',0,0);

  pcabcom^.commanddata.Instance:=@cabcomparam;
  pcabcom^.commanddata.PTD:=SysUnit.TypeName2PTD('TELCableComParam');
  cabcomparam.Traces.Enums.init(10);
  cabcomparam.PTrace:=nil;

  CreateCommandFastObjectPlugin(@_Cable_com_Invert,'El_Cable_Invert',CADWG,0);
  CreateCommandFastObjectPlugin(@_Cable_com_Manager,'El_CableMan',CADWG,0);
  CreateCommandFastObjectPlugin(@_Cable_com_Legend,'El_Cable_Legend',CADWG,0);
  CreateCommandFastObjectPlugin(@_Cable_com_Join,'El_Cable_Join',CADWG,0);
  csel:=CreateCommandFastObjectPlugin(@_Cable_com_Select,'El_Cable_Select',CADWG,0);
  csel.CEndActionAttr:=0;
  CreateCommandFastObjectPlugin(@_Material_com_Legend,'El_Material_Legend',CADWG,0);
  CreateCommandFastObjectPlugin(@_Cable_mark_com,'KIP_Cable_Mark',CADWG,0);

  CreateCommandFastObjectPlugin(@_Ren_n_to_0n_com,'El_Cable_RenN_0N',CADWG,0);
  CreateCommandFastObjectPlugin(@_SelectMaterial_com,'SelMat',CADWG,0);
  CreateCommandFastObjectPlugin(@_test_com,'test',CADWG,0);

  EM_SRBUILD.init('EM_SRBUILD',0,0);
  EM_SEPBUILD.init('EM_SEPBUILD',0,0);

  EM_SEPBUILD.commanddata.Instance:=@em_sepbuild_params;
  EM_SEPBUILD.commanddata.PTD:=SysUnit.TypeName2PTD('TBasicFinter');

  CreateCommandRTEdObjectPlugin(@ElLeaser_com_CommandStart,@Line_com_CommandEnd,nil,nil,@Line_com_BeforeClick,@El_Leader_com_AfterClick,nil,'El_Leader',0,0);
  pfindcom:=CreateCommandRTEdObjectPlugin(@Find_com,nil,nil,@commformat,nil,nil,nil,'El_Find',0,0);
  pfindcom.CEndActionAttr:=0;
  pfindcom^.commanddata.Instance:=@FindDeviceParam;
  pfindcom^.commanddata.PTD:=SysUnit.TypeName2PTD('TFindDeviceParam');
  FindDeviceParam.FindType:=tft_obozn;
  FindDeviceParam.FindString:='';
  ELLeaderComParam.Scale:=1;
  ELLeaderComParam.Size:=1;
end;

procedure finalize;
begin
     MainSpecContentFormat.FreeAndDone;
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('GDBCommandsElectrical.initialization');{$ENDIF}
  startup;
finalization
  finalize;
end.


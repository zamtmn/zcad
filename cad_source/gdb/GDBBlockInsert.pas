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
unit GDBBlockInsert;
{$INCLUDE def.inc}

interface
uses UGDBLayerArray,GDBBlockDef{,UGDBLayerArray},math,gdbasetypes,GDBComplex,{GDBGenericSubEntry,}SysInfo,sysutils,
{UGDBOpenArrayOfPV,}UGDBObjBlockdefArray{,UGDBSelectedObjArray,UGDBVisibleOpenArray},gdbEntity,varman{,varmandef},
gl,UGDBEntTree,
GDBase,UGDBDescriptor{,GDBWithLocalCS},gdbobjectsconstdef,oglwindowdef,geometry,dxflow,memman,GDBSubordinated,UGDBOpenArrayOfByte;
const zcadmetric='!!ZMODIFIER:';
type
{Export+}
PGDBObjBlockInsert=^GDBObjBlockInsert;
GDBObjBlockInsert=object(GDBObjComplex)
                     scale:GDBvertex;(*saved_to_shd*)
                     rotate:GDBDouble;(*saved_to_shd*)
                     index:GDBInteger;(*saved_to_shd*)(*oi_readonly*)(*hidden_in_objinsp*)
                     Name:GDBString;(*saved_to_shd*)(*oi_readonly*)
                     pattrib:GDBPointer;(*hidden_in_objinsp*)
                     BlockDesc:TBlockDesc;(*'Block params'*)(*saved_to_shd*)(*oi_readonly*)
                     constructor initnul;
                     constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                     procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTUnit);virtual;
                     function FromDXFPostProcessBeforeAdd(ptu:PTUnit):PGDBObjSubordinated;virtual;

                     procedure SaveToDXF(var handle:longint; var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
                     procedure CalcObjMatrix;virtual;
                     function getosnappoint(ostype:GDBFloat):gdbvertex;virtual;
                     function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                     //procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;
                     //procedure rtmodifyonepoint(point:pcontrolpointdesc;tobj:PGDBObjEntity;dist,wc:gdbvertex;ptdata:GDBPointer);virtual;
                     destructor done;virtual;
                     function GetObjTypeName:GDBString;virtual;
                     procedure correctobjects(powner:PGDBObjEntity;pinownerarray:GDBInteger);virtual;
                     procedure BuildGeometry;virtual;
                     procedure BuildVarGeometry;virtual;

                     procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
                     procedure ReCalcFromObjMatrix;virtual;
                     procedure rtsave(refp:GDBPointer);virtual;

                     procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;
                     procedure Format;virtual;

                     function getrot:GDBDouble;virtual;
                     procedure setrot(r:GDBDouble);virtual;

                     property testrotate:GDBDouble read getrot write setrot;(*'Rotate'*)

                     //function ProcessFromDXFObjXData(_Name,_Value:GDBString):GDBBoolean;virtual;
                  end;
{Export-}
implementation
uses {GDBNet,}GDBDevice{,GDBTEXT},log;
procedure GDBObjBlockInsert.ReCalcFromObjMatrix;
var
    ox:gdbvertex;
begin
     inherited;
     Local.basis.ox:=PGDBVertex(@objmatrix[0])^;
     Local.basis.oy:=PGDBVertex(@objmatrix[1])^;

     Local.basis.ox:=normalizevertex(Local.basis.ox);
     Local.basis.oy:=normalizevertex(Local.basis.oy);
     Local.basis.oz:=normalizevertex(Local.basis.oz);

     Local.P_insert:=PGDBVertex(@objmatrix[3])^;

     scale.x:=geometry.oneVertexlength(PGDBVertex(@objmatrix[0])^);
     scale.y:=geometry.oneVertexlength(PGDBVertex(@objmatrix[1])^);
     scale.z:=geometry.oneVertexlength(PGDBVertex(@objmatrix[2])^);

     {if abs(local.OX.x)>eps then
                                scale.x:=PGDBVertex(@objmatrix[0])^.x/local.OX.x
                            else
                                scale.x:=1;
     if abs(local.Oy.y)>eps then
                                scale.y:=PGDBVertex(@objmatrix[1])^.y/local.Oy.y
     else
         scale.y:=1;

     if abs(local.Oz.z)>eps then
                                scale.z:=PGDBVertex(@objmatrix[2])^.z/local.Oz.z
     else
         scale.z:=1;
     }

     if (abs (Local.basis.oz.x) < 1/64) and (abs (Local.basis.oz.y) < 1/64) then
                                                                    ox:=CrossVertex(YWCS,Local.basis.oz)
                                                                else
                                                                    ox:=CrossVertex(ZWCS,Local.basis.oz);
     normalizevertex(ox);
     rotate:=geometry.scalardot(Local.basis.ox,ox);
     rotate:=arccos(rotate)*180/pi;
     if local.basis.OX.y<-eps then rotate:=360-rotate;
end;
procedure GDBObjBlockInsert.setrot(r:GDBDouble);
var m1:DMatrix4D;
begin
m1:=onematrix;
m1[0,0]:=cos(r*pi/180);
m1[1,1]:=cos(r*pi/180);
m1[1,0]:=-sin(r*pi/180);
m1[0,1]:=sin(r*pi/180);
objMatrix:=MatrixMultiply(m1,objMatrix);
end;
function GDBObjBlockInsert.getrot:GDBDouble;
begin
     result:=arccos((objmatrix[0,0])/geometry.oneVertexlength(PGDBVertex(@objmatrix[0])^))*180/pi
end;

procedure GDBObjBlockInsert.Format;
begin
     inherited;
end;
procedure GDBObjBlockInsert.AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);
//var tv:gdbvertex;
begin
     posr.arrayworldaxis.Add(@local.basis.OX);
     posr.arrayworldaxis.Add(@local.basis.OY);
end;
procedure GDBObjBlockInsert.rtsave;
//var m:DMatrix4D;
begin
  inherited;
  PGDBObjBlockInsert(refp)^.rotate := rotate;
  PGDBObjBlockInsert(refp)^.scale := scale;
end;
procedure GDBObjBlockInsert.CalcObjMatrix;
var m1:DMatrix4D;
begin
  inherited CalcObjMatrix;
  {m1:= OneMatrix;

  m1[0,0]:=cos(rotate*pi/180);
  m1[1,1]:=cos(rotate*pi/180);
  m1[1,0]:=-sin(rotate*pi/180);
  m1[0,1]:=sin(rotate*pi/180);
  objMatrix:=MatrixMultiply(m1,objMatrix);}
  setrot(rotate);

  m1:=OneMatrix;
  m1[0, 0] := scale.x;
  m1[1, 1] := scale.y;
  m1[2, 2] := scale.z;
  objMatrix:=MatrixMultiply(m1,objMatrix);
end;
procedure GDBObjBlockInsert.TransformAt;
var
    ox:gdbvertex;
begin
     inherited;
     ReCalcFromObjMatrix;
end;
procedure GDBObjBlockInsert.correctobjects;
var pobj:PGDBObjEntity;
    ir:itrec;
begin
     bp.ListPos.Owner:=powner;
     bp.ListPos.SelfIndex:=pinownerarray;
     pobj:=self.ConstObjArray.beginiterate(ir);
     if pobj<>nil then
     repeat
           pobj^.correctobjects(@self,{ir.itp}ir.itc);
           pobj:=self.ConstObjArray.iterate(ir);
     until pobj=nil;
end;
function GDBObjBlockInsert.GetObjTypeName;
begin
     result:=ObjN_GDBObjBlockInsert;
end;
constructor GDBObjBlockInsert.init;
begin
  inherited init(own,layeraddres,LW);
  POINTER(name):=nil;
  //GDBGetMem(self.varman,sizeof(varmanager));
  bp.ListPos.Owner:=own;
  vp.ID:=GDBBlockInsertID;
  scale:=ScaleOne;
  rotate:=0;
  index:=-1;
  pattrib:=nil;
  pprojoutbound:=nil;
end;
constructor GDBObjBlockInsert.initnul;
begin
  inherited initnul;
  POINTER(name):=nil;
  //GDBGetMem(self.varman,sizeof(varmanager));
  bp.ListPos.Owner:=nil;
  vp.ID:=GDBBlockInsertID;
  scale:=ScaleOne;
  rotate:=0;
  index:=-1;
  GDBPointer(Name):=nil;
  pattrib:=nil;
  //ConstObjArray.init({$IFDEF DEBUGBUILD}'{9DC0AF69-6DBD-479E-91FE-A61F4AC3BE56}',{$ENDIF}100);
  //varman.init('Block_Variable');
  //varman.mergefromfile(programpath+'components\defaultblockvar.ini');
  pprojoutbound:=nil;
end;
function GDBObjBlockInsert.FromDXFPostProcessBeforeAdd;
var //pblockdef:PGDBObjBlockdef;
    //pvisible:PGDBObjEntity;
    //i:GDBInteger;
    //m4:DMatrix4D;
    //TempNet:PGDBObjNet;
    TempDevice:PGDBObjDevice;
    //po:pgdbobjgenericsubentry;
    //    ir:itrec;
    //s,operand:gdbstring;
    isdevice:GDBBoolean;
begin
     isdevice:=false;
     if self.PExtAttrib<>nil then
     if self.PExtAttrib^.Upgrade>0 then
       isdevice:=true;

     index:=gdb.GetCurrentDWG.BlockDefArray.getindex(pansichar(name));
     result:=nil;
     //pblockdef:=gdb.GetCurrentDWG.BlockDefArray.getelement(index);
     (*if pos('EL_WIRE_',uppercase(name))=1 then
     begin
          GDBGetMem({$IFDEF DEBUGBUILD}'{A50F676E-CE01-4795-879F-DC51EE6B1676}',{$ENDIF}GDBPointer(TempNet),sizeof(GDBObjNet));
          result:=tempnet;
          TempNet^.initnul(nil);
          TempNet^.name:=copy(name,9,length(name)-8);
          pvisible:=pblockdef.ObjArray.beginiterate(ir);
          if pvisible<>nil then
          repeat
                pvisible:=pvisible^.Clone(@self);
                pvisible^.bp.Owner:=tempnet;
                pvisible^.format;
                tempnet.ObjArray.add(@pvisible);
                pvisible:=pblockdef.ObjArray.iterate(ir);
          until pvisible=nil;
     end
else*) if (pos('DEVICE_',uppercase(name))=1)or isdevice then
     begin
          if isdevice then
                          name:='DEVICE_'+name;
          GDBGetMem({$IFDEF DEBUGBUILD}'{4C837C43-E018-4307-ADC2-DEB5134AF6D8}',{$ENDIF}GDBPointer(TempDevice),sizeof(GDBObjDevice));
          result:=tempdevice;
          TempDevice^.initnul;
          {pvisible:=pblockdef.ObjArray.beginiterate(ir);
          if pvisible<>nil then
          repeat
                if pvisible^.vp.ID=GDBtextID then
                begin
                     s:=pgdbobjtext(pvisible)^.Content;
                     if length(s)>length(zcadmetric) then
                     if copy(s,1,length(zcadmetric))=zcadmetric then
                        begin
                             s:=copy(s,length(zcadmetric)+1,length(s)-length(zcadmetric));
                             i:=pos('=',s);
                             operand:=copy(s,i+1,length(s)-i);
                             s:=copy(s,1,i-1);
                             if s='TYPE' then
                                             begin
                                                  if operand='CONNECTOR' then
                                                                             TempDevice^.DType:=DT_Connector;
                                             end
                        else if s='GROUP' then
                                             begin
                                                  if operand='EL_DEVICE' then
                                                                             TempDevice^.DGroup:=DG_El_Device;

                                             end
                        else if s='BORDER' then
                                             begin
                                                  if operand='OWNER' then
                                                                             TempDevice^.DBorder:=DB_Owner
                                             else if operand='SELF' then
                                                                             TempDevice^.DBorder:=DB_Self;
                                             end



                        end;



                end;
                pvisible:=pblockdef.ObjArray.iterate(ir);
          until pvisible=nil;}

          TempDevice.vp.Layer:=vp.Layer;
          TempDevice^.Local:=local;
          TempDevice^.scale:=scale;
          TempDevice^.rotate:=rotate;
          TempDevice^.P_insert_in_WCS:=P_insert_in_WCS;
{БЛЯДЬ так делать нельзя!!!!}          if PExtAttrib<>nil then
                                                              begin
                                                              Tempdevice^.PExtAttrib:=CopyExtAttrib;//PExtAttrib;   hjkl
                                                              //PExtAttrib:=nil;
                                                              end;

          //TempDevice^..:=PGDBObjWithLocalCS(@self)^;
          //TempDevice^.bp.Owner:=bp.Owner;
          TempDevice^.name:=copy(name,8,length(name)-7);
          TempDevice^.index:=gdb.GetCurrentDWG.BlockDefArray.getindex(pansichar(copy(name,8,length(name)-7)));
          //bp.Owner^.addmi(@TempDevice);
          //gdb.ObjRoot.ObjArray.add(@TempDevice);
          //TempDevice^.Format;
          //TempDevice^.CreateVarPart;
          //gdb.ObjRoot.ObjArray.add(@TempDevice);
          //po:=pgdbobjgenericsubentry(bp.owner);
          //self.YouDeleted;
          //po^.Format;
     end
end;
function GDBObjBlockInsert.Clone;
var tvo: PGDBObjBlockInsert;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{F9D41F4A-1E80-4D3A-9DD1-D0037EFCA988}',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjBlockInsert));
  tvo^.scale:=scale;
  //tvo^.ObjMatrix:=objmatrix;;
  tvo^.init({bp.owner}own,vp.Layer, vp.LineWeight);
  tvo^.vp.id := GDBBlockInsertID;
  tvo^.vp.layer :=vp.layer;
  GDBPointer(tvo^.name) := nil;
  tvo^.name := name;
  tvo^.pattrib := nil;
  tvo^.Local.p_insert := Local.p_insert;
  tvo^.Local := Local;
  tvo^.scale := scale;
  tvo^.rotate := rotate;
  tvo.index := index;
  tvo^.bp.ListPos.Owner:=own;
  tvo.ConstObjArray.init({$IFDEF DEBUGBUILD}'{E9005274-601F-4A3F-BDB8-E311E59D558C}',{$ENDIF}ConstObjArray.count);
  ConstObjArray.CloneEntityTo(@tvo.ConstObjArray,tvo);
  //tvo^.format;
  result := tvo;
end;
procedure GDBObjBlockInsert.BuildVarGeometry;
var pblockdef:PGDBObjBlockdef;
    //pvisible,pvisible2:PGDBObjEntity;
    //freelayer:PGDBLayerProp;
    //i:GDBInteger;
    //varobject:gdbboolean;
begin
     index:=gdb.GetCurrentDWG.BlockDefArray.getindex(pansichar(name));
     pblockdef:=gdb.GetCurrentDWG.BlockDefArray.getelement(index);
     pblockdef^.ou.copyto(@ou);
end;
procedure GDBObjBlockInsert.BuildGeometry;
var pblockdef:PGDBObjBlockdef;
    pvisible,pvisible2:PGDBObjEntity;
    //freelayer:PGDBLayerProp;
    i:GDBInteger;
    //varobject:gdbboolean;
begin
          if name='' then
                         name:='_error_here';
          index:=gdb.GetCurrentDWG.BlockDefArray.getindex(pansichar(name));
          if index<0 then
                         index:=index;
          assert((index>=0) and (index<gdb.GetCurrentDWG.BlockDefArray.count), 'Неверный индекс блока');

          if not PBlockDefArray(gdb.GetCurrentDWG.BlockDefArray.parray)^[index].Formated then
                                                                               begin
                                                                                PBlockDefArray(gdb.GetCurrentDWG.BlockDefArray.parray)^[index].format;
                                                                               end;
          ConstObjArray.cleareraseobj;

          if getmainowner.gettype=1 then
                                                begin
                                                     i:=i+1;
                                                exit;
                                                end;

          pblockdef:=gdb.GetCurrentDWG.BlockDefArray.getelement(index);
          if pblockdef.ObjArray.count>0 then
          begin

          for i:=0 to pblockdef.ObjArray.count-1 do
          begin
               pvisible:=GDBPointer(pblockdef.ObjArray.getelement(i)^);
               pvisible:=pvisible^.Clone(@self);
               pvisible2:=pgdbobjEntity(pvisible.FromDXFPostProcessBeforeAdd(nil));
               if pvisible2=nil then
                                     begin
                                          pvisible^.correctobjects(@self,{pblockdef.ObjArray.getelement(i)}i);
                                          pvisible^.format;
                                          pvisible.BuildGeometry;
                                          ConstObjArray.add(@pvisible);
                                     end
                                 else
                                     begin
                                          pvisible2^.correctobjects(@self,{pblockdef.ObjArray.getelement(i)}i);
                                          pvisible2^.format;
                                          pvisible.BuildGeometry;
                                          ConstObjArray.add(@pvisible2);
                                     end;
          end;
          ConstObjArray.Shrink;
          end;
          self.BlockDesc:=pblockdef.BlockDesc;
          self.getoutbound;
          inherited;
end;
function GDBObjBlockInsert.getosnappoint;
begin
  if ostype = os_blockinsert then result := Local.p_insert
end;
procedure GDBObjBlockInsert.LoadFromDXF;
var
  s: GDBString;
  byt{, code, i}: GDBInteger;
  hlGDBWord: GDBInteger;
  attrcont: GDBBoolean;
begin
  //initnul;
  attrcont := false;
  byt:=readmystrtoint(f);
  while byt <> 0 do
  begin
     if not LoadFromDXFObjShared(f,byt,ptu) then
     if not dxfvertexload(f,10,byt,Local.P_insert) then
     if not dxfvertexload1(f,41,byt,scale) then
     if not dxfGDBDoubleload(f,50,byt,rotate) then
     if dxfGDBIntegerload(f,71,byt,hlGDBWord)then begin if hlGDBWord = 1 then attrcont := true; end
else if not dxfGDBStringload(f,2,byt,name)then s := f.readgdbstring;
    byt:=readmystrtoint(f);
  end;
  if attrcont then ;
      {begin
        GDBGetMem(PGDBBlockInsert(temp)^.pattrib, attrmemsize);
        PGDBBlockInsert(temp)^.pattrib^.count := 0;
        s := f.readworld(#10, #13);
        repeat
          GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).angle := 0;
          GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).oblique := 0;
          GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).wfactor := 0.65;
          GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).size := 10;
          GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).linespace := 10 * 1.66;
          GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).ptext := nil;
          GDBPointer(GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).content) := nil;
          GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).content := '';
          ux.x := 1;
          ux.y := 0;
          ux.z := 0;
          vv := 0;
          gv := 0;
          doublepoint := false;
          GDBPointer(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].tag) := nil;
          GDBPointer(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].value) := nil;
          GDBPointer(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].prompt) := nil;

          s := f.readworld(#10, #13);
          val(s, byt, code);
          while byt <> 0 do
          begin
            case byt of
              1:
                begin
                  s := f.readworld(#10, #13);
                  PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].value := s;
                end;
              2:
                begin
                  s := f.readworld(#10, #13);
                  PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].tag := s;
                end;

              10:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).p_insert.x, code);
                end;
              20:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).p_insert.y, code);
                end;
              30:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).p_insert.z, code);
                end;
              11:
                begin
                  doublepoint := true;
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).p_draw.x, code);
                end;
              21:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).p_draw.y, code);
                end;
              31:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).p_draw.z, code);
                end;

              40:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).size, code);
                end;
              44:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).linespace, code);
                  GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).linespace :=
                  GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).size * GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).linespace * 5 / 3
                end;
              50:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).angle, code);
                end;
              51:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).oblique, code);
                end;
              72:
                begin
                  s := f.readworld(#10, #13);
                  val(s, gv, code);
                end;
              73:
                begin
                  s := f.readworld(#10, #13);
                  val(s, vv, code);
                end;
              41:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).width, code);
                end;
            else
              s := f.readworld(#10, #13);
            end;
            s := f.readworld(#10, #13);
            val(s, byt, code);
          end;
          if doublepoint then
            GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).p_insert := GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).p_draw;
          GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).justify := jt[vv, gv];
          GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).content := PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].value;
          reformatmtext(@GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt));
          inc(PGDBBlockInsert(temp)^.pattrib^.count);
          s := f.readworld(#10, #13);
        until s = 'SEQEND'
      end;}
      if name='EL_LIGHT_SWIITH' then
                                        name:=name;
      index:=gdb.GetCurrentDWG.BlockDefArray.getindex(pansichar(name));
      //format;
end;
procedure GDBObjBlockInsert.SaveToDXF(var handle: longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);
//var
  //i, j: GDBInteger;
  //hv, vv: GDBByte;
  //s: GDBString;
begin
  SaveToDXFObjPrefix(handle,outhandle,'INSERT','AcDbBlockReference');
  dxfGDBStringout(outhandle,2,name);
  dxfvertexout(outhandle,10,Local.p_insert);
  dxfvertexout1(outhandle,41,scale);
  dxfGDBDoubleout(outhandle,50,rotate);
  SaveToDXFObjPostfix(outhandle);
end;
destructor GDBObjBlockInsert.done;
begin
     name:='';
     inherited done;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBBlockInsert.initialization');{$ENDIF}
end.
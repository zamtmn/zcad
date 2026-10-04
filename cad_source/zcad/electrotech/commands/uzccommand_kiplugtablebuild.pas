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
{$mode delphi}
unit uzcCommand_KIPLugTableBuild;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  LazUTF8,
  gzctnrVectorTypes,uzsbVarmanDef,
  uzeconsts,
  uzcLog,
  Varman,
  uzccablemanager,uzcdialogsfiles,
  uzccommandsabstract,uzccommandsimpl,
  uzgldrawcontext,
  uzcinterface,
  uzeentity,uzcentcable,uzeentdevice,uzeEntTable,
  uzcEnitiesVariablesExtender,
  uzcbillofmaterial,
  uzcdrawings,uzbPaths,uzcTranslations,uzccmdfloatinsert,UGDBSelectedObjArray,uzeblockdef,
  uzeGeometryTypes,uzeGeometry,uzccomdraw,uzcstrconsts;

implementation

type
  KIP_LugTableBuild_com=object(FloatInsert_com)
    procedure Command(Operands:TCommandOperands);virtual;
  end;

var
  KIP_LugTableBuild:KIP_LugTableBuild_com;

procedure KIP_LugTableBuild_com.Command(Operands:TCommandOperands);
var
  psd:PSelectedObjDesc;
  ir:itrec;
  pnevdev:PGDBObjDevice;
  PBH:PGDBObjBlockdef;
  currentcoord:TzePoint3d;
  t_matrix:TzeTypedMatrix4d;
  pobj,pcobj:PGDBObjEntity;
  ir2:itrec;
  pvd:pvardesk;
  dn:tdevname;
  dna:devnamearray;
  i:integer;
  DC:TDrawContext;
  entvarext,delvarext:TVariablesExtender;
  extensionssave:pointer;
begin
  currentcoord:=cP3d__0__0__0;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'KIP_LUGTABLEELEMENT');
  PBH:=drawings.GetCurrentDWG^.BlockDefArray.getblockdef('KIP_LUGTABLEELEMENT');
  if pbh=nil then
    exit;
  if not PBH.Formated then
    PBH.FormatEntity(drawings.GetCurrentDWG^,dc);
  dna:=devnamearray.Create;
  psd:=drawings.GetCurrentDWG^.SelObjArray.beginiterate(ir);
  if psd<>nil then
    repeat
      if psd^.objaddr^.GetObjType=GDBDeviceID then begin
        entvarext:=psd^.objaddr^.GetExtension<TVariablesExtender>;
        pvd:=entvarext.entityunit.FindVariable('NMO_Name');
        if pvd<>nil then
          dn.Name:=pvd.Data.PTD.GetValueAsString(pvd.Data.Addr.Instance)
        else
          dn.Name:='';
        dn.pdev:=pointer(psd^.objaddr);
        dna.PushBack(dn);
      end;
      psd:=drawings.GetCurrentDWG^.SelObjArray.iterate(ir);
    until psd=nil;

  if dna.Size=0 then begin
    zcUI.TextMessage(rscmSelDevsBeforeComm,TMWOHistoryOut);
  end else begin
    devnamesort.Sort(dna,dna.Size);
    t_matrix:=uzegeometry.CreateTranslationMatrix(TzeVector3d.Make(50,12,0));


    for i:=0 to dna.Size-1 do begin
      dn:=dna[i];

      extensionssave:=dn.pdev^.EntExtensions;
      dn.pdev^.EntExtensions:=nil;
      pointer(pnevdev):=dn.pdev^.Clone(@drawings.GetCurrentDWG.ConstructObjRoot);
      dn.pdev^.EntExtensions:=extensionssave;

      entvarext:=dn.pdev^.GetExtension<TVariablesExtender>;
      entvarext:=entvarext.getMainFuncVariablesExtender;
      pnevdev^.AddExtension(TVariablesExtender.Create(pnevdev));
      delvarext:=pnevdev^.GetExtension<TVariablesExtender>;
      entvarext.addDelegate(pnevdev,delvarext);


      pnevdev.Local.P_insert:=currentcoord;
      pnevdev.Local.Basis.oz:=cV3d__0__0__1;
      pnevdev.Local.Basis.ox:=cV3d__1__0__0;
      pnevdev.Local.Basis.oy:=cV3d__0__1__0;
      pnevdev.rotate:=0;
      pnevdev^.formatEntity(drawings.GetCurrentDWG^,dc);
      pobj:=PBH.ObjArray.beginiterate(ir2);
      if pobj<>nil then
        repeat
          pcobj:=pobj.Clone(pnevdev);
          pcobj.transformat(pobj,@t_matrix);
          if pcobj^.IsHaveLCS then
            pcobj^.FormatEntity(drawings.GetCurrentDWG^,dc);
          pcobj^.FormatEntity(drawings.GetCurrentDWG^,dc);
          pnevdev^.VarObjArray.AddPEntity(pcobj^);
          pobj:=PBH.ObjArray.iterate(ir2);
        until pobj=nil;
      pnevdev^.formatEntity(drawings.GetCurrentDWG^,dc);
      drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.AddPEntity(pnevdev^);
      currentcoord.y:=currentcoord.y-24;
    end;
  end;
  dna.Destroy;
end;


initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  KIP_LugTableBuild.init('KIP_LugTableBuild',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

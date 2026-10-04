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
unit uzcCommand_KIPCDBuild;

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
  uzeGeometryTypes,uzeGeometry,uzccomdraw,uzcstrconsts,UUnitManager;

implementation

type
  KIP_CDBuild_com=object(FloatInsert_com)
    procedure Command(Operands:TCommandOperands);virtual;
  end;

var
  KIP_CDBuild:KIP_CDBuild_com;

procedure KIP_CDBuild_com.Command(Operands:TCommandOperands);
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
  pu:PTSimpleUnit;
begin
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;

  //добавляем определение блока HEAD_CONNECTIONDIAGRAM в чечтеж если надо
  drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'HEAD_CONNECTIONDIAGRAM');

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
      if psd^.objaddr^.GetObjType=GDBDeviceID then begin
        entvarext:=psd^.objaddr^.GetExtension<TVariablesExtender>;
        //pvd:=PTEntityUnit(psd^.objaddr^.ou.Instance)^.FindVariable('DESC_MountingSite');
        pvd:=entvarext.entityunit.FindVariable({'DESC_MountingSite'}'NMO_Name');
        if pvd<>nil then
          dn.Name:=pvd.Data.PTD.GetValueAsString(pvd.Data.Addr.Instance)
        else
          dn.Name:='';
        dn.pdev:=pointer(psd^.objaddr);
        dna.PushBack(dn);
      end;
      psd:=drawings.GetCurrentDWG^.SelObjArray.iterate(ir);
    until psd=nil;

  if dna.Size=0 then
    //ругаемся если устройств в выделениии не оказалось
    zcUI.TextMessage(rscmSelDevsBeforeComm,TMWOHistoryOut)
  else begin
    //устройства в выделениии присутствуют, сортируем по именам
    //это нужно только чтоб вставить рыбу в упорядоченной по именам последовательности
    devnamesort.Sort(dna,dna.Size);
    //создаем матрицу для перемещения по оси У на +15
    t_matrix:=uzegeometry.CreateTranslationMatrix(TzeVector3d.Make(0,15,0));
    //ищем модуль с переменными дефолтными переменными для представителя устройства
    pu:=units.findunit(GetSupportPaths,InterfaceTranslate,'uentrepresentation');
    //эта команда работает после указания пользователем точки вставки
    //смещение первого вставляемого элемента nulvertex
    currentcoord:=cP3d__0__0__0;
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

      //получаем переменные
      entvarext:=dn.pdev^.GetExtension<TVariablesExtender>;
      //но нам нужна толко главная функция
      entvarext:=entvarext.getMainFuncVariablesExtender;
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
      pnevdev.Local.Basis.oz:=cV3d__0__0__1;
      pnevdev.Local.Basis.ox:=cV3d__1__0__0;
      pnevdev.Local.Basis.oy:=cV3d__0__1__0;
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


initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  KIP_CDBuild.init('KIP_CDBuild',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

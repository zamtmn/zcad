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
@author(Vladimir Bobrov)
}

unit uzvcabmountmethod;
{$INCLUDE zengineconfig.inc}
interface
uses
     uzceltechtreeprop,//определение класса менеджера "стринговых деревьев"
     uzbpaths,//работа с путями
     uzctranslations,//работа с локализацией
     uzcefstringstreeselector,//окно выбора в дереве
     uzcsysparams,
     uzctypesdecorations,zcobjectinspectorui,//uzcoidecorations,//для "быстрых" редакторов
     UUnitManager,
     sysutils,
     Forms,Controls,

     uzccommandsimpl,    //тут реализация объекта CommandRTEdObject
     uzccommandsabstract,//базовые объявления для команд
            //базовые типы
     uzccommandsmanager, //менеджер команд

     uzvcom,             //
     uzvnum,
     uzvtreedevice,      //новая механизм кабеле прокладки на основе Дерева
     //uzvtmasterdev,
     uzvagensl,
     uzvtestdraw, // тестовые рисунки

     uzcinterface,
     //uzctnrvectorString,
     //uzegeometrytypes,
     uzegeometry,
     uzcuitypes,
     uzbtypes,
     typinfo,
     //gzctnrVector,
     //uzvconsts,
     //uzcutils,
     Varman;             //Зкадовский RTTI

var
 MountingMethodsTree:TTreePropManager;//экзкмпляр с деревом  способов прокладки
 MountingMethodsTreeSelector:TStringsTreeSelector=nil;//экзкмпляр с окном выбора в дереве  способов прокладки

implementation

function MountingMethodsTest_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  MountingMethodsTreeSelector:=TStringsTreeSelector.Create(nil);//создаем форму
  MountingMethodsTreeSelector.fill(MountingMethodsTree.BlobTree);//заполняем дерево
  MountingMethodsTreeSelector.ShowModal;//показываем форму модально
  freeandnil(MountingMethodsTreeSelector);//уничтожаем форму
  result:=cmd_ok;//все окей
end;

procedure RunMountingMethodsFastEditor(PInstance:Pointer);
var
   modalresult:integer;
begin
     if not assigned(MountingMethodsTreeSelector) then //если не создана
     begin
       MountingMethodsTreeSelector:=TStringsTreeSelector.create(application.MainForm);//создаем форму
       //восстанавливаем размеры формы
       MountingMethodsTreeSelector.BoundsRect:=GetBoundsFromSavedUnit('MountingMethodsTreeSelectorWND',SysParam.notsaved.ScreenX,SysParam.notsaved.Screeny);
     end;
     MountingMethodsTreeSelector.clear;//очищаем
     MountingMethodsTreeSelector.fill(MountingMethodsTree.BlobTree);//заполняем
     MountingMethodsTreeSelector.setValue(PStringTreeType(PInstance)^);//присваивсем  начальное значение ближайшее к данному
     MountingMethodsTreeSelector.caption:=('MountingMethodsFastEditor');//называем окно
     MountingMethodsTreeSelector.ActiveControl:=MountingMethodsTreeSelector.StringsTree;//назначаем  активный  контрол
     modalresult:=ZCMsgCallBackInterface.DOShowModal(MountingMethodsTreeSelector);//показываем форму модально
     if modalresult=ZCMrOk then//если нажали окей
       PStringTreeType(PInstance)^:=MountingMethodsTreeSelector.TreeResult; //сохраняем выбранное значение
     StoreBoundsToSavedUnit('MountingMethodsTreeSelectorWND',MountingMethodsTreeSelector.BoundsRect);//сохраняем размеры формы
     freeandnil(MountingMethodsTreeSelector);//уничтожаем форму
end;


initialization
  MountingMethodsTree:=TTreePropManager.Create('~','MountingMethodsRoot');//создаем экземпляр, указываем разделитель и имя корневого узла
  MountingMethodsTree.LoadTree(expandpath('*rtl/velec/mountingmethodss.xml'),InterfaceTranslate);//грузим файл передаем путь  и переводчика
  CreateZCADCommand(@MountingMethodsTest_com,'mt',CADWG,0);//тестовая команда, вызывает окно с твоим деревом


  AddFastEditorToType(units.findunit(GetSupportPath,InterfaceTranslate,'cables').TypeName2PTD('TDCableMountingMethod'),//привязка быстрого редактора, я вяжу к String, ты поставишь свой тип
                      @OIUI_FE_ButtonGetPrefferedSize,//процедура определяющая размер кнопки в инспекторе
                      @OIUI_FE_ButtonMultiplyDraw,//процедура рисующая кнопку в инспекторе
                      @RunMountingMethodsFastEditor);//запуск  редактора  и  возврат  значения

finalization
  MountingMethodsTree.Destroy;

end.

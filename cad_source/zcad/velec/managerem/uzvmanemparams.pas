unit uzvmanemparams;
interface
uses
  uzctnrVectorStrings;
type
  PTuzvmanemComParams=^TuzvmanemComParams;//указатель на тип данных параметров команды. зкад работает с ними через указатель

  //TsettingDebugging=record
  //  //sErrors:Boolean;
  //  vizGraphEM:Boolean;        // Визуализировать граф
  //  beforeGraphEMSort:Boolean; // Перед отрисовкой графа, отсортировать его так как будет строиться схема
  //  //vizEasyTreeCab:Boolean; //визуализировать упрощенное дерево
  //end;

  TsettingRepeatEMShema=record
    vizStructureGraphEM:Boolean;        // Визуализировать граф
    beforeGraphEMSort:Boolean;          // Перед отрисовкой графа, отсортировать его так как будет строиться схема
  end;

  TuzvmanemComParams=record       //определяем параметры команды которые будут видны в инспекторе во время выполнения команды
                                        //регистрировать их будем паскалевским RTTI
                                        //не через экспорт исходников и парсинг файла с определениями типов
    NamesList:TEnumData;//это тип для отображения списков в инспекторе
    //nameSL:String;
    accuracy:Double;
    metricDev:Boolean;
    sortGraph:Boolean;  //отсортировать граф как удобно для отрисовки. возможно потому будут условия

    settingRepeatEMShema:TsettingRepeatEMShema;

  end;
var
  uzvmanemComParams:TuzvmanemComParams;//определяем экземпляр параметров нашей команды
implementation
end.

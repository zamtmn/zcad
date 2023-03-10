unit uzvmanemshieldsgroupparams;
interface
uses
  uzctnrVectorStrings;
type
  TuzvmanemSGSetConstruct=(
        TSC_Short(*'Кратко'*),
        TSC_Medium(*'Упрощенно'*),
        TSC_Full(*'Полно'*)
       );

  TuzvmanemSGSetProtectDev=(
        TPD_AV(*'Автом.выкл.'*),
        TPD_DF(*'Дифф.'*),
        TPD_UZO(*'УЗО'*)
       );

  TuzvmanemSG=record
    uzvmanemSGSetConstruct:TuzvmanemSGSetConstruct;        // Визуализировать граф
    uzvmanemSGSetProtectDev:TuzvmanemSGSetProtectDev;      // Перед отрисовкой графа, отсортировать его так как будет строиться схема
  end;

  TuzvmanemSGparams=record      //определяем параметры команды которые будут видны в инспекторе во время выполнения команды
    nameShield:String;          //Имя щита
    uzvmanemSG1:TuzvmanemSG;
    uzvmanemSG2:TuzvmanemSG;
    uzvmanemSG3:TuzvmanemSG;
    uzvmanemSG4:TuzvmanemSG;
    uzvmanemSG5:TuzvmanemSG;
    uzvmanemSG6:TuzvmanemSG;
    uzvmanemSG7:TuzvmanemSG;
    uzvmanemSG8:TuzvmanemSG;
    uzvmanemSG9:TuzvmanemSG;
    uzvmanemSG10:TuzvmanemSG;
    uzvmanemSG11:TuzvmanemSG;
    uzvmanemSG12:TuzvmanemSG;
    uzvmanemSG13:TuzvmanemSG;
    uzvmanemSG14:TuzvmanemSG;
    uzvmanemSG15:TuzvmanemSG;
    uzvmanemSG16:TuzvmanemSG;
    uzvmanemSG17:TuzvmanemSG;
    uzvmanemSG18:TuzvmanemSG;
    uzvmanemSG19:TuzvmanemSG;
    uzvmanemSG20:TuzvmanemSG;
  end;
var
  uzvmanemSGparams:TuzvmanemSGparams;//определяем экземпляр параметров нашей команды
implementation
end.

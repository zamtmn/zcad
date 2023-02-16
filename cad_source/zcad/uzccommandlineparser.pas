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

unit uzcCommandLineParser;
{$INCLUDE zengineconfig.inc}
{$mode objfpc}{$H+}

interface

uses
  uzbCommandLineParser;

var
  CommandLineParser:TCommandLineParser;

  NOSPLASHHDL,              //опция nosplash - не показывать сплэш
  UPDATEPOHDL,              //опция updatepo - актуализация файлов локализации, необходима для команды updatepo
  NOLOADLAYOUTHDL,          //опция noloadlayout - запуск без загрузки начального состояния раскладки окон
  LOGFILEHDL,               //опция logfile - указание лог файла, требует аргумент(ы) имя файла
  NOTCHECKUNIQUEINSTANCEHDL,//опция noloadlayout - запуск без загрузки начального состояния раскладки окон
  LEAMHDL,                  //опция leam -(Log Enable All Modules) разрешение записи в лог всех модулей
  LEMHDL,                   //опция lem -(Log Enable Module) разрешение записи в лог определенного модуля, требует аргумент(ы)
  LDMHDL,                   //опция ldm -(Log Disable Module) запрещение записи в лог определенного модуля, требует аргумент(ы)
  LEMMHDL,                  //опция lemm -(Log Enable Modules Mask) разрешение записи в лог модулей с именем удовлетворяющим маске, требует аргумент(ы)
  LDMMHDL,                  //опция ldmm -(Log Disable Modules Mask) запрещение записи в лог модулей с именем удовлетворяющим маске, требует аргумент(ы)
  LCLHDL,                   //опция lcl -(Log Current Level) установка текущего уровня лога, требует аргумент
  MaxStackFrameCountHDL,    //опция MaxStackFrameCount - максимальная глубина стека для обработчика исключений
  RunScript                //опция runscript - запуск скрипта при старте программы, требует аргумент(ы)
  :TCLOptionHandle;

implementation

initialization
  CommandLineParser.Init;
  NOSPLASHHDL:=CommandLineParser.RegisterArgument('nosplash',AT_Flag);
  UPDATEPOHDL:=CommandLineParser.RegisterArgument('updatepo',AT_Flag);
  NOLOADLAYOUTHDL:=CommandLineParser.RegisterArgument('noloadlayout',AT_Flag);
  LOGFILEHDL:=CommandLineParser.RegisterArgument('logfile',AT_WithOperands);
  NOTCHECKUNIQUEINSTANCEHDL:=CommandLineParser.RegisterArgument('notcheckuniqueinstance',AT_Flag);
  LEAMHDL:=CommandLineParser.RegisterArgument('leam',AT_Flag);
  LEMHDL:=CommandLineParser.RegisterArgument('lem',AT_WithOperands);
  LDMHDL:=CommandLineParser.RegisterArgument('ldm',AT_WithOperands);
  LEMMHDL:=CommandLineParser.RegisterArgument('lemm',AT_WithOperands);
  LDMMHDL:=CommandLineParser.RegisterArgument('ldmm',AT_WithOperands);
  LCLHDL:=CommandLineParser.RegisterArgument('lcl',AT_WithOperands);
  MaxStackFrameCountHDL:=CommandLineParser.RegisterArgument('maxstackframecount',AT_WithOperands);
  RunScript:=CommandLineParser.RegisterArgument('runscript',AT_WithOperands);
  CommandLineParser.ParseCommandLine;
finalization
  CommandLineParser.Done;
end.


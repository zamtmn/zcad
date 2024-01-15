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
@author(Vladimir Bobrov)
}
{$mode objfpc}{$H+}

unit uzvstripmtext;
{$INCLUDE zengineconfig.inc}

interface
uses

  sysutils,

  uzeentmtext,
  uzbtypes,
  uzeconsts, //base constants
             //описания базовых констант
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                   //менеджер команд и объекты связанные с ним
  uzcdrawings,     //Drawings manager, all open drawings are processed him
  //uzccombase,
  uzccommand_regen,
  gzctnrVectorTypes,
  uzcinterface,
  RegExpr;


implementation

//**Очистка текста на чертеже
function stripMtext_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var

  pobj: PGDBObjMText;
  pmtext:PGDBObjMText;
  ir:itrec;
  newText:ansistring;

  UCoperands:string;
  function clearText(a:TDXFEntsInternalStringType):ansistring;
    var
      re: TRegExpr;
    begin
       clearText:=AnsiString(a);
       re := TRegExpr.Create;

       re.Expression := '(\\\\)';
       clearText:= re.Replace(clearText, '#levoeNaklonnayCherta#', false);

       re.Expression := '(\\P)';
       clearText:= re.Replace(clearText, '#nachaloNovoyStroki#', false);

       re.Expression := '(\\{)';
       clearText:= re.Replace(clearText, '#figurSkobkaOtkr#', false);

       re.Expression := '(\\})';
       clearText:= re.Replace(clearText, '#figurSkobkaZakr#', false);

       re.Expression := '\\[^\\]*?;';
       clearText:= re.Replace(clearText, '', false);

       re.Expression := '[\\][\\]';
       clearText:= re.Replace(clearText, '\', false);

       re.Expression := '[{}]';
       clearText:= re.Replace(clearText, '', false);

       re.Expression := '(\\([lL]|[oO]))';
       clearText:= re.Replace(clearText, '', false);

       re.Expression := '(#figurSkobkaOtkr#)';
       clearText:= re.Replace(clearText, '\{', false);

       re.Expression := '(#figurSkobkaZakr#)';
       clearText:= re.Replace(clearText, '\}', false);

       re.Expression := '(#nachaloNovoyStroki#)';
       clearText:= re.Replace(clearText, '\P', false);

       re.Expression := '(#levoeNaklonnayCherta#)';
       clearText:= re.Replace(clearText, '\\', false);

       re.free;
    end;
begin

  UCoperands:=uppercase(operands);
   if UCoperands='ALL' then
   begin
   pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //выбрать первый элемент чертежа
     if pobj<>nil then
     repeat                                                   //перебор всех элементов чертежа
           if pobj^.GetObjType=GDBMTextID then                //работа только с кабелями
           begin
            pmtext:=PGDBObjMText(pobj);
            //ZCMsgCallBackInterface.TextMessage('Do : ' + pmtext^.Template,TMWOHistoryOut);
            newText:=clearText(pmtext^.Template);
            //ZCMsgCallBackInterface.TextMessage('After : ' + newText,TMWOHistoryOut);
            pmtext^.Template:=TDXFEntsInternalStringType(newText);
            pmtext^.Content:=TDXFEntsInternalStringType(newText);
           end;
    pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
    until pobj=nil;
   end
   else
   begin
     pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //выбрать первый элемент чертежа
     if pobj<>nil then
     repeat                                                   //перебор всех элементов чертежа
       if pobj^.GetObjType=GDBMTextID then                //работа только с кабелями
         if pobj^.selected then
           begin
              //pobj^.DeSelect(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,@drawings.CurrentDWG^.deselector);
              pmtext:=PGDBObjMText(pobj);
              newText:=clearText(pmtext^.Template);

              pmtext^.Template:=TDXFEntsInternalStringType(newText);
              pmtext^.Content:=TDXFEntsInternalStringType(newText);
           end;
    pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
    until pobj=nil;

    end;
    Regen_com(Context,EmptyCommandOperands);   //выполнитть регенирацию всего листа
    result:=cmd_ok;
end;

initialization
  CreateZCADCommand(@stripMtext_com,'stripmtext',CADWG,0);
end.


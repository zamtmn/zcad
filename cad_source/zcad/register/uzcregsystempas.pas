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

unit uzcregsystempas;
{$INCLUDE def.inc}
interface
uses uzbpaths,UUnitManager,uzcsysvars,{$IFNDEF DELPHI}uzctranslations,{$ENDIF}
     uzbstrproc,Varman,languade,SysUtils,
     UBaseTypeDescriptor,uzbtypes,UGDBOpenArrayOfByte, strmy, varmandef,
     uzcsysparams,uzcsysinfo,TypeDescriptors,URecordDescriptor,
     uzclog,uzbmemman,LazLogger;
implementation
{$IFNDEF WINDOWS}
var
  ptd:PUserTypeDescriptor;
{$ENDIF}
initialization;
     programlog.logoutstr('uzcregsystempas.initialization',lp_IncPos,LM_Debug);
     if SysUnit=nil then
       begin
         units.loadunit(SupportPath,InterfaceTranslate,expandpath('*rtl/system.pas'),nil);
         SysUnit:=units.findunit(SupportPath,InterfaceTranslate,'System');
       end;
     programlog.logoutstr('end; {uzcregsystempas.initialization}',lp_DecPos,LM_Debug);
finalization;
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization')
end.

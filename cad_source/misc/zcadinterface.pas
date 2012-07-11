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
unit zcadinterface;
{$INCLUDE def.inc}
interface
uses varmandef,forms,classes;
type
    //Abstract
    TSimpleProcedure=Procedure;
    TProcedure_Pointer_=Procedure(p:pointer);
    TProcedure_Integer_=Procedure(a:integer);
    TFunction__Integer=Function:integer;
    TFunction__Boolean=Function:boolean;
    TFunction__Pointer=Function:Pointer;
    TFunction__TForm=Function:TForm;
    TFunction__TComponent=Function:TComponent;

    //SplashWnd
    TSplashTextOutProc=procedure (s:string;pm:boolean);

    //ObjInsp
    TSetGDBObjInsp=procedure(exttype:PUserTypeDescriptor; addr:Pointer);
    TStoreAndSetGDBObjInsp=procedure(exttype:PUserTypeDescriptor; addr:Pointer);
var
   //SplashWnd
   SplashTextOut:TSplashTextOutProc;

   //Objinsp
   SetGDBObjInspProc:TSetGDBObjInsp;
   StoreAndSetGDBObjInspProc:TStoreAndSetGDBObjInsp;
   ReStoreGDBObjInspProc:TFunction__Boolean;
   UpdateObjInspProc:TSimpleProcedure;
   ReturnToDefaultProc:TSimpleProcedure;
   ClrarIfItIsProc:TProcedure_Pointer_;
   ReBuildProc:TSimpleProcedure;
   SetCurrentObjDefaultProc:TSimpleProcedure;
   GetCurrentObjProc:TFunction__Pointer;
   SetNameColWidthProc:TProcedure_Integer_;
   GetNameColWidthProc:TFunction__Integer;
   CreateObjInspInstanceProc:TFunction__TForm;
   GetPeditorProc:TFunction__TComponent;
   FreEditorProc:TSimpleProcedure;
implementation
end.

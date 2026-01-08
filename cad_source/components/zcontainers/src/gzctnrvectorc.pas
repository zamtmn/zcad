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
@author(Andrey Zubarev <zamtmn@yandex.ru>)
}
{**Модуль описания базового генерика обьекта-массива}
unit gzctnrVectorc;

{DEFINE FILL0ALLOCATEDMEMORY}
interface
uses gzctnrVectorTypes,sysutils,typinfo;
const
  {**типы нуждающиеся в инициализации}
  TypesNeedToFinalize=[tkUnknown{$IFNDEF DELPHI},tkSString{$ENDIF},tkLString{$IFNDEF DELPHI},tkAString{$ENDIF},
                       tkWString,tkVariant,tkRecord,tkInterface,
                       tkClass{$IFNDEF DELPHI},tkObject{$ENDIF},tkDynArray{$IFNDEF DELPHI},tkInterfaceRaw{$ENDIF},
                       tkUString{$IFNDEF DELPHI},tkUChar{$ENDIF}{$IFNDEF DELPHI},tkHelper{$ENDIF}{$IFNDEF DELPHI},tkFile{$ENDIF},tkClassRef];
  {**типы нуждающиеся в финализации}
  TypesNeedToInicialize=[tkUnknown{$IFNDEF DELPHI},tkSString{$ENDIF},tkLString{$IFNDEF DELPHI},tkAString{$ENDIF},
                         tkWString,tkVariant,tkRecord,tkInterface,
                         tkClass{$IFNDEF DELPHI},tkObject{$ENDIF},tkDynArray{$IFNDEF DELPHI},tkInterfaceRaw{$ENDIF},
                         tkUString{$IFNDEF DELPHI},tkUChar{$ENDIF}{$IFNDEF DELPHI},tkHelper{$ENDIF}{$IFNDEF DELPHI},tkFile{$ENDIF},tkClassRef];
type
TZAbsVectorClass=class
end;

{**Генерик объекта-массива}
GZVectorc<T>=class(TZAbsVectorClass)//(TZAbsVector)
    type
        TDataType=T;                               //**< Тип данных T
        PT=^T;                                     //**< Тип указатель на тип данных T
        TArr=array[0..0] of T;                     //**< Тип массив данных T
        PTArr=^TArr;                               //**< Тип указатель на массив данных T
        TEqualFunc=function(const a, b: T):Boolean;//**< Тип функция идентичности T
        TProcessProc=procedure(const p: PT);       //**< Тип процедура принимающая указатель на T
    var
        PArray:PTArr;(*hidden_in_objinsp*)   //**< Указатель на массив данных
        Count:TArrayIndex;(*hidden_in_objinsp*)               //**< Количество занятых элементов массива
        Max:TArrayIndex;(*hidden_in_objinsp*)                 //**< Размер массива (под сколько элементов выделено памяти)
     public
        {**Деструктор}
        destructor Destroy;override;
        {**Конструктор}
        constructor Create(m:TArrayIndex);overload;
        {**Конструктор}
        constructor Create;

        {**Удаление всех элементов массива}
        //procedure free;virtual;

        {**Начало "перебора" элементов массива
          @param(ir переменная "итератор")
          @return(указатель на первый элемент массива)}
        function beginiterate(out ir:itrec):Pointer;virtual;
        {**"Перебор" элементов массива
          @param(ir переменная "итератор")
          @return(указатель на следующий элемент массива, nil если это конец)}
        function iterate(var ir:itrec):Pointer;virtual;

        function SetCount(index:Integer):Pointer;virtual;
        {**Инвертировать массив}
        procedure Invert;
        {**Копировать в массив}
        function copyto(var dest:GZVectorc<T>):Integer;virtual;
        {**Выделяет место и копирует в массив SData элементов из PData. Надо compilermagic! соответствие с AllocData
          @PData(указатель на копируемые элементы)
          @SData(кол-во копируемых элементов)
          @return(индекс первого скопированного элемента в массиве)}
        function AddData(PData:Pointer;SData:Word):Integer;virtual;
        {**Выделяет место в массиве под SData элементов. Надо compilermagic! соответствие с AddData
          @SData(кол-во копируемых элементов)
          @return(индекс первого выделенного элемента в массиве)}
        function AllocData(SData:Word):Integer;virtual;


        {old}
        {**Удалить элемент по индексу, без уменьшениием размера массива, элемент затирается значением default(T)}
        function DeleteElement(index:Integer):Pointer;
        //TODO:исправить пиздеж
        {**Пиздеж!!! уменьшается!!! Удалить элемент по индексу, с уменьшениием размера массива}
        function EraseElement(index:Integer):Pointer;
        {**Перевод указателя в индекс}
        function P2I(pel:Pointer):Integer;
        {**Удалить элемент по указателю}
        function DeleteElementByP(pel:Pointer):Pointer;
        {**вставить элемент}
        function InsertElement(index:Integer;const data:T):Pointer;

        {need compilermagic}
        procedure Grow(newmax:Integer=0);virtual;
        {**Выделяет память под массив}
        function CreateArray:Pointer;virtual;

        {reworked}
        {**Устанавливает длину массива}
        procedure SetSize(nsize:TArrayIndex);
        {**Возвращает указатель на значение по индексу}
        function getPData(index:TArrayIndex):Pointer;virtual;
        {**Возвращает указатель на значение по индексу}
        function getDataMutable(index:TArrayIndex):PT;
        {**Возвращает значение по индексу}
        function getData(index:TArrayIndex):T;
        {**Возвращает последнее значение}
        function getLast:T;
        {**Добавить в конец массива значение, возвращает индекс добавленного значения}
        function PushBackData(const data:T):TArrayIndex;
        {**Добавить в конец массива значение если его еще нет в массиве, возвращает индекс найденного или добавленного значения}
        function PushBackIfNotPresentWithCompareProc(data:T;EqualFunc:TEqualFunc):Integer;
        {**Добавить в конец массива значение если оно еще не в конце массива, возвращает индекс найденного или добавленного значения}
        function PushBackIfNotLastWithCompareProc(data:T;EqualFunc:TEqualFunc):Integer;
        {**Добавить в конец массива значение если оно еще не в конце массива или не в начале масива, возвращает индекс найденного или добавленного значения}
        function PushBackIfNotLastOrFirstWithCompareProc(data:T;EqualFunc:TEqualFunc):Integer;
        {**Проверка нахождения в массиве значения с функцией сравнения}
        function IsDataExistWithCompareProc(pobj:T;EqualFunc:TEqualFunc):Integer;
        {**Пустой ли массив?}
        function IsEmpty:Boolean;
        {**Возвращает тип элемента массива}
        function GetSpecializedTypeInfo:PTypeInfo;inline;

        {**Возвращает размер элемента массива}
        function SizeOfData:TArrayIndex;
        {**Возвращает указатель на массив}
        function GetParray:pointer;virtual;
        {**Возвращает указатель на массив}
        function GetParrayAsPointer:pointer;
        {**Очищает массив не убивая элементы, просто count:=0}
        procedure Clear;virtual;
        {**Возвращает реальное колво элементов, в данном случае=count}
        function GetRealCount:Integer;
        {**Возвращает колво элементов}
        function GetCount:Integer;
        {**Подрезать выделенную память по count}
        procedure Shrink;virtual;

        procedure freewithproc(freeproc:TProcessProc);virtual;
  end;

function remapmememblock(pblock:Pointer;sizeblock:Integer):Pointer;
function enlargememblock(pblock:Pointer;oldsize,nevsize:Integer):Pointer;

implementation

function remapmememblock(pblock:Pointer;sizeblock:Integer):Pointer;
var
  newblock:Pointer;
begin
  newblock:=nil;
  GetMem(newblock, sizeblock);
  Move(pblock^, newblock^, sizeblock);
  result := newblock;
  FreeMem(pblock);
end;
function enlargememblock(pblock:Pointer;oldsize,nevsize:Integer):Pointer;
var
  newblock:Pointer;
begin
  newblock:=nil;
  GetMem(newblock, nevsize);
  if pblock<>nil then
    Move(pblock^, newblock^, oldsize);
  result := newblock;
  FreeMem(pblock);
end;

function GZVectorc<T>.GetSpecializedTypeInfo:PTypeInfo;
begin
  result:=TypeInfo(T);
end;
function GZVectorc<T>.getPData(index:TArrayIndex):Pointer;
begin
  result:=getDataMutable(index);
end;
function GZVectorc<T>.getDataMutable;
begin
     if (index>=max)
        or(index<0)then
                     result:=nil
else if PArray=nil then
                     result:=nil
                   else
                     result:=@parray[index];
end;
function GZVectorc<T>.getData;
begin
     if (index>=max)
        or(index<0)then
                     result:=default(T)
else if PArray=nil then
                     result:=default(T)
                   else
                     result:=parray[index];
end;
function GZVectorc<T>.getLast;
begin
  Result:=getData(count-1);
end;

function GZVectorc<T>.PushBackData(const data:T):TArrayIndex;
begin
  if parray=nil then
                     CreateArray;
  if count = max then
                     grow;
  begin
       if PTypeInfo(TypeInfo(T))^.kind in TypesNeedToInicialize
          then fillchar(parray[count],sizeof(T),0);
       parray[count]:=data;
       result:=count;
       inc(count);
  end;
end;
function GZVectorc<T>.GetParray:pointer;
begin
  result:=GetParrayAsPointer;
end;
function GZVectorc<T>.GetParrayAsPointer;
begin
  result:=pointer(parray);
end;

function GZVectorc<T>.IsDataExistWithCompareProc;
var i:integer;
begin
     for i:=0 to count-1 do
     if EqualFunc(parray[i],pobj) then
                           begin
                                result:=i;
                                exit;
                           end;
     result:=-1;
end;
function GZVectorc<T>.PushBackIfNotLastWithCompareProc(data:T;EqualFunc:TEqualFunc):Integer;
begin
  if count>0 then
  begin
    if not EqualFunc(parray[count-1],data) then
      result:=PushBackData(data)
    else
      result:=count-1;
  end
  else
    result:=PushBackData(data);
end;
function GZVectorc<T>.PushBackIfNotLastOrFirstWithCompareProc(data:T;EqualFunc:TEqualFunc):Integer;
begin
  if count>0 then
  begin
    if not EqualFunc(parray[count-1],data) then
    begin
      if not EqualFunc(parray[0],data) then
        result:=PushBackData(data)
      else
        result:=0;
    end
    else
      result:=count-1;
  end
  else
    result:=PushBackData(data);
end;
function GZVectorc<T>.PushBackIfNotPresentWithCompareProc;
begin
  result:=IsDataExistWithCompareProc(data,EqualFunc);
  if result=-1 then
                   result:=PushBackData(data);
  {if IsDataExistWithCompareProc(data,EqualFunc)>=0 then
                                                   begin
                                                        result := -1;
                                                        exit;
                                                   end;
  result:=PushBackData(data);}
end;
function GZVectorc<T>.AllocData(SData:Word):Integer;
begin
  if parray=nil then
                    createarray;
  if count+sdata>max then
                         Grow((count+sdata)*2);
  result:={@parray^[}count{]};
  //result:=pointer(PtrUInt(parray)+count*SizeOfData);
  {$IFDEF FILL0ALLOCATEDMEMORY}
  fillchar(result^,sdata,0);
  {$ENDIF}
  inc(count,SData);
end;
function GZVectorc<T>.AddData(PData:Pointer;SData:Word):Integer;
var addr:pointer;
begin
  if parray=nil then
                    createarray;
  if count+sdata>max then
                         begin
                              if count+sdata>2*max then
                                                       {Grow}SetSize(count+sdata)
                                                   else
                                                        Grow;
                         end;
  {if count = max then
                     begin
                          parray := enlargememblock(parray, size * max, 2*size * max);
                          max:=2*max;
                     end;}
  begin
       //Pointer(addr) := parray;
       //addr := addr + count;
       { TODO : Надо копировать  с учетом compiler magic а не тупо мовить }
       addr:=@parray^[count];
       Move(PData^, addr^,SData*SizeOfData);
       result:=count;
       inc(count,SData);
  end;
end;
function GZVectorc<T>.GetRealCount:Integer;
{var p:Pointer;
    ir:itrec;}
begin
  result:=GetCount;
  {p:=beginiterate(ir);
  if p<>nil then
  repeat
        inc(result);
        p:=iterate(ir);
  until p=nil;}
end;
function GZVectorc<T>.copyto(var dest:GZVectorc<T>):Integer;
var i:integer;
begin
     result:=count;
     for i:=0 to count-1 do
       dest.PushBackData(parray[i]);
end;

{var p:pt;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        source.PushBackData(p^);  //-----------------//-----------
        p:=iterate(ir);
  until p=nil;
  result:=count;
end;}
procedure GZVectorc<T>.Invert;
(*var p,pl,tp:Pointer;
    ir:itrec;
begin
  p:=beginiterate(ir);
  p:=getDataMutable(0);
  pl:=getDataMutable(count-1);
  Getmem(tp,SizeOfData);
  if p<>nil then
  repeat
        if PtrUInt(pl)<=PtrUInt(p) then
                                         break;
        Move(p^,tp^,SizeOfData);
        Move(pl^,p^,SizeOfData);
        Move(tp^,pl^,SizeOfData);
        dec(PtrUInt(pl),SizeOfData);
        inc(PtrUInt(p),SizeOfData);
  until false;
  Freemem(tp);
end;*)
var i,j:integer;
    tdata:t;
begin
  j:=count-1;
  for i:=0 to (count-1)div 2 do
  begin
       tdata:=parray^[i];
       parray^[i]:=parray^[j];
       parray^[j]:=tdata;
       dec(j);
  end;
end;

function GZVectorc<T>.SetCount;
begin
     count:=index;
     if parray=nil then
                        createarray;
     if count>=max then
                       begin
                            if count>2*max then
                                               SetSize(2*count)
                                           else
                                               SetSize(2*max);
                       end;
     result:=parray;
end;
procedure GZVectorc<T>.SetSize;
begin
     if nsize>max then
                      begin
                           parray := enlargememblock(parray, SizeOfData*max, SizeOfData*nsize);
                      end
else if nsize<max then
                      begin
                           parray := enlargememblock(parray, SizeOfData*max, SizeOfData*nsize);
                           if count>nsize then count:=nsize;
                      end;
     max:=nsize;
end;
function GZVectorc<T>.beginiterate;
begin
  if parray=nil then
                    result:=nil
                else
                    begin
                          {ir.itp:=pointer(PtrUInt(parray)-SizeOfData);}
                          ir.itp:=pointer(parray);
                          dec(pt(ir.itp));
                          ir.itc:=-1;
                          result:=iterate(ir);
                    end;
end;
function GZVectorc<T>.iterate;
begin
  if count=0 then result:=nil
  else if ir.itc<(count-1) then
                      begin
                           inc(pByte(ir.itp),SizeOfData);
                           inc(ir.itc);

                           result:=ir.itp;
                      end
                  else result:=nil;
end;
constructor GZVectorc<T>.Create;
begin
  PArray:=nil;
  Count:=0;
  Max:=0;
end;
constructor GZVectorc<T>.Create(m:TArrayIndex);
begin
  PArray:=nil;
  Count:=0;
  Max:=m;
end;
destructor GZVectorc<T>.Destroy;
var i:integer;
   _pt:PTypeInfo;
begin
  _pt:=TypeInfo(T);
  if _pt^.Kind = tkClass then
    for i:=0 to count-1 do
      TObject(PArray^[i]).destroy;
  if _pt^.Kind in TypesNeedToFinalize then
    for i:=0 to count-1 do
      PArray^[i]:=default(t);
  if PArray<>nil then
    Freemem(PArray);
  PArray:=nil;
  inherited;
end;
{procedure GZVectorc<T>.free;
var i:integer;
   _pt:PTypeInfo;
begin
 _pt:=TypeInfo(T);
     if _pt^.Kind in TypesNeedToFinalize then
       for i:=0 to count-1 do
                             PArray^[i]:=default(t);
  count:=0;
end;}
function GZVectorc<T>.SizeOfData:TArrayIndex;
begin
  result:=sizeof(T);
end;
procedure GZVectorc<T>.clear;
begin
  count:=0;
end;
function GZVectorc<T>.CreateArray;
begin
  Getmem(PArray,SizeOfData*max);
  result:=parray;
end;
procedure GZVectorc<T>.Grow;
begin
     if newmax<=0 then
                     newmax:=2*max;
     parray := enlargememblock(parray, SizeOfData * max, SizeOfData * newmax);
     max:=newmax;
end;
procedure GZVectorc<T>.Shrink;
begin
  if (count<>0)and(count<max) then
  begin
       parray := remapmememblock(parray, SizeOfData * count);
       max := count;
  end;
end;
function GZVectorc<T>.GetCount:Integer;
begin
  result:=count;
end;
function GZVectorc<T>.IsEmpty:Boolean;
begin
  result:=(count=0);
end;
function GZVectorc<T>.InsertElement;
{var
   s:integer;}
begin
     if index=count then
                        PushBackData(data)
                    else
     begin
       if parray=nil then
                          CreateArray;
       if count = max then
                          grow;
       Move(parray[index],parray[index+1],(count-index)*sizeof(t));
       if PTypeInfo(TypeInfo(T))^.kind in TypesNeedToInicialize
               then fillchar(parray[index],sizeof(T),0);
       parray[index]:=data;
       inc(count);
     end;
     result:=parray;
end;
function GZVectorc<T>.DeleteElement;
begin
  if (index>=0)and(index<count)then
  begin
    dec(count);
    if PTypeInfo(TypeInfo(T))^.kind in TypesNeedToInicialize
      then parray^[index]:=default(t);
    if index<>count then
    Move(parray^[index+1],parray^[index],(count-index)*SizeOfData);
  end;
  result:=parray;
end;
function GZVectorc<T>.EraseElement;
begin
  if (index>=0)and(index<count)then
  begin
    dec(count);
    if PTypeInfo(TypeInfo(T))^.kind in TypesNeedToInicialize
      then parray^[index]:=default(t);
    if index<>count then
    Move(parray^[index+1],parray^[index],(count-index)*SizeOfData);
  end;
  result:=parray;
end;
function GZVectorc<T>.P2I(pel:Pointer):Integer;
begin
  result:=PT(pel)-PT(parray);
end;
function GZVectorc<T>.DeleteElementByP;
{var
   s:integer;}
begin
  result:=deleteelement(p2i(pel));
  {s:=PT(pel)-PT(parray);
  if s>=0 then
  begin
    deleteelement(s);
  end;
  result:=parray;}
end;
procedure GZVectorc<T>.freewithproc;
var i:integer;
begin
     for i:=0 to self.count-1 do
     begin
       freeproc(@parray[i]);
     end;
     self.count:=0;
end;
begin
end.

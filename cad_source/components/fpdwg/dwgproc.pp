{*************************************************************************** }
{  gfdwg - free implementation of the DWG file format based on LibreDWG      }
{                                                                            }
{        Copyright (C) 2022 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{  You should have received a copy of the GNU General Public License         }
{  along with this program.  If not, see <http://www.gnu.org/licenses/>.     }
{*************************************************************************** }

unit dwgproc;

{$IFDEF FPC}
  {$PACKRECORDS C}
  {$MACRO ON}
  {$IFDEF Windows}
    {$DEFINE extdecl := stdcall}
  {$ELSE}
    {$DEFINE extdecl := cdecl}
  {$ENDIF}
  {$Mode objfpc}{$H+}
  {$ModeSwitch advancedrecords}
{$ENDIF}

interface
  uses
    SysUtils, {ctypes,} dynlibs, dwg, ghashmap, TypInfo;

  resourcestring
    rsHandlerAlreadyReg='Handler already registered for %d';
    rsCouldNotLoadLib='Could not load library: %s';

  const
  {$if defined(Windows)}
    LibreDWG_Lib = 'libredwg-0.dll';
  {$elseif defined(OS2)}
    //LibreDWG_Lib = '';
  {$elseif defined(darwin)}
    //LibreDWG_LIB =  '';
  {$elseif defined(haiku) or defined(OpenBSD)}
    //LibreDWG_LIB = '';
  {$elseif defined(MorphOS)}
    //LibreDWG_LIB = '';
  {$else}
    LibreDWG_LIB = 'libredwg.so';
  {$endif}
  type

    TDWGCtx=record
      DWG:Dwg_Data;
      DWGVer:DWG_VERSION_TYPE;
      procedure CreateRec(var ADWG:Dwg_Data);
    end;

    TData=PtrInt;
    TCounter=Integer;
    TProcessLongProcess=procedure(const Data:TData;const Counter:TCounter);

    HashDWG_OBJECT_TYPE=class
      class function hash(dot:DWG_OBJECT_TYPE; n:longint):SizeUInt;
    end;

    generic GDWGParser<GUserCtx>=class
      type
        TDWGObjectLoadProc=procedure(var ZContext:GUserCtx;var DWGContext:TDWGCtx;var DWGObject:Dwg_Object;P:Pointer);
        PTDWGObjectData=^TDWGObjectData;
        TDWGObjectData=record
          LoadEntityProc:TDWGObjectLoadProc;
          LoadObjectProc:TDWGObjectLoadProc;
          procedure Create;
        end;
        //work in fpc3.2.2
        //TDWGObjectsDataDict=class (specialize TDictionary<DWG_OBJECT_TYPE,TDWGObjectData>)
        //  function GetMutableValue(key:DWG_OBJECT_TYPE; out PAValue:PTDWGObjectData):boolean;
        //end;
        TDWGObjectsDataDict=specialize THashmap<DWG_OBJECT_TYPE,TDWGObjectData,HashDWG_OBJECT_TYPE>;
      var
        DWGObj2LPDict:TDWGObjectsDataDict;
      constructor create;
      destructor destroy;override;
      procedure RegisterDWGEntityLoadProc(const DOT:DWG_OBJECT_TYPE;const LP:TDWGObjectLoadProc);
      procedure RegisterDWGObjectLoadProc(const DOT:DWG_OBJECT_TYPE;const LP:TDWGObjectLoadProc);
      procedure parseDwg_Data(var ZContext:GUserCtx;var dwg:Dwg_Data;const lpp:TProcessLongProcess;const data:TData);
    end;


  var
    dwg_read_file : function(const filename:pchar;
                             dwg:PDwg_Data):integer;extdecl;
    dxf_read_file : function(const filename:pchar;
                             dwg:PDwg_Data):integer;extdecl;
    dwg_free : procedure(dwg:PDwg_Data);extdecl;
    dwg_get_entity_layer : function(entity:PDwg_Object_Entity):PDwg_Object_LAYER;extdecl;

  procedure FreeLibreDWG;
  procedure LoadLibreDWG(lib : pchar = LibreDWG_Lib; reloadlib : Boolean = False);
  procedure BITCODE_T2Text(const p:BITCODE_T;constref DWGContext:TDWGCtx;out text:string);
  function DWG_V2Str(v:DWG_VERSION_TYPE):string;

implementation

  var
    hlib : tlibhandle;

   class function HashDWG_OBJECT_TYPE.hash(dot:DWG_OBJECT_TYPE; n:longint):SizeUInt;
   begin
     result:=ord(dot) mod SizeUInt(n);
   end;

  procedure TDWGCtx.CreateRec(var ADWG:Dwg_Data);
  begin
    DWG:=ADWG;
    DWGVer:=ADWG.HEADER.version;
    if DWGVer=R_INVALID then
      DWGVer:=ADWG.HEADER.from_version;
  end;

  procedure GDWGParser.TDWGObjectData.Create;
  begin
    LoadEntityProc:=nil;
    LoadObjectProc:=nil;
  end;

  procedure GDWGParser.RegisterDWGEntityLoadProc(const DOT:DWG_OBJECT_TYPE;const LP:TDWGObjectLoadProc);
  var
    //pdod:PTDWGObjectData;
    dod:TDWGObjectData;
  begin
    //work in fpc3.2.2
    //if DWGObj2LPDict.GetMutableValue(DOT,pdod) then begin
    //  if pdod^.LoadEntityProc<>nil then
    //    raise Exception.Create(format(rsHandlerAlreadyReg,[DOT]))
    //  else begin
    //    pdod^.LoadEntityProc:=LP;
    //    pdod^.LoadObjectProc:=nil;
    //  end;
    //end else begin
      dod.Create;
      dod.LoadEntityProc:=LP;
      dod.LoadObjectProc:=nil;
      DWGObj2LPDict.insert(DOT,dod);
    //end;
  end;

  procedure GDWGParser.RegisterDWGObjectLoadProc(const DOT:DWG_OBJECT_TYPE;const LP:TDWGObjectLoadProc);
  var
    //pdod:PTDWGObjectData;
    dod:TDWGObjectData;
  begin
    //work in fpc3.2.2
    //if DWGObj2LPDict.GetMutableValue(DOT,pdod) then begin
    //  if pdod^.LoadEntityProc<>nil then
    //    raise Exception.Create(format(rsHandlerAlreadyReg,[DOT]))
    //  else begin
    //    pdod^.LoadEntityProc:=nil;
    //    pdod^.LoadObjectProc:=LP;
    //  end;
    //end else begin
      dod.Create;
      dod.LoadEntityProc:=nil;
      dod.LoadObjectProc:=LP;
      DWGObj2LPDict.insert(DOT,dod);
    //end;
  end;

  procedure GDWGParser.parseDwg_Data(var ZContext:GUserCtx;var dwg:Dwg_Data;const lpp:TProcessLongProcess;const data:TData);
  //work in fpc3.2.2
  //var
  //  i:BITCODE_BL;
  //  pdod:PTDWGObjectData;
  //  DWGContext:TDWGCtx;
  //begin
  //  DWGContext.CreateRec(dwg);
  //  if DWGObj2LPDict<>nil then begin
  //    i:=0;
  //    while (i<dwg.num_objects) do begin
  //      if DWGObj2LPDict.GetMutableValue(dwg.&object[i].fixedtype,pdod) then begin
  //        if pdod^.LoadEntityProc<>nil then
  //          pdod^.LoadEntityProc(ZContext,DWGContext,dwg.&object[i],dwg.&object[i].tio.entity^.tio.UNUSED)
  //        else if pdod^.LoadObjectProc<>nil then
  //          pdod^.LoadObjectProc(ZContext,DWGContext,dwg.&object[i],dwg.&object[i].tio.&object^.tio.DUMMY);
  //      end;
  //      if @lpp<>nil then
  //        lpp(data,i);
  //      inc(i);
  //    end;
  //  end;
  //end;
  var
    i:BITCODE_BL;
    dod:TDWGObjectData;
    DWGContext:TDWGCtx;
  begin
    DWGContext.CreateRec(dwg);
    if DWGObj2LPDict<>nil then begin
      i:=0;
      while (i<dwg.num_objects) do begin
        if DWGObj2LPDict.GetValue(dwg.&object[i].fixedtype,dod) then begin
          if (dod.LoadEntityProc<>nil) and (dwg.&object[i].tio.entity<>nil) then
            dod.LoadEntityProc(ZContext,DWGContext,dwg.&object[i],dwg.&object[i].tio.entity^.tio.UNUSED)
          else if (dod.LoadObjectProc<>nil) and (dwg.&object[i].tio.&object<>nil) then
            dod.LoadObjectProc(ZContext,DWGContext,dwg.&object[i],dwg.&object[i].tio.&object^.tio.DUMMY);
        end;
        if @lpp<>nil then
          lpp(data,i);
        inc(i);
      end;
    end;
  end;

  //work in fpc3.2.2
  //function GDWGParser.TDWGObjectsDataDict.GetMutableValue(key:DWG_OBJECT_TYPE; out PAValue:PTDWGObjectData):Boolean;
  //var
  //  LIndex: SizeInt;
  //  LHash: UInt32;
  //begin
  //  LIndex := FindBucketIndex(FItems, key, LHash);
  //
  //  if LIndex < 0 then begin
  //    result:=false;
  //    PAValue:=nil;
  //  end else begin
  //    result:=true;
  //    PAValue:=@FItems[LIndex].Pair.Value;
  //  end;
  //end;

  constructor GDWGParser.create;
  begin
    DWGObj2LPDict:=TDWGObjectsDataDict.create;
  end;
  destructor GDWGParser.destroy;
  begin
    DWGObj2LPDict.Free;
  end;

  function DWG_V2Str(v:DWG_VERSION_TYPE):string;
  begin
    if Ord(v)>Ord(R_AFTER)then
      v:=R_AFTER;
    result:=GetEnumName(typeinfo(v),Ord(v));
  end;

  procedure BITCODE_T2Text(const p:BITCODE_T;constref DWGContext:TDWGCtx;out text:string);
  begin
    if DWGContext.dwg.header.version<=R_2004 then
      text:=pchar(p)
    else
      text:=punicodechar(p)
  end;



  procedure FreeLibreDWG;
  begin
    if (hlib <> 0) then
      FreeLibrary(hlib);
    hlib:=0;
    dwg_read_file:=nil;
    dxf_read_file:=nil;
    dwg_free:=nil;
    dwg_get_entity_layer:=nil;
  end;

  procedure LoadLibreDWG(lib : pchar = LibreDWG_Lib; reloadlib : Boolean = False);
  begin
    if reloadlib then
      FreeLibreDWG;
    if hlib = 0 then begin
      hlib:=LoadLibrary(lib);
      pointer(dwg_read_file):=GetProcAddress(hlib,'dwg_read_file');
      pointer(dxf_read_file):=GetProcAddress(hlib,'dxf_read_file');
      pointer(dwg_free):=GetProcAddress(hlib,'dwg_free');
      pointer(dwg_get_entity_layer):=GetProcAddress(hlib,'dwg_get_entity_layer');
    end;
    if hlib=0 then
      raise Exception.Create(format(rsCouldNotLoadLib,[lib]));
  end;

initialization
  hlib:=0;
  FreeLibreDWG;
finalization
  FreeLibreDWG;
end.

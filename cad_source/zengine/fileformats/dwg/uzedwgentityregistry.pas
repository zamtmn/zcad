{*************************************************************************** }
{  fpdwg - DWG entity / object handler registry (Stage 5.x R5)               }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

{ Refactor R5 (per TZ_DWG_LOAD_TO_ZCAD_AUDIT §3.5 / TZ §6.5):
  a single public registration point that decouples entity mappers from the
  loader orchestration. Mappers in dwg/entities/* register themselves here in
  their initialization sections; uzefflibredwg.pas reads the resulting
  parser singleton without knowing about individual mapper units. This
  removes the previous mutual `uses` between uzefflibredwg.pas and
  uzefflibredwg2ents.pas — the only "glue" left is that both depend on this
  registry. }

unit uzedwgentityregistry;

{$Include zengineconfig.inc}
{$Mode objfpc}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  dwg, dwgproc,uzeffmanager,
  uzedrawingsimple;

type
  { Specialized parser for the ZCAD drawing context. The same shape mappers
    already used in uzefflibredwg2ents.pas, exposed through the registry so
    individual entity units can register without referencing the global
    parser variable directly. }
  TZCADDWGParser = specialize GDWGParser<TZDrawingContext>;

  { Mapper signature shared by every entity / object handler. Entities access
    the LibreDWG payload through DWGObject.tio.entity^.tio.<Name>; objects use
    DWGObject.tio.&object^.tio.<Name>. The registry passes them through
    untouched so each mapper can cast to its concrete pointer type. }
  TDWGEntityHandler = TZCADDWGParser.TDWGObjectLoadProc;

{ Registration entry points used by individual mapper units. Both forwards to
  the TZCADDWGParser singleton (created on first access) and raise the same
  rsHandlerAlreadyReg exception on a duplicate DOT. }
procedure RegisterDWGEntityHandler(const DOT: DWG_OBJECT_TYPE;
  const H: TDWGEntityHandler);
procedure RegisterDWGObjectHandler(const DOT: DWG_OBJECT_TYPE;
  const H: TDWGEntityHandler);

{ Lazy accessor for the parser. The singleton is created on demand so the FPC
  unit-init order does not matter — any of the entity units (or the loader
  unit itself) may be the first to touch the registry. The orchestration
  unit (uzefflibredwg.pas) calls this to obtain the parser instance for
  parseDwg_Data. }
function GetDWGParser: TZCADDWGParser;

{ Issue #1198 P2 (TZ §5): introspection used by the diagnostic histogram so it
  can flag fixedtypes that arrived in the file but have no registered handler.
  Looks up the DOT in the parser's internal dispatch table; result is True
  iff at least one entity- or object-handler is registered for that DOT. The
  query is cheap (THashmap.GetValue) — the histogram calls it once per bucket. }
function HasHandlerFor(const DOT: DWG_OBJECT_TYPE): Boolean;

implementation

var
  GParser: TZCADDWGParser = nil;

function GetDWGParser: TZCADDWGParser;
begin
  if GParser = nil then
    GParser := TZCADDWGParser.Create;
  Result := GParser;
end;

procedure RegisterDWGEntityHandler(const DOT: DWG_OBJECT_TYPE;
  const H: TDWGEntityHandler);
begin
  GetDWGParser.RegisterDWGEntityLoadProc(DOT, H);
end;

procedure RegisterDWGObjectHandler(const DOT: DWG_OBJECT_TYPE;
  const H: TDWGEntityHandler);
begin
  GetDWGParser.RegisterDWGObjectLoadProc(DOT, H);
end;

function HasHandlerFor(const DOT: DWG_OBJECT_TYPE): Boolean;
var
  Parser: TZCADDWGParser;
  dod: TZCADDWGParser.TDWGObjectData;
begin
  Parser := GetDWGParser;
  if Parser.DWGObj2LPDict = nil then
    Exit(False);
  Result := Parser.DWGObj2LPDict.GetValue(DOT, dod);
end;

initialization
finalization
  FreeAndNil(GParser);
end.

{*************************************************************************** }
{  fpdwg - DWG text-style name resolution helpers (Issue #1198 P6)           }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

{ Issue #1198 P6 (АНАЛИЗ_ЗАГРУЗЧИКА_DWG.md §4.4/§P6): pure name-resolution
  helpers used by AddTextStyle to pick a non-aliasing name for a DWG STYLE
  record. The legacy code unconditionally renamed every empty-named style to
  'Standard', which let two distinct DWG handles share the same ZCAD pstyle
  and silently lose one of the original names (the second RegisterShell
  returned False and the second handle ended up pointing at the first style).

  The functions in this unit are deliberately split off from uzedwgtables so
  the regression tests can link them without pulling the ZCAD drawing /
  styles units onto the test project's search path. Only SysUtils and the
  load-context registry are referenced. }

unit uzedwgstylename;

{$Include zengineconfig.inc}
{$Mode objfpc}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  uzedwgtypes,
  uzedwgloadcontext;

{ Pick the name a DWG STYLE record should be registered under when the
  decoded payload is empty. Shape styles with a non-empty FontFile keep using
  the FontFile (existing legacy behaviour — that path drives linetype shape
  glyphs and must not change). Real text styles keep their decoded name when
  it survives the codepage decode. Empty-named entries fall back to a
  handle-derived placeholder 'dwg_<hex>' that is stable across re-imports of
  the same file. Handle=0 keeps the legacy 'Standard' fallback so synthetic
  fixtures (and any future caller that supplies no handle) still behave
  deterministically. }
function DWGTextStyleBaseName(const DecodedName, FontFile: String;
  IsShape: Boolean; Handle: QWord): String;

{ Build the '<base>_dwg<hex>' name used when the base name picked by
  DWGTextStyleBaseName collides with a style already owned by a different
  DWG handle. The suffix is derived from the handle so re-importing the same
  file produces the same uniquified name (i.e. references that survive a
  round-trip do not silently switch styles). Handle=0 produces '<base>_dwg0',
  which is still distinct from <base> itself — that lets fixture callers
  exercise the rename path without crafting a real handle. }
function DWGTextStyleUniquifyName(const BaseName: String;
  Handle: QWord): String;

{ Scan the load context's handle registry for a textstyle entry whose Ptr
  matches APtr but whose handle differs from ANewHandle. Returns True when
  another DWG handle already claims that pstyle — the AddTextStyle mapper
  uses this signal to know it must register the new handle under a
  uniquified name instead of silently aliasing onto the existing pstyle.
  The scan is O(N) over registered handles; textstyle tables in practice
  contain at most a few dozen entries so the cost is negligible. }
function DWGTextStylePtrOwnedByAnotherHandle(Ctx: TDWGZCADLoadContext;
  APtr: Pointer; ANewHandle: QWord): Boolean;

implementation

function DWGTextStyleBaseName(const DecodedName, FontFile: String;
  IsShape: Boolean; Handle: QWord): String;
begin
  if IsShape and (FontFile <> '') then
    Result := FontFile
  else if DecodedName <> '' then
    Result := DecodedName
  else if Handle <> 0 then
    Result := 'dwg_' + IntToHex(Handle, 1)
  else
    Result := 'Standard';
end;

function DWGTextStyleUniquifyName(const BaseName: String;
  Handle: QWord): String;
begin
  if Handle <> 0 then
    Result := BaseName + '_dwg' + IntToHex(Handle, 1)
  else
    Result := BaseName + '_dwg0';
end;

function DWGTextStylePtrOwnedByAnotherHandle(Ctx: TDWGZCADLoadContext;
  APtr: Pointer; ANewHandle: QWord): Boolean;
var
  I: Integer;
  Entry: PDWGZCADHandleEntry;
begin
  Result := False;
  if (Ctx = nil) or (APtr = nil) then
    Exit;
  for I := 0 to Ctx.Handles.Count - 1 do begin
    Entry := Ctx.Handles.EntryAt(I);
    if (Entry^.Kind = dokTextStyle) and (Entry^.Ptr = APtr) and
       (Entry^.Handle <> ANewHandle) then
      Exit(True);
  end;
end;

end.

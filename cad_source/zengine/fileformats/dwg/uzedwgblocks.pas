{*************************************************************************** }
{  fpdwg - DWG block-header / block mappers (Stage 5.x R6)                   }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

{ Refactor R6 (per TZ_DWG_LOAD_TO_ZCAD_AUDIT §3.6 / TZ §6.5):
  BLOCK_HEADER and BLOCK mappers extracted from uzefflibredwg2ents.pas.
  Model / paper / user-block recognition (TZ §12.4) lives here together
  with the BlockDef registration so AddBlockHeader does not pull the table
  mappers above it. }

unit uzedwgblocks;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  dwg, dwgproc, uzedwghandle, uzedwgtext,
  uzedrawingsimple,
  uzeblockdef, UGDBObjBlockdefArray,
  uzeTypes,
  uzedwgloadcontext,
  uzedwgentityregistry,
  uzedwgtypes,
  uzeffmanager,
  uzedwgimport;

implementation

uses
  uzedwglog;

{ Stage 4 (TZ §12.4): a block header may describe model-space, paper-space or
  a user block. The first two are containers but not user-visible blocks, so
  they must NOT spawn a BlockDef and must NOT count as duplicates against
  user-named blocks. LibreDWG exposes `mspace_block` / `pspace_block` on the
  Dwg_Data root: comparing the object pointer is locale/version safe and
  cheaper than a name match. We still keep a name fallback because the layout
  pointers are only populated for real DWG files — fixture-driven tests that
  build a Dwg_Object by hand can reach this code path with parent=nil. }
function DWGBlockHeaderIsModelSpace(var DWGObject: Dwg_Object;
  const Name: string): Boolean;
var
  Dwg: PDwg_Data;
  upper: string;
begin
  Dwg := PDwg_Data(DWGObject.parent);
  if (Dwg <> nil) and (Dwg^.mspace_block <> nil) and
     (Pointer(Dwg^.mspace_block) = @DWGObject) then
    Exit(True);
  upper := UpperCase(Name);
  Result := (upper = '*MODEL_SPACE') or (upper = '$MODEL_SPACE');
end;

function DWGBlockHeaderIsPaperSpace(var DWGObject: Dwg_Object;
  const Name: string): Boolean;
var
  Dwg: PDwg_Data;
  upper: string;
begin
  Dwg := PDwg_Data(DWGObject.parent);
  if (Dwg <> nil) and (Dwg^.pspace_block <> nil) and
     (Pointer(Dwg^.pspace_block) = @DWGObject) then
    Exit(True);
  upper := UpperCase(Name);
  Result := (upper = '*PAPER_SPACE') or (upper = '$PAPER_SPACE') or
            (Copy(upper, 1, 12) = '*PAPER_SPACE');
end;

procedure AddBlockHeader(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PDWGBlock_Header: PDwg_Object_BLOCK_HEADER);
var
  name: string;
  Handle: QWord;
  pBlockDef: PGDBObjBlockdef;
  existingIdx: Integer;
  isModel, isPaper: Boolean;
  Ctx: TDWGZCADLoadContext;
begin
  BITCODE_T2Text(PDWGBlock_Header^.name, DWGContext, name);
  name := DWGDecodedTextForZCAD(name);
  //DWGLogInfoFormatStr('BlockHeader: %s', [name]);

  Ctx := GetLoadCtx;
  if Ctx = nil then
    Exit;
  Handle := DWGObjectHandleValue(DWGObject);
  if Handle = 0 then
    Exit;

  // Stage 4 (TZ §12.4): model and paper space are containers, not user blocks.
  // The model-space root is already registered under handle 0 in
  // BeginDWGImport so child entities with a null/missing owner fall back to
  // it; here we additionally register the real model-space handle so entities
  // whose ownerhandle points to model_space land in the same drawing root and
  // not into a freshly created BlockDef. Paper space gets its own kind so
  // future paper-space layouts can be wired without changing this routine.
  isModel := DWGBlockHeaderIsModelSpace(DWGObject, name);
  isPaper := (not isModel) and DWGBlockHeaderIsPaperSpace(DWGObject, name);

  if isModel then begin
    Ctx.RegisterShell(Handle, dokModelSpace,
      ZContext.PDrawing^.pObjRoot, -1);
    Exit;
  end;
  if isPaper then begin
    // Stage 4 leaves paper-space contents in fallback root for now (TZ §12.4
    // covers recognition, full paper-space rendering is its own future stage).
    // Registering with pObjRoot keeps child resolve working without
    // pretending we have a separate paper-space drawing.
    Ctx.RegisterShell(Handle, dokPaperSpace,
      ZContext.PDrawing^.pObjRoot, -1);
    Exit;
  end;

  // Stage 4 (TZ §12.4): a real user block. Honour LoadMode the same way
  // LayerTable.MergeItem does — TLOMerge keeps the existing definition,
  // TLOLoad reuses it (and lets later mappers overwrite fields). The
  // BlockDefArray itself does not provide MergeItem so we inline the lookup.
  existingIdx := ZContext.PDrawing^.BlockDefArray.getindex(name);
  if existingIdx >= 0 then begin
    pBlockDef := @PBlockdefArray(
      ZContext.PDrawing^.BlockDefArray.parray)[existingIdx];
    if ZContext.LoadMode = TLOMerge then begin
      // Duplicate-by-name in merge mode: do not overwrite, but still register
      // the new handle so children inside this duplicate landed under the
      // already-loaded block definition.
      DWGLogInfoFormatStr('BlockHeader: duplicate "%s" merged', [name]);
    end;
  end else begin
    pBlockDef := ZContext.PDrawing^.BlockDefArray.create(name);
    if pBlockDef <> nil then begin
      pBlockDef^.Base.x := PDWGBlock_Header^.base_pt.x;
      pBlockDef^.Base.y := PDWGBlock_Header^.base_pt.y;
      pBlockDef^.Base.z := PDWGBlock_Header^.base_pt.z;
    end;
  end;
  Ctx.RegisterShell(Handle, dokBlockDef, pBlockDef, -1);
end;

procedure AddBlock(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PDWGBlock_Header: PDwg_Object_BLOCK_HEADER);
var
  name: string;
begin
  BITCODE_T2Text(PDWGBlock_Header^.name, DWGContext, name);
  //DWGLogInfoFormatStr('Block: %s', [name]);
end;

initialization
  RegisterDWGObjectHandler(DWG_TYPE_BLOCK_HEADER, @AddBlockHeader);
  RegisterDWGEntityHandler(DWG_TYPE_BLOCK, @AddBlock);
end.

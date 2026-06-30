{*************************************************************************** }
{  fpdwg - DWG block definition capacity reservation                         }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

unit uzedwgblockreserve;

{$Include zengineconfig.inc}
{$Mode objfpc}{$H+}

interface

uses
  dwg,
  UGDBObjBlockdefArray;

const
  { ResolveRefs may create the synthetic missing-block definition before
    ResolveOwners attaches block content. Keep one spare slot so that fallback
    creation cannot grow BlockDefArray and invalidate already registered owner
    pointers. }
  DWG_IMPORT_EXTRA_BLOCKDEF_SLOTS = 1;

function DWGRawBlockHeaderCount(var Raw: Dwg_Data): Integer;
procedure DWGReserveBlockDefCapacity(var Raw: Dwg_Data;
  var BlockDefs: GDBObjBlockdefArray;
  ExtraSlots: Integer = DWG_IMPORT_EXTRA_BLOCKDEF_SLOTS);

implementation

function DWGRawBlockHeaderCount(var Raw: Dwg_Data): Integer;
var
  I: BITCODE_BL;
begin
  Result := 0;
  if (Raw.num_objects = 0) or (Raw.&object = nil) then
    Exit;

  I := 0;
  while I < Raw.num_objects do begin
    if Raw.&object[I].fixedtype = DWG_TYPE_BLOCK_HEADER then
      Inc(Result);
    Inc(I);
  end;
end;

procedure DWGReserveBlockDefCapacity(var Raw: Dwg_Data;
  var BlockDefs: GDBObjBlockdefArray; ExtraSlots: Integer);
var
  BlockHeaderCount: Integer;
  NeededMax: Integer;
begin
  if ExtraSlots < 0 then
    ExtraSlots := 0;

  BlockHeaderCount := DWGRawBlockHeaderCount(Raw);
  if BlockHeaderCount = 0 then
    Exit;

  NeededMax := BlockDefs.count + BlockHeaderCount + ExtraSlots;
  if NeededMax > BlockDefs.max then
    BlockDefs.Grow(NeededMax);
end;

end.

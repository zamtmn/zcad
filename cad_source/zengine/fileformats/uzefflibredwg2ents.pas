{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file GPL-3.0.txt, included in this distribution,                 *
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

{ Refactor R5/R6 (TZ_DWG_LOAD_TO_ZCAD_AUDIT §3.5/§3.6, §6.4):
  This unit used to host the entire DWG load context, all object/entity
  mappers and the global parser singleton (717 lines). After the split it
  is a thin compatibility facade that:

    * re-exports BeginDWGImport / EndDWGImport from uzedwgimport so existing
      callers (uzefflibredwg.pas, fpdwg_tests) keep their imports unchanged;
    * pulls every per-entity / per-table / per-block mapper unit into the
      build via the implementation-uses clause so each unit's initialization
      section runs (registering its handler against the registry).

  No new code lives here. New mappers go into dwg/entities/uzedwgent*.pas
  (entities) or dwg/uzedwg*.pas (tables, blocks, lifecycle). }

unit uzeffLibreDWG2Ents;
{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}
interface

uses
  dwg,
  uzedrawingsimple,
  uzeffmanager,
  uzedwgimport;

procedure BeginDWGImport(var ZContext: TZDrawingContext;
  const ASourcePath: String = '');
procedure ScanDWGImport(var Raw: Dwg_Data);
procedure EndDWGImport(var ZContext: TZDrawingContext);

implementation

uses
  // Pulling these mapper units into the build makes their initialization
  // sections run, which is how every handler ends up registered against the
  // shared TZCADDWGParser singleton in uzedwgentityregistry. The unit list
  // is the only place where mapper coverage is enumerated; adding a new
  // entity is a one-line edit here plus the new unit itself.
  uzedwgtables,
  uzedwgblocks,
  uzedwgcontrolobjects,
  uzedwgentline,
  uzedwgentcircle,
  uzedwgentarc,
  uzedwgentpoint,
  uzedwgentlwpolyline,
  uzedwgenttext,
  uzedwgentmtext,
  uzedwgentinsert,
  uzedwgentattrib,
  uzedwgentdimension,
  uzedwgent3dface,
  uzedwgentsolid,
  uzedwgentellipse,
  uzedwgentspline,
  uzedwgenthatch,
  uzedwgentpolyline,
  uzedwgentproxy;

procedure BeginDWGImport(var ZContext: TZDrawingContext;
  const ASourcePath: String = '');
begin
  uzedwgimport.BeginDWGImport(ZContext, ASourcePath);
end;

procedure ScanDWGImport(var Raw: Dwg_Data);
begin
  uzedwgimport.ScanDWGImport(Raw);
end;

procedure EndDWGImport(var ZContext: TZDrawingContext);
begin
  uzedwgimport.EndDWGImport(ZContext);
end;

end.

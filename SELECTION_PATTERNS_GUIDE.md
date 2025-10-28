# ZCAD Object Selection Patterns Guide

Based on thorough analysis of the ZCAD codebase, here are the established patterns for handling object selection in commands.

## 1. DATA STRUCTURES FOR SELECTION

### Selected Object Array (UGDBSelectedObjArray)
Located in: `/tmp/gh-issue-solver-1761647622010/cad_source/zengine/containers/UGDBSelectedObjArray.pas`

```pascal
{ Descriptor for a single selected object }
PSelectedObjDesc=^SelectedObjDesc;
SelectedObjDesc=record
  objaddr:PGDBObjEntity;           { Pointer to the entity }
  pcontrolpoint:PGDBControlPointArray;  { Optional control points }
  ptempobj:PGDBObjEntity;          { Optional temporary object }
end;

{ Array containing all selected objects }
PGDBSelectedObjArray=^GDBSelectedObjArray;
GDBSelectedObjArray= object(GZVector{-}<selectedobjdesc>{//})
  SelectedCount:Integer;  { Total count of selected items }
  function addobject(PEntity:PGDBObjEntity):pselectedobjdesc;virtual;
  procedure pushobject(PEntity:PGDBObjEntity);
  procedure free;virtual;
  ...
end;
```

### Accessing Selected Objects
From drawing object:
- `drawings.GetCurrentDWG.SelObjArray` - Array of selected objects
- `drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount` - Count of selected objects
- `pobj^.selected` - Boolean property indicating if object is selected

---

## 2. CHECKING IF OBJECTS ARE SELECTED

### Pattern 1: Simple Count Check
```pascal
{ Check if any objects are selected }
if (drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount=0) then begin
  zcUI.TextMessage('Entities must be selected before run the command',TMWOHistoryOut);
  Exit;
end;
```

### Pattern 2: Iterate Through All Objects and Count Selected
```pascal
{ From uzccommand_move.pas - CommandStart }
counter:=0;
pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
if pobj<>nil then
  repeat
    if pobj^.selected then
      Inc(counter);
    pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj=nil;

if counter>0 then begin
  { Process selected objects }
end else begin
  zcUI.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
  Commandmanager.executecommandend;
end;
```

### Pattern 3: Get Bounding Box of Selected Entities
```pascal
{ From uzccommand_duplicate.pas }
function GetSelectedEntsAABB(constref ObjArray:GDBObjEntityOpenArray;
  out SelectedAABB:TBoundingBox):boolean;
var
  pobj:pGDBObjEntity;
  ir:itrec;
begin
  Result:=False;
  SelectedAABB:=default(TBoundingBox);

  pobj:=ObjArray.beginiterate(ir);
  if pobj<>nil then
    repeat
      if pobj.selected then begin
        if Result then
          ConcatBB(SelectedAABB,pobj.vp.BoundingBox)
        else
          SelectedAABB:=pobj.vp.BoundingBox;
        Result:=True;
      end;
      pobj:=ObjArray.iterate(ir);
    until pobj=nil;
end;
```

---

## 3. ITERATING THROUGH SELECTED OBJECTS

### Pattern 1: Iterate Through SelObjArray (Recommended)
```pascal
{ From uzccommand_erase.pas }
psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
if psd<>nil then
  repeat
    pv:=psd^.objaddr;  { Get the entity pointer }
    { Process the object }
    { Example: pv^.Selected:=False; }
    psd:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
  until psd=nil;
```

### Pattern 2: Iterate Through All Objects and Check Selected Flag
```pascal
{ From uzccommand_inverseselected.pas }
Count:=0;
pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
if pv<>nil then
  repeat
    if not pv^.Selected then  { or: if pv^.Selected then }
      Inc(Count);
    pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;
```

---

## 4. BUILDING COLLECTION OF SELECTED OBJECTS

### Pattern 1: Store Selected Objects in Vector
```pascal
{ From uzccommand_move.pas - InternalCommandStart }
counter:=0;

{ First pass: count selected objects }
pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
if pobj<>nil then
  repeat
    if pobj^.selected then
      Inc(counter);
    pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj=nil;

if counter>0 then begin
  { Initialize vector with proper size }
  Getmem(Pointer(pcoa),sizeof(tpcoavector));
  pcoa^.init(counter);
  
  { Second pass: populate the vector }
  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj<>nil then
    repeat
      if pobj^.selected then begin
        { Create proxy copy for manipulation }
        tv:=pobj^.Clone(@drawings.GetCurrentDWG^.ConstructObjRoot);
        if tv<>nil then begin
          tv^.State:=tv^.State+[ESConstructProxy];
          drawings.GetCurrentDWG^.ConstructObjRoot.AddMi(@tv);
          tcd.sourceEnt:=pobj;
          tcd.tmpProxy:=tv;
          tcd.copyEnt:=nil;
          pcoa^.PushBackData(tcd);  { Add to collection }
          tv^.formatentity(drawings.GetCurrentDWG^,dc);
        end;
      end;
      pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pobj=nil;
end;
```

### Pattern 2: Create Array of Selected Entities
```pascal
{ From uzccommand_inverseselected.pas }
if Count>0 then begin
  Ents.init(Count);
  pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if not pv^.Selected then
        Ents.PushBackData(pv);  { Add to array }
      pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pv=nil;
  drawings.GetCurrentDWG.DeSelectAll;
  drawings.GetCurrentDWG.SelectEnts(Ents);  { Select new set }
  Ents.Clear;
  Ents.done;
end;
```

---

## 5. REQUESTING USER TO SELECT OBJECTS

### Pattern 1: Display Error Message If No Selection
```pascal
{ From uzccommand_move.pas }
if counter>0 then begin
  { Execute command }
end else begin
  zcUI.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
  Commandmanager.executecommandend;
end;
```

### Pattern 2: Interactive Selection with getentity
```pascal
{ From uzccommand_matchprop.pas }
if commandmanager.getentity(rscmSelectSourceEntity,ps) then begin
  { Process source entity }
  while commandmanager.getentity(rscmSelectDestinationEntity,pd) do begin
    { Process destination entities one by one }
  end;
end;
```

### String Constants Used
From `/tmp/gh-issue-solver-1761647622010/cad_source/zcad/uzcstrconsts.pas`:
```pascal
rscmBasePoint='Base point:';
rscmSelEntBeforeComm='Entities must be selected before run the command';
rscmSelectSourceEntity='Select source entity'; { Custom }
rscmSelectDestinationEntity='Select destination entity'; { Custom }
```

---

## 6. DESELECTING AND CLEARING SELECTION

### Clear All Selection Counters
```pascal
{ From uzccommand_erase.pas }
drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount:=0;
drawings.GetCurrentDWG^.wa.param.seldesc.OnMouseObject:=nil;
drawings.GetCurrentDWG^.wa.param.seldesc.LastSelectedObject:=nil;
drawings.GetCurrentDWG^.wa.param.lastonmouseobject:=nil;
zcUI.Do_GUIaction(nil,zcMsgUIReturnToDefaultObject);
```

### Deselect All Command
```pascal
{ From uzccommand_deselectall.pas }
function DeSelectAll_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
begin
  zcUI.Do_GUIaction(nil,zcMsgUIActionRedraw);
  Result:=cmd_ok;
end;

{ Registration shows the action attributes }
deselall:=CreateZCADCommand(@DeSelectAll_com,'DeSelectAll',CADWG or CASelEnts,0);
deselall^.CEndActionAttr:=[CEGUIReturnToDefaultObject,CEDeSelect];
```

---

## 7. COMMAND STRUCTURE WITH SELECTION HANDLING

### Complete Pattern from Move Command
```pascal
type
  move_com=object(CommandRTEdObject)
    t3dp:gdbvertex;
    pcoa:ptpcoavector;  { Collection of objects to process }
    
    function InternalCommandStart(const Context:TZCADCommandContext;
      Operands:TCommandOperands):boolean;virtual;
    procedure CommandStart(const Context:TZCADCommandContext;
      Operands:TCommandOperands);virtual;
    procedure CommandCancel(const Context:TZCADCommandContext);virtual;
  end;

function move_com.InternalCommandStart(const Context:TZCADCommandContext;
  Operands:TCommandOperands):boolean;
var
  pobj:pGDBObjEntity;
  counter:integer;
begin
  { 1. Count selected objects }
  counter:=0;
  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj<>nil then
    repeat
      if pobj^.selected then
        Inc(counter);
      pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pobj=nil;

  { 2. Check if selection exists }
  if counter>0 then begin
    { 3. Start command and build collection }
    inherited CommandStart(context,'');
    Getmem(Pointer(pcoa),sizeof(tpcoavector));
    pcoa^.init(counter);
    
    pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
    if pobj<>nil then
      repeat
        if pobj^.selected then begin
          { Populate collection with selected objects }
          tv:=pobj^.Clone(...);
          pcoa^.PushBackData(tcd);
        end;
        pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
      until pobj=nil;
    Result:=True;
  end else begin
    Result:=False;  { No selection, command cannot proceed }
  end;
end;

procedure move_com.CommandStart(const Context:TZCADCommandContext;
  Operands:TCommandOperands);
begin
  inherited;
  if not InternalCommandStart(Context,Operands) then begin
    zcUI.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
    Commandmanager.executecommandend;
  end;
end;

procedure move_com.CommandCancel(const Context:TZCADCommandContext);
begin
  if pcoa<>nil then begin
    pcoa^.done;
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Free;
    Freemem(pointer(pcoa));
  end;
  inherited;
end;
```

---

## 8. COMMAND REGISTRATION WITH SELECTION ATTRIBUTES

### CASelEnts Flag Usage
```pascal
{ From various commands }
deselall:=CreateZCADCommand(@DeSelectAll_com,'DeSelectAll',
  CADWG or CASelEnts,0);
InvSel:=CreateZCADCommand(@InverseSelected_com,'InverseSelected',
  CADWG or CASelEnts,0);

{ Command End Actions }
deselall^.CEndActionAttr:=[CEGUIReturnToDefaultObject,CEDeSelect];
InvSel^.CEndActionAttr:=[CEGUIRePrepare];
```

### Attributes Meaning
- `CADWG` - Command works with current drawing
- `CASelEnts` - Command works with selected entities
- `CEGUIReturnToDefaultObject` - Return to default object after command
- `CEDeSelect` - Deselect objects after command
- `CEGUIRePrepare` - Prepare GUI after command

---

## 9. KEY FUNCTIONS AND TYPES

### Iteration Records (ir)
```pascal
var ir:itrec;  { Iterator record for container traversal }

{ Usage pattern }
pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
if pobj<>nil then
  repeat
    { Process pobj }
    pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj=nil;
```

### Vector Types
```pascal
ptpcoavector=^tpcoavector;
tpcoavector={-}specialize{//}
  GZVector{-}<TCopyObjectDesc>{//};

{ Usage }
Getmem(Pointer(pcoa),sizeof(tpcoavector));
pcoa^.init(size);
pcoa^.PushBackData(data);
pcoa^.done;
Freemem(pointer(pcoa));
```

---

## 10. COMMON MESSAGES AND CONSTANTS

```pascal
{ From uzcstrconsts.pas }
rscmBasePoint='Base point:'
rscmNewBasePoint='New base point:'
rscmSelEntBeforeComm='Entities must be selected before run the command'

{ Display message to user }
zcUI.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
```

---

## 11. BEST PRACTICES

1. **Always Check Selection Count First**: Before processing, verify that selected objects exist
2. **Use SelObjArray for Iteration**: It's optimized for selected objects, not all objects
3. **Handle Empty Selection**: Provide clear message: "Entities must be selected before run the command"
4. **Clean Up Resources**: Free allocated memory in CommandCancel
5. **Update UI After Changes**: Call `zcRedrawCurrentDrawing` after modifying selections
6. **Use Undo Markers**: Wrap modifications with `PushStartMarker` and `PushEndMarker`
7. **Set Correct Command Attributes**: Use `CASelEnts` flag and appropriate `CEndActionAttr`

---

## 12. RELATED FILES FOR REFERENCE

Key files implementing selection patterns:

1. `/tmp/gh-issue-solver-1761647622010/cad_source/zengine/containers/UGDBSelectedObjArray.pas`
   - Core selection array implementation

2. `/tmp/gh-issue-solver-1761647622010/cad_source/zcad/commands/uzccommand_erase.pas`
   - Erase command - processes all selected objects and removes them

3. `/tmp/gh-issue-solver-1761647622010/cad_source/zcad/commands/uzccommand_move.pas`
   - Move command - collects selected objects and moves them together

4. `/tmp/gh-issue-solver-1761647622010/cad_source/zcad/commands/uzccommand_copy.pas`
   - Copy command - duplicates selected objects

5. `/tmp/gh-issue-solver-1761647622010/cad_source/zcad/commands/uzccommand_duplicate.pas`
   - Duplicate command - duplicates with auto-calculated offset

6. `/tmp/gh-issue-solver-1761647622010/cad_source/zcad/commands/uzccommand_inverseselected.pas`
   - Inverse selection - inverts the selection state

7. `/tmp/gh-issue-solver-1761647622010/cad_source/zcad/commands/uzccommand_deselectall.pas`
   - Deselect all - clears all selection

8. `/tmp/gh-issue-solver-1761647622010/cad_source/zcad/commands/uzccommand_matchprop.pas`
   - Match properties - shows how to request entities one at a time with getentity()

9. `/tmp/gh-issue-solver-1761647622010/cad_source/zcad/commands/uzccommandsimpl.pas`
   - Base command implementation classes

10. `/tmp/gh-issue-solver-1761647622010/cad_source/zcad/uzcstrconsts.pas`
    - All string constants for messages

unit callstack_mem_dump;
{$mode objfpc}{$H+}

interface

uses
  SysUtils, Generics.Collections
  ,Forms, Controls
  ,laz.VirtualTrees
  ,uzccommandsabstract
  ,lnfodwrf
  ;

function dumptofile(const Context:TZCADCommandContext; Operands:TCommandOperands):TCommandResult;
procedure RestoreMemoryManager; inline;

implementation

type
  PCodePointer = ^TCodePointer;
  TCodePointer = record
    cp: CodePointer;
    next: array of TCodePointer;
    data: Pointer;
    cnt: SizeUInt;
  end;
  PCodePointerArray = ^TCodePointerArray;
  TCodePointerArray = array of TCodePointer;
  TStackTree = record
    name: String;
    stack_tree: TCodePointerArray;
  end;
  PStackTreeArray = ^TStackTreeArray;
  TStackTreeArray = array of TStackTree;
  Tupdate_data_proc = procedure (var data: pointer; args: array of const);

  PNodeData = ^TNodeData;
  TNodeData = record
    addr: CodePointer;
    cnt: Integer;
    data: Pointer;
    name: String;
  end;

  TMemUsageMonitor = class(specialize TDictionary<Pointer, PtrUInt>)
    function ChangePtrMemSize(p:pointer;Size:ptruint;p_new:pointer):PtrInt;
  end;

  TEventsHandler = class
    procedure VTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;TextType: TVSTTextType; var CellText: AnsiString);
  end;

const
  skip_memusage_frames = 3;


var
  root_stack: TStackTreeArray = nil;
  root_mem: TStackTreeArray = nil;
  mem_monitor: TMemUsageMonitor = nil;
  NewMM, OldMM: TMemoryManager;

procedure collect_callstack(const name: String; args: array of const; update_proc: Tupdate_data_proc = nil; skip_frames: integer = 2; skip_bottom_frames: integer=0);
var
  i: longint = 0;
  i2: longint = 0;
  count: longint = 0;
  frames: array [0..255] of codepointer;
  list: PCodePointerArray = nil;
  pcp: PCodePointer;
  found: boolean;
  root: PStackTreeArray = nil;
begin
  count:=CaptureBacktrace(skip_frames,255,@frames[0]);

  found:=false;
  root := @root_stack;
  for i:=high(root^) downto low(root^) do
  begin
    found := root^[i].name = name;
    if found then
    begin
      list:=@root^[i].stack_tree;
      Break;
    end;
  end;
  if not found then
  begin
    SetLength(root^, Length(root^)+1);
    root^[high(root^)].name:=name;
    list:=@root^[high(root^)].stack_tree;
  end;

  for i:=count-1-skip_bottom_frames downto 0 do
  begin
    found:=false;
    for i2:=low(list^) to high(list^) do
    begin
      pcp:=@list^[i2];
      found := pcp^.cp=frames[i];
      if found then Break;
    end;
    if found then
    begin
      inc(pcp^.cnt);
    end else
    begin
      SetLength(list^, length(list^)+1);
      pcp:=@list^[high(list^)];
      pcp^.cp:=frames[i];
      pcp^.cnt:=1;
      pcp^.data:=nil;
    end;
    if Assigned(update_proc) then update_proc(pcp^.data, args);
    list:=@pcp^.next;
  end;
end;

procedure update_ptr_memusage(var data: pointer; args: array of const); inline;
begin
  PtrUInt(data)+=args[0].VInt64^;
end;

procedure collect_memusage(const name: String; mem_size:PtrInt; skip_frames: integer=2; skip_bottom_frames: integer=0); inline;
begin
  collect_callstack({name}'MemUsage', [mem_size], @update_ptr_memusage, skip_frames, skip_bottom_frames);
end;

function NewGetMem(Size:ptruint):Pointer;
begin
  Result := OldMM.GetMem(Size);

  SetMemoryManager(OldMM);
  collect_memusage('NewGetMem', mem_monitor.ChangePtrMemSize(nil, Size, Result), skip_memusage_frames);
  //collect_callstack('NewGetMem',[]);
  SetMemoryManager(NewMM);
end;
function NewFreeMem(p:pointer):ptruint;
begin
  Result := OldMM.FreeMem(p);

  SetMemoryManager(OldMM);
  collect_memusage('NewFreeMem', mem_monitor.ChangePtrMemSize(p, 0, nil), skip_memusage_frames);
  //collect_callstack('NewFreeMem',[]);
  SetMemoryManager(NewMM);
end;
function NewFreeMemSize(p:pointer;Size:ptruint):ptruint;
begin
  Result := OldMM.FreeMemSize(p,Size);

  SetMemoryManager(OldMM);
  collect_memusage('NewFreeMemSize', mem_monitor.ChangePtrMemSize(p, 0, nil), skip_memusage_frames);
  //collect_callstack('NewFreeMemSize',[]);
  SetMemoryManager(NewMM);
end;
function NewAllocMem(Size:ptruint):pointer;
begin
  Result := OldMM.AllocMem(size);

  SetMemoryManager(OldMM);
  collect_memusage('NewAllocMem', mem_monitor.ChangePtrMemSize(nil, Size, Result), skip_memusage_frames);
  //collect_callstack('NewAllocMem',[]);
  SetMemoryManager(NewMM);
end;
function NewReAllocMem(var p:pointer;Size:ptruint):pointer;
var
  old_p:pointer;
begin
  old_p:=p;
  Result := OldMM.ReAllocMem(p,size);

  SetMemoryManager(OldMM);

  collect_memusage('NewReallocMem', mem_monitor.ChangePtrMemSize(old_p, Size, Result), skip_memusage_frames);

  //collect_callstack('NewReallocMem',[]);
  SetMemoryManager(NewMM);
end;

procedure ReplaceMemoryManager;
begin
  mem_monitor:=TMemUsageMonitor.Create;

  GetMemoryManager(OldMM);
  NewMM:=OldMM;

  NewMM.Getmem:=@NewGetMem;
  NewMM.Freemem:=@NewFreeMem;
  NewMM.FreememSize:=@NewFreeMemSize;
  NewMM.AllocMem:=@NewAllocMem;
  NewMM.ReAllocMem:=@NewReAllocMem;

  SetMemoryManager(NewMM);
end;
procedure RestoreMemoryManager; inline;
begin
  SetMemoryManager(OldMM);
  mem_monitor.Free;
end;

// Copy from unit "lnfodwrf"
{$push}
{$H-}
function MyDwarfBackTraceStr(addr: CodePointer): shortstring;
var
  hs,
  source  : shortstring;
  line    : longint;
  Store   : TBackTraceStrFunc;
  Success : boolean;
begin
  Success:=false;
  Store := BackTraceStrFunc;
  BackTraceStrFunc := @SysBackTraceStr;
  Success:=GetLineInfo(codeptruint(addr), result, source, line);

  if Success then
  begin
    if source<>'' then
    begin
      if line<>0 then
      begin
        str(line, hs);
        Result:=Result + ' line ' + hs + ' of ' + source;
      end else
      begin
        Result:=Result + ' of ' + source;
      end;
    end;
  end;
  BackTraceStrFunc := Store;
end;
{$pop}

procedure TEventsHandler.VTGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: AnsiString);
var
  pnd: PNodeData;
begin
  pnd:=PPointer(Sender.GetNodeData(Node))^;
  if not Assigned(pnd) then
  begin
    CellText:='nil';
    Exit;
  end;
  case Column of
    0: CellText:=IntToHex(PtrUInt(pnd^.addr)).TrimLeft('0');
    1: CellText:=IntToStr(pnd^.cnt);
    2: CellText:=IntToStr(PtrInt(pnd^.data));
    3: begin
      if pnd^.name='' then pnd^.name:=MyDwarfBackTraceStr(pnd^.addr);
      CellText:=pnd^.name;
    end;
    else CellText:='huh?';
  end;
end;

function TMemUsageMonitor.ChangePtrMemSize(p: pointer; Size: PtrUInt;
  p_new: pointer): PtrInt;
begin
  if Assigned(p) and (Size=0) then
  begin
    if ContainsKey(p) then
    begin
      Result := -Items[p];
      Remove(p);
    end else
    begin
      Result:=0;
    end;

    Exit;
  end
  else if not Assigned(p) and (Size<>0) then
  begin
    AddOrSetValue(p_new, Size);

    Exit(Size);
  end;

  Result:=Size;
  if p<>p_new then
  begin
    if ContainsKey(p) then
    begin
      Result := Result - Items[p];
      Remove(p);
    end;

    Add(p_new, Size);
  end else
  begin
    if ContainsKey(p) then
    begin
      Result := Result - Items[p];
    end;

    AddOrSetValue(p, Size);
  end;
end;



function dumptofile(const Context:TZCADCommandContext; Operands:TCommandOperands):TCommandResult;
var
  vt: TLazVirtualStringTree;
  i,ii: Integer;
  pn: PVirtualNode;
  f: TForm;
  pnd: PNodeData;
  stack: array of record
    val: PCodePointerArray;
    pvn: PVirtualNode;
  end = nil;
  pstack_arr: PCodePointerArray;
  EventsHandler: TEventsHandler;

procedure push(const val:PCodePointerArray; const pvn: PVirtualNode);inline;
begin
  //Generics.Collections.TStack;
  SetLength(stack, Length(stack)+1);
  stack[High(stack)].val:=val;
  stack[High(stack)].pvn:=pvn;
end;
procedure pop(out val:PCodePointerArray; out pvn: PVirtualNode);inline;
begin
  val:=stack[High(stack)].val;
  pvn:=stack[High(stack)].pvn;
  SetLength(stack, Length(stack)-1);
end;

begin
  f:=TForm.Create(nil);
  EventsHandler:=TEventsHandler.Create;
  vt:=TLazVirtualStringTree.Create(f);
  vt.NodeDataSize:=SizeOf(Pointer);
  vt.TreeOptions.SelectionOptions:=vt.TreeOptions.SelectionOptions+[toFullRowSelect];
  vt.Header.Columns.Add.Text:='addr';
  vt.Header.Columns.Add.Text:='cnt';
  vt.Header.Columns.Add.Text:='mem';
  vt.Header.Columns.Add.Text:='name';
  vt.Header.Options:=vt.Header.Options+[hoVisible];
  vt.DefaultText:='';
  vt.Parent:=f;
  vt.Align:=alClient;
  vt.OnGetText:=@EventsHandler.VTGetText;
  f.Show;

  vt.BeginUpdate;
  for i:=Low(root_stack) to High(root_stack) do
  begin
    New(pnd);
    pnd^.cnt:=0;
    pnd^.addr:=nil;
    pnd^.data:=nil;
    pnd^.name:=root_stack[i].name;
    pn:=vt.AddChild(nil, pnd);

    push(@root_stack[i].stack_tree, pn);

    while Length(stack)>0 do
    begin
      pop(pstack_arr, pn);

      for ii:=Low(pstack_arr^) to High(pstack_arr^) do
      begin
        New(pnd);
        pnd^.cnt:=pstack_arr^[ii].cnt;
        pnd^.addr:=pstack_arr^[ii].cp;
        pnd^.data:=pstack_arr^[ii].data;
        pnd^.name:='';

        if Length(pstack_arr^[ii].next)>0 then
        begin
          push(@pstack_arr^[ii].next, vt.AddChild(pn, pnd));
        end else
        begin
          vt.AddChild(pn, pnd);
        end;
      end;
    end;
  end;
  vt.EndUpdate;

  result:=cmd_ok;
  EventsHandler.Free;
end;

initialization
  ReplaceMemoryManager;
end.


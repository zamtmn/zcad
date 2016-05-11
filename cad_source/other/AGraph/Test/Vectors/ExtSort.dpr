program ExtSort;
{ external sort demo }

uses
  ExtType,
  {$IFDEF WIN32}Windows,{$ENDIF}
  SysUtils,
  ExtSys,
  Aliasv,
  Boolv,
  Pointerv,
  StrLst,
  SIQueue,
  VTxtStrm;

{$APPTYPE CONSOLE}

procedure Main;
var
  I, MemoryLimit, MemoryOccupied, BlockCount: Integer;
  IgnoreCase: Bool;
  P: Pointer;
  T1, TempDirectory, TempFileName: String;
  InStream, OutStream, TempStream: TTextStream;
  Bookmarks, ReadStreams: TClassList;
  HaveString: TBoolVector;
  LinesInBlock: TIntegerVector;
  S: TStrLst;
  SIQueue: TStrIndexedQueue;
begin
  { using up to Max(1/2 of free memory size, 1/4 of total memory size) }
  MemoryLimit:=PhysicalMemoryFree div 2;
  I:=PhysicalMemorySize div 4;
  if MemoryLimit < I then MemoryLimit:=I;
  writeln('MemoryLimit: ', MemoryLimit);
  InStream:=TTextStream.Create(ParamStr(1), tsRead);
  OutStream:=nil;
  S:=nil;
  try
    OutStream:=TTextStream.Create(ParamStr(2), tsRewrite);
    write('Reading...');
    IgnoreCase:=ParamCount > 2;
    if IgnoreCase then
      S:=TStrLst.Create
    else
      S:=TCaseSensStrLst.Create;
    { ignore reference-counting implementation of AnsiString in Delphi }
    MemoryOccupied:=0;
    while (MemoryOccupied <= MemoryLimit) and not InStream.EOF do begin
      T1:=InStream.ReadString;
      S.Add(T1);
      Inc(MemoryOccupied, Length(T1));
    end;
    writeln;
    write('Sorting...');
    S.Sort;
    if InStream.EOF then begin
      writeln;
      write('Writing...');
      S.WriteToTextStream(OutStream);
    end
    else begin
      Bookmarks:=TClassList.Create;
      LinesInBlock:=TIntegerVector.Create(0, 0);
      try
        { create temporary file }
        {$IFDEF WIN32}
        SetLength(TempDirectory, MAX_PATH);
        I:=GetTempPath(Length(TempDirectory), PChar(TempDirectory));
        if I = 0 then raise Exception.Create('GetTempPath Error');
        SetLength(TempDirectory, I);
        SetLength(TempFileName, MAX_PATH);
        I:=GetTempFileName(PChar(TempDirectory), 'vsr', 0, PChar(TempFileName));
        if I = 0 then raise Exception.Create('GetTempFileName Error');
        SetLength(TempFileName, StrLen(PChar(TempFileName)));
        {$ELSE}
        TempFileName:='extsort.tmp';
        {$ENDIF}
        TempStream:=TTextStream.Create(TempFileName, tsRewrite);
        { read string blocks, sort them and write to temporary file  }
        try
          S.WriteToTextStream(TempStream);
          LinesInBlock.Add(S.Count);
          S.Clear;
          repeat
            Bookmarks.Add(TempStream.CreateBookmark);
            MemoryOccupied:=0;
            repeat
              T1:=InStream.ReadString;
              S.Add(T1);
              Inc(MemoryOccupied, Length(T1));
            until (MemoryOccupied >= MemoryLimit) or InStream.EOF;
            S.Sort;
            S.WriteToTextStream(TempStream);
            LinesInBlock.Add(S.Count);
            S.Clear;
          until InStream.EOF;
          P:=InStream;
          InStream:=nil;
          TObject(P).Free;
        finally
          TempStream.Free;
        end;
        writeln(LinesInBlock.Count, ' blocks');
        { merge sort }
        BlockCount:=Bookmarks.Count;
        ReadStreams:=TClassList.Create;
        try
          ReadStreams.Add(TTextStream.Create(TempFileName, tsRead));
          for I:=0 to BlockCount - 1 do begin
            TempStream:=TTextStream.Create(TempFileName, tsRead);
            TempStream.GotoBookmark(Bookmarks[I]);
            ReadStreams.Add(TempStream);
          end;
          Inc(BlockCount);
          HaveString:=TBoolVector.Create(BlockCount, False);
          SIQueue:=nil;
          try
            if IgnoreCase then
              SIQueue:=TStrIndexedQueue.Create
            else
              SIQueue:=TCaseSensStrIndexedQueue.Create;
            repeat
              for I:=0 to BlockCount - 1 do
                if not (HaveString[I] or (LinesInBlock[I] = 0)) then begin
                  SIQueue.Add(TTextStream(ReadStreams[I]).ReadString, I);
                  HaveString[I]:=True;
                  LinesInBlock.DecItem(I, 1);
                end;
              if SIQueue.IsEmpty then Break;
              OutStream.WriteString(SIQueue.DeleteMin(I));
              HaveString[I]:=False;
            until False;
          finally
            HaveString.Free;
            SIQueue.Free;
          end;
        finally
          ReadStreams.FreeItems;
          ReadStreams.Free;
        end;
        if not DeleteFile(TempFileName) then
          raise Exception.CreateFmt('Can''t delete file "%s"', [TempFileName]);
      finally
        Bookmarks.FreeItems;
        Bookmarks.Free;
        LinesInBlock.Free;
      end;
    end;
    writeln('done');
  finally
    S.Free;
    InStream.Free;
    OutStream.Free;
  end;
end;

begin
  if ParamCount > 1 then begin
    {$IFNDEF FPC}{$IFDEF WIN32}FreeLibrary(GetModuleHandle('OleAut32'));{$ENDIF}{$ENDIF}
    Main;
  end
  else
    writeln('Usage: ExtSort <from_file> <to_file> [/i]'^M^J +
            ' /i - ignore case');
end.

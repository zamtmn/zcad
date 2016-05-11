program TestMMappedStream;

uses
  SysUtils, ExtType, ExtSys, VStream, VFStream, VMapStrm, VectProc, VFstTmr;

{$APPTYPE CONSOLE}

procedure Test;
const
  Count = 256 * 1024 * 50;
  FileName1 = 'TestMMapedStream1.dat';
  FileName2 = 'TestMMapedStream2.dat';
var
  I, N, OldPos: Integer;
  Tmr: TVFastTimer;
  Strm1, Strm2: TVStream;
  Buf1, Buf2: array [0..65535] of Int32;
begin
  writeln('You should have ', Count div 131072, ' Mb of free space on the current logical disk');
  Tmr:=TVFastTimer.Create;
  try
    write('Creating file with ', Count, ' integers from 0 to ', Count - 1, '... ');
    Tmr.Start;
    Strm1:=TVBufFileStream.Create(FileName1, fmCreate);
    try
      for I:=0 to Count - 1 do
        Strm1.WriteInt32(I);
    finally
      Strm1.Free;
    end;
    Tmr.Report;
    write('Creating file with ', Count, ' integers from ', Count, ' to 1... ');
    Tmr.Start;
    Strm1:=TVBufFileStream.Create(FileName2, fmCreate);
    try
      for I:=Count downto 1 do
        Strm1.WriteInt32(I);
    finally
      Strm1.Free;
    end;
    Tmr.Report;
    write('Adding file 2 to file 1 using memory-mapped streams... ');
    Tmr.Start;
    Strm1:=TVMemoryMappedStream.Create(FileName1, '1', fmOpenReadWrite);
    Strm2:=nil;
    try
      Strm2:=TVMemoryMappedStream.Create(FileName2, '2', fmOpenRead);
      AddInt32Proc(TVMemoryMappedStream(Strm1).Memory^,
        TVMemoryMappedStream(Strm2).Memory^, Count);
    finally
      Strm1.Free;
      Strm2.Free;
    end;
    Tmr.Report;
    write('Adding file 1 to file 2 using regular streams... ');
    Tmr.Start;
    Strm1:=TVFileStream.Create(FileName1, fmOpenRead);
    Strm2:=nil;
    try
      Strm2:=TVFileStream.Create(FileName2, fmOpenReadWrite);
      while not Strm1.EOF do begin
        OldPos:=Strm2.Position;
        I:=Strm1.ReadFunc(Buf1, SizeOf(Buf1));
        Strm2.ReadProc(Buf2, I);
        AddInt32Proc(Buf2, Buf1, I div 4);
        Strm2.Seek(OldPos);
        Strm2.WriteProc(Buf2, I);
      end;
    finally
      Strm1.Free;
      Strm2.Free;
    end;
    Tmr.Report;
    write('Count elements in the file 1 using memory-mapped stream... ');
    Tmr.Start;
    Strm1:=TVMemoryMappedStream.Create(FileName1, '1', fmOpenRead);
    try
      N:=CountEqualToValue32(TVMemoryMappedStream(Strm1).Memory^, Count, Count);
    finally
      Strm1.Free;
    end;
    Tmr.Report;
    if N <> Count then begin
      writeln('Error');
      Exit;
    end;
    write('Count elements in the file 1 using buffered stream... ');
    Tmr.Start;
    Strm1:=TVBufFileStream.Create(FileName1, fmOpenRead);
    try
      N:=0;
      for I:=1 to Count do
        if Strm1.ReadInt32 = Count then Inc(N);
    finally
      Strm1.Free;
    end;
    Tmr.Report;
    if N <> Count then begin
      writeln('Error');
      Exit;
    end;
  finally
    Tmr.Free;
  end;
  DeleteFile(FileName1);
  DeleteFile(FileName2);
end;

begin
  Test;
  write('Press Return to continue...');
  readln;
end.


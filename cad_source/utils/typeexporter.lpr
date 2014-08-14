{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev)
}

program typeexporter;
{$APPTYPE CONSOLE}
{$INCLUDE def.inc}
 uses
  SysUtils,iolow,classes,gdbasetypes;

const IgnoreSHP=#13;
      BreakSHP=#10;
      starttoken='{EXPORT+}';
      endtoken='{EXPORT-}';
      objregtoken='{REGISTEROBJECTTYPE ';
var
   outhandle,registerhandle,registerfnhandle:cardinal;
   FileName:pstring;
   FileNames:TStringList;
   error:boolean;
   ir:itrec;
   i:integer;
function createoutfile(name:string):cardinal;
var filehandle:cardinal;
begin
  filehandle:=0;
  filehandle := FileCreate(name);
  result:=filehandle;
end;
function closeoutfile(filehandle:cardinal):cardinal;
begin
  fileclose(filehandle);
end;
procedure writestring(h: integer; s: string);
begin
  if s='//Generate on E:\zcad\CAD_SOURCE\gdb\GDBtext.pas' then
               s:=s;
  s := s + eol;
  FileWrite(h,s[1],length(s));
end;
procedure processfile(name:string;handle:cardinal);
var f:filestream;
    line,lineend:string;
    expblock:integer;
    find,find2,find3:integer;
begin
  expblock:=0;
  f.init(10000);
  f.assign(name,fmShareDenyNone);
  line:='';
  lineend:='';
  line:=f.readgdbstring;
  while f.filesize<>f.currentpos do
    begin
         if (pos('PROCEDURE',uppercase(line))<=0)and
            (pos('FUNCTION',uppercase(line))<=0)and
            (pos('CONSTRUCTOR',uppercase(line))<=0)and
            (pos('DESTRUCTOR',uppercase(line))<=0) then
         begin
         find:=pos(starttoken,uppercase(line));
         if find>0 then
                       begin
                            find:=find+length(starttoken);
                            inc(expblock);
                            line:=copy(line,find,length(line)-find+1);
                       end;
         find:=pos(endtoken,uppercase(line));
         if find>0 then
                       begin
                            DEC(expblock);
                            lineend:=copy(line,1,find-1);
                       end;
         if (lineend<>'') then writestring(handle,lineend);
         lineend:='';
         if (expblock>0)and(line<>'') then
         begin
              //{-}PGDBObjVisible{/pointer/}
              find:=pos('{-}',line);
              if find>0 then
              begin
                   find2:=pos('{/',line);
                   find3:=pos('/}',line);
                   if (find2>find)and(find3>find2) then
                   begin
                        line:=copy(line,1,find-1)+copy(line,find2+2,find3-find2-2)+copy(line,find3+2,length(line)-find3+2);
                   end;

              end;
              writestring(handle,line);
         end;
         end;
         line:=f.readgdbstring;
         {fileclose(handle);
         handle:=FileOpen('C:\CAD\components\type\GDBObjectsdef.pas', fmOpenWrite);
         FileSeek(handle,0,2);}
    end;
    f.close;
    f.done;
end;
procedure processfileabstract(name:string;handle,rh,registerfnhandle:cardinal);
var f:filestream;
    line,lineend,fn:string;
    expblock:integer;
    find,find2,find3:integer;
    inobj,alreadyinuses:boolean;
begin
  alreadyinuses:=false;
  writestring(handle,'//Generate on '+name);
  expblock:=0;
  f.init(10000);
  f.assign(name,fmShareDenyNone);
  write('Process file: ',f.name);
  if f.filesize<>-1 then
  begin
  line:='';
  lineend:='';
  line:=f.readgdbstring;
  inobj:=false;
  while f.filesize<>f.currentpos do
    begin
         find:=pos(objregtoken,uppercase(line));
         if find>0 then
                       begin
                            find:=find+length(objregtoken);
                            line:=copy(line,find,length(line)-find);
                            writestring(rh,'     pt:=SysUnit.ObjectTypeName2PTD('''+line+''');');
                            writestring(rh,'     pt^.RegisterVMT(TypeOf('+line+'));');
                            if not alreadyinuses then
                                                 begin
                                                      fn:=ExtractFileName(name);
                                                      fn:=copy(fn,1,pos('.',fn)-1);
                                                      writestring(registerfnhandle,','+fn);
                                                 end;
                            alreadyinuses:=true;
                       end;
         find:=pos('OBJECT',uppercase(line));
         if find>0 then inobj:=true;
         find:=pos('END;',uppercase(line));
         if inobj and (find>0) then inobj:=false;
         begin
         find:=pos(starttoken,uppercase(line));
         if find>0 then
                       begin
                            find:=find+length(starttoken);
                            inc(expblock);
                            line:=copy(line,find,length(line)-find+1);
                       end;
         find:=pos(endtoken,uppercase(line));
         if find>0 then
                       begin
                            DEC(expblock);
                            lineend:=copy(line,1,find-1);
                       end;
         if (lineend<>'') then writestring(handle,lineend);
         lineend:='';
         if (expblock>0)and(line<>'') then
         begin
              //{-}PGDBObjVisible{/pointer/}
              find:=pos('{-}',line);
              if find>0 then
              begin
                   find2:=pos('{/',line);
                   find3:=pos('/}',line);
                   if (find2>find)and(find3>find2) then
                   begin
                        line:=copy(line,1,find-1)+copy(line,find2+2,find3-find2-2)+copy(line,find3+2,length(line)-find3+2);
                   end;

              end;
         if (pos('VIRTUAL',uppercase(line))>0) then
         begin
              if (pos('ABSTRACT',uppercase(line))<=0) then
                                                          line:=line+'abstract;';
              writestring(handle,line);
         end
         else if {((pos('PROCEDURE',uppercase(line))<=0)and
            (pos('FUNCTION',uppercase(line))<=0)and
            (pos('CONSTRUCTOR',uppercase(line))<=0)and
            (pos('DESTRUCTOR',uppercase(line))<=0))} true and inobj then writestring(handle,line)
            else  if not inobj then writestring(handle,line);
         end;
         end;
         line:=f.readgdbstring;


         {fileclose(handle);
         handle:=FileOpen('C:\CAD\components\type\GDBObjectsdef.pas', fmOpenWrite);
         FileSeek(handle,0,2);}
    end;

    writeln('...OK');
  end
  else
      begin
           writeln('...ERROR! Source file not found');
           error:=true;
      end;
    f.close;
    f.done;
{$R *.res}


end;
begin
     error:=false;
     outhandle:=createoutfile('E:\zcad\CAD\rtl\system.tmp');
     registerhandle:=createoutfile('E:\zcad\CAD_SOURCE\LANGUADE\RegCnownTypes.pas');
     registerfnhandle:=createoutfile('E:\zcad\CAD_SOURCE\LANGUADE\RFN.pas');

     writestring(outhandle,'unit System;');
     writestring(outhandle,'{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}');
     writestring(outhandle,'interface');
     writestring(outhandle,'type');

     writestring(registerhandle,'unit RegCnownTypes;');
     writestring(registerhandle,'{$INCLUDE def.inc}');
     writestring(registerhandle,'{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}');
     writestring(registerhandle,'interface');
     writestring(registerhandle,'procedure RegTypes;');
     writestring(registerhandle,'implementation');
     writestring(registerhandle,'uses URecordDescriptor,UObjectDescriptor,Varman,gdbase {$INCLUDE RFN.pas};');
     writestring(registerhandle,'procedure RegTypes;');
     writestring(registerhandle,'var');
     writestring(registerhandle,'pt:PObjectDescriptor;');
     writestring(registerhandle,'begin');
     writestring(registerhandle,'if assigned(SysUnit) then begin');

     FileNames:=TStringList.create;
     FileNames.loadfromfile(ExtractFilePath(paramstr(0))+'filelist.txt');
     for i:=0 to FileNames.Count-1 do
        processfileabstract(FileNames.ValueFromIndex[i],outhandle,registerhandle,registerfnhandle);


     {FileNames.init(1000);
     FileNames.loadfromfile('filelist.txt');
     FileName:=nil;
     FileName:=FileNames.beginiterate(ir);
     if FileName<>nil then
     repeat
        processfileabstract(FileName^,outhandle,registerhandle,registerfnhandle);
        FileName:=FileNames.iterate(ir);
     until FileName=nil;}
     writestring(registerhandle,'end;');
     writestring(outhandle,'implementation');
     writestring(outhandle,'begin');
     writestring(outhandle,'end.');
     closeoutfile(outhandle);
     writestring(registerhandle,'end;');
     writestring(registerhandle,'end.');
     closeoutfile(registerhandle);
     closeoutfile(registerfnhandle);

     if error then
                  begin
                       writeln;
                       writeln('Errors found. File "rtl\system.pas" not created!')
                  end
              else
                  begin
                       DeleteFile('E:\zcad\CAD\rtl\system.pas');
                       RenameFile('E:\zcad\CAD\rtl\system.tmp','E:\zcad\CAD\rtl\system.pas');
                       DeleteFile('E:\zcad\CAD\rtl\system.tmp');
                  end
end.



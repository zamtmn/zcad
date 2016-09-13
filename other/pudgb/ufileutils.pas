unit ufileutils;

{$mode objfpc}{$H+}

interface
uses
  LazUTF8,sysutils;
function GetPartOfPath(out part:String;var path:String;const separator:String):String;
function FindInSupportPath(PPaths:String;FileName:String):String;
implementation
function GetPartOfPath(out part:String;var path:String;const separator:String):String;
var
   i:Integer;
begin
           i:=pos(separator,path);
           if i<>0 then
                       begin
                            part:=copy(path,1,i-1);
                            path:=copy(path,i+1,length(path)-i);
                       end
                   else
                       begin
                            part:=path;
                            path:='';
                       end;
     result:=part;
end;
function FindInSupportPath(PPaths:String;FileName:String):String;
var
   s,ts:string;
begin
     if FileExists(utf8tosys(FileName)) then
                                 begin
                                      result:=FileName;
                                      exit;
                                 end;
     begin
     s:=PPaths;
     repeat
           GetPartOfPath(ts,s,';');
           ts:=ts+FileName;
           if FileExists(utf8tosys(ts)) then
                                 begin
                                      result:=ts;
                                      exit;
                                 end;
     until s='';
     end;
     result:='';
end;
end.


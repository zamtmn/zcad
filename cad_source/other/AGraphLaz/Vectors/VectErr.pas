{ Version 050604. Copyright (c) Alexey A.Chernobaev, 1996-2005 }

unit VectErr;

interface

{$I VCheck.inc}

uses
  SysUtils;

const
  SAlgorithmFailure = 'Algorithm failure';
  SAssignError = 'Assign error';
  SBOF = 'BOF reached';
  SCanNotConvertToFloat_s = 'Can''t convert ''%s'' to float';
  SCanNotConvertToInteger_s = 'Can''t convert ''%s'' to integer';
  SCanNotRollBack = 'Can''t roll back';
  SCrcError = 'CRC error';
  SCreateMappingError_sd = 'Error creating file mapping object "%s" (%d)';
  SDataTooLarge_d = 'Data too large (%d)';
  SDiskFull = 'Disk full';
  SDuplicateError = 'Duplicate values not allowed';
  SEmptyQueue = 'Queue is empty';
  SEmptyStack = 'Stack is empty';
  SEOF = 'Unexpected end of file';
  SErrorInParameters = 'Error in parameters';
  SFlushError = 'Flush error';
  SGetSizeError = 'Get size error';
  SIllegalBool = 'Illegal boolean ''%s''';
  SIllegalChar = 'Illegal character ''%s''';
  SIllegalDateTime = 'Illegal date/time ''%s''';
  SIllegalUseOfCrcStream = 'Illegal use of CRC stream';
  SIncompatibleClasses = 'Incompatible classes';
  SInsufficientMemory = 'Insufficient memory';
  SInternalError = 'Internal error';
  SKeyNotFound_s = 'Key ''%s'' not found';
  SKeyNotFound_d = 'Key ''%d'' not found';
  SMethodNotApplicable = 'Method not applicable';
  SNoCurrentValue = 'No current value';
  SNotImplemented = 'Method not implemented';
  SOpenMappingError_sd = 'Error opening file mapping object "%s" (%d)';
  SRangeError_d = 'Range check error (%d)';
  SReadAfterEnd = 'Read after end error';
  SReadError = 'Read error';
  SSeekError_d = 'Seek error (%d)';
  SSetSizeError = 'Set size error';
  SStreamCorrupted = 'Stream is corrupted';
  SStreamError = 'Stream error';
  STooManyValues = 'Too many values';
  SValueExpected = 'Value expected';
  SWriteError = 'Write error';
  SWrongMatrixSize = 'Wrong matrix size';
  SWrongVectorSize_d = 'Wrong vector size (%d)';

  CException = 50;

  SFileGeneralError = 'File error';
  SFileGeneralError_s = 'Error processing "%s"';
  CFileGeneralError = 150;

  SFileCreateError = 'File create error';
  SFileCreateError_s = 'Can''t create file "%s"';
  CFileCreateError = 151;

  SFileDeleteError = 'File delete error';
  SFileDeleteError_s = 'Can''t delete file "%s"';
  CFileDeleteError = 152;

  SFileGetSizeError = 'Get file size error';
  CFileGetSizeError = 153;

  SFileFindError = 'Can''t find file';
  SFileFindError_s = 'Can''t find file "%s"';
  CFileFindError = 154;

  SFileMappingError_sd = 'Error mapping file "%s" (%d)';
  CFileMappingError = 155;

  SFileOpenError = 'File open error';
  SFileOpenError_s = 'Can''t open file "%s"';
  CFileOpenError = 156;

  SFileReadError = 'File read error';
  SFileReadError_s = 'Error reading file "%s"';
  CFileReadError = 157;

  SFileSeekError_d = 'File seek error (%d)';
  SFileSeekError_s = 'Error seeking in file "%s"';
  CFileSeekError = 158;

  SFileSetSizeError = 'Set file size error';
  CFileSetSizeError = 159;

  SFileTooLarge = 'File is too large (>= 2Gb)';
  SFileTooLarge_s = 'File "%s" is too large (>= 2Gb)';
  CFileTooLarge = 160;

  SFileWriteError = 'File write error';
  SFileWriteError_s = 'Error writing file "%s"';
  CFileWriteError = 161;

  SPathFindError = 'Path not found';
  SPathFindError_s = 'Path "%s" not found';
  CPathFindError = 162;

  SFileCopyError = 'File copy error';
  SFileCopyError_ss = 'Error copying file "%s" to "%s"';
  CFileCopyError = 163;

  SFileCanNotCopyToItself = 'Can''t copy file to itself';
  SFileCanNotCopyToItself_s = 'Can''t copy file "%s" to itself';
  CFileCanNotCopyToItself = 164;

  SDirCreateError = 'Folder create error';
  SDirCreateError_s = 'Can''t create folder "%s"';
  CDirCreateError = 165;

  SFileAlreadyExistsError = 'File exists already';
  SFileAlreadyExistsError_s = 'File "%s" exists already';
  CFileAlreadyExistsError = 166;

  SFileCreateErrorDirExists = 'Can''t create file: a folder with the same ' +
    'name exists already';
  SFileCreateErrorDirExists_s = 'Can''t create file: folder with name "%s" ' +
    'exists already';
  CFileCreateErrorDirExists = 167;

  SFileNotSupported = 'File is damaged or not supported';
  SFileNotSupported_s = 'File "%s" is damaged or not supported';
  CFileNotSupported = 168;

function ErrMsg(const Msg: String; const Data: array of const): String;

{$IFDEF V_32}
function FormatFileError(const FileName, SimpleMessage: String;
  Code, LastOSError: Integer): String;
{$ENDIF}

implementation

function ErrMsg(const Msg: String; const Data: array of const): String;
begin
  Result:=Msg;
  if Pos('%', Result) > 0 then
    Result:=Format(Result, Data);
end;

{$IFDEF V_32}
function FormatFileError(const FileName, SimpleMessage: String;
  Code, LastOSError: Integer): String;
var
  Msg: String;
begin
  {$IFNDEF V_AUTOINITSTRINGS}
  Msg:='';
  {$ENDIF}
  Case Code of
    CFileCreateError: Msg:=SFileCreateError_s;
    CFileDeleteError: Msg:=SFileDeleteError_s;
    CFileFindError: begin
      Msg:=SFileFindError_s;
      if LastOSError = 2 then { to prevent tautology }
        LastOSError:=0;
    end;
    CFileOpenError: Msg:=SFileOpenError_s;
    CFileReadError: Msg:=SFileReadError_s;
    CFileSeekError: Msg:=SFileSeekError_s;
    CFileWriteError: Msg:=SFileWriteError_s;
    CPathFindError: Msg:=SPathFindError_s;
    CDirCreateError: Msg:=SDirCreateError_s;
    CFileAlreadyExistsError: Msg:=SFileAlreadyExistsError_s;
    CFileCreateErrorDirExists: Msg:=SFileCreateErrorDirExists_s;
  Else
    Result:=Format(SFileGeneralError_s, [FileName]);
    Msg:=SimpleMessage;
    if Msg <> '' then begin
      if Msg[1] in ['A'..'Z'] then
        Msg[1]:=Chr(Ord(Msg[1]) + (Ord('a') - Ord('A'))); { LoCase }
      Result:=Result + ': ' + Msg;
      Msg:='';
    end;
  End;
  if Msg <> '' then
    Result:=Format(Msg, [FileName]);
  if LastOSError <> 0 then
    Result:=Result + '. ' + SysErrorMessage(LastOSError);
end;
{$ENDIF}

end.

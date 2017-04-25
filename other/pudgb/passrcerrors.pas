	{$mode objfpc}
unit test;
interface
const
  Platform = {$if defined(cpu32)} 'x86'
             {$elseif defined(cpu64)} 'x64'
             {$else} {$error unknown platform} {$endif};

implementation
end.
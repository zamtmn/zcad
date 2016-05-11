{ Version 050603. Copyright © Alexey A.Chernobaev, 1996-2005 }

unit AttrErr;

interface

{$I VCheck.inc}

const
  SAttrAlreadyDefined_s = 'attribute ''%s'' already defined';
  SAttrNotDefined_s = 'attribute ''%s'' not defined';
  SAttrPrefixReserved = 'attribute prefix ''.'' reserved for internal use';
  SIndexAlreadyDefined_s = 'index ''%s'' already defined';
  SIndexNotDefined_s = 'index ''%s'' not defined';
  SWrongAttrType_s = 'attribute ''%s'' has different type';
  SWrongAttrName_s = 'wrong attribute name ''%s''';
  SWrongTextStreamFormat = 'Wrong text stream format';

implementation

end.

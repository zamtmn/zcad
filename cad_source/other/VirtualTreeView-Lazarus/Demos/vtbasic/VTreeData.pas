{***********************************************************************        }
{ File: VTreeData.pas                                                            }
{                                                                                }
{ Purpose:                                                                       }
{           source file to demonstrate how to get started with VT (5)            }
{           <--  Basic node data class wrapped in a record allowing for  -->     }
{                                                                                }
{ Credits:                                                                       }
{           taken + modified from example by Sven H. (h.sven@gmx.at)             }
{                                                                                }
{ Module Record:                                                                 }
{                                                                                }
{  Date        AP  Details                                                       }
{ --------     --  --------------------------------------                        }
{ 05-Nov-2002  TC  Created  (tomc@gripsystems.com)                               }
{**********************************************************************}
unit VTreeData;

{$mode delphi}
{$H+}

interface

   uses
      LCLIntf, Messages, SysUtils, Classes, Graphics, VirtualTrees;

   type
      // declare common node class
      TBasicNodeData = 
      class
         protected
         FCaption    : shortstring;
         FID         : longint;
         FImageIndex : longint;
         FHasChanged : boolean;
                                                               
         public
         constructor Create( const sCaption : shortstring; const iID, iIndex: longint);   
                  
         property Caption     : shortstring  read FCaption     write FCaption;
         property ID          : longint      read FID          write FID;
         property ImageIndex  : longint      read FImageIndex  write FImageIndex;
         property HasChanged  : boolean      read FHasChanged  write FHasChanged;
      end;             

      // declare descendant node class
      TBasicNodeAddData = 
      class(TBasicNodeData)
         protected
         FJobTitle   : shortstring;
         FAdd1       : shortstring;
         FAdd2       : shortstring;
         FAdd3       : shortstring;
                                                               
         public
         property Add1 : shortstring  read FAdd1 write FAdd1;
         property Add2 : shortstring  read FAdd2 write FAdd2;
         property Add3 : shortstring  read FAdd3 write FAdd3;
         property JobTitle    : shortstring  read FJobTitle    write FJobTitle;
      end;             
      
      (*--------------------------------------------------------------------------------------
      This is a very simple record we use to store data in the nodes.
      Since the application is responsible to manage all data including the node's caption
      this record can be considered as minimal requirement in all VT applications using this 
      method (as opposed to a pre-defined record). Note that this also means individual nodes 
      can store different descendants from TBasicNodeData
      --------------------------------------------------------------------------------------*)
      PBasicNodeRec= ^TBasicNodeRec;
      TBasicNodeRec = 
      record
         bnd : TBasicNodeData;
      end;

implementation

   constructor TBasicNodeData.Create( const sCaption : shortstring; const iID, iIndex: longint); 
   begin
      inherited Create;
      FCaption    := sCaption;
      FID         := iID;
      FImageIndex := iIndex;
   end;

end.

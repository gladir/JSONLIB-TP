{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2023
  @website(https://www.gladir.com/CODER/JSONLIB-TP)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Unit JSONExpo;

INTERFACE

Const
 errNoError=0;
 errCantCreateFile=-1;
 errCantOpenFile=-2;
 errCommandNotImplemented=-3;
 errCommandNotSupported=-4;
 errDataExpected=-5;
 errDataTypeExpected=-6;
 errIntoKeywordExpected=-7;
 errRecordTooBig=-8;
 errSeparatorExpected=-9;
 errStringWithoutTerminaison=-10;
 errTableNameExpected=-11;
 errTableKeywordExpected=-12;
 errUnknownCommand=-13;
 errUnknownDataType=-14;

Function GetErrorMessageImport(Err:Integer):String;
Function JSON2XML(SourceName,TargetName:String):Integer;

IMPLEMENTATION

Uses DOS;

Type
 FieldRec=Record
  FieldName:String[50];
  FieldType:Char;
  Spare1,Spare2:Integer;
  Width,Dec:Byte;
 End;

Function TrimL(S:String):String;
Var
 I:Byte;
Begin
 For I:=1to Length(S)do Begin
  If S[I]<>' 'Then Begin
   TrimL:=Copy(S,I,255);
   Exit;
  End;
 End;
 TrimL:=S;
End;

Function TrimR(s:String):String;
Var
 i:Integer;
Begin
 i:=Length(s);
 While (i>0)and(s[i]in[#9,' '])do Dec(i);
 s[0]:=Chr(i);
 TrimR:=S;
End;

Function Trim(s:String):String;Begin
 Trim:=TrimL(TrimR(s));
End;

Function StrToUpper(S:String):String;
Var
 I:Byte;
Begin
 For I:=1 to Length(S)do Begin
  If S[I] in['a'..'z']Then S[I]:=Chr(Ord(S[I])-32);
 End;
 StrToUpper:=S;
End;

Function Path2Name(S:String):String;
Var
 D:DirStr;
 N:NameStr;
 E:ExtStr;
Begin
 FSplit(S,D,N,E);
 Path2Name:=N;
End;

Function Path2Ext(S:String):String;
Var
 D:DirStr;
 N:NameStr;
 E:ExtStr;
Begin
 FSplit(S,D,N,E);
 Path2Ext:=E;
End;

Function Path2NoExt(S:String):String;
Var
 D:DirStr;
 N:NameStr;
 E:ExtStr;
Begin
 FSplit(S,D,N,E);
 Path2NoExt:=D+N;
End;

Function JSON2XML(SourceName,TargetName:String):Integer;
Var
 Mode:(Key,Value);
 DirectValue,InString:Boolean;
 SourceJSON,TargetXML:Text;
 Spacing:Word;
 C:Char;
 CurrWord,FileName,TFileName:String;
 Ident:Integer;
 FieldList:Array[0..127]of FieldRec;
 GroupValue:Array[0..49]of Boolean;
Begin
 FileName:=FExpand(SourceName);
 If Path2Ext(FileName)=''Then FileName:=FileName+'.JSON';
 Assign(SourceJSON,FileName);
 {$I-}Reset(SourceJSON);{$I+}
 If IoResult<>0Then Begin
  JSON2XML:=errCantOpenFile;
  Exit;
 End;
 Spacing:=2;
 InString:=False;
 Ident:=0;
 CurrWord:='';
 Mode:=Key;
 FillChar(FieldList,SizeOf(FieldList),0);
 FillChar(GroupValue,SizeOf(GroupValue),0);
 TFileName:=FExpand(TargetName);
 If Path2Ext(TFileName)=''Then TFileName:=TFileName+'.XML';
 Assign(TargetXML,TFileName);
 {$I-}Rewrite(TargetXML); {$I+}
 If IoResult<>0Then Begin
  JSON2XML:=errCantCreateFile;
  Close(SourceJSON);
  Exit;
 End;
 WriteLn(TargetXML,'<?xml version="1.0" encoding="UTF-8"?>');
 While Not EOF(SourceJSON)do Begin
  Read(SourceJSON,C);
  If(InString)Then Begin
   If C='"'Then InString:=False
           Else CurrWord:=CurrWord+C;
  End
   Else
  If Not(C in[#0,#13,#10])Then Begin
   Case C of
    '"':Begin
     InString:=True;
     DirectValue:=False;
    End;
    '{':Begin
     If(Mode=Value)Then Begin
      WriteLn(TargetXML);
     End;
     If CurrWord=''Then GroupValue[Ident]:=True;
     Inc(Ident);
    End;
    '}':Begin
     If(Mode=Value)Then Begin
      If(DirectValue)Then Write(TargetXML,Trim(CurrWord))
                     Else Write(TargetXML,CurrWord);
      Mode:=Key;
     End;
     If Not(GroupValue[Ident])Then WriteLn(TargetXML,'</',FieldList[Ident].FieldName,'>');
     If Ident>0Then Begin
      Dec(Ident);
      If GroupValue[Ident]Then Begin
       If Ident<>0 Then Begin
        If Ident>1 Then Write(TargetXML,' ':Pred(Ident)*Spacing);
        WriteLn(TargetXML,'</',FieldList[Ident].FieldName,'>');
       End;
      End;
     End;
     Mode:=Key;
    End;
    ':':Begin
     FieldList[Ident].FieldName:=Trim(CurrWord);
     If Ident>1 Then Write(TargetXML,' ':Pred(Ident)*Spacing);
     Write(TargetXML,'<',FieldList[Ident].FieldName,'>');
     CurrWord:='';
     DirectValue:=True;
     Mode:=Value;
     GroupValue[Ident]:=False;
    End;
    ',':Begin
     If(Mode=Value)Then Begin
      If(DirectValue)Then Write(TargetXML,Trim(CurrWord))
                     Else Write(TargetXML,CurrWord);
      WriteLn(TargetXML,'</',FieldList[Ident].FieldName,'>');
      Mode:=Key;
     End;
     CurrWord:='';
     Mode:=Key;
    End;
    Else CurrWord:=CurrWord+C;
   End;
  End;
 End;
 Close(TargetXML);
 Close(SourceJSON);
End;

Function GetErrorMessageImport(Err:Integer):String;Begin
 Case Err of
  errNoError:GetErrorMessageImport:='';
  errCantCreateFile:GetErrorMessageImport:='Impossible de cr‚er le fichier';
  errCantOpenFile:GetErrorMessageImport:='Impossible d''ouvrir le fichier source';
  errCommandNotImplemented:GetErrorMessageImport:='Commande non impl‚ment‚';
  errCommandNotSupported:GetErrorMessageImport:='Commande non support‚';
  errDataExpected:GetErrorMessageImport:='Donn‚es attendue';
  errDataTypeExpected:GetErrorMessageImport:='Type de donn‚es attendu';
  errIntoKeywordExpected:GetErrorMessageImport:='Mot clef INTO attendu';
  errRecordTooBig:GetErrorMessageImport:='Enregistrement trop grand';
  errSeparatorExpected:GetErrorMessageImport:='S‚parateur attendu';
  errStringWithoutTerminaison:GetErrorMessageImport:='Chaine de caractŠres sans terminaison';
  errTableNameExpected:GetErrorMessageImport:='Nom de table attendu';
  errTableKeywordExpected:GetErrorMessageImport:='Mot clef TABLE attendu';
  errUnknownCommand:GetErrorMessageImport:='Command inconnu';
  errUnknownDataType:GetErrorMessageImport:='Type de donn‚es inconnu';
 End;
End;

END.
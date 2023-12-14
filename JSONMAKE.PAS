{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2023
  @website(https://www.gladir.com/CODER/JSONLIB-TP)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Unit JSONMAKE;

INTERFACE

Uses Strings;

Type
 KeyValue=Record
  Key,Value:PChar;
 End;
 KeyValueArray=Array[0..100] of KeyValue;

Procedure BeginTag(Var F:Text;TagName:String);
Function  CloseJSON(Var F:Text):Boolean;
Function  CreateJSON(Var F:Text;FileName:String):Boolean;
Procedure EndTag(Var F:Text;TagName:String);
Procedure WriteArray(Var F:Text;NumKV:Word;Const Data:KeyValueArray);
Procedure WriteDataTag(Var F:Text;Value:String);
Procedure WriteTag(Var F:Text;TagName,Value:String);

IMPLEMENTATION

Function CreateJSON(Var F:Text;FileName:String):Boolean;
Var
 R:Boolean;
Begin
 {$I-}Assign(F,FileName);
 Rewrite(F);{$I+}
 R:=IOResult=0;
 CreateJSON:=R;
 If(R)Then Begin
  WriteLn(F,'{');
 End;
End;

Procedure BeginTag(Var F:Text;TagName:String);Begin
 Write(F,'{"',TagName,'":');
End;

Procedure WriteDataTag(Var F:Text;Value:String);Begin
 Write(F,Value);
End;

Procedure WriteTag(Var F:Text;TagName,Value:String);Begin
 WriteLn(F,'{"',TagName,'":"',Value,'"}');
End;

Procedure EndTag(Var F:Text;TagName:String);Begin
 WriteLn(F,'}');
End;

Procedure WriteArray(Var F:Text;NumKV:Word;Const Data:KeyValueArray);
Var
 I:Integer;
Begin
 WriteLn(F,'{');
 For I:=1 to NumKV do Begin
  If I>1 Then Write(F,',');
  Write(F,'"',StrPas(Data[I-1].Key),'","',StrPas(Data[I-1].Value),'"');
 End;
 WriteLn(F,'}');
End;

Function CloseJSON(Var F:Text):Boolean;Begin
 WriteLn(F,'}');
 Close(F);
 CloseJSON:=IOResult=0;
End;

END.
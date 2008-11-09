
{Summary the MeRegExpr extension object .}
{
   @author  Riceball LEE(riceballl@hotmail.com)
   @version $Revision$

  License:
    * The contents of this file are released under a dual \license, and
    * you may choose to use it under either the Mozilla Public License
    * 1.1 (MPL 1.1, available from http://www.mozilla.org/MPL/MPL-1.1.html)
    * or the GNU Lesser General Public License 2.1 (LGPL 2.1, available from
    * http://www.opensource.org/licenses/lgpl-license.php).
    * Software distributed under the License is distributed on an "AS
    * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
    * implied. See the License for the specific language governing
    * rights and limitations under the \license.
    * The Original Code is $RCSfile: uMeRegExpr.pas,v $.
    * The Initial Developers of the Original Code are Riceball LEE.
    * Portions created by Riceball LEE is Copyright (C) 2003-2008
    * All rights reserved.

    * Contributor(s):
}
unit uMeRegExpr;

interface

{$I MeSetting.inc}
{.$DEFINE SubExprName_RegExpr}

uses
{$IFDEF MSWINDOWS}
  Windows, 
{$ENDIF}
  //TypInfo,
  SysUtils
  , uRegExpr
  , uMeConsts
  , uMeSystem
  , uMeObject
  //, uMeYield
  , uMeCoroutine
  {$IFDEF DEBUG}
  , DbugIntf
  {$ENDIF}
  ;

type
{
�����е�������ʽ������һ��
  Content=/():Count: [[SearchListBegin]] [[SearchList]] [[SearchListEnd]] ():NextPageURL:/:1
    SearchListBegin = //
    SearchList = /():Field1: ():Field2:/:n

SearchListBegin, SearchList Ϊ�ӱ��ʽ����ǰ��ֹ���ӱ��ʽ��Ƕ���ӱ��ʽ��

ð�ź�������ֱ�ʾִ��ƥ�������Ĵ����������n��ʾһֱ����ֱ��û��ƥ������ݡ�
���ʡ������ð�ź����֣���ʾ�˱��ʽֻ����1�Ρ�

֧��Ƕ��ƥ���Լ�ƥ�������
�Ⱥŷָ�ƥ�䶨�������Լ�ƥ������: Name=Content[:n]
���ContentΪ�������ݣ���ʾΪ���ַ���ƥ�䣨֧��*�ź�?��ͨ����ţ�ת�����Ϊ\���� Name='my*.*':1
���ContentΪ"/"б������ģ����ʾΪ����ƥ�䣬���Զ������ֶ�
�磺 Name =/hello(.*):myfield:/:n


��һ�����ӵ����ӣ�
<table>
<tr><th>�Ա�</th><th>����</th><th>����</th></tr>
<tr><td>Male</td><td>13</td><td>Rose</td></tr>
<tr><td>Female</td><td>20</td><td>Jacky</td></tr>
</table>

Content=/[[ListTitle]] [[ListDetail]]/
ListTitle=/<tr><th>(.*):Sex</th><th>(.*):Age</th><th>(.*):Name</th></tr>/:1
ListDetail=/<tr><td>(.*):$[ListTitle.Sex]:</td><td>(.*):$[ListTitle.Age]:</td><td>(.*):$[ListTitle.Name]:</td></tr>/:n

if not found "$[ListTitle.Sex]" then use ListTitle.Sex as FiledName.

[[ListTitle]] Ϊ�ӱ��ʽ


    property MatchStrPos [const aSubExprName : RegExprString] : integer read GetMatchStrPos;
    property MatchStrLen [const aSubExprName : RegExprString] : integer read GetMatchStrLen;
    property MatchStr [const aSubExprName : RegExprString] : RegExprString read GetMatchStr;
    property SubExprMatchCount : integer read GetSubExprMatchCount;
    property SubExprNames[const index: integer]: RegExprString read GetSubExprName;
    Function GetSubExprIndexByName(const aSubExprName: RegExprString) : Integer;




How to use the MatchResult?
treat the RegExprResultItem as the record item.
  the record item includes the fields and values.
    the fields collects only the sub-expressions in the RegExpr.Match[1]...Match[SubExprMatchCount].
    if the SubExprName_RegExpr enabled, it will be format: "SubExprName=MatchValue" in the Strings.
}
(*
Defines:
  SubExpression: [[SearchListBegin]]
  SubField: $[SubField]
  Macro(inline): $[:Macro{Param1=XX1,Param2=XX2}:]
    the macro is pure Regular expression! the "{Param1=XX1, Param2=XX2}" is optional.
    eg: 
    Macro: ATag= <a href=(['|"])(?<URI>.*?)(\-2).*>(?<Name>.*?)</a>
      List=/$[:ATag{URI=MyURI,Name=MName}:]/:n

*)
  PMeAbstractRegExpr = ^ TMeAbstractRegExpr;
  PMeCustomSimpleRegExpr = ^ TMeCustomSimpleRegExpr;
  PMeSimpleRegExpr = ^ TMeSimpleRegExpr;
  PMeCustomRegExpr = ^ TMeCustomRegExpr;
  PMeRegExpr = ^ TMeRegExpr;
  PMeRegExprs = ^ TMeRegExprs;
  PMeRegExprResultItem = ^ TMeRegExprResultItem;
  PMeRegExprResult = ^ TMeRegExprResult;

  //if no SubExpr Defined then aResult is nil.
  TMeRegExprFoundEvent = procedure(const Sender: PMeAbstractRegExpr; const aResult: PMeRegExprResultItem) of object;

  TMeRegExprResultItem = object(TMeDynamicObject)
  protected
    FRegExpr: PMeAbstractRegExpr;
    FFields: PMeStrings;
    procedure Init; virtual; //override
  public
    destructor Destroy; virtual; //override
    //the aName is FieldName or RegExpr.Name + '.' + FieldName.
    function GetValueByName(const aName: RegExprString): string;

    property Fields: PMeStrings read FFields;
    property RegExpr: PMeAbstractRegExpr read FRegExpr;
  end;

  TMeRegExprResult = object(TMeList)
  protected
    function GetItem(Index: Integer): PMeRegExprResultItem;
  public
    destructor Destroy; virtual;{override}
    procedure Clear;
    function IndexOfRegEx(const aRegExprName: RegExprString; const aBeginIndex: Integer = 0): Integer;
    function FindByRegEx(const aRegExprName: RegExprString): PMeRegExprResultItem;

    function ValueOf(const aName: RegExprString): String;
  public
    property Items[Index: Integer]: PMeRegExprResultItem read GetItem; default;
  end;

  TMeAbstractRegExpr = object(TMeDynamicObject)
  protected
    FOwner: PMeCustomRegExpr;
    FParent: PMeCustomRegExpr;
    FRegExpr: TRegExpr; //only available on the execution time.
    FRoot: PMeCustomRegExpr;
    FMacros: PMeStrings;

    FExecCount: Integer;
    FInputString: RegExprString;
    FName: RegExprString;
    {
      TMeRegExprResultItem = TMeStrings;
        SubExprName=Value
        SubExprName=Value
        SubExprName=Value
      TMeRegExprResult = TMeList of PMeStrings
    }
    FMatchResult: PMeRegExprResult; //of PMeStrings
    //the Regular Expression pattern
    FPattern: RegExprString;
    FOnFound: TMeRegExprFoundEvent;

    function GetRoot: PMeCustomRegExpr;
    function GetName: RegExprString;
    function GetMacros: PMeStrings;
    function GetMatchResult: PMeRegExprResult; overload;

    procedure Init; virtual; //override;
    procedure SetPattern(const Value: RegExprString);virtual;
    function iExecute(const aRegExpr: TRegExpr; var aPos: Integer): Boolean; virtual;abstract;
    procedure ApplyExpression(const aRegExpr: TRegExpr);virtual;abstract;

    property Macros: PMeStrings read GetMacros;
    property MatchResult: PMeRegExprResult read GetMatchResult;
    property Root: PMeCustomRegExpr read GetRoot;
  public
    destructor Destroy; virtual; //override;
    function Execute(const aInputString: RegExprString; const aPos: Integer = 1): Boolean;overload;
    function Execute(): Boolean;overload;
    procedure GetMatchResult(const aResult: PMeStrings);overload; virtual;
    function AddMacro(const aName: RegExprString; const aExpression: RegExprString): Integer;

    //the exec count for the expression, -1 means for ever until end.
    //the default is 1.
    property ExecCount: Integer read FExecCount write FExecCount;
    property InputString: RegExprString read FInputString write FInputString;
    property Name: RegExprString read GetName write FName;
    property Pattern: RegExprString read FPattern write SetPattern;
    property RegExpr: TRegExpr read FRegExpr;
    property OnFound: TMeRegExprFoundEvent read FOnFound write FOnFound;
  end;

  TMeCustomSimpleRegExpr = object(TMeAbstractRegExpr)
  protected
    procedure DoResultFound(const Sender: PMeAbstractRegExpr);
    function DoReplacePatternFunc(const aRegExpr : TRegExpr): RegExprString;
    //function GetRegExpr: TRegExpr;
    //function GetExpression: RegExprString; virtual;
    function GetAdjustedPattern: RegExprString;
    //procedure Init; virtual; //override;

    function iExecute(const aRegExpr: TRegExpr; var aPos: Integer): Boolean; virtual; //override
    procedure ApplyExpression(const aRegExpr: TRegExpr);virtual; //override

  public
    //destructor Destroy; virtual; //override;
    //procedure GetMatchResult(const aResult: PMeStrings);overload; virtual; //override

  end;

  TMeSimpleRegExpr = object(TMeCustomSimpleRegExpr)
  public
    property Macros;
    property MatchResult;
  end;

  TMeRegExprs = object(TMeList)
  protected
    FFreeAll: Boolean;
    function GetItem(Index: Integer): PMeAbstractRegExpr;
  public
    destructor Destroy; virtual;{override}
    procedure Clear;
    //procedure Assign(const aObjs: PMeNamedObjects);
    function IndexOf(const aName: RegExprString; const aBeginIndex: Integer = 0): Integer;
    function Find(const aName: RegExprString): PMeAbstractRegExpr;
  public
    property Items[Index: Integer]: PMeAbstractRegExpr read GetItem; default;
  end;

  TMeCustomRegExpr = object(TMeAbstractRegExpr)
  protected
    //this is Regular Expressions to run
    FSubRegExprs: PMeRegExprs; //of TMeCustomSimpleRegExpr or TMeCustomRegExpr(Ref from FExpressions)
    //this is added Expressions
    FExpressions: PMeRegExprs; //of TMeCustomRegExpr

    function CreateSimpleRegExpr: PMeCustomSimpleRegExpr;
    procedure ApplyExpression(const aRegExpr: TRegExpr);virtual; //override
    procedure SetPattern(const Value: RegExprString); virtual; //override
    procedure Init; virtual; //override;
    function iExecuteList(const aRegExpr: TRegExpr; var aPos: Integer): Boolean;
    function iExecute(const aRegExpr: TRegExpr; var aPos: Integer): Boolean; virtual; //override

  public
    destructor Destroy; virtual; //override;
    //Add a New varaible Expression define into Exprssions List
    function AddExpr(const aName: RegExprString; const aExpression: RegExprString; const aExecCount: Integer = -2): Integer;
    { the Strs Fmt: 
        the first Line is always the main pattern.
        the fllowing non-empty lines are the SubExpressions.
        eg,
        /[[Before]][[List]][[After]]/
        Before=/..../
        List=/.../
        After=/.../
    }
    procedure LoadPatternFromStrs(const aStrs: PMeStrings);
    procedure SavePatternToStrs(const aStrs: PMeStrings);

    property SubRegExprs: PMeRegExprs read FSubRegExprs;
    property Macros;
    property MatchResult;
  end;

  TMeRegExpr = object(TMeCustomRegExpr)
  public
  end;

const
   // '\/(.*):Expression:\/(\:(\d+|n):ExecCount:)?';
   {1: Expression; 3: ExecCount}
  cMeExpressionPattern = '\/(.*)\/(\:(\d+|n))?';
  //'\[\[(.+?):SubRegEx:\]\]';  ".+? " means non-greedy
  {1: SubExpressionName} 
  cMeSubExpressionNamePattern = '\[\[(\S+)\]\]';
  cMeFieldNamePattern = '\$\[(\S+)\]';

implementation

uses 
  RTLConsts, SysConst;

const
  cRegExprFound = 0;
  cRegExprNotFound = 1;
  cRegExprItemNotFound = 2;
  cRegExprCountError = 3;
  cRegExprOver = 4;

{ TMeAbstractRegExpr }
procedure TMeAbstractRegExpr.Init;
begin
  inherited;
  FExecCount := 1;
end;

destructor TMeAbstractRegExpr.Destroy;
begin
  FPattern := '';
  FName := '';
  if Assigned(FMatchResult) then
  begin
    FMatchResult.Free;
  end;
  MeFreeAndNil(FMacros);
  inherited;
end;

function TMeAbstractRegExpr.AddMacro(const aName: RegExprString; const aExpression: RegExprString): Integer;
begin
  with Macros^ do
  begin
    Result := IndexOfName(PChar(aName));
    if Result < 0 then
    begin
      Result := Add(aName+'='+aExpression);
    end
    else
      Result := -1;
  end;
end;

function TMeAbstractRegExpr.Execute(): Boolean;
begin
  Result := Execute(FInputString);
end;

function TMeAbstractRegExpr.Execute(const aInputString : RegExprString; const aPos: Integer): Boolean;
var
  vPos: Integer;
begin
  FRegExpr := TRegExpr.Create;
  try
    with MatchResult^ do
    begin
      FreeMeObjects;
      Clear;
    end;
    ApplyExpression(FRegExpr);
    FRegExpr.InputString := aInputString;
    vPos := aPos;
    Result := iExecute(FRegExpr, vPos);
  finally
    FRegExpr.Free;
    FRegExpr := nil;
  end;
end;

function TMeAbstractRegExpr.GetMacros: PMeStrings;
begin
  if Assigned(FRoot) then
    Result := FRoot.GetMacros
  else 
  begin
    if not Assigned(FMacros) then
      New(FMacros, Create);
    Result := FMacros;
  end;
end;

function TMeAbstractRegExpr.GetMatchResult: PMeRegExprResult;
begin
  if Assigned(FRoot) then
    Result := FRoot.GetMatchResult
  else 
  begin
    if not Assigned(FMatchResult) then
      New(FMatchResult, Create);
    Result := FMatchResult;
  end;
end;

procedure TMeAbstractRegExpr.GetMatchResult(const aResult: PMeStrings);
var
  i: Integer;
begin
  if Assigned(aResult) and Assigned(FMatchResult) then
  begin
    with FMatchResult^ do for i := 0 to Count - 1 do
    aResult.AddStrings(PMeStrings(Items[i].FFields));
  end;
end;

function TMeAbstractRegExpr.GetName: RegExprString;
var
  vP: PMeAbstractRegExpr;
begin
  Result := FName;
  vP := FParent;
  While (Result = '') and Assigned(vP) do
  begin
    Result := vP.FName;
    if vP = vP.FParent then exit;
    vP := vP.FParent;
  end;
end;

function TMeAbstractRegExpr.GetRoot: PMeCustomRegExpr;
begin
  if Assigned(FRoot) then
    Result := FRoot
  else
    Result := @Self;
end;

procedure TMeAbstractRegExpr.SetPattern(const Value: RegExprString);
begin  
  if FPattern <> Value then
    FPattern := Value;
end;

{ TMeCustomSimpleRegExpr }
{
procedure TMeCustomSimpleRegExpr.Init;
begin
  inherited;
end;


destructor TMeCustomSimpleRegExpr.Destroy;
begin
  inherited;
end;
//}

procedure TMeCustomSimpleRegExpr.ApplyExpression(const aRegExpr: TRegExpr);
var
  vLastError: Integer;
begin
  with aRegExpr do
  begin
    Expression := GetAdjustedPattern;
    Compile;
    vLastError := LastError;
    if vLastError <> 0 then
      Error(vLastError);
  end;
end;

procedure TMeCustomSimpleRegExpr.DoResultFound(const Sender: PMeAbstractRegExpr);
var
  vItem: PMeRegExprResultItem;
  i: Integer;
  s : RegExprString;
begin
  if Assigned(FRegExpr) then
  begin
    New(vItem, Create);
    with FRegExpr do
    try
      for i := 1 to SubExprMatchCount do
      begin
      {$IFDEF SubExprName_RegExpr}
        s := SubExprNames[i];
        if s <> '' then
          s := s + '=' + Match[i];
      {$ELSE}
        s := Match[i];
      {$ENDIF}
        if  s <> '' then
          vItem.FFields.Add(s);
      end; //for
    finally
      if vItem.FFields.Count > 0 then
      begin
        vItem.FRegExpr := @Self;
        MatchResult.Add(vItem);
      end
      else
        MeFreeAndNil(vItem);
    end; //try-finally
    
    //if Assigned(vItem) then
    begin
      if Assigned(FOnFound) then
        FOnFound(Sender, vItem)
      else if Assigned(FRoot) and Assigned(FRoot.FOnFound) then
        FRoot.FOnFound(Sender, vItem);
    end;
  end;
end;

function TMeCustomSimpleRegExpr.DoReplacePatternFunc(const aRegExpr : TRegExpr): RegExprString;
var
  s: RegExprString;
  i: Integer;
  vParams: PMeStrings;
begin
  with aRegExpr do
  begin
    s := Trim(Match[1]);
    if (Length(s) >= 3) and (s[1] =':') and (s[Length(s)]=':') then 
    begin
      //Is Macro
      New(vParams, Create);
      try
        s := Trim(Copy(s, 2, Length(s)-2));
        if (Length(s) > 3) and (s[Length(s)] = '}') then //have params
        begin
          i := AnsiPos(RegExprString('{'), s);
          vParams.AddDelimitedText(Copy(s, i+1, Length(s)-i-1));
          s := Copy(s, 1, i-1);
        end;
        s := Macros.Values[PChar(s)];
        if (s <> '') then
        begin
          for i := 0 to vParams.Count - 1 do
          begin
            s := StringReplace(s, vParams.Names[i], vParams.GetValueByIndex(i), [rfReplaceAll]);
          end;
        end
        else //can not find in the Macros, restore it.
          s := Trim(Match[1]);
      finally
        MeFreeAndNil(vParams);
      end;
    end;
    Result := MatchResult.ValueOf(s);
    if Result = '' then
      Result := s;
    //writeln(' replacePattern:', Result);
  end;
end;

function TMeCustomSimpleRegExpr.GetAdjustedPattern: RegExprString;
begin
  Result := FPattern;
  with TRegExpr.Create do
  try
    Expression := cMeFieldNamePattern;
    Result := ReplaceEx(Result, DoReplacePatternFunc);
    //writeln('GetAdjustedPattern=', Result);
  finally
    Free;
  end;
end;

function TMeCustomSimpleRegExpr.iExecute(const aRegExpr: TRegExpr; var aPos: Integer): Boolean;
var
  vExecCount: Integer;
begin
  with aRegExpr do
  begin
    Result := ExecPos(aPos);
    if Result then
    begin
      //Yield(FRegExpr);
      //FParent.Yield;
      DoResultFound(@Self);
      vExecCount := FExecCount - 1;
      aPos := MatchPos[0] + MatchLen[0];
      while ((vExecCount > 0) or (FExecCount < 0)) and Result do
      begin
        Result := ExecNext;
        //Yield(FRegExpr);
        //FParent.Yield;
        DoResultFound(@Self);
        Dec(vExecCount);
        aPos := MatchPos[0] + MatchLen[0];
      end;
      Result := vExecCount <= 0;
      if not Result then
      begin
        Raise EMeError.Create('TMeCustomSimpleRegExpr.iExecute: the ExecCount is not enough left:' + IntToStr(vExecCount));
      end
    end;
  end;
end;

{
function TMeCustomSimpleRegExpr.GetRegExpr: TRegExpr;
begin
  if not Assigned(FRegExpr) then
    FRegExpr := TRegExpr.Create;
  Result := FRegExpr;
end;
}

{ TMeCustomRegExpr }
procedure TMeCustomRegExpr.Init;
begin
  inherited;
  New(FSubRegExprs, Create);
  New(FExpressions, Create);
  FExpressions.FFreeAll := True;
end;

destructor TMeCustomRegExpr.Destroy;
begin
  MeFreeAndNil(FSubRegExprs);
  MeFreeAndNil(FExpressions);
  inherited;
end;

function TMeCustomRegExpr.AddExpr(const aName: RegExprString; const aExpression: RegExprString; const aExecCount: Integer = -2): Integer;
var
  vExpr: PMeAbstractRegExpr;
  vIsSimple: Boolean;
  s: string;
begin
  Result := FExpressions.IndexOf(aName);
  if Result < 0 then
  begin
    vIsSimple := True;
    s := aExpression;
    with TRegExpr.Create do
    try
      Expression := cMeExpressionPattern;
      if Exec(s) then 
      begin
        s := Match[1];
        Expression := cMeSubExpressionNamePattern;
        if Exec(s) then //only SubExpression exists
        begin
          vIsSimple := False;
          s := aExpression;
        end;
      end;
    finally
      Free;
    end;
    if vIsSimple then
      vExpr := New(PMeCustomSimpleRegExpr, Create)
    else
      vExpr := New(PMeCustomRegExpr, Create);
    with vExpr^ do
    begin
      FOwner  := @Self;
      FParent := @Self;
      FRoot   := Self.Root;
      Name := aName;
      Pattern := s;
      if aExecCount <> -2 then
        FExecCount := aExecCount;
    end;
    FExpressions.Add(vExpr);
  end
  else
    Result := -1;
end;

procedure TMeCustomRegExpr.ApplyExpression(const aRegExpr: TRegExpr);
begin
end;

function TMeCustomRegExpr.CreateSimpleRegExpr: PMeCustomSimpleRegExpr;
begin
  New(Result, Create);
  with Result^ do
  begin
    FParent := @Self;
    FRoot := Self.Root;
  end;
end;

{
procedure TMeCustomRegExpr.GetMatchResult(const aResult: PMeStrings);
var
  i: Integer;
begin
  if Assigned(aResult) then
  for i := 0 to FSubRegExprs.Count - 1 do
  begin
    FSubRegExprs.Items[i].GetMatchResult(aResult);
  end;
end;
//}

function TMeCustomRegExpr.iExecuteList(const aRegExpr: TRegExpr; var aPos: Integer): Boolean;
var
  i: Integer;
  vPrevPos: Integer;
begin
  Result := False;
  for i := 0 to FSubRegExprs.Count - 1 do with FSubRegExprs.Items[i]^ do
  begin
    //Writeln('run ', FName, ' ', FPattern);
    FRegExpr := aRegExpr;
    ApplyExpression(aRegExpr);
    vPrevPos := aPos;
    Result := iExecute(aRegExpr, aPos);
    FRegExpr := nil;
    if not Result then
    begin
      //Raise EMeError.Create('TMeCustomRegExpr.Exec: the SubExpr['+Name+'] is not match:'+Pattern);
      Exit;
    end;
    {
    Result := Result and (vPrevPos = aRegExpr.MatchPos[0]);
    if not Result then
    begin
      //Raise EMeError.Create('TMeCustomRegExpr.Exec: the SubExpr can not link to anthoer pattern!!');
      Exit;
    end; //}
  end;
end;

function TMeCustomRegExpr.iExecute(const aRegExpr: TRegExpr; var aPos: Integer): Boolean;
var
  vExecCount: Integer;
  vPrevPos: Integer;
begin
  Result := FSubRegExprs.Count > 0;
  if Result then
  begin
    vPrevPos := aPos;
    Result := iExecuteList(aRegExpr, aPos);
    vExecCount := FExecCount - 1;
    if (vExecCount > 0) or (FExecCount < 0) then
    begin
      while ((vExecCount > 0) or (FExecCount < 0)) and (vPrevPos <> aPos) do
      begin
        vPrevPos := aPos;
        Result := iExecuteList(aRegExpr, aPos);
        //writeln('iExecuteList=', Result);
        //Yield(FRegExpr);
        Dec(vExecCount);
        //aPos := MatchPos[0] + MatchLen[0];
      end;
      Result := (vExecCount <= 0);
      if not Result then
      begin
        Raise EMeError.Create('TMeCustomRegExpr.iExecute['+Name+']: the ExecCount is not enough left:' + IntToStr(vExecCount));
      end;
    end;
  end
  else
    Raise EMeError.Create('TMeCustomRegExpr.Exec: No Expression to execute!');
end;

procedure TMeCustomRegExpr.LoadPatternFromStrs(const aStrs: PMeStrings);
var
  i: Integer;
begin
  if Assigned(aStrs) then with aStrs^ do
  begin
    FExpressions.Clear;
    for i := 1 to Count - 1 do
    begin
      AddExpr(Names[i], GetValueByIndex(i));
    end;
    Pattern := Items[0];
  end;
end;

procedure TMeCustomRegExpr.SavePatternToStrs(const aStrs: PMeStrings);
var
  i: Integer;
begin
  if Assigned(aStrs) then with aStrs^ do
  begin
    Clear;
    Add(Pattern);
    for i := 0 to FExpressions.Count - 1 do
    begin
      with FExpressions.Items[i]^ do
        Add(Name+ '=' + Pattern);
    end;
  end;
end;

procedure TMeCustomRegExpr.SetPattern(const Value: RegExprString);
var
  s: RegExprString;
  vRegExpr: PMeCustomSimpleRegExpr;
  vExpr: PMeCustomRegExpr;
  vExecCount: Integer;
  vPrevPos: Integer;
begin  
  if FPattern <> Value then
  begin
    FSubRegExprs.Clear;
  //1. AnsiExtractQuotedStr(var s: PChar; Quote: Char = '/'): string;
    with TRegExpr.Create do
    try
      //Expression := '\/(.+?):Expression:\/((\:(\d+|n):ExecCount:)|)';
      Expression := cMeExpressionPattern;
      if Exec(Value) then
      begin
        s := Match[1];
        if Match[3] <> '' then
          FExecCount := StrToIntDef(Match[3], -1);
      end
      else
        Raise EMeError.Create('TMeCustomRegExpr.SetExpression: the  RegExprString format is error!');
      //s := AnsiExtractQuotedStr(PChar(Value), '/');
    //2. Search all the sub RegExpressions: 
      //RegExpr.Expression := '\/\[(.+?):SubRegEx:\]\/';
      Expression := cMeSubExpressionNamePattern;
      vPrevPos := 1;
      if Exec(s) then
        repeat
          s := Trim(System.Copy(InputString, vPrevPos, MatchPos[0] - vPrevPos));
          vPrevPos := MatchPos [0] + MatchLen [0];
          if s <> '' then
          begin
            vRegExpr := CreateSimpleRegExpr;
            vRegExpr.Pattern := s;
            FSubRegExprs.Add(vRegExpr);
          end;
          s := Trim(Match[1]);
          if s <>  '' then
          begin
            vExpr := PMeCustomRegExpr(FExpressions.Find(s));
            if not Assigned(vExpr) then
              Raise EMeError.Create('TMeCustomRegExpr.SetExpression: No Such SubRegExpression found:' + s);
            FSubRegExprs.Add(vExpr);
          end
          else
            Raise EMeError.Create('TMeCustomRegExpr.SetExpression: The SubRegExpression is empty!');
        until not ExecNext
      else  //No SubRegExpression, only one.
      begin
        vRegExpr := CreateSimpleRegExpr;
        vRegExpr.Pattern := s;
        //vRegExpr.FExecCount := vExecCount;
        FSubRegExprs.Add(vRegExpr);
      end; //if
    finally
      Free;
    end;

    FPattern := Value;
  end;
end;

{ TMeRegExprs }
destructor TMeRegExprs.Destroy;
begin
  Clear;
  inherited;
end;

procedure TMeRegExprs.Clear;
var
  I: Integer;
begin
  if FFreeAll then
    FreeMeObjects
  else
    for I := Count - 1 downto 0 do
    begin
      if Assigned(FItems[I]) then with PMeAbstractRegExpr(FItems[I])^ do
      begin
        if  not Assigned(FOwner) then
          Free;
      end;
      FItems[I] := nil;
    end;

  inherited Clear;
end;

function TMeRegExprs.Find(const aName: RegExprString): PMeAbstractRegExpr;
var
  i: integer;
begin
  i := IndexOf(aName);
  if i >= 0 then
    Result := Items[i]
  else
    Result := nil;
end;

function TMeRegExprs.IndexOf(const aName: RegExprString; const aBeginIndex: Integer = 0): Integer;
begin
  for Result := aBeginIndex to Count - 1 do
  begin
    if (aName = Items[Result].Name) then
      exit;
  end;
  Result := -1;
end;

function TMeRegExprs.GetItem(Index: Integer): PMeAbstractRegExpr;
begin
  Result := Inherited Get(Index);
end;

{ TMeRegExprResultItem }
procedure TMeRegExprResultItem.Init;
begin
  Inherited;
  New(FFields, Create);
end;

destructor TMeRegExprResultItem.Destroy;
begin
  MeFreeAndNil(FFields);
  Inherited;
end;

function TMeRegExprResultItem.GetValueByName(const aName: RegExprString): string;
var
  i: Integer;
begin
  with FFields^ do for i := 0 to Count - 1 do
  begin
    if (aName = Names[i]) or (Assigned(RegExpr) and (aName = RegExpr.Name+'.'+Names[i])) then
    begin
      Result := GetValueByIndex(i);
      Exit;
    end;
  end;
  Result := ''; 
end;

{ TMeRegExprResult }
destructor TMeRegExprResult.Destroy;
begin
  FreeMeObjects;
  Inherited;
end;

procedure TMeRegExprResult.Clear;
begin
  FreeMeObjects;
  Inherited;
end;

function TMeRegExprResult.GetItem(Index: Integer): PMeRegExprResultItem;
begin
  Result := Inherited Get(Index);
end;

function TMeRegExprResult.FindByRegEx(const aRegExprName: RegExprString): PMeRegExprResultItem;
var
  i: integer;
begin
  i := IndexOfRegEx(aRegExprName);
  if i >= 0 then
    Result := Items[i]
  else
    Result := nil;
end;

function TMeRegExprResult.IndexOfRegEx(const aRegExprName: RegExprString; const aBeginIndex: Integer = 0): Integer;
begin
  for Result := aBeginIndex to Count - 1 do
  begin
    with Items[Result]^ do 
      if Assigned(RegExpr) and (aRegExprName = RegExpr.Name) then
        exit;
  end;
  Result := -1;
end;

function TMeRegExprResult.ValueOf(const aName: RegExprString): String;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
  begin
    with Items[i]^ do 
      Result := GetValueByName(aName);
    if Result <> '' then exit;
  end;
  Result := '';
end;

initialization
  SetMeVirtualMethod(TypeOf(TMeAbstractRegExpr), ovtVmtParent, TypeOf(TMeDynamicObject));
  SetMeVirtualMethod(TypeOf(TMeCustomSimpleRegExpr), ovtVmtParent, TypeOf(TMeAbstractRegExpr));
  SetMeVirtualMethod(TypeOf(TMeCustomRegExpr), ovtVmtParent, TypeOf(TMeAbstractRegExpr));
  SetMeVirtualMethod(TypeOf(TMeRegExprs), ovtVmtParent, TypeOf(TMeList));
  SetMeVirtualMethod(TypeOf(TMeRegExprResultItem), ovtVmtParent, TypeOf(TMeDynamicObject));
  SetMeVirtualMethod(TypeOf(TMeRegExprResult), ovtVmtParent, TypeOf(TMeList));

  {$IFDEF MeRTTI_SUPPORT}
  SetMeVirtualMethod(TypeOf(TMeAbstractRegExpr), ovtVmtClassName, nil);
  SetMeVirtualMethod(TypeOf(TMeCustomSimpleRegExpr), ovtVmtClassName, nil);
  SetMeVirtualMethod(TypeOf(TMeCustomRegExpr), ovtVmtClassName, nil);
  SetMeVirtualMethod(TypeOf(TMeRegExprs), ovtVmtClassName, nil);
  SetMeVirtualMethod(TypeOf(TMeRegExprResultItem), ovtVmtClassName, nil);
  SetMeVirtualMethod(TypeOf(TMeRegExprResult), ovtVmtClassName, nil);
  {$ENDIF}
end.



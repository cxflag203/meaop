
{ Summary the method(procedure) Code Injector }
{ Description
  Provide the lightest and simplest injector object -- TMeInjector.
  This object do not use any virtual method, so you can use it directly.
  Each injector only take 36 bytes about in the memory. One injector 
  maintains the one injected method(procedure) only. Call the InjectXXX 
  Method to inject. The injector object is the smallest, simplest and 
  fastest object in the MeAOP .

  
  CN:
  �ṩ��������ɵ�ע��������(Object)����Objectû���κ��鷽����̬������
  ��������ֱ��ʹ������ÿһ��ע������Լ��ռ�ڴ�36���ֽڣ�ָ�ֶ��򣩡�
  һ��ע����(TMeInjector)ά��һ�����̻򷽷���ʹ��ע������ Inject
  ϵ�з�������ע�룬
  ע���Enbaled����Ϊ�棬����ע��ֻҪ����Enabled����Ϊ�ټ��ɣ�����ע��ֻҪ��������
  Enabled����Ϊ�档ע�⣬ע���������Ϊע���������������ȱ���Ҫ����Enabled����
  Ϊ�١������ע�����������ע�����ٴ�ע�룬��ôֻ�е��Ǹ�ע�������ȳ���ע���
  ����ܳ���ע�룡��

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
    * The Original Code is $RCSfile: uMeInjector.pas,v $.
    * The Initial Developers of the Original Code are Riceball LEE.
    * Portions created by Riceball LEE is Copyright (C) 2006-2008
    * All rights reserved.

    * Contributor(s):
}
unit uMeInjector;

interface

{$I MeSetting.inc}

uses
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  SysUtils, Classes, TypInfo
  , uMeConsts
  , uMeSystem
  , uMeException
  , uMeTypInfo
  ;

const
  //the x86 instruction for injected static method or procedure
  DefaultInjectDirective = cX86JumpDirective;

type
  EMeInjectorError = EMeError;

  PMeInjector = ^TMeInjector; 
  { Summary: Provide the lightest and simplest injector object to inject function or method. }
  {
  Description:
  This object do not use any virtual method, so you can use it directly.
  Each injector only take 36 bytes about in the memory. One injector 
  maintains the one injected method(procedure) only. Call the InjectXXX 
  Method to inject. The injector object is the smallest, simplest and 
  fastest object in the MeAOP .
  
  }
  TMeInjector = object
  protected
    //����Ҫ����ΪҪ�ָ�
    FEnabled: Boolean;

    FMethodType: TMethodType;

    FMethodNewLocation: Pointer;
    // keep the Original method(procedure) proc address.
    FMethodOriginalLocation: Pointer; 

    //only for static method or procedure.
    // the actual original static method(procedure) location
    // if the procedure is in BPL(DLL) then the OriginalLocation <> OriginalActualLocation
    // else the OriginalLocation = OriginalActualLocation 
    FMethodOriginalActualLocation: Pointer; 
    FMethodOriginalBackup: TRedirectCodeRec; 

    //if this is a procedure then it will be nill.
    FMethodClass: TClass;
    // for virtual method(Index) or dynamic method(Slot) 
    // or published method(PPublishedMethodEntry)
    // or static method(procedure) it is the directive: JMP or CALL
    FMethodIndex: Integer; 

    procedure SetEnabled(Value: Boolean);

    function _InjectPublishedMethod: Boolean;
    function _InjectStaticMethod: Boolean;
    function _InjectVirtualMethod: Boolean;
    function _InjectDynamicMethod: Boolean;
    function _UnInjectStaticMethod: Boolean;
    function _UnInjectVirtualMethod: Boolean;
    function _UnInjectDynamicMethod: Boolean;
    function _UnInjectPublishedMethod: Boolean;

    function Inject:Boolean;overload;
    function UnInject:Boolean;
  public
    {: return the original procedure address for the procedure or static-method}
    {
     only available for STATIC_METHOD_SCRAMBLING_CODE_SUPPORT or pre-holed procedure
     other return nil. 
    }
    function OriginalProc: Pointer;
    {###only when the enabled is false can inject!!}
    { Summary: Inject the procedure }
    { Description
      @param aDirective the inject directive: near CALL or JMP.
                        the default is the near JMP directive used.
    }
    function InjectProcedure(const aPatchLocation: Pointer; const aNewLocation: Pointer; const aDirective: Integer = DefaultInjectDirective): Boolean;
    { Summay: Inject the static method }
    function InjectStaticMethod(const aClass: TClass; const aPatchLocation: Pointer; const aNewLocation: Pointer; const aDirective: Integer = DefaultInjectDirective): Boolean;
    { Summary Inject the aNewLocation to the VMT.}
    {NOTE: if you insert a new virtual method the index number may be changed.}
    function InjectVirtualMethod(const aClass: TClass; const aIndex: Integer; const aNewLocation: Pointer): Boolean;
    { Summary Inject the aNewLocation to the DMT.}
    function InjectDynamicMethod(const aClass: TClass; const aSlot: Integer; const aNewLocation: Pointer): Boolean;
    { Summary Inject the aNewLocation to the PMT.}
    function InjectPublishedMethod(const aClass: TClass; const aEntry: PPublishedMethodEntry; const aNewLocation: Pointer): Boolean;
    { Summary: the general inject method }
    { Description
    Inject the procedure : Inject(@aProc, @MyNewProc);
    Inject the method : Inject(@TAClass.Method, @MyNewMethod, TAClass [, mtVirtual]);
      Note:
        * the last parameter is optional, it should be mtStatic, mtVirtual and mtDynamic
        * the TAClass.Method can not be the abstract method unless it is pulbished.
            you should call the InjectVirtualMethod or InjectDynamicMethod directly 
            if you wanna inject an abstract method 
    } 
    function Inject(const aPatchLocation: Pointer; const aNewLocation: Pointer
      ; const aClass: TClass = nil
      ; const aMethodType: TMethodType=mtUnknown): Boolean;overload;
    { Summary: Inject the Published method of the class by InjectStaticMethod!} 
    { Note: the published method can be the abstract method!
       Inject('MyMethodName', @MyNewMethodProc, TMyClass);
      See Also InjectStaticMethod
      Why do I inject it as StaticMethod?
        I wanna the return address via CALL. 
    }
    function Inject(const aMethodName: string; const aNewLocation: Pointer
      ; const aClass: TClass
      ; const aMethodType: TMethodType=mtPublished
      ; const aDirective: Integer = DefaultInjectDirective): Boolean;overload;
    //set enabled to false will restore the Original method(procedure)
    //set enabled to true will patch the NewLocation again if NewLocation <> nil.
    property Enabled: Boolean read FEnabled write SetEnabled;

    //keep the injected method type
    property MethodType: TMethodType read FMethodType;  
    //keep the injected method new entry
    property MethodNewLocation: Pointer read FMethodNewLocation;
    //keep the injected method Original entry
    property MethodOriginalLocation: Pointer read FMethodOriginalLocation; 

    //keep the injected method class
    property MethodClass: TClass read FMethodClass;  
    // for virtual method(Index) or dynamic method(Slot) 
    // or published method(PPublishedMethodEntry)
    // or static method(procedure) it is the drecitve: JMP or CALL
    property MethodIndex: Integer read FMethodIndex;  


    //only for static method or procedure.
    // the actual original static method(procedure) location
    // if the procedure is in BPL(DLL) then the OriginalLocation <> OriginalActualLocation
    // else the OriginalLocation = OriginalActualLocation 
    property MethodOriginalActualLocation: Pointer read FMethodOriginalActualLocation; 
    //<COMBINE MethodOriginalActualLocation>
    property MethodOriginalBackup: TRedirectCodeRec read FMethodOriginalBackup; 
  end;

  



implementation

{$IFDEF THREADSAFE_SUPPORT}
uses
  uMeSyncObjs;
var
  FLock:  TMeCriticalSection;
{$ENDIF}

{##### TMeInjector ######}
procedure TMeInjector.SetEnabled(Value: Boolean);
begin
  if Enabled <> Value then
  begin
    if (FMethodType <> mtUnknown) and (FMethodOriginalLocation <> nil) then
    begin 
      if Value then
      begin
        Value := Inject;
      end else
      begin
        if not UnInject() then
          Value := True;
          //Raise EMeInjectorError.CreateRes(@rsCanNotUnInjectError); 
      end;
    end
    else 
      Value := False;
    //if Value = False then 
    FEnabled := Value;
  end;
end;

function TMeInjector.InjectProcedure(const aPatchLocation: Pointer; const aNewLocation: Pointer; const aDirective: Integer): Boolean;
begin
  Result := not Enabled; 
  if Result then
  begin
    FMethodOriginalActualLocation := GetActualAddress(aPatchLocation);
    FMethodNewLocation := aNewLocation;
    FMethodIndex := aDirective;
    Result := _InjectStaticMethod();
    if Result then
    begin
      FEnabled := True;
      FMethodType := mtProcedure;
      FMethodOriginalLocation := aPatchLocation;
      FMethodClass := nil; 
    end; 
  end; 
end;

function TMeInjector.InjectStaticMethod(const aClass: TClass; const aPatchLocation: Pointer
  ; const aNewLocation: Pointer; const aDirective: Integer): Boolean;
begin
  Result := aClass <> nil;
  if Result then
  begin
    Result := InjectProcedure(aPatchLocation, aNewLocation, aDirective);
    if Result then
    begin
      FMethodClass := aClass; 
      FMethodType := mtStatic;
    end;
  end;
end;

function TMeInjector.InjectPublishedMethod(const aClass: TClass; const aEntry: PPublishedMethodEntry; const aNewLocation: Pointer): Boolean;
begin
  Result := not Enabled and (aClass <> nil);
  if Result then
  begin
    FMethodClass := aClass; 
    FMethodIndex := Integer(aEntry); 
    FMethodNewLocation := aNewLocation;
    Result := _InjectPublishedMethod();
    if Result then
    begin
      FEnabled := True;
      FMethodType := mtPublished;
    end;
  end;
end;

function TMeInjector.InjectVirtualMethod(const aClass: TClass; const aIndex: Integer; const aNewLocation: Pointer): Boolean;
begin
  Result := not Enabled and (aClass <> nil);
  if Result then
  begin
    FMethodClass := aClass; 
    FMethodIndex := aIndex; 
    FMethodNewLocation := aNewLocation;
    Result := _InjectVirtualMethod();
    if Result then
    begin
      FEnabled := True;
      FMethodType := mtVirtual;
    end;
  end;
end;

function TMeInjector.InjectDynamicMethod(const aClass: TClass; const aSlot: Integer; const aNewLocation: Pointer): Boolean;
begin
  Result := not Enabled and (aClass <> nil);
  if Result then
  begin
    FMethodClass := aClass; 
    FMethodIndex := aSlot; 
    FMethodNewLocation := aNewLocation;
    Result := _InjectDynamicMethod();
    if Result then
    begin
      FEnabled := True;
      FMethodType := mtDynamic;
    end;
  end;
end;

function TMeInjector.Inject(const aPatchLocation: Pointer; const aNewLocation: Pointer
  ; const aClass: TClass = nil; const aMethodType: TMethodType=mtUnknown): Boolean;
begin
  Result := not Enabled and (aPatchLocation <> nil);
  if Result = False then Exit;
  if aClass = nil then
  begin
    Result := InjectProcedure(aPatchLocation, aNewLocation); 
  end
  else begin
    //if IsAbstractMethod(aPatchLocation) then
      //raise EMeInjectorError.CreateRes(@rsInjectAbstractMethodError);
    case aMethodType of
      mtPublished:
      begin
        FMethodIndex := Integer(FindPublishedMethodEntryByAddr(aClass, aPatchLocation));
        Result := FMethodIndex <> 0;
        if Result then
          Result := InjectPublishedMethod(aClass, PPublishedMethodEntry(FMethodIndex), aNewLocation);
      end;
      mtVirtual: 
      begin
        FMethodIndex := FindVirtualMethodIndex(aClass, aPatchLocation);
        Result := FMethodIndex >= 0;
        if Result then
          Result := InjectVirtualMethod(aClass, FMethodIndex, aNewLocation);
      end;
      mtDynamic:
      begin
        FMethodIndex := FindDynamicMethodIndex(aClass, aPatchLocation);
        Result := FMethodIndex >= 0;
        if Result then
          Result := InjectDynamicMethod(aClass, FMethodIndex, aNewLocation);
      end;
      mtStatic:
      begin
        Result := InjectStaticMethod(aClass, aPatchLocation, aNewLocation);
      end;
      mtUnknown:
      begin
        FMethodIndex := Integer(FindPublishedMethodEntryByAddr(aClass, aPatchLocation));
        Result := FMethodIndex <> 0;
        if Result then
          Result := InjectPublishedMethod(aClass, PPublishedMethodEntry(FMethodIndex), aNewLocation);

        FMethodIndex := FindVirtualMethodIndex(aClass, aPatchLocation);
        Result := FMethodIndex >= 0;
        if Result then
        begin
          Result := InjectVirtualMethod(aClass, FMethodIndex, aNewLocation);
          Exit;
        end;
        FMethodIndex := FindDynamicMethodIndex(aClass, aPatchLocation);
        Result := FMethodIndex >= 0;
        if Result then
        begin
          Result := InjectDynamicMethod(aClass, FMethodIndex, aNewLocation);
          Exit;
        end;
        Result := InjectStaticMethod(aClass, aPatchLocation, aNewLocation);
      end;
    end;
  end;
end;

function TMeInjector.Inject(const aMethodName: string; const aNewLocation: Pointer
  ; const aClass: TClass; const aMethodType: TMethodType
  ; const aDirective: Integer): Boolean;
begin
  Result := aClass <> nil;
  if Result then
  begin
    FMethodIndex := Integer(FindPublishedMethodEntryByName(aClass, aMethodName));
    Result := FMethodIndex <> 0;
    if Result then
      Result := InjectStaticMethod(aClass, 
        PPublishedMethodEntry(FMethodIndex).Address, aNewLocation, aDirective);

    {//this will inject it to PMT, abondoned
    FMethodOriginalLocation := aClass.MethodAddress(aMethodName);
    Result := Inject(FMethodOriginalLocation, aNewLocation, aClass, aMethodType);
    //}
  end
end;

function TMeInjector.Inject:Boolean;
var
  vInjectProc: function: Boolean of object;
begin
  case FMethodType of
    mtPublished: vInjectProc := _InjectPublishedMethod;
    mtVirtual: vInjectProc := _InjectVirtualMethod;
    mtProcedure, mtStatic: vInjectProc := _InjectStaticMethod;
    mtDynamic: vInjectProc := _InjectDynamicMethod;
  else
    vInjectProc := nil;
  end;
  Result := @vInjectProc <> nil;
  if Result then 
    Result := vInjectProc();
end;

function TMeInjector.UnInject:Boolean;
var
  vUnInjectProc: function: Boolean of object;
begin
  case FMethodType of
    mtPublished: vUnInjectProc := _UnInjectPublishedMethod;
    mtVirtual: vUnInjectProc := _UnInjectVirtualMethod;
    mtProcedure, mtStatic: vUnInjectProc := _UnInjectStaticMethod;
    mtDynamic: vUnInjectProc := _UnInjectDynamicMethod;
  else
    vUnInjectProc := nil;
  end;
  Result := @vUnInjectProc <> nil;
  if Result then
  begin 
    Result := vUnInjectProc();
  end;
end;

function TMeInjector._InjectPublishedMethod: Boolean;
begin
  {$IFDEF THREADSAFE_SUPPORT}
  FLock.Enter;
  try
  {$ENDIF}

  FMethodOriginalLocation := PPublishedMethodEntry(FMethodIndex).Address;
  FMethodOriginalActualLocation := @PPublishedMethodEntry(FMethodIndex).Address;
  //FMethodOriginalActualLocation := GetActualAddress(FMethodOriginalActualLocation);
  WriteMem(FMethodOriginalActualLocation, @FMethodNewLocation, SizeOf(FMethodNewLocation));
  Result := True;

  {$IFDEF THREADSAFE_SUPPORT}
  finally
    FLock.Leave;
  end;
  {$ENDIF}
end;

function TMeInjector._InjectStaticMethod: Boolean;
begin
  {$IFDEF THREADSAFE_SUPPORT}
  FLock.Enter;
  try
  {$ENDIF}

  Result := PatchDirective(FMethodOriginalActualLocation, FMethodNewLocation, FMethodOriginalBackup, FMethodIndex);
  {$IFDEF STATIC_METHOD_THREADSAFE_SUPPORT}
  with FMethodOriginalBackup do
    if IsRedirectCodeNoop(FMethodOriginalBackup) then
    begin 
      Integer(FMethodOriginalActualLocation) := Integer(FMethodOriginalActualLocation) 
        + cNearJMPDirectiveSize;
    end
    {$IFNDEF STATIC_METHOD_SCRAMBLING_CODE_SUPPORT}
    else
      raise EMeInjectorError.CreateRes(@rsCanNotInjectError); 
    {$ENDIF}
  {$ENDIF}

  {$IFDEF THREADSAFE_SUPPORT}
  finally
    FLock.Leave;
  end;
  {$ENDIF}
end;

function TMeInjector._InjectVirtualMethod: Boolean;
begin
  {$IFDEF THREADSAFE_SUPPORT}
  FLock.Enter;
  try
  {$ENDIF}

  FMethodOriginalLocation := SetVirtualMethod(FMethodClass, FMethodIndex, FMethodNewLocation);
  Result := FMethodOriginalLocation <> nil;

  {$IFDEF THREADSAFE_SUPPORT}
  finally
    FLock.Leave;
  end;
  {$ENDIF}
end;

function TMeInjector._InjectDynamicMethod: Boolean;
begin
  {$IFDEF THREADSAFE_SUPPORT}
  FLock.Enter;
  try
  {$ENDIF}

  FMethodOriginalLocation := SetDynamicMethod(FMethodClass, FMethodIndex, FMethodNewLocation);
  Result := FMethodOriginalLocation <> nil;

  {$IFDEF THREADSAFE_SUPPORT}
  finally
    FLock.Leave;
  end;
  {$ENDIF}
end;

function TMeInjector._UnInjectPublishedMethod: Boolean;
var
  P: Pointer;
begin
  {$IFDEF THREADSAFE_SUPPORT}
  FLock.Enter;
  try
  {$ENDIF}

  ReadMem(FMethodOriginalActualLocation, @P, SizeOf(P));
  Result := P = FMethodNewLocation;
  if not Result then 
    raise EMeInjectorError.CreateRes(@rsInjectByOthersError); 
  WriteMem(FMethodOriginalActualLocation, @FMethodOriginalLocation, SizeOf(FMethodOriginalLocation));

  {$IFDEF THREADSAFE_SUPPORT}
  finally
    FLock.Leave;
  end;
  {$ENDIF}
end;

function TMeInjector._UnInjectStaticMethod: Boolean;
begin
  {$IFDEF THREADSAFE_SUPPORT}
  FLock.Enter;
  try
  {$ENDIF}

  {$IFDEF STATIC_METHOD_THREADSAFE_SUPPORT}
  with FMethodOriginalBackup do 
    if IsRedirectCodeNoop(FMethodOriginalBackup) then 
  //if (Offset = Integer(cX86NoOpDirective4Bytes)) and  (Jump = cX86NoOpDirective) then
    Integer(FMethodOriginalActualLocation) := Integer(FMethodOriginalActualLocation)
      - cNearJMPDirectiveSize;
  {$ENDIF}
  Result := IsPatchedDirective(FMethodOriginalActualLocation, FMethodNewLocation, FMethodIndex);
  if not Result then
    raise EMeInjectorError.CreateRes(@rsInjectByOthersError); 
  Result := UnPatchDirective(FMethodOriginalActualLocation, FMethodOriginalBackup);

  {$IFDEF THREADSAFE_SUPPORT}
  finally
    FLock.Leave;
  end;
  {$ENDIF}
end;

function TMeInjector._UnInjectVirtualMethod: Boolean;
var
  p: Pointer;
begin
  {$IFDEF THREADSAFE_SUPPORT}
  FLock.Enter;
  try
  {$ENDIF}

  p := GetVirtualMethod(FMethodClass, FMethodIndex);
  Result := p = FMethodNewLocation;
  if not Result then
    raise EMeInjectorError.CreateRes(@rsInjectByOthersError); 
  p := SetVirtualMethod(FMethodClass, FMethodIndex, FMethodOriginalLocation);
  Result := p <> nil;

  {$IFDEF THREADSAFE_SUPPORT}
  finally
    FLock.Leave;
  end;
  {$ENDIF}
end;

function TMeInjector._UnInjectDynamicMethod: Boolean;
var
  p: Pointer;
begin
  {$IFDEF THREADSAFE_SUPPORT}
  FLock.Enter;
  try
  {$ENDIF}

  p := GetDynamicMethodBySlot(FMethodClass, FMethodIndex);
  Result := p = FMethodNewLocation;
  if not Result then
    raise EMeInjectorError.CreateRes(@rsInjectByOthersError); 
  p := SetDynamicMethod(FMethodClass, FMethodIndex, FMethodOriginalLocation);
  Result := p <> nil;

  {$IFDEF THREADSAFE_SUPPORT}
  finally
    FLock.Leave;
  end;
  {$ENDIF}
end;

function TMeInjector.OriginalProc: Pointer;
begin
  {$IFDEF STATIC_METHOD_THREADSAFE_SUPPORT}
  if IsRedirectCodeNoop(FMethodOriginalBackup) then
    Result := FMethodOriginalActualLocation 
  else 
  {$ENDIF}
  {$IFDEF STATIC_METHOD_SCRAMBLING_CODE_SUPPORT}
    Result := @FMethodOriginalBackup; 
  {$ELSE}
    Result := nil;
  {$ENDIF}
end;

initialization
{$IFDEF THREADSAFE_SUPPORT}
  FLock.Create;
{$ENDIF}

finalization
{$IFDEF THREADSAFE_SUPPORT}
  FLock.Free(False);
{$ENDIF}
end.

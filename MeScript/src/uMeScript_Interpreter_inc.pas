{## the VM instructions ## }
procedure iVMNext(const aGlobalFunction: PMeScriptGlobalFunction); forward;

procedure iVMNext(const aGlobalFunction: PMeScriptGlobalFunction);
var
  vInstruction: TMeVMInstruction; //the instruction.
  vProc: TMeVMInstructionProc;
begin
  with aGlobalFunction^ do
    {$IFDEF FPC}
    While (psRunning in TMeScriptProcessorStates(LongWord(States))) do
    {$ELSE Borland}
    While (psRunning in TMeScriptProcessorStates(States)) do
    {$ENDIF}
    begin
      vInstruction := PMeVMInstruction(aGlobalFunction._PC.Mem)^;
      Inc(aGlobalFunction._PC.Mem);
      vProc := GMeScriptCoreWords[vInstruction];
      if Assigned(vProc) then
      begin
        vProc(aGlobalFunction);
      end
      else begin
        //BadOpError
        //_iVMHalt(errBadInstruction);
        //break;
      end;
    end;
end;


procedure VMAssignment(const aGlobalFunction: PMeScriptGlobalFunction);
{���������ں����ϵģ���δ���
  ��1�� ����ĳ������ʱ��ѹ��ԭ����_Func��_PC,��ֵ��ȫ�� _Func �� _PC. �޸ķ���ջ������Ϊ�� _Func, _PC���˳�������ԭԭ���ġ�
}
begin
end;

procedure VMCall(const aGlobalFunction: PMeScriptGlobalFunction);
begin
end;

procedure InitMeScriptCoreWordList;
begin
end;


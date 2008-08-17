{Summary MeScript VM Execution Core .}
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
    * The Original Code is $RCSfile: uMeScriptInterpreter.pas,v $.
    * The Initial Developers of the Original Code are Riceball LEE.
    * Portions created by Riceball LEE is Copyright (C) 2007-2008
    * All rights reserved.

    * Contributor(s):


}
unit uMeScriptInterpreter;

interface

{$I MeSetting.inc}

uses
  SysUtils
  , uMeScript
  , uMeScriptConsts
  ;

implementation

type
  //the Core VM instructions List
  {: ��������ָ��� } 
  TMeScriptCoreWords = array [TMeVMInstruction] of TMeVMInstructionProc;

var
  GMeScriptCoreWords: TMeScriptCoreWords;

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

initialization
  SetVMExecutorProc(iVMNext);
end.



{Summary MeRemote Function Client Invoker.}
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
    * The Original Code is $RCSfile: uMeRemoteFuncFeature.pas,v $.
    * The Initial Developers of the Original Code are Riceball LEE.
    * Portions created by Riceball LEE is Copyright (C) 2007-2008
    * All rights reserved.

    * Contributor(s):

}
unit uMeRemoteFuncFeature;

interface

{$I Setting.inc}

uses
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  SysUtils, Classes
  , TypInfo
  , uMeObject
  , uMeStream
  , uMeSysUtils
  , uMeTypes
  , uMeProcType
  , uMeInterceptor
  , uMeFeature
  , uMeTransport
  , uMeRemoteUtils
  ;

type
  TMeRemoteFuncFeature = class(TMeCustomInterceptor)
  protected
    FTransport: TMeClientTransport;
    function AllowExecute(Sender: TObject; MethodItem: TMeInterceptedMethodItem;
            const Params: PMeProcParams = nil): Boolean; override;
    procedure SetTransport(const Value: TMeClientTransport);
    procedure TransportFreeNotify(Instance : Pointer);
  public
    class function AddTo(aProc:Pointer; const aProcName: string;
            aMethodParams: PTypeInfo = nil; const aTransport: TMeClientTransport = nil): TMeAbstractInterceptor; overload;
    destructor Destroy; override;
    property Transport: TMeClientTransport read FTransport write SetTransport;
  end;

implementation

class function TMeRemoteFuncFeature.AddTo(aProc:Pointer; const aProcName: string;
         aMethodParams: PTypeInfo; const aTransport: TMeClientTransport): TMeAbstractInterceptor;
begin
  Result := inherited AddToProcedure(aProc, aProcName, aMethodParams);
  
  if Assigned(aTransport) then
    TMeRemoteFuncFeature(Result).Transport := aTransport;
end;

destructor TMeRemoteFuncFeature.Destroy;
begin
  //FreeAndNil(FTransport);
  Transport := nil;
  inherited;
end;

function TMeRemoteFuncFeature.AllowExecute(Sender: TObject; MethodItem: TMeInterceptedMethodItem;
            const Params: PMeProcParams): Boolean;
var
  vStream: PMeMemoryStream;
  vResultStream: PMeMemoryStream;
begin
  Result := False; //do not execute the Original Proc.
  if Assigned(FTransport) then
  begin
    New(vStream, Create);
    New(vResultStream, Create);
    try
      //vStream.WriteString(MethodItem.Name);
      if Assigned(Params) then
      begin
        SaveParamsToStream(Params, vStream);
      end;
      FTransport.Send(MethodItem.Name, vStream, vResultStream);
      vResultStream.Seek(0, soBeginning);
      if Assigned(Params) then
      begin
        LoadParamsFromStream(Params, vResultStream);
      end;
    finally
      vStream.Free;
      vResultStream.Free;
    end;
  end;
end;

procedure TMeRemoteFuncFeature.SetTransport(const Value: TMeClientTransport);
begin
  if FTransport <> Value then
  begin
    if Assigned(FTransport) then
    begin
      RemoveFreeNotification(FTransport, TransportFreeNotify);
    end;
    FTransport := Value;
    if Assigned(FTransport) then
      AddFreeNotification(Pointer(FTransport), TransportFreeNotify);
  end;
end;

procedure TMeRemoteFuncFeature.TransportFreeNotify(Instance : Pointer);
begin
  if FTransport = Instance then
    FTransport := nil;
end;

initialization
end.

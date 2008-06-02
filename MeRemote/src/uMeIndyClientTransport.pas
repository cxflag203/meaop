
{Summary Indy Client MeTransport class.}
{
   @author  Riceball LEE(riceballl@hotmail.com)
   @version $Revision: 1.00 $

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
    * The Original Code is $RCSfile: uMeIndyClientTransport.pas,v $.
    * The Initial Developers of the Original Code are Riceball LEE.
    * Portions created by Riceball LEE is Copyright (C) 2008
    * All rights reserved.

    * Contributor(s):

}
unit uMeIndyClientTransport;

{$I MeSetting.inc}
{$IFNDEF MeRTTI_EXT_SUPPORT}
  {$Message Fatal 'need MeRTTI_EXT_SUPPORT'}
{$ENDIF}

interface

uses
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  SysUtils, Classes
  , uMeObject
  , uMeTransport
  , uMeRemoteUtils
  , IdTCPConnection, IdTCPClient
  ;

type
  {Binary protocol
    C: cmd aMethodName<LN>
    S: 200 //one byte for status, 200 for ok
    C: <StreamSize><Stream> //the StreamSize is Int32 (open IOHandler.LargeStream = true for int64)
    S: <StreamSize><Stream>
  }
  TMeIndyBinClient = class(TIdTCPClientCustom)
  protected
  public
    procedure SendCmd(const aCmd: string; const aRequest: PMeStream; const aReply: PMeStream); overload;
  end;

  TMeIndyClientTransport = class(TMeTransport)
  protected
    FClient: TMeIndyBinClient;
    //procedure iSendAsyn(const aCmd: string; const aRequest: TStream; const aReply: PMeStream; const aTimeOut: Integer = 0);override;
    procedure iSend(const aCmd: string; const aRequest: PMeStream; const aReply: PMeStream);override;
    procedure iConnect();override;
    procedure iDisconnect();override;
    procedure iURLChanged;override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

const 
  cDefaultPort = 8000; 

implementation

{ TMeIndyBinClient }
procedure TMeIndyBinClient.SendCmd(const aCmd: string; const aRequest: PMeStream; const aReply: PMeStream); 
var
  b: Byte;
  vStream: TMeStreamProxy;
begin
  CheckConnected;
  IOHandler.WriteLn('cmd '+ aCmd);
  CheckConnected;
  b := IOHandler.ReadByte;
  if b <> 200 then
    raise Exception.Create('Can not Execute Cmd: '+ aCmd + ' Error Status:' + IntToStr(b));
  CheckConnected;
  vStream := TMeStreamProxy.Create(aRequest);
  try
    //true: write the stream size first.
    IOHandler.Write(vStream, 0, True);
    CheckConnected;
    vStream.MeStream := aReply;
    IOHandler.ReadStream(vStream);
  finally
    vStream.Free;
  end;
end;

{ TMeIndyClientTransport }
constructor TMeIndyClientTransport.Create;
begin
  inherited;
  FClient := TMeIndyBinClient.Create(nil);
end;

destructor TMeIndyClientTransport.Destroy;
begin
  FClient.Free;
  inherited;
end;

procedure TMeIndyClientTransport.iConnect();
begin
  FClient.Connect;
end;

procedure TMeIndyClientTransport.iDisconnect();
begin
  FClient.Disconnect;
end;

procedure TMeIndyClientTransport.iSend(const aCmd: string; const aRequest: PMeStream; const aReply: PMeStream);
begin
  FClient.SendCmd(aCmd, aRequest, aReply);
end;

procedure TMeIndyClientTransport.iURLChanged;
var
  i: Integer;
begin
  if FURL <> '' then
  begin
    i := Pos(':', FURL);
    if i>0 then
    begin
      FClient.Host := Copy(FURL, 1, i-1);
      FClient.Port := StrToIntDef(Copy(FURL, i+1, MaxInt), cDefaultPort);
    end
    else 
    begin
      FClient.Host := FURL;
      FClient.Port := cDefaultPort;
    end;
  end;
end;

initialization
end.
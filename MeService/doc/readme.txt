The MeService Library is a mini general SOA(service-oriented architecture) system framework

Purpose:
  1. Fast and Small 
  2. Mini Remote Service Library
  3. Mini Local Plugin(DLL) Library

Vocatons(�ʻ��):
Host:
Service:
Plugin: the plugin is a special local service for DLL.
System Plugin: 

the unit Levels:

uMeServiceTypes
  uMeService
    uMeServiceMgr
      uMePluginMgr
    uMePlugin : the plugin features implement in it(for Delphi object).
      DLL plugin MUST export 3 funcions: ServiceInfo, InitializeService,  TerminateService
      One DLL means one plugin ONLY.

plugin flowchart(����):
  Host Load System Plugin via LoadFromDLL check three functions whether exists.
    call ServiceInfo function to retreive the plugin info.
    Initialize system plugin:
      then Fill the ServiceInitInfo
      Notity the System.OnLoaded(aPlugin) Event
      Call the System.GetPluginFolder function to get the plugin folder
      Load the plugins from the PluginFolder
      Initialize plugins
      Notity the System.OnAllLoaded() Event

  ���ȼ���ϵͳ�����Ϊ����֤ϵͳ���������ͨ��ָ��������Կ��
    ϵͳ������뻹��export һ�������� exchageKey(const aKey: PAnsiChar): Integer;
    ���߲����������Ǳ����� system.Version(const aKey: PAnsiChar; const aSize: Cardinal): Integer;
      ���е����ֶ�����ָ�����뱻�滻������ system �汾��.����ǿվ�ֻ���ذ汾�š�
    ��ϵͳ�������������Щ������Լ����յ��ø������ز���ĳ�ʼ�����̡�

  ��Ҫ���ǵı��˱�д��Service api��һ�����̰߳�ȫ�ģ��ڶ��߳�����δ���
  ��һ�������Ǽ����̣߳�������֣���ʹ��windows�� APC����(QueueUserAPC)������Ҫ�����ڿ��б������
  Handle := 0;
  MsgWaitForMultipleObjectsEx(0, Handle, INFINITE, QS_ALLINPUT, MWMO_ALERTABLE); 
  ������SleepEx(1, true)���� alertable Ϊ�棬�ŵ����߳��첽���еĺ�����
  ��������������ƽ̨������


Service URN declaration samples:
  Function: System/Connection/UIService/Member.Enum
  Event: System/Connection.OnConnect

System Service:
  Functions:
    System.RegisterFunction
    System.RegisterEvent
    System.GetFunction(aName: TMeIdentity; const aProcParams: PTypeInfo = nil): HMeServiceFunction;
    System.GetFunctionPtr(const aFunc: TMeIdentity; const aProcInfo: Pointer= nil): Pointer;
    System.GetEvent(aName: TMeIdentity): HMeServiceEvent;
    System.CallFunction
    System.Notify(const aHandle: HMeServiceEvent; const wParam, lParam: Cardinal): Integer;
    System.NotifyByName(const aName: TMeIdentity; const wParam, lParam: Cardinal): Integer;
    System.HookEvent
    System.UnHookEvent
  Events:
    System.OnLoaded(aPlugin) : triggered when the aPlugin loaded.
    System.OnModulesLoaded() : triggered when all modules loaded.
  
Local:
  PluginMgr load plugin from DLL.
  PluginMgr ---> SerivceMgr
    manage the ServiceInfo --> CustomService 
  plugin features implementation in:  CustomPlugin --> CustomService --> AbstractService

Remote:
  1. Client: Crete RPC Plugin to do so.
       RemoteClientTransportPlugin
       RemoteClientPlugin
  2. Server: 
       RemoteServiceMgr --> PluginMgr
       RemoteServerTransportPlugin --> Plugin

���̵���֧������ģʽ:
  1. ���õĹ̶�����ģʽ: wParam, lParam
  2. ��ǿģʽ���������ģʽ����������ͨ�� VariantArray. ��δʵ�֣�ͨ�����뿪�ش�: SUPPORTS_MESERVICE_CALLEX��

ע���¼�ֻ֧�̶ֹ�����ģʽ��

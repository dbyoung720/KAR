program KAR;

uses
  Winapi.Windows, Winapi.TlHelp32, System.SysUtils, Winapi.PsAPI;

{ ɱ������ }
function KillTask(ExeFileName: string): String;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop   : Boolean;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  hProcess       : THandle;
  PathName       : array [0 .. 1023] of Char;
begin
  Result                 := '';
  FSnapshotHandle        := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop           := Process32First(FSnapshotHandle, FProcessEntry32);

  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) = UpperCase(ExeFileName))) then
    begin
      hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, FProcessEntry32.th32ProcessID);
      GetModuleFileNameEx(hProcess, FProcessEntry32.th32ModuleID, PathName, 1024);
      Result := PathName;
      TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), FProcessEntry32.th32ProcessID), 0);
    end;
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

procedure KillAndRun(const strProcessName: String);
var
  strFileName: String;
begin
  strFileName := KillTask(strProcessName);              // ɱ������
  Sleep(3000);                                          // ��ʱ���ȴ����̽���
  WinExec(PAnsiChar(AnsiString(strFileName)), SW_SHOW); // �ٴ�����ɱ���Ľ���
end;

begin
  if ParamCount < 1 then
  begin
    MessageBox(0, '��������Ҫɱ���Ľ�������', 'ϵͳ��ʾ��', MB_ICONERROR);
    Exit;
  end;
  KillAndRun(ParamStr(1));

end.

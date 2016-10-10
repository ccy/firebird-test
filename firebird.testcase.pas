unit firebird.testcase;

interface

uses
  System.SysUtils, System.AnsiStrings, Winapi.Windows,
  DUnitX.TestFramework, Firebird;

{$WARN SYMBOL_PLATFORM OFF}

type
  [TestFixture]
  TFirebird_Test = class(TObject)
  private
    FClientHandle: THandle;
    FUtil: IUtil;
    FStatus: IStatus;
	  FProvider: IProvider;
  protected
    procedure CORE_5370;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure CORE_5370_Test;
  end;

implementation

uses System.IOUtils;

procedure TFirebird_Test.Setup;
var fb_get_master_interface: function: IMaster; cdecl;
    master: IMaster;
begin
  FClientHandle := LoadLibrary('Firebird-3.0.1\fbclient.dll');
  CheckOSError(GetLastError);

  fb_get_master_interface := GetProcAddress(FClientHandle, 'fb_get_master_interface');
  CheckOSError(GetLastError);

	master := fb_get_master_interface;
	FUtil := master.getUtilInterface;
	FStatus := master.getStatus;
	FProvider := master.getDispatcher;
end;

procedure TFirebird_Test.TearDown;
begin
  Win32Check(FreeLibrary(FClientHandle));
end;

procedure TFirebird_Test.CORE_5370;
var dpb: IXpbBuilder;
    att: IAttachment;
    tra: ITransaction;
    sTable: string;
    i: Integer;
begin
  // create DPB
	dpb := FUtil.getXpbBuilder(FStatus, IXpbBuilder.DPB, nil, 0);
	dpb.insertInt(FStatus, isc_dpb_page_size, 16 * 1024);
	dpb.insertString(FStatus, isc_dpb_user_name, 'sysdba');
	dpb.insertString(FStatus, isc_dpb_password, 'masterkey');

  // create empty database
	att := FProvider.createDatabase(FStatus, PAnsiChar(AnsiString('localhost:' + TPath.GetTempPath + 'DB_5370.FDB')), dpb.getBufferLength(FStatus), dpb.getBuffer(FStatus));
  try
    // start transaction
    for i := 1 to 40000 do begin
      tra := att.startTransaction(FStatus, 0, nil);
      sTable := Format('T_%d_%d', [GetCurrentProcessID, i]);
      att.execute(FStatus, tra, 0, PAnsiChar(AnsiString('create table ' + sTable + '(Code varchar(10))')), 3, nil, nil, nil, nil);
      att.execute(FStatus, tra, 0, PAnsiChar(AnsiString(Format('create index %s_I on %s(Code) ', [sTable, sTable]))), 3, nil, nil, nil, nil);
      tra.commitRetaining(FStatus);
      att.execute(FStatus, tra, 0, PAnsiChar(AnsiString('drop table ' + sTable)), 3, nil, nil, nil, nil);
      tra.commit(FStatus);
      if i mod 100 = 0 then
        OutputDebugString(PChar(i.ToString));
    end;
	finally
    att.dropDatabase(FStatus);
  end;
end;

procedure TFirebird_Test.CORE_5370_Test;
var Buf: PAnsiChar;
    BufSize: Cardinal;
begin
  try
    CORE_5370;
  except
    on E: FbException do begin
      BufSize := 1024;
      Buf := AnsiStrAlloc(BufSize);
      try
        while FUtil.formatStatus(Buf, BufSize, E.getStatus) = 0 do begin
          System.AnsiStrings.StrDispose(Buf);
          Inc(BufSize, BufSize);
        end;
        raise Exception.Create(string(AnsiString(Buf)));
      finally
        System.AnsiStrings.StrDispose(Buf);
      end;
    end else
      raise;
  end;
end;

end.

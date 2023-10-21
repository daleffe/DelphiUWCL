unit UCL.Threading;

interface

{$IF CompilerVersion > 29}
  {$LEGACYIFEND ON}
{$IFEND}

uses
  Classes
{$IF CompilerVersion > 29}
  , Threading
{$IFEND}
  ;

type
  TControlThreadSyncProc = reference to function (V: Integer): Boolean;
  TControlThreadDoneProc = reference to procedure;

  TControlThread = class(TThread)
    var CurrentValue: Integer;

    private
      FOnSync: TControlThreadSyncProc;
      FOnDone: TControlThreadDoneProc;
      FStartValue: Integer;
      FDeltaValue: Integer;
      FBreakLoop: Boolean;

    protected
      procedure UpdateControl;
      procedure DoneControl;
      function UpdateFunction: Boolean; virtual;

      procedure Execute; override;

    public
      constructor Create(aStartValue, aDeltaValue: Integer; aSyncProc: TControlThreadSyncProc; aDoneProc: TControlThreadDoneProc); virtual;
      destructor Destroy; override;

      //  Events
      property OnSync: TControlThreadSyncProc read FOnSync write FOnSync;
      property OnDone: TControlThreadDoneProc read FOnDone write FOnDone;

      //  Properties
      property StartValue: Integer read FStartValue write FStartValue default 0;
      property DeltaValue: Integer read FDeltaValue write FDeltaValue default 0;
  end;

implementation

{ TControlThread }

constructor TControlThread.Create(aStartValue, aDeltaValue: Integer; aSyncProc: TControlThreadSyncProc; aDoneProc: TControlThreadDoneProc);
begin
  inherited Create(True);
  FreeOnTerminate := False;

  //  Internal
  CurrentValue := 0;

  //  Fields
  FStartValue := aStartValue;
  FDeltaValue := aDeltaValue;
  FOnSync := aSyncProc;
  FOnDone := aDoneProc;

  //  Finish
  UpdateFunction;
end;

destructor TControlThread.Destroy;
begin
// nothing here, but declare it for future use
  inherited;
end;

procedure TControlThread.Execute;
begin
  //  Update easing function
  //  If Result = false (error found), then exit
  if not UpdateFunction then
    Exit;

  CurrentValue := FDeltaValue;
  Synchronize(UpdateControl);
  if FBreakLoop then
    Terminate; // jumps to last synchronize call

  while not Terminated do begin
    //Inc(CurrentValue, FDeltaValue);
    Synchronize(UpdateControl);
    if FBreakLoop then
      Terminate; // exits the loop
  end;

  Synchronize(DoneControl);
end;

procedure TControlThread.UpdateControl;
begin
  if Assigned(FOnSync) then
    FBreakLoop:=not FOnSync(CurrentValue);
end;

procedure TControlThread.DoneControl;
begin
  if Assigned(FOnDone) then
    FOnDone();
end;

function TControlThread.UpdateFunction: Boolean;
begin
  Result := True;
end;

end.

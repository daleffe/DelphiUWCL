unit UCL.IntAnimation;

interface

{$IF CompilerVersion > 29}
  {$LEGACYIFEND ON}
{$IFEND}

uses
  Classes,
  UCL.Threading
//{$IF CompilerVersion > 29}
//  , Threading
//{$IFEND}
  ;

type
  TAniSyncProc = TControlThreadSyncProc;
  TAniDoneProc = TControlThreadDoneProc;
  TAniFunction = reference to function (P: Single): Single;

  TAniKind = (akIn, akOut, akInOut);

  TAniFunctionKind =
  (
    afkLinear, afkQuadratic, afkCubic, afkQuartic, afkQuintic,
    afkBack, afkBounce, afkExpo, afkSine, afkCircle
  );

  TIntAniSet = class(TPersistent)
  private
    FAniKind: TAniKind;
    FAniFunctionKind: TAniFunctionKind;
    FDelayStartTime: Cardinal;
    FDuration: Cardinal;
    FStep: Cardinal;
    FQueue: Boolean;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure QuickAssign(AniKind: TAniKind; AniFunctionKind: TAniFunctionKind; Delay, Duration, Step: Cardinal; Queue: Boolean = False);
  published
    property AniKind: TAniKind read FAniKind write FAniKind;
    property AniFunctionKind: TAniFunctionKind read FAniFunctionKind write FAniFunctionKind;
    property DelayStartTime: Cardinal read FDelayStartTime write FDelayStartTime;
    property Duration: Cardinal read FDuration write FDuration;
    property Step: Cardinal read FStep write FStep;
    property Queue: Boolean read FQueue write FQueue default False;
  end;

  TIntAni = class(TControlThread)
  private
    var AniFunction: TAniFunction;

    FAniSet: TIntAniSet;

  protected
    function UpdateFunction: Boolean; override;

    procedure Execute; override;

  public
    constructor Create(aStartValue, aDeltaValue: Integer; aSyncProc: TAniSyncProc; aDoneProc: TAniDoneProc); override;
    destructor Destroy; override;

    //  Properties
    property AniSet: TIntAniSet read FAniSet write FAniSet;
  end;

implementation

uses
  SysUtils,
  Math,
  UCL.IntAnimation.Collection;

{ SPECIAL }

function TIntAni.UpdateFunction: Boolean;
begin
  Result := True;
  case AniSet.AniKind of
    akIn:
      case AniSet.AniFunctionKind of
        afkLinear:
          AniFunction := TIntAniCollection.Linear;
        afkQuadratic:
          AniFunction := TIntAniCollection.Quadratic_In;
        afkCubic:
          AniFunction := TIntAniCollection.Cubic_In;
        afkQuartic:
          AniFunction := TIntAniCollection.Quartic_In;
        afkQuintic:
          AniFunction := TIntAniCollection.Quintic_In;
        afkBack:
          AniFunction := TIntAniCollection.Back_In;
        afkBounce:
          AniFunction := TIntAniCollection.Bounce_In;
        afkExpo:
          AniFunction := TIntAniCollection.Expo_In;
        afkSine:
          AniFunction := TIntAniCollection.Sine_In;
        afkCircle:
          AniFunction := TIntAniCollection.Circle_In;
        else
          Result := False;
      end;

    akOut:
      case AniSet.AniFunctionKind of
        afkLinear:
          AniFunction := TIntAniCollection.Linear;
        afkQuadratic:
          AniFunction := TIntAniCollection.Quadratic_Out;
        afkCubic:
          AniFunction := TIntAniCollection.Cubic_Out;
        afkQuartic:
          AniFunction := TIntAniCollection.Quartic_Out;
        afkQuintic:
          AniFunction := TIntAniCollection.Quintic_Out;
        afkBack:
          AniFunction := TIntAniCollection.Back_Out;
        afkBounce:
          AniFunction := TIntAniCollection.Bounce_Out;
        afkExpo:
          AniFunction := TIntAniCollection.Expo_Out;
        afkSine:
          AniFunction := TIntAniCollection.Sine_Out;
        afkCircle:
          AniFunction := TIntAniCollection.Circle_Out;
        else
          Result := False;
      end;

    akInOut:
      case AniSet.AniFunctionKind of
        afkLinear:
          AniFunction := TIntAniCollection.Linear;
        afkQuadratic:
          AniFunction := TIntAniCollection.Quadratic_InOut;
        afkCubic:
          AniFunction := TIntAniCollection.Cubic_InOut;
        afkQuartic:
          AniFunction := TIntAniCollection.Quartic_InOut;
        afkQuintic:
          AniFunction := TIntAniCollection.Quintic_InOut;
        afkBack:
          AniFunction := TIntAniCollection.Back_InOut;
        afkBounce:
          AniFunction := TIntAniCollection.Bounce_InOut;
        afkExpo:
          AniFunction := TIntAniCollection.Expo_InOut;
        afkSine:
          AniFunction := TIntAniCollection.Sine_InOut;
        afkCircle:
          AniFunction := TIntAniCollection.Circle_InOut;
        else
          Result := False;
      end;

    else
      Result := False;
  end;
end;

{ MAIN CLASS }

constructor TIntAni.Create(aStartValue: Integer; aDeltaValue: Integer; aSyncProc: TAniSyncProc; aDoneProc: TAniDoneProc);
begin
  //  Internal
  AniFunction := Nil;

  //  AniSet
  FAniSet := TIntAniSet.Create;
  FAniSet.QuickAssign(akOut, afkLinear, 0, 200, 20);

  inherited Create(aStartValue, aDeltaValue, aSyncProc, aDoneProc);
  FreeOnTerminate := True;

  //  Finish
  UpdateFunction;
end;

destructor TIntAni.Destroy;
begin
  FAniSet.Free;
  inherited;
end;

procedure TIntAni.Execute;
var
  i: Cardinal;
  t, d, TimePerStep: Cardinal;
  b, c: Integer;
begin
  if not UpdateFunction then
    Exit;
    ///  Update easing function
    ///  Depend on AniKind (In, Out,...) and AniFunctionKind (Linear,...)
    ///  If Result = false (error found), then exit

  d := AniSet.Duration;
  b := StartValue;
  c := DeltaValue;

  //  Delay start
  Sleep(AniSet.DelayStartTime);

  //  Calc step by FPS
  TimePerStep := Round(d / AniSet.Step);

  //  Run
  for i := 1 to AniSet.Step - 1 do
    begin
      t := i * TimePerStep;
      CurrentValue := b + Round(c * AniFunction(t / d));
      if AniSet.Queue then
        Queue(UpdateControl)
      else
        Synchronize(UpdateControl);
      Sleep(TimePerStep);
    end;

  //  Last step
  t := d;
  CurrentValue := b + Round(c * AniFunction(t / d));
  if AniSet.Queue then
    Queue(UpdateControl)
  else
    Synchronize(UpdateControl);

  //  Finish
//  if AniSet.Queue then
//    Queue(Nil, DoneControl)
//  else
    Synchronize(DoneControl);
end;

{ TIntAniSet }

constructor TIntAniSet.Create;
begin
  inherited Create;
  FAniKind := akOut;
  FAniFunctionKind := afkLinear;
  FDelayStartTime := 0;
  FDuration := 200;
  FStep := 20;
  FQueue := False;
end;

procedure TIntAniSet.Assign(Source: TPersistent);
begin
  if Source is TIntAniSet then begin
    FAniKind := (Source as TIntAniSet).AniKind;
    FAniFunctionKind := (Source as TIntAniSet).AniFunctionKind;
    FDelayStartTime := (Source as TIntAniSet).DelayStartTime;
    FDuration := (Source as TIntAniSet).Duration;
    FStep := (Source as TIntAniSet).Step;
    FQueue := (Source as TIntAniSet).Queue;
  end
  else
    inherited;
end;

procedure TIntAniSet.QuickAssign(AniKind: TAniKind; AniFunctionKind: TAniFunctionKind; Delay, Duration, Step: Cardinal; Queue: Boolean = False);
begin
  FAniKind := AniKind;
  FAniFunctionKind := AniFunctionKind;
  FDelayStartTime := Delay;
  FDuration := Duration;
  FStep := Step;
  FQueue := Queue;
end;

end.

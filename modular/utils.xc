; Shared constants and configuration

; Component aliases
const $RADAR_DISPLAY = "Dashboard_0" ; 2x2 grid radar screens
const $LOG_DISPLAY = "Dashboard_1" ; Contact log dashboard
const $CTL_DISPLAY = "Dashboard_2" ; Controls/buttons dashboard
const $TRACK_DISPLAY = "Dashboard_3" ; In-range contacts dashboard
const $BZ = "SPKR_0" ; Buzzer alias
const $NAV = "NAV" ; Ground station NavInstrument
const $BCN_RX = "BCN_RX" ; Receive beacon
const $BCN_TX = "BCN_TX" ; Transmit beacon (reserved)
const $RAD_MOTOR = "RAD_MOTOR" ; Small Pivot rotating the dish
const $CLOCK_BCN = "CLOCK_BCN" ; Clock beacon (receives sun angle 0-360 on freq 1944)

; Math constants
const $PI = 3.14159265
const $TWO_PI = 6.28318530

; Radar parameters (must be defined before init uses $MAX_RANGE_KM)
const $SWEEP_DEG_PER_TICK = 8 ; ~8 deg per tick @25Hz -> full rotation ~1.8s
const $MAX_RANGE_KM = 400 ; logical max range represented by outer ring
const $RESPAWN_RANGE_KM = 408 ; aircraft beyond this respawn closer with inbound heading
const $RING_COUNT = 4
const $TIME_SCALE = 30 ; speed multiplier for aircraft movement (1=normal, 10=10x faster)
var $SIM_ENABLED = 1 ; 1=simulate targets, 0=accept external telemetry only (runtime toggle)

; Hardware alignment/calibration
const $RAD_MOTOR_PHASE = 0 ; radians: + rotates motor ahead of sweep, - lags
const $RAD_MOTOR_MAX_RPS = 1.0 ; Small Pivot Max Rotation Speed configured in-game (rot/s)
const $RAD_MOTOR_DIR = -1 ; +1 or -1 to match physical rotation direction to sweep



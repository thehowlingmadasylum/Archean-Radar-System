; Screen handles and runtime scalar state

; Radar display screens (2x2 grid)
var $s0 = screen($RADAR_DISPLAY, 0)
var $s1 = screen($RADAR_DISPLAY, 1)
var $s2 = screen($RADAR_DISPLAY, 2)
var $s3 = screen($RADAR_DISPLAY, 3)

; Contact log dashboard screens
var $d1_top = screen($LOG_DISPLAY, 1) ; top
var $d1_bot = screen($LOG_DISPLAY, 0) ; bottom (reserved)

; In-range contacts dashboard (Dashboard_3)
var $d3 = screen($TRACK_DISPLAY, 0) ; top screen
var $d3_bot = screen($TRACK_DISPLAY, 1) ; bottom screen

; Runtime state
var $sweep = 0 ; radians
var $labelPhase = 0 ; cycles [0..3] telemetry detail
var $tickCount = 0
var $turn = 0 ; increments each time sweep wraps 0->2π
var $sweepPrev = 0 ; previous sweep angle (radians)
var $wrapped = 0 ; 1 when sweep crossed 2π this tick

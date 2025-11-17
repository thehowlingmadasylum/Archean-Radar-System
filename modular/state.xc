; Arrays, state, and counters

; Per-screen layout controls (pixels and scale)
array $offsetX : number
array $offsetY : number
array $scale   : number

; Render geometry (set by render.xc each frame)
var $renderGCX = 0
var $renderGCY = 0
var $renderR = 0
var $renderOX0 = 0
var $renderOY0 = 0
var $renderOX1 = 0
var $renderOY1 = 0
var $renderOX2 = 0
var $renderOY2 = 0
var $renderOX3 = 0
var $renderOY3 = 0

; Simulated targets (change N to add/remove)
const $N = 50
array $ax : number ; km (east)
array $ay : number ; km (north)
array $spd : number ; m/s
array $hdg : number ; degrees (0=north, 90=east)
array $alt : number ; m
array $vs  : number ; m/s
array $id  : text
array $dispAx : number ; last scanned east km
array $dispAy : number ; last scanned north km
array $scanTurn : number ; last sweep turn index when updated
array $vis : number ; 1=visible/in-range, 0=hidden/out-of-range
array $visPrev : number ; previous visibility to detect transitions
array $labelPos : number ; label position for each aircraft (0=top-right, 1=top-left, 2=bottom-right, 3=bottom-left)

; Contact log (recent history) for Dashboard_1 top screen
const $LOG_MAX = 80
array $logId : text
array $logWhen : text
array $logStatus : text ; "ACQ" or "LOST"
array $logX : number
array $logY : number
var $logCount = 0
var $logTotal = 0 ; cumulative events counter (not capped by LOG_MAX)
var $uptimeTicks = 0 ; used for session timestamp text
var $logTmpIdx = -1 ; temp for logging helpers

; Runtime mode tracking
var $simPrev = -1 ; track last applied simulation mode

; Dynamic spawning system
var $spawnTimer = 0 ; ticks since last spawn attempt
const $SPAWN_CHECK_INTERVAL = 75 ; check for spawn every ~3 seconds (75 ticks @ 25Hz)
var $trafficDensity = 0.00002 ; current traffic density (varies over time)
const $MIN_DENSITY = 0.00001 ; minimum traffic (low traffic times)
const $MAX_DENSITY = 0.00008 ; maximum traffic (rush hour)
var $densityChangeTimer = 0 ; timer for density variation
const $DENSITY_CHANGE_INTERVAL = 1250 ; change density every ~50 seconds
var $activeTargets = 0 ; current count of active (non-empty) targets

; Respawn system globals (shared by simulation)
var $respawnX = 0
var $respawnY = 0
var $respawnHdg = 0
var $respawnSpd = 0
var $respawnAlt = 0
var $respawnVs = 0

; Generic geodesic inputs to avoid cross-file dependency
var $geoInNorthKm = 0
var $geoInEastKm = 0
var $geoInLat = 0
var $geoInLon = 0

; Clock system (receives sun angle 0-360 from beacon on freq 1944)
var $sunAngle = 0 ; sun angle in degrees (0-360) from clock beacon
const $USE_24H_CLOCK = 0 ; 0=12-hour clock with AM/PM, 1=24-hour clock

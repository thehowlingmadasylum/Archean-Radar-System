; Aviation/navigation icon library for radar display
; Each icon function draws to all 4 screens with proper offset handling
; Uses global $iconOX0-3 and $iconOY0-3 for screen offsets (set before calling icons)
;
; USAGE EXAMPLE:
;   ; Set screen offsets for 2x2 grid
;   $iconOX0 = $ox0; $iconOY0 = $oy0
;   $iconOX1 = $ox1; $iconOY1 = $oy1
;   $iconOX2 = $ox2; $iconOY2 = $oy2
;   $iconOX3 = $ox3; $iconOY3 = $oy3
;   ; Draw icons in world coordinates
;   @icon_airport($worldX, $worldY, cyan)
;   @icon_waypoint(1500, 2000, magenta)
;   @icon_final_approach(3000, 500, 270, green)  ; heading 270 degrees

; ==============================================
; User-configurable ICON REGISTRY (lat/lon list)
; ==============================================
; Users: Edit @icons_user_config() at the bottom of this file to add your icons.
; Supported types:
;   1 = airport, 2 = minor_airport, 3 = waypoint, 4 = navaid, 5 = obstruction,
;   6 = prohibited, 7 = restricted, 8 = class_d, 9 = nuclear, 10 = final_approach,
;   11 = boundary, 12 = vor, 13 = ndb, 14 = dme, 15 = heliport, 16 = seaplane
; Colors: use color names (white, gray, cyan, magenta, green, yellow, red, etc.)

const $ICON_MAX = 128
array $iconType  : number
array $iconLat   : number
array $iconLon   : number
array $iconHead  : number  ; heading (deg) for types that need it (e.g., final_approach), else 0
array $iconColor : number
var $iconCount = 0

function @icons_clear()
	; Ensure arrays are allocated to capacity before any indexing
	$iconCount = 0
	$iconType.fill($ICON_MAX, 0)
	$iconLat.fill($ICON_MAX, 0)
	$iconLon.fill($ICON_MAX, 0)
	$iconHead.fill($ICON_MAX, 0)
	$iconColor.fill($ICON_MAX, 0)

function @icons_add($type : number, $lat : number, $lon : number, $headingDeg : number, $color : number)
	if $iconCount < $ICON_MAX
		$iconType.$iconCount  = $type
		$iconLat.$iconCount   = $lat
		$iconLon.$iconCount   = $lon
		$iconHead.$iconCount  = $headingDeg
		$iconColor.$iconCount = $color
		$iconCount++


; Screen offset globals (must be set by caller before drawing icons)
var $iconOX0 = 0
var $iconOY0 = 0
var $iconOX1 = 0
var $iconOY1 = 0
var $iconOX2 = 0
var $iconOY2 = 0
var $iconOX3 = 0
var $iconOY3 = 0
; Boundaries between the left/right and top/bottom screens (virtual canvas coords)
var $iconBX = 0 ; boundary X (equals OX1)
var $iconBY = 0 ; boundary Y (equals OY2)

; Icon drawing helpers - use global offsets
function @icon_pixel($x : number, $y : number, $color : number)
	if $x < $iconBX
		if $y < $iconBY
			$s0.draw_point($x - $iconOX0, $y - $iconOY0, $color)
		else
			$s2.draw_point($x - $iconOX2, $y - $iconOY2, $color)
	else
		if $y < $iconBY
			$s1.draw_point($x - $iconOX1, $y - $iconOY1, $color)
		else
			$s3.draw_point($x - $iconOX3, $y - $iconOY3, $color)

function @icon_line($x1 : number, $y1 : number, $x2 : number, $y2 : number, $color : number)
	; Choose target screen based on first endpoint (icons are small; clipping near seams is acceptable)
	var $tx = $x1
	var $ty = $y1
	if $tx < $iconBX
		if $ty < $iconBY
			$s0.draw_line($x1 - $iconOX0, $y1 - $iconOY0, $x2 - $iconOX0, $y2 - $iconOY0, $color)
		else
			$s2.draw_line($x1 - $iconOX2, $y1 - $iconOY2, $x2 - $iconOX2, $y2 - $iconOY2, $color)
	else
		if $ty < $iconBY
			$s1.draw_line($x1 - $iconOX1, $y1 - $iconOY1, $x2 - $iconOX1, $y2 - $iconOY1, $color)
		else
			$s3.draw_line($x1 - $iconOX3, $y1 - $iconOY3, $x2 - $iconOX3, $y2 - $iconOY3, $color)

function @icon_circle($x : number, $y : number, $r : number, $color : number)
	if $x < $iconBX
		if $y < $iconBY
			$s0.draw_circle($x - $iconOX0, $y - $iconOY0, $r, $color)
		else
			$s2.draw_circle($x - $iconOX2, $y - $iconOY2, $r, $color)
	else
		if $y < $iconBY
			$s1.draw_circle($x - $iconOX1, $y - $iconOY1, $r, $color)
		else
			$s3.draw_circle($x - $iconOX3, $y - $iconOY3, $r, $color)

function @icon_rect($x1 : number, $y1 : number, $x2 : number, $y2 : number, $color : number)
	var $tx = $x1
	var $ty = $y1
	if $tx < $iconBX
		if $ty < $iconBY
			$s0.draw_rect($x1 - $iconOX0, $y1 - $iconOY0, $x2 - $iconOX0, $y2 - $iconOY0, $color)
		else
			$s2.draw_rect($x1 - $iconOX2, $y1 - $iconOY2, $x2 - $iconOX2, $y2 - $iconOY2, $color)
	else
		if $ty < $iconBY
			$s1.draw_rect($x1 - $iconOX1, $y1 - $iconOY1, $x2 - $iconOX1, $y2 - $iconOY1, $color)
		else
			$s3.draw_rect($x1 - $iconOX3, $y1 - $iconOY3, $x2 - $iconOX3, $y2 - $iconOY3, $color)

; AIRPORT - Large circle with crossed runways
function @icon_airport($x : number, $y : number, $color : number)
	@icon_circle($x, $y, 6, $color)
	@icon_line($x - 4, $y, $x + 4, $y, $color)
	@icon_line($x, $y - 4, $x, $y + 4, $color)

; MINOR AIRPORT - Small circle with single line
function @icon_minor_airport($x : number, $y : number, $color : number)
	@icon_circle($x, $y, 4, $color)
	@icon_line($x - 3, $y, $x + 3, $y, $color)

; WAYPOINT/INTERSECTION - Triangle
function @icon_waypoint($x : number, $y : number, $color : number)
	@icon_line($x, $y - 5, $x - 4, $y + 3, $color)
	@icon_line($x - 4, $y + 3, $x + 4, $y + 3, $color)
	@icon_line($x + 4, $y + 3, $x, $y - 5, $color)

; NAVAID - Hexagon
function @icon_navaid($x : number, $y : number, $color : number)
	var $r = 5
	var $h = 4
	var $w = 3
	@icon_line($x - $w, $y - $h, $x + $w, $y - $h, $color)
	@icon_line($x + $w, $y - $h, $x + $r, $y, $color)
	@icon_line($x + $r, $y, $x + $w, $y + $h, $color)
	@icon_line($x + $w, $y + $h, $x - $w, $y + $h, $color)
	@icon_line($x - $w, $y + $h, $x - $r, $y, $color)
	@icon_line($x - $r, $y, $x - $w, $y - $h, $color)

; OBSTRUCTION - X mark with warning
function @icon_obstruction($x : number, $y : number, $color : number)
	@icon_line($x - 4, $y - 4, $x + 4, $y + 4, $color)
	@icon_line($x - 4, $y + 4, $x + 4, $y - 4, $color)
	@icon_circle($x, $y, 6, $color)

; PROHIBITED AREA - Circle with slash (red)
function @icon_prohibited($x : number, $y : number)
	@icon_circle($x, $y, 6, red)
	@icon_line($x - 4, $y - 4, $x + 4, $y + 4, red)

; RESTRICTED AREA - Dashed circle
function @icon_restricted($x : number, $y : number, $color : number)
	var $r = 6
	; Draw dashed circle (8 segments)
	@icon_line($x, $y - $r, $x + 2, $y - 5, $color)
	@icon_line($x + 4, $y - 4, $x + 5, $y - 2, $color)
	@icon_line($x + $r, $y, $x + 5, $y + 2, $color)
	@icon_line($x + 4, $y + 4, $x + 2, $y + 5, $color)
	@icon_line($x, $y + $r, $x - 2, $y + 5, $color)
	@icon_line($x - 4, $y + 4, $x - 5, $y + 2, $color)
	@icon_line($x - $r, $y, $x - 5, $y - 2, $color)
	@icon_line($x - 4, $y - 4, $x - 2, $y - 5, $color)

; CLASS D AIRSPACE - Dashed square
function @icon_class_d($x : number, $y : number, $color : number)
	var $sz = 5
	; Top
	@icon_line($x - $sz, $y - $sz, $x - 2, $y - $sz, $color)
	@icon_line($x + 2, $y - $sz, $x + $sz, $y - $sz, $color)
	; Right
	@icon_line($x + $sz, $y - $sz, $x + $sz, $y - 2, $color)
	@icon_line($x + $sz, $y + 2, $x + $sz, $y + $sz, $color)
	; Bottom
	@icon_line($x + $sz, $y + $sz, $x + 2, $y + $sz, $color)
	@icon_line($x - 2, $y + $sz, $x - $sz, $y + $sz, $color)
	; Left
	@icon_line($x - $sz, $y + $sz, $x - $sz, $y + 2, $color)
	@icon_line($x - $sz, $y - 2, $x - $sz, $y - $sz, $color)

; NUCLEAR FACILITY - Radiation symbol
function @icon_nuclear($x : number, $y : number)
	; Center dot
	@icon_circle($x, $y, 2, yellow)
	; Three radiation blades
	@icon_line($x, $y, $x, $y - 6, yellow)
	@icon_line($x, $y, $x - 5, $y + 3, yellow)
	@icon_line($x, $y, $x + 5, $y + 3, yellow)
	; Outer circle
	@icon_circle($x, $y, 7, yellow)

; FINAL APPROACH COURSE - Arrow pointing to runway
function @icon_final_approach($x : number, $y : number, $heading : number, $color : number)
	; Heading in degrees, 0=north
	var $rad = ($heading * $PI / 180)
	var $sin = sin($rad)
	var $cos = cos($rad)
	; Arrow shaft
	var $x1 = $x - $sin * 8
	var $y1 = $y + $cos * 8
	@icon_line($x1, $y1, $x, $y, $color)
	; Arrow head
	var $ax1 = $x - $sin * 3 - $cos * 3
	var $ay1 = $y + $cos * 3 - $sin * 3
	var $ax2 = $x - $sin * 3 + $cos * 3
	var $ay2 = $y + $cos * 3 + $sin * 3
	@icon_line($x, $y, $ax1, $ay1, $color)
	@icon_line($x, $y, $ax2, $ay2, $color)

; AIRSPACE BOUNDARY MARKER - Diamond
function @icon_boundary($x : number, $y : number, $color : number)
	@icon_line($x, $y - 5, $x + 4, $y, $color)
	@icon_line($x + 4, $y, $x, $y + 5, $color)
	@icon_line($x, $y + 5, $x - 4, $y, $color)
	@icon_line($x - 4, $y, $x, $y - 5, $color)

; VOR STATION - Compass rose
function @icon_vor($x : number, $y : number, $color : number)
	@icon_circle($x, $y, 6, $color)
	; Cardinal spokes
	@icon_line($x, $y - 6, $x, $y - 3, $color)
	@icon_line($x + 6, $y, $x + 3, $y, $color)
	@icon_line($x, $y + 6, $x, $y + 3, $color)
	@icon_line($x - 6, $y, $x - 3, $y, $color)

; NDB STATION - Solid dot with circle
function @icon_ndb($x : number, $y : number, $color : number)
	; Filled center
	@icon_circle($x, $y, 2, $color)
	@icon_pixel($x, $y, $color)
	@icon_pixel($x + 1, $y, $color)
	@icon_pixel($x - 1, $y, $color)
	@icon_pixel($x, $y + 1, $color)
	@icon_pixel($x, $y - 1, $color)
	; Outer circle
	@icon_circle($x, $y, 4, $color)

; DME STATION - Square with center dot
function @icon_dme($x : number, $y : number, $color : number)
	@icon_rect($x - 4, $y - 4, $x + 4, $y + 4, $color)
	@icon_pixel($x, $y, $color)

; HELIPORT - H in circle
function @icon_heliport($x : number, $y : number, $color : number)
	@icon_circle($x, $y, 5, $color)
	; H shape
	@icon_line($x - 2, $y - 3, $x - 2, $y + 3, $color)
	@icon_line($x + 2, $y - 3, $x + 2, $y + 3, $color)
	@icon_line($x - 2, $y, $x + 2, $y, $color)

; SEAPLANE BASE - Anchor symbol
function @icon_seaplane($x : number, $y : number, $color : number)
	; Anchor shaft
	@icon_line($x, $y - 4, $x, $y + 2, $color)
	; Top ring
	@icon_circle($x, $y - 4, 2, $color)
	; Flukes
	@icon_line($x, $y + 2, $x - 3, $y + 5, $color)
	@icon_line($x, $y + 2, $x + 3, $y + 5, $color)
	; Cross bar
	@icon_line($x - 3, $y, $x + 3, $y, $color)

; ==============================
; Projected rendering from lat/lon
; ==============================
; Draw all configured icons using radar center/scale
; Parameters:
;   $GCX,$GCY   = radar center (px on virtual canvas)
;   $R          = radar radius (px)
;   $OX0..$OY3  = per-screen origins (px)
function @icons_draw_all($GCX : number, $GCY : number, $R : number, $OX0 : number, $OY0 : number, $OX1 : number, $OY1 : number, $OX2 : number, $OY2 : number, $OX3 : number, $OY3 : number)
	; Set screen offsets for helpers
	$iconOX0 = $OX0; $iconOY0 = $OY0
	$iconOX1 = $OX1; $iconOY1 = $OY1
	$iconOX2 = $OX2; $iconOY2 = $OY2
	$iconOX3 = $OX3; $iconOY3 = $OY3
	; Set quadrant boundaries (left/right split is OX1, top/bottom split is OY2)
	$iconBX = $OX1
	$iconBY = $OY2

	; Precompute km per lon degree at ground station latitude
	var $latRad = $GND_LAT * $PI / 180
	var $kmPerDegLon = 111 * cos($latRad)
	if $kmPerDegLon < 0.01
		$kmPerDegLon = 0.01

	repeat $iconCount ($ii)
		; Convert lat/lon to local km offsets from ground station
		var $dLat = $iconLat.$ii - $GND_LAT
		var $dLon = $iconLon.$ii - $GND_LON
		var $dyKm = $dLat * 111
		var $dxKm = $dLon * $kmPerDegLon
		; Cull outside max range
		var $rng = sqrt($dxKm*$dxKm + $dyKm*$dyKm)
		if $rng <= $MAX_RANGE_KM
			; Project to screen
			var $bearing = atan($dxKm, $dyKm)
			if $bearing < 0
				$bearing += $TWO_PI
			var $pr = ($rng / $MAX_RANGE_KM) * $R
			var $px = $GCX + sin($bearing) * $pr
			var $py = $GCY - cos($bearing) * $pr
			; Draw by type
			var $t = $iconType.$ii
			var $col = $iconColor.$ii
			if $t == 1
				@icon_airport($px, $py, $col)
			elseif $t == 2
				@icon_minor_airport($px, $py, $col)
			elseif $t == 3
				@icon_waypoint($px, $py, $col)
			elseif $t == 4
				@icon_navaid($px, $py, $col)
			elseif $t == 5
				@icon_obstruction($px, $py, $col)
			elseif $t == 6
				@icon_prohibited($px, $py)
			elseif $t == 7
				@icon_restricted($px, $py, $col)
			elseif $t == 8
				@icon_class_d($px, $py, $col)
			elseif $t == 9
				@icon_nuclear($px, $py)
			elseif $t == 10
				@icon_final_approach($px, $py, $iconHead.$ii, $col)
			elseif $t == 11
				@icon_boundary($px, $py, $col)
			elseif $t == 12
				@icon_vor($px, $py, $col)
			elseif $t == 13
				@icon_ndb($px, $py, $col)
			elseif $t == 14
				@icon_dme($px, $py, $col)
			elseif $t == 15
				@icon_heliport($px, $py, $col)
			else
				@icon_seaplane($px, $py, $col)

; ==========================
; User configuration section
; ==========================
; Add your icons here. Called once during init.
function @icons_user_config()
	@icons_clear()
	; EXAMPLES (remove comments and adjust positions):
	 @icons_add(1, -0.6977, 151.2454, 0, cyan)          ; Major airport (e.g., KSFO)
	; @icons_add(3, 37.750000, -122.290000, 0, magenta)       ; Waypoint/intersection
	; @icons_add(10, 37.619500, -122.360000, 280, green)      ; Final approach heading 280°
	; @icons_add(12, 37.620000, -122.340000, 0, white)        ; VOR-like marker


; Simulation helpers and respawn system

; Respawn system globals are declared in state.xc

; Seed initial aircraft with randomized positions across entire radar range
function @seed_default_sim()
	; First, clear all slots
	repeat $N ($i)
		$ax.$i = 0
		$ay.$i = 0
		$spd.$i = 0
		$hdg.$i = 0
		$alt.$i = 0
		$vs.$i = 0
		$id.$i = ""
	; Start with random 2-8 aircraft spread across radar range
	var $initialCount = 2 + floor(random * 7)
	repeat $initialCount ($i)
		; Random position anywhere in radar range
		var $rng = random * $MAX_RANGE_KM * 0.9 ; 0-90% of max range
		var $bearing = random * $TWO_PI
		$ax.$i = sin($bearing) * $rng
		$ay.$i = cos($bearing) * $rng
		; Random heading
		$hdg.$i = random * 360
		; Random speed (80-230 m/s)
		$spd.$i = 80 + (random * 150)
		; Random altitude (500-12000m)
		$alt.$i = 500 + (random * 11500)
		; Random vertical speed (-10 to +10 m/s)
		$vs.$i = (random * 20) - 10
		$id.$i = @generate_random_callsign()

; Respawn helper: place aircraft outside radar range with inbound heading
function @respawn_aircraft()
	; Random bearing 0-360
	var $bear = random * 360
	var $bearRad = $bear * $PI / 180
	; Spawn distance: between max_range and respawn_range
	var $spawnDist = $MAX_RANGE_KM + (random * ($RESPAWN_RANGE_KM - $MAX_RANGE_KM))
	; Position in km
	var $spawnX = sin($bearRad) * $spawnDist
	var $spawnY = cos($bearRad) * $spawnDist
	; Heading: point roughly toward center (bearing + 180 ± 45 deg)
	var $hdgBase = $bear + 180
	var $hdgJitter = (random * 90) - 45
	var $newHdg = $hdgBase + $hdgJitter
	if $newHdg >= 360
		$newHdg -= 360
	if $newHdg < 0
		$newHdg += 360
	; Random speed, altitude, vertical speed
	var $newSpd = 80 + (random * 150)
	var $newAlt = 1000 + (random * 8000)
	var $newVs = (random * 10) - 5
	; Store results in global $respawn_* vars for caller to apply
	$respawnX = $spawnX
	$respawnY = $spawnY
	$respawnHdg = $newHdg
	$respawnSpd = $newSpd
	$respawnAlt = $newAlt
	$respawnVs = $newVs

; Update targets and redraw screens every tick

tick
	$tickCount++
	
	; Read clock beacon for world time (sun angle 0-360 degrees on frequency 1944)
	var $clockRx = input_number($CLOCK_BCN, 5)
	if $clockRx == 1
		$sunAngle = input_number($CLOCK_BCN, 0)

	; Read beacon telemetry when in real mode
	if $SIM_ENABLED == 0
		var $beaconRx = input_number($BCN_RX, 5)
		if $beaconRx == 1
			var $telem = input_text($BCN_RX, 0)
			; Parse key-value telemetry: expects keys id, spd, vs, alt, hdg, lat, lon
			var $rxId = $telem.id
			var $rxSpd = $telem.spd
			var $rxVs = $telem.vs
			var $rxAlt = $telem.alt
			var $rxHdg = $telem.hdg
			var $rxLat = $telem.lat
			var $rxLon = $telem.lon
			; Find or allocate target slot by ID
			var $slot = -1
			repeat $N ($si)
				if $id.$si == $rxId
					$slot = $si
					elseif ($id.$si == "") and ($slot == -1)
					$slot = $si
			if $slot >= 0
				; Update target with received telemetry
				$id.$slot = $rxId
				$spd.$slot = $rxSpd
				$vs.$slot = $rxVs
				$alt.$slot = $rxAlt
				$hdg.$slot = $rxHdg
				; Convert lat/lon to E/N km offsets relative to ground for drawing
				var $latRad_rx = $GND_LAT * $PI / 180
				var $kmPerDegLon_rx = 111 * cos($latRad_rx)
				if $kmPerDegLon_rx < 0.01
					$kmPerDegLon_rx = 0.01
				$ay.$slot = ($rxLat - $GND_LAT) * 111 ; north km
				$ax.$slot = ($rxLon - $GND_LON) * $kmPerDegLon_rx ; east km

	; Detect runtime simulation mode changes and apply transitions
	if $SIM_ENABLED != $simPrev
		if $SIM_ENABLED == 0
			; Switch to telemetry mode: clear simulated targets far away and reset visibility
			repeat $N ($i)
				$ax.$i = $MAX_RANGE_KM + 100
				$ay.$i = $MAX_RANGE_KM + 100
				$spd.$i = 0
				$hdg.$i = 0
				$alt.$i = 0
				$vs.$i = 0
				$id.$i = ""
				$dispAx.$i = $ax.$i
				$dispAy.$i = $ay.$i
				$vis.$i = 0
				$visPrev.$i = 0
				$scanTurn.$i = -999
		else
			; Switch to simulation mode: clear all slots first
			repeat $N ($i)
				$ax.$i = 0
				$ay.$i = 0
				$spd.$i = 0
				$hdg.$i = 0
				$alt.$i = 0
				$vs.$i = 0
				$id.$i = ""
				$dispAx.$i = 0
				$dispAy.$i = 0
				$vis.$i = 0
				$visPrev.$i = 0
				$scanTurn.$i = -999
			; Seed initial random aircraft
			@seed_default_sim()
			; Sync displayed positions for seeded aircraft
			repeat $N ($i)
				if $id.$i != ""
					$dispAx.$i = $ax.$i
					$dispAy.$i = $ay.$i
					var $initRng2 = sqrt($ax.$i*$ax.$i + $ay.$i*$ay.$i)
					if $initRng2 <= $MAX_RANGE_KM
						$vis.$i = 1
						$visPrev.$i = 1
					else
						$vis.$i = 0
						$visPrev.$i = 0
			; Reset spawn timer and randomize initial density
			$spawnTimer = 0
			$trafficDensity = $MIN_DENSITY + (random * ($MAX_DENSITY - $MIN_DENSITY))
			$densityChangeTimer = 0
		$simPrev = $SIM_ENABLED
	; Sweep advance (convert deg to rad)
	$wrapped = 0
	$sweepPrev = $sweep
	$sweep += ($SWEEP_DEG_PER_TICK * $PI / 180)
	if $sweep >= $TWO_PI
		$sweep -= $TWO_PI
		$turn++
		$wrapped = 1

	; Drive radar dish motor at configured max speed
	var $norm = 1.0 * $RAD_MOTOR_DIR
	if $norm > 1
		$norm = 1
	if $norm < -1
		$norm = -1
	output_number($RAD_MOTOR, 0, $norm)
	
	; Dynamic spawn system with variable traffic density
	if $SIM_ENABLED == 1
		; Slowly vary traffic density over time (creates rush hours and quiet periods)
		$densityChangeTimer++
		if $densityChangeTimer >= $DENSITY_CHANGE_INTERVAL
			$densityChangeTimer = 0
			; Gradually drift density toward random target
			var $targetDensity = $MIN_DENSITY + (random * ($MAX_DENSITY - $MIN_DENSITY))
			var $drift = ($targetDensity - $trafficDensity) * 0.3
			$trafficDensity += $drift
			; Clamp
			if $trafficDensity < $MIN_DENSITY
				$trafficDensity = $MIN_DENSITY
			if $trafficDensity > $MAX_DENSITY
				$trafficDensity = $MAX_DENSITY
		
		; Probabilistic spawning: try more frequently but with chance-based spawning
		$spawnTimer++
		if $spawnTimer >= $SPAWN_CHECK_INTERVAL
			$spawnTimer = 0
			; Count active targets
			$activeTargets = 0
			repeat $N ($i)
				if $id.$i != ""
					$activeTargets++
			; Calculate desired target count based on current density
			var $coverageArea = $PI * $MAX_RANGE_KM * $MAX_RANGE_KM
			var $desiredTargets = $coverageArea * $trafficDensity
			; Probabilistic spawn: higher chance when below desired, but not guaranteed
			if $activeTargets < $N
				var $deficit = $desiredTargets - $activeTargets
				if $deficit > 0
					; Spawn probability increases with deficit (0-100%)
					var $spawnChance = $deficit / 5
					if $spawnChance > 1
						$spawnChance = 1
					if random < $spawnChance
						; Find random empty slot (not just first)
						var $attempts = 0
						var $emptySlot = -1
						repeat 10 ($attempt)
							if $emptySlot == -1
								var $trySlot = floor(random * $N)
								if $id.$trySlot == ""
									$emptySlot = $trySlot
						if $emptySlot >= 0
							; Spawn new aircraft in empty slot
							@respawn_aircraft()
							$ax.$emptySlot = $respawnX
							$ay.$emptySlot = $respawnY
							$hdg.$emptySlot = $respawnHdg
							$spd.$emptySlot = $respawnSpd
							$alt.$emptySlot = $respawnAlt
							$vs.$emptySlot = $respawnVs
							$id.$emptySlot = @generate_random_callsign()
							$scanTurn.$emptySlot = -999
							$vis.$emptySlot = 0
							$visPrev.$emptySlot = 0

	; Move aircraft (simple kinematics, no wind). Heading 0=north, 90=east
	if $SIM_ENABLED == 1
		repeat $N ($i)
			; Skip empty slots
			if $id.$i == ""
				continue
			var $hdgRad = ($hdg.$i * $PI / 180)
			; Speed integration: convert m/s to km per tick at 25 Hz, scaled by time multiplier
			var $step = (($spd.$i / 1000) / 25) * $TIME_SCALE
			$ax.$i += sin($hdgRad) * $step ; east component
			$ay.$i += cos($hdgRad) * $step ; north component
			; Altitude integration: apply m/s per 25 Hz tick, scaled by time multiplier
			$alt.$i += (($vs.$i / 25) * $TIME_SCALE)
			; Clamp altitude to a realistic range [0, 15000] m
			if $alt.$i < 0
				$alt.$i = 0
			if $alt.$i > 15000
				$alt.$i = 15000
			; Despawn system: if aircraft too far away, clear slot (dynamic spawn will refill)
			var $distFromCenter = sqrt($ax.$i*$ax.$i + $ay.$i*$ay.$i)
			if $distFromCenter > $RESPAWN_RANGE_KM
				; Clear this slot - it will be refilled by dynamic spawning
				$ax.$i = 0
				$ay.$i = 0
				$hdg.$i = 0
				$spd.$i = 0
				$alt.$i = 0
				$vs.$i = 0
				$id.$i = ""
				$dispAx.$i = 0
				$dispAy.$i = 0
				$scanTurn.$i = -999
				$vis.$i = 0
				$visPrev.$i = 0
	
	; Radar sweep detection and display update logic
	var $beam = 6 * $PI / 180 ; beam width (for future visual highlight)
	repeat $N ($i)
		; Skip empty slots
		if $id.$i == ""
			continue
		; Real (current) position (continuously updated by physics)
		var $realDx = $ax.$i
		var $realDy = $ay.$i
		var $realRng = sqrt($realDx*$realDx + $realDy*$realDy)
		; Visibility based on real range
		if $realRng <= $MAX_RANGE_KM
			$vis.$i = 1
		else
			$vis.$i = 0
		; Detect transitions and trigger buzzer tones
		if $vis.$i == 1
			if $visPrev.$i == 0
				@buzz_start_acq()
				$visPrev.$i = 1
				; Initialize displayed position to real position on acquire to avoid showing stale data
				$dispAx.$i = $realDx
				$dispAy.$i = $realDy
				$scanTurn.$i = $turn
				; Log acquire
				$logTmpIdx = $i
				@log_add_acq()
		else
			if $visPrev.$i == 1
				@buzz_start_lost()
				$visPrev.$i = 0
				; Log lost
				$logTmpIdx = $i
				@log_add_lost()
		
		; Use displayed (last scanned) position for bearing check & drawing
		var $dx = $dispAx.$i
		var $dy = $dispAy.$i
		var $rng = sqrt($dx*$dx + $dy*$dy)
		
		; Only update displayed position when target is in range and beam sweeps
		if $vis.$i == 1
			var $bearing = atan($dx, $dy)
			if $bearing < 0
				$bearing += $TWO_PI
			; Determine if sweep crossed bearing this tick (robust to large sweep step)
			var $crossed = 0
			if $wrapped == 0
				if $bearing >= $sweepPrev
					if $bearing < $sweep
						$crossed = 1
			else
				; Wrap-around case: bearing in either segment
				if $bearing >= $sweepPrev
					$crossed = 1
				elseif $bearing < $sweep
					$crossed = 1
			; Update only once per rotation when crossed, and only if still in-range
			if $crossed == 1
				if $scanTurn.$i != $turn
					if $realRng <= $MAX_RANGE_KM
						$dispAx.$i = $realDx
						$dispAy.$i = $realDy
						$scanTurn.$i = $turn
						; Update latest log entry for this ID to current lat/lon when visible
						var $li = -1
						repeat $logCount ($k)
							var $idxBack = ($logCount - 1) - $k
							if $li == -1
								if $logId.$idxBack == $id.$i
									$li = $idxBack
						if $li >= 0
							; Update latest log entry to current lat/lon
							var $e_upd = $dispAx.$i
							var $n_upd = $dispAy.$i
							; Convert E/N km offsets to lat/lon (inline calculation)
							var $latRad_upd = $GND_LAT * $PI / 180
							var $kmPerDegLon_upd = 111 * cos($latRad_upd)
							if $kmPerDegLon_upd < 0.01
								$kmPerDegLon_upd = 0.01
							$logY.$li = $GND_LAT + ($n_upd / 111)
							$logX.$li = $GND_LON + ($e_upd / $kmPerDegLon_upd)

	; Render each screen
	@render_global()

	; Beeper control moved to timer block to satisfy runtime restrictions

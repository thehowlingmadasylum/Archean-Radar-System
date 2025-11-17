; Initialization
init
	; Initialize persistent storage (loads from disk automatically)
	@storage_init()
	
	; Initialize callsign generator data
	@callsign_init()

	$offsetX.fill(4, 0)
	$offsetY.fill(4, 0)
	$scale.fill(4, 1)

	; Reset cumulative log counter (current session volatile logs)
	$logTotal = 0

	; Initialize contact log arrays
	$logId.fill($LOG_MAX, "")
	$logWhen.fill($LOG_MAX, "")
	$logStatus.fill($LOG_MAX, "")
	$logX.fill($LOG_MAX, 0)
	$logY.fill($LOG_MAX, 0)

	; Restore recent logs from persistent storage (most recent entries up to LOG_MAX)
	var $histSize = @storage_log_count()
	if $histSize > 0
		; Calculate how many entries to restore (up to LOG_MAX)
		var $restoreCount = $histSize
		if $restoreCount > $LOG_MAX
			$restoreCount = $LOG_MAX
		; Calculate starting index in storage (to get most recent entries)
		var $startIdx = $histSize - $restoreCount
		; Copy from storage to volatile log arrays
		repeat $restoreCount ($ri)
			var $storIdx = $startIdx + $ri
			$logId.$ri = $histId.$storIdx
			$logWhen.$ri = $histWhen.$storIdx
			$logStatus.$ri = $histStatus.$storIdx
			$logY.$ri = $histLat.$storIdx
			$logX.$ri = $histLon.$storIdx
		$logCount = $restoreCount
		$logTotal = $histSize

	; Seed aircraft at various bearings/ranges
	$ax.fill($N, 0)
	$ay.fill($N, 0)
	$spd.fill($N, 0)
	$hdg.fill($N, 0)
	$alt.fill($N, 0)
	$vs.fill($N, 0)
	$id.fill($N, "")

	; Initialize per-target scan turn to -999 so first beam pass will update
	$scanTurn.fill($N, -999)
	$vis.fill($N, 1)
	$visPrev.fill($N, 1)
	$labelPos.fill($N, 0)

	; Test buzzer on startup - set frequency then amplitude
	output_number("SPKR_0", 1, 1200)
	output_number("SPKR_0", 0, 1)
	; Arm the timer to turn it off after a few ticks
	$buzzTone = $TONE_ACQ
	$buzzTicks = 8
	$buzzArm = 0

	; Load user-defined radar icons (lat/lon registry)
	@icons_user_config()

	; Configure clock beacon to receive on frequency 1944
	output_number($CLOCK_BCN, 2, 1944)

	; Record initial simulation mode
	$simPrev = $SIM_ENABLED

	; Read ground station position from NAV instrument
	$GND_LAT = input_number($NAV, 8)
	$GND_LON = input_number($NAV, 9)

	; Define a few aircraft
	if $SIM_ENABLED == 1
		@seed_default_sim()
	else
		; Telemetry mode baseline: place placeholders far out so they don't appear until real data arrives
		repeat $N ($i)
			$ax.$i = $MAX_RANGE_KM + 100
			$ay.$i = $MAX_RANGE_KM + 100
			$spd.$i = 0
			$hdg.$i = 0
			$alt.$i = 0
			$vs.$i = 0
			$id.$i = ""

	; Initialize displayed (scanned) positions to initial true positions
	$dispAx.fill($N,0)
	$dispAy.fill($N,0)
	repeat $N ($i)
		$dispAx.$i = $ax.$i
		$dispAy.$i = $ay.$i
		; Seed vis/visPrev from initial ranges to avoid spurious beeps on start
		; Only process aircraft with valid IDs
		if $id.$i != ""
			var $initRng = sqrt($ax.$i*$ax.$i + $ay.$i*$ay.$i)
			if $initRng <= $MAX_RANGE_KM
				$vis.$i = 1
				$visPrev.$i = 1
				; Log initially visible targets
				if $SIM_ENABLED == 1
					$logTmpIdx = $i
					@log_add_acq()
			else
				$vis.$i = 0
				$visPrev.$i = 0
		else
			; Empty slot - ensure visibility is off
			$vis.$i = 0
			$visPrev.$i = 0

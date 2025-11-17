; Contact log helpers (must be defined before init)

function @log_format_time()
	; World time from sun angle (0-360 degrees from clock beacon)
	var $adjustedAngle = $sunAngle + 90.0
	if $adjustedAngle >= 360.0
		$adjustedAngle = $adjustedAngle - 360.0
	var $hoursFloat = ($adjustedAngle / 360.0) * 24.0
	if $hoursFloat >= 24.0
		$hoursFloat = $hoursFloat - 24.0
	var $hours = floor($hoursFloat)
	var $minutes = floor(($hoursFloat - $hours) * 60.0)
	; Format based on clock preference
	if $USE_24H_CLOCK == 1
		; 24-hour format
		var $minStr = text("{}", $minutes)
		if $minutes < 10
			$minStr = text("0{}", $minutes)
		$logWhen.$logCount = text("{}:{}", $hours, $minStr)
	else
		; 12-hour format with AM/PM
		var $ampm = "AM"
		var $displayHour = $hours
		if $hours >= 12
			$ampm = "PM"
		if $hours > 12
			$displayHour = $hours - 12
		elseif $hours == 0
			$displayHour = 12
		var $minStr = text("{}", $minutes)
		if $minutes < 10
			$minStr = text("0{}", $minutes)
		$logWhen.$logCount = text("{}:{}{}", $displayHour, $minStr, $ampm)

function @log_add_acq()
	if $logCount >= $LOG_MAX
		; shift up to keep newest at bottom
		var $shiftMax = $LOG_MAX - 1
		repeat $shiftMax ($k)
			var $j = $k + 1
			$logId.$k = $logId.$j
			$logWhen.$k = $logWhen.$j
			$logStatus.$k = $logStatus.$j
			$logX.$k = $logX.$j
			$logY.$k = $logY.$j
		$logCount = $LOG_MAX - 1
	$logTotal++
	$logId.$logCount = $id.$logTmpIdx
	$logStatus.$logCount = "ACQ"
	@log_format_time()
	; Convert displayed E/N km to lat/lon for logging
	var $e_acq = $dispAx.$logTmpIdx
	var $n_acq = $dispAy.$logTmpIdx
	var $latRad_acq = $GND_LAT * $PI / 180
	var $kmPerDegLon_acq = 111 * cos($latRad_acq)
	if $kmPerDegLon_acq < 0.01
		$kmPerDegLon_acq = 0.01
	$logY.$logCount = $GND_LAT + ($n_acq / 111)
	$logX.$logCount = $GND_LON + ($e_acq / $kmPerDegLon_acq)
	; Save to persistent storage before incrementing logCount
	@storage_add_log($id.$logTmpIdx, $logWhen.$logCount, "ACQ", $logY.$logCount, $logX.$logCount)
	$logCount++

function @log_add_lost()
	if $logCount >= $LOG_MAX
		; shift up to keep newest at bottom
		var $shiftMax = $LOG_MAX - 1
		repeat $shiftMax ($k)
			var $j = $k + 1
			$logId.$k = $logId.$j
			$logWhen.$k = $logWhen.$j
			$logStatus.$k = $logStatus.$j
			$logX.$k = $logX.$j
			$logY.$k = $logY.$j
		$logCount = $LOG_MAX - 1
	$logTotal++
	$logId.$logCount = $id.$logTmpIdx
	$logStatus.$logCount = "LOST"
	@log_format_time()
	; Convert displayed E/N km to lat/lon for logging
	var $e_lost = $dispAx.$logTmpIdx
	var $n_lost = $dispAy.$logTmpIdx
	var $latRad_lost = $GND_LAT * $PI / 180
	var $kmPerDegLon_lost = 111 * cos($latRad_lost)
	if $kmPerDegLon_lost < 0.01
		$kmPerDegLon_lost = 0.01
	$logY.$logCount = $GND_LAT + ($n_lost / 111)
	$logX.$logCount = $GND_LON + ($e_lost / $kmPerDegLon_lost)
	; Save to persistent storage before incrementing logCount
	@storage_add_log($id.$logTmpIdx, $logWhen.$logCount, "LOST", $logY.$logCount, $logX.$logCount)
	$logCount++

; Render function for all screens and log dashboard

function @render_global()
	; Clear screens for radar rendering
	$s0.blank(black)
	$s1.blank(black)
	$s2.blank(black)
	$s3.blank(black)
	
	; Gather per-screen sizes
	var $W0 = $s0.width
	var $H0 = $s0.height
	var $W1 = $s1.width
	var $H1 = $s1.height
	var $W2 = $s2.width
	var $H2 = $s2.height
	var $W3 = $s3.width
	var $H3 = $s3.height

	; Virtual canvas (2x2 grid)
	var $VCW = $W0 + $W1
	var $VCH = $H0 + $H2
	var $GCX = $W0
	var $GCY = $H0
	var $baseR = (min($VCW, $VCH) / 2) - 6
	var $R = $baseR
	if $R < 20
		$R = 20

	; Origins per screen
	var $OX0 = 0
	var $OY0 = 0
	var $OX1 = $W0
	var $OY1 = 0
	var $OX2 = 0
	var $OY2 = $H0
	var $OX3 = $W0
	var $OY3 = $H0

	; Range rings
	repeat $RING_COUNT ($ri)
		var $rn = $ri + 1
		var $rr = $R * $rn / $RING_COUNT
		$s0.draw_circle($GCX - $OX0, $GCY - $OY0, $rr, gray)
		$s1.draw_circle($GCX - $OX1, $GCY - $OY1, $rr, gray)
		$s2.draw_circle($GCX - $OX2, $GCY - $OY2, $rr, gray)
		$s3.draw_circle($GCX - $OX3, $GCY - $OY3, $rr, gray)

	; Cardinal marks (N,E,S,W)
	$s0.draw_line($GCX - $OX0, $GCY - $OY0 - $R, $GCX - $OX0, $GCY - $OY0 - ($R-6), white)
	$s1.draw_line($GCX - $OX1, $GCY - $OY1 - $R, $GCX - $OX1, $GCY - $OY1 - ($R-6), white)
	$s2.draw_line($GCX - $OX2, $GCY - $OY2 - $R, $GCX - $OX2, $GCY - $OY2 - ($R-6), white)
	$s3.draw_line($GCX - $OX3, $GCY - $OY3 - $R, $GCX - $OX3, $GCY - $OY3 - ($R-6), white)
	$s0.draw_line($GCX - $OX0 + $R, $GCY - $OY0, $GCX - $OX0 + ($R-6), $GCY - $OY0, gray)
	$s1.draw_line($GCX - $OX1 + $R, $GCY - $OY1, $GCX - $OX1 + ($R-6), $GCY - $OY1, gray)
	$s2.draw_line($GCX - $OX2 + $R, $GCY - $OY2, $GCX - $OX2 + ($R-6), $GCY - $OY2, gray)
	$s3.draw_line($GCX - $OX3 + $R, $GCY - $OY3, $GCX - $OX3 + ($R-6), $GCY - $OY3, gray)
	$s2.draw_line($GCX - $OX2, $GCY - $OY2 + $R, $GCX - $OX2, $GCY - $OY2 + ($R-6), gray)
	$s3.draw_line($GCX - $OX3, $GCY - $OY3 + $R, $GCX - $OX3, $GCY - $OY3 + ($R-6), gray)
	$s0.draw_line($GCX - $OX0 - $R, $GCY - $OY0, $GCX - $OX0 - ($R-6), $GCY - $OY0, gray)
	$s1.draw_line($GCX - $OX1 - $R, $GCY - $OY1, $GCX - $OX1 - ($R-6), $GCY - $OY1, gray)
	$s2.draw_line($GCX - $OX2 - $R, $GCY - $OY2, $GCX - $OX2 - ($R-6), $GCY - $OY2, gray)
	$s3.draw_line($GCX - $OX3 - $R, $GCY - $OY3, $GCX - $OX3 - ($R-6), $GCY - $OY3, gray)

	; Text setup
	$s0.text_size(1)
	$s1.text_size(1)
	$s2.text_size(1)
	$s3.text_size(1)
	$s0.text_align(top_left)
	$s1.text_align(top_left)
	$s2.text_align(top_left)
	$s3.text_align(top_left)
	
	; Beacon-based world time display (top-left, screen s0)
	; Clock beacon provides sun angle: 0°=midnight, 90°=6am, 180°=noon, 270°=6pm, 360°=midnight
	; Need to shift by 90° so 90° = noon (12:00)
	var $adjustedAngle = $sunAngle + 90.0
	if $adjustedAngle >= 360.0
		$adjustedAngle = $adjustedAngle - 360.0
	var $hoursFloat = ($adjustedAngle / 360.0) * 24.0 ; 0.0 to 24.0 hours
	if $hoursFloat >= 24.0
		$hoursFloat = $hoursFloat - 24.0
	var $hours = floor($hoursFloat)
	var $minutes = floor(($hoursFloat - $hours) * 60.0)
	var $timeStr = ""
	if $USE_24H_CLOCK == 1
		; 24-hour format
		; Format minutes with leading zero if needed
		var $minStr = text("{}", $minutes)
		if $minutes < 10
			$minStr = text("0{}", $minutes)
		$timeStr = text("{}:{}", $hours, $minStr)
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
		; Format minutes with leading zero if needed
		var $minStr = text("{}", $minutes)
		if $minutes < 10
			$minStr = text("0{}", $minutes)
		$timeStr = text("{}:{} {}", $displayHour, $minStr, $ampm)
	$s0.write(4, 4, white, $timeStr)
	
	; Place 'N' just inside the ring on the top-right screen to avoid seam splitting
	var $ch1 = $s1.char_h
	var $cw1 = $s1.char_w

	; Draw user icons UNDER the sweep and aircraft (but after rings)
	@icons_draw_all($GCX, $GCY, $R, $OX0, $OY0, $OX1, $OY1, $OX2, $OY2, $OX3, $OY3)
	
	; Radar range display (top-right, screen s1)
	var $rangeStr = text("RNG: {} km", $MAX_RANGE_KM)
	; Approximate text width (10 characters for "RNG: 400 km")
	var $rangeTextW = 12 * $cw1
	$s1.write($W1 - $rangeTextW - 4, 4, white, $rangeStr)
	var $nx = $GCX - $OX1 + 6 - ($cw1/2)
	var $ny = $GCY - $OY1 - ($R - 2) - $ch1
	$s1.write($nx, $ny, white, "N")

	; Sweep line + trail (0 rad = North). Use sin for X, cos for Y so 0 points up.
	var $x1 = $GCX + sin($sweep) * $R
	var $y1 = $GCY - cos($sweep) * $R
	$s0.draw_line($GCX - $OX0, $GCY - $OY0, $x1 - $OX0, $y1 - $OY0, green)
	$s1.draw_line($GCX - $OX1, $GCY - $OY1, $x1 - $OX1, $y1 - $OY1, green)
	$s2.draw_line($GCX - $OX2, $GCY - $OY2, $x1 - $OX2, $y1 - $OY2, green)
	$s3.draw_line($GCX - $OX3, $GCY - $OY3, $x1 - $OX3, $y1 - $OY3, green)
	var $trail = 10 * $PI / 180
	var $x2 = $GCX + sin($sweep - $trail) * $R
	var $y2 = $GCY - cos($sweep - $trail) * $R
	var $x3 = $GCX + sin($sweep - 2*$trail) * $R
	var $y3 = $GCY - cos($sweep - 2*$trail) * $R
	$s0.draw_line($GCX - $OX0, $GCY - $OY0, $x2 - $OX0, $y2 - $OY0, gray)
	$s1.draw_line($GCX - $OX1, $GCY - $OY1, $x2 - $OX1, $y2 - $OY1, gray)
	$s2.draw_line($GCX - $OX2, $GCY - $OY2, $x2 - $OX2, $y2 - $OY2, gray)
	$s3.draw_line($GCX - $OX3, $GCY - $OY3, $x2 - $OX3, $y2 - $OY3, gray)
	$s0.draw_line($GCX - $OX0, $GCY - $OY0, $x3 - $OX0, $y3 - $OY0, gray)
	$s1.draw_line($GCX - $OX1, $GCY - $OY1, $x3 - $OX1, $y3 - $OY1, gray)
	$s2.draw_line($GCX - $OX2, $GCY - $OY2, $x3 - $OX2, $y3 - $OY2, gray)
	$s3.draw_line($GCX - $OX3, $GCY - $OY3, $x3 - $OX3, $y3 - $OY3, gray)

	; Draw aircraft targets at displayed (scanned) positions
	repeat $N ($i)
		; Use displayed (last scanned) position for drawing
		var $dx = $dispAx.$i
		var $dy = $dispAy.$i
		var $rng = sqrt($dx*$dx + $dy*$dy)
		; Only draw when visible and within range
		if $vis.$i == 1
			var $bearing = atan($dx, $dy)
			if $bearing < 0
				$bearing += $TWO_PI
			if $rng <= $MAX_RANGE_KM
				var $pr = ($rng / $MAX_RANGE_KM) * $R
				if $pr > 0
					var $px = $GCX + sin($bearing) * $pr
					var $py = $GCY - cos($bearing) * $pr
					; Echo dot (larger)
					$s0.draw_point($px - $OX0, $py - $OY0, gray)
					$s0.draw_point($px+1 - $OX0, $py - $OY0, gray)
					$s0.draw_point($px-1 - $OX0, $py - $OY0, gray)
					$s0.draw_point($px - $OX0, $py+1 - $OY0, gray)
					$s0.draw_point($px - $OX0, $py-1 - $OY0, gray)
					$s1.draw_point($px - $OX1, $py - $OY1, gray)
					$s1.draw_point($px+1 - $OX1, $py - $OY1, gray)
					$s1.draw_point($px-1 - $OX1, $py - $OY1, gray)
					$s1.draw_point($px - $OX1, $py+1 - $OY1, gray)
					$s1.draw_point($px - $OX1, $py-1 - $OY1, gray)
					$s2.draw_point($px - $OX2, $py - $OY2, gray)
					$s2.draw_point($px+1 - $OX2, $py - $OY2, gray)
					$s2.draw_point($px-1 - $OX2, $py - $OY2, gray)
					$s2.draw_point($px - $OX2, $py+1 - $OY2, gray)
					$s2.draw_point($px - $OX2, $py-1 - $OY2, gray)
					$s3.draw_point($px - $OX3, $py - $OY3, gray)
					$s3.draw_point($px+1 - $OX3, $py - $OY3, gray)
					$s3.draw_point($px-1 - $OX3, $py - $OY3, gray)
					$s3.draw_point($px - $OX3, $py+1 - $OY3, gray)
					$s3.draw_point($px - $OX3, $py-1 - $OY3, gray)
					; Persistent lock box around last scanned position
					$s0.draw_rect($px-4 - $OX0, $py-4 - $OY0, $px+4 - $OX0, $py+4 - $OY0, green)
					$s1.draw_rect($px-4 - $OX1, $py-4 - $OY1, $px+4 - $OX1, $py+4 - $OY1, green)
					$s2.draw_rect($px-4 - $OX2, $py-4 - $OY2, $px+4 - $OX2, $py+4 - $OY2, green)
					$s3.draw_rect($px-4 - $OX3, $py-4 - $OY3, $px+4 - $OX3, $py+4 - $OY3, green)
					; Smart label positioning with collision avoidance
					; Estimate label dimensions (callsign ~8 chars, detail line ~12 chars)
					var $labelW = 12 * $cw1
					var $labelH = 2 * $ch1
					; Try all 4 positions and pick first that doesn't collide
					; Position 0: top-right, 1: top-left, 2: bottom-right, 3: bottom-left
					var $bestPos = -1
					var $tryPos = 0
					repeat 4 ($posAttempt)
						if $bestPos == -1
							; Calculate label bounding box for this attempt
							; For collision detection, need top-left corner of bounding box
							var $testLx = 0
							var $testLy = 0
							if $tryPos == 0
								; Top-right: text grows right from leader end
								$testLx = $px + 14
								$testLy = $py - 14
							elseif $tryPos == 1
								; Top-left: text grows left from leader end
								$testLx = $px - 14 - $labelW
								$testLy = $py - 14
							elseif $tryPos == 2
								; Bottom-right: text grows right from leader end
								$testLx = $px + 14
								$testLy = $py + 14
							else
								; Bottom-left: text grows left from leader end
								$testLx = $px - 14 - $labelW
								$testLy = $py + 14
							; Check screen bounds
							var $blocked = 0
							if ($testLx < 0) or ($testLx + $labelW > $VCW)
								$blocked = 1
							if ($testLy < 0) or ($testLy + $labelH > $VCH)
								$blocked = 1
							; Check collision with previously positioned aircraft (only check nearby aircraft)
							if $blocked == 0
								repeat $i ($j)
									if ($blocked == 0) and ($id.$j != "")
										if $vis.$j == 1
											var $dx_j = $dispAx.$j
											var $dy_j = $dispAy.$j
											var $rng_j = sqrt($dx_j*$dx_j + $dy_j*$dy_j)
											if $rng_j <= $MAX_RANGE_KM
												var $bearing_j = atan($dx_j, $dy_j)
												if $bearing_j < 0
													$bearing_j += $TWO_PI
												var $pr_j = ($rng_j / $MAX_RANGE_KM) * $R
												var $px_j = $GCX + sin($bearing_j) * $pr_j
												var $py_j = $GCY - cos($bearing_j) * $pr_j
												; Only check collision if aircraft are close in screen space
												var $distX = $px - $px_j
												var $distY = $py - $py_j
												var $screenDist = sqrt($distX*$distX + $distY*$distY)
												; Only avoid if within ~60 pixels (label can extend ~30 pixels)
												if $screenDist < 60
													; Get the bounding box (top-left corner) for aircraft j's label
													var $lx_j = 0
													var $ly_j = 0
													var $jPos = $labelPos.$j
													if $jPos == 0
														; Top-right: bbox starts at leader end
														$lx_j = $px_j + 14
														$ly_j = $py_j - 14
													elseif $jPos == 1
														; Top-left: bbox starts labelW to the left of leader end
														$lx_j = $px_j - 14 - $labelW
														$ly_j = $py_j - 14
													elseif $jPos == 2
														; Bottom-right: bbox starts at leader end
														$lx_j = $px_j + 14
														$ly_j = $py_j + 14
													else
														; Bottom-left: bbox starts labelW to the left of leader end
														$lx_j = $px_j - 14 - $labelW
														$ly_j = $py_j + 14
													; Check bounding box overlap with padding
													if ($testLx < $lx_j + $labelW + 4) and ($testLx + $labelW + 4 > $lx_j)
														if ($testLy < $ly_j + $labelH + 4) and ($testLy + $labelH + 4 > $ly_j)
															$blocked = 1
							; If not blocked, use this position
							if $blocked == 0
								$bestPos = $tryPos
							$tryPos++
					; Fallback to position 0 if all blocked
					if $bestPos == -1
						$bestPos = 0
					; Store chosen position for this aircraft
					$labelPos.$i = $bestPos
					; Draw leader line and set text position based on chosen position
					var $cornerX = 0
					var $cornerY = 0
					var $leaderEndX = 0
					var $leaderEndY = 0
					if $bestPos == 0
						; Top-right: corner at (+4,-4), leader ends at (+14,-14)
						$cornerX = $px + 4
						$cornerY = $py - 4
						$leaderEndX = $px + 14
						$leaderEndY = $py - 14
					elseif $bestPos == 1
						; Top-left: corner at (-4,-4), leader ends at (-14,-14)
						$cornerX = $px - 4
						$cornerY = $py - 4
						$leaderEndX = $px - 14
						$leaderEndY = $py - 14
					elseif $bestPos == 2
						; Bottom-right: corner at (+4,+4), leader ends at (+14,+14)
						$cornerX = $px + 4
						$cornerY = $py + 4
						$leaderEndX = $px + 14
						$leaderEndY = $py + 14
					else
						; Bottom-left: corner at (-4,+4), leader ends at (-14,+14)
						$cornerX = $px - 4
						$cornerY = $py + 4
						$leaderEndX = $px - 14
						$leaderEndY = $py + 14
					; Draw leader line
					$s0.draw_line($cornerX - $OX0, $cornerY - $OY0, $leaderEndX - $OX0, $leaderEndY - $OY0, green)
					$s1.draw_line($cornerX - $OX1, $cornerY - $OY1, $leaderEndX - $OX1, $leaderEndY - $OY1, green)
					$s2.draw_line($cornerX - $OX2, $cornerY - $OY2, $leaderEndX - $OX2, $leaderEndY - $OY2, green)
					$s3.draw_line($cornerX - $OX3, $cornerY - $OY3, $leaderEndX - $OX3, $leaderEndY - $OY3, green)
					; Set text alignment and calculate text anchor point
					$s0.text_size(1)
					$s1.text_size(1)
					$s2.text_size(1)
					$s3.text_size(1)
					; Always use left-align; adjust X position for left-side labels
					$s0.text_align(top_left)
					$s1.text_align(top_left)
					$s2.text_align(top_left)
					$s3.text_align(top_left)
					var $textX = $leaderEndX
					if ($bestPos == 1) or ($bestPos == 3)
						; Left positions: move text left by labelW so it appears left of leader
						$textX = $leaderEndX - $labelW
					; Write callsign at calculated text position
					$s0.write($textX - $OX0, $leaderEndY - $OY0, green, $id.$i)
					$s1.write($textX - $OX1, $leaderEndY - $OY1, green, $id.$i)
					$s2.write($textX - $OX2, $leaderEndY - $OY2, green, $id.$i)
					$s3.write($textX - $OX3, $leaderEndY - $OY3, green, $id.$i)
					var $yoff = $s0.char_h
					var $phase = $labelPhase
					; Detail line uses same text X position as callsign
					if $phase == 0
						var $alt_i = floor($alt.$i + 0.5)
						$s0.write($textX - $OX0, $leaderEndY - $OY0 + $yoff, white, text("ALT {} m", $alt_i))
						$s1.write($textX - $OX1, $leaderEndY - $OY1 + $yoff, white, text("ALT {} m", $alt_i))
						$s2.write($textX - $OX2, $leaderEndY - $OY2 + $yoff, white, text("ALT {} m", $alt_i))
						$s3.write($textX - $OX3, $leaderEndY - $OY3 + $yoff, white, text("ALT {} m", $alt_i))
					elseif $phase == 1
						var $spd1 = floor(($spd.$i*10) + 0.5) / 10
						$s0.write($textX - $OX0, $leaderEndY - $OY0 + $yoff, white, text("SPD {} m/s", $spd1))
						$s1.write($textX - $OX1, $leaderEndY - $OY1 + $yoff, white, text("SPD {} m/s", $spd1))
						$s2.write($textX - $OX2, $leaderEndY - $OY2 + $yoff, white, text("SPD {} m/s", $spd1))
						$s3.write($textX - $OX3, $leaderEndY - $OY3 + $yoff, white, text("SPD {} m/s", $spd1))
					elseif $phase == 2
						var $hdg_i = floor($hdg.$i + 0.5)
						$s0.write($textX - $OX0, $leaderEndY - $OY0 + $yoff, white, text("HDG {}°", $hdg_i))
						$s1.write($textX - $OX1, $leaderEndY - $OY1 + $yoff, white, text("HDG {}°", $hdg_i))
						$s2.write($textX - $OX2, $leaderEndY - $OY2 + $yoff, white, text("HDG {}°", $hdg_i))
						$s3.write($textX - $OX3, $leaderEndY - $OY3 + $yoff, white, text("HDG {}°", $hdg_i))
					else
						var $vs1 = floor(($vs.$i*10) + 0.5) / 10
						$s0.write($textX - $OX0, $leaderEndY - $OY0 + $yoff, white, text("VS {} m/s", $vs1))
						$s1.write($textX - $OX1, $leaderEndY - $OY1 + $yoff, white, text("VS {} m/s", $vs1))
						$s2.write($textX - $OX2, $leaderEndY - $OY2 + $yoff, white, text("VS {} m/s", $vs1))
						$s3.write($textX - $OX3, $leaderEndY - $OY3 + $yoff, white, text("VS {} m/s", $vs1))

	; Render Dashboard_1 recent contact log with diagnostics/fallback
	var $topW = $d1_top.width
	var $botW = $d1_bot.width
	var $topH = $d1_top.height
	var $botH = $d1_bot.height
	if ($topW <= 0) and ($botW <= 0)
		; Neither Dashboard_1 screen seems available: show a warning on primary radar
		$s0.text_size(1)
		$s0.text_align(top_left)
		$s0.write(2, 2, red, "Dashboard_1 not found (check alias/channels)")
	else
		if $topW > 0
			; Primary path: draw to Dashboard_1 top (channel 1)
			$d1_top.blank(black)
			$d1_top.text_size(1)
			$d1_top.text_align(top_left)
			var $lh = $d1_top.char_h
			if $lh <= 0
				$lh = 16 ; assume a reasonable default line height
			var $cw = $d1_top.char_w
			$d1_top.write(2, 2, white, text("RECENT CONTACTS  ({})", $logTotal))
			; Separator line under header
			$d1_top.draw_line(0, 2 + $lh + 2, $topW-1, 2 + $lh + 2, gray)
			; Reserve footer height for GS position (one line + padding)
			var $footerH = $lh + 6
			var $avail = $topH - (3*$lh) - $footerH
			if $avail < 0
				$avail = 0
			; Two-line entries with small padding
			var $entryH = (2*$lh) + 2
			var $rows = floor($avail / $entryH)
			if $rows < 1
				$rows = 1
			var $start = 0
			if $logCount > $rows
				$start = $logCount - $rows
			var $y = 2 + $lh + 4
			var $toShow = $logCount - $start
			if $toShow < 0
				$toShow = 0
			repeat $toShow ($ri)
				var $idx = $start + $ri
				; Alternating band background (odd rows)
				if mod($ri, 2) == 1
					var $fillH = $entryH
					repeat $fillH ($fy)
						$d1_top.draw_line(0, $y + $fy - 1, $topW-1, $y + $fy - 1, gray)
				; Round lat/lon to 4 decimal places for display
				var $latv = $logY.$idx
				var $lonv = $logX.$idx
				var $latSign = 1
				if $latv < 0
					$latSign = -1
				var $lonSign = 1
				if $lonv < 0
					$lonSign = -1
				var $latAbs = $latv * $latSign
				var $lonAbs = $lonv * $lonSign
				var $lat4 = floor(($latAbs*10000) + 0.5) / 10000
				var $lon4 = floor(($lonAbs*10000) + 0.5) / 10000
				$lat4 = $lat4 * $latSign
				$lon4 = $lon4 * $lonSign
				; First line: time, status, id
				var $line1 = text("{}  {}  {}", $logWhen.$idx, $logStatus.$idx, $logId.$idx)
				; Second line: lat/lon
				var $line2 = text("Lat:{}°  Lon:{}°", $lat4, $lon4)
				var $col = white
				if $logStatus.$idx == "ACQ"
					$col = green
				elseif $logStatus.$idx == "LOST"
					$col = red
				$d1_top.write(2, $y, $col, $line1)
				$d1_top.write(2, $y + $lh, white, $line2)
				$y += $entryH
			; Footer: GS position centered at bottom
			var $latv_gs2 = $GND_LAT
			var $lonv_gs2 = $GND_LON
			var $latSign_gs2 = 1
			if $latv_gs2 < 0
				$latSign_gs2 = -1
			var $lonSign_gs2 = 1
			if $lonv_gs2 < 0
				$lonSign_gs2 = -1
			var $latAbs_gs2 = $latv_gs2 * $latSign_gs2
			var $lonAbs_gs2 = $lonv_gs2 * $lonSign_gs2
			var $lat4_gs2 = floor(($latAbs_gs2*10000) + 0.5) / 10000
			var $lon4_gs2 = floor(($lonAbs_gs2*10000) + 0.5) / 10000
			$lat4_gs2 = $lat4_gs2 * $latSign_gs2
			$lon4_gs2 = $lon4_gs2 * $lonSign_gs2
			var $gsText2 = text("GS Lat:{}° Lon:{}°", $lat4_gs2, $lon4_gs2)
			; Approximate width: prefix 7 + lat (sign+2+1+4) + sep 6 + lon (sign+3+1+4) + suffix 1
			var $textChars = 7 + (1 + 2 + 1 + 4) + 6 + (1 + 3 + 1 + 4) + 1
			var $xGS2 = floor(($topW - ($textChars * $cw)) / 2)
			if $xGS2 < 2
				$xGS2 = 2
			var $ySepFooter = $topH - $footerH
			$d1_top.draw_line(0, $ySepFooter, $topW-1, $ySepFooter, gray)
			$d1_top.write($xGS2, $ySepFooter + 2, gray, $gsText2)
		else
			; Fallback: draw to Dashboard_1 bottom (channel 0) if top not present
			$d1_bot.blank(black)
			$d1_bot.text_size(1)
			$d1_bot.text_align(top_left)
			var $lhb = $d1_bot.char_h
			if $lhb <= 0
				$lhb = 16
			var $cwb = $d1_bot.char_w
			$d1_bot.write(2, 2, white, text("RECENT CONTACTS  ({})", $logTotal))
			; Separator under header
			$d1_bot.draw_line(0, 2 + $lhb + 2, $botW-1, 2 + $lhb + 2, gray)
			; Reserve footer for GS position
			var $footerHb = $lhb + 6
			var $availb = $botH - (3*$lhb) - $footerHb
			if $availb < 0
				$availb = 0
			var $entryHb = (2*$lhb) + 2
			var $rowsb = floor($availb / $entryHb)
			if $rowsb < 1
				$rowsb = 1
			var $startb = 0
			if $logCount > $rowsb
				$startb = $logCount - $rowsb
			var $yb = 2 + $lhb + 4
			var $toShowb = $logCount - $startb
			if $toShowb < 0
				$toShowb = 0
			repeat $toShowb ($rib)
				var $idxb = $startb + $rib
				; Alternating band background (odd rows)
				if mod($rib, 2) == 1
					var $fillHb = $entryHb
					repeat $fillHb ($fyb)
						$d1_bot.draw_line(0, $yb + $fyb - 1, $botW-1, $yb + $fyb - 1, gray)
				; Round lat/lon to 4 decimal places for display
				var $latvb = $logY.$idxb
				var $lonvb = $logX.$idxb
				var $latSignb = 1
				if $latvb < 0
					$latSignb = -1
				var $lonSignb = 1
				if $lonvb < 0
					$lonSignb = -1
				var $latAbsb = $latvb * $latSignb
				var $lonAbsb = $lonvb * $lonSignb
				var $lat4b = floor(($latAbsb*10000) + 0.5) / 10000
				var $lon4b = floor(($lonAbsb*10000) + 0.5) / 10000
				$lat4b = $lat4b * $latSignb
				$lon4b = $lon4b * $lonSignb
				var $line1b = text("{}  {}  {}", $logWhen.$idxb, $logStatus.$idxb, $logId.$idxb)
				var $line2b = text("Lat:{}°  Lon:{}°", $lat4b, $lon4b)
				var $colb = white
				if $logStatus.$idxb == "ACQ"
					$colb = green
				elseif $logStatus.$idxb == "LOST"
					$colb = red
				$d1_bot.write(2, $yb, $colb, $line1b)
				$d1_bot.write(2, $yb + $lhb, white, $line2b)
				$yb += $entryHb
			; Footer GS position centered at bottom
			var $latvb_gs2 = $GND_LAT
			var $lonvb_gs2 = $GND_LON
			var $latSignb_gs2 = 1
			if $latvb_gs2 < 0
				$latSignb_gs2 = -1
			var $lonSignb_gs2 = 1
			if $lonvb_gs2 < 0
				$lonSignb_gs2 = -1
			var $latAbsb_gs2 = $latvb_gs2 * $latSignb_gs2
			var $lonAbsb_gs2 = $lonvb_gs2 * $lonSignb_gs2
			var $lat4b_gs2 = floor(($latAbsb_gs2*10000) + 0.5) / 10000
			var $lon4b_gs2 = floor(($lonAbsb_gs2*10000) + 0.5) / 10000
			$lat4b_gs2 = $lat4b_gs2 * $latSignb_gs2
			$lon4b_gs2 = $lon4b_gs2 * $lonSignb_gs2
			var $gsTextb2 = text("GS Lat:{}° Lon:{}°", $lat4b_gs2, $lon4b_gs2)
			var $textCharsb = 7 + (1 + 2 + 1 + 4) + 6 + (1 + 3 + 1 + 4) + 1
			var $xGSb2 = floor(($botW - ($textCharsb * $cwb)) / 2)
			if $xGSb2 < 2
				$xGSb2 = 2
			var $ySepFooterb = $botH - $footerHb
			$d1_bot.draw_line(0, $ySepFooterb, $botW-1, $ySepFooterb, gray)
			$d1_bot.write($xGSb2, $ySepFooterb + 2, gray, $gsTextb2)

	; In-range contacts panel on Dashboard_3 (channel 0 + 1, spans 2 HD screens)
	var $trkW = $d3.width
	var $trkH = $d3.height
	var $trkW_bot = $d3_bot.width
	var $trkH_bot = $d3_bot.height
	; Calculate combined height for both screens
	var $combinedH = $trkH + $trkH_bot
	if $trkW > 0
		$d3.blank(black)
		$d3_bot.blank(black)
		$d3.text_size(1)
		$d3.text_align(top_left)
		$d3_bot.text_size(1)
		$d3_bot.text_align(top_left)
		var $lhc = $d3.char_h
		if $lhc <= 0
			$lhc = 16
		var $cwc = $d3.char_w
		; Count in-range contacts (only those with valid IDs)
		var $inCount = 0
		repeat $N ($ci)
			if $id.$ci != ""
				var $dxc = $dispAx.$ci
				var $dyc = $dispAy.$ci
				var $rngc = sqrt($dxc*$dxc + $dyc*$dyc)
				if ($vis.$ci == 1) and ($rngc <= $MAX_RANGE_KM)
					$inCount++
		$d3.write(2, 2, white, text("IN-RANGE CONTACTS  ({})", $inCount))
		; Separator under header
		$d3.draw_line(0, 2 + $lhc + 2, $trkW-1, 2 + $lhc + 2, gray)
		var $yC = 2 + $lhc + 4
		; Three-line entries with small padding
		var $entryHc = (3*$lhc) + 3
		var $rowsc = floor(($combinedH - $yC) / $entryHc)
		if $rowsc < 1
			$rowsc = 1
		; Precompute lon scaling
		var $latRad_c = $GND_LAT * $PI / 180
		var $kmPerDegLon_c = 111 * cos($latRad_c)
		if $kmPerDegLon_c < 0.01
			$kmPerDegLon_c = 0.01
		; Render in-range contacts up to available rows across both screens
		var $shown = 0
		repeat $N ($ri2)
			if $shown < $rowsc
				if $id.$ri2 != ""
					var $dxr = $dispAx.$ri2
					var $dyr = $dispAy.$ri2
					; Fallback to actual position if displayed position not yet scanned
					if ($dxr == 0) and ($dyr == 0)
						$dxr = $ax.$ri2
						$dyr = $ay.$ri2
					var $rng2 = sqrt($dxr*$dxr + $dyr*$dyr)
					if ($vis.$ri2 == 1) and ($rng2 <= $MAX_RANGE_KM)
						; Alternating band background (odd rows) - draw across both screens if needed
						if mod($shown, 2) == 1
							var $fillHc = $entryHc
							repeat $fillHc ($fyc)
								var $fillY = $yC + $fyc - 1
								if $fillY < $trkH
									$d3.draw_line(0, $fillY, $trkW-1, $fillY, gray)
								else
									$d3_bot.draw_line(0, $fillY - $trkH, $trkW_bot-1, $fillY - $trkH, gray)
						; Compute display values
						var $hdg_i = floor($hdg.$ri2 + 0.5)
						var $spd1 = floor(($spd.$ri2*10) + 0.5) / 10
						var $alt_i = floor($alt.$ri2 + 0.5)
						var $vs1 = floor(($vs.$ri2*10) + 0.5) / 10
						; Calculate lat/lon with validation
						var $line3c = "Lat/Lon: Scanning..."
						var $hasValidPos = 0
						if ($dxr != 0) or ($dyr != 0)
							$hasValidPos = 1
						if $hasValidPos == 1
							var $latv = $GND_LAT + ($dyr / 111)
							var $lonv = $GND_LON + ($dxr / $kmPerDegLon_c)
							var $latSign = 1
							if $latv < 0
								$latSign = -1
							var $lonSign = 1
							if $lonv < 0
								$lonSign = -1
							var $latAbs = $latv * $latSign
							var $lonAbs = $lonv * $lonSign
							var $lat4 = floor(($latAbs*10000) + 0.5) / 10000
							var $lon4 = floor(($lonAbs*10000) + 0.5) / 10000
							$lat4 = $lat4 * $latSign
							$lon4 = $lon4 * $lonSign
							$line3c = text("Lat:{}°  Lon:{}°", $lat4, $lon4)
						; Three-line block: ID, HDG/SPD/ALT/VS, Lat/Lon
						; Each line checks which screen it should draw on
						var $line1c = text("{}", $id.$ri2)
						var $line2c = text("HDG:{}°  SPD:{} m/s  ALT:{} m  VS:{} m/s", $hdg_i, $spd1, $alt_i, $vs1)
						; Line 1
						if $yC < $trkH
							$d3.write(2, $yC, white, $line1c)
						else
							$d3_bot.write(2, $yC - $trkH, white, $line1c)
						; Line 2
						var $yLine2 = $yC + $lhc
						if $yLine2 < $trkH
							$d3.write(2, $yLine2, white, $line2c)
						else
							$d3_bot.write(2, $yLine2 - $trkH, white, $line2c)
						; Line 3
						var $yLine3 = $yC + 2*$lhc
						if $yLine3 < $trkH
							$d3.write(2, $yLine3, white, $line3c)
						else
							$d3_bot.write(2, $yLine3 - $trkH, white, $line3c)
						$yC += $entryHc
						$shown++

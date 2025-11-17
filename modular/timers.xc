; Timers

timer frequency 0.5
	$labelPhase = mod($labelPhase + 1, 4)
	; advance uptime for session-relative timestamps
	$uptimeTicks += floor(25 * 0.5)

; 25Hz beeper control loop (I/O-safe context)
timer frequency 25
	; If a beep is armed this frame, start it
	if $buzzArm == 1
		; Set frequency (channel 1) then amplitude (channel 0)
		output_number("SPKR_0", 1, $buzzTone)
		output_number("SPKR_0", 0, 1)
		$buzzArm = 0
	; Maintain beep envelope and silence when done
	if $buzzTicks > 0
		$buzzTicks--
		if $buzzTicks == 0
			output_number("SPKR_0", 0, 0)

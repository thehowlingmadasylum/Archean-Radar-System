; Buzzer tones, state, and helpers

; Buzzer tones and beep timing
const $TONE_ACQ = 1200 ; Hz for acquire
const $TONE_LOST = 400  ; Hz for lost
const $BEEP_TICKS = 8   ; ~320 ms at 25Hz
var $buzzTicks = 0
var $buzzArm = 0
var $buzzTone = 0

; Buzzer helpers
function @buzz_start_acq()
	$buzzTone = $TONE_ACQ
	$buzzTicks = $BEEP_TICKS
	$buzzArm = 1

function @buzz_start_lost()
	$buzzTone = $TONE_LOST
	$buzzTicks = $BEEP_TICKS
	$buzzArm = 1

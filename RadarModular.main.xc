; RadarModular.main.xc — modular parent that includes child scripts
; Original monolith preserved: RadarDisplay.test.xc
; Set the computer to run this file as the entrypoint.

; Include order matters - state must come before geodesic
include "modular/utils.xc"
include "modular/storage.xc"
include "modular/state.xc"
include "modular/geodesic.xc"
include "modular/logs.xc"
include "modular/buzzer.xc"
include "modular/callsigns.xc"
include "modular/simulation.xc"
include "modular/screens.xc"
include "modular/icons.xc"
include "modular/render.xc"
include "modular/init.xc"
include "modular/timers.xc"
include "modular/tick.xc"

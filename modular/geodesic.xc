; Ground station position and geodesic helpers

; Ground station position (from NAV instrument)
var $GND_LAT = 0
var $GND_LON = 0

; Geodesic helper outputs
var $geoDeltaLat = 0
var $geoDeltaLon = 0
var $geoDistKm = 0

; Geodesic helpers for lat/lon conversion
function @km_to_lat_delta()
	; 1 degree latitude ~= 111 km
	; Returns delta lat in degrees for $geoInNorthKm km north
	var $deltaLat = $geoInNorthKm / 111
	$geoDeltaLat = $deltaLat

function @km_to_lon_delta()
	; 1 degree longitude varies by latitude: ~111*cos(lat) km
	; Returns delta lon in degrees for $geoInEastKm km east at $GND_LAT
	var $latRad = $GND_LAT * $PI / 180
	var $kmPerDegLon = 111 * cos($latRad)
	if $kmPerDegLon < 0.01
		$kmPerDegLon = 0.01
	var $deltaLon = $geoInEastKm / $kmPerDegLon
	$geoDeltaLon = $deltaLon

function @latlon_distance_km()
	; Haversine distance in km between ($geoInLon,$geoInLat) and ($GND_LON,$GND_LAT)
	var $lat1 = $geoInLat * $PI / 180
	var $lon1 = $geoInLon * $PI / 180
	var $lat2 = $GND_LAT * $PI / 180
	var $lon2 = $GND_LON * $PI / 180
	var $dlat = $lat2 - $lat1
	var $dlon = $lon2 - $lon1
	var $a = sin($dlat/2)*sin($dlat/2) + cos($lat1)*cos($lat2)*sin($dlon/2)*sin($dlon/2)
	var $c = 2 * atan(sqrt($a), sqrt(1-$a))
	var $dist = 6371 * $c
	$geoDistKm = $dist

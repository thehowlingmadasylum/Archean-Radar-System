; Aircraft callsign generator following real-world aviation standards

; Airline ICAO codes (3-letter) for commercial flights
const $AIRLINE_COUNT = 20
array $airlineCodes : text

; Military callsign prefixes
const $MILITARY_COUNT = 8
array $militaryCodes : text

; General aviation registration prefixes by country
const $GA_PREFIX_COUNT = 5
array $gaPrefixes : text

; Initialize callsign data (call during init)
function @callsign_init()
	; Major airline ICAO codes
	$airlineCodes.append("AAL") ; American Airlines
	$airlineCodes.append("UAL") ; United Airlines
	$airlineCodes.append("DAL") ; Delta Air Lines
	$airlineCodes.append("SWA") ; Southwest Airlines
	$airlineCodes.append("FFT") ; Frontier Airlines
	$airlineCodes.append("JBU") ; JetBlue Airways
	$airlineCodes.append("ASA") ; Alaska Airlines
	$airlineCodes.append("SKW") ; SkyWest Airlines
	$airlineCodes.append("ENY") ; Envoy Air
	$airlineCodes.append("RPA") ; Republic Airways
	$airlineCodes.append("BAW") ; British Airways
	$airlineCodes.append("AFR") ; Air France
	$airlineCodes.append("DLH") ; Lufthansa
	$airlineCodes.append("KLM") ; KLM Royal Dutch Airlines
	$airlineCodes.append("ANA") ; All Nippon Airways
	$airlineCodes.append("JAL") ; Japan Airlines
	$airlineCodes.append("QFA") ; Qantas
	$airlineCodes.append("ACA") ; Air Canada
	$airlineCodes.append("ETH") ; Ethiopian Airlines
	$airlineCodes.append("UAE") ; Emirates
	
	; Military callsign prefixes
	$militaryCodes.append("RCH") ; Reach (USAF Air Mobility Command)
	$militaryCodes.append("EVAC") ; Aeromedical Evacuation
	$militaryCodes.append("GTMO") ; Guantanamo Bay
	$militaryCodes.append("CNV") ; Convoy (Military cargo)
	$militaryCodes.append("SPAR") ; Special Air Resources
	$militaryCodes.append("NAVY") ; US Navy
	$militaryCodes.append("ARMY") ; US Army
	$militaryCodes.append("USAF") ; US Air Force
	
	; General aviation registration prefixes
	$gaPrefixes.append("N") ; United States
	$gaPrefixes.append("C") ; Canada
	$gaPrefixes.append("G") ; United Kingdom
	$gaPrefixes.append("D") ; Germany
	$gaPrefixes.append("F") ; France

; Generate a random commercial airline callsign (e.g., "AAL2441", "UAL1957")
function @generate_airline_callsign() : text
	; Pick random airline
	var $airlineIdx = floor(random * $AIRLINE_COUNT)
	var $code = $airlineCodes.$airlineIdx
	; Flight number: 1-9999
	var $flightNum = floor(random * 9999) + 1
	return text("{}{}", $code, $flightNum)

; Generate a random military callsign (e.g., "RCH453", "EVAC12")
function @generate_military_callsign() : text
	; Pick random military prefix
	var $milIdx = floor(random * $MILITARY_COUNT)
	var $code = $militaryCodes.$milIdx
	; Mission number: 1-999
	var $missionNum = floor(random * 999) + 1
	return text("{}{}", $code, $missionNum)

; Generate a random general aviation registration (e.g., "N215U", "N757NJ", "C-GABC")
function @generate_ga_callsign() : text
	; Pick random country prefix
	var $prefixIdx = floor(random * $GA_PREFIX_COUNT)
	var $prefix = $gaPrefixes.$prefixIdx
	
	; US registrations (N-prefix): N + 1-5 digits/letters
	if $prefix == "N"
		; Generate pattern: N + (1-4 digits) + (0-2 letters)
		var $digitCount = floor(random * 4) + 1
		var $letterCount = floor(random * 3)
		
		var $callsign = "N"
		
		; Add digits
		repeat $digitCount ($d)
			var $digit = floor(random * 10)
			$callsign &= $digit:text
		
		; Add letters (if any)
		repeat $letterCount ($l)
			var $letterIdx = floor(random * 26)
			var $letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
			; Extract single character by index
			if $letterIdx == 0
				$callsign &= "A"
			elseif $letterIdx == 1
				$callsign &= "B"
			elseif $letterIdx == 2
				$callsign &= "C"
			elseif $letterIdx == 3
				$callsign &= "D"
			elseif $letterIdx == 4
				$callsign &= "E"
			elseif $letterIdx == 5
				$callsign &= "F"
			elseif $letterIdx == 6
				$callsign &= "G"
			elseif $letterIdx == 7
				$callsign &= "H"
			elseif $letterIdx == 8
				$callsign &= "I"
			elseif $letterIdx == 9
				$callsign &= "J"
			elseif $letterIdx == 10
				$callsign &= "K"
			elseif $letterIdx == 11
				$callsign &= "L"
			elseif $letterIdx == 12
				$callsign &= "M"
			elseif $letterIdx == 13
				$callsign &= "N"
			elseif $letterIdx == 14
				$callsign &= "O"
			elseif $letterIdx == 15
				$callsign &= "P"
			elseif $letterIdx == 16
				$callsign &= "Q"
			elseif $letterIdx == 17
				$callsign &= "R"
			elseif $letterIdx == 18
				$callsign &= "S"
			elseif $letterIdx == 19
				$callsign &= "T"
			elseif $letterIdx == 20
				$callsign &= "U"
			elseif $letterIdx == 21
				$callsign &= "V"
			elseif $letterIdx == 22
				$callsign &= "W"
			elseif $letterIdx == 23
				$callsign &= "X"
			elseif $letterIdx == 24
				$callsign &= "Y"
			else
				$callsign &= "Z"
		
		return $callsign
	else
		; Other countries: Prefix + hyphen + 4 alphanumeric
		var $callsign = text("{}-", $prefix)
		repeat 4 ($i)
			var $useDigit = random < 0.5
			if $useDigit
				var $digit = floor(random * 10)
				$callsign &= $digit:text
			else
				var $letterIdx = floor(random * 26)
				if $letterIdx == 0
					$callsign &= "A"
				elseif $letterIdx == 1
					$callsign &= "B"
				elseif $letterIdx == 2
					$callsign &= "C"
				elseif $letterIdx == 3
					$callsign &= "D"
				elseif $letterIdx == 4
					$callsign &= "E"
				elseif $letterIdx == 5
					$callsign &= "F"
				elseif $letterIdx == 6
					$callsign &= "G"
				elseif $letterIdx == 7
					$callsign &= "H"
				elseif $letterIdx == 8
					$callsign &= "I"
				elseif $letterIdx == 9
					$callsign &= "J"
				elseif $letterIdx == 10
					$callsign &= "K"
				elseif $letterIdx == 11
					$callsign &= "L"
				elseif $letterIdx == 12
					$callsign &= "M"
				elseif $letterIdx == 13
					$callsign &= "N"
				elseif $letterIdx == 14
					$callsign &= "O"
				elseif $letterIdx == 15
					$callsign &= "P"
				elseif $letterIdx == 16
					$callsign &= "Q"
				elseif $letterIdx == 17
					$callsign &= "R"
				elseif $letterIdx == 18
					$callsign &= "S"
				elseif $letterIdx == 19
					$callsign &= "T"
				elseif $letterIdx == 20
					$callsign &= "U"
				elseif $letterIdx == 21
					$callsign &= "V"
				elseif $letterIdx == 22
					$callsign &= "W"
				elseif $letterIdx == 23
					$callsign &= "X"
				elseif $letterIdx == 24
					$callsign &= "Y"
				else
					$callsign &= "Z"
		
		return $callsign

; Generate a random callsign (mixed types for realistic variety)
function @generate_random_callsign() : text
	; Distribution: 50% commercial, 35% GA, 15% military
	var $typeRoll = random
	if $typeRoll < 0.5
		; Commercial airline
		return @generate_airline_callsign()
	elseif $typeRoll < 0.85
		; General aviation
		return @generate_ga_callsign()
	else
		; Military
		return @generate_military_callsign()


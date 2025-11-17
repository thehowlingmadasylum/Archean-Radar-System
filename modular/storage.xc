; Persistent storage for contact log history

; Storage capacity configuration
const $MAX_HISTORY = 200 ; Max persistent log entries (must stay under 256 storage limit)

; Persistent log storage arrays (stored on disk, survive reboots)
storage array $histId : text
storage array $histWhen : text
storage array $histStatus : text
storage array $histLat : number
storage array $histLon : number

; Initialize storage on first boot or validate existing storage
function @storage_init()
	; Storage arrays are automatically loaded from disk if they exist
	; Nothing to do here unless we want to validate/migrate old data
	; Size is automatically preserved from disk

; Add new log entry to persistent storage (with automatic overflow management)
function @storage_add_log($id : text, $when : text, $status : text, $lat : number, $lon : number)
	; If storage is full, remove oldest entry to make room
	if size($histId) >= $MAX_HISTORY
		$histId.erase(0)
		$histWhen.erase(0)
		$histStatus.erase(0)
		$histLat.erase(0)
		$histLon.erase(0)
	; Append new entry to all storage arrays
	$histId.append($id)
	$histWhen.append($when)
	$histStatus.append($status)
	$histLat.append($lat)
	$histLon.append($lon)

; Get total number of historical log entries
function @storage_log_count() : number
	return size($histId)

; Clear all historical logs (use with caution)
function @storage_clear_logs()
	$histId.clear()
	$histWhen.clear()
	$histStatus.clear()
	$histLat.clear()
	$histLon.clear()


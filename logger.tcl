package provide logger 1.0

namespace eval Logger {
	namespace export warn error info ok debug
	variable traceLevel 0
	proc log {level line} {
		variable traceLevel
		if {$traceLevel < $level } {
				puts stderr "\[[icon $level]\]$line"
			}
	}
	proc debug {line} {
		log 1 $line
	}
	proc warn {line} {
		log 2 $line
	}
	proc info {line} {
		log 3 $line
	}
	proc error {line} {
		log 4 $line
	}
	proc ok {line} {
		log 5 $line
	}
	proc icon {level} {
		switch $level {
			1 {return "d"}
			2 {return "w"}
			3 {return "!"}
			4 {return "-"}
			5 {return "+"}
		}
	}
}

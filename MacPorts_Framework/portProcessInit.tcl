package require macports
#package require notifications Require My new notifications extension


#Set ui_options to log all messages to stdout and notify system
#filtering is done on the Obj-C side of things
set ui_options(ports_debug) "yes"
set ui_options(ports_verbose) "yes"

# ui_options accessor
proc ui_isset {val} {
	global ui_options
	if {[info exists ui_options($val)]} {
		if {$ui_options($val) == "yes"} {
			return 1
		}
	}
	return 0
}

#Wrapping the following API routines to catch errors
#and log error Information in a similar fashion to code
#in macports.tcl.
proc mportuninstall {portname {v ""} {optionslist ""}} {
	if {[catch {portuninstall::uninstall $portname $v $optionslist} result]} {
		
			global errorInfo
			ui_debug "$errorInfo"
			ui_error "Uninstall $portname $v failed: $result"
			return 1
	}
}

proc mportactivate {portname v optionslist} {
	if {[catch {portimage::activate $portname $v $optionslist} result]} {
			
			global errorInfo
			ui_debug "$errorInfo"
			ui_error "Activate $portname $v failed: $result"
			return 1
	}
}

proc mportdeactivate {portname v optionslist} {
	if {[catch {portimage::deactivate $portname $v $optionslist} result]} {
			
			global errorInfo
			ui_debug "$errorInfo"
			ui_error "Deactivate $portname $v failed: $result"
			return 1
	}
}

proc mportupgrade {portname} {
    array set depscache {}
	if {[catch {macports::upgrade $portname "port:$portname" [array get global_variations] [array get variations] [array get options] depscache} result]} {
			
			global errorInfo
			ui_debug "$errorInfo"
			ui_error "Upgrade $portname failed: $result"
			return 1
	}
}


# Initialize dport
# This must be done following parse of global options, as some options are
# evaluated by dportinit.
if {[catch {mportinit ui_options global_options global_variations} result]} {
	global errorInfo
	puts "$errorInfo"
	fatal "Failed to initialize ports system, $result"
}

package require macports
package require notifications

proc ui_init {priority prefix channels message} {
    switch $priority {
  		msg {
  			set nottype "MPMsgNotification" 
  		}
  		debug {
  			set nottype "MPDebugNotification"
  			puts "Recieved Debug init"
  		}
  		warn {
  			set nottype "MPWarnNotification"
  		}
  		error {
  			set nottype "MPErrorNotification"
  			puts "Recieved Error"
  		}
  		info {
  			set nottype "MPInfoNotification"
  			puts "Recieved Info"
  		}
  		default {
  			set nottype "MPDefaultNotification"
  		}	
  	}

    proc ::ui_$priority {message} [subst {
        notifications send $nottype "$channels($priority) $prefix" "\$message"
        ui_message $priority $prefix "" "\$message"
    }]
}



#Wrapping the following API routines to catch errors
#and log error Information in a similar fashion to code
#in macports.tcl.
proc mportuninstall {portname {v ""} {optionslist ""}} {
	if {[catch {registry_uninstall::uninstall $portname $v $optionslist} result]} {
		
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

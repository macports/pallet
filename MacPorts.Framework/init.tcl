#catch {source \
#	[file join "/Library/Tcl" macports1.0 macports_fastload.tcl]}

#Trying my own MacPorts build rather than default one on the system
catch {source \
	[file join "/Users/Armahg/macportsbuild/build1/Library/Tcl" macports1.0 macports_fastload.tcl]}


package require macports
package require notifications

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

# UI Callback
proc ui_prefix {priority} {
    switch $priority {
        debug {
        	return "DEBUG: "
        }
        error {
        	return "Error: "
        }
        warn {
        	return "Warning: "
        }
        default {
        	return ""
        }
    }
}

proc ui_channels {priority} {
    global logfd
    switch $priority {
        debug {
            if {[ui_isset ports_debug]} {
            	return {stderr}
            } else {
            	return {}
            }
        }
        info {
            if {[ui_isset ports_verbose]} {
                return {stdout}
            } else {
                return {}
			}
		}
        msg {
            if {[ui_isset ports_quiet]} {
                return {}
			} else {
				return {stdout}
			}
		}
        error {
        	return {stderr}
        }
        default {
        	return {stdout}
        }
    }
}


#Modifying UI initialization to enable notifications
proc ui_init {priority prefix channels message} {

	#notifications send global "MP $message Notification" "INSIDE UI_INIT"
	#notifications send global MPpriorityNotification "INSIDE UI_INIT"
	
    # Get the list of channels.
    try {
        set channels [ui_channels $priority]
    } catch * {
        set channels [ui_channels_default $priority]
    }

    # Simplify ui_$priority.
    set nbchans [llength $channels]
    if {$nbchans == 0} {
        proc ::ui_$priority {str} 
		[ 
		notifications send global "MP $priority Notification" $message ]
    } else {
        try {
            set prefix [ui_prefix $priority]
        } catch * {
            set prefix [ui_prefix_default $priority]
        }
            
		if {$nbchans == 1} {
                set chan [lindex $channels 0]
				
				#Redefine ui_$priority here to also throw notifications of some sort
				proc ::ui_$priority {str} [
					subst { puts $chan "$prefix\$str" }

					#Send notifications using NSDistributedNotificationCenter for now
					#We need a way to name notifications based on given input, using
					#testMacPortsNotification for now
					notifications send global "MP $priority Notification" "$str"
					notifications send global "MP $priority Notification" $message
				]
				
				
            } else {
                proc ::ui_$priority {str} [
					subst {
						foreach chan \$channels {
							puts $chan "$prefix\$str"
						}
					}
					#Should we discriminate based on channel?
					notifications send global "MP $priority Notification" $message
				]
            }
			
        # Call ui_$priority
        ::ui_$priority $message
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
#catch {source \
#	[file join "/Library/Tcl" macports1.0 macports_fastload.tcl]}

#Trying my own MacPorts build rather than default one on the system
catch {source \
	[file join "/Users/Armahg/macportsbuild/build1/Library/Tcl" macports1.0 macports_fastload.tcl]}

#load notifications.dylib


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


#Helper function for sending notifications 
#Action taken is based on priority
#ui_msg - Sent as local notifications
#ui_debug - Don't know what to do with this for now
#ui_warn - Send as local notification ?
#ui_error - Send as local notification ? 
#ui_info - Also don't know what to do with this for now
#Remember to strip possible possible preceding "--->" from message

proc notify_system {priority prefix chan str} {
	set newstr [string trimleft $str "--->"]
	
	#puts $newstr
	
	switch $priority {
		#For now, send these as message notifications to
		#client application. I really think we need some more
		#granularity, how is someone suppose to know if the 
		#message is coming from the result of a sync, selfupdate,
		#exec call etc. ?
		#Suggestion : We can either have user's modify a variable that
		#indicates the current mport operation being performed or we can
		#inquire from the interpreter and change the notification name
		#based on that.
		
		msg {
			notifications send "MPMsgNotification" \
			"Channel $chan Prefix $prefix" $newstr 
		}
		debug {
			#For now we don't need to do anything with these?
			#The user can scrape stdout for them
		}
		warn {
			notifications send "MPWarnNotification" \
			"Channel $chan Prefix $prefix" $newstr
		}
		error {
			notifications send global "MPErrorNotification" \
			"Channel $chan Prefix $prefix" $newstr
		}
		info {
			notifications send "MPInfoNotification" \
			"Channel $chan Prefix $prefix" $newstr
		}
		default {
			#Don't send anything for now
		}			
	}
}



#Modifying UI initialization to enable notifications
#Redefine ui_$pritority to throw global notifications
#This is currently under works ... a reasonable solution
#should be coming up soon
proc ui_init {priority prefix channels message} {
	
	switch $priority {
		msg {
			set nottype "MPMsgNotification" 
			set sendNotification "true"
		}
		debug {
			#For now we don't need to do anything with these?
			#The user can scrape stdout for them
			set sendNotification "false"
		}
		warn {
			set nottype "MPWarnNotification"
			set sendNotification "true"
		}
		error {
			set nottype "MPErrorNotification"
			set sendNotification "true"
		}
		info {
			set nottype "MPInfoNotification"
			set sendNotification "true"
		}
		default {
			#Don't send anything for now
			set nottype "MPDefaultNotification"
			set sendNotification "false"
		}	
	}
    # Get the list of channels.
    try {
        set channels [ui_channels $priority]
    } catch * {
        set channels [ui_channels_default $priority]
    }

    # Simplify ui_$priority.
    set nbchans [llength $channels]
    if {$nbchans == 0} {
        proc ::ui_$priority {str} [subst {
        		#notifications send global "MP $priority Notification" "Channel1 none \
        		#Prefix $prefix" "\$str"
        		#notify_system $priority $prefix "none" $message 
				
				if {$sendNotification == "true"} {
					notifications send $nottype "Channel $chan Prefix $prefix" "\$str"
				}
        }]
    } else {
        try {
            set prefix [ui_prefix $priority]
        } catch * {
            set prefix [ui_prefix_default $priority]
        }

        try {
            ::ui_init $priority $prefix $channels $message
        } catch * {
            if {$nbchans == 1} {
                set chan [lindex $channels 0]
                
                proc ::ui_$priority {str} [subst { 
                	puts $chan "$prefix\$str"
                	#notifications send "MP $priority Notifications" "Channel2 $chan \
                	#Prefix $prefix" "\$str"
					#notify_system $priority $prefix $chan "\$str"
					
					if {$sendNotification == "true"} {
						notifications send $nottype "Channel $chan Prefix $prefix" "\$str"
					}
                }]
            } else {
            		
                proc ::ui_$priority {str} [subst {
                    foreach chan \$channels {
                        puts $chan "$prefix\$str"
                        #notify_system $priority $prefix $chan $message
						#notifications send global "MP $priority Notifications" "Channel3 $chan \
						#Prefix $prefix" "\$str"
						
						if {$sendNotification == "true"} {
							notifications send $nottype "Channel $chan Prefix $prefix" "\$str"
						}
                    }
                }]
            }
        }
        # Call ui_$priority
        ::ui_$priority $message
    }
}


#Wrapping the following API routines to catch errors
#and log error Information in a similar fashion to code
#in macports.tcl.
proc mportuninstall {portname {v ""} optionslist} {
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


# Initialize dport
# This must be done following parse of global options, as some options are
# evaluated by dportinit.
if {[catch {mportinit ui_options global_options global_variations} result]} {
	global errorInfo
	puts "$errorInfo"
	fatal "Failed to initialize ports system, $result"
}
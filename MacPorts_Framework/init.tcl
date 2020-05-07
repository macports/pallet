package require macports
package require notifications

proc ui_init {priority prefix channels args} {
    global display_message

    switch $priority {
  		msg {
  			set nottype "MPMsgNotification" 
  		}
  		debug {
  			set nottype "MPDebugNotification"
            puts "Debug: $args"
  		}
  		warn {
  			set nottype "MPWarnNotification"
  		}
  		error {
  			set nottype "MPErrorNotification"
  			puts "Error: $args"
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
        notifications send $nottype "$prefix" "\$message"
        ui_message $priority $prefix { " nonewline" "\$message" }
    }]
}



#Wrapping the following API routines to catch errors
#and log error Information in a similar fashion to code
#in macports.tcl.
proc test {} {
    puts "TEST"
}

proc mportuninstall {portname {version ""} {revision ""} {variants 0} {optionslist ""}} {
	if {[catch {registry_uninstall::uninstall $portname $version $revision $variants $optionslist} result]} {
		
			global errorInfo
			ui_debug "$errorInfo"
			ui_error "Uninstall $portname ${version}_${revision}${variants} failed: $result"
			return 1
	}
}
proc mportuninstall_composite {portname {v ""} {optionslist ""}} {
	if {[catch {registry_uninstall::uninstall_composite $portname $v $optionslist} result]} {
		
			global errorInfo
			ui_debug "$errorInfo"
			ui_error "Uninstall $portname $v failed: $result"
			return 1
	}
}

proc mportactivate {portname {version ""} {revision ""} {variants 0} {optionslist ""}} {
	if {[catch {portimage::activate $portname $version $revision $variants $optionslist} result]} {
			
			global errorInfo
			ui_debug "$errorInfo"
			ui_error "Activate $portname ${version}_${revision}${variants} failed: $result"
			return 1
	}
}
proc mportactivate_composite {portname {v ""} {optionslist ""}} {
	if {[catch {portimage::activate_composite $portname $v $optionslist} result]} {
			
			global errorInfo
			ui_debug "$errorInfo"
			ui_error "Activate $portname $v failed: $result"
			return 1
	}
}

proc mportdeactivate {portname {version ""} {revision ""} {variants 0} {optionslist ""}} {
	if {[catch {portimage::deactivate $portname $version $revision $variants $optionslist} result]} {
			
			global errorInfo
			ui_debug "$errorInfo"
			ui_error "Deactivate $portname ${version}_${revision}${variants} failed: $result"
			return 1
	}
}
proc mportdeactivate_composite {portname {v ""} {optionslist ""}} {
	if {[catch {portimage::deactivate_composite $portname $v $optionslist} result]} {
			
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
global display_message
set display_message 0
if {[catch {mportinit ui_options global_options global_variations} result]} {
	global errorInfo
	puts "$errorInfo"
	fatal "Failed to initialize ports system, $result"
}

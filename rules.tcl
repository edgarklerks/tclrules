package provide ruleH 1.0
package require logger 1.0
package require rulesUtils 1.0
package require rulesGraph 1.0

ruleH runOnce {name} {
    if { [lindex [dict get $rules $name] 1] eq "once"} {
        return 1
    } else {
        return 0
    }
}

ruleH runRule {name} {
    set ruleDef [dict get $rulesDef $name]
    if {[dict exists $ranRules $name] eq 0 || ![runOnce $name]} {
        dict set ranRules $name 1
        uplevel $ruleDef
    } else {
        Logger::debug "Skipping rule $name"
    } 
}

ruleH hasUnimplemented {} {
    forRules {
        if {$state eq "U"} {
            Logger::info "Unimplemented $rule"
            set err 1
        }
    }
}

ruleH checkRules {} {
    set err 0
    hasUnimplemented
    hasCycle
    if {$err eq 1} {
        exit 1
    }
}

ruleH showRules {} {
    puts "The following rules are available"
    forRules { 
        puts $rule

    }
}


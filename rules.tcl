
package require hash
#catch {[hashVal]} res
#catch {[hashFile]} res
package provide ruleH 1.0
package require logger 1.0
package require rulesUtils 1.0
package require rulesEnv 1.0
package require rulesGraph 1.0

namespace eval Rules {
    variable rules [dict create]
    variable ruleEdges [dict create]
    variable rulesDef [dict create]
    variable ranRules [dict create]
    variable ruleChecks [list]
    variable err

    ruleH reset {} {
        variable rules [dict create]
        variable rulesDef [dict create]
        variable ruleEdges [dict create]
        variable ranRules [dict create] 
        variable err 0
    }
}

ruleH addRuleCheck {name} {
    variable ruleChecks
    lappend ruleChecks $name
}


ruleH runOnce {name} {
    if { [lindex [dict get $rules $name] 1] eq "once"} {
        return 1
    } else {
        return 0
    }
}


ruleH runRule {name} {
    if {[dict exists $rulesDef $name] eq 0} {
        Logger::error "Rule $name doesn't exist" 
        exit 1
    }
    set ruleDef [dict get $rulesDef $name]
    if {[dict exists $ranRules $name] eq 0 || ![runOnce $name]} {
        dict set ranRules $name 1
        puts $ruleDef
        uplevel $ruleDef
    } else {
        Logger::debug "Skipping rule $name"
    }
}

ruleH hasUnimplemented {} {
    variable err
    forRules {
        if {$state eq "U"} {
            Logger::info "Unimplemented $rule"
            set err 1
        }
    }
}

Rules::addRuleCheck hasUnimplemented
Rules::addRuleCheck hasCycle

ruleH checkRules {} {
    variable ruleChecks
    variable err 
    set err 0
    foreach check $ruleChecks {
        namespace eval Rules [list uplevel $check]
    }
    if {$err eq 1} {
        puts "Rules are wrong"
        exit 1
    }
}

ruleH showRules {} {
    puts "The following rules are available"
    forRules {
        puts $rule

    }
}

proc forFiles {files body} {

    set res [foreach file $files {
        if {[file exists $file]} {
            return 1            
        }
    }]

    if {$res} {
        uplevel $body
    }

}
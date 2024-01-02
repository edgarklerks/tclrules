package provide rulesGraph 1.0
package require rulesUtils 1.0


ruleH isRecStack {name} {
    upvar recStack recStack
    return [dict get $recStack $name]
}

ruleH isVisited {name} {
    upvar visited visited
    return [dict get $visited $name]
}

ruleH setVisited {name v} {
    upvar visited visited
    dict set visited $name $v
}

ruleH setRecStack {name v} {
    upvar recStack recStack
    upvar visited visited
    dict set recStack $name $v
}

ruleH DFSCycle {name} {
    upvar cyclic cyclic
    upvar recStack recStack
    upvar visited visited
    if {[isRecStack $name]} {
    return 0
   }    
   if {[isVisited $name]} {
    return 1
   }
   setVisited $name 1
   foreach n [getNeighbours $name] {
   if { [DFSCycle $n] } {
    lappend cyclic $n
   }}
   setRecStack $name 1
   return 0
}

proc lunique {list} {
    upvar $list q
    set l [dict create]
    foreach e $q {dict set l $e 1}
    set q [dict keys $l]
}

# Various rules 

ruleH hasCycle {} {
    variable err
    set visited [dict create]
    set recStack [dict create]
    forRules {
        setVisited $rule 0
        setRecStack $rule 0
    }
    forRules { 
        set cyclic [list]
        if {[DFSCycle $rule]} {
            lappend cyclic $rule
        }
        if {[llength $cyclic] > 0} {
            lunique cyclic
            Logger::info "Cycle detected in $cyclic"
            set err 1

        }
    }
    if {$err eq 1} {
        return 1
    }
}

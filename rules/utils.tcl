package provide rulesUtils 1.0

namespace eval Rules {
    variable rules [dict create]
    variable ruleEdges [dict create]
    variable rulesDef [dict create]
    variable ranRules [dict create]
}

set rules [dict create]
set ruleEdges [dict create]
set rulesDef [dict create]
set ranRules [dict create]

proc ruleH {name larg body} {
   set source "upvar rules rules;\
   upvar ruleEdges ruleEdges;\
   upvar err err;\
   upvar rulesDef rulesDef;\
   upvar ranRules ranRules; $body"

   proc $name $larg $source 
}


ruleH forEdges {body} {
    dict for {s ns} $ruleEdges {
        foreach e $ns {
            uplevel [list set edge "$s,$e"]
            uplevel [list set s $s]
            uplevel [list set e $e]
            uplevel $body
        }
    }
}


ruleH forRules {body} {
    dict for {rule st} $rules {
        set state [lindex $st 0]
        set once [lindex $st 1]
        uplevel [list set state $state]
        uplevel [list set once $once]
        uplevel [list set rule $rule]
        uplevel $body
        
    }
}

ruleH addRule {name other_rules once} {

    insertNode $name [list I $once]
    initEdge $name 
    foreach rule $other_rules {
        unlessNode rule_$rule {
            insertNode rule_$rule [list U ""]
        }
        addEdge $name rule_$rule 
     }
}

ruleH initEdge {name} {
    set ruleEdges [dict set ruleEdges $name [list]]
}

ruleH addEdge {name rule } {
    set ruleEdges [dict lappend ruleEdges $name $rule]
}

ruleH unlessNode {name body} {
    if {[dict exists $rules $name] eq 0} {
        uplevel $body
    }
}

ruleH insertNode {name state} {
    set rules [dict set rules $name $state]
}


ruleH getNeighbours {name} {
    if {[dict exists $ruleEdges $name]} {
        return [dict get $ruleEdges $name]
    }
    return [list]
}


ruleH rule {name other_rules body {once "once"}} {
    set name "rule_$name"
    addRule $name $other_rules $once
    set nameRule [list Logger::info "Running rule $name"]
    set prefix ""
    foreach rule $other_rules {
        append prefix "uplevel rule_$rule\n"

    }
    set rulesDef [dict set rulesDef $name "$prefix$nameRule$body"]
    ruleH $name {} "runRule $name"
}

lappend auto_path [pwd]
package require tcltest
package require ruleH

tcltest::test graph-cycle-found {
    Find a simple graph cycle 
} -setup {
    Rules::reset
} -body {
    rule x {y} {
    }
    rule y {x} {

    }
    return [Rules::hasCycle]
} -result 1

tcltest::test graph-complex-cycle-found {
    Find a complicated cycle
} -setup {
    Rules::reset
} -body {
    rule x {y} {

    }
    rule y {z} {

    }
    rule z {x y} {

    }
    return [Rules::hasCycle]

} -result 1

tcltest::test rules_get_run_env_works {
    rule gets run and env works
} -setup {
 Rules::reset
} -body {
    rule x {} {
        %test=1
    }

    Rules::runRule rule_x
    return [%test]
} -result 1

tcltest::test rules_run_once {
    rule gets run only once 
} -setup {
    Rules::reset
} -body {
    Rules::env counter 0
    rule x {y y} {
    } 
    rule y {} {
        set counter [%counter]
        incr counter
        %counter=$counter
    }

    Rules::runRule rule_x
    return [%counter]

} -result 1

tcltest::test rules_run_once {
    rule gets run only once 
} -setup {
    Rules::reset
} -body {
    Rules::env counter 0
    rule x {y y} {
    } 
    rule y {} {
        set counter [%counter]
        incr counter
        %counter=$counter
    } mult

    Rules::runRule rule_x
    return [%counter]

} -result 2

%t=3

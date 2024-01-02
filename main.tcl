#!env tclsh

lappend auto_path [pwd]
package require ruleH
package require runner
package require logger


source Rules 
Rules::checkRules

if {$argc eq 0} {
    Rules::showRules
}

foreach arg $argv {
        Rules::runRule rule_$arg
}

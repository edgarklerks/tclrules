#!env tclsh

lappend auto_path [pwd]

package require struct
package require ruleH
package require runner
package require logger

source Rules 
checkRules

if {$argc eq 0} {
    showRules
}

foreach arg $argv {
        rule_$arg
}

puts $ranRules
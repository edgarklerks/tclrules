package provide rulesEnv 1.0

namespace eval Rules {
    variable envVars [dict create]

    proc env {name {value ""}} {
        variable envVars
        if {$value ne ""} {
            dict set envVars $name $value
            return
        }
        return [dict get $envVars $name]
    }

    proc unsetEnv {name} {
        variable envVars
        dict unset envVars $name
    }
}

if {[info proc _unknown]==""} {rename unknown _unknown} ;# keep the original
proc unknown {args} {
    set stringStart [string index $args 0]
    if {[llength $args] == 1 && $stringStart eq "%"} {
        set data [string replace $args 0 0]
        if {[regexp "(.+)=(.+)" $data glob name val]} {
                Rules::env $name $val
                return 
        } else {
            return [Rules::env $data]
        }
    }
    return [_unknown $args]
} 
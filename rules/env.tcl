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
rename  unknown env_unknown_original  
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
    } elseif {$stringStart eq "%"} {
        set data [string replace $args 0 0]
        if {[regexp "(.+)=(.+)" $data glob name val]} {
            puts $data
                if { [catch [list eval $val] res] } {
                    puts "Name: $name, $val"
                    Rules::env $name $val
                } else {
                    Rules::env $name $res
                }
                return 
        }
    }
    uplevel 1 env_unknown_original $args
} 
        
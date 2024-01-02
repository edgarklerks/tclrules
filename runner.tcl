package provide runner 1.0
package require Thread
package require logger

set counter 0

proc readpipe {p1 p2} {
    append ::out($p1) [read $p1]
    if {[eof $p1]} {
        close $p1
        if {$p2 ni [chan names]} {
            set ::done ok
        }
    }
}

proc pushpipe {p1 p2 out} {
    set line [read $p1]
    if {$line ne "" && $line ne "\n"} {
        puts -nonewline $out $line 
    }
    if {[eof $p1]} {
        chan eof $p1
        close $p1 
        if { $p2 ni [chan names]} {
            set ::done ok 
        }
    }
}


proc invoke {chanout chanerr command args} {
    lassign [chan pipe] rerr werr 
    lassign [chan pipe] rout wout 

    fconfigure $rerr -blocking 0 -buffering line 
    fconfigure $rout -blocking 0 -buffering line

    fileevent $rerr readable "pushpipe $rerr $rout $chanerr"
    fileevent $rout readable "pushpipe $rout $rerr $chanout"

    set runList [list $command {*}$args] 

    set tid [thread::create]
    thread::transfer $tid $werr
    thread::transfer $tid $wout

    thread::send $tid {
        proc runCommand {cmdList out err} {
            if [catch {
                exec {*}$cmdList >@$out 2>@$err
            } status] {
                puts stderr "\[-\] Error while running $cmdList: $status"
                exit 1
            }  
            close $out
            close $err
        }
    }


    thread::send $tid [list runCommand [list $command {*}$args] $wout $werr]
    vwait done
    chan close $chanout write 
    chan close $chanerr write
    thread::release $tid
}

proc prefixPipe {p1 out prefix} {
    set line [gets $p1]
    if {$line ne ""} {
        puts $out "\[$prefix\] $line"   
    }
    if {[chan eof $p1]} {
        chan close $p1
        set ::prefix$prefix 1
    }
}
proc mkLambda {argl body} {
    global counter
    upvar lambda_name lambda_name
    set name "lambda_$counter"
    set counter [expr $counter + 1 ]
    set prefix [list set done "rename $name \"\""]
    proc $name $argl $prefix$body
    set lambda_name $name
    return $name
}


proc mapChan {chan mapper args} {
    lassign [chan pipe] rchan wchan
    fconfigure $rchan -blocking 0 -buffering line
    fconfigure $wchan -blocking 0 -buffering line
 
    chan event $rchan readable "$mapper $rchan $chan {*}$args"
    return $wchan
}


proc run {cmd args} {
            set perr [mapChan stderr prefixPipe -]
            set pout [mapChan stdout prefixPipe +]
            invoke $pout $perr $cmd {*}$args
            vwait prefix+
}


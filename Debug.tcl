if { [namespace exists Debug] } return
source [file join [file dirname [info script]] ProcAccess.tcl]


#============================================================================
#============================================================================
#============================================================================

namespace eval ::Debug {
  variable verbose_ 0

  public proc setVerbose { {onOff 1} } {
    variable verbose_
    set verbose_ $onOff
  }

  public proc verboseDo { script } {
    variable verbose_
    if { $verbose_ } {
      uplevel $script
    }
  }

  public proc vputs { msg } {
    verboseDo {
      puts $msg
    }
  }

  public proc dumpDict { title dict {indent 0} } {
    lassign [split "$title|Key|Value" |] title lbl1 lbl2
    set maxKeyWd [string length $lbl1]
    set maxValWd [string length $lbl2]
    dict for {key val} $dict {
      if { [set wd [string length $key]] > $maxKeyWd } {
        set maxKeyWd $wd
      }
      foreach val [splitDictVal $val] {
        if { [set wd [string length $val]] > $maxValWd } {
          set maxValWd $wd
        }
      }
    }
    set pfx [string repeat "  " $indent]
    set dashes [string repeat "-" [expr {$maxKeyWd > $maxValWd ? $maxKeyWd : $maxValWd}]]
    set fmt "${pfx}${pfx}| %-${maxKeyWd}.${maxKeyWd}s | %-${maxValWd}.${maxValWd}s |"
    puts "${pfx}$title \{"
    puts [format $fmt $lbl1 $lbl2]
    #puts [format $fmt $maxKeyWd $maxValWd]
    puts [format $fmt $dashes $dashes]
    dict for {key val} $dict {
      foreach val [splitDictVal $val] {
        puts [format $fmt $key $val]
        set key {}
      }
    }
    puts "${pfx}\}"
  }


  private proc splitDictVal { val } {
    set ret {}
    if { [string length $val] > 90 && ![catch {dict info $val}] } {
      dict for {key2 val2} $val {
        lappend ret "$key2 [list $val2]"
      }
    } else {
      set ret [list $val]
    }
    return $ret
  }
  namespace ensemble create
}

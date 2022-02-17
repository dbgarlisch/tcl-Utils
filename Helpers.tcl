if { [namespace exists ::Helpers] } return
source [file join [file dirname [info script]] ProcAccess.tcl]

#============================================================================
#============================================================================
#============================================================================

namespace eval ::Helpers {
  
  # foreachExcept varRef allList skipList body
  public proc foreachExcept {varRef allList skipList body } {
    upvar $varRef var
    set skipList [lsort $skipList]
    foreach var $allList {
      if { -1 == [lsearch -sorted $skipList $var] } {
        uplevel 1 $body
      }
    }
  }


  # foreachProcArg nameVar valVar ?skipList? body
  public proc foreachProcArg { nameVar valVar args } {
    switch -- [llength $args] {
    2 {lassign $args skip body}
    1 {lassign $args body skip}
    default {return -code error \
      {wrong # args: should be "foreachProcArg nameVar valVar ?skipList? body"}}
    }
    upvar $nameVar name
    upvar $valVar val
    set procName [dict get [info frame -1] proc]
    foreachExcept name [info args $procName] $skip {
      upvar $name namedVal
      set val $namedVal
      uplevel 1 $body
    }
  }


  public proc dumpProcs { {ns ""} {indent "  "} } {
    puts "${ns}::*"
    foreach proc [lsort -nocase [getProcs $ns maxLen]] {
      puts [format "${indent}%-*.*s \{ %s \}" \
        $maxLen $maxLen [namespace tail $proc] \
        [info args $proc]]
    }
  }


  public proc getProcs { ns {maxLenVar ""} } {
    if { 0 != [string length $maxLenVar] } {
      upvar $maxLenVar maxLen
    }
    set maxLen 0
    set ret [list]
    foreach proc [info procs ${ns}::*] {
      lappend ret $proc
      set tailProcLen [string length [namespace tail $proc]]
      if { $tailProcLen > $maxLen } {
        set maxLen $tailProcLen
      }
    }
    return $ret
  }


  private proc _UnitTest {} {
    proc foreachProcArgTest { firstVal strVal intVal realVal } {
      puts "\nTesting: foreachProcArg arg val body"
      foreachProcArg arg val {
        puts "> $arg=[list $val]"
      }
      set skip {firstVal intVal}
      puts "\nTesting: foreachProcArg arg val \{$skip\} body"
      foreachProcArg arg val $skip {
        puts "> $arg=[list $val]"
      }
    }
    foreachProcArgTest TEST "The Name" 33 1.5

    set all {I1 I2 I3 I4}
    set skip {I3 I2}
    puts "\nTesting: foreachExcept [list $all]"
    foreachExcept var $all {} {
      puts "> var='$var'"
    }
    puts "\nTesting: foreachExcept [list $all] [list $skip]"
    foreachExcept var $all $skip {
      puts "> var='$var'"
    }
    puts "\nTesting: foreachExcept [list $all] [list $all]"
    foreachExcept var $all $all {
      puts "> var='$var'"
    }
  }
}

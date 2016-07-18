if { [namespace exists ::UnitTester] } return

source [file join [file dirname [info script]] Debug.tcl]
source [file join [file dirname [info script]] ProcAccess.tcl]
#source [file join [file dirname [info script]] .. Param.tcl]


namespace eval ::UnitTester {
  variable group_ {test}
  variable groupCnt_ 0
  variable errorDb_ {}

  public proc H { group } {
    variable group_ $group
    variable groupCnt_ 0
  }


  public proc T { cmd expectedResult } {
    if { [catch {uplevel $cmd} result] } {
      # unexpected error thrown
      putsDetails T ERROR $result $expectedResult Error
    } elseif { ![compare $result $expectedResult] } {
      # cmd executed returning incorrect result
      putsDetails T FAIL $result $expectedResult
    } else {
      putsDetails T PASS $result $expectedResult
    }
  }


  public proc E { cmd expectedResult } {
    if { ![catch {uplevel $cmd} result] } {
      # expected error not thrown
      putsDetails E NOERROR $result $expectedResult
    } elseif { ![compare $result $expectedResult] } {
      # expected error was thrown with incorrect error message
      putsDetails E FAIL $result $expectedResult
    } else {
      putsDetails E PASS $result $expectedResult
    }
  }


  public proc Summary { } {
    variable errorDb_
    if { 0 == [dict size $errorDb_] } {
      puts "No Errors"
    } else {
      ::Debug::dumpDict "[namespace current]|Test Group|+Error Count" $errorDb_
    }
  }


  private proc compare { result expectedResult } {
    switch -- [parseExpectedResult $expectedResult range] {
    r {
      set ret [regexp "^$range\$" $result]
    }
    g {
      set ret [string match $range $result]
    }
    int -
    integer {
      set ret [compareNumeric $result $range integer 0]
    }
    real -
    float -
    double {
      set tol 1e-6
      set ret [compareNumeric $result $range double $tol]
    }
    string -
    text {
      set ret [string equal $result $range]
    }
    default {
      return -code error "Unknown comparison type in '$expectedResult'. Expecting \[compareType<SEP>\]range\[<SEP>\]"
    } }
    return $ret
  }


  private proc parseExpectedResult { expectedResult rangeVar } {
    # expectedResult -> [compareType<({/>]range[<)}/>]
    upvar $rangeVar range
    set re {^(r|g|int(?:eger)?|real|double|float|string|text)[({/](.+)[})/]$}
    set expectedResult [string trim $expectedResult]
    set compareType string
    set sep {?}
    set range {}
    if { ![regexp $re $expectedResult -> compareType range] } {
      # did not start with a compareType, use string compare
      set range $expectedResult
    }
    return $compareType
  }


  private proc compareNumeric { val1 val2 type tol } {
    return [expr {
      [string is $type -strict [set val1 [string trim $val1]]] &&
      [string is $type -strict [set val2 [string trim $val2]]] &&
      abs($val1 - $val2) <= $tol
    }]
  }


  private proc putsDetails { testType pass result expectedResult {lblResult {Result}} {lblExpected {Expected}} } {
    variable group_
    variable groupCnt_
    variable errorDb_
    if { "PASS" != $pass || [::Debug::isVerbose] } {
      set wd [::tcl::mathfunc::max [string length $lblResult] [string length $lblExpected]]
      set fmt [format "\n  | %%-%d.%ds \[%%s\]" $wd $wd]
      set details [format "$fmt$fmt" $lblResult $result $lblExpected $expectedResult]
      dict incr errorDb_ $group_
    } else {
      set details {}
    }
    puts [format {%1.1s.%4.4s: %s(%s)%s} $testType $pass $group_ [incr groupCnt_] $details]
  }
}

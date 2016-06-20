if { [namespace exists ::ProcAccess] } return
#puts "# [namespace current] / ProcAccess: [info script]"

# Implements public/private keywords for namespaces.
# If a namespaced proc is public, it is exported from the namespace.
# If a namespaced proc is private, it is not exported from the namespace.
# Ensembles will include all public procs as commands.
#
# for example:
#
#   namespace eval TEST {
#     public proc testPublic { a1 a2 a3 } {
#     }
#   
#     private proc testPrivate { b1 b2 b3 } {
#     }
#
#     namespace ensemble create
#   }
#
#   TEST testPublic 1 2 3  ;# okay
#   TEST testPrivate 4 5 6  ;# error
#
# Is the same as:
#
#   namespace eval TEST {
#     proc testPublic { a1 a2 a3 } {
#     }
#     namespace export testPublic
#   
#     proc testPrivate { b1 b2 b3 } {
#     }
#
#     namespace ensemble create
#   }
#
#   TEST testPublic 1 2 3  ;# okay
#   TEST testPrivate 4 5 6  ;# error

#============================================================================
#============================================================================
#============================================================================

namespace eval ::ProcAccess {
  proc access__ { access proc name args body } {
    if { [set ns [uplevel 1 {namespace current}]] == "::" } {
      set ns {}
    }
    uplevel 1 [list proc $name [list {*}$args] $body]
    if { "" != $ns && "public" == $access} {
      #puts ">> $access proc ${ns}::$name [list $args] {body}"
      #puts ">> namespace export $name"
      uplevel 1 [list namespace export $name]
    }
  }
}

# alias the public/private keywords to the appropriate namespaced proc
interp alias {} public  {} ::ProcAccess::access__ public
interp alias {} private {} ::ProcAccess::access__ private

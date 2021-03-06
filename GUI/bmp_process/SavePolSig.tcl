#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {

    # Provoke name search
    catch {package require bogus-package-name}
    set packageNames [package names]

    package require BWidget
    switch $tcl_platform(platform) {
	windows {
	}
	default {
	    option add *ScrolledWindow.size 14
	}
    }
    
    package require Tk
    switch $tcl_platform(platform) {
	windows {
            option add *Button.padY 0
	}
	default {
            option add *Scrollbar.width 10
            option add *Scrollbar.highlightThickness 0
            option add *Scrollbar.elementBorderWidth 2
            option add *Scrollbar.borderWidth 2
	}
    }
    
}

#############################################################################
# Visual Tcl v1.60 Project
#




#############################################################################
## vTcl Code to Load Stock Images


if {![info exist vTcl(sourcing)]} {
#############################################################################
## Procedure:  vTcl:rename

proc ::vTcl:rename {name} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    regsub -all "\\." $name "_" ret
    regsub -all "\\-" $ret "_" ret
    regsub -all " " $ret "_" ret
    regsub -all "/" $ret "__" ret
    regsub -all "::" $ret "__" ret

    return [string tolower $ret]
}

#############################################################################
## Procedure:  vTcl:image:create_new_image

proc ::vTcl:image:create_new_image {filename {description {no description}} {type {}} {data {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    # Does the image already exist?
    if {[info exists ::vTcl(images,files)]} {
        if {[lsearch -exact $::vTcl(images,files) $filename] > -1} { return }
    }

    if {![info exists ::vTcl(sourcing)] && [string length $data] > 0} {
        set object [image create  [vTcl:image:get_creation_type $filename]  -data $data]
    } else {
        # Wait a minute... Does the file actually exist?
        if {! [file exists $filename] } {
            # Try current directory
            set script [file dirname [info script]]
            set filename [file join $script [file tail $filename] ]
        }

        if {![file exists $filename]} {
            set description "file not found!"
            ## will add 'broken image' again when img is fixed, for now create empty
            set object [image create photo -width 1 -height 1]
        } else {
            set object [image create  [vTcl:image:get_creation_type $filename]  -file $filename]
        }
    }

    set reference [vTcl:rename $filename]
    set ::vTcl(images,$reference,image)       $object
    set ::vTcl(images,$reference,description) $description
    set ::vTcl(images,$reference,type)        $type
    set ::vTcl(images,filename,$object)       $filename

    lappend ::vTcl(images,files) $filename
    lappend ::vTcl(images,$type) $object

    # return image name in case caller might want it
    return $object
}

#############################################################################
## Procedure:  vTcl:image:get_image

proc ::vTcl:image:get_image {filename} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    set reference [vTcl:rename $filename]

    # Let's do some checking first
    if {![info exists ::vTcl(images,$reference,image)]} {
        # Well, the path may be wrong; in that case check
        # only the filename instead, without the path.

        set imageTail [file tail $filename]

        foreach oneFile $::vTcl(images,files) {
            if {[file tail $oneFile] == $imageTail} {
                set reference [vTcl:rename $oneFile]
                break
            }
        }
    }
    return $::vTcl(images,$reference,image)
}

#############################################################################
## Procedure:  vTcl:image:get_creation_type

proc ::vTcl:image:get_creation_type {filename} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    switch [string tolower [file extension $filename]] {
        .ppm -
        .jpg -
        .bmp -
        .gif    {return photo}
        .xbm    {return bitmap}
        default {return photo}
    }
}

foreach img {


            } {
    eval set _file [lindex $img 0]
    vTcl:image:create_new_image\
        $_file [lindex $img 1] [lindex $img 2] [lindex $img 3]
}

}
#############################################################################
## vTcl Code to Load User Images

catch {package require Img}

foreach img {

        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}

            } {
    eval set _file [lindex $img 0]
    vTcl:image:create_new_image\
        $_file [lindex $img 1] [lindex $img 2] [lindex $img 3]
}

#################################
# VTCL LIBRARY PROCEDURES
#

if {![info exists vTcl(sourcing)]} {
#############################################################################
## Library Procedure:  Window

proc ::Window {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global vTcl
    foreach {cmd name newname} [lrange $args 0 2] {}
    set rest    [lrange $args 3 end]
    if {$name == "" || $cmd == ""} { return }
    if {$newname == ""} { set newname $name }
    if {$name == "."} { wm withdraw $name; return }
    set exists [winfo exists $newname]
    switch $cmd {
        show {
            if {$exists} {
                wm deiconify $newname
            } elseif {[info procs vTclWindow$name] != ""} {
                eval "vTclWindow$name $newname $rest"
            }
            if {[winfo exists $newname] && [wm state $newname] == "normal"} {
                vTcl:FireEvent $newname <<Show>>
            }
        }
        hide    {
            if {$exists} {
                wm withdraw $newname
                vTcl:FireEvent $newname <<Hide>>
                return}
        }
        iconify { if $exists {wm iconify $newname; return} }
        destroy { if $exists {destroy $newname; return} }
    }
}
#############################################################################
## Library Procedure:  vTcl:DefineAlias

proc ::vTcl:DefineAlias {target alias widgetProc top_or_alias cmdalias} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global widget
    set widget($alias) $target
    set widget(rev,$target) $alias
    if {$cmdalias} {
        interp alias {} $alias {} $widgetProc $target
    }
    if {$top_or_alias != ""} {
        set widget($top_or_alias,$alias) $target
        if {$cmdalias} {
            interp alias {} $top_or_alias.$alias {} $widgetProc $target
        }
    }
}
#############################################################################
## Library Procedure:  vTcl:DoCmdOption

proc ::vTcl:DoCmdOption {target cmd} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## menus are considered toplevel windows
    set parent $target
    while {[winfo class $parent] == "Menu"} {
        set parent [winfo parent $parent]
    }

    regsub -all {\%widget} $cmd $target cmd
    regsub -all {\%top} $cmd [winfo toplevel $parent] cmd

    uplevel #0 [list eval $cmd]
}
#############################################################################
## Library Procedure:  vTcl:FireEvent

proc ::vTcl:FireEvent {target event {params {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## The window may have disappeared
    if {![winfo exists $target]} return
    ## Process each binding tag, looking for the event
    foreach bindtag [bindtags $target] {
        set tag_events [bind $bindtag]
        set stop_processing 0
        foreach tag_event $tag_events {
            if {$tag_event == $event} {
                set bind_code [bind $bindtag $tag_event]
                foreach rep "\{%W $target\} $params" {
                    regsub -all [lindex $rep 0] $bind_code [lindex $rep 1] bind_code
                }
                set result [catch {uplevel #0 $bind_code} errortext]
                if {$result == 3} {
                    ## break exception, stop processing
                    set stop_processing 1
                } elseif {$result != 0} {
                    bgerror $errortext
                }
                break
            }
        }
        if {$stop_processing} {break}
    }
}
#############################################################################
## Library Procedure:  vTcl:Toplevel:WidgetProc

proc ::vTcl:Toplevel:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
        ## If no arguments, returns the path the alias points to
        return $w
    }
    set command [lindex $args 0]
    set args [lrange $args 1 end]
    switch -- [string tolower $command] {
        "setvar" {
            foreach {varname value} $args {}
            if {$value == ""} {
                return [set ::${w}::${varname}]
            } else {
                return [set ::${w}::${varname} $value]
            }
        }
        "hide" - "show" {
            Window [string tolower $command] $w
        }
        "showmodal" {
            ## modal dialog ends when window is destroyed
            Window show $w; raise $w
            grab $w; tkwait window $w; grab release $w
        }
        "startmodal" {
            ## ends when endmodal called
            Window show $w; raise $w
            set ::${w}::_modal 1
            grab $w; tkwait variable ::${w}::_modal; grab release $w
        }
        "endmodal" {
            ## ends modal dialog started with startmodal, argument is var name
            set ::${w}::_modal 0
            Window hide $w
        }
        default {
            uplevel $w $command $args
        }
    }
}
#############################################################################
## Library Procedure:  vTcl:WidgetProc

proc ::vTcl:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
        ## If no arguments, returns the path the alias points to
        return $w
    }

    set command [lindex $args 0]
    set args [lrange $args 1 end]
    uplevel $w $command $args
}
#############################################################################
## Library Procedure:  vTcl:toplevel

proc ::vTcl:toplevel {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    uplevel #0 eval toplevel $args
    set target [lindex $args 0]
    namespace eval ::$target {set _modal 0}
}
}


if {[info exists vTcl(sourcing)]} {

proc vTcl:project:info {} {
    set base .top241
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd72
    namespace eval ::widgets::$site_3_0.cpd98 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd73
    namespace eval ::widgets::$site_6_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd76 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd87 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd91 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd91
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd92 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd73
    namespace eval ::widgets::$site_7_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd93 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd93 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd73
    namespace eval ::widgets::$site_7_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd95 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd95
    namespace eval ::widgets::$site_4_0.rad96 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd97 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd98 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd99 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd100 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.but101 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd102 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.m71 {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top241
        }
        set compounds {
        }
        set projectType single
    }
}
}

#################################
# USER DEFINED PROCEDURES
#
#############################################################################
## Procedure:  main

proc ::main {argc argv} {
## This will clean up and call exit properly on Windows.
#vTcl:WindowsCleanup
}

#############################################################################
## Initialization Procedure:  init

proc ::init {argc argv} {

}

init $argc $argv

#################################
# VTCL GENERATED GUI PROCEDURES
#

proc vTclWindow. {base} {
    if {$base == ""} {
        set base .
    }
    ###################
    # CREATING WIDGETS
    ###################
    wm focusmodel $top passive
    wm geometry $top 200x200+154+154; update
    wm maxsize $top 1684 1035
    wm minsize $top 104 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm withdraw $top
    wm title $top "vtcl"
    bindtags $top "$top Vtcl all"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    ###################
    # SETTING GEOMETRY
    ###################

    vTcl:FireEvent $base <<Ready>>
}

proc vTclWindow.top241 {base} {
    if {$base == ""} {
        set base .top241
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -menu "$top.m71" 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x140+520+100; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Save Polarimetric Signatures"
    vTcl:DefineAlias "$top" "Toplevel241" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame1" vTcl:WidgetProc "Toplevel241" 1
    set site_3_0 $top.cpd72
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame5" vTcl:WidgetProc "Toplevel241" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -state normal \
        -textvariable PolSigOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh6" vTcl:WidgetProc "Toplevel241" 1
    frame $site_5_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd73" "Frame2" vTcl:WidgetProc "Toplevel241" 1
    set site_6_0 $site_5_0.cpd73
    label $site_6_0.lab74 \
        -text {/ } 
    vTcl:DefineAlias "$site_6_0.lab74" "Label1" vTcl:WidgetProc "Toplevel241" 1
    entry $site_6_0.cpd76 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PolSigOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd76" "Entry1" vTcl:WidgetProc "Toplevel241" 1
    pack $site_6_0.lab74 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame12" vTcl:WidgetProc "Toplevel241" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd87 \
        \
        -command {global DirName DataDir PolSigOutputDir
global VarWarning WarningMessage WarningMessage2

set PolSigDirOutputTmp $PolSigOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set PolSigOutputDir $DirName
        } else {
        set PolSigOutputDir $PolSigDirOutputTmp
        }
    } else {
    set PolSigOutputDir $PolSigDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd87 "$site_6_0.cpd87 Button $top all _vTclBalloon"
    bind $site_6_0.cpd87 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd87 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd91" "Frame6" vTcl:WidgetProc "Toplevel241" 1
    set site_4_0 $site_3_0.cpd91
    TitleFrame $site_4_0.cpd92 \
        -ipad 0 -text {Copol Signature Output File} 
    vTcl:DefineAlias "$site_4_0.cpd92" "TitleFrame9" vTcl:WidgetProc "Toplevel241" 1
    bind $site_4_0.cpd92 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd92 getframe]
    entry $site_6_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -state normal \
        -textvariable CopolSigOutputFile 
    vTcl:DefineAlias "$site_6_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel241" 1
    frame $site_6_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd73" "Frame9" vTcl:WidgetProc "Toplevel241" 1
    set site_7_0 $site_6_0.cpd73
    label $site_7_0.lab74 \
        -text . 
    vTcl:DefineAlias "$site_7_0.lab74" "Label2" vTcl:WidgetProc "Toplevel241" 1
    entry $site_7_0.cpd76 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable GnuOutputFormat -width 3 
    vTcl:DefineAlias "$site_7_0.cpd76" "Entry2" vTcl:WidgetProc "Toplevel241" 1
    pack $site_7_0.lab74 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $site_4_0.cpd93 \
        -ipad 0 -text {Xpol Signature Output File} 
    vTcl:DefineAlias "$site_4_0.cpd93" "TitleFrame10" vTcl:WidgetProc "Toplevel241" 1
    bind $site_4_0.cpd93 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd93 getframe]
    entry $site_6_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -state normal \
        -textvariable XpolSigOutputFile 
    vTcl:DefineAlias "$site_6_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel241" 1
    frame $site_6_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd73" "Frame10" vTcl:WidgetProc "Toplevel241" 1
    set site_7_0 $site_6_0.cpd73
    label $site_7_0.lab74 \
        -text . 
    vTcl:DefineAlias "$site_7_0.lab74" "Label3" vTcl:WidgetProc "Toplevel241" 1
    entry $site_7_0.cpd76 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable GnuOutputFormat -width 3 
    vTcl:DefineAlias "$site_7_0.cpd76" "Entry3" vTcl:WidgetProc "Toplevel241" 1
    pack $site_7_0.lab74 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd93 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    frame $site_3_0.cpd95 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd95" "Frame11" vTcl:WidgetProc "Toplevel241" 1
    set site_4_0 $site_3_0.cpd95
    radiobutton $site_4_0.rad96 \
        -text cgm -value cgm -variable GnuOutputFormat 
    vTcl:DefineAlias "$site_4_0.rad96" "Radiobutton1" vTcl:WidgetProc "Toplevel241" 1
    radiobutton $site_4_0.cpd97 \
        -text corel -value cdw -variable GnuOutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd97" "Radiobutton2" vTcl:WidgetProc "Toplevel241" 1
    radiobutton $site_4_0.cpd98 \
        -text emf -value emf -variable GnuOutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd98" "Radiobutton3" vTcl:WidgetProc "Toplevel241" 1
    radiobutton $site_4_0.cpd99 \
        -text png -value png -variable GnuOutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd99" "Radiobutton4" vTcl:WidgetProc "Toplevel241" 1
    radiobutton $site_4_0.cpd100 \
        -text {postscript (eps)} -value eps -variable GnuOutputFormat 
    vTcl:DefineAlias "$site_4_0.cpd100" "Radiobutton7" vTcl:WidgetProc "Toplevel241" 1
    button $site_4_0.but101 \
        -background #ffff00 \
        -command {global VarSaveGnuPlotFile

set VarSaveGnuPlotFile "ok"
Window hide $widget(Toplevel241); TextEditorRunTrace "Close Window Save Polarimetric Signatures" "b"} \
        -padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_4_0.but101" "Button6" vTcl:WidgetProc "Toplevel241" 1
    button $site_4_0.cpd102 \
        -background #ffff00 \
        -command {global PolSigDirOutput PolSigOutputDir PolSigOutputSubDir
global GnuOutputFile CopolSigOutputFile XpolSigOutputFile
global BMPPolSigX BMPPolSigY GnuOutputFormat PolSigOutputUnit
global GnuplotPipeFid GnuplotPipeSave
global TMPCopolSigTxt TMPCopolSigBin TMPXpolSigTxt TMPXpolSigBin  
global GnuXview GnuZview VarSaveGnuPlotFile

set Rb240_1 .top240.fra71.fra72.cpd77.f.cpd75.fra84.rad78
set Rb240_2 .top240.fra71.fra72.cpd77.f.cpd75.cpd71.rad78
set Rb240_3 .top240.fra71.fra72.cpd77.f.cpd75.cpd72.rad78
set Rb240_4 .top240.fra71.fra72.cpd77.f.cpd72.fra84.rad78
set Rb240_5 .top240.fra71.fra72.cpd77.f.cpd72.cpd71.rad78
set Rb240_6 .top240.fra71.fra72.cpd77.f.cpd72.cpd73.rad78
set B240_1 .top240.fra71.fra72.fra79.but81
set B240_2 .top240.fra92.but24
set B240_4 .top240.fra71.fra72.fra79.but83
set B240_5 .top240.fra71.fra72.fra79.but71

set config "true"
if {$BMPPolSigX == ""} {set config "false"}
if {$BMPPolSigY == ""} {set config "false"}
if {$config == "true"} {
$Rb240_1 configure -state disable
$Rb240_2 configure -state disable
$Rb240_3 configure -state disable
$Rb240_4 configure -state disable
$Rb240_5 configure -state disable
$Rb240_6 configure -state disable
$B240_1 configure -state disable
$B240_2 configure -state disable
$B240_4 configure -state disable
$B240_5 configure -state disable

set PolSigDirOutput $PolSigOutputDir
if {$PolSigOutputSubDir != ""} {append PolSigDirOutput "/$PolSigOutputSubDir"}
set GnuOutputFile "$PolSigDirOutput/$XpolSigOutputFile"
append GnuOutputFile ".$GnuOutputFormat"
if [file exists $TMPXpolSigTxt] {
    if {$GnuplotPipeSave == ""} {
	GnuPlotInit  0 0 1 1
    	set GnuplotPipeSave $GnuplotPipeFid
	}
    GnuPlotTerm $GnuplotPipeSave $GnuOutputFormat
    set Unit ""; if {$PolSigOutputUnit == "dB"} {set Unit "dB"}
    GnuPlot3D $GnuplotPipeSave $TMPXpolSigTxt $TMPXpolSigBin "Tau (�)" "Phi (�)" $Unit $GnuXview $GnuZview "Normalized Polarimetric Signature : Cross-polarisation channel" 1 $PolSigOutputFormat 3
    catch "close $GnuplotPipeSave"
    }
set GnuplotPipeSave ""

set PolSigDirOutput $PolSigOutputDir
if {$PolSigOutputSubDir != ""} {append PolSigDirOutput "/$PolSigOutputSubDir"}
set GnuOutputFile "$PolSigDirOutput/$CopolSigOutputFile"
append GnuOutputFile ".$GnuOutputFormat"
if [file exists $TMPCopolSigTxt] {
    if {$GnuplotPipeSave == ""} {
	GnuPlotInit  0 0 1 1
    	set GnuplotPipeSave $GnuplotPipeFid
	}
    GnuPlotTerm $GnuplotPipeSave $GnuOutputFormat
    set Unit ""; if {$PolSigOutputUnit == "dB"} {set Unit "dB"}
    GnuPlot3D $GnuplotPipeSave $TMPCopolSigTxt $TMPCopolSigBin "Tau (�)" "Phi (�)" $Unit $GnuXview $GnuZview "Normalized Polarimetric Signature : Co-polarisation channel" 1 $PolSigOutputFormat 3
    catch "close $GnuplotPipeSave"
    }
set GnuplotPipeSave ""
        
$Rb240_1 configure -state normal
$Rb240_2 configure -state normal
$Rb240_3 configure -state normal
$Rb240_4 configure -state normal
$Rb240_5 configure -state normal
$Rb240_6 configure -state normal
$B240_1 configure -state normal
$B240_2 configure -state normal
$B240_4 configure -state normal
$B240_5 configure -state normal

set VarSaveGnuPlotFile "ok"
}
Window hide $widget(Toplevel241); TextEditorRunTrace "Close Window Save Polarimetric Signatures" "b"} \
        -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_4_0.cpd102" "Button7" vTcl:WidgetProc "Toplevel241" 1
    pack $site_4_0.rad96 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd97 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd98 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd99 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd100 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.but101 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd102 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd91 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side top 
    pack $site_3_0.cpd95 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side top 
    menu $top.m71 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd72 \
        -in $top -anchor center -expand 1 -fill both -side top 

    vTcl:FireEvent $base <<Ready>>
}

#############################################################################
## Binding tag:  _TopLevel

bind "_TopLevel" <<Create>> {
    if {![info exists _topcount]} {set _topcount 0}; incr _topcount
}
bind "_TopLevel" <<DeleteWindow>> {
    if {[set ::%W::_modal]} {
                vTcl:Toplevel:WidgetProc %W endmodal
            } else {
                destroy %W; if {$_topcount == 0} {exit}
            }
}
bind "_TopLevel" <Destroy> {
    if {[winfo toplevel %W] == "%W"} {incr _topcount -1}
}
#############################################################################
## Binding tag:  _vTclBalloon


if {![info exists vTcl(sourcing)]} {
}

Window show .
Window show .top241

main $argc $argv

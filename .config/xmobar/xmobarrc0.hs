Config { 

   -- appearance
     font =         "xft:Liberation Mono:size=12:bold:antialias=true"
   , bgColor =      "black"
   , fgColor =      "#646464"
   , position =     Top
   , border =       NoBorder
   , borderColor =  "#646464"
   , iconRoot = "/home/alex/.config/xmobar/icons"

   -- layout
   , sepChar =  "%"   -- delineator between plugin names and straight text
   , alignSep = "}{"  -- separator between left-right alignment
   , template = "%UnsafeStdinReader% }{ %kbd% "

   -- general behavior
   , lowerOnStart =     True    -- send to bottom of window stack on start
   , hideOnStart =      False   -- start with window unmapped (hidden)
   , allDesktops =      True    -- show on all desktops
   , overrideRedirect = False   -- set the Override Redirect flag (Xlib)
   , pickBroadest =     False   -- choose widest display (multi-monitor)
   , persistent =       False   -- enable/disable hiding (True = disabled)

   -- plugins
   --   Numbers can be automatically colored according to their value. xmobar
   --   decides color based on a three-tier/two-cutoff system, controlled by
   --   command options:
   --     --Low sets the low cutoff
   --     --High sets the high cutoff
   --
   --     --low sets the color below --Low cutoff
   --     --normal sets the color between --Low and --High cutoffs
   --     --High sets the color above --High cutoff
   --
   --   The --template option controls how the plugin is displayed. Text
   --   color can be set by enclosing in <fc></fc> tags. For more details
   --   see http://projects.haskell.org/xmobar/#system-monitor-plugins.
   , commands = 
        -- network activity monitor (dynamic interface resolution)
        [Run UnsafeStdinReader
        ,Run Kbd            [ ("ru" , "<fc=#00008B>RU</fc>")
                             , ("us"         , "<fc=#8B0000>US</fc>")
                             , ("ge"         , "<fc=#00ff00>GE</fc>")
                             ]
        ]
   }

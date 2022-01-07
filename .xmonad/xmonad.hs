-- Imports --

import XMonad
import XMonad.Hooks.ManageDocks     (avoidStruts, docks, ToggleStruts(ToggleStruts))
import XMonad.Hooks.DynamicLog      (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Util.SpawnOnce        (spawnOnce)
import XMonad.Util.Run              (spawnPipe, hPutStrLn)
import XMonad.Util.NamedScratchpad  (namedScratchpadFilterOutWorkspacePP)
import XMonad.Layout.Spacing        (spacingRaw, incWindowSpacing, Border(..))
import XMonad.Layout.NoBorders      (smartBorders)
import XMonad.Layout.Maximize       (maximizeWithPadding, maximizeRestore)
import XMonad.Hooks.EwmhDesktops    (ewmh, fullscreenEventHook, ewmhDesktopsEventHook)
--import XMonad.Layout.Grid           (Grid(Grid))

import System.Exit (exitWith, ExitCode(ExitSuccess))

import qualified XMonad.StackSet as W ( focusUp
                                      , focusDown
                                      , swapUp
                                      , swapDown
                                      , swapMaster
                                      , sink
                                      , greedyView
                                      , shift
                                      , shiftMaster
                                      , integrate'
                                      , stack
                                      , workspace
                                      , current
                                      )
import qualified Data.Map        as M (fromList, lookup)
import Data.Maybe                     (fromJust)
import Data.Monoid                    (mappend)

-- Default terminal emulator
myTerminal = "alacritty"

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

-- Whether focus follows the mouse pointer
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
myBorderWidth = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
myWorkspaces    = ["Terminal", "Web", "Graphics", "Games", "Other"]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..]

clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
  where i = fromJust $ M.lookup ws myWorkspaceIndices

-- Windows border colors
myNormalBorderColor  = "#666666"
myFocusedBorderColor = "#ff2f2f"

------------------------------------------------------------------------
    -- Key bindings. Add, modify or remove key bindings here.
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- Keybinds
    [
    -- Maximize current window
      ((modm, xK_backslash), withFocused (sendMessage . maximizeRestore))

    -- Toggle keyboard layout
      , ((modm,               xK_Tab   ), spawn "~/.local/bin/layout_switch")

    -- Toggle struts
      , ((modm,               xK_b     ), sendMessage $ ToggleStruts)

    -- Close focused window
      , ((modm,               xK_c     ), kill)

     -- Rotate through the available layout algorithms
       , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
      , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Move focus to the next window
      , ((modm,               xK_n     ), windows W.focusDown)
      , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
      , ((modm,               xK_p     ), windows W.focusUp  )
      , ((modm,               xK_k     ), windows W.focusUp  )

    -- Swap the focused window and the master window
      , ((modm,               xK_m), windows W.swapMaster)

    -- Swap the focused window with the next window
      , ((modm .|. shiftMask, xK_n     ), windows W.swapDown  )
      , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
      , ((modm .|. shiftMask, xK_p     ), windows W.swapUp    )
      , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Change master area size
      , ((modm,               xK_h     ), sendMessage Shrink)
      , ((modm,               xK_l     ), sendMessage Expand)

    -- Change padding space
      , ((modm,               xK_equal  ), incWindowSpacing 4)
      , ((modm,               xK_minus  ), incWindowSpacing (-4))

    -- Push window back into tiling
      , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
      , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
      , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Quit xmonad
      , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
      , ((modm .|. shiftMask, xK_r     ), spawn "pkill xmobar; xmonad --recompile; xmonad --restart")
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]


    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
--    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
--        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
--        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
    -- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
      , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
      , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
    -- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = avoidStruts
         $ maximizeWithPadding 0
         $ smartBorders
         $ spacingRaw False (Border 0 0 0 0) False (Border 0 0 0 0) True
         $ tiled ||| (Mirror tiled) ||| Full
             where
                 -- Default tiling algorithm partitions the screen into two panes
                 tiled   = Tall 1 (3/100) (1/2)

------------------------------------------------------------------------
    -- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
tlauncherClassName :: String
tlauncherClassName = "org-tlauncher-tlauncher-rmo-TLauncher" -- The name was just too long :(

myManageHook = composeAll [ className =? "MPlayer"              --> doFloat

                          -- Terminal
                          , className =? "Alacritty"            --> doShift (myWorkspaces !! 0)
                          , title     =? "Консоль разработчика" <&&> className =? tlauncherClassName
                                                                --> doShift (myWorkspaces !! 0)

                          -- Web
                          , className =? "firefox"              --> doShift (myWorkspaces !! 1)
                          , className =? "Chromium"             --> doShift (myWorkspaces !! 1)

                          -- Graphics
                          , className =? "Blender"              --> doShift (myWorkspaces !! 2)
                          , className =? "Gimp"                 --> doShift (myWorkspaces !! 2)

                          -- Games
                          , className =? tlauncherClassName     --> doShift (myWorkspaces !! 3)
                          , className =? "Minecraft* 1.17.1"    --> doShift (myWorkspaces !! 3)
                          , title     =? "ULTRAKILL"            --> doShift (myWorkspaces !! 3)

                          -- Other
                          , resource  =? "desktop_window"       --> doIgnore
                          , resource  =? "kdesktop"             --> doIgnore]

------------------------------------------------------------------------
    -- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = ewmhDesktopsEventHook `mappend` fullscreenEventHook

------------------------------------------------------------------------
    -- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--


------------------------------------------------------------------------
    -- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
  spawnOnce "sxhkd &"
  spawnOnce "feh --bg-scale /home/alex/Pictures/\"Harry Potter epic background.jpg\" &"
  spawnOnce "xsetroot -cursor_name left_ptr &"
  spawnOnce "picom &"
  spawnOnce "lxqt-notificationd &"

------------------------------------------------------------------------
    -- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify

main = do
  xmproc0 <- spawnPipe "xmobar ~/.config/xmobar/xmobarrc0.hs"
  xmproc1 <- spawnPipe "xmobar ~/.config/xmobar/xmobarrc1.hs"
  xmonad $ ewmh $ docks $ def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = dynamicLogWithPP $ namedScratchpadFilterOutWorkspacePP $ xmobarPP
              -- the following variables beginning with 'pp' are settings for xmobar.
                { ppOutput = \x -> hPutStrLn xmproc0 x
                , ppCurrent = xmobarColor "#c792ea" "" . wrap "<box type=Bottom width=2 mb=2 color=#c792ea>" "</box>"         -- Current workspace
                , ppVisible = xmobarColor "#c792ea" "" . clickable              -- Visible but not current workspace
                , ppHidden = xmobarColor "#82AAFF" "" . wrap "<box type=Bottom width=1 mb=2 color=#82AAFF>" "</box>" . clickable -- Hidden workspaces
                , ppHiddenNoWindows = xmobarColor "#82AAFF" ""  . clickable     -- Hidden workspaces (no windows)
                , ppTitle = xmobarColor "#b3afc2" "" . shorten 60               -- Title of active window
                , ppSep =  "<fc=#666666> <fn=1>|</fn> </fc>"                    -- Separator character
                , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"            -- Urgent workspace
                , ppExtras  = [windowCount]                                     -- # of windows current workspace
                , ppOrder  = \(ws:l:t:ex) -> [ws, (unwords $ drop 2 $ words l)]++ex++[t] -- order of things in xmobar
                },
        startupHook        = myStartupHook
  }

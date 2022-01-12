    -- Base
import XMonad
import System.Directory
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

    -- Actions
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S

    -- Data
import Data.Char (isSpace, toUpper)
import Data.Maybe (fromJust)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M

    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks (docks, avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, doCenterFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory

    -- Layouts
import XMonad.Layout.Accordion
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

    -- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

   -- Utilities
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce


myTerminal = "kitty"
myModMask = mod4Mask

myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#7d14d9"
myBorderWidth = 2

myStartupHook = do
    spawnOnce "nitrogen --restore &"
    spawnOnce "picom &"

myLayout = avoidStruts (tiled ||| Mirror tiled ||| Full)
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

myKeys :: [(String, X ())]
myKeys = 
    [ (("M-p"), spawn "dmenu_run") 
    , (("M-c"), spawn "google-chrome-stable")
    , (("M-g"), spawn "google-chrome-stable https://mail.google.com")
    , (("<Print>"), spawn "flameshot gui")
    , (("M-<Print>"), spawn "flameshot full --clipboard")
    , (("M-S-<Print>"), spawn "flameshot full -p $HOME/screenshots/")
    -- Pomobar
    , (("M-C-s"), spawn "dbus-send --print-reply --dest=org.pomobar /org/pomobar org.Pomobar.startTimerSwitch array:int16:25,10,5")
    , (("M-C-p"), spawn "dbus-send --print-reply --dest=org.pomobar /org/pomobar org.Pomobar.pauseResumeTimer")
    , (("M-C-k"), spawn "dbus-send --print-reply --dest=org.pomobar /org/pomobar org.Pomobar.timerAddMin int16:1")
    , (("M-C-j"), spawn "dbus-send --print-reply --dest=org.pomobar /org/pomobar org.Pomobar.timerAddMin int16:-1")
      ]

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     -- 'doFloat' forces a window to float.  Useful for dialog boxes and such.
     -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
     -- I'm doing it this way because otherwise I would have to write out the full
     -- name of my workspaces and the names would be very long if using clickable workspaces.
     [ className =? "confirm"         --> doFloat
     , className =? "file_progress"   --> doFloat
     , className =? "dialog"          --> doFloat
     , className =? "download"        --> doFloat
     , className =? "error"           --> doFloat
     , className =? "notification"    --> doFloat
     , className =? "splash"          --> doFloat
     , className =? "toolbar"         --> doFloat
     , className =? "Gimp"            --> doFloat
     , title     =? "Emulator"        --> doFloat
     , className =? "google-chrome"   --> doFloat
     ]

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

main :: IO ()
main = do
    xmproc0 <- spawnPipe ("xmobar -x 0 $HOME/.xmobarrc")
    xmproc1 <- spawnPipe ("xmobar -x 1 $HOME/.xmobarrc2")
    xmonad $ docks def {
      terminal = myTerminal
    , modMask = myModMask
    , normalBorderColor = myNormalBorderColor
    , focusedBorderColor = myFocusedBorderColor
    , borderWidth = myBorderWidth
    -- hooks
    , startupHook = myStartupHook
    , layoutHook = myLayout
    , manageHook = myManageHook
    , logHook = dynamicLogWithPP $ xmobarPP
          -- XMOBAR SETTINGS
          { ppOutput = \x -> hPutStrLn xmproc0 x    -- xmobar on monitor 1
                          >> hPutStrLn xmproc1 x
            -- Current workspace
          , ppCurrent = xmobarColor "#7C3D8F" "" . wrap
                        ("<box type=Bottom width=2 mb=2 color=" ++ "#A088BF" ++ ">") "</box>"
            -- Visible but not current workspace
          , ppVisible = xmobarColor "#7C3D8F" ""
            -- Hidden workspace
          , ppHidden = xmobarColor "#86A59C" "" . wrap
                       ("<box type=Top width=2 mt=2 color=" ++ "#86A59C" ++ ">") "</box>"
            -- Hidden workspaces (no windows)
          , ppHiddenNoWindows = xmobarColor "#86A59C" ""
            -- Title of active window
          , ppTitle = xmobarColor "#89CE94" "" . shorten 60
            -- Separator character
          , ppSep =  "<fc=" ++ "#86A59C" ++ "> | </fc>"
            -- Urgent workspace
          , ppUrgent = xmobarColor "#7C3D8F" "" . wrap "!" "!"
            -- Adding # of windows on current workspace to the bar
          , ppExtras  = [windowCount]
            -- order of things in xmobar
          , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
          }
    } `additionalKeysP` myKeys

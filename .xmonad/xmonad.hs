
{-# OPTIONS_GHC -fglasgow-exts #-} -- required for XMonad.Layout.MultiToggle

import XMonad
import XMonad.Config.Gnome
import XMonad.Actions.CycleWS
import XMonad.Actions.DwmPromote
import XMonad.Actions.FindEmptyWorkspace
import qualified XMonad.Actions.FlexibleResize as Flex
import XMonad.Actions.RotSlaves
import XMonad.Actions.Search
import XMonad.Actions.WindowGo
import XMonad.Hooks.DynamicLog as Log
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.EZConfig
import XMonad.Prompt
import XMonad.Prompt.RunOrRaise
import XMonad.Prompt.Shell
import XMonad.Prompt.Ssh
import XMonad.Prompt.Workspace
import XMonad.Util.Dzen as Dzen
import XMonad.Util.Run
import XMonad.Util.Loggers
import XMonad.Util.WindowProperties
import XMonad.Layout.Accordion
import XMonad.Layout.Combo
import XMonad.Layout.DwmStyle
import XMonad.Layout.IM
import XMonad.Layout.Maximize
import XMonad.Layout.MultiToggle
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Layout.ResizableTile
import XMonad.Layout.TwoPane
import XMonad.Layout.WindowNavigation

import Codec.Binary.UTF8.String
import Control.Monad
import Data.Ratio ((%))
import System.Exit
import System.IO (hPutStrLn)

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import qualified Data.List       as L

data ACCORDION = ACCORDION deriving (Read, Show, Eq, Typeable)
instance Transformer ACCORDION Window where
      transform _ x k = k Accordion

data FULL = FULL deriving (Read, Show, Eq, Typeable)
instance Transformer FULL Window where
      transform _ x k = k (noBorders Full)

data NOBORDERS = NOBORDERS deriving (Read, Show, Eq, Typeable)
instance Transformer NOBORDERS Window where
      transform _ x k = k (noBorders x)

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myTerminal = "urxvtcd &"

bugzilla = searchEngine "bugzilla" "https://bugzilla.altlinux.org/show_bug.cgi?id="
wikipediarus = searchEngine "wikipedia" "http://ru.wikipedia.org/wiki/"
wikipediaeng = searchEngine "wikipedia" "http://en.wikipedia.org/wiki/"

myLayout = dwmStyle shrinkText myTheme . windowNavigation . avoidStruts . maximize . mkToggle (single ACCORDION) . mkToggle (single FULL) $ onWorkspace "IM" tiledIM (Mirror tiled) ||| onWorkspace "IM" (Mirror tiled) tiledIM
  where
     tiled   = ResizableTall 1 0.03 0.6180 []
     tiledIM   = ResizableTall 1 0.03 0.85 []
     myTheme = defaultTheme

myLogHook :: X ()
myLogHook = ewmhDesktopsLogHook

myHandleEventHook = ewmhDesktopsEventHook

myManageHook = (composeAll . concat $
  [ [resource  =? r                 --> doIgnore         |  r    <- myIgnores] -- ignore desktop
  , [className =? c                 --> doCenterFloat    |  c    <- myFloats ] -- float my floats
  , [name      =? n                 --> doCenterFloat    |  n    <- myNames  ] -- float my names
  , [isFullscreen                   --> doFullFloat                          ]
  ]) <+> manageTypes <+> manageDocks
  where
    name      = stringProperty "WM_NAME"
    -- classnames
    myFloats  = ["MPlayer", "Vlc", "Zenity", "VirtualBox", "Xmessage", "Save As...", "container"]
    -- resources
    myIgnores = ["desktop", "desktop_window"]
    -- names
    myNames   = []
    -- modified version of manageDocks
    manageTypes :: ManageHook
    manageTypes = checkType --> doCenterFloat
    ---
    checkType :: Query Bool
    checkType = ask >>= \w -> liftX $ do
      m   <- getAtom    "_NET_WM_WINDOW_TYPE_MENU"
      d   <- getAtom    "_NET_WM_WINDOW_TYPE_DIALOG"
      u   <- getAtom    "_NET_WM_WINDOW_TYPE_UTILITY"
      mbr <- getProp32s "_NET_WM_WINDOW_TYPE" w
      case mbr of
	Just [r] -> return $ elem (fromIntegral r) [m,d,u]
	_        -> return False

-- Mutimedia keys bindings
multKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $ [
      ((0, 0x1008ff14), spawn "mpc --no-status toggle")
    , ((0, 0x1008ff15), spawn "mpc --no-status stop")
    , ((0, 0x1008ff16), spawn "mpc --no-status prev")
    , ((0, 0x1008ff17), spawn "mpc --no-status next")
    , ((0, 0x1008ff11), spawn "mpcvolume -")
    , ((0, 0x1008ff13), spawn "mpcvolume +")

    , ((0, 0x1008ff18), runOrRaise "firefox" (className =? "Firefox-bin"))
    , ((0, 0x1008ff19), runOrRaise "claws-mail" (className =? "Claws-mail"))
    , ((0, 0x1008ff30), runOrRaise "kvirc" (className =? "Kvirc"))

    , ((0, 0x1008ff10), spawn "/usr/bin/xscreensaver-command -lock")
    , ((0, xK_Print), unsafeSpawn "import -w root png:$HOME/screenshot--`date +%F--%T`.png")
    ]

myKeys = \conf -> mkKeymap conf $ [
    ("M-<Return>", spawn $ XMonad.terminal conf),

    ("M-S-c", kill),
    ("M-r", refresh),
    ("M-b", sendMessage ToggleStruts),
    ("M-S-C-<Pause>", io (exitWith ExitSuccess)),
    ("M-q", restart "xmonad" True),

    -- Propmpts here
    ("M-S-b", selectSearch bugzilla),
    ("M-w", selectSearch wikipediarus),
    ("M-S-w", selectSearch wikipediaeng),

    -- Workspaces
    ("M-`", viewEmptyWorkspace) ,
    ("M-<L>", prevWS),
    ("M-C-h", prevWS),
    ("M-<R>", nextWS),
    ("M-C-l", nextWS),
    ("M-S-<L>", shiftToPrev),
    ("M-S-<R>", shiftToNext),

    ("M-<Tab>", sendMessage NextLayout),
    ("M-S-<Tab>", setLayout $ XMonad.layoutHook conf),

    --- Window management
    ("M-h", sendMessage $ Go L),
    ("M-S-h", sendMessage $ Swap L),
    ("M-j", sendMessage $ Go D),
    ("M-S-j", sendMessage $ Swap D),
    ("M-k", sendMessage $ Go U),
    ("M-S-k", sendMessage $ Swap U),
    ("M-l", sendMessage $ Go R),
    ("M-S-l", sendMessage $ Swap R),

--      ("M-<Tab>", windows W.focusDown),
--      ("M-S-<Tab>", windows W.focusUp),

--      , ("M-j", windows W.focusDown)
--      , ("M-S-j", windows W.swapDown)

--      , ("M-k", windows W.focusUp)
--      , ("M-S-k", windows W.swapUp)

--      , ("M-<Return>", windows W.focusMaster)
    ("M-m", dwmpromote) ,
    ("M-y", rotSlavesDown),
    ("M-S-y", rotAllDown),
    ("M-o", rotSlavesUp),
    ("M-S-o", rotAllUp),

    ("M-S-u", sendMessage Shrink),
    ("M-S-i", sendMessage Expand),
    ("M-u", sendMessage MirrorExpand),
    ("M-i", sendMessage MirrorShrink),

    ("M-<Space>", withFocused $ sendMessage . maximizeRestore ),
    ("M-s", sendMessage $ Toggle ACCORDION),
    ("M-f", sendMessage $ Toggle FULL),
    ("M-S-<Space>", withFocused $ windows . W.sink),	-- unfloat

    -- Increment the number of windows in the master area
    ("M-,", sendMessage (IncMasterN 1)),
    ("M-.", sendMessage (IncMasterN (-1))),

    ("M-x", focusUrgent)

    ]
    ++
    [ (m ++ i, windows $ f j)
                    | (i, j) <- zip (map show [1..9] ++ ["0","C-r"]) (XMonad.workspaces conf)
                    , (m, f) <- [("M-", W.view), ("M-S-", W.shift)]
    ]

-- Use the gnomeConfig, but change a couple things
customGnomeConfig = gnomeConfig {
      startupHook        = ewmhDesktopsStartup >> setWMName "LG3D", -- Make Java GUI work
      terminal           = myTerminal,

      modMask            = mod1Mask,
      keys               = \c -> myKeys c `M.union` multKeys c,

      handleEventHook    = myHandleEventHook,
      logHook            = myLogHook,
      layoutHook         = myLayout,
      manageHook         = myManageHook,
      focusFollowsMouse  = myFocusFollowsMouse
}

--- Run xmonad with the specified conifguration
main = xmonad customGnomeConfig

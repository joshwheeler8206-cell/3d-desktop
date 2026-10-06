U.S. AutoForce - 3D Wallpaper for Lively  (Windows 11)
====================================================

WHAT THIS IS
    The U.S. AutoForce 3D Desktop, but as your ACTUAL desktop background:
    the AutoForce logo, the tagline and a live clock, sitting behind your
    desktop icons. One HTML file, no internet, no images, no libraries.

    It runs inside Lively Wallpaper, which renders it behind the desktop.
    There is no control bar and no keyboard shortcuts in this version - the
    settings live in Lively's own properties panel instead (see CONTROLS).


STEP 1 - INSTALL LIVELY (once)
    Download from:  https://github.com/rocksdanister/lively/releases
    Or install the "Lively Wallpaper" app from the Microsoft Store.
    Lively is free and open source. No admin rights needed.


STEP 2 - ADD THE WALLPAPER
    Start Lively, then either:
      a) drag  autoforce-wallpaper.html  onto the Lively window, or
      b) click the  +  button -> Add -> Browse... and pick
         autoforce-wallpaper.html
    Lively finds LivelyProperties.json automatically because it sits in the
    same folder. Keep the two files together - do not move just the .html.


STEP 3 - ENJOY
    Lively applies it immediately. Right click the Lively tray icon to
    pause, change scenes, or turn it off for full screen apps / on battery.


CONTROLS
    Right click the wallpaper in Lively -> Customise -> Lively Properties:

      Scene             Night Highway / Crimson Dawn / Indigo Deck / Stealth
      Speed             0 = crawl, 50 = normal (1x), 100 = fastest
      Mouse parallax    follow the pointer with the scene
      Lite mode         drops stars, streaks and scanlines on weak hardware

    Settings are remembered per monitor. "Restore Default" resets them.


A NOTE ON THE CLOCK
    The large clock and date in the middle are part of the design, same as the
    full-screen 3D Desktop version. Desktop icons sit on the left, so they do
    not collide with it. If you would rather have no clock, use the plain
    "AutoForce 3D Wallpaper" icon from install.bat instead - that version is
    the same scene with no logo, no tagline and no clock at all.


TROUBLESHOOTING
    Black / blank wallpaper
        Windows 11 ships the WebView2 runtime that Lively needs. If your
        machine is missing it, install "Microsoft Edge WebView2 Runtime"
        (free) from Microsoft, then restart Lively.

    No controls under "Customise"
        LivelyProperties.json is missing or not next to the .html file.

    Choppy animation
        Set Speed to about 35, and/or turn on Lite mode.

    Nothing shows behind the icons
        Lively can be told to pause when a full screen app has focus
        (Lively -> Settings -> Performance). Disable that if a full screen
        app is running.

    Want to move it to another PC
        In Lively: right click the wallpaper -> Export Lively .zip.

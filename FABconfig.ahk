#Requires AutoHotkey v2.0
#SingleInstance Force

;@Ahk2Exe-SetMainIcon Resources\VBS_Logo.ico
;@Ahk2Exe-SetProductName FABconfig
;@Ahk2Exe-SetDescription FABconfig - Add Fabrication Configuration
;@Ahk2Exe-SetCompanyName Virtual Building Supply`, LLC
;@Ahk2Exe-SetCopyright Copyright (C) 2026 Virtual Building Supply`, LLC. GNU GPL v3.

/* ---+---+---+---+---+---+---FABconfig+---+---+---+---+---+---+
 *
 * FABconfig - Add Fabrication Configuration
 * Adds the Autodesk Fabrication database this program runs from to
 * Fabrication as a named configuration: creates a configuration folder with
 * a map.ini that points back to the database, and registers it with each
 * recent Fabrication version.
 *
 * Copyright (C) 2026 Virtual Building Supply, LLC
 * Author: Scott Hendricks
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * Additional terms under GNU GPL version 3, section 7:
 *  (b) The copyright notice and author attribution above must be preserved
 *      in this file and in any modified version of it.
 *  (e) This License grants no rights to use the trade names, trademarks or
 *      logos of Virtual Building Supply, LLC, including the VBS logo files in
 *      the Resources folder. Modified versions that are distributed must
 *      replace them.
 *
 * Version: see APP_VERSION below (AutoHotkey v2)
 *
 * ---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
 */

;======================= Configuration ==============================
APP_NAME    := "FABconfig"
; The version lives only here. The Ahk2Exe lines below copy it (without the
; "v") into the .exe's version details and name, so they must stay directly
; after this line. A second release on the same day adds a fourth number,
; like "v26.10.24.1".
APP_VERSION := "v26.10.24"
;@Ahk2Exe-Let U_version = %A_PriorLine~^.*"v([\d.]+)".*$~$1%
;@Ahk2Exe-SetVersion %U_version%
;@Ahk2Exe-ExeName FABconfig_v%U_version%.exe
WIN_TITLE   := "FABconfig - Add Fabrication Configuration"
CONFIG_ROOT := "C:\fabrication-configurations"
; FABconfig marks the map.ini it writes with this first line. VBS databases'
; own map.ini files start with it as well.
MAP_MARKER  := "# Created by Virtual Building Supply"

; Fabrication versions to register the configuration with: 4 years back to
; 2 years ahead of the current year (same range as the original script).
YEAR_FROM := A_YYYY - 4
YEAR_TO   := A_YYYY + 2

; The database is the folder this script is run from.
; If there's no map.ini here (or this is a configuration folder),
; FABconfig asks for the database folder at start-up.
DB_DIR  := IsDatabaseFolder(A_ScriptDir) && FileExist(A_ScriptDir "\map.ini") ? A_ScriptDir : ""
DB_PATH := StrReplace(DB_DIR, "\", "/")   ; map.ini uses forward slashes
; [COMPANY-INFO] DBNAME is optional; without it the name starts blank.
DB_NAME := DB_DIR != "" ? Trim(IniRead(DB_DIR "\map.ini", "COMPANY-INFO", "DBNAME", "")) : ""
NO_DB_TEXT := "No database selected. Click Browse to choose one."

;======================= VBS brand palette ==========================
; Greens and grays come from VBS_Logo.svg. The darker shades are used for
; text and icons so they stay readable on white.
CLR_GREEN          := "A6B727"   ; logo green: active-tab marker, focus outline
CLR_GREEN_DARK     := "6B7619"   ; text and icons on white
CLR_GREEN_MID      := "808D1E"   ; logo green outline
CLR_GREEN_TINT     := "F1F4DC"   ; chips, button fill, hover
CLR_GREEN_TINT2    := "E4EABF"   ; hover on tinted buttons
CLR_GREEN_HOVER    := "5A6315"   ; hover on the dark green button
CLR_GRAY_DARK      := "6C6C6E"   ; logo gray outline
CLR_SIDEBAR        := "2F3033"
CLR_SIDEBAR_HOVER  := "393B3F"
CLR_SIDEBAR_ACTIVE := "43454A"
CLR_SIDEBAR_TEXT   := "C9CACC"
CLR_SIDEBAR_MUTED  := "A9AAAD"
CLR_PAGE           := "F3F4F6"   ; window background
CLR_CARD           := "FFFFFF"
CLR_FIELD          := "F3F4F6"   ; text box fill
CLR_TEXT           := "2B2D31"
CLR_MUTED          := "6C6C6E"

FONT      := "Segoe UI"
FONT_SEMI := "Segoe UI Semibold"
ICON_FONT := "Segoe MDL2 Assets"   ; built into Windows 10 and 11

; Logo files live in a Resources folder next to the script. The compiled .exe
; has both built in (the icon through SetMainIcon, the badge below), so it
; doesn't need the folder.
LOGO_ICO   := A_ScriptDir "\Resources\VBS_Logo.ico"
LOGO_BADGE := A_ScriptDir "\Resources\VBS_Logo_Badge.png"
;@Ahk2Exe-AddResource Resources\VBS_Logo_Badge.png, VBS_LOGO_BADGE

ABOUT_TEXT := "
(
FABconfig adds the Fabrication database in this folder to Autodesk Fabrication (Revit, CADmep, ESTmep, CAMduct) as a configuration you can choose when the program starts. Run it from inside the database folder, or choose the database folder when it asks.

The map.ini it writes points the Database, Items, Images, Profiles, Reports and Scripts folders at this database. Projects, DXFs, Blocks and Backups stay in the configuration folder, so local work stays separate from the shared database.

Nothing in the database folder itself is changed. Running it again with the same name updates that configuration.

Copyright © 2026 Virtual Building Supply, LLC. FABconfig is free software under the GNU General Public License v3 and comes with ABSOLUTELY NO WARRANTY. See the LICENSE file for details.
)"

STEPS := [
    {Glyph: 0xE8B7, Color: CLR_GREEN_DARK, Title: "Create folder", Text: "Its own folder on this PC"},
    {Glyph: 0xE8A5, Color: CLR_GRAY_DARK,  Title: "Write map.ini", Text: "Points Fabrication at this database"},
    {Glyph: 0xE8B9, Color: CLR_GREEN_MID,  Title: "Copy picture",  Text: "config.png for the start-up list"},
    {Glyph: 0xE73E, Color: "4A4B4E",       Title: "Register",      Text: "Fabrication " YEAR_FROM "–" YEAR_TO}
]

;======================= Scaling ====================================
; Layout is designed at 100% scaling (96 DPI) and multiplied by SCALE.
SCALE := A_ScreenDPI / 96
S(n) => Round(n * SCALE)

currentView := "main"
locTouched  := false   ; true once the user edits or browses the location
settingLoc  := false
mainCtrls   := []
aboutCtrls  := []
ctl    := {}
groups := []           ; clickable groups (nav items, buttons, cards)
hoverMap := Map()      ; control hwnd -> group id
hotId  := 0            ; group currently under the mouse
created := []          ; every control, in the order it was added

if FileExist(LOGO_ICO)
    TraySetIcon(LOGO_ICO)          ; also becomes the window icon
else if !A_IsCompiled
    TraySetIcon(A_WinDir "\System32\shell32.dll", 239)

;======================= Build GUI ==================================
; +0x2000000 (WS_CLIPCHILDREN) stops the window background from painting
; over the controls, which reduces flicker when resizing.
g := Gui("+Resize -DPIScale +0x2000000", WIN_TITLE)
g.BackColor := CLR_PAGE
g.OnEvent("Close",  (*) => ExitApp())
g.OnEvent("Escape", OnEscape)
g.OnEvent("Size",   OnResize)
g.Opt("+OwnDialogs")   ; folder pickers and messages stay on top of this window
OnMessage(0x200, OnMouseMove)    ; WM_MOUSEMOVE: hover effects
OnMessage(0x20,  OnSetCursor)    ; WM_SETCURSOR: hand cursor on clickable items

; ---- Sidebar ----
ctl.Side := AddCtl("Text", "Background" CLR_SIDEBAR)
badgeBmp := A_IsCompiled ? LoadPngResource("VBS_LOGO_BADGE", S(64)) : 0
if badgeBmp {
    ctl.Badge := AddCtl("Picture", "w" S(64) " h" S(64), "HBITMAP:" badgeBmp)
} else if FileExist(LOGO_BADGE) {
    ctl.Badge := AddCtl("Picture", "w" S(64) " h" S(64), LOGO_BADGE)
} else {
    SetF("s22 c" CLR_GREEN_DARK, ICON_FONT)
    ctl.Badge := AddCtl("Text", "Center +0x200 Background" CLR_CARD, Chr(0xE8B7))
}
SetF("s13 cFFFFFF", FONT_SEMI)
ctl.AppName := AddCtl("Text", "Center Background" CLR_SIDEBAR, APP_NAME)
SetF("s9 c" CLR_SIDEBAR_MUTED)
ctl.AppVer := AddCtl("Text", "Center Background" CLR_SIDEBAR, APP_VERSION)

navMain  := MakeNav(0xE710, "New configuration", (*) => ShowView("main"))
navAbout := MakeNav(0xE897, "What's this?",      (*) => ShowView("about"))
navExit  := MakeNav(0xE7E8, "Exit",              (*) => ExitApp())

; ---- Main view ----
SetF("s17 c" CLR_TEXT, FONT_SEMI)
ctl.Head := AddCtl("Text", "Background" CLR_PAGE, "New configuration")
SetF("s10 c" CLR_MUTED)
ctl.Sub := AddCtl("Text", "Background" CLR_PAGE, "Add this database to Autodesk Fabrication as a configuration.")
mainCtrls.Push(ctl.Head, ctl.Sub)

ctl.Card := AddCtl("Text", "Background" CLR_CARD)
SetF("s11 c" CLR_TEXT, FONT_SEMI)
ctl.CardTitle := AddCtl("Text", "Background" CLR_CARD, "Configuration details")
SetF("s9 c" CLR_MUTED)
ctl.NameLbl := AddCtl("Text", "Background" CLR_CARD, "Configuration name")
fName := MakeField(DB_NAME)
SetF("s9 c" CLR_MUTED)
ctl.LocLbl := AddCtl("Text", "Background" CLR_CARD, "Configuration location")
fLoc := MakeField(CONFIG_ROOT "\" DB_NAME)   ; just the root if there's no DBNAME
btnBrowse := MakeButton(0xE838, "Browse", CLR_GREEN_TINT, CLR_GREEN_TINT2, CLR_GREEN_DARK, BrowseLocation)
SetF("s9 c" CLR_MUTED)
ctl.DbLbl := AddCtl("Text", "Background" CLR_CARD, "Fabrication database folder")
fDb := MakeField(DB_DIR != "" ? DB_DIR : NO_DB_TEXT, true)
btnDb := MakeButton(0xE838, "Browse", CLR_GREEN_TINT, CLR_GREEN_TINT2, CLR_GREEN_DARK, ChooseDatabase)
btnCreate := MakeButton(0xE710, "Create Configuration", CLR_GREEN_DARK, CLR_GREEN_HOVER, "FFFFFF", SaveConfig)
mainCtrls.Push(ctl.Card, ctl.CardTitle, ctl.NameLbl, ctl.LocLbl, ctl.DbLbl)

ctl.Name := fName.Edit
ctl.Loc  := fLoc.Edit
ctl.Name.OnEvent("Change", OnNameChange)
ctl.Loc.OnEvent("Change", OnLocChange)


; Versions card
ctl.VerCard := AddCtl("Text", "Background" CLR_CARD)
SetF("s10 c" CLR_TEXT, FONT_SEMI)
ctl.VerTitle := AddCtl("Text", "Background" CLR_CARD, "Registers with")
SetF("s9 c" CLR_MUTED)
ctl.VerSub := AddCtl("Text", "Background" CLR_CARD, "Autodesk Fabrication versions")
mainCtrls.Push(ctl.VerCard, ctl.VerTitle, ctl.VerSub)
chips := []
SetF("s9 c" CLR_GREEN_DARK, FONT_SEMI)
Loop (YEAR_TO - YEAR_FROM + 1) {
    chip := AddCtl("Text", "Center +0x200 Background" CLR_GREEN_TINT, YEAR_FROM + A_Index - 1)
    chips.Push(chip)
    mainCtrls.Push(chip)
}

; Enter key saves (a hidden default button)
AddCtl("Button", "Default Hidden", "Save").OnEvent("Click", (*) => (currentView = "main") && SaveConfig())

; ---- About view ----
SetF("s17 c" CLR_TEXT, FONT_SEMI)
ctl.AHead := AddCtl("Text", "Background" CLR_PAGE, "What this program does")
SetF("s10 c" CLR_MUTED)
ctl.ASub := AddCtl("Text", "Background" CLR_PAGE, "Here's what happens when you click Create Configuration.")
aboutCtrls.Push(ctl.AHead, ctl.ASub)

for st in STEPS {
    st.Bg := AddCtl("Text", "Background" CLR_CARD)
    SetF("s15 cFFFFFF", ICON_FONT)
    st.Icon := AddCtl("Text", "Center +0x200 Background" st.Color, Chr(st.Glyph))
    SetF("s10 c" CLR_TEXT, FONT_SEMI)
    st.Head := AddCtl("Text", "Background" CLR_CARD, st.Title)
    SetF("s9 c" CLR_MUTED)
    st.Desc := AddCtl("Text", "Background" CLR_CARD, st.Text)
    aboutCtrls.Push(st.Bg, st.Icon, st.Head, st.Desc)
}

ctl.ACard := AddCtl("Text", "Background" CLR_CARD)
SetF("s10 c" CLR_TEXT)
ctl.ABody := AddCtl("Text", "Background" CLR_CARD, ABOUT_TEXT)
aboutCtrls.Push(ctl.ACard, ctl.ABody)

;======================= Show window ================================
MonitorGetWorkArea(MonitorGetPrimary(), &waL, &waT, &waR, &waB)
winW := Min(S(920), waR - waL - S(40))
winH := Min(S(560), waB - waT - S(60))
g.Opt("+MinSize" winW "x" winH)

StackControls()
ShowView("main")
Layout(winW, winH)
g.Show("w" winW " h" winH)
ctl.Name.Focus()
if (DB_DIR = "")
    ChooseDatabase()
return

;======================= Building blocks ============================
SetF(opts, face := FONT) => g.SetFont("norm " opts, face)

; Every control goes through AddCtl so we know the order it was created in.
; +0x4000000 (WS_CLIPSIBLINGS) stops a control from painting over the
; controls stacked on top of it (for example a card painting over its text).
AddCtl(type, opts := "", text := "") {
    c := g.Add(type, opts " +0x4000000", text)
    created.Push(c)
    return c
}

; Windows stacks each new control *underneath* the ones before it, so the
; cards and the sidebar (created first) were covering everything placed on
; them. Re-stack so each control sits above the ones created before it.
StackControls() {
    for c in created
        DllCall("SetWindowPos", "ptr", c.Hwnd, "ptr", 0   ; 0 = HWND_TOP
            , "int", 0, "int", 0, "int", 0, "int", 0
            , "uint", 0x213)                             ; NOMOVE|NOSIZE|NOACTIVATE|NOOWNERZORDER
}

; A group is a set of controls that act as one clickable item with a hover color.
NewGroup(base, hover, onClick) {
    grp := {Id: groups.Length + 1, Normal: base, Hover: hover, OnClick: onClick, Parts: []}
    groups.Push(grp)
    return grp
}

AddPart(grp, ctrl) {
    grp.Parts.Push(ctrl)
    hoverMap[ctrl.Hwnd] := grp.Id
    ctrl.OnEvent("Click", (*) => grp.OnClick.Call())
    return ctrl
}

Paint(grp, clr) {
    for c in grp.Parts
        c.Opt("+Background" clr)
    for c in grp.Parts
        RedrawCtl(c)
}

; Repaint one control right away (honoring the controls stacked on top of it).
RedrawCtl(c) {
    DllCall("RedrawWindow", "ptr", c.Hwnd, "ptr", 0, "ptr", 0, "uint", 0x185)   ; INVALIDATE|ERASE|ALLCHILDREN|UPDATENOW
}

MakeNav(glyph, label, onClick) {
    grp := NewGroup(CLR_SIDEBAR, CLR_SIDEBAR_HOVER, onClick)
    grp.Bg := AddPart(grp, AddCtl("Text", "Background" CLR_SIDEBAR))
    SetF("s12 c" CLR_SIDEBAR_TEXT, ICON_FONT)
    grp.Icon := AddPart(grp, AddCtl("Text", "Center +0x200 Background" CLR_SIDEBAR, Chr(glyph)))
    SetF("s10 c" CLR_SIDEBAR_TEXT)
    grp.Label := AddPart(grp, AddCtl("Text", "+0x200 Background" CLR_SIDEBAR, label))
    grp.Ind := AddCtl("Text", "Hidden Background" CLR_GREEN)   ; active-tab marker
    return grp
}

SetNavActive(grp, on) {
    grp.Normal := on ? CLR_SIDEBAR_ACTIVE : CLR_SIDEBAR
    grp.Hover := on ? CLR_SIDEBAR_ACTIVE : CLR_SIDEBAR_HOVER
    fg := on ? "FFFFFF" : CLR_SIDEBAR_TEXT
    grp.Icon.SetFont("c" fg)
    grp.Label.SetFont("c" fg)
    grp.Ind.Visible := on
    Paint(grp, grp.Normal)
}

MakeButton(glyph, label, base, hover, fg, onClick) {
    grp := NewGroup(base, hover, onClick)
    grp.Bg := AddPart(grp, AddCtl("Text", "Background" base))
    SetF("s11 c" fg, ICON_FONT)
    grp.Icon := AddPart(grp, AddCtl("Text", "Center +0x200 Background" base, Chr(glyph)))
    SetF("s10 c" fg, FONT_SEMI)
    grp.Label := AddPart(grp, AddCtl("Text", "+0x200 Background" base, label))
    grp.Label.GetPos(, , &lw)            ; added without a width, so this is the text's width
    grp.LabelW := lw / SCALE
    mainCtrls.Push(grp.Parts*)
    return grp
}

; A rounded text box: a border layer (turns green when focused), a fill layer,
; and a borderless Edit on top. isStatic shows read-only text instead.
MakeField(value, isStatic := false) {
    f := {}
    f.Border := AddCtl("Text", "Background" CLR_FIELD)
    f.Fill   := AddCtl("Text", "Background" CLR_FIELD)
    if isStatic {
        SetF("s10 c" CLR_MUTED)
        f.Edit := AddCtl("Text", "+0x8000 +0x200 Background" CLR_FIELD, value)   ; 0x8000: shorten long paths with "..."
    } else {
        SetF("s10 c" CLR_TEXT)
        f.Edit := AddCtl("Edit", "-E0x200 r1 -Wrap Background" CLR_FIELD, value)
        f.Edit.OnEvent("Focus",     (*) => FieldFocus(f, true))
        f.Edit.OnEvent("LoseFocus", (*) => FieldFocus(f, false))
    }
    mainCtrls.Push(f.Border, f.Fill, f.Edit)
    return f
}

FieldFocus(f, on) {
    f.Border.Opt("+Background" (on ? CLR_GREEN : CLR_FIELD))
    RedrawCtl(f.Border)
    RedrawCtl(f.Fill)
    RedrawCtl(f.Edit)
}

; Loads a PNG built into the compiled .exe (AddResource stores it as RT_RCDATA)
; and scales it to size x size pixels with GDI+. Returns an HBITMAP, or 0.
LoadPngResource(name, size) {
    hMod := DllCall("GetModuleHandle", "ptr", 0, "ptr")
    hRes := DllCall("FindResource", "ptr", hMod, "str", name, "ptr", 10, "ptr")   ; 10 = RT_RCDATA
    if !hRes
        return 0
    bytes := DllCall("SizeofResource", "ptr", hMod, "ptr", hRes, "uint")
    pData := DllCall("LockResource", "ptr", DllCall("LoadResource", "ptr", hMod, "ptr", hRes, "ptr"), "ptr")
    stream := DllCall("shlwapi\SHCreateMemStream", "ptr", pData, "uint", bytes, "ptr")
    if !stream
        return 0

    DllCall("LoadLibrary", "str", "gdiplus")
    si := Buffer(24, 0), NumPut("uint", 1, si)                ; GdiplusStartupInput, version 1
    DllCall("gdiplus\GdiplusStartup", "ptr*", &token := 0, "ptr", si, "ptr", 0)
    hbm := 0
    DllCall("gdiplus\GdipCreateBitmapFromStream", "ptr", stream, "ptr*", &src := 0)
    if src {
        ; Draw onto a size x size bitmap with high-quality scaling (the logo is
        ; 256 px), then convert it with a white background (the badge is on white).
        DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", size, "int", size, "int", 0, "int", 0x26200A, "ptr", 0, "ptr*", &dst := 0)   ; 32bppARGB
        DllCall("gdiplus\GdipGetImageGraphicsContext", "ptr", dst, "ptr*", &gfx := 0)
        DllCall("gdiplus\GdipSetInterpolationMode", "ptr", gfx, "int", 7)      ; HighQualityBicubic
        DllCall("gdiplus\GdipSetPixelOffsetMode", "ptr", gfx, "int", 4)        ; HighQuality
        DllCall("gdiplus\GdipDrawImageRectI", "ptr", gfx, "ptr", src, "int", 0, "int", 0, "int", size, "int", size)
        DllCall("gdiplus\GdipDeleteGraphics", "ptr", gfx)
        DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "ptr", dst, "ptr*", &hbm, "uint", 0xFFFFFFFF)
        DllCall("gdiplus\GdipDisposeImage", "ptr", dst)
        DllCall("gdiplus\GdipDisposeImage", "ptr", src)
    }
    ObjRelease(stream)
    DllCall("gdiplus\GdiplusShutdown", "ptr", token)
    return hbm
}

;======================= Layout =====================================
OnResize(guiObj, minMax, w, h) {
    if (minMax = -1)
        return
    Layout(w, h)
}

; Move a control using 100%-scale units; r rounds its corners.
M(ctrl, x, y, w, h, r := 0) {
    ctrl.Move(S(x), S(y), S(w), S(h))
    if r
        RoundCorners(ctrl, S(r))
}

RoundCorners(ctrl, r) {
    ctrl.GetPos(, , &w, &h)
    rgn := DllCall("CreateRoundRectRgn", "int", 0, "int", 0, "int", w + 1, "int", h + 1, "int", r, "int", r, "ptr")
    DllCall("SetWindowRgn", "ptr", ctrl.Hwnd, "ptr", rgn, "int", true)
}

PlaceNav(grp, y) {
    M(grp.Bg,    0,  y,     200, 40)
    M(grp.Ind,   0,  y + 8, 4,   24)
    M(grp.Icon,  20, y,     24,  40)
    M(grp.Label, 54, y,     140, 40)
}

PlaceButton(grp, x, y, w, h) {
    M(grp.Bg, x, y, w, h, 10)
    lw := Min(grp.LabelW + 4, w - 46)
    sx := x + (w - (20 + 8 + lw)) / 2   ; center icon + label together
    M(grp.Icon,  sx,      y, 20, h)
    M(grp.Label, sx + 28, y, lw, h)
}

PlaceField(f, x, y, w, h := 38) {
    M(f.Border, x,       y,       w,       h,       10)
    M(f.Fill,   x + 1.5, y + 1.5, w - 3,   h - 3,   9)
    M(f.Edit,   x + 12,  y + 8,   w - 24,  h - 16)
}

Layout(w, h) {
    W := w / SCALE, H := h / SCALE      ; work in 100%-scale units
    SB := 200                           ; sidebar width

    ; ---- Sidebar ----
    M(ctl.Side,    0, 0, SB, H)
    M(ctl.Badge,   (SB - 64) / 2, 30, 64, 64, 18)
    M(ctl.AppName, 0, 104, SB, 26)
    M(ctl.AppVer,  0, 130, SB, 18)
    PlaceNav(navMain,  172)
    PlaceNav(navAbout, 216)
    PlaceNav(navExit,  H - 64)

    pad := 28
    x0  := SB + pad
    cw  := W - SB - 2 * pad             ; content width
    top := 96

    ; ---- Main view ----
    M(ctl.Head, x0, 22, cw, 34)
    M(ctl.Sub,  x0, 58, cw, 20)

    rw := 230, gap := 20                ; right column
    lw := cw - rw - gap                 ; left column
    rx := x0 + lw + gap

    perRow := 3
    rows := Ceil(chips.Length / perRow)
    verY  := top
    verH  := 72 + rows * 34 + 8
    colH  := Max(354, H - top - pad)    ; fill the window height; 354 fits the fields and buttons

    M(ctl.Card, x0, top, lw, colH, 16)
    ix := x0 + 22, iw := lw - 44
    M(ctl.CardTitle, ix, top + 20, iw, 24)
    y := top + 60
    M(ctl.NameLbl, ix, y, iw, 18)
    PlaceField(fName, ix, y + 22, iw)
    y += 76
    bw := 104
    M(ctl.LocLbl, ix, y, iw, 18)
    PlaceField(fLoc, ix, y + 22, iw - bw - 8)
    PlaceButton(btnBrowse, ix + iw - bw, y + 22, bw, 38)
    y += 76
    M(ctl.DbLbl, ix, y, iw, 18)
    PlaceField(fDb, ix, y + 22, iw - bw - 8)
    PlaceButton(btnDb, ix + iw - bw, y + 22, bw, 38)
    by := top + colH - 22 - 40          ; buttons along the bottom of the card
    PlaceButton(btnCreate, ix + iw - 220, by, 220, 40)

    M(ctl.VerCard,  rx,      verY,      rw,      verH, 16)
    M(ctl.VerTitle, rx + 20, verY + 18, rw - 40, 22)
    M(ctl.VerSub,   rx + 20, verY + 40, rw - 40, 18)
    chipW := (rw - 40 - (perRow - 1) * 8) / perRow
    for i, chip in chips {
        r := (i - 1) // perRow, c := Mod(i - 1, perRow)
        M(chip, rx + 20 + c * (chipW + 8), verY + 72 + r * 34, chipW, 26, 12)
    }

    ; ---- About view ----
    M(ctl.AHead, x0, 22, cw, 34)
    M(ctl.ASub,  x0, 58, cw, 20)
    tw := (cw - 3 * 16) / 4, th := 150
    for i, st in STEPS {
        tx := x0 + (i - 1) * (tw + 16)
        M(st.Bg,   tx,      top,       tw,      th, 16)
        M(st.Icon, tx + 18, top + 18,  40,      40, 12)
        M(st.Head, tx + 18, top + 72,  tw - 36, 22)
        M(st.Desc, tx + 18, top + 94,  tw - 36, 44)
    }
    ay := top + th + 20
    M(ctl.ACard, x0,      ay,      cw,      H - ay - pad,      16)
    M(ctl.ABody, x0 + 24, ay + 20, cw - 48, H - ay - pad - 40)
}

;======================= Views and hover ============================
ShowView(name) {
    global currentView := name
    SetHot(0)
    for c in mainCtrls
        c.Visible := (name = "main")
    for c in aboutCtrls
        c.Visible := (name = "about")
    SetNavActive(navMain,  name = "main")
    SetNavActive(navAbout, name = "about")
    if (name = "main")
        ctl.Name.Focus()
}

OnEscape(*) {
    if (currentView = "about")
        ShowView("main")
    else
        ExitApp()
}

OnMouseMove(wParam, lParam, msg, hwnd) {
    SetHot(hoverMap.Has(hwnd) ? hoverMap[hwnd] : 0)
}

; Polls while something is highlighted, to catch the mouse leaving the window.
CheckHover() {
    MouseGetPos(, , , &h, 2)
    SetHot((h && hoverMap.Has(h)) ? hoverMap[h] : 0)
}

SetHot(id) {
    global hotId
    if (id = hotId)
        return
    if hotId
        Paint(groups[hotId], groups[hotId].Normal)
    hotId := id
    if id {
        Paint(groups[id], groups[id].Hover)
        SetTimer(CheckHover, 50)
    } else {
        SetTimer(CheckHover, 0)
    }
}

OnSetCursor(wParam, lParam, msg, hwnd) {
    if hoverMap.Has(wParam) {
        DllCall("SetCursor", "ptr", DllCall("LoadCursor", "ptr", 0, "ptr", 32649, "ptr"))   ; hand
        return true
    }
}

;======================= Database folder ============================
; A folder counts as a Fabrication database if it has a map.ini or a DATABASE
; folder, and isn't a configuration folder.
IsDatabaseFolder(dir) => (FileExist(dir "\map.ini") || DirExist(dir "\DATABASE")) && !IsConfigFolder(dir)

; A configuration folder's map.ini points Main at a database somewhere else;
; a database's own map.ini points Main at itself (usually "."). The first-line
; marker can't tell them apart: VBS databases have it too.
IsConfigFolder(dir) {
    if !FileExist(dir "\map.ini")
        return false
    main := Trim(IniRead(dir "\map.ini", "PROGRAM PATHS", "Main", ""))
    if (main = "")
        return false
    main := StrReplace(main, "/", "\")
    if !RegExMatch(main, "^([A-Za-z]:|\\\\)")   ; relative to the map.ini's folder
        main := dir "\" main
    return RTrim(FullPath(main), "\") != RTrim(FullPath(dir), "\")
}

; Resolves "." and ".." in a path.
FullPath(p) {
    buf := Buffer(32768 * 2)
    n := DllCall("GetFullPathNameW", "str", p, "uint", 32768, "ptr", buf, "ptr", 0, "uint")
    return n ? StrGet(buf) : p
}

; True if FABconfig wrote this folder's map.ini. Only meaningful for a
; configuration folder, since VBS databases have the same first line.
HasMarker(dir) {
    try {
        f := FileOpen(dir "\map.ini", "r")   ; detects a UTF-8/UTF-16 BOM
        line := f.ReadLine()
        f.Close()
        return InStr(line, MAP_MARKER) = 1
    }
    return false
}

ChooseDatabase(*) {
    start := DB_DIR != "" ? "*" DB_DIR : ""
    prompt := "Select a folder that contains a Fabrication database"
    Loop {
        sel := DirSelect(start, 0, prompt)
        if (sel = "")                  ; cancelled
            return false
        sel := RTrim(sel, "\")
        if IsDatabaseFolder(sel) {
            SetDatabase(sel)
            return true
        }
        if IsConfigFolder(sel)
            why := "This is a Fabrication configuration folder, not a database. Its map.ini points to a database somewhere else:`n"
        else
            why := "This folder doesn't look like a Fabrication database (it has no map.ini or DATABASE folder):`n"
        if MsgBox(why sel "`n`nChoose a different folder?", APP_NAME, "RetryCancel Icon!") != "Retry"
            return false
        start := "*" sel
    }
}

SetDatabase(dir) {
    global DB_DIR := dir, DB_PATH := StrReplace(dir, "\", "/")
    global DB_NAME := Trim(IniRead(dir "\map.ini", "COMPANY-INFO", "DBNAME", ""))
    fDb.Edit.Text := dir
    ; Fill in the name from the database, unless the user already typed one.
    if (Trim(ctl.Name.Value) = "" && DB_NAME != "") {
        ctl.Name.Value := DB_NAME
        OnNameChange()
    }
}

;======================= Inputs =====================================
; Keep the location in step with the name until the user picks their own.
OnNameChange(*) {
    global settingLoc
    if locTouched
        return
    name := Trim(ctl.Name.Value)
    settingLoc := true
    ctl.Loc.Value := CONFIG_ROOT "\" name   ; just the root while the name is blank
    settingLoc := false
}

OnLocChange(*) {
    global locTouched
    if !settingLoc
        locTouched := true
}

BrowseLocation(*) {
    global locTouched
    start := ctl.Loc.Value != "" ? "*" ctl.Loc.Value : ""
    sel := DirSelect(start, 3, "Select the folder for this configuration.")
    if (sel = "")
        return
    locTouched := true
    ctl.Loc.Value := sel
}

;======================= Save =======================================
SaveConfig(*) {
    name := Trim(ctl.Name.Value)
    dir  := RTrim(Trim(ctl.Loc.Value), "\")

    ; ---- Validate ----
    if (DB_DIR = "") {
        MsgBox("Choose the Fabrication database folder first.", APP_NAME, "Iconi")
        ShowView("main")
        ChooseDatabase()
        return
    }
    if (name = "")
        return Fail(ctl.Name, "Enter a configuration name.")
    if RegExMatch(name, '[\\/:*?"<>|]')
        return Fail(ctl.Name, "The configuration name can't contain any of these characters:`n\ / : * ? `" < > |")
    if (dir = "")
        return Fail(ctl.Loc, "Choose a configuration location.")
    if !RegExMatch(dir, "^([A-Za-z]:|\\\\)")
        return Fail(ctl.Loc, "The configuration location must be a full path, like`n" CONFIG_ROOT "\" name)
    if (dir = DB_DIR) || InStr(DB_DIR "\", dir "\") = 1
        return Fail(ctl.Loc, "The configuration location can't be the database folder or a folder that contains it.")
    if InStr(dir "\", DB_DIR "\") = 1
        return Fail(ctl.Loc, "The configuration location can't be inside the database folder. Choose a folder outside it, like`n" CONFIG_ROOT "\" name)

    ; ---- Confirm before overwriting an existing configuration ----
    years := FabYears()
    found := FindConfig(name, years)
    if found.Years.Length {
        msg := 'A configuration named "' name '" already exists.`n`n'
            . "Registered with: Fabrication " JoinList(found.Years) "`n"
            . "Location:`n" JoinList(found.Paths, "`n") "`n"
        for p in found.Paths
            if FileExist(p "\map.ini") && !HasMarker(p) {
                msg .= "`nIt wasn't made by FABconfig, so it may have been set up by hand.`n"
                break
            }
        if (found.Paths.Length > 1 || found.Paths[1] != dir)
            msg .= "`nIt will point to the new location instead:`n" dir "`nThe old folder is left as it is.`n"
        else if FileExist(dir "\map.ini")
            msg .= "`nThe current map.ini will be kept as map.ini.bak.`n"
        if MsgBox(msg "`nOverwrite it?", APP_NAME, "YesNo Icon! Default2") != "Yes"
            return
    } else if FileExist(dir "\map.ini") {
        if MsgBox("This folder already has a map.ini:`n" dir
                . "`n`nOverwrite it? The current one will be kept as map.ini.bak.", APP_NAME, "YesNo Icon! Default2") != "Yes"
            return
    }

    ; ---- Create folder and files ----
    try {
        DirCreate(dir)
        ; Only the files we replace need to be writable.
        try FileSetAttrib("-R", dir "\config.png")
        try FileSetAttrib("-R", dir "\map.ini")
        try FileSetAttrib("-R", dir "\map.ini.bak")
        if FileExist(DB_DIR "\config.png")
            FileCopy(DB_DIR "\config.png", dir "\config.png", 1)
        ; Keep the previous map.ini (one level of backup).
        if FileExist(dir "\map.ini")
            FileMove(dir "\map.ini", dir "\map.ini.bak", 1)
        FileAppend(MapIniText(), dir "\map.ini", "CP0 `n")
    } catch as err {
        MsgBox("Couldn't write the configuration files in`n" dir "`n`n" err.Message, APP_NAME, "Icon!")
        return
    }

    ; ---- Register with Fabrication ----
    ; Every year in the range, plus any other installed year it was already
    ; registered with, so an overwrite doesn't leave old entries behind.
    try {
        for year in years
            RegWrite(dir, "REG_SZ", RegKey(year, name), "Path")
    } catch as err {
        MsgBox("The files were created, but registering the configuration failed:`n`n" err.Message, APP_NAME, "Icon!")
        return
    }

    done := found.Years.Length ? "updated" : "added"
    MsgBox('Configuration "' name '" ' done '.`n`nIt will appear in the configuration list the next time you start Fabrication.'
        , APP_NAME, "Iconi")
    ExitApp()
}

; The Fabrication years to check and register: the YEAR_FROM-YEAR_TO range
; plus any other "Fabrication <year>" key already in the registry.
; Map keys are integers, so a for-loop returns them in order.
FabYears() {
    years := Map()
    Loop (YEAR_TO - YEAR_FROM + 1)
        years[YEAR_FROM + A_Index - 1] := true
    try {
        Loop Reg, "HKCU\Software\Autodesk", "K"
            if RegExMatch(A_LoopRegName, "^Fabrication (\d{4})$", &m)
                years[Integer(m[1])] := true
    }
    return years
}

; Which of those years have a configuration with this name, and the
; (distinct) folders they point to.
FindConfig(name, years) {
    found := {Years: [], Paths: []}
    seen := Map()
    seen.CaseSense := "Off"
    for year in years {
        p := RTrim(RegRead(RegKey(year, name), "Path", ""), "\")
        if (p = "")
            continue
        found.Years.Push(year)
        if !seen.Has(p) {
            seen[p] := true
            found.Paths.Push(p)
        }
    }
    return found
}

JoinList(items, sep := ", ") {
    out := ""
    for i, item in items
        out .= (i > 1 ? sep : "") item
    return out
}

Fail(edt, message) {
    MsgBox(message, APP_NAME, "Iconi")
    ShowView("main")
    edt.Focus()
}

RegKey(year, name) => "HKCU\Software\Autodesk\Fabrication " year "\Configuration\" name

MapIniText() {
    text := "
    (
# Created by Virtual Building Supply, LLC

[PROGRAM PATHS]
DXF=.
Blocks=.
Backup=.
Common={1}
Database={1}/database
Download=.
Images={1}/images
Items={1}/items
Main={1}
Profiles={1}/profiles
Project=./projects
Reports={1}/reports
Scripts={1}/scripts
Textures=.

    )"
    return Format(text, DB_PATH)
}

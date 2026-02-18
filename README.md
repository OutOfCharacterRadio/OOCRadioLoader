# Out of Character Radio – In-Game Radio & Loading Screen
![Out of Character Radio Promotional Image](https://drive.google.com/u/0/drive-viewer/AKGpihb2V7wEMXIQAOmOFSJnUgqjzzAzz_FJgxUcnf-7xvg8jRlT0yVe8aDSZC9_OVgqyFYaaBmoZ6-KlLm55KXrF5Ui-p10mYagSA=s1600-rw-v1)
---

## Quick start

1. Copy the **OOCRadioLoader** folder into your server `resources` directory.
2. In `server.cfg`: `ensure OOCRadioLoader` (use your folder name if different).
3. Edit **config.json** – community name, loading screen welcome message, rules, and news.

---

## Config (one file for everything)

**config.json** – Edit this file only:

| Field | Description |
|-------|-------------|
| `communityName` | Your server/community name (used in `/requestsong` and `/shoutout`; if empty, server hostname is used). |
| `welcomeMessage` | Loading screen heading below the logo. |
| `rulesContent` | “Rules & Info” card. Supports **bold**, *italic*, [text](url), line breaks. |
| `latestNewsContent` | “What’s New” card. Same Markdown. |

---

## Loading screen

- **Text:** All in **config.json** (`welcomeMessage`, `rulesContent`, `latestNewsContent`).
- **Images:** Add to **assets/** folder: `logo.png`, `oocradio_logo.png`, `background.png` (see `assets/README.txt`). Then in **fxmanifest.lua** uncomment the three `assets/...` lines in `files { }`.
- **Cursor:** Already enabled (`loadscreen_cursor 'yes'`).

---

## In-game radio

- **Station:** Set in **fxmanifest.lua** via `supersede_radio` (default: iFruit → Out of Character Radio).
- **Radio wheel logo:** See **stream/STREAM_README.md** to replace the GTA wheel icon with your logo.
- **Commands:** `/requestsong <message>` and `/shoutout <message>` (when presenter is live). 403 = “Presenter is not live” in chat.

---

## Folder structure

```
radio/
├── fxmanifest.lua    # Manifest (radio + loadscreen)
├── config.json       # Single config: community name + loading screen text
├── server.lua        # /requestsong, /shoutout
├── client.js
├── data.js
├── index.html        # In-game radio NUI
├── loadscreen.html   # Loading screen
├── loadscreen.css
├── loadscreen.js
├── assets/           # Optional: logo.png, oocradio_logo.png, background.png
└── stream/           # Optional: hud.ytd for radio wheel logo
```

---

## Credits

- Radio: Hellslicer. Loading screen: Custom developed by Out of Character Radio

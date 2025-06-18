# StillsFromTimecode.lua

**Batch Export Stills from Timecode List — DaVinci Resolve Utility**

## Overview

This Lua script allows you to **batch export PNG stills** from a DaVinci Resolve timeline using a list of SMPTE timecodes from a text file. Perfect for quickly generating frame exports for VFX, reference, client review, or archiving — **without needing the Gallery**.

---

## Features

- **Batch Export:** Export frames at each timecode from a list.
- **Automatic Naming:** PNGs are named after their timecode (e.g., `01_23_45_12.png`).
- **No Gallery Needed:** Works directly from the Color or Edit page.
- **Easy to Use:** Interactive file pickers for your timecode list and output folder.
- **Error Handling:** Skips invalid lines and reports issues clearly.

---

## Requirements

- **DaVinci Resolve Studio** (the script uses API calls available only in Studio)
- Timeline must be set to the **intended FPS and start timecode**
- Use on the **Color** or **Edit** page (where still export is supported)

---

## Installation

1. **Copy** `ExtractBatchStills.lua` to:

    ```
    ~/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Utility
    ```

    *(On Windows, use the equivalent path inside your DaVinci Resolve user folder.)*

2. **Restart DaVinci Resolve** if it’s open.

---

## Usage

1. **Open your Resolve project and timeline.**
2. Go to the **Color** or **Edit** page.
3. Run the script via:  
    ```
    Workspace > Scripts > Utility > ExtractBatchStills
    ```
4. **Select your timecode text file** (format: one SMPTE timecode per line, e.g., `01:23:45:12`).
5. **Choose an output folder** for the PNG stills.
6. Let the script process your list — each valid timecode will generate a PNG named after it.

---

## Timecode File Format

- Plain `.txt` file
- One SMPTE timecode per line (e.g., `hh:mm:ss:ff`)
- Example:
    ```
    00:00:10:00
    00:00:45:12
    01:02:03:04
    ```

---

## Notes & Tips

- The timeline’s **start timecode and frame rate** must match your timecode list.
- The script reports and skips invalid or empty lines.
- Stills are exported using Resolve’s internal method for high quality.

---

## Troubleshooting

- **"Please open a project and a timeline first."**  
  Make sure you have an active timeline in your Resolve project.
- **"No valid timecode file selected."**  
  The script needs a readable `.txt` file with timecodes.
- **"Failed to export: ..."**  
  Check write permissions for the output folder or timeline position validity.

---

## License

MIT License — Free to use, modify, and share.

---

*If you need enhancements or hit bugs, please open an issue or PR!*

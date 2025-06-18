-- ===============================================
-- ✅ DaVinci Resolve Lua Script:
-- Batch Export Stills from Timecode List (No Gallery needed)
--
-- Purpose:
--   For each SMPTE timecode in a text file,
--   - Seek the timeline to that frame,
--   - Export the frame as a PNG,
--   - Name each PNG after its timecode,
--   - Save to user-specified folder.
--
-- Requirements:
--   - DaVinci Resolve Studio
--   - Timeline must match intended FPS and starting TC
--   - Color page or Edit page active
--
-- How to run:
--   1. Place this script in ~/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Utility
--   2. Run from Workspace > Scripts
--   3. Pick your timecode .txt and output folder
--
-- ===============================================

-- === Load core Resolve objects ===

resolve = Resolve()
pm = resolve:GetProjectManager()
project = pm:GetCurrentProject()
timeline = project:GetCurrentTimeline()

-- Get Fusion UI app for file/folder pickers
fusion = bmd.scriptapp("Fusion")

-- === Basic checks ===
if not project or not timeline then
    print("❌ Please open a project and a timeline first.")
    return
end

-- === Helper: check if file exists ===
function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then io.close(f) return true else return false end
end

-- === Step 1: Prompt user for Timecode file ===

tcFile = fusion:RequestFile("Select Timecode TXT File")
if not tcFile or not file_exists(tcFile) then
    print("❌ No valid timecode file selected.")
    return
end

-- === Step 2: Prompt user for output folder ===

outputFolder = fusion:RequestDir("Select Output Folder")
if not outputFolder or outputFolder == "" then
    print("❌ No output folder selected.")
    return
end

print("✅ Timecode file: " .. tcFile)
print("✅ Output folder: " .. outputFolder)

-- === Step 3: Get timeline info (for correct frame math) ===

fps = tonumber(project:GetSetting("timelineFrameRate"))
timelineStartTC = timeline:GetStartTimecode()

print("✅ Timeline starts at: " .. timelineStartTC)
print("✅ Timeline FPS: " .. fps)

-- === Step 4: Read and clean timecodes ===

timecodes = {}

for line in io.lines(tcFile) do
    -- Remove any BOM or stray Unicode markers
    local tc = line:gsub("\226\128\175",""):gsub("\239\187\191",""):match("^%s*(.-)%s*$")
    -- Keep only valid SMPTE TC strings (hh:mm:ss:ff)
    if tc ~= "" and tc:match("^%d+:%d+:%d+:%d+$") then
        table.insert(timecodes, tc)
    else
        print("⚠️  Skipping invalid or empty line: [" .. line .. "]")
    end
end

if #timecodes == 0 then
    print("❌ No valid timecodes found in file.")
    return
end

print("✅ Found " .. #timecodes .. " valid timecodes.")

-- === Helper: SMPTE <-> frames converters ===

-- Convert SMPTE TC to integer frame number
function smpte_to_frames(tc, fps)
    local h, m, s, f = string.match(tc, "(%d+):(%d+):(%d+):(%d+)")
    return tonumber(h)*3600*fps + tonumber(m)*60*fps + tonumber(s)*fps + tonumber(f)
end

-- Convert frame number back to SMPTE TC
function frames_to_smpte(frames, fps)
    local total_sec = frames / fps
    local h = math.floor(total_sec / 3600)
    local m = math.floor((total_sec % 3600) / 60)
    local s = math.floor(total_sec % 60)
    local f = math.floor(frames % fps)
    return string.format("%02d:%02d:%02d:%02d", h, m, s, f)
end

-- === Step 5: For each timecode, seek + export frame ===

for i, tc in ipairs(timecodes) do
    print("➡️  Processing: " .. tc)

    -- Convert clip-based TC to timeline-based TC
    -- Example: if timeline starts at 01:00:00:00 and TC is 00:00:45:00,
    -- add the start offset to get correct timeline position.
    local inputFrames = smpte_to_frames(tc, fps)
    local offsetFrames = smpte_to_frames(timelineStartTC, fps)
    local absoluteFrames = inputFrames + offsetFrames
    local finalTC = frames_to_smpte(absoluteFrames, fps)

    -- Seek timeline playhead to the target timecode
    local ok = timeline:SetCurrentTimecode(finalTC)

    if not ok then
        print("❌ Could not seek to: " .. finalTC)
    else
        -- Build safe output filename (replace : with _)
        local safeName = tc:gsub(":", "_") .. ".png"
        local path = outputFolder .. "/" .. safeName

        -- Use official Project method to export frame
        local success = project:ExportCurrentFrameAsStill(path)
        if success then
            print("✅ Saved: " .. path)
        else
            print("❌ Failed to export: " .. path)
        end
    end
end

print("🎉 All done! " .. #timecodes .. " stills exported successfully.")

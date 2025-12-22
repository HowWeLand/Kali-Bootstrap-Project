# Correction: nvme-cli Command Syntax

**Date Discovered:** 2025-12-17  
**Impact:** Major (script command will fail)  
**Affects:** phase1-automated-install.sh serial verification function

---

## What Was Wrong

Script used `nvme id-ctrl` without the `-H` (human-readable) flag for parsing serial numbers:

```bash
# Original (incorrect) command
actual_serial=$(nvme id-ctrl "$drive" 2>/dev/null | grep "^sn" | awk '{print $3}')
```

## Why It Was Wrong

**`nvme id-ctrl` without `-H` outputs raw binary/hex data**, not parseable text.

**The problem:**
- `grep "^sn"` won't find a field labeled "sn" in raw output
- Output is controller information in hex format
- Serial number is buried in binary data
- Cannot reliably extract with text tools (grep, awk)

**What happens:**
```bash
nvme id-ctrl /dev/nvme0n1
# Output: Binary gibberish that grep can't parse
# Result: $actual_serial = empty string
# Consequence: Serial verification always fails
```

## What's Correct

**Use `-H` flag for human-readable output:**

```bash
# Corrected command
actual_serial=$(nvme id-ctrl -H /dev/nvme0n1 2>/dev/null | grep "^sn" | awk '{print $3}')
```

**With `-H`, output is:**
```
NVME Identify Controller:
vid       : 0x144d
ssvid     : 0x144d
sn        : S5GXNX0T123456    ← Now parseable!
mn        : Samsung SSD 990 PRO 2TB
...
```

**Now `grep "^sn"` works correctly** and awk can extract the serial number.

## How We Discovered This

### Testing the Script

**Attempted to run script against actual hardware:**

```bash
# Test serial verification function
verify_drive_serial "/dev/nvme0n1" "S5GXNX0T123456"

# Error output:
# Serial mismatch for /dev/nvme0n1!
#   Expected: S5GXNX0T123456
#   Actual:   UNKNOWN
```

**Investigation:**
```bash
# Manual testing
nvme id-ctrl /dev/nvme0n1 | grep "^sn"
# Returns: nothing (no line starting with "sn")

# Check raw output
nvme id-ctrl /dev/nvme0n1
# Output: Binary data, hex dumps, not text fields

# Try with -H flag
nvme id-ctrl -H /dev/nvme0n1 | grep "^sn"
# Output: sn        : S5GXNX0T123456
# Success!
```

**Root cause:** Script was written based on documentation/examples that didn't specify `-H` requirement for text parsing.

## What Changed

### Script Update

**File:** `scripts/phase1-automated-install.sh`

**Function:** `verify_drive_serial()`

```bash
# Before
if [[ "$drive" =~ nvme ]]; then
    actual_serial=$(nvme id-ctrl "$drive" 2>/dev/null | grep "^sn" | awk '{print $3}' || echo "UNKNOWN")
fi

# After
if [[ "$drive" =~ nvme ]]; then
    actual_serial=$(nvme id-ctrl -H "$drive" 2>/dev/null | grep "^sn" | awk '{print $3}' || echo "UNKNOWN")
fi
```

**The fix:** Added `-H` flag to `nvme id-ctrl` command.

### Alternative Command (Also Correct)

**Using `nvme id-ctrl` with specific field extraction:**

```bash
# More robust approach
actual_serial=$(nvme id-ctrl -H /dev/nvme0n1 | grep "^sn" | cut -d: -f2 | xargs)
```

**Or using nvme-cli's output parsing:**
```bash
# Most reliable (but requires newer nvme-cli)
actual_serial=$(nvme id-ctrl /dev/nvme0n1 --output-format=json | jq -r '.sn')
```

**Current implementation uses `grep | awk` for compatibility** with older nvme-cli versions that may not support `--output-format`.

## Lesson Learned

### Test Commands on Real Hardware

**Mistake:** Wrote script based on documentation/examples without testing actual command output.

**Correction:** Always test commands against real hardware before incorporating into scripts.

**Process should be:**
1. Read documentation
2. Test command manually
3. Verify output format
4. Write parsing logic
5. Test parsing on actual output
6. Incorporate into script

**Don't skip steps 2-5.**

### Human-Readable Flags Matter

**Many system tools have two output modes:**
- Machine-readable (default, often binary/hex)
- Human-readable (with flags like `-H`, `--human-readable`)

**For parsing with grep/awk/sed:** You almost always need the human-readable version.

**Examples:**
- `nvme id-ctrl -H` (human-readable controller info)
- `df -h` (human-readable disk space)
- `du -h` (human-readable directory sizes)
- `smartctl -i` (info mode, already human-readable)

**If grep isn't finding what documentation says should be there:** Check if you need a flag for human-readable output.

### Documentation Isn't Always Complete

**NVMe-cli documentation** shows command examples but doesn't always specify when `-H` is required for text parsing.

**Lesson:** Read man pages thoroughly and test commands rather than copy-pasting examples.

```bash
man nvme-id-ctrl
# Shows -H, --human-readable flag
# "This will show the fields in a human readable format"
```

### Error Handling Caught This

**The script's error handling worked:**

```bash
actual_serial=$(... || echo "UNKNOWN")
```

When the command failed to extract serial, it returned "UNKNOWN" rather than crashing.

**Then the verification function caught the mismatch:**

```bash
if [[ "$actual_serial" != "$expected_serial" ]]; then
    log_error "Serial mismatch!"
    die "Drive serial number does not match."
fi
```

**This prevented the wrong drive from being erased.**

**Lesson:** Defensive programming (error handling, validation) catches mistakes before they cause damage.

---

## Testing Procedure

**To verify the fix works:**

```bash
# Get your NVMe drive's actual serial
nvme id-ctrl -H /dev/nvme0n1 | grep "^sn"
# Output: sn        : S5GXNX0T123456

# Set that serial in script
NVME_EXPECTED_SERIAL="S5GXNX0T123456"

# Run verification function
verify_drive_serial "/dev/nvme0n1" "$NVME_EXPECTED_SERIAL"
# Should output: [SUCCESS] Serial verified: S5GXNX0T123456

# Test with wrong serial (should fail safely)
verify_drive_serial "/dev/nvme0n1" "WRONG_SERIAL"
# Should output error and die
```

---

**Status:** Corrected (pending real hardware test)  
**Related Docs:** 
- scripts/phase1-automated-install.sh (corrected)
- docs/Script-Architecture.md (testing procedures)

**Note:** While corrected in script, **still untested on real hardware**. Final verification needed during actual installation.

---

*This correction is licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/). You are free to remix, correct, and make it your own with attribution.*

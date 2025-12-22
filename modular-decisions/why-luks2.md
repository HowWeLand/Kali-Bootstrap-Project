# Decision: Encryption Strategy (LUKS2)

## TL;DR

**Choice:** LUKS2 with Argon2id, passphrase + encrypted USB keyfile, detached header backup.

**Why:** Standard Linux FDE, hardware-agnostic, well-audited, strong offline attack resistance. Deniability is explicitly a non-goal.

---

## Why Deniability Doesn't Matter

This section draws heavily from the [cryptsetup FAQ](https://gitlab.com/cryptsetup/cryptsetup/-/blob/main/FAQ.md) (Section 5.18), which provides the definitive explanation.

### The Core Argument

From the cryptsetup FAQ (Arno Wagner):

> Why should "I do not have a hidden partition" be any more plausible than "I forgot my crypto key" or "I wiped that partition with random data, nothing in there"? I do not see any reason.

### The Two Scenarios

**Scenario A: They cannot force you to reveal the key**
→ Simply don't. No deniability needed.

**Scenario B: They CAN force you (legal compulsion, physical coercion)**
→ They don't need to *prove* you have encrypted data. If they have the power to compel, they have the power to act on suspicion alone.

> "The situation will allow them to waterboard/lock-up/deport you anyways, regardless of how 'plausible' your deniability is."

### Hidden Partitions Aren't Hidden

The FAQ identifies two technical approaches, both flawed:

1. **Smaller filesystem in larger container** - The mismatch between container size and filesystem size is "glaringly obvious and can be detected in an automated fashion."

2. **Hidden data in filesystem free space** - Requires never mounting the outer filesystem read-write, or you risk overwriting hidden data. This usage pattern itself is suspicious.

### Environmental Leakage

Even if the crypto is perfect, real-world usage creates evidence:
- Shell history showing cryptsetup commands
- System logs
- Backup software configurations
- Application recent-file lists
- Browser history about encryption tools

Bruce Schneier's research on TrueCrypt and Deniable File Systems documents how these "environment cues" defeat deniability in practice.

### The Practical Reality

If your threat model requires deniability, you likely need:
- Air-gapped machines
- Tails/amnesic OS for every session
- No persistent storage whatsoever
- Operational security far beyond what disk encryption provides

**For this project:** We assume the threat is unauthorized access to data at rest (theft, seizure, forensic analysis of powered-off device). Strong encryption defeats this. Deniability is theater that adds complexity without meaningful protection.

### Reference

Full discussion: [cryptsetup FAQ Section 5.18](https://gitlab.com/cryptsetup/cryptsetup/-/blob/main/FAQ.md)

---

## Encryption Options Compared

| Feature | LUKS2 | LUKS1 | VeraCrypt | Plain dm-crypt |
|---------|-------|-------|-----------|----------------|
| **Header** | Visible (JSON metadata) | Visible (binary) | Optional hidden | None |
| **KDF** | Argon2id (default) | PBKDF2 | PBKDF2 | N/A |
| **Memory-hard** | Yes | No | No | N/A |
| **Multiple keyslots** | Yes (32) | Yes (8) | Limited | No |
| **Integrity** | Optional (AEAD) | No | No | No |
| **Linux native** | Yes | Yes | Requires userspace | Yes |
| **Boot support** | GRUB, systemd | GRUB, systemd | Limited | Manual |
| **Deniability** | No | No | Yes (hidden volumes) | Possible |

---

## Why LUKS2

### Case FOR LUKS2

**1. Argon2id KDF (Memory-Hard)**

LUKS1 uses PBKDF2, which is vulnerable to GPU/ASIC acceleration. LUKS2 defaults to Argon2id:

```bash
# LUKS2 default (memory-hard, resists GPU attacks)
cryptsetup luksFormat --type luks2 /dev/disk/by-partlabel/LUKS_ROOT

# Verify Argon2id is in use
cryptsetup luksDump /dev/disk/by-partlabel/LUKS_ROOT | grep -i argon
# PBKDF:      argon2id
```

Argon2id parameters can be tuned:
- `--pbkdf-memory` - Memory cost in KB (default: 1GB)
- `--pbkdf-parallel` - Parallelism (default: 4)
- `--iter-time` - Target unlock time in ms (default: 2000)

**2. Token Support**

LUKS2 supports hardware tokens (FIDO2, TPM2, PKCS#11) via the token subsystem:

```bash
# Enroll a FIDO2 key (YubiKey, etc.)
systemd-cryptenroll --fido2-device=auto /dev/disk/by-partlabel/LUKS_ROOT
```

**3. More Keyslots**

LUKS2 supports 32 keyslots vs LUKS1's 8. Useful for:
- Multiple users
- Recovery keys
- Automated unlock tokens
- Key rotation without downtime

**4. JSON Metadata**

Human-readable, extensible metadata format. Easier debugging:

```bash
cryptsetup luksDump --dump-json-metadata /dev/disk/by-partlabel/LUKS_ROOT | jq .
```

**5. Integrity Protection (Optional)**

LUKS2 can use authenticated encryption (AEAD) to detect tampering:

```bash
# With integrity checking (slower, more secure)
cryptsetup luksFormat --type luks2 --integrity hmac-sha256 /dev/disk/by-partlabel/LUKS_ROOT
```

### Case AGAINST LUKS2

**1. GRUB Support Limitations**

GRUB's LUKS2 support is newer and has restrictions:
- Only PBKDF2 supported in GRUB (not Argon2id)
- Workaround: Use LUKS1 for /boot, LUKS2 for root

**2. Slightly Larger Header**

LUKS2 header is typically 16MB vs LUKS1's 2MB. Irrelevant for modern disks.

**3. Newer = Less Battle-Tested**

LUKS1 has been around since 2004. LUKS2 since 2017. However, LUKS2 is now the default in all major distributions.

---

## Alternatives Considered

### Plain dm-crypt (No Header)

```bash
cryptsetup open --type plain /dev/sdX secret
```

**Pros:**
- No visible header (looks like random data)
- Simple

**Cons:**
- No keyslots (one password only)
- No KDF metadata (must remember cipher, hash, etc.)
- No key rotation without re-encryption
- Must specify all parameters manually every time

**Verdict:** Too fragile for system encryption. Acceptable for specific "looks like wiped disk" use cases.

### VeraCrypt

**Pros:**
- Hidden volume support
- Cross-platform (Windows/Mac/Linux)
- Deniability features

**Cons:**
- Not native Linux (requires userspace daemon)
- Uses PBKDF2 (no memory-hard KDF)
- Complex boot setup
- Development concerns after TrueCrypt discontinuation

**Verdict:** Use if you need Windows compatibility. Otherwise, LUKS2 is superior on Linux.

### LUKS1

**Pros:**
- Maximum compatibility
- Simpler header structure
- Full GRUB support including Argon2id... wait, no.

**Cons:**
- PBKDF2 only (GPU-acceleratable)
- Fewer keyslots (8)
- Binary metadata (harder to inspect)

**Verdict:** Only use if you have specific GRUB/legacy requirements. Otherwise, LUKS2.

---

## For This Project Specifically

### Configuration Chosen

```bash
# Create LUKS2 container with Argon2id
cryptsetup luksFormat \
    --type luks2 \
    --cipher aes-xts-plain64 \
    --key-size 512 \
    --hash sha512 \
    --pbkdf argon2id \
    --pbkdf-memory 1048576 \
    --pbkdf-parallel 4 \
    --iter-time 3000 \
    --label CRYPT_ROOT \
    /dev/disk/by-partlabel/LUKS_ROOT
```

**Parameters explained:**
- `aes-xts-plain64` - AES-256 in XTS mode (standard for FDE)
- `--key-size 512` - 512 bits for XTS = 256-bit AES (XTS splits key)
- `--hash sha512` - Hash for key derivation
- `--pbkdf argon2id` - Memory-hard KDF
- `--pbkdf-memory 1048576` - 1GB memory cost
- `--iter-time 3000` - Target 3 second unlock time

### Keyfile Strategy

**Two-factor unlock:**
1. Passphrase (something you know)
2. Encrypted keyfile on USB (something you have)

```bash
# Keyslot 0: Passphrase (created during luksFormat)
# Keyslot 1: USB keyfile
cryptsetup luksAddKey \
    --key-slot 1 \
    /dev/disk/by-partlabel/LUKS_ROOT \
    /mnt/usb/keys/root.key
```

See: [Keyfile Strategy Document](../keyfile-strategy.md) (TODO)

### Header Backup (CRITICAL)

```bash
# IMMEDIATELY after luksFormat, BEFORE adding keyfiles
cryptsetup luksHeaderBackup \
    /dev/disk/by-partlabel/LUKS_ROOT \
    --header-backup-file /mnt/usb/backups/luks-header-$(date +%Y%m%d).img

# Verify backup is valid
cryptsetup luksHeaderRestore \
    --header-backup-file /mnt/usb/backups/luks-header-*.img \
    --test \
    /dev/disk/by-partlabel/LUKS_ROOT
```

**Store header backups:**
- On the USB keyfile drive
- In a separate secure location (safe deposit box, etc.)
- NOT on the encrypted drive itself

---

## Threat Model Reminder

**This encryption protects against:**
- ✓ Physical seizure of powered-off device
- ✓ Theft of laptop/drive
- ✓ Offline brute-force attacks
- ✓ Forensic analysis of disk at rest

**This encryption does NOT protect against:**
- ✗ Attacks while system is running (memory, DMA, cold boot)
- ✗ Evil maid attacks (without Secure Boot + measured boot)
- ✗ Keyloggers / shoulder surfing
- ✗ Compelled disclosure (legal or otherwise)
- ✗ Rubber hose cryptanalysis

---

## How to Swap This Out

### Migrating from LUKS1 to LUKS2

```bash
# In-place conversion (non-destructive)
cryptsetup convert --type luks2 /dev/disk/by-partlabel/LUKS_ROOT

# Verify
cryptsetup luksDump /dev/disk/by-partlabel/LUKS_ROOT | head -5
```

### Migrating to VeraCrypt

Requires full re-encryption:
1. Backup all data
2. Create VeraCrypt volume
3. Restore data
4. Reconfigure bootloader (complex)

### Adding Hardware Token (FIDO2/YubiKey)

```bash
# With systemd-cryptenroll (systemd 248+)
systemd-cryptenroll --fido2-device=auto /dev/disk/by-partlabel/LUKS_ROOT

# Update /etc/crypttab
crypt_root UUID=... none luks,fido2-device=auto
```

### Adding TPM2 Unlock

```bash
# Enroll TPM2 (binds to current PCR state)
systemd-cryptenroll --tpm2-device=auto /dev/disk/by-partlabel/LUKS_ROOT

# Update /etc/crypttab  
crypt_root UUID=... none luks,tpm2-device=auto
```

**Warning:** TPM unlock without additional factors means anyone who boots your hardware can access your data. Consider TPM + PIN or TPM + FIDO2.

---

## References

- [cryptsetup FAQ](https://gitlab.com/cryptsetup/cryptsetup/-/blob/main/FAQ.md) - Authoritative source, especially Section 5.18 on deniability
- [LUKS2 On-Disk Format Specification](https://gitlab.com/cryptsetup/LUKS2-docs)
- [Arch Wiki: dm-crypt](https://wiki.archlinux.org/title/Dm-crypt)
- [Argon2 paper](https://github.com/P-H-C/phc-winner-argon2)

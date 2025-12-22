# Init System Decision Matrix: systemd vs OpenRC

**Purpose:** Help you choose the right init system for your Kali installation based on your specific use case and requirements.

---

## Executive Summary

**Use OpenRC if:**
- Multi-drive encrypted BTRFS setup
- Want explicit, understandable service dependencies
- Need custom runlevels for different operational modes
- Prefer simpler, more predictable boot process
- Don't need GNOME desktop

**Use systemd if:**
- Single drive installation
- Simple partition layout
- Want GNOME desktop environment
- Prefer Kali's default configuration
- Following standard tutorials/documentation

---

## The Core Difference

### systemd Philosophy
**"We'll figure it out for you"**
- Implicit dependency resolution
- Complex dependency graphs
- Tries to be smart about service ordering
- One tool does everything (init, scheduling, logging, etc.)

### OpenRC Philosophy  
**"You declare it, we'll do it"**
- Explicit dependency declarations
- Clear, readable service dependencies
- Predictable service ordering
- Does one thing well (init and service management)

---

## Technical Comparison

### Dependency Management

**systemd:**
```ini
[Unit]
After=network.target network-online.target
Wants=network-online.target
Requires=cryptsetup.target
```

**Problems:**
- What does this actually mean?
- When does it start?
- What if network-online.target fails?
- Implicit dependencies hidden in target definitions

**OpenRC:**
```bash
depend() {
    need net
    use dns
    after cryptdisks
}
```

**Benefits:**
- Crystal clear what's required
- Explicit failure modes
- Easy to debug
- Read the service file, understand the dependencies

### Service States and Runlevels

**systemd Targets:**
```
multi-user.target
graphical.target
rescue.target
```

**Problems:**
- What services are in each target? Check systemctl.
- Complex target interdependencies
- Hard to create custom operational modes
- Switching between states is opaque

**OpenRC Runlevels:**
```
boot        # System initialization
default     # Normal operation
shutdown    # Clean shutdown
[custom]    # Your own defined states
```

**Benefits:**
```bash
# See exactly what's in each runlevel
rc-status -a

# Create custom runlevel for malware analysis
rc-update add netfilter lab
rc-update del network lab

# Switch to lab mode (isolated, no network)
rc lab

# Back to default
rc default
```

**Clear state transitions, explicit service management.**

### Boot Process Transparency

**systemd:**
```bash
systemctl status
# 187 units loaded
# Good luck understanding the dependency graph

journalctl -xb
# Wall of logs
# Find the actual problem in the noise
```

**OpenRC:**
```bash
rc-status
# Shows exactly what's running in current runlevel

rc-service some-service start
# Explicit: "service 'network' needed by 'some-service' is not running"

# Dependency tree is readable
cat /etc/init.d/some-service
```

### Debugging

**systemd - When Mount Fails:**
```bash
systemctl status mnt-foo.mount
# Failed to mount
# Check dependencies...
systemctl list-dependencies mnt-foo.mount
# Circular dependencies detected
# After=cryptsetup.target but Before=local-fs.target
# Good luck
```

**OpenRC - When Mount Fails:**
```bash
rc-service localmount start
# Reads /etc/fstab in order
# Mounts sequentially
# Fails with clear error on specific mount
# Check /etc/fstab line X
```

---

## The Multi-Drive Encrypted BTRFS Problem

### Why systemd Fails

**The scenario:**
- Multiple LUKS2 encrypted drives
- BTRFS subvolumes across different physical drives
- Root on NVMe, home on SATA
- Subvolumes need specific mount order

**What happens with systemd:**
1. cryptsetup unlocks both drives ✓
2. Root subvolume mounts ✓
3. systemd tries to "optimize" remaining mounts
4. Dependency resolver gets confused by cross-drive subvolumes
5. Mount ordering breaks
6. Emergency shell

**Why it breaks:**
- systemd assumes it's smarter than /etc/fstab order
- Dependency resolver can't handle cross-drive BTRFS subvolumes
- "After=" and "Requires=" don't work reliably for complex mounts
- No way to force strict sequential mounting

**Attempted fixes that failed:**
- Mount unit files with explicit dependencies
- x-systemd.* mount options
- cryptsetup.target manipulation
- Custom systemd mount ordering

**None worked reliably.**

### Why OpenRC Works

**Same scenario with OpenRC:**
1. `cryptdisks-early` unlocks drives
2. `mountall.sh` reads /etc/fstab
3. Mounts in order, top to bottom
4. Respects dependencies
5. Just works

**Why it works:**
- Simple, predictable behavior
- Reads /etc/fstab sequentially
- No "optimization" that breaks things
- If fstab says mount A then B, it mounts A then B

**The lesson:**
For complex multi-drive encrypted setups, simpler is better.

---

## Desktop Environment Compatibility

### GNOME

**Status:** Requires systemd
- Uses systemd-logind for session management
- Many GNOME components assume systemd presence
- Possible to patch, but fragile

**Verdict:** If you need GNOME, use systemd (or use single-drive setup)

### XFCE

**Status:** Works perfectly with OpenRC
- Uses elogind for session management (systemd-logind replacement)
- No systemd dependencies
- Kali's XFCE configuration is excellent

**Verdict:** Recommended for OpenRC setups

### KDE Plasma

**Status:** Works with OpenRC
- Supports elogind
- No hard systemd requirements
- More customization than XFCE (can be good or bad)

**Verdict:** Compatible, but XFCE is simpler

### Window Managers (i3, bspwm, etc.)

**Status:** Work perfectly with OpenRC
- Minimal dependencies
- No session manager requirements
- Can use elogind if needed

**Verdict:** Excellent choice for OpenRC

---

## Use Case Decision Tree

### Scenario 1: Single Drive, Want Kali Defaults

**Recommendation:** systemd
- Simpler initial setup
- Follows Kali documentation
- GNOME available if desired
- Standard tutorials apply

**Tradeoffs:**
- Less control over boot process
- Dependency resolution is opaque
- Harder to create custom operational modes

### Scenario 2: Multi-Drive Encrypted BTRFS

**Recommendation:** OpenRC (REQUIRED)
- systemd mount ordering will fail
- OpenRC handles complex mounts correctly
- Explicit dependencies help debugging

**Tradeoffs:**
- GNOME not available (use XFCE)
- Slightly more manual service configuration
- Some tutorials assume systemd

### Scenario 3: Pen-Testing Workstation with Operational Modes

**Recommendation:** OpenRC
- Create runlevels for different modes:
  - `default` - Normal work with network
  - `lab` - Malware analysis, network isolated
  - `demo` - Presentation mode, optimized
- Switch between modes cleanly
- Explicit service control

**Tradeoffs:**
- Need to understand runlevels
- Create custom service files for some tools
- Less "magical" automation

### Scenario 4: Learning/Educational

**Recommendation:** OpenRC
- Explicit dependencies teach how boot works
- Runlevels are understandable concepts
- Service files are readable shell scripts
- Better for understanding Linux init

**Tradeoffs:**
- Need to invest time learning OpenRC
- Gentoo docs are better than Debian docs
- Smaller community than systemd

---

## Service Management Comparison

### Starting Services

**systemd:**
```bash
systemctl start service-name
systemctl enable service-name
systemctl status service-name
```

**OpenRC:**
```bash
rc-service service-name start
rc-update add service-name default
rc-service service-name status
```

**Similarity:** Nearly identical workflow

### Creating Custom Services

**systemd:**
```ini
# /etc/systemd/system/my-service.service
[Unit]
Description=My Service
After=network.target

[Service]
ExecStart=/usr/local/bin/my-service
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

**OpenRC:**
```bash
# /etc/init.d/my-service
#!/sbin/openrc-run

description="My Service"

depend() {
    need net
}

start() {
    ebegin "Starting my-service"
    start-stop-daemon --start --exec /usr/local/bin/my-service
    eend $?
}
```

**Difference:** OpenRC is a shell script, systemd is a config file

**Benefits of OpenRC approach:**
- Can use full shell scripting
- Easier to add custom logic
- Readable as a script

### Viewing System State

**systemd:**
```bash
systemctl list-units
systemctl list-dependencies
systemctl list-timers
```

**OpenRC:**
```bash
rc-status
rc-update show
# For timers: use cron/anacron separately
```

**Difference:** OpenRC separates concerns (init vs scheduling)

---

## Migration Path

### Starting Fresh: Use OpenRC from Bootstrap

**Recommended:**
```bash
debootstrap --variant=minbase \
  --include=kali-archive-keyring,sysvinit-core,openrc,elogind \
  --arch=amd64 kali-rolling /mnt http://http.kali.org/kali
```

**Why:**
- Clean installation
- No conversion needed
- Simpler than systemd → OpenRC conversion

### Already Have systemd: Convert to OpenRC

**Possible but more complex**

**See:** `docs/openrc-conversion-from-systemd.md` for detailed procedure

**When to convert:**
- Hit systemd mount ordering issues
- Want OpenRC benefits
- Don't want to reinstall

---

## Scheduling and Timers

### systemd Approach

**Built-in timers:**
```bash
systemctl list-timers
# Shows systemd timer units
```

**Pros:** Integrated with init system  
**Cons:** Yet another systemd-ism to learn

### OpenRC Approach

**Use traditional cron:**
```bash
apt install cron anacron
rc-update add cron default
```

**Pros:** 
- Separation of concerns
- Standard cron syntax
- Works with any init system
- 50 years of proven stability

**Cons:**
- Separate daemon (but that's a feature)

**For laptops:** Use `anacron` to catch missed jobs when system sleeps

---

## Performance Comparison

### Boot Time

**systemd:**
- Parallel service startup
- Usually faster on simple systems
- Can be slower with complex dependencies

**OpenRC:**
- Can do parallel startup (`rc_parallel="YES"`)
- Sequential by default (more predictable)
- Similar speeds in practice

**Verdict:** Negligible difference for desktop/laptop use

### Resource Usage

**systemd:**
- More processes running
- Higher memory footprint
- Many systemd-* daemons

**OpenRC:**
- Simpler process tree
- Lower memory usage
- Fewer background services

**Verdict:** OpenRC is lighter, but difference is small on modern hardware

---

## Community and Documentation

### systemd

**Pros:**
- Widely adopted
- More tutorials assume systemd
- Larger community

**Cons:**
- Documentation scattered
- Complex to understand fully
- Much debate/controversy

### OpenRC

**Pros:**
- Gentoo documentation is excellent
- Simpler to understand
- Service files are readable

**Cons:**
- Smaller community
- Fewer Debian/Kali specific guides
- Need to adapt Gentoo docs

**Resources:**
- Gentoo Wiki: https://wiki.gentoo.org/wiki/OpenRC
- OpenRC GitLab: https://gitlab.com/openrc/openrc
- Gentoo ebuilds: Source for service file examples

---

## Making Your Decision

### Questions to Ask

1. **Do you have multiple encrypted drives with BTRFS?**
   - Yes → OpenRC (systemd will fail)
   - No → Either works

2. **Do you need GNOME desktop?**
   - Yes → systemd
   - No → Either works

3. **Do you want custom operational modes (runlevels)?**
   - Yes → OpenRC (much easier)
   - No → Either works

4. **Do you want to understand your boot process?**
   - Yes → OpenRC (explicit dependencies)
   - No → systemd (automatic)

5. **Are you following standard Kali tutorials?**
   - Yes → systemd (tutorials assume it)
   - No → Either works

### The Recommendation Matrix

| Use Case | Drives | Desktop | Recommendation |
|----------|--------|---------|----------------|
| Standard Kali | Single | GNOME | systemd |
| Pen-testing workstation | Single | XFCE/KDE | Either |
| Multi-drive encrypted | Multiple | XFCE | **OpenRC** |
| Malware analysis lab | Multiple | Any | **OpenRC** |
| Learning/Educational | Any | Any | OpenRC |
| Quick install | Single | Any | systemd |

---

## Conversion Complexity

### systemd → OpenRC

**Difficulty:** Medium
- Requires chroot from live environment
- Force package installation
- Rebuild initramfs
- Some trial and error

**Time:** 1-2 hours  
**See:** `docs/openrc-conversion-from-systemd.md`

### OpenRC → systemd

**Difficulty:** Easy
- Standard package installation
- Let systemd take over
- Regenerate initramfs

**Time:** 30 minutes

**Note:** Why would you go back? But it's easier than the other direction.

---

## Summary

### systemd Strengths
- Default in Kali/Debian
- GNOME support
- Integrated timers/scheduling
- More tutorials available

### systemd Weaknesses
- Fails with complex multi-drive encrypted setups
- Opaque dependency resolution
- Harder to debug
- Does too many things

### OpenRC Strengths
- Explicit, clear dependencies
- Handles complex mounts correctly
- Easy to create custom runlevels
- Simpler, more understandable
- Separation of concerns

### OpenRC Weaknesses
- No GNOME support
- Smaller community
- Fewer tutorials
- Requires cron separately

### The Bottom Line

**For the multi-drive encrypted BTRFS setup documented in this project:**

**OpenRC is not just recommended, it's necessary.** systemd's mount ordering cannot handle this scenario reliably.

**For simpler setups:** Either works fine, choose based on preference.

---

**Document Status:** Complete  
**Based on:** Real-world testing, systemd failure, OpenRC success

---

*This documentation is licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/). You are free to remix, correct, and make it your own with attribution.*

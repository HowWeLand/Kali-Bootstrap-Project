# Decision: Desktop Environment

## TL;DR

**Options:** Xfce (Kali default), KDE Plasma, GNOME, i3/Sway, or headless (no DE).

**This is a placeholder** - full decision document to be written during Phase 4 breakdown.

---

## Available Options

| Desktop | Metapackage | RAM Usage | Notes |
|---------|-------------|-----------|-------|
| **Xfce** | `kali-desktop-xfce` | ~400MB | Kali default, lightweight, familiar |
| **KDE Plasma** | `kali-desktop-kde` | ~600-800MB | Feature-rich, highly customizable, modern |
| **GNOME** | `kali-desktop-gnome` | ~700MB | Polished, opinionated, touchscreen-friendly |
| **i3** | `kali-desktop-i3` | ~100MB | Tiling WM, keyboard-driven, minimal |
| **MATE** | `kali-desktop-mate` | ~350MB | GNOME 2 fork, traditional layout |
| **LXDE** | `kali-desktop-lxde` | ~200MB | Ultra-lightweight |
| **Enlightenment** | `kali-desktop-e17` | ~300MB | Unique aesthetic, compositing |
| **None** | (no package) | ~0MB | Headless / CLI only |

---

## Quick Comparison

### Xfce (Kali Default)
- **Pros:** Lightweight, stable, familiar to Kali users, good documentation
- **Cons:** Less modern appearance, fewer effects, some rough edges
- **Best for:** Resource-constrained systems, VM use, traditional desktop users

### KDE Plasma
- **Pros:** Extremely customizable, modern features (Activities, KDE Connect), polished
- **Cons:** Heavier resource usage, more complex, occasional integration issues
- **Best for:** Users who want customization, touchpad gestures, modern UX

### GNOME
- **Pros:** Polished UX, consistent design language, touchscreen support, Wayland-first
- **Cons:** Opinionated (limited customization without extensions), heavier
- **Best for:** Users who prefer GNOME workflow, touchscreen devices

### i3 / Sway
- **Pros:** Minimal resource usage, keyboard-driven efficiency, scriptable
- **Cons:** Learning curve, no mouse-friendly defaults, manual configuration
- **Best for:** Power users, tiling workflow enthusiasts, minimal systems

### Headless (No Desktop)
- **Pros:** Minimal attack surface, all resources for tools, scriptable
- **Cons:** No GUI tools, steeper learning curve for some tasks
- **Best for:** Servers, automated systems, experienced CLI users

---

## Installation

```bash
# Xfce (default)
apt install kali-desktop-xfce

# KDE Plasma
apt install kali-desktop-kde

# GNOME
apt install kali-desktop-gnome

# i3 (tiling)
apt install kali-desktop-i3

# Multiple can be installed - choose at login
```

---

## Modularity Note

Desktop choice is **independent** of:
- Encryption setup (Phase 0)
- Hardening (Phase 2)
- Development tools (Phase 6)
- Security tools selection

You can:
- Start headless, add DE later
- Install multiple DEs, switch at login
- Remove DE without affecting other phases

---

## TODO

Full decision document should cover:
- [ ] Display manager options (lightdm, sddm, gdm)
- [ ] Wayland vs X11 considerations
- [ ] Kali-specific theming
- [ ] Resource benchmarks
- [ ] Tool integration (which GUIs work best with which DE)
- [ ] Multi-monitor setup differences

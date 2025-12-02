# Licensing

This repository contains multiple types of content under different licenses to support the goal: **remix, correct, make it your own.**

## Quick Reference

| Content Type | License | Location |
|--------------|---------|----------|
| Documentation (`.md` files in `/docs`, `/appendices`) | CC-BY-SA-4.0 | [Full text](licenses/CC-BY-SA-4.0.txt) |
| Scripts and tooling (`/scripts`) | MIT | [Full text](licenses/MIT.txt) |
| GPL-covered configurations | GPL-3.0-or-later | [Full text](licenses/GPL-3.0.txt) |

---

## Documentation (CC-BY-SA-4.0)

All markdown documentation files in `/docs` and `/appendices` are licensed under **Creative Commons Attribution-ShareAlike 4.0 International (CC-BY-SA-4.0)**.

**You are free to:**
- **Share** — copy and redistribute the material in any medium or format
- **Adapt** — remix, transform, and build upon the material for any purpose, even commercially

**Under these terms:**
- **Attribution** — You must give appropriate credit, provide a link to the license, and indicate if changes were made
- **ShareAlike** — If you remix, transform, or build upon the material, you must distribute your contributions under the same license
- **No additional restrictions** — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits

**Full license:** [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/)  
**Full text:** [licenses/CC-BY-SA-4.0.txt](licenses/CC-BY-SA-4.0.txt)

### Documentation Footer Template

Add this to the end of documentation files:

```markdown
---

*This documentation is licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/). You are free to remix, correct, and make it your own with attribution.*
```

---

## Scripts and Tooling (MIT)

All scripts, automation tooling, and code in `/scripts` are licensed under the **MIT License**.

**Permission is granted to:**
- Use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
- Permit persons to whom the Software is furnished to do so

**Conditions:**
- The copyright notice and permission notice must be included in all copies or substantial portions

**Full text:** [licenses/MIT.txt](licenses/MIT.txt)

### Script Header Template

Add this to the top of script files:

```bash
#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2024 [Your Name]
#
# [Brief description of what this script does]
```

For Python:
```python
#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
# Copyright (c) 2024 [Your Name]
#
# [Brief description of what this script does]
```

---

## Configuration Files

Configuration files in `/configs` may be subject to different licenses depending on the software they configure:

### MIT-Licensed Configurations

Original configuration files not derived from GPL software are **MIT licensed**.

**Header template:**
```bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2024 [Your Name]
# 
# [Description of configuration]
```

### GPL-Covered Configurations

Some configuration files are derivative works of GPL-licensed software and **must be distributed under GPL-3.0-or-later**.

This typically applies to:
- Modified versions of GPL'd example configurations
- Configurations that include substantial portions of GPL'd code
- Scripts that modify GPL software internals

**Header template:**
```bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2024 [Your Name]
#
# This configuration is a derivative work of [GPL software name]
# and is distributed under the GNU General Public License v3.0 or later.
#
# Based on: [original GPL file/source]
```

**Full text:** [licenses/GPL-3.0.txt](licenses/GPL-3.0.txt)

---

## When Is a Configuration GPL-Covered?

**General rule:** If a configuration file is merely *input* to GPL software (telling it what to do), it's usually NOT a derivative work and can be MIT licensed. If it's *based on* or *incorporates* GPL code/examples, it IS a derivative work and must be GPL.

**Examples:**

**NOT GPL-covered (MIT is fine):**
- Your custom `/etc/ssh/sshd_config` (configuration OF OpenSSH)
- Your custom firewall rules (input TO iptables)
- Your systemd unit files (configuration OF systemd)

**IS GPL-covered (must be GPL):**
- Modified version of a GPL'd example configuration that ships with the software
- Configuration that includes substantial portions of GPL'd template code
- Scripts that patch or modify GPL software source code

**When in doubt:** Mark it GPL. Being overly cautious about GPL compliance is better than violating it.

---

## Contributing

By submitting contributions to this project, you agree to license them under the project's existing licenses:

- **Documentation contributions:** CC-BY-SA-4.0
- **Script contributions:** MIT
- **GPL-covered configuration contributions:** GPL-3.0-or-later

You retain copyright to your contributions but grant permission to distribute them under these licenses.

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines.

---

## Why Multiple Licenses?

This licensing structure supports the project philosophy:

**"Remix, correct, make it your own"**

- **MIT for scripts:** Maximum freedom to adapt and integrate into any workflow
- **CC-BY-SA for documentation:** Free to remix, but improvements stay free (copyleft)
- **GPL where required:** Legal compliance with upstream software licenses

All three licenses support remixing and adaptation. The differences are in the specific freedoms and requirements of each.

---

## License Compatibility

**Can I combine content under different licenses?**

**MIT + CC-BY-SA:** Generally compatible. You can reference MIT scripts in CC-BY-SA docs.

**MIT + GPL:** Compatible. MIT can be incorporated into GPL projects (MIT is GPL-compatible).

**CC-BY-SA + GPL:** Complex. Generally compatible for documentation that references GPL code, but consult a lawyer for derivative works.

**When mixing licenses in derivative works, consult legal advice.** This overview is not legal guidance.

---

## SPDX License Identifiers

This project uses [SPDX](https://spdx.org/) identifiers for clear, machine-readable license declarations:

- `SPDX-License-Identifier: MIT`
- `SPDX-License-Identifier: CC-BY-SA-4.0`
- `SPDX-License-Identifier: GPL-3.0-or-later`

These identifiers should appear in the header of every file.

---

## Not a Lawyer (NAL)

**Disclaimer:** This licensing overview represents our understanding of these licenses and how they apply to this project. It is NOT legal advice.

**For specific legal questions about:**
- Whether you can use this project for a particular purpose
- Whether your derivative work complies with these licenses
- How these licenses interact with your organization's policies

**Please consult an actual lawyer.** NAL.

---

## Full License Texts

Complete, unmodified license texts are included in the `/licenses` directory:

- [MIT License](licenses/MIT.txt)
- [Creative Commons Attribution-ShareAlike 4.0 International](licenses/CC-BY-SA-4.0.txt)
- [GNU General Public License v3.0](licenses/GPL-3.0.txt)

These texts are included for offline reference and legal clarity. A few kilobytes of license text is worth absolute clarity about permissions and requirements.

---

**Questions about licensing?** Open an issue and we'll clarify (but remember: NAL, consult a lawyer for legal advice).

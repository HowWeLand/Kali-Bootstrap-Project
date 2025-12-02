# Threat Model

## Purpose

This document outlines the threat model assumptions for this Kali Linux installation project. Understanding what threats this setup addresses and what it cannot protect against is critical for making informed security decisions.

**Important:** This is MY threat model. Your circumstances, risks, and adversaries may differ significantly. This documentation cannot provide individualized threat modeling. Use this as a starting point to think through your own threat landscape.

## Threat Model Tiers

Security threats exist on a spectrum. Different adversaries have different capabilities, resources, and motivations. This threat model is organized into four tiers, from most capable to least.

---

## Part 1: Outside Our Scope - APT and Nation State Actors

**Adversary profile:** FBI, NSA, foreign intelligence agencies (North Korea, China, Russia, etc.), or similar well-resourced organizations targeting you specifically as an individual.

**Their capabilities:**
- Legal compulsion (warrants, subpoenas, gag orders, national security letters)
- Supply chain interdiction
- Zero-day exploits unknown to the security community
- Physical surveillance and covert access to devices
- Resources that dwarf individual defensive capabilities
- Cooperation with other agencies and international partners

**What you can do if you face this threat:**

Reflect on your life choices. This is as serious as a heart attack and has the potential to be just as fatal. Technical security measures are largely theater against adversaries at this level.

If you are actually being targeted by nation-state actors or federal agencies:
- Consult actual lawyers specializing in national security law
- Understand that technical measures have already failed if you've reached this point
- Consider whether your activities justify this level of attention

**What this documentation cannot do:**

Protect you from determined, well-resourced adversaries with legal authority or nation-state capabilities. No amount of encryption, compartmentalization, or operational security documented here will save you.

This applies equally whether we're talking about US three-letter agencies, foreign intelligence services, or dedicated security companies with nation-state-level resources investigating you as a specific target.

**Defensive posture:** None. If you are here, pray you survive what you have coming.

---

## Part 2: Regional Advanced Threats

**Adversary profile:** Well-resourced regional organizations with significant but bounded capabilities. This includes state-level law enforcement agencies, regional security firms with investigative capabilities, and well-funded corporate security departments.

**Example scale:** State police agencies in large US states operate with budgets and technical capabilities on par with some national agencies in smaller countries. For context, Illinois as an economy would rank internationally alongside countries like Belgium or France. The Illinois State Police can bring similar resources to bear within their domain, including forensic labs, digital forensics teams, and access to federal databases.

**Their capabilities:**
- Significant financial resources (comparable to small national economies)
- Legal tools within their jurisdiction
- Technical capabilities beyond individual attackers
- Access to commercial surveillance tools and forensic software
- Trained investigators and digital forensics specialists
- Ability to compel cooperation from service providers within jurisdiction

**Limitations they face:**
- Jurisdictional boundaries (crossing state lines complicates pursuit)
- Budget constraints compared to federal agencies
- Legal process requirements
- Resource prioritization (they focus on cases worth their investment)
- Less international cooperation than federal agencies

**Defensive posture:**

Don't become a priority target. This isn't about technical measures. If you're already interesting enough to justify their resource investment, technical defenses provide limited protection.

The primary defense is not engaging in activities that make you worth investigating in the first place. Technical security measures might raise the cost of investigation enough to cause deprioritization if you're a minor target among many, but they won't stop a determined investigation if you're a priority.

**What this documentation provides:**

Some technical measures that raise the cost of opportunistic or low-priority investigation. This might cause deprioritization if resources are limited and you're not a high-value target.

**What this documentation cannot provide:**

Protection if you're already a priority target for a well-resourced organization.

**Note on framing:** Law enforcement agencies are used as capability benchmarks because their resources and methods are well-documented through FOIA requests and public records. This provides clear examples of threat capabilities. This applies equally to other well-resourced adversaries: corporate security investigating IP theft, private investigators, or any organization with similar resources and bounded jurisdiction.

---

## Part 3: Motivated Local Adversaries

**Adversary profile:** Limited resources but direct access or specific motivation. This includes local law enforcement in small jurisdictions (towns of 50-100k population), individuals with technical skills but limited tools, or people with physical access to your devices.

**Their capabilities:**
- Can cause significant disruption to your life
- May have physical access opportunities
- Limited technical forensics capability
- Constrained by budget and expertise
- Motivation but not necessarily means

**What they can do:**
- Seize devices and attempt basic forensics
- Use common forensic tools if they have access
- Make your life miserable even if they can't prove anything
- Pursue you persistently if motivated

**What they likely cannot do:**
- Advanced digital forensics beyond commercial tools
- Sustained technical investigation over long periods
- Access to cutting-edge exploit frameworks
- Extended surveillance operations

**Defensive measures that work:**

Full disk encryption with strong passphrases protects against opportunistic access. If someone has physical access and limited technical capability, they cannot easily bypass LUKS encryption.

Strong passphrases, proper key management, and encrypted backups are effective at this tier.

**Critical exception - Physical Safety:**

If you are in an abusive relationship or domestic violence situation, your physical safety is infinitely more important than any data on your devices.

If you need to leave an abusive situation:
- Break the laptop or take it with you if safely possible
- Just break the laptop if taking it creates danger
- Focus on getting to safety first
- Don't let concern over data keep you in danger

**National Domestic Violence Hotline: 1-800-799-7233**

Data can be replaced. Your life cannot. If someone has physical access to you and means to harm you, no technical security measure matters. Get to safety.

**Defensive posture:**

Encryption and proper operational security are effective. Resource denial strategies may be appropriate depending on your specific circumstances.

---

## Part 4: Opportunistic Attackers

**Adversary profile:** Casual snoops or opportunistic theft. This includes someone who finds a password on a sticky note and decides to look around, laptop theft where the thief thinks they got lucky, or casual unauthorized access attempts.

**Their capabilities:**
- Physical access to powered-off device
- Basic technical knowledge
- Willingness to try obvious attacks
- No specialized tools or training

**What they can do:**
- Try to boot from USB and access files
- Attempt to reset OS passwords
- Look for obvious sensitive data
- Sell or repurpose the hardware

**What they cannot do:**
- Bypass strong encryption
- Perform forensic analysis
- Dedicate significant resources to one device
- Justify spending more effort than the device is worth

**Defensive measures that work:**

Full disk encryption stops this threat cold. Without the encryption passphrase, a powered-off device is effectively a brick. The attacker gets working hardware components but no data access.

**Effective protections:**
- LUKS encryption (powered-off device = inaccessible data)
- No passwords on sticky notes (or see resource denial below)
- Automatic screen locking when stepping away
- Strong passphrases not easily guessed from personal information

**Ineffective protections:**
- Relying only on OS login passwords (easily bypassed with physical access)
- Hiding sensitive files in obscure directories
- Trusting that "nobody would look there"
- Weak or default passwords

**Resource denial:**

The goal at this tier is making your data cost more to access than it's worth to the attacker. For opportunistic threats, any encryption is usually enough - they move on to easier targets.

For some threat scenarios in Parts 3 and 4, resource denial (making data inaccessible even to you) can be a valid defensive strategy.

Kali maintains `cryptsetup-nuke-password` in their repositories (not upstreamed to Debian due to policy reasons). This tool provides additional options for data protection strategies.

**What this documentation covers:** How to install and configure the tool (Phase 0 modular decision).

**What this documentation does NOT cover:** Plausible deniability approaches. If deniability is required for your threat model, you need to be absolutely certain your adversary won't attempt physical coercion (rubber hose cryptanalysis). Failed deniability dramatically increases suspicion and consequences.

See Kali's official documentation for `cryptsetup-nuke-password` to make your own informed decision about whether and how to use it. You will need to develop your own deployment strategy based on your specific circumstances and threat model.

**Defensive posture:**

Standard encryption and basic operational security are highly effective. The adversary will give up and move to easier targets.

---

## What This Threat Model Assumes

This documentation assumes a threat model focused on:
- Privacy from commercial surveillance and mass data collection
- Protection against opportunistic attacks and common malware
- Professional security testing and research activities
- Learning offensive security techniques in controlled environments
- Defense against motivated individuals with limited resources
- Resource denial against some physical access scenarios

This documentation does NOT assume:
- You are evading law enforcement for criminal activity
- You need protection from nation-state actors
- You require plausible deniability for your data
- You are engaging in activities that would make you a high-priority target

## Determining Your Threat Model

To determine your own threat model, ask:

1. **Who might want my data or to harm me?**
   - Random thieves? Former partners? Competitors? Government agencies?

2. **What capabilities do they have?**
   - Physical access? Technical skills? Legal authority? Budget?

3. **What are they willing to invest?**
   - Minutes? Hours? Days? Unlimited resources?

4. **What are the consequences if they succeed?**
   - Embarrassment? Financial loss? Physical danger? Legal jeopardy?

5. **Am I in immediate physical danger?**
   - If yes, technical security is secondary to physical safety

Your threat model determines which security measures are appropriate and which are security theater for your specific situation.

## Using This Threat Model

**If your adversaries are primarily Part 4 (opportunistic):**
- Focus on basic encryption and strong passphrases
- Standard operational security practices are sufficient
- This documentation provides appropriate protections

**If your adversaries are primarily Part 3 (motivated local):**
- Encryption and careful operational security are important
- Consider resource denial strategies for specific scenarios
- Physical security of devices matters
- This documentation provides relevant protections with caveats

**If your adversaries are Part 2 (regional advanced):**
- Technical measures help but aren't sufficient alone
- Don't become a priority target is your primary defense
- This documentation provides some protection for low-priority scenarios
- Consult legal and security professionals for your specific situation

**If your adversaries are Part 1 (nation-state/APT):**
- This documentation cannot help you
- Technical security measures are insufficient
- Seek professional legal counsel immediately
- Seriously reconsider your activities and choices

## Updates and Revisions

Threat landscapes change. New capabilities emerge, old assumptions break, and your personal circumstances evolve. Review your threat model periodically and adjust your security posture accordingly.

This threat model document will be updated as new information becomes available or as the security landscape shifts.

---

**Document Status:** Living document. Subject to updates as threat landscape evolves.

---

*This documentation is licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/). You are free to remix, correct, and make it your own with attribution.*


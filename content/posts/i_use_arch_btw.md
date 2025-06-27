+++
title = "I use Arch, btw."
description = "A living collection of field notes from a journey using Arch Linux as a daily driver for both development and gaming."
date = 2025-06-08
updated = 2025-06-08
draft = false

[taxonomies]
categories = ["linux"] 
tags = [
    "linux",
    "arch-linux",
    "field-notes"
]
+++

This is a living document, a collection of field notes from my experience using Arch Linux as my daily driver for software development and gaming. Forget the abstract philosophy; this is about the practical realities—the setup, the software that works, the problems I encounter, and how I solve them.

## June 7, 2025

The journey began today. I used the official archinstall script to lay down the system's foundation, choosing a familiar and reliable stack: KDE Plasma for the desktop environment, GRUB as the bootloader, and a simple ext4 filesystem. For my RTX 3080 Ti, I specifically opted for the ```nvidia-open``` kernel modules. Once the base system was up, I pulled in my essential software: Firefox, Neovim, Steam, and of course, yay for access to the Arch User Repository. The result is a clean, snappy system. Everything is working as expected and feels incredibly responsive.

## June 8, 2025

With the base system stable, it was time for the first real test: non-native gaming. I added the Battle.net installer executable as a "Non-Steam Game" in my library and enabled the Proton compatibility layer. It took a bit of experimentation, but forcing it to use ```Proton 10.0-1 (beta)``` did the trick. The client installed perfectly, and from there, I was able to download and launch World of Warcraft without a hitch. This was a huge win and a great confidence booster for using Arch as a primary gaming OS.

## June 27, 2025

The experiment has reached a turning point. After about a month, the friction of using Arch for gaming has led me back to Windows. The core issue wasn't a single, catastrophic failure, but rather a death by a thousand cuts. The biggest issue was unreliability after periods of inactivity. I'd come home on Friday, hoping for a quick hour or two of gaming, only to spend that time troubleshooting. An update to drivers, Proton, or just solving issues due to a recent game update during the week would silently break my previously working setup. Compounding this were persistent, nagging audio issues that would disappear just as fast as they showed up.

For now, the "it just works" reliability of Windows for gaming outweights the satisfaction of running everything on Linux. I don't recommend Linux for gaming at the moment unless you have the time and desire to be a constant system administrator. While I'll likely re-approach this in the future, the dream of a single OS for everything is on hold.
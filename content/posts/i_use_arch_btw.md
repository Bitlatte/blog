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

# Introduction

This is a living document, a collection of field notes from my experience using Arch Linux as my daily driver for software development and gaming. Forget the abstract philosophy; this is about the practical realities—the setup, the software that works, the problems I encounter, and how I solve them.

# Field Notes

This is the running log of my system. Updates, fixes, and discoveries will be added here as they happen.

## June 7, 2025

The journey began today. I used the official archinstall script to lay down the system's foundation, choosing a familiar and reliable stack: KDE Plasma for the desktop environment, GRUB as the bootloader, and a simple ext4 filesystem. For my GeForce 3080 Ti, I specifically opted for the nvidia-open kernel modules. Once the base system was up, I pulled in my essential software: Firefox, Neovim, Steam, and of course, yay for access to the Arch User Repository. The result is a clean, snappy system. Everything is working as expected and feels incredibly responsive.

## June 8, 2025

With the base system stable, it was time for the first real test: non-native gaming. I added the Battle.net installer executable as a "Non-Steam Game" in my library and enabled the Proton compatibility layer. It took a bit of experimentation, but forcing it to use Proton 10.0-1 (beta) did the trick. The client installed perfectly, and from there, I was able to download and launch World of Warcraft without a hitch. This was a huge win and a great confidence booster for using Arch as a primary gaming OS.
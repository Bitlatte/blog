+++
title = "My Self-Hosted Media Setup"
description = "A detailed guide on my journey to replace commercial streaming services by building a two-server self-hosted media setup using the *arr stack, Jellyfin, Proxmox, TrueNAS, and Docker, focusing on cost savings and media control."
date = 2025-05-25
updated = 2025-05-25
draft = false

[taxonomies]
categories = ["Homelab"] 
tags = [
    "Self-Hosting",
    "Jellyfin",
    "*arr Stack",
    "Media Server",
    "Docker"
]
+++

## Introduction

I moved to a self-hosted media solution using the *arr stack and Jellyfin primarily for cost savings and better media access. Managing multiple streaming subscriptions was expensive, and content availability was unreliable – shows and movies often disappeared or weren't available where I expected. My goal was to consolidate our media into a single, easily accessible library, simplify viewing for my family (my wife finds searching one application, rather than five, much easier), and learn new technical skills in the process. This post outlines how I achieved this, using Usenet as a more economical source for content.

---

## Part 2: The Building Blocks - My Hardware and Software

My self-hosted media environment is built upon a two-server setup, a decision driven by the principle of **separation of concerns** and the desire for a dedicated Network Attached Storage (NAS) solution. I'm a strong advocate for **open-source software**, which heavily influenced my choices for operating systems and hypervisors.

### Server 1: The 'Brains' & Application Hub - Dell R710

* **Role:** This server is dedicated to running the automation suite (*arr stack), download client, and reverse proxy.
* **Hypervisor:** Proxmox VE. I chose Proxmox for its robust, open-source virtualization capabilities.
* **Virtual Machine (VM) for Applications:** An Ubuntu Server VM is the heart of my application hosting.
    * **VM Resources:** Allocated 6 vCPUs and 16GB of RAM. While this is likely overkill for the current workload, it provides ample room for future projects and services.
    * **Containerization:** All applications within this VM are run using Docker for efficient management and isolation.
* **Key Specifications:**
    * **CPU:** 2x Intel Xeon X5650
    * **RAM:** 64GB DDR3
* **Dockerized Applications:**
    * **Media Automation:** Radarr (movies), Sonarr (TV shows), Lidarr (music), Readarr (books/magazines)
    * **Management & Utilities:** Prowlarr (indexer management), Bazarr (subtitles), Profilarr (*arr stack profile synchronization)
    * **Download Client:** SABnzbd (for Usenet)
    * **Reverse Proxy:** Caddy (for secure and simplified remote access)

![Dell R710 Server in Rack](/img/my_self_hosted_media_setup/DELL_R710.jpg)

### Server 2: The 'Media Fortress' & Streaming Powerhouse - Supermicro 6028U-TR4T+

* **Role:** This server acts as my dedicated NAS and powers the media streaming experience via Jellyfin, crucially handling hardware transcoding.
* **Operating System:** TrueNAS Scale. Selected for its open-source nature and particularly for its excellent ZFS filesystem capabilities, which provide robust data integrity and storage management.
* **Key Specifications:**
    * **CPU:** 2x Intel Xeon E5-2620 v4
    * **RAM:** 64GB DDR4
* **Storage Array:**
    * **Drives:** 4x 4TB Seagate Exos HDDs
    * **Configuration:** RAIDZ1 (offering a balance of ~12TB usable space and single-drive failure redundancy)
* **Media Server Application:** Jellyfin (installed as a TrueNAS Scale App). Jellyfin was placed on this server primarily due to the ease of installing and passing through an AMD RX 590 GPU, enabling efficient hardware transcoding. The Supermicro motherboard provided the necessary GPU power pins, which my Dell R710 motherboard lacked.
* **Transcoding:** AMD RX 590 GPU

![Supermicro Server in Rack](/img/my_self_hosted_media_setup/SUPERMICRO.jpg)

### Usenet Infrastructure

* **Indexers:** To ensure comprehensive media discovery, I utilize three Usenet indexers: NZBGeek, NZBPlanet, and ALTHub.
* **(Implicit) Usenet Provider(s):** Access to Usenet is managed via SABnzbd and requires a separate Usenet provider subscription.

---

## Part 3: Weaving it All Together - The Setup Process

With the hardware and core software choices made, the next step was configuration. My approach was to build a solid foundation with networking and storage, then layer on the applications.

### 1. Network Foundation: Link Aggregation

Before diving into software, I optimized my server connectivity.
* **Dell R710 (Application Server):** Configured a 4-port Link Aggregation Control Protocol (LACP) bond.
* **Supermicro (NAS & Jellyfin Server):** Configured an 8-port LACP bond.
My rationale was straightforward: I had the physical ports available, and link aggregation offers increased bandwidth potential and some redundancy for the network connections to these critical machines.

### 2. OS & Hypervisor Installation: Keeping it Standard

The installation of Proxmox VE on the Dell R710 and TrueNAS Scale on the Supermicro was relatively standard. Both offer excellent documentation and straightforward installation processes.

### 3. Application Deployment on the R710: Docker, Docker Compose, and NFS

The bulk of the media management applications run within a Dockerized environment on an Ubuntu Server VM hosted on Proxmox.
* **Docker Compose is Key:** I utilized Docker Compose to define and manage all the application containers (*arrs, SABnzbd, Caddy, etc.). This makes deployment, updates, and configuration management significantly easier.
* **Following Best Practices:** For container configurations, I heavily referenced the [trash-guides.info](https://trash-guides.info) website. Their guides are an invaluable resource for setting up a robust and optimized *arr stack.
* **Bridging Servers with NFS:** A crucial piece of the puzzle in this two-server setup is media file access. I configured an NFS (Network File System) share on the TrueNAS Scale server (Supermicro). This NFS share is then mounted directly into the Ubuntu Server VM on the R710. This allows applications like Radarr and Sonarr to instruct SABnzbd where to download files and, more importantly, allows the *arrs to see and manage the media files stored on the TrueNAS server. Proper path mapping within Docker Compose configurations is essential here to ensure containers can access these NFS mounts.

### 4. Jellyfin on TrueNAS Scale: Simplified Streaming with a Twist

Setting up Jellyfin on the Supermicro was mostly straightforward, with one hardware hurdle:
* **TrueNAS Scale Community App:** Jellyfin is available as a *community* app within TrueNAS Scale, which simplifies installation.
* **GPU Passthrough & Hardware Choice:** A primary reason for running Jellyfin on the TrueNAS server was to leverage its AMD RX 590 GPU for hardware transcoding. The Supermicro motherboard provided the necessary GPU power pins, which my Dell R710 motherboard lacked. TrueNAS Scale has a straightforward option to pass through an AMD GPU to the Jellyfin application.
* **The GPU Fitment Challenge:** One unexpected issue was the physical size of the RX 590. It wouldn't fit into the server chassis with its fans attached. My solution was to carefully remove the GPU's fan shroud and fans, leaving just the PCB and heatsink. 

![AMD RX 590 GPU with fans removed](/img/my_self_hosted_media_setup/GPU_NO_FANS.jpg)

This allowed it to fit, and thankfully, server airflow seems sufficient for cooling so far. 

![Modified AMD RX 590 GPU installed in Supermicro server](/img/my_self_hosted_media_setup/GPU_IN_SERVER.jpg)

(*Disclaimer: Modifying hardware like this carries risks, including potential damage or overheating if not done carefully and with adequate alternative cooling. Proceed with caution if you attempt something similar.*)

### 5. Secure Access with Caddy Reverse Proxy

To manage access to the various web UIs and Jellyfin, I implemented Caddy:
* **Dedicated Docker Network:** Caddy runs in its own Docker network, and other application containers that need to be exposed are connected to this network.
* **Internal Access Scheme:** For internal network access to the *arr stack UIs (Radarr, Sonarr, etc.), I configured Caddy to use a custom local domain scheme (e.g., `radarr.local.yourpersonaldomain.com`, `sonarr.local.yourpersonaldomain.com`). This involved setting up my own private DNS resolution for this custom domain.
* **External Access for Jellyfin:** Jellyfin is made accessible externally. Currently, this is achieved by port forwarding external ports 80 (HTTP) and 443 (HTTPS) from my router directly to the Caddy container, which then handles SSL termination and proxying to Jellyfin. I am considering exploring VPN tunnels or Cloudflare Tunnels in the future for an alternative approach to remote access.

### A Key Takeaway from the Trenches:

If there's one universal truth I've learned from this and other tech projects, it's this: **when things aren't working, it's probably due to your own mistake somewhere.** Double-checking configurations, paths, and permissions often reveals the culprit!

---

## Part 4: The Payoff - User Experience & Benefits

With the system up and running, the most important question is: was it worth it? For me and my family, the answer is a resounding yes.

### 1. A Better Viewing Experience:
The most significant changes are the **reduction in frustration and cost**. We're no longer disappointed to find a show or movie has been removed from a streaming service. If it's in our library, it's there to stay. Plus, the monthly 'media bill' is noticeably lower, even accounting for Usenet costs.

### 2. Day-to-Day Advantages: Reliability and Efficiency:
The biggest practical benefit is **reliability**. We have what we want, when we want it. Gone are the days of spending 30 minutes hopping between different streaming platforms to find something to watch. Now, it's all in one place.

### 3. Why Jellyfin Shines:
For our front-end, Jellyfin's **simplicity** is its greatest strength. It focuses on presenting *my* media, and my media only, without the clutter of third-party content or ads sometimes found in other solutions. It does its job effectively and stays out of the way.

### 4. The Learning Curve and Self-Correction:
Are there downsides? Beyond the initial setup time, any issues have generally been self-inflicted. For instance, I once had a movie download in the wrong language. However, this wasn't a fault of the system, but rather my own oversight in not properly configuring language profiles in the *arr stack. It serves as a good reminder of the 'user error' principle mentioned earlier and the ongoing learning process involved in managing a self-hosted setup.

---

## Part 5: The Bottom Line - Costs vs. Savings

One of the primary drivers for this project was cost savings. Let's break down the numbers to see how a self-hosted setup compares to my previous streaming service subscriptions.

### Previous Monthly Streaming Expenses (largely ad-supported tiers):

* Netflix (with ads): $7.99
* Disney+ Bundle (Disney+, Max, Hulu - all with ads): $16.99
* Peacock: $7.99
* Crunchyroll: $11.99
* Apple TV+: $9.99
* **Total Monthly Streaming Cost:** $54.95
* **Total Annual Streaming Cost:** **$659.40**

### Current Annual Self-Hosted Expenses:

* Usenet Provider: $70.00
* Usenet Indexer 1 (NZBGeek): $12.00
* Usenet Indexer 2 (NZBPlanet): $10.00
* Usenet Indexer 3 (ALTHub): $15.00
* **Total Annual Self-Hosted Service Cost:** **$107.00**

**(Note on Electricity:** For my specific situation, electricity costs are bundled into my rent, so I don't see a direct extra charge. I haven't monitored the precise power consumption of the servers, but this is a factor potential self-hosters should consider based on their local electricity rates and hardware.)

### Hardware Investment:

It's important to note that I was planning to acquire server hardware regardless of this specific project. However, for context if someone were looking at similar hardware:
* Dell R710: Free (obtained from a friend years ago)
* AMD RX 590 GPU: Free (repurposed from old hardware)
* Supermicro Server: ~$450 (purchased used via eBay)
* 4x 4TB Seagate Exos Drives: ~$150 (purchased used via eBay)
* **Relevant Hardware Outlay for this Comparison:** ~$600

### The Financial Payoff:

* **Annual Savings on Services:** $659.40 (former streaming) - $107.00 (current services) = **$552.40 saved per year.**
* **Return on Hardware Investment:** Based on these savings, the ~$600 spent on the Supermicro and drives would be recouped in approximately **just over 13 months** ($600 / $552.40 savings per year ≈ 1.086 years).

Considering much of my hardware was free or repurposed, my personal breakeven point was even sooner. For anyone starting from scratch, the initial hardware investment would be the main factor, but the ongoing annual savings on subscription services are significant and compelling.

---

## Part 6: What's Next? - Future Plans

This self-hosting journey doesn't end here; there's always room for improvement and expansion!

* **Significant Storage Upgrade:** The most immediate plan is a major storage expansion. I'm currently awaiting a shipment of ten additional 4TB drives. Eight of these will be integrated into the Supermicro server's ZFS array, substantially increasing our media storage capacity. The remaining two will serve as cold spares, ready to be swapped in should a drive fail, ensuring data integrity and minimizing downtime.
* **Potential GPU Refresh:** While my AMD RX 590 is handling transcoding duties adequately for now, it is an older card by today's standards. I'm keeping an eye on newer GPU alternatives that might offer better performance, efficiency, or broader codec support (like AV1 encoding). However, I haven't found a compelling enough reason to upgrade just yet, as the current setup still meets my needs.
* **New Self-Hosted Services:** Beyond media, I'm looking to expand the utility of my home server. The next service on my list is [Immich](https://immich.app/), a self-hosted photo and video backup solution. The goal is to create a private alternative to cloud-based photo services, giving me more control over my personal memories.
* **Remote Access Refinement:** As mentioned earlier, I plan to explore more robust remote access solutions like a VPN or a Cloudflare Tunnel as an alternative to direct port forwarding for Jellyfin.

These additions and considerations will further enhance the capabilities and resilience of my home lab.

---

## Part 7: Conclusion - Final Thoughts on the Self-Hosting Voyage

My journey into self-hosting the *arr stack with Jellyfin has been, overall, an amazing experience. While there were certainly moments of frustration during the setup – as there often are with any complex tech project – the process of tinkering, problem-solving, and ultimately building a system tailored to my exact needs has been incredibly rewarding and a lot of fun.

### Is This Path Right for You?

If you're considering a similar setup, my biggest piece of advice is to first **clearly define your own needs and wants.** The beauty of self-hosting is its flexibility. Your requirements might call for significantly more powerful hardware, or you might find that a much smaller, more economical setup (like a Raspberry Pi for direct play) is perfectly adequate.

### Do your research.
Explore the tools, read guides (like those on trash-guides.info), and understand the components you'll be working with. This isn't a plug-and-play solution for everyone, and it does require a willingness to learn and troubleshoot. Be sure you understand what you're getting into, especially regarding the time investment for setup and ongoing maintenance.

However, if you enjoy technology, value control over your media, and are looking for a cost-effective and highly customizable alternative to commercial streaming services, then diving into the world of self-hosting could very well be for you. The satisfaction of building your own media haven is, in my opinion, well worth the effort.
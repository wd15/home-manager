# mr-french Bare-Metal Host Setup

This directory contains the bare-metal host configuration files required to bootstrap the Nix Home Manager environment on the `mr-french` HPC cluster.

## The Problem
1. **Forced Shell:** The cluster strictly assigns `/bin/bash` as the login shell via `/etc/passwd`. We do not have `chsh` privileges to permanently change the default to Zsh.
2. **NFS Latency (The Nix Penalty):** Transitioning to Zsh by evaluating the Home Manager Nix flake dynamically (`nix shell --inputs-from...`) takes 15+ minutes due to the cluster's network storage latency.

## The Solution: The Bouncer
To achieve instant logins, the bare-metal `~/.bashrc` acts as a session "bouncer":
1. SSH connects, the system forces `/bin/bash`, and `~/.bashrc` is triggered.
2. The `bashrc` script checks `~/.bootstrap-zsh-path` for a hardcoded Nix store path.
3. If valid, it reads the path and `exec`s the Zsh binary instantly—bypassing the Nix evaluator entirely.
4. If invalid or missing, it falls back to the slow flake resolution.

## Initial Setup (Manual Bootstrap)
If the cluster account is wiped, migrated, or you are setting this up from scratch, follow these steps to restore the instant login:

1. **Deploy the Bouncer:**
   Copy the `bashrc` from this repository directory to `~/.bashrc` on `mr-french`. 
   *(Note: If the system relies on a profile file for interactive SSH sessions, ensure `~/.bash_profile` exists and sources `~/.bashrc`).*

2. **Generate the First Pin:**
   Run the following command to evaluate the Nix flake once and write the physical store path to the tracker file:
   ```bash
   /toolbox/wd15/opt/bin/nix build --inputs-from ~/git/home-manager nixpkgs#zsh --no-link --print-out-paths > ~/.bootstrap-zsh-path

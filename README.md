# wd15 Home Manager config

Standalone Home Manager, two machines, one flake:

- **`wd15`** — laptop (`pippi`), Ubuntu-based, Hyprland desktop
- **`cluster`** — HPC head node (`mr-french`), headless, non-standard Nix install

```bash
# Laptop
home-manager switch --flake .#wd15

# Cluster
home-manager switch --flake .#cluster
```

Always run from inside this repo directory. Commit before switching — flakes warn loudly ("Git tree is dirty") on uncommitted changes; it's not fatal but it's a signal you forgot to commit.

---

## File map

| File | Used by | Purpose |
|---|---|---|
| `flake.nix` | both | Defines the two `homeConfigurations`. Pins `nixos-25.11`. |
| `home.nix` | laptop | Top-level laptop module: identity, imports, tmux, vscode. |
| `home-cluster.nix` | cluster | Top-level cluster module: identity (`/users/wd15`!), imports, tmux (no Wayland bits), cache-location fix. |
| `bash.nix` | laptop | Full aliases + CUDA paths + conda + LSHOST/cricket. Laptop hardware/software assumptions baked in. |
| `bash-cluster.nix` | cluster | Same prompt/tmux-autostart mechanism, but **no CUDA hardcoding, no conda**, plus `/etc/profile.d` re-sourcing for the module system, plus Slurm aliases (`jobs`, `jobsall`, `cancel`). |
| `emacs.nix` | both (shared) | Fully headless-safe — `menu-bar-mode`/etc. are no-ops without a GUI frame. `services.emacs` daemon works fine over SSH too. |
| `git-ssh.nix` | both (shared) | git/ssh dotfiles, keychain, `.mambarc`. See "SSH keys" note below — content differs per machine even though config is shared. |
| `packages.nix` | laptop | Full CLI + scientific Python/Haskell/Julia stack + heavy apps. |
| `packages-cluster.nix` | cluster | CLI tools + *light* Python (jupyter/ipython only) + uv/poetry/micromamba. **Deliberately excludes** numpy/scipy/pandas/matplotlib/Julia/Haskell/MPI — see "Why no scientific packages" below. |
| `browsers.nix` | laptop only | Wrapped browser binaries + all XDG/MIME/desktop-entry wiring. |
| `hyprland.nix` | laptop only | Hyprland, waybar, hyprlock, hyprpaper, all desktop tooling. |
| `workspace-icons.nix` | laptop only | `hyprland-autoname-workspaces` config — see gotchas below, this one bit us hard. |
| `sway.nix` | laptop only (unused) | Predates Hyprland switch. Not imported anywhere currently. |
| `shell.nix` | laptop only | Misc laptop scripts (`backup`, `vpn`, `jupyter-cricket`, etc.) — none of these apply to the cluster. |

---

## Machine-specific facts (don't re-derive these, they took a while)

### Laptop (pippi)
- Standard single-user Nix install, `/nix` is real.
- Hostname `pippi`, hardware has NVIDIA GPU (see `env` vars in `hyprland.nix`).
- YubiKey/PIV smartcard reader lives here physically — `pcscd`/`opensc-pkcs11`/`p11-kit-proxy` stack, not relevant to the cluster.

### Cluster (mr-french)
- **Home directory is `/users/wd15`, NOT `/home/wd15`.** This is an actual NFS mount (`genie:/vol0/home/wd15`) and is at **98% capacity** — reported to sysadmin, not user-fixable. Don't point caches or GC roots here if avoidable.
- **Nix is NOT installed normally.** Binary lives at `/toolbox/wd15/opt/bin/nix`, a statically-linked build. `/nix` does not exist as a real path (`ls /nix` → "No such file or directory") — confirmed via `strings` that this binary does its own mount-namespace unsharing (`tryUnshareFilesystemEv`) to privately present `/toolbox/wd15/opt/nix` as `/nix` *from its own process's point of view only*. This is a legitimate, deliberate no-root-access workaround (cleaner than the old `nix-user-chroot`/`~/bin/nix-root` approach from a previous, now-abandoned install attempt — that script still exists but is **not used** anymore).
  - **Consequence: Home Manager's `nix.settings` option is inert on the cluster.** It configures whatever Nix Home Manager finds on `PATH`, but doesn't reach into this binary's actual config, which lives at `~/.config/nix/nix.conf` directly. Edit that file by hand for cluster Nix settings (substituters, store path, etc.), not via `home-cluster.nix`.
  - The `store = /toolbox/wd15/opt` line in that config file means "parent dir containing a `nix/store` subtree", not the store root itself — real paths land at `/toolbox/wd15/opt/nix/store/...`. Slightly confusing naming, not a bug.
- **First-ever flake evaluation is genuinely slow (~60s)**, not a hang — fetching + evaluating nixpkgs cold. Every subsequent call is ~1-2s. If a `nix` command seems stuck, let it run at least 90s before assuming it's broken; don't reflexively `Ctrl+C`/`timeout` it, we burned a lot of time chasing a phantom "hang" that was actually just this.
- `XDG_CACHE_HOME` is set to `/toolbox/wd15/.cache` in `home-cluster.nix` — keeps Nix's tarball/eval cache on local block storage (`/dev/mapper/vg0-toolbox`) rather than the slow, nearly-full NFS home dir. This didn't turn out to be the fix for the "slow eval" scare above (that was just cold-cache cost, unrelated to storage tier) but it's still correct practice to keep it off NFS regardless.
- Compute nodes have internet access (confirmed).
- Storage tiers seen in the wild: `/users/wd15` (NFS home), `/toolbox/wd15` (local, fast, used for Nix + micromamba root), `/working/wd15` (NFS, older FiPy/miniconda stuff, mostly legacy).

---

## Why no scientific packages on the cluster (`packages-cluster.nix`)

Deliberate choice, not an oversight:
- **MPI**: the cluster's module-loaded MPI is built against the actual interconnect/Slurm PMI. A Nix-provided MPI on `PATH` could silently shadow it and cause performance loss or hangs in real jobs. Existing `nix develop` flakes for OpenFOAM/AdditiveFOAM/ExaCA already handle this correctly per-project — don't duplicate that at the Home Manager level.
- **numpy/scipy/pandas/Julia/Haskell etc.**: kept in per-project `flake.nix` files (e.g. `am-dt-modeling`, `phase-field-schema/automated-rocrate`) rather than the home profile, so project dependency changes don't require touching this repo.
- What *is* here: `jupyter`+`ipython` only, for viewing/running a notebook someone hands you without needing a project's full flake — plus `uv`/`poetry`/`micromamba` as fast ad-hoc environment tools, not stacks themselves.

---

## SSH keys

`keychain.keys = [ "id_ed25519" "id_rsa" ]` is shared config between both machines — but this only references **key names to unlock**, not key content. Per-machine practice: keys are regenerated separately on each filesystem (laptop and cluster each have their own actual `id_ed25519`/`id_rsa` files with different content) — never copied between machines. This is intentional and correct; don't "fix" it by syncing key files.

`.mambarc`'s Cloudflare Gateway proxy block is shared (not laptop-only) — the same network restriction applies from both machines, confirmed by you directly.

---

## Known gotchas (all cost real debugging time — read before assuming something's broken)

1. **tmux serves stale environment variables to "fresh" terminals.** `bash.nix`/`bash-cluster.nix` auto-attach every interactive shell to tmux. tmux *servers* are long-lived and only capture env vars at the moment they first start — a new terminal window attaching to an old server gets that old environment, not a fresh one. This caused hours of confusion around `WAYLAND_DISPLAY`, `HYPRLAND_INSTANCE_SIGNATURE`, and `SSH_AUTH_SOCK` all appearing "stuck." Fix when this happens: `tmux kill-server`, then open a genuinely new terminal.

2. **`exec-once` (Hyprland) only fires on a真 fresh compositor start**, never on `home-manager switch` or a config reload. If you add something to `exec-once` (e.g. `nm-applet`, `blueman-applet`), you must fully log out and back in (or restart Hyprland) — not just switch — before it'll actually run.

3. **`HYPRLAND_INSTANCE_SIGNATURE` sometimes shows literally `unknown_<numbers>` instead of a real hash.** Confirmed via Hyprland's own log (not just an env var issue) — this is a genuine quirk of this particular Nix-based Hyprland install, not something we broke. Workaround if `hyprctl` stops working: check `hyprctl instances`, or just open a fresh terminal (watch out for gotcha #1 interfering with the "fresh" part).

4. **`hyprland-autoname-workspaces` config format trap**: `client_active` (the *active-workspace wrapper template*, e.g. controls asterisks/color) must go inside an actual `[format]` section header:
   ```toml
   [format]
   client_active = "{icon}"
   ```
   NOT inside `[class_active]` (which only overrides per-app icon *content*, a completely different setting). We spent a very long debugging session on this because the generated example file has `client_active` commented out at the top with no real `[format]` header at all — editing `[class_active]` did nothing because a different, hardcoded default was silently winning. If workspace active-state formatting ever looks wrong again, check `[format]` first.
   - Color for the active workspace is handled via waybar CSS (`#workspaces button.active { color: ...; }` in `programs.waybar.style`), NOT via Pango `<span>` tags in the workspace name — Hyprland workspace names are plain text, no markup rendering happens in that path.

5. **`~/.config/mimeapps.list` keeps getting clobbered.** Obsidian (and potentially other apps) rewrites this file directly when registering URI handlers (e.g. `x-scheme-handler/obsidian`), destroying Home Manager's symlink in the process. Fixed via `xdg.configFile."mimeapps.list".force = true;` in `browsers.nix` — Nix always wins on next switch regardless of what apps write in between.

6. **Home Manager backup collisions**: if `home-manager switch` complains a file "would be clobbered," check whether a stale `.backup` file already exists before re-running with `-b backup` — it'll refuse to overwrite its own old backup too. `diff` the conflicting files first; they're often harmless GUI-generated cruft, not anything worth preserving.

---

## Open items / not yet resolved

- `~/.bash_paths` and `~/.local/bin/env` on the cluster were never fully inspected — the old bashrc sourced both, and `~/.bash_paths` defines an `$arch_path` variable used in `LD_LIBRARY_PATH` that we never traced. Low priority unless something cluster-side breaks mysteriously.
- FiPy's old SVN-based workflow (`FIPYROOT`/`FIPYBASE`/`FIPYTRUNK`, `~/Documents/python/fipy`) status was never confirmed retired-or-not. Not carried into any current config either way.
- `~/bin/nix-root` (old `nix-user-chroot`-based script) confirmed **not in use** — current Nix install method is the static-binary-with-mount-namespace approach described above. The script can probably be deleted but hasn't been.
- `dotfiles/ssh-config` is shared between machines but contains laptop-oriented `Host mr-french.nist.gov`/`Host cricket.nist.gov` blocks with `ForwardAgent yes` that are meaningless when run from on the cluster itself. Harmless (SSH ignores non-matching `Host` blocks) but may want splitting if cluster-specific SSH hops get added later.

---

## Making changes — general workflow

1. Edit the relevant `.nix` file.
2. `home-manager switch --flake .#wd15` (laptop) or `--flake .#cluster` (cluster).
3. If a file conflict error appears ("would be clobbered"), diff it first, then `-b backup` if safe, or add `force = true` to that specific option if it's a recurring fight with some other app (see gotcha #5 for the pattern).
4. For Hyprland-specific changes involving `exec-once`, remember gotcha #2 — you need a real restart, not just a switch.
5. Commit once confirmed working — don't leave the tree dirty for long, flakes nag about it constantly and it's easy to lose track of what's actually applied vs. staged.

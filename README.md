# 🔐 ubuntu-root-toggle

[![Shellcheck](https://github.com/v29r/ubuntu-root-toggle/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/v29r/ubuntu-root-toggle/actions/workflows/shellcheck.yml)
[![License: GPL v3](https://img.shields.io/github/license/v29r/ubuntu-root-toggle)](https://github.com/v29r/ubuntu-root-toggle/blob/main/LICENSE)
[![Made with Bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20%7C%2022.04%20%7C%2024.04-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com/)

A simple, interactive Bash script to **enable or disable root login** on Ubuntu systems — covering both SSH access and the root account itself.

> ⚠️ **Security Notice:** Enabling root login reduces system security. Only enable it when necessary, and disable it again as soon as your task is complete.

---

## Features

- ✅ Enable root login (SSH + password unlock)
- ✅ Disable root login (SSH + password lock)
- ✅ Check current root login status at a glance
- ✅ Interactive menu — no flags to memorize
- ✅ Automatically detects and restarts the SSH service (`ssh` or `sshd`)
- ✅ Safe — prompts before making changes

---

## Supported Operating Systems

| Operating System | Version | Supported |
|-----------------|---------|-----------|
| Ubuntu          | 20.04   | ✅        |
|                 | 22.04   | ✅        |
|                 | 24.04   | ✅        |
| Debian          | 11 / 12 | ⚠️ Likely works, untested |
| Other           | —       | ❌        |

---

## Usage

Run the following command as root (or with `sudo`):

```bash
curl -s https://raw.githubusercontent.com/v29r/ubuntu-root-toggle/main/toggle.sh | bash
```

> **Note:** On some systems you must be logged in as root before running the one-liner. If `sudo` doesn't work, switch to root first with `sudo -i`.

You will be presented with an interactive menu:

```
  ubuntu-root-toggle v1.0.0
  https://github.com/v29r/ubuntu-root-toggle

  [ INFO  ] Detected OS: Ubuntu 22.04.3 LTS

  Current root login status:

    Password:        Locked
    SSH PermitRoot:  no

  What would you like to do?

    [1] Enable  root login
    [2] Disable root login
    [3] Check   status only
    [4] Exit

  Enter option [1-4]:
```

---

## What the script does

### Enable root login
1. Checks if the root account has a password — if not, prompts you to set one
2. Sets `PermitRootLogin yes` in `/etc/ssh/sshd_config`
3. Restarts the SSH service
4. Unlocks the root account (`usermod -U root`)

### Disable root login
1. Locks the root password (`passwd -l root`)
2. Sets `PermitRootLogin no` in `/etc/ssh/sshd_config`
3. Restarts the SSH service

### Check status
- Shows whether the root password is set, locked, or missing
- Shows the current `PermitRootLogin` value from `sshd_config`

---

## Running locally (without curl)

```bash
git clone https://github.com/v29r/ubuntu-root-toggle.git
cd ubuntu-root-toggle
sudo bash toggle.sh
```

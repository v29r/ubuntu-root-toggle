#!/usr/bin/env bash

########################################################################
#                                                                      #
#  ubuntu-root-toggle — Enable or Disable Root Login on Ubuntu         #
#  https://github.com/v29r/ubuntu-root-toggle                 #
#                                                                      #
#  This program is free software: you can redistribute it and/or       #
#  modify it under the terms of the GNU General Public License as      #
#  published by the Free Software Foundation, either version 3 of the  #
#  License, or (at your option) any later version.                     #
#                                                                      #
########################################################################

SCRIPT_VERSION="v1.0.0"
GITHUB_SOURCE="https://raw.githubusercontent.com/v29r/ubuntu-root-toggle/main"

# ─────────────────────────────── Colors ────────────────────────────── #
RED="\033[0;31m"
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
BOLD="\033[1m"
RESET="\033[0m"

# ──────────────────────────── Helpers ───────────────────────────────── #
print_banner() {
  echo ""
  echo -e "${CYAN}${BOLD}  ubuntu-root-toggle ${SCRIPT_VERSION}${RESET}"
  echo -e "${CYAN}  https://github.com/v29r/ubuntu-root-toggle${RESET}"
  echo ""
}

info()    { echo -e "  [ ${GREEN}INFO${RESET}  ] $1"; }
warn()    { echo -e "  [ ${YELLOW}WARN${RESET}  ] $1"; }
error()   { echo -e "  [ ${RED}ERROR${RESET} ] $1"; }
success() { echo -e "  [ ${GREEN} OK ${RESET}  ] $1"; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root."
    echo "  Try: sudo bash toggle.sh"
    exit 1
  fi
}

check_os() {
  if [[ ! -f /etc/os-release ]]; then
    error "Cannot detect OS. /etc/os-release not found."
    exit 1
  fi
  # shellcheck source=/dev/null
  source /etc/os-release
  if [[ "$ID" != "ubuntu" ]]; then
    warn "This script is designed for Ubuntu. Detected: ${PRETTY_NAME}"
    read -rp "  Continue anyway? [y/N]: " CONTINUE
    [[ "${CONTINUE,,}" != "y" ]] && { info "Aborted."; exit 0; }
  else
    info "Detected OS: ${PRETTY_NAME}"
  fi
}

# ──────────────────────── Core Functions ────────────────────────────── #

enable_root_login() {
  echo ""
  info "Enabling root login..."

  # 1. Set a root password if not already set
  if ! grep -q "^root:[^!*]" /etc/shadow 2>/dev/null; then
    warn "Root account has no password set."
    echo ""
    echo -e "  ${BOLD}You must set a root password to enable login:${RESET}"
    passwd root
    echo ""
  fi

  # 2. Enable root in sshd_config
  SSHD_CONFIG="/etc/ssh/sshd_config"
  if grep -qE "^\s*PermitRootLogin\s+" "$SSHD_CONFIG"; then
    sed -i 's/^\s*PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"
  else
    echo "PermitRootLogin yes" >> "$SSHD_CONFIG"
  fi
  success "Set PermitRootLogin yes in $SSHD_CONFIG"

  # 3. Restart SSH service
  if systemctl is-active --quiet ssh; then
    systemctl restart ssh
    success "Restarted ssh service."
  elif systemctl is-active --quiet sshd; then
    systemctl restart sshd
    success "Restarted sshd service."
  else
    warn "Could not detect running SSH service. Please restart manually."
  fi

  # 4. Also allow root in PAM / console (unlock the account)
  usermod -U root 2>/dev/null && success "Unlocked root account (usermod -U)."

  echo ""
  echo -e "  ${GREEN}${BOLD}Root login has been ENABLED.${RESET}"
  echo ""
  warn "For security, consider disabling root login again after your task is done."
  echo ""
}

disable_root_login() {
  echo ""
  info "Disabling root login..."

  # 1. Lock root password
  passwd -l root
  success "Locked root password."

  # 2. Disable root in sshd_config
  SSHD_CONFIG="/etc/ssh/sshd_config"
  if grep -qE "^\s*PermitRootLogin\s+" "$SSHD_CONFIG"; then
    sed -i 's/^\s*PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONFIG"
  else
    echo "PermitRootLogin no" >> "$SSHD_CONFIG"
  fi
  success "Set PermitRootLogin no in $SSHD_CONFIG"

  # 3. Restart SSH service
  if systemctl is-active --quiet ssh; then
    systemctl restart ssh
    success "Restarted ssh service."
  elif systemctl is-active --quiet sshd; then
    systemctl restart sshd
    success "Restarted sshd service."
  else
    warn "Could not detect running SSH service. Please restart manually."
  fi

  echo ""
  echo -e "  ${GREEN}${BOLD}Root login has been DISABLED.${RESET}"
  echo ""
}

check_status() {
  echo ""
  info "Current root login status:"
  echo ""

  # Check password status
  ROOT_PASS_STATUS=$(passwd -S root 2>/dev/null | awk '{print $2}')
  case "$ROOT_PASS_STATUS" in
    P) echo -e "    Password:        ${GREEN}Set (active)${RESET}" ;;
    L) echo -e "    Password:        ${RED}Locked${RESET}" ;;
    NP) echo -e "    Password:        ${YELLOW}Not set${RESET}" ;;
    *) echo -e "    Password:        ${YELLOW}Unknown${RESET}" ;;
  esac

  # Check sshd_config
  SSHD_CONFIG="/etc/ssh/sshd_config"
  PERMIT_ROOT=$(grep -E "^\s*PermitRootLogin\s+" "$SSHD_CONFIG" 2>/dev/null | awk '{print $2}' | tail -1)
  if [[ -z "$PERMIT_ROOT" ]]; then
    echo -e "    SSH PermitRoot:  ${YELLOW}Not explicitly set (default: no)${RESET}"
  elif [[ "${PERMIT_ROOT,,}" == "yes" ]]; then
    echo -e "    SSH PermitRoot:  ${GREEN}yes${RESET}"
  else
    echo -e "    SSH PermitRoot:  ${RED}${PERMIT_ROOT}${RESET}"
  fi

  echo ""
}

# ───────────────────────────── Menu ─────────────────────────────────── #
main_menu() {
  print_banner
  check_os
  check_status

  echo -e "  ${BOLD}What would you like to do?${RESET}"
  echo ""
  echo "    [1] Enable  root login"
  echo "    [2] Disable root login"
  echo "    [3] Check   status only"
  echo "    [4] Exit"
  echo ""
  read -rp "  Enter option [1-4]: " OPTION

  case "$OPTION" in
    1) enable_root_login ;;
    2) disable_root_login ;;
    3) check_status ;;
    4) info "Exiting."; exit 0 ;;
    *) error "Invalid option."; main_menu ;;
  esac
}

# ───────────────────────────── Entry ────────────────────────────────── #
require_root
main_menu

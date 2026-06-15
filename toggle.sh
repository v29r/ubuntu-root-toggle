#!/usr/bin/env bash

########################################################################
#  ubuntu-root-toggle — Enable or Disable Root Login on Ubuntu         #
#  https://github.com/v29r/ubuntu-root-toggle                          #
########################################################################

SCRIPT_VERSION="v1.0.1"

RED="\033[0;31m"
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
BOLD="\033[1m"
RESET="\033[0m"

info()    { echo -e "  [ ${GREEN}INFO${RESET}  ] $1"; }
warn()    { echo -e "  [ ${YELLOW}WARN${RESET}  ] $1"; }
error()   { echo -e "  [ ${RED}ERROR${RESET} ] $1"; }
success() { echo -e "  [  ${GREEN}OK${RESET}   ] $1"; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root. Try: sudo bash toggle.sh"
    exit 1
  fi
}

check_os() {
  source /etc/os-release 2>/dev/null
  info "Detected OS: ${PRETTY_NAME}"
}

check_status() {
  echo ""
  info "Current root login status:"
  echo ""
  ROOT_PASS_STATUS=$(passwd -S root 2>/dev/null | awk '{print $2}')
  case "$ROOT_PASS_STATUS" in
    P)  echo -e "    Password:        ${GREEN}Set (active)${RESET}" ;;
    L)  echo -e "    Password:        ${RED}Locked${RESET}" ;;
    NP) echo -e "    Password:        ${YELLOW}Not set${RESET}" ;;
    *)  echo -e "    Password:        ${YELLOW}Unknown${RESET}" ;;
  esac
  PERMIT_ROOT=$(grep -E "^\s*PermitRootLogin\s+" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' | tail -1)
  if [[ -z "$PERMIT_ROOT" ]]; then
    echo -e "    SSH PermitRoot:  ${YELLOW}Not set (default: no)${RESET}"
  elif [[ "${PERMIT_ROOT,,}" == "yes" ]]; then
    echo -e "    SSH PermitRoot:  ${GREEN}yes${RESET}"
  else
    echo -e "    SSH PermitRoot:  ${RED}${PERMIT_ROOT}${RESET}"
  fi
  echo ""
}

enable_root_login() {
  info "Enabling root login..."
  if ! grep -q "^root:[^!*]" /etc/shadow 2>/dev/null; then
    warn "Root has no password. Set one now:"
    passwd root
  fi
  sed -i '/^\s*PermitRootLogin/d' /etc/ssh/sshd_config
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
  success "Set PermitRootLogin yes"
  systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
  success "Restarted SSH service"
  usermod -U root 2>/dev/null
  success "Unlocked root account"
  echo ""
  echo -e "  ${GREEN}${BOLD}Root login ENABLED.${RESET}"
  warn "Disable it again after your task is done."
  echo ""
}

disable_root_login() {
  info "Disabling root login..."
  passwd -l root
  success "Locked root password"
  sed -i '/^\s*PermitRootLogin/d' /etc/ssh/sshd_config
  echo "PermitRootLogin no" >> /etc/ssh/sshd_config
  success "Set PermitRootLogin no"
  systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
  success "Restarted SSH service"
  echo ""
  echo -e "  ${GREEN}${BOLD}Root login DISABLED.${RESET}"
  echo ""
}

# ── Always read from /dev/tty so curl|bash works ──
ask() {
  local prompt="$1" var
  printf "%s" "$prompt" > /dev/tty
  read -r var < /dev/tty
  echo "$var"
}

main_menu() {
  echo ""
  echo -e "${CYAN}${BOLD}  ubuntu-root-toggle ${SCRIPT_VERSION}${RESET}"
  echo -e "${CYAN}  https://github.com/v29r/ubuntu-root-toggle${RESET}"
  echo ""
  check_os
  check_status
  echo -e "  ${BOLD}What would you like to do?${RESET}"
  echo ""
  echo "    [1] Enable  root login"
  echo "    [2] Disable root login"
  echo "    [3] Check   status only"
  echo "    [4] Exit"
  echo ""
  OPTION=$(ask "  Enter option [1-4]: ")
  case "$OPTION" in
    1) enable_root_login ;;
    2) disable_root_login ;;
    3) check_status ;;
    4) info "Exiting."; exit 0 ;;
    *) error "Invalid option '$OPTION'."; main_menu ;;
  esac
}

require_root
main_menu

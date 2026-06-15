# Changelog

All notable changes to this project will be documented in this file.

---

## [v1.0.0] - 2024-01-01

### Added
- Interactive menu to enable or disable root login
- Enable root: set root password, `PermitRootLogin yes`, unlock account, restart SSH
- Disable root: lock password, `PermitRootLogin no`, restart SSH
- Status check: shows current password state and SSH config value
- OS detection with warning for non-Ubuntu systems
- Automatic detection of `ssh` vs `sshd` service name
- Colored output for info, warnings, errors, and success messages

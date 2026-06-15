# Contributing to ubuntu-root-toggle

Thank you for your interest in contributing! Below are the guidelines to help you get started.

---

## Reporting Issues

- Search [existing issues](https://github.com/YOUR_USERNAME/ubuntu-root-toggle/issues) before opening a new one.
- Include your Ubuntu version (`lsb_release -a`), a clear description of the problem, and steps to reproduce it.

---

## Pull Requests

1. Fork the repository and create your branch from `main`.
2. Make sure your changes pass [ShellCheck](https://www.shellcheck.net/) with no errors.
3. Test on at least one supported Ubuntu version.
4. Write clear commit messages.
5. Open a pull request describing what you changed and why.

---

## Code Style

- Use 2-space indentation.
- Always quote variables: `"$VAR"` not `$VAR`.
- Add comments for any non-obvious logic.
- Run `shellcheck toggle.sh` locally before submitting.

---

## Setting Up ShellCheck Locally

```bash
sudo apt install shellcheck
shellcheck toggle.sh
```

---

## Scope

This script is intentionally simple. Feature requests that significantly expand scope (e.g., adding support for unrelated SSH hardening tasks) may be declined to keep the project focused.

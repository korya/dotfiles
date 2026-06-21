# dotfiles

Install the dotfiles — turns `$HOME` into this repo, backing up any files
macOS pre-seeded (`.zshrc`, `.zprofile`, …) instead of forcing a manual merge:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/korya/dotfiles/master/.korya.d/install-dotfiles.sh)
```

Pre-existing files are moved to `~/.dotfiles-backup-<timestamp>/`. The script is
idempotent: re-running just fast-forwards the repo.

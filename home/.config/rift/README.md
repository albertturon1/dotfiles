# rift

Rift configuration (`config.toml`).

## No helper programs

Rift is a fork (see the fork repository) and does everything itself: group focus commands (`next_sibling`, `next_slot`,
`move_focus_in_group`), accordion roots through the `stacked_root` workspace rule, workspace switching and the
JankyBorders border (`[settings.borders]`). `config.toml` runs no helper: do not add Go, Python, shell or Node scripts for a
handler. A behaviour that is missing belongs in the fork, with a test next to it.

The config only loads with the fork: stock Rift stops on the new keys. The Accessibility permission and the signing
certificate belong to one machine each (see the fork's `rebuild.sh`).

## The fork

The fork is the submodule `vendor/rift`: its `dotfiles` branch is ONE commit on top of upstream Rift, in the Rift fork
repository on GitHub. It is also the working copy: change code there, run `./rift-dev.sh test`, then
`git -C vendor/rift commit --amend` (never a second commit, that keeps every rebase to one conflict at most).

| Task | Command (from the dotfiles root) |
|---|---|
| Build, sign, install and restart Rift | `./rift-dev.sh build` |
| Take the newest upstream Rift | `./rift-dev.sh update` (rebase onto `upstream/main`, then the tests) |
| Publish a new version | `./rift-dev.sh ship`, then commit the staged `vendor/rift` pointer |
| Install on another machine | `./install.sh` or `./rift-install.sh` (downloads the build for the pinned commit) |

`rift-dev.sh cert` creates a local signing certificate once: with it the Accessibility permission survives every
rebuild on this machine. Other machines need no certificate, only the permission once per downloaded binary. The
published binaries are release assets of the fork (`build-<sha>`), not files in git.

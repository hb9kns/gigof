# gigof : framework for public Git gopher server

This script suite is used to run the git-gopher-services on
gopher://dome.circumlunar.space/.

## addgg.sh

script for installing a new user with predefined gopher directory and
related git repo, permitting remote pushing with automatic update,
blocking non-git shell access; installs `git-shell` as login shell

## signup.sh

custom login shell for automatic and unattended logging of new user
account submissions (requests)

## setstat.sh

script for admin, to set status messages for account submissions
(which are then accessible for users through gopher)

## instsign.sh

script for installation of signup user, by default 'new'
(anonymous login to signup.sh)

## templates/

collection of sample script directories to be used
as interactive custom commands for `git-shell`

Copy all scripts you need into a working directory and feed its name
(as copy or as symlink)
to `addgg.sh` for installation in `~/git-shell-commands` for the
new user.

+ none: contains only `non-interactive-login` to inform the
  user that interactive access is blocked
+ basics: basic commands for housekeeping, read/write admin messages,
  and handling of additional git repos
  *file names are hardcoded in scripts!*

## msgadm.sh

script for admin side of user communication

## gitdaemon.sh

script for easy launching of git-daemon in a terminal without detaching,
exporting a common (system-wide) directory as well as additional user repos

---

*(2018-Nov // HB9KNS)*

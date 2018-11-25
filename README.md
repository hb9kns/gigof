# gigof : framework for public Git gopher server

*work in progress, see status lines*

## addgg.sh

*status: usable*

script for installing a new user with predefined gopher directory and
related git repo, permitting remote pushing with automatic update,
blocking non-git shell access; installs `git-shell` as login shell

## signup.sh

*status: usable*

custom login shell for automatic and unattended logging of new user
account submissions (requests)

## setstat.sh

*status: beta*

script for admin, to set status messages for account submissions
(which are then accessible for users through gopher)

## instsign.sh

*status: alpha*

script for installation of signup user
(anonymous login to signup.sh)

## templates/

*status: usable*

collection of sample script directories to be used
as interactive custom commands for `git-shell`

Copy all scripts you need into a working directory and feed its name
to `addgg.sh` for installation in `~/git-shell-commands` for the
new user.

+ none: contains only `non-interactive-login` to inform the
  user that interactive access is blocked
+ basics: basic commands for housekeeping, read/write admin messages
  *file names are hardcoded in scripts!*

## msgadm.sh

*status: usable*

script for admin side of user communication

---

*(2018-Nov // HB9KNS)*

# gigof : framework for public Git gopher server

This script suite is used to run the git-gopher-services on
gopher://dome.circumlunar.space/.

It consists of various administrator scripts
(normally run through ˋsudoˋ or as root)
for installation of an ssh-accessed signup script
under a dedicated user (which is ˋnewˋ by default),
managing status of signup submissions, installation
of new users (if accepted by the admin) with predefined
gopher content and related git repository including
hook for automatic publication and possibly interactive
git-shell access,
communication with users through local text files,
and scripts for listing externally accessible git repos
and easy launching of git-daemon for external repo access.

For users, a small suite of git-shell scripts exists which
can provide self-management of their home directory:
management of git repos in addition to the standard
ˋgopher.gitˋ for the gopherhole, housekeeping of git repos,
and communication with the admin through text files.

The suite is tested and used on standard Ubuntu 16.

## scripts

### addgg.sh

admin script for installing a new user with predefined gopher directory and
related git repo, permitting remote pushing with automatic update,
blocking non-git shell access; installs `git-shell` as login shell

### signup.sh

custom login shell for automatic and unattended logging of new user
account submissions (requests)

### setstat.sh

admin script to set status messages for account submissions
(which are then accessible for users through gopher)

### instsign.sh

admin script for installation of signup user, by default 'new'
(anonymous login to signup.sh)

### templates/

collection of sample script directories to be used
as interactive custom commands for `git-shell`

Copy all scripts you need into a working directory and feed its name
(as copy or as symlink)
to `addgg.sh` for installation in `~/git-shell-commands` for the
new user.

+ ˋnoneˋ contains only `non-interactive-login` to inform the
  user that interactive access is blocked
+ ˋbasicsˋ contains commands for housekeeping, read/write admin messages,
  and handling of additional git repos;
  *file names are hardcoded in scripts!*

### msgadm.sh

admin script for user communication

### gitdaemon.sh

script for easy launching of git-daemon in a terminal without detaching,
exporting a common (system-wide) directory as well as additional user repos

### gitexplist.sh

script to generate list of externally available git repos in
common ˋ/var/localˋ and ˋ/home/USER/r/ˋ directories

### privrep.sh

admin script to set file in user's directory permitting them
to switch additional repos between public/exported and private/hidden
with the ˋreposˋ command in ˋtemplates/basics/ˋ 

### status.cgi

gopher query cgi script to report status of given submission ID
(generated and displayed to submitting user by signup script)

---

*(2018-Nov // HB9KNS)*

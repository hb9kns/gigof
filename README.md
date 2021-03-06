# gigof : framework for public Git gopher server

This script suite is used to run the git-gopher-services on
[Ryumin's Dome]( gopher://dome.circumlunar.space/ ).

It consists of various administrator scripts
(normally run through `sudo` or as root)
for installation of an ssh-accessed signup script
under a dedicated user (which is `new` by default),
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
`gopher.git` for the gopherhole, housekeeping of git repos,
and communication with the admin through text files.

The suite currently is tested and used on Ubuntu 16.

## workflows

Most of the setup scripts must write as/for other users,
therefore being root or employing `sudo` is required.
In general, the latter is safer,
but for brevity, we're assuming the former.

### system setup

The system needs to provide a standard POSIX toolchain,
and administrative tools like `sudo` and `adduser` are required.
The repective commands currently are hard coded,
i.e the scripts require manual modifications for other tools.

In addition, `git` , `ssh` and `gophernicus` (or a compatible gopher
server) must be installed and working for all users on the default
file paths; management of these tools will not be covered here, but
in most systems, standard installations of these tools should work
out of the box.

Newly created git-gopher accounts will belong to group `gigofs`
which must be set up manually, e.g with `addgroup` -- alternatively,
the `addgg.sh` script could be modified to use an existing group.

#### installing submission request account

To permit future users to submit their desired user/account
names and public ssh keys for access, the script `instsign.sh`
installs a special account (named `new` by default) which has
the script `signup.sh` as login shell.

The script adds a rule to `/etc/ssh/sshd_config` prohibiting
TCP forwarding globally, to prevent anonymous remote parties from
using the special account for hopping/tunneling elsewhere.

To activate this rule, a running sshd process should be forced to
re-read the configuration, e.g with `kill -HUP $sid` where `$sid`
is the process id of sshd. Alternatively, reboot the system.

Finally, with `passwd new` (or the modified account name)
a password for remote login must be set, typically also `new`
or something similarly simple: this must be published anyway,
for prospective users to be able to submit applications.

### everyday use

#### submitting new user account requests

This workflow is on the user side. Prospective users must know
the sshd port and the host IP, so that they may log in as the
`new` user described above. Then they may enter their desired
user name (which is sanitized to be 4 to 8 characters long,
only letters and numbers) and ssh public key material.  If they
do not provide functional pubkey(s), login to the account will
*never be possible!*

The `signup.sh` script has a builtin timeout of about 5 min, i.e
an account request must be finished in that time, otherwise the
process will abort.

If successful, the signup process will report back to the user a
random submission ID number for later reference. Users may look up
the status with help of that number by requesting a file named
`<ID>.txt` from the directory `accounts` of the `new` user account,
e.g `gopher://dome.circumlunar.space:70/0/~new/accounts/1234567890.txt`
(where `1234567890` must be replaced by the actual ID).
If the request is accepted and the account installed, they
can connect to it with ssh and git push/pull to their repos.

By default, one repository is installed, named `gopher.git` and
located in the user's home directory, which is linked to the
personal gopherhole located under `public_gopher` in the home.
It contains a git hook automatically doing a `git pull` into the
gopherhole whenever the user pushes content to `gopher.git` and
therefore updating the gopherhole.

If permitted by the administrator, users may install additional
git repos, which may be exported through git-daemon; see below.

#### processing submission requests

Submissions can be viewed in the `~new/public_gopher/accounts`
directory, e.g by grepping for files with the string `:NEW:`
contained. Administrators should change the corresponding file
according to the decisions/actions taken.

Users can submit a desired account name and ssh pubkey material,
all saved in the file with the submission ID in the directory
mentioned above.
Administrators should get the data from that file and
feed it to the `addgg.sh` script as described below, then modify
the file to report back to users the acceptance or refusal of
requests.

#### setting up user accounts

The script `addgg.sh` takes as arguments a directory containing
pre-defined scripts for interactive launch by git-shell, and an
account name that should be newly installed.

Furthermore, the script expects public-keys for ssh on STDIN, one
line per key (standard `id_xxx.pub` format); if entered manually,
finish entry with a single CTRL-D on a line.

If the account name is not reserved, conforms to the requirements
(4 to 8 letters or numbers), and does not yet exist, it will be
installed with a dedicated `gigofs` group.

The script installs a `public_gopher` directory and a bare `gopher.git`
repository, together with a git post-update hook for publication
of `gopher.git` contents into `public_gopher` whenever new content
is pushed into the former.  The config of `gopher.git` is populated
with pseudonymous entries to prevent leaking of personal data;
however, it is up to the users to make sure not to commit locally
with compromising user.name and user.email configurations!

With option '-b', the gopher directory and repository both will be
empty and ready for uploading (push) an external existing git repo.
Otherwise, a simple gophermap will be added to the gopher directory,
and the result will be commited to the repository, making the latter
being ready for cloning into an external new git repository.

Public-keys will be added to the new user's `.ssh/authorized_keys` file.

#### managing user accounts

Simple communication with users having `basics` git-shell commands
is possible through text files handled on the administrator side by
`msgadm.sh` and by the `read/write/clear` commands on the user side.

The `msgadm.sh` script displays a list of all user accounts and
whether they have any pending (unanswered) messages in their outbox.
After selection of a user, the administrator can then clear their
inbox or write a reply (therefore clearing the outbox flag) using
the editor defined in `$EDITOR` environment variable.

The administrator can permit users to keep private additional git
repositories with the `privrep.sh` script. This will activate the
`private/public` subcommands of the `repos` script, which remove/add
the `git-daemon-export-ok` file to the repository in question.  By
default, all additional repos except for `gopher.git` contain this
file and therefore may be accessible (public) from outside through
`git daemon` (see below).

#### exporting additional git repos

The `gitexplist.sh` script puts together a list of all `*.git`
repositories found in `/var/local/` (meant for common host-wide
repos) as well as all additional user repos in their home directories
in the `r` subdirectory and containing `git-daemon-export-ok` in
their `.git` (see above, e.g interactive git-shell access).

This list for example could be published through gopher for external
users to find the various repositories which can then be cloned
through git-daemon, if this is running on the system.

The script `gitdaemon.sh` provides an example of running `git daemon`
with the correct settings. On a productive system, this might be
set up through `init` or `inetd` or similar means. For testing or
on small systems, it is also feasible to run the script in the
background or a detached terminal under an unprivileged user account.

#### interactive git-shell access

If the account is installed with the template `none` then no
interactive git-shell access will be possible, and login attempts
will fail.  In that case, the user will have no possibility to
interact with the system other than through git access to the
`gopher.git` repository.

Various types of script environments for git-shell can be set up.
On `dome.circumlunar.space` the `basics` template is used.

##### basics git-shell access

This template provides several scripts to the user for interactive access.

- `help` : provides a short description of available commands
- `stat` : displays system information and size of user's home directory
- `tidy` : searches for all `*.git` directories and does `git gc` and `fsck`
- `read` : permits reading of messages from the system administrator
- `write` : permits writing of messages to the system administrator
- `schat` : call the simple local shell chat 'schat' if present
- `clear` : clears all messages to the system administrator
- `repos` : permits managing of additional repositories
- `mango` : provides commands for reinstalling initial gopherhole, or even
  a completely bare gopherhole allowing to push a remote working repo
  *Warning: destroys contents!*

The `repos` command allows to add or remove additional repositories
(which by default are in the directory `r` in the user's home), and
if the user has been given permission by the administrator (using
the `privrep.sh` script, see above), also to block or permit access
by the git daemon, i.e from the outside as `git://host/~user/repo`
for cloning and pulling.

The `mango` ("manage gopherhole") command provides the possibility to
reinitialize the gopherhole and `gopher.git` as it was when the account
was created, or (with the `bare` subcommand) to have a completely empty
gopherhole and `gopher.git` (except for the publication githook); this
allows to push content from an existing (working and already populated)
remote repo.
*Warning: These commands will destroy any existing gopherhole content!*

The `schat` command checks whether a `schat` command is available on the
standard path, and if so executes it. This might be the simple shell chat
[schat]( git://circumlunar.space/schat ) script.

#### git-gopher access

The main purpose of this script suite is to permit users to publish
content at the address `gopher://host/~user` through the `gopher.git`
repository.

Initially, i.e after account generation, users should clone the repo with
`git clone ssh://USER@dome.circumlunar.space:1010/home/USER/gopher.git`
where `USER` is the account name and `dome...1010` is the host's IP
and sshd port. Then they should set up git configuration in that directory
to prevent information leaks:

	cd gopher
	git config --local user.name "joe sixpack"
	git config --local user.email "joe@example.com"

or whatever other name and email is desired.
Otherwise, the local information will be used and cannot be removed
later on from the `gopher.git` repo!

In the local `gopher` working directory, the user may then
add/remove/rename files and directories at will, keeping in mind
that this will be published immediately through the gopher server
(e.g gophernicus) on the host side after commiting and pushing back
to the remote.

---

## overview of scripts

Most scripts will display usage information when launched without arguments.

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

+ `none` contains only `non-interactive-login` to inform the
  user that interactive access is blocked
+ `basics` contains commands for housekeeping, read/write admin messages,
  and handling of additional git repos;
  *file names are hardcoded in scripts!*

### msgadm.sh

admin script for user communication

### gitdaemon.sh

script for easy launching of git-daemon in a terminal without detaching,
exporting a common (system-wide) directory as well as additional user repos

### gitexplist.sh

script to generate list of externally available git repos in
common `/var/local` and `/home/USER/r/` directories

### privrep.sh

admin script to set file in user's directory permitting them
to switch additional repos between public/exported and private/hidden
with the `repos` command in `templates/basics/` 

### status.cgi

gopher query cgi script to report status of given submission ID
(generated and displayed to submitting user by signup script)

---

*(2019-Mar // HB9KNS)*

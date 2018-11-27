# gigof : framework for public Git gopher server

This script suite is used to run the git-gopher-services on
gopher://dome.circumlunar.space/.

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

The system needs to provide a standard POSIX toolchain.
In addition, administrative tools like `sudo` and `adduser`
are required. The repective commands currently are hard coded,
i.e the scripts require manual modifications for other tools.

In addition, `ssh` and `gophernicus` (or another gopher server)
must be installed and working; management of these tools will
not be covered here.

#### installing submission request user

To permit future users to submit their desired user/account
names and public ssh keys for access, the script `instsign.sh`
installs a special account (named `new` by default) which has
the script `signup.sh` as login shell.

It makes use of a special directory `/var/local/accounts/`
for communicating submission status between the various
scripts for account management.
This directory must exist before the script is started
and could be generated by `sudo mkdir -p /var/local/accounts`
(with `-p` to generate `/var/local` if necessary).
Its name can be changed in the script at the beginning if desired,
but then also `status.cgi` and `setstat.sh` should be modified.

Finally, with `passwd new` (or the modified account name)
a password for remote login must be set, typically also `new`
or something similarly simple: this must be published anyway,
for prospective users to be able to submit applications.

#### submitting new user account requests

This workflow is on the user side. Prospective users must know
the sshd port and the host IP, so that they may log in as the
`new` user described above. Then they may enter their desired
user name (which is sanitized to be 4 to 8 characters long,
only letters and numbers) and ssh public key material. If they
do not provide any functional pubkey, login to the account will
not be possible.

The `signup.sh` script has a builtin timeout of about 5 min, i.e
an account request must be finished in that time, otherwise the
process will abort.

If successful, the signup process will report back to the user
a submission ID number for later reference. Users may look up
the status with help of that number by submitting it to the
`status.cgi` script reachable through the gopher server on the
gigof host. If the request is accepted and the account installed,
they can connect to it with ssh and git push/pull to their repos.

By default, one repository is installed, named `gopher.git` and
located in the user's home directory, which is linked to the
personal gopherhole located under `public_gopher` in the home.
It contains a git hook automatically doing a `git pull` into the
gopherhole whenever the user pushes content to `gopher.git` and
therefore updating the gopherhole.

If permitted by the administrator, users may install additional
git repos, which may be exported through git-daemon; see below.

#### processing submission requests

Submissions can be viewed and managed with `setstat.sh` which
lists the pending and processed requests when called without
arguments, or permits to manually set a status given as argument.

Users can submit a desired account name and ssh pubkey material,
all saved in the file `/var/local/accounts/submissions.txt` as
textfile. Administrators should get the data from that file and
feed it to the `addgg.sh` script as described below, then use
`setstat.sh` to report back to users acceptance or refusal of
the requests.

The CGI script `status.cgi` can be installed in a cgi-bin
gopher directory. It requires (as Gopher search query) a
submission ID number generated by `signup.sh` for reporting of
the corresponding submission status.

#### setting up user accounts



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

*(2018-Nov // HB9KNS)*

<!--
%\VignetteIndexEntry{Parallel Workers on Other Machines}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{vignette}
%\VignetteEngine{parallelly::selfonly}
-->


# Introduction

Sometimes it is not sufficient to parallize on a single computer - it
cannot provide all of the compute power we are looking for. When we
hit this limit, a natural next level is to look at other computers
near us, e.g. desktops in an office or other computers we have access
to remotely. In this vignette, we will cover how to run parallel R
workers on other machines. Sometimes we distinguish between local
machines and on remote machines, where _local_ machines are machines
considered to be on the same local area network (LAN) and that might
share a common file system. _Remote_ machines are machines that are on
a different network and that do not share a common file system with
the main R computer. In most cases the distinction between local and
remote machines does not matter, but in some cases we can take
advantages of workers being local.

Regardless of running parallel workers on local or remote machines, we
need a way to connect to the machines and launch R on them.


## SSH and R configuration (once)

### Verifying SSH access

The most common approach to connect to another machine is via Secure
Shell (SSH). Linux, macOS, and MS Windows all have a built-in SSH
client called `ssh`. Consider we have another Linux machine called
`n1.remote.org`, it can be accessed via SSH, and we have an account
`alice` on that machine. For the case of these instructions, it does
not matter whether `n1.remote.org` is on our local network (LAN) or a
remote machine on the internet. Also, to make it clear that we do not have to have the same username on `n1.remote.org` and on our local machine, we will use `ally` as the username on our local machine.

To access the `alice` user account on `n1.remote.org` from our local
computer, we open a terminal on the local computer and then SSH to the
other machine as:

```sh
{ally@local}$ ssh alice@n1.remote.org
alice@n1.remote.org's password: *************
{alice@n1}$ 
```

The commands to call are what follows after the prompt. The prompt on
our local machine is `{ally@local}$`, which tells us that our username
is `ally` and the name of the local machine is `local`.  The prompt on
the `n1.remote.org` machine is `{alice@n1}$`, which tells us that our
username on that machine is `alice` and that the machine is called
`n1` on that system.

To return to our local machine, exit the SSH shell by typing `exit`;

```sh
{alice@n1}$ exit
{ally@local}$ 
```

If we get this far, we have confirmed that we have SSH access to this
machine.


### Configure password-less SSH access

Launching parallel R workers is typically done automatically in the
background, which means it cumbersome, or even impossible, to enter
the SSH password for each machine we wish to connect to. The solution
is to configure SSH to connect with _public-private keys_, which
pre-establish SSH authentication between the main machine and the
machine to connect to. As this is common practice when working with
SSH, there are numerous online tutorials explaining how to configure
private-public SSH key pairs. Please consult one of them for the
details, but the gist is to use (i) `ssh-keygen` to generate the
public-private SSH keys on your local machine, and then (ii)
`ssh-copy-id` to deploy the public key on the machine you want to
connect to.

Step 1: Generate public-private SSH keys locally

```sh
{ally@local}$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/ally/.ssh/id_rsa): 
Created directory '/home/ally/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/ally/.ssh/id_rsa
Your public key has been saved in /home/ally/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:Sx48uXZTUL12SKKUzWB77e/Pm3TifqrDIbOnJ0pEWHY ally@local
The key's randomart image is:
+---[RSA 3072]----+
|        o E=..   |
|       + ooo+.o  |
|      . ..o..o.o |
|       o ..o .+ .|
|        S   .... |
|       + =o..  . |
|        * o= ...o|
|       o .o.=..++|
|        ...=.++=*|
+----[SHA256]-----+
```


Step 2: Copy the public SSH key to the other machine

```sh
{ally@local}$ ssh-copy-id alice@n1.remote.org
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/ally/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
alice@n1.remote.org:s password: *************

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'alice@n1.remote.org'"
and check to make sure that only the key(s) you wanted were added.
```

At this point, we should be able to SSH to the other machine without
having to enter a password;

```sh
{ally@local}$ ssh alice@n1.remote.org
{alice@n1}$
```

Type `exit` to return to your local machine.

Note, if you later want to connect to other machines,
e.g. `n2.remote.org` or `hpc.my-university.edu`, you may re-use the
above generated keys for those systems to. In other words, you do not
have to use `ssh-keygen` to generate new keys for those machines.


### Verifying R exists on the other machine

In order to run parallel R workers on another machine, it (i) needs to
be installed on that machine, and (ii) ideally readily available by
calling `Rscript`. Parallel R workers are launched via `Rscript`,
instead of the more commonly known `R` command - both come with all R
installation, i.e. if you have one of them, you have the other too.

To verify that R is installed on the other machine, SSH to the machine and call `Rscript --version`;

```sh
{ally@local}$ ssh alice@n1.remote.org
{alice@n1}$ Rscript --version
Rscript (R) version 4.4.2 (2024-10-31)
```

If you get:

```sh
{alice@n1}$ Rscript --version
Rscript: command not found
```

then R is either not installed on that machine, or it cannot be
found. If it is installed, but cannot be found, make sure that
environment variable `PATH` his configured properly on that machine.


### Final checks

With password-less SSH access, and R being available, on the other
machine, we should be able to SSH into the other machine and query the
R version in a single call:

```sh
{ally@local}$ ssh alice@n1.remote.org Rscript --version
Rscript (R) version 4.4.2 (2024-10-31)
{ally@local}$
```

This is all that is needed to launch one or more parallel R workers on
machine `n1.remote.org` running under user `alice`. We can test this
from within R with the **parallelly** package using:

```sh
{ally@local}$ R --quiet
library(parallely)
cl <- makeClusterPSOCK("n1.remote.org", user = "alice")
print(cl)
#> Socket cluster with 1 nodes where 1 node is on host 'n1.remote.org'
#> (R version 4.4.2 (2024-10-31), platform x86_64-pc-linux-gnu)
parallel::stopCluster(cl)
```

If you want to run parallel workers on other machines, repeat the
above for each machine.  After this, you will be able to launch
parallel R workers on these machines with little efforts.


### Machine-specific SSH customization (recommended)

Some machines do not use the default port 22 to answer on SSH
connection requests. If the machine uses another port, say, port 2201,
then we canspecify that via option `-p port`, when we connect to it,
e.g.

```sh
{ally@local}$ ssh -p 2201 alice@n1.remote.org
```

In R, we can specify argument `port=port` as in:

```sh
cl <- makeClusterPSOCK("n1.remote.org", port = 2201, user = "alice")
```

Now, it can be tedious to have to remember custom SSH ports and
usernames when setting up remote workers in R. It also adds noise and
distraction having such details in the R script, and not to mention
the fact that the R script has a specific username hardcoded into the
code makes the script less reproducible for other users - they need to
change the code to match their username. One way to avoid having to
give specific SSH options when calling `ssh` in the terminal, or
`makeClusterPSOCK()` in R, is to configure these settings in SSH. This
can be done via a file called `~/.ssh/config` _on your local
machine_. This file does not exist by default, so you would have to
create it yourself, if missing. It is a plain text file, so you should
use a plain text editor to create and edit it.

To configure SSH to use port 2201 and username `alice` whenever
connecting to `n1.remote.org`, the `~/.ssh/config` file should
contain the following entry:

```plain
Host n1.remote.org
  User alice
  Port 2201
```

With this, we can connect to `n1.remote.org` by just using:

```sh
{ally@local}$ ssh n1.remote.org
{alice@n1}$ 
```

SSH will then connect to the machine as if we had specified also `-p
2201` and `-l alice`. These settings will also be picked up when we
connect via R, meaning the following will also work:

```sh
cl <- makeClusterPSOCK("n1.remote.org")
```

To achieve the same for other machines, add another entry for them,
e.g.

```plain
Host n1.remote.org
  User alice
  Port 2201

Host n2.remote.org
  User alice
  Port 2201

Host hpc.my-university.edu
  User alice.bobson
```

When hosts on the same system share the same setting, one can use
globbing to configure them the same way.  For instance, the above can
be shorted to:

```plain
Host n?.remote.org
  User alice
  Port 2201

Host hpc.my-university.edu
  User alice.bobson
```

Being able to connect to remote machines by just specifying their
hostnames is convenient and simplifies also the R code.  Because of
this, we recommend setting up also `~/.ssh/config`.


# Examples

## Example: Two parallel workers on a single remote machine

Our first example sets up two parallel workers on the remote machine
`n1.remote.org`. For this to work, we need SSH access to the machine,
and it must have R installed, as explained in the above
section. Contrary to local parallel workers, the number of parallel
workers on remote machines is specified by repeating the machine name
an equal number of times;

```r
library(parallelly)
workers <- c("n1.remote.org", "n1.remote.org")
cl <- makeClusterPSOCK(workers, user = "alice")
print(cl)
#> Socket cluster with 2 nodes where 2 nodes are on host 'n1.remote.org'
#> (R version 4.4.2 (2024-10-31), platform x86_64-pc-linux-gnu).
```

_Comment_: In the **parallel** package, a parallel worker is referred
to a parallel node, or short _node_, which is why we use the same term
in the **parallelly** package.

Note, contrary to parallel workers running on the local machine,
parallel workers on remote machines are launched sequentially, that is
one after each other. Because of this, the setup time for a remote
parallel cluster will increase linearly with the number of remote
parallel workers.

_Technical details_: If we would add `verbose = TRUE` to
`makeClusterPSOCK()`, we would learn that the parallel workers are
launched in the background by R using something like:

```
'/usr/bin/ssh' -R 11058:localhost:11058 -l alice n1.remote.org Rscript ...
'/usr/bin/ssh' -R 11059:localhost:11059 -l alice n1.remote.org Rscript ...
```

This tells us that there is one active SSH connection per parallel
worker. It also reveals that that each of these connections uses a so
called _reverse tunnel_, which is used to establish a unique
communication channel between the main R process and the corresponding
parallel worker. It also this use of reverse tunneling that avoids
having to configure dynamic DNS (DDNS) and port-forwarding in our
local firewalls, which is cumbersome and requires administrative
rights. When using **parallelly**, there is no need for administrative
rights - any non-privileged user can launch remote parallel R workers.


## Example: Two parallel workers on two remote machines

This example sets up a parallel worker on each of two remote machines
`n1.remote.org` and `n2.remote.org`. It works very similar to the
previous example, but now the two SSH connections go to two different
machines rather than the same.

```r
library(parallelly)
workers <- c("n1.remote.org", "n2.remote.org")
cl <- makeClusterPSOCK(workers, user = "alice")
print(cl)
#> Socket cluster with 2 nodes where 1 node is on host 'n1.remote.org'
#> (R version 4.4.2 (2024-10-31), platform x86_64-pc-linux-gnu), 
#> 1 node is on host 'n2.remote.org' (R version 4.4.2 (2024-10-31),
#> platform x86_64-pc-linux-gnu)
```

_Technical details_: If we would add `verbose = TRUE` also in this
case, we would see:

```
'/usr/bin/ssh' -R 11464:localhost:11464 -l alice n1.remote.org Rscript ...
'/usr/bin/ssh' -R 11465:localhost:11464 -l alice n2.remote.org Rscript ...
```

Recall, if we have configured SSH to pick up the username `alice` from
`~/.ssh/config` on our local machine, as shown in the previous
section, we could have skipped the `user` argument, and just used:

```r
workers <- c("n1.remote.org", "n2.remote.org")
cl <- makeClusterPSOCK(workers)
```

Note how these instructions for setting up a parallel cluster on these
two machines would be the identical for another user that has
configured their personal `~/.ssh/config` file.


## Example: Three parallel workers on two remote machines

When we now understand that we control the number of parallel workers
on a specific machine by replicate the machine name, we also know how
to launch different number of parallel workers on different machines.
From now on, we will also assume that the remote username no longer
has to be specified, because it has already been configured via the
`~/.ssh/config` file.  With this, we can sets up two parallel workers
on `n1.remote.org` and one on `n2.remote.org`, by:

```r
library(parallelly)
workers <- c("n1.remote.org", "n1.remote.org", "n2.remote.org")
cl <- makeClusterPSOCK(workers)
print(cl)
#> Socket cluster with 3 nodes where 2 nodes are on host 'n1.remote.org'
#> (R version 4.4.2 (2024-10-31), platform x86_64-pc-linux-gnu), 
#> 1 node is on host 'n2.remote.org' (R version 4.4.2 (2024-10-31),
#> platform x86_64-pc-linux-gnu)
```

Again, the `user` argument does not have to be specified, because it is configured in `~/.ssh/config`.

To generalize to many workers, we can use the `rep()` function. For example,

```r
workers <- c(rep("n1.remote.org", 3), rep("n2.remote.org", 4))
```

sets up three workers on `n1.remote.org` and four on `n2.remote.org`,
totaling seven parallel workers.


## Example: A mix of local and remote workers

As an alternative to `makeClusterPSOCK(n)`, we can use
`makeClusterPSOCK(workers)` to set up parallelly workers running on
the local machine. By convention, the name `localhost` is an alias to
your local machine. This means, we can use:

```sh
library(parallelly)
workers <- rep("localhost", 4)
cl_local <- makeClusterPSOCK(workers)
print(cl_local)
#> Socket cluster with 4 nodes where 4 nodes are on host 'localhost'
#> (R version 4.4.2 (2024-10-31), platform x86_64-pc-linux-gnu)
```

to launch four local parallel workers. Note how we did not have to
specify `user = "ally"`. This is because the default username is
always the local username. Next, assume we want to add another four
parallel workers running on `n1.remote.org`. We already know we can
set these up as:

```sh
library(parallelly)
workers <- rep("n1.remote.org", 4)
cl_remote <- makeClusterPSOCK(workers, user = "alice")
print(cl_remote)
#> Socket cluster with 4 nodes where 4 nodes are on host 'n1.remote.org'
#> (R version 4.4.2 (2024-10-31), platform x86_64-pc-linux-gnu).
```

At this point, we have two independent clusters of parallel workers:
`cl_local` and `cl_remote`. We can combine them into a single
cluster using:

```r
cl <- c(cl_local, cl_remote)
print(cl)
#> Socket cluster with 8 nodes where 4 nodes are on host 'localhost'
#> (R version 4.4.2 (2024-10-31), platform x86_64-pc-linux-gnu), 4
#> nodes are on host 'n1.remote.org' (R version 4.4.2 (2024-10-31),
#> platform x86_64-pc-linux-gnu)
```

To emphasize the usefulness of customizing our SSH connections via
`~/.ssh/config`, if the remote username would already have been
already configured there, we would be able to set up the full cluster
in one single call, as in:

```sh
library(parallelly)
workers <- c(rep("localhost", 4), rep("n1.remote.org", 4)
cl <- makeClusterPSOCK(workers)
```


## Example: Parallel workers on a remote machine accessed via dedicated login machine

Sometimes a remote machine, where we want to run R, is only accessible
via an intermediate login machine, which in SSH terms may also be
referred to as a "jumphost".  For example, assume machine
`secret1.remote.org` can only be accessed by first logging into
`login.remote.org` as in:

```sh
{ally@local}$ ssh alice@login.remote.org
{alice@login}$ ssh alice@secret1.remote.org
{alice@secret1}$ 
```

To achive the same in a single SSH call, we can specify the "jumphost"
`-J hostname` option for SSH, as in:

```sh
{ally@local}$ ssh -J alice@login.remote.org alice@secret1.remote.org
{alice@secret1}$ 
```

We can use the `rshopts` argument of `makeClusterPSOCK()` to achieve
the same when setting up parallel workers.  To launch three parallel
workers on `secret1.remote.org`, use:

```r
workers <- rep("secret1.remote.org", 3)
cl <- makeClusterPSOCK(
  workers,
  rshopts = c("-J", "login.remote.org"),
  user = "alice"
)
```

A more convenient solution is to configure the jumphost in
`~/.ssh/config`, as in:

```plain
Host *.remote.org
  User alice

Host secret?.remote.org
  ProxyJump login.remote.org
```

This will cause any SSH connection to a machine on the `remote.org`
network to use username `alice`.  It will also cause any SSH
connection to machines `secret1.remote.org`, `secret2.remote.org`, and
so on, to use jumphost `login.remote.org`.  You can verify that all
this work by:

```sh
{ally@local}$ ssh login.remote.org
{alice@login}$
```

and then:

```sh
{ally@local}$ ssh secret1.remote.org
{alice@secret1}$ 
```

If the above work, then the following will work from within R:

```r
library(parallelly)
workers <- rep("secret1.remote.org", 3)
cl <- makeClusterPSOCK(workers)
```


# Special needs and tweaks

The above sections cover most common use cases for setting up a
parallel cluster from a local Linux, macOS, and MS Windows
machine. However, there are cases where there above does not work, or
you prefer to use another solution. This section aims to cover such
alternatives.


## Example: Remote workers ignoring any remote .Rprofile settings

To launch parallel workers skipping any `~/.Rprofile` settings on the
remote machines, we can pass option `--no-init-file` to `Rscript` via
argument `rscript_args`. For example,

```r
workers <- rep("n1.remote.org", 2)
cl <- makeClusterPSOCK(workers, rscript_args = "--no-init-file")
```

will launch two parallel workers on `n1.remote.org` ignoring any
`.Rprofile` files.


## Example: Use PuTTY on MS Windows to connect to remote worker

If you run on an MS Windows machine and prefer to use PuTTY to manage
your SSH connections, or for other reasons cannot use the built-in
`ssh` client, you can tell `makeClusterPSOCK()` to use PuTTY and your
PuTTY settings via various arguments.

Here is an example that launches two parallel workers on
`n1.remote.org` running under user `alice` connecting via SSH port
2201 using PuTTY and public-private SSH keys in file
`C:/Users/ally/.ssh/putty.ppk`:

```r
workers <- "n1.remote.org"
cl <- makeClusterPSOCK(
  workers, 
  user = "alice",
  rshcmd = "<putty-plink>",
  rshopts = c("-P", 2201, "-i", "C:/Users/ally/.ssh/putty.ppk")
)
```


## Example: Two remote workers running on MS Windows

Thus far we have considered our remote machines to run a Unix-like
operating system, e.g. Linux or macOS. If your remote machines run MS
Windows, you can use similar techniques to launch parallel workers
there as well.  For this to work, the remote MS Windows machines must
accept incoming SSH connections, which is something most Windows
machines are not configured to do by default. If you do not know set
that up, or if you do not have the system permissions to do so, please
reach out to you system administrator of those machines.

Assuming we have SSH access to two MS Windows machines,
`mswin1.remote.org` and `mswin2.remote.org`, everything works the same
as before, except that we need to specify also argument `rscript_sh =
"cmd"`;

```r
workers <- c("mswin1.remote.org", "mswin2.remote.org")
cl <- makeClusterPSOCK(workers, rscript_sh = "cmd")
```

That argument specifies that the parallel R workers should be launched
on the remote machines via MS Windows' `cmd.exe` shell.

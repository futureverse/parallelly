<!--
%\VignetteIndexEntry{parallelly: Setting up parallel workers on other machines}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{vignette}
%\VignetteKeyword{Rprofile}
%\VignetteKeyword{Renviron}
%\VignetteEngine{parallelly::selfonly}
-->


# Introduction

Sometimes it is not sufficient to parallization on a single computer -
it cannot provide all of the compute power we are looking for. When we
hit this limit, a natural next level is to look at other computers
near us, e.g. desktops in an office or other computers we have access
to remotely. In this vignette, we will cover how to run parallel R
workers on other machines. Sometimes we distingush between local
machines and on remote machines, where _local_ machines are machines
considered to be on the same local area network (LAN) and that might
share a common file system. _Remote_ machines are machines that are on
a different network and that do not share a common file system with
the main R computer. In most cases the distinction between local and
remote machines does not matter, but in some cases we can take
advantages of workers being local.

Regardless of running parallel workers on local or remote machines, we
need a way to connect to the machines and launch R on them.


## Setup (once)

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
SSH, there are numerous online tutorial explaining how to configure
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
machine `n1.remote.org` running under user `alice`. When can test this
from within R with the **parallelly** package using:

```sh
{ally@local}$ R --quiet
cl <- parallelly::makeClusterPSOCK("n1.remote.org", user = "alice")
print(cl)
#> Socket cluster with 1 nodes where 1 node is on host 'n1.remote.org'
#> (R version 4.4.2 (2024-10-31), platform x86_64-pc-linux-gnu)
parallel::stopCluster(cl)
```

If you want to run parallel workers on other machines, repeat the
above for each machine.  After this, you will be able to launch
parallel R workers on these machines with little efforts.


# Examples

## Example: Two parallel workers on a single remote machine

Our first example sets up two parallel workers on the remote machine
`n1.remote.org`. For this to work, we need SSH access to the machine,
and it must have R installed, as explained in the above section. Contrary to local parallel workers, the number of parallel workers on remote machines is specified by repeating the machine name an equal number of times;

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
communication channel between the main R process and the correponding
parallel worker. It also this use of reverse tunneling that avoids
having to configure dynamic DNS (DDNS) and port-forwarding in our
local firewalls, which is cumbersome and requires administrative
rights. When using **parallelly**, there is no need for administrative
rights - any non-priviliged user can launch remote parallel R workers.


## Example: Two parallel workers on two remote machines

This example sets up a parallel worker on each of two remote machines
`n1.remote.org` and `n2.remote.org`. It works very similar to the previous example, but now the two SSH connections go to two different machiens rather than the same.

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


## Example: Three parallel workers on two remote machines

When we now understand that we control the number of parallel workers
on a specific machine by replicate the machine name, we also know how
to launch different number of parallel workers on different machines.
For example, to sets up two parallel workers on `n1.remote.org` and
one on `n2.remote.org`, we do:

```r
library(parallelly)
workers <- c("n1.remote.org", "n1.remote.org", "n2.remote.org")
cl <- makeClusterPSOCK(workers, user = "alice")
print(cl)
#> Socket cluster with 3 nodes where 2 nodes are on host 'n1.remote.org'
#> (R version 4.4.2 (2024-10-31), platform x86_64-pc-linux-gnu), 
#> 1 node is on host 'n2.remote.org' (R version 4.4.2 (2024-10-31),
#> platform x86_64-pc-linux-gnu)
```

To generalize to ar large number of workers, we can use the `rep()`
function, e.g.

```r
workers <- c(rep("n1.remote.org", 3), rep("n2.remote.org", 4))
```

will setup three workers on `n1.remote.org` and four on
`n2.remote.org`, totaling seven parallel workers.


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

If the username would be the same on the local and the remote
machines, we would be able to set it all up with:

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
option for SSH, as in:

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


## Example: Two remote workers running on MS Windows

To launch two parallel workers on two remove MS Windows machines,
`mswin1.remote.org` and `mswin2.remote.org`, everything works the same
as above, except that we need to also specify `rscript_sh =
"cmd"`. The specifies that the parallel R workers should be launched
via MS Windows' `cmd.exe` shell.  For this example, the two MS Windows
machines must accept incoming SSH connections.

```r
workers <- c("mswin1.remote.org", "mswin2.remote.org")
cl <- makeClusterPSOCK(workers, rscript_sh = "cmd")
```


## EXAMPLE: Local and remote workers

```r
## Same setup when the two machines are on the local network and
## have identical software setups
cl <- makeClusterPSOCK(
  workers,
  revtunnel = FALSE, homogeneous = TRUE,
  dryrun = TRUE, quiet = TRUE
)
```


## EXAMPLE: Remote worker running on Linux from MS Windows machine

```r
## Connect to remote Unix machine 'remote.server.org' on port 2200
## as user 'bob' from a MS Windows machine with PuTTY installed.
## Using the explicit special rshcmd = "<putty-plink>", will force
## makeClusterPSOCK() to search for and use the PuTTY plink software,
## preventing it from using other SSH clients on the system search PATH.
## The parallel worker is launched as:
## 'plink' -l bob -P 2200 -i C:/Users/bobby/.ssh/putty.ppk remote.server.org ...
cl <- makeClusterPSOCK(
  "remote.server.org", user = "bob",
  rshcmd = "<putty-plink>",
  rshopts = c("-P", 2200, "-i", "C:/Users/bobby/.ssh/putty.ppk"),
  dryrun = TRUE, quiet = TRUE
)

```


## EXAMPLE: Remote workers with specific setup


```r
## Setup of remote worker with more detailed control on
## authentication and reverse SSH tunneling
## The parallel worker is launched as:
## '/usr/bin/ssh' -l johnny -v -R 11000:gateway:11942 remote.server.org ...
## "R_DEFAULT_PACKAGES=... 'nice' '/path/to/Rscript' --no-init-file ...
cl <- makeClusterPSOCK(
  "remote.server.org", user = "johnny",
  ## Manual configuration of reverse SSH tunneling
  revtunnel = FALSE,
  rshopts = c("-v", "-R 11000:gateway:11942"),
  master = "gateway", port = 11942,
  ## Run Rscript nicely and skip any startup scripts
  rscript = c("nice", "/path/to/Rscript"),
  rscript_args = c("--no-init-file"),
  dryrun = TRUE, quiet = TRUE
)
```


## EXAMPLE: Remote worker running on Linux from RStudio on MS Windows

```r
## Connect to remote Unix machine 'remote.server.org' on port 2200
## as user 'bob' from a MS Windows machine via RStudio's SSH client.
## Using the explicit special rshcmd = "<rstudio-ssh>", will force
## makeClusterPSOCK() to use the SSH client that comes with RStudio,
## preventing it from using other SSH clients on the system search PATH.
## The parallel worker is launched as:
## 'ssh' -l bob remote.server.org:2200 ...
cl <- makeClusterPSOCK(
  "remote.server.org:2200", user = "bob", rshcmd = "<rstudio-ssh>",
  dryrun = TRUE, quiet = TRUE
)
```

##  Advanced Singularity usage

### Making containerized apps behave more like normal apps

In the third hour we are going to consider an extended example describing a containerized application that takes a file as input, analyzes the data in the file, and produces another file as output.  This is obviously a very common situation.

Let's imagine that we want to use the cowsay program in our `lolcow.sif` to "analyze data".  We should give our container an input file, it should reformat it (in the form of a cow speaking), and it should dump the output into another file.

Here's an example.  First I'll make some "data"

```
$ echo "The grass is always greener over the septic tank" > input
```

Now I'll "analyze" the "data"

```
$ cat input | singularity exec lolcow.sif cowsay > output
```

The "analyzed data" is saved in a file called `output`.

```
$ cat output
 ______________________________________
/ The grass is always greener over the \
\ septic tank                          /
 --------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

This _works..._ but the syntax is ugly and difficult to remember.

Singularity supports a neat trick for making a container function as though it were an executable.  We need to create a **runscript** inside the container. It turns out that our Singularity recipe file already contains a runscript.  It causes our container to print a helpful message.

```
$ ./lolcow.sif
This is what happens when you run the container...
```

Let's rewrite this runscript in the definition file and rebuild our container
so that it does something more useful.

```
BootStrap: library
From: ubuntu:latest

%runscript
    #!/bin/bash
    if [ $# -ne 2 ]; then
        echo "Please provide an input and an output file."
        exit 1
    fi
    cat $1 | cowsay > $2

%post
    echo "Hello from inside the container"
    sed -i 's/$/ universe/' /etc/apt/sources.list
    apt-get update
    apt-get -y install vim fortune cowsay lolcat

%environment
    export PATH=/usr/games:$PATH
    export LC_ALL=C
```

Now we must rebuild out container to install the new runscript.

```
$ sudo singularity build --force lolcow.sif Singularity
```

Note the `--force` option which ensures our previous container is completely overwritten.

After rebuilding our container, we can call the lolcow.sif as though it were an executable, and simply give it two arguments.  One for input and one for output.

```
$ ./lolcow.sif
Please provide an input and an output file.

$ ./lolcow.sif input output2

$ cat output2
 ______________________________________
/ The grass is always greener over the \
\ septic tank                          /
 --------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

### Bind mounting host system directories into a container

It's possible to create and modify files on the host system from within the container. In fact, that's exactly what we did in the previous example when we created output files in our home directory.

Let's be more explicit. Consider this example.

```
$ singularity shell lolcow.sif

Singularity lolcow.sif:~> echo wutini > ~/jawa.sez

Singularity lolcow.sif:~> cat ~/jawa.sez
wutini

Singularity lolcow.sif:~> exit

$ cat ~/jawa.sez
wutini
```

Here we shelled into a container and created a file with some text in our home directory.  Even after we exited the container, the file still existed. How did this work?

There are several special directories that Singularity _bind mounts_ into
your container by default.  These include:

- `/home/$USER`
- `/tmp`
- `/proc`
- `/sys`
- `/dev`

You can specify other directories to bind using the `--bind` option or the environmental variable `$SINGULARITY_BINDPATH`

Let's say we want to use our `cowsay.sif` container to "analyze data" and save results in a different directory.  For this example, we first need to create a new directory with some data on our host system.

```
$ sudo mkdir /data

$ sudo chown $USER:$USER /data

$ echo 'I am your father' > /data/vader.sez
```

We also need a directory _within_ our container where we can bind mount the host system `/data` directory.  We could create another directory in the `%post` section of our recipe file and rebuild the container, but our container already has a directory called `/mnt` that we can use for this example.

Now let's see how bind mounts work.  First, let's list the contents of `/mnt` within the container without bind mounting `/data` to it.

```
$ singularity exec lolcow.sif ls -l /mnt
total 0
```

The `/mnt` directory within the container is empty.  Now let's repeat the same command but using the `--bind` option to bind mount `/data` into the container.

```
$ singularity exec --bind /data:/mnt lolcow.sif ls -l /mnt
total 4
-rw-rw-r-- 1 ubuntu ubuntu 17 Jun  7 20:57 vader.sez
```

Now the `/mnt` directory in the container is bind mounted to the `/data` directory on the host system and we can see its contents.

Now what about our earlier example in which we used a runscript to run a our container as though it were an executable?  The `singularity run` command  accepts the `--bind` option and can execute our runscript like so.

```
$ singularity run --bind /data:/mnt lolcow.sif /mnt/vader.sez /mnt/output3

$ cat /data/output3
 __________________
< I am your father >
 ------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

But that's a cumbersome command.  Instead, we could set the variable `$SINGULARITY_BINDPATH` and then use our container as before.

```
$ export SINGULARITY_BINDPATH=/data:/mnt

$ ./lolcow.sif /mnt/output3 /mnt/metacow2

$ ls -l /data/
total 12
-rw-rw-r-- 1 ubuntu ubuntu 809 Jun  7 21:07 metacow2
-rw-rw-r-- 1 ubuntu ubuntu 184 Jun  7 21:06 output3
-rw-rw-r-- 1 ubuntu ubuntu  17 Jun  7 20:57 vader.sez

$ cat /data/metacow2
 ________________________________________
/  __________________ < I am your father \
| >                                      |
|                                        |
| ------------------                     |
|                                        |
| \ ^__^                                 |
|                                        |
| \ (oo)\_______                         |
|                                        |
| (__)\ )\/\                             |
|                                        |
| ||----w |                              |
|                                        |
\ || ||                                  /
 ----------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

For a lot more info on how to bind mount host directories to your container, check out the [singularity documentation](https://www.sylabs.io/guides/3.0/user-guide/).

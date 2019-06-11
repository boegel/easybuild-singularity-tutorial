*(note: this tutorial assumes you are using EasyBuild v3.9.2 or later)*

# EasyBuild: basic usage & typical workflow

To install software using EasyBuild, you typically specify the name of one or more easyconfig files.

## Searching for easyconfig files

Using ``eb --search``, you can query which easyconfig files are available:

```
$ eb --search cowsay
* /usr/easybuild/easyconfigs/c/cowsay/cowsay-3.04.eb
```

## Determining missing dependencies

#### ``eb --dry-run``

To check which dependencies are missing to install a particular easyconfig file, use ``eb --dry-run``:

```
eb cowsay-3.04.eb --dry-run
== temporary log file in case of crash /tmp/eb-WTJ8nB/easybuild-3ish_r.log
Dry run: printing build status of easyconfigs and dependencies
 * [ ] /usr/easybuild/easyconfigs/c/cowsay/cowsay-3.04.eb (module: cowsay/3.04)
== Temporary log file(s) /tmp/eb-WTJ8nB/easybuild-3ish_r.log* have been removed.
== Temporary directory /tmp/eb-WTJ8nB has been removed.
```

In this output, easyconfig files that are marked with ``[ ]`` (rather than ``[x]``) are still missing.

#### ``eb --missing``

Alternatively, you can use ``eb --missing`` to get a list of only missing modules:

```
eb cowsay-3.04.eb --missing
== temporary log file in case of crash /tmp/eb-L_Z9MO/easybuild-38T0hT.log

1 out of 1 required modules missing:

* cowsay/3.04 (cowsay-3.04.eb)

== Temporary log file(s) /tmp/eb-L_Z9MO/easybuild-38T0hT.log* have been removed.
== Temporary directory /tmp/eb-L_Z9MO has been removed.
```

## Inspecting installation procedure

To quickly inspect the installation procedure that EasyBuild would perform (without anything actually being done),
you can use ``eb --extended-dry-run`` (or ``eb -x``):

```
$ eb cowsay-3.04.eb -x
...
*** DRY RUN using 'Binary' easyblock (easybuild.easyblocks.generic.binary @ /usr/lib/python2.7/site-packages/easybuild/easyblocks/generic/binary.py) ***

== building and installing cowsay/3.04...
...
[install_step method]
  running command "./install.sh /home/centos/software/cowsay/3.04"
  (in /home/centos/build/cowsay/3.04/dummy-dummy/cowsay-3.04)

...
[sanity_check_step method]
Sanity check paths - file ['files']
  * bin/cowsay
Sanity check paths - (non-empty) directory ['dirs']
  (none)
Sanity check commands
  (none)
...
```

## Installing software

Once you have found an easyconfig file that matches your requirements, simply pass it to the ``eb`` command to install the software and generate an accompanying module file

```
$ eb cowsay-3.04.eb
== temporary log file in case of crash /tmp/eb-M_aWni/easybuild-Ju7oEF.log
== processing EasyBuild easyconfig /usr/easybuild/easyconfigs/c/cowsay/cowsay-3.04.eb
== building and installing cowsay/3.04...
== fetching files...
== creating build dir, resetting environment...
== unpacking...
== patching...
== preparing...
== configuring...
== building...
== testing...
== installing...
== taking care of extensions...
== restore after iterating...
== postprocessing...
== sanity checking...
== cleaning up...
== creating module...
== permissions...
== packaging...
== COMPLETED: Installation ended successfully
== Results of the build can be found in the log file(s) /home/centos/software/cowsay/3.04/easybuild/easybuild-cowsay-3.04-20190610.202533.log
== Build succeeded for 1 out of 1
== Temporary log file(s) /tmp/eb-M_aWni/easybuild-Ju7oEF.log* have been removed.
== Temporary directory /tmp/eb-M_aWni has been removed.
```

To get more details while the installation is running, you can use ``eb --trace``:

```
$ eb cowsay-3.04.eb --trace
...
== installing...
  >> running command:
	  [started at: 2019-06-10 20:34:23]
	  [output logged in /tmp/eb-Lko7Gt/easybuild-run_cmd-pFzeRb.log]
	  ./install.sh /home/centos/software/cowsay/3.04
  >> command completed: exit 0, ran in < 1s
...
```

## Using the installed software

In order to use the installed software, you should load the module file that corresponds with it.

First, check that the module is available for loading using the ``module avail`` command.
If it is not, you may need to extend the list of locations considered by the modules tool using ``module use``:

```
$ module avail cowsay
No modules found!
...

$ module use $HOME/modules/all
$ module avail cowsay

----- /home/centos/modules/all -----
   cowsay/3.04

$ module load cowsay/3.04

$ which cowsay
~/software/cowsay/3.04/bin/cowsay

$ cowsay Thanks to EasyBuild, I have more time for coffee!
 _______________________________________
/ Thanks to EasyBuild, I have more time \
\ for coffee!                           /
 ---------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||


## More information

* https://easybuild.readthedocs.io/en/latest/Typical_workflow_example_with_WRF.html
* https://easybuild.readthedocs.io/en/latest/Using_the_EasyBuild_command_line.html

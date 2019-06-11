# Configuring EasyBuild

Full list of available configuration options is available via ``eb --help``.

## Configuration levels

EasyBuild can be configured via 3 different configuration levels:

* configuration files (``/etc/easybuild.d/*.cfg``, ``$HOME/.config/easybuild/config.cfg``, ...)
  * INI format, output of ``eb --confighelp`` can be used as a starting point
* ``$EASYBUILD_*`` environment variables
* command line options for the ``eb`` command

You can mix these as you see fit.

## Important configuration settings

(see also https://easybuild.readthedocs.io/en/latest/Configuration.html#available-configuration-settings)

* ``sourcepath``: location for source files (default: ``$HOME/.local/easybuild/sources``)

* ``buildpath``: location for build directories (default: ``$HOME/.local/easybuild/build``)

* ``installpath``: installation prefix for software & modules (default: ``$HOME/.local/easybuild/{software,modules}``

* ``containerpath``: location for generated container recipes/images (default: ``$HOME/.local/easybuild/containers``)

* ``robot-paths``: locations that are considered when searching for easyconfig files (default: location to easyconfig files included with EasyBuild installation);
  see also https://easybuild.readthedocs.io/en/latest/Using_the_EasyBuild_command_line.html#robot-search-path

Default parent directory (``$HOME/.local/easybuild``) can be changed via ``prefix`` configuration option.

## Example configuration

Configure EasyBuild to use (subdirectories of) ``$HOME`` for locations of installed software/modules, source path,
generated container recipes/images, ...

For the build directories, we specify ``/dev/shm/$USER`` (which may speed up the compilation process).

```
export EASYBUILD_PREFIX=$HOME
export EASYBUILD_BUILDPATH=/dev/shm/$USER
```

## Inspecting current configuration

To inspect the current EasyBuild configuration, use ``eb --show-config``.

The most important configuration settings are shown, together with any that were set differently from the default.

For each configuration setting, the configuration level through which it was set is indicated.

Example output:
```
$ eb --show-config
#
# Current EasyBuild configuration
# (C: command line argument, D: default value, E: environment variable, F: configuration file)
#
buildpath      (E) = /dev/shm/example
containerpath  (E) = /user/example/containers
installpath    (E) = /user/example
packagepath    (E) = /user/example/packages
prefix         (E) = /user/example
repositorypath (E) = /user/example/ebfiles_repo
robot-paths    (D) = /software/EasyBuild/3.9.2/lib/python2.7/site-packages/easybuild_easyconfigs-3.9.2-py2.7.egg/easybuild/easyconfigs
sourcepath     (E) = /user/example/sources
```


## More information

* https://easybuild.readthedocs.io/en/latest/Using_the_EasyBuild_command_line.html


# License <a name="C1"/>

This Source Code Form is subject to the terms of the Mozilla
Public License, v. 2.0. If a copy of the MPL was not distributed
with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

```
        email: Andrey Makarov <mka-at-mailru@mail.ru>
 Project home: https://github.com/loafer-mka/version-stamper.git

               Copyright (c) Andrey Makarov 2023
```

# Content <a name="C2"/>

- [License](#C1)
- [Content](#C2)
- [About](#C3)
- [Installation and use](#C4)
  - [Options of version-stamper](#C4.1)
  - [Commands of version-stamper](#C4.2)
  - [Configuration file .version-stamper](#C4.3)
- [Improve version-stamper](#C5)
  - [Plugin internals](#C5.1)
    - [`__PLUGIN_XXX_NOTICE__`](#C5.1.1)
    - [`__PLUGIN_XXX_SAMPLE__`](#C5.1.2)
    - [`__PLUGIN_XXX_ATTRIB__`](#C5.1.3)
    - [`__PLUGIN_XXX_GETVER__`](#C5.1.4)
    - [`__PLUGIN_XXX_CREATE__`](#C5.1.5)
    - [`__PLUGIN_XXX_MODIFY__`](#C5.1.6)
  - [Unit-Tests](#C5.2)
- [Appendix](#C6)
  - [A little about git hooks](#C6.1)
  - [Overview of the git repository directory structure](#C6.2)

# About <a name="C3"/>

Version-stamper is a simple script for generating text files in different
programming languages containing information about the current version of
the project - conventionally called a “version stamp”.

The version information is based on the `git describe` command, limited
to tags of the form `vMJ.MN`, where `MJ` and `MN` are integer major and
minor version numbers, and the letter `v` can be replaced by any other
letter.

So, for example, in the C/C++ language, the generated stamp file may contain:

```
#ifndef __VERSION_H__
#       define  __VERSION_H__
#       define  VERSION_ID          0x0102014DL
#       define  VERSION_TEXT        "v1.2-333.branchname"
#       define  VERSION_DATE        "2023-11-06 20:16:40"
#       define  VERSION_SHORTDATE   "231106201640"
#       define  VERSION_UNIXTIME    1699291000LL
#       define  VERSION_BRANCH      "branchname"
#       define  VERSION_HOSTINFO    "your@email.org openSUSE Leap 15.5"
#       define  VERSION_AUTHORSHIP  "Your Name"
#       define  VERSION_DECLARATION "Copyright (c) Your Name 2023"
// information below based on parent commit's hash
#       define  VERSION_SHA_SHORT   "p:e2477886"
#       define  VERSION_SHA_LONG    "p:e2477886f1fff6ddac0e533f22d7be244674e064"
#endif
```

Support for different programming languages is provided by auxiliary
“plugins”, the list of which can be expanded. Currently supported:

- C/C++ language (values are represented by a set of macros)

- C# language (changes are written to traditional Properties/AssemblyInfo.cs)

- Makefile script (character set is determined)

- Matlab script (a class with constant fields is defined)

- Bash or Sh script (character set is determined)

- Windows cmd script (.bat, character set determined)

To support another language or an alternative representation of the
version stamp, you need to change or add the corresponding plugin.

If one project uses many subprojects in separate repositories, it may
happen that several different "stamps" from different subprojects must
be used simultaneously. To avoid confusion with matching identifiers
(for example, VERSION_TEXT) of different stamps, these identifiers can
be modified by adding specific prefixes and/or suffixes to them, for
example, `YOURPROJECT_VERSION_TEXT` or `VERSION_TEXT_YOURPROJECT`.
This and some other things are achieved by editing the .version-stamp
configuration file in the root of the project's working tree.

# Installation and use <a name="C4"/>

To use version-stamper, it is enough to ensure that the main version-stamper
script can be executed from the directories of your project. Version-stamper
can either be placed in any directory on the search path for executable
files (`PATH`), or simply copied to any directory, including included in
your project as a submodule or copy, so that it can be executed according
to an explicitly specified absolute or relative path to the version-stamper
script.

Usage:

```
   version-stamper [options] [commands]
```

The version-stamper parameters can be divided into two groups:

- only those that display information (for example, `--help`)

- creating files with version or configuration stamps

The first group of parameters has no side effects, and the second leads
to the formation of a “working environment” for version-stamper, including
creating (if not) a configuration file with default parameters, installing
git hooks, changing or creating `.gitignore` and `.gitattributes`.

When deleting version-stamp, you need to make sure that its configuration
file is deleted (`.version-stamper` in the project root) and that hooks
(same git hooks) are deleted, see the `.git/hooks/` directory, owned
by version-stamper. All hooks belonging to version-stamper contain the line:

```
export STAMPER_SUITE="Version suite v0.0-0.master"
```

where a specific version and branch of version-stamper are indicated
instead of v0.0-0.master.

## Options of version-stamper <a name="C4.1"/>

Options usually have what is called a short form (such as -V or -q) and
a long form (such as --version or --quiet). Parameters can be used
separately, or may require additional values. Thus, the -cd, --directory
and --git-hook parameters require a value that can be specified either
as an additional argument separated by a space:

```
your_project> ./tools/stamper/version-stamper --directory "/other/working/directory"
```

or using an assignment:

```
your_project> ./tools/stamper/version-stamper --directory="/other/working/directory"
```

Available options:

- `-V` or `--version`<br/>
  Print the version of version-stamper itself and exit.

- `-h` or `/?` or `--help` or `/help`<br/>
  Print this help and exit.

- `-v` or `--verbose`<br/>
  Print a lot of debugging information onto stderr.

- `-q` or `--quiet`<br/>
  Turn off verbose mode.

- `-cd PATH` or `--directory PATH`<br/>
  Specify the directory in which version-stamper should be executed.
  This can be any subdirectory of the project, the utility will determine
  the root of the project worktree (git worktree) to which the specified
  folder belongs (or the current one if `--directory` was not used).
  Note: version-stamper also tries to detect the fact that the folder
  being used belongs not just to the project, but to one of its submodules.

- `-l` or `--list`<br/>
  List available plugins and display their configuration - generated files
  with version stamps and inclusion of these files in `.gitignore` and
  `.gitattributes`.

```
  your_project> ./tools/stamper/version-stamper -l
  Folders:
     CURRENT_DIR=        /home/your_name/your_project
     GIT_DIR=            /home/your_name/your_project/.git
     ROOT_DIR=           /home/your_name/your_project
     SUPERPROJECT_DIR=   

     Plugin   = Target file                        Information
  -----------------------------------------------------------------------
     CS       = Properties/sample-AssemblyInfo.cs  config, fs: len=1571 2023-11-06 20:29:21
     BAT      = -                                  Not configured
     C        = -                                  Not configured
     M        = -                                  Not configured
     SH       = version.sh                         config, git: 2023-11-06 20:16:40 @9e4ee3e, fs: len=868 2023-11-06 20:29:22
     MAKEFILE = -                                  Not configured
```

  Plugin information contains an indication of how the plugin was launched
  (by command line argument or configuration parameter), information about
  this file in the file system (size and date) and information about this
  file in the git repository - date and hash of the commit. Some information
  may be missing.

  `VERSION_CURRENT_DIR` is the current directory in which version-stamper
  is executed. `VERSION_ROOT_DIR` is the root directory of the project's
  working tree (git worktree), `VERSION_GIT_DIR` is the `.git` folder of
  the repository, and `VERSION_SUPER_DIR` is an empty string in normal
  cases or the path to the root of the super project's working tree if
  this project is included as a submodule .

- `-p` or `--print`<br/>
  Print parsed information about current version.

```
  your_project> ./tools/stamper/version-stamper -p
  v1.2-333.branchname  2023-11-06 22:17:09  your@email.org openSUSE Leap 15.5
     VERSION_ID=            0102014D
     VERSION_TEXT=          v1.2-333.branchname
     VERSION_PREFIX=        v
     VERSION_MAJOR=         1
     VERSION_MINOR=         2
     VERSION_BUILD=         333
     VERSION_BRANCH=        branchname
     VERSION_DIRTY=       
     VERSION_DATE=          2023-11-06 22:17:09
     VERSION_SHORTDATE=     231106221709
     VERSION_UNIXTIME       1699298229
     VERSION_SHA_LONG=      47920119e1110edeeda572e5612ab211096fdc6a
     VERSION_SHA_SHORT=     47920119
     VERSION_HOSTINFO=      your@email.org openSUSE Leap 15.5
     VERSION_AUTHORSHIP=    Your Name
     VERSION_DECLARATION=   Copyright (c) Your Name 2023
     VERSION_COMMIT_AUTHOR= Your Name
     VERSION_COMMIT_EMAIL=  your@email.org
     VERSION_SUBMOD_NAME= 
     VERSION_SUBMOD_PATH= 
     VERSION_LEADER=      
     VERSION_TRAILER=     
     Note. The identifier names listed here are exposed in the plugin, not in the target file.
```

  Here version `v1.2` is the nearest tag containing the major and minor
  version numbers, 333 is the build number (the distance from the current
  commit to the tag), this information is returned by `git describe`.
  Version code `VERSION_ID`, equal to 0102014D, is a 32-bit number
  containing the major version number in the high byte, the minor number
  in the next byte, and build number in the low 16-bit word. The name of
  the current branch `branchname` is either the name of the attached
  branch, or calculated if HEAD is detached (which is often the case
  for submodules). Computation cannot guarantee the correctness of the
  calculation or selection if there may be more than one matching branch
  for a given commit.

  `VERSION_DIRTY` - flag of the changed working tree (not taking into
  account changes in version stamps). Indicated by the `+` symbol if there
  are changes unsaved in the repository. In this case, the `+` character
  is also appended to the branch name in `VERSION_TEXT`.

  `VERSION_DATE`, `VERSION_SHORTDATE` and `VERSION_UNIXTIME` - contain
  the current date (may differ from the commit date; especially for a
  modified working tree).

  `VERSION_SHA_LONG` and `VERSION_SHA_SHORT` - contain information about
  the current commit and its ancestors (in this case, the prefix `p:` is
  added before the hash). The ancestor hash is used in the `pre-commit`
  hook because the hash of the new commit is not yet known at this time.

  `VERSION_AUTHORSHIP` and `VERSION_DECLARATION` - taken from the
  `.version-stamper` configuration file, when it is created, they are
  initially assigned based on the username, git configuration and standard
  parameters in the `version-stamper-config` file.
  
  `VERSION_COMMIT_AUTHOR` and `VERSION_COMMIT_EMAIL` - retrieved from
  current commit description. If the repository is completely empty, then
  based on the username and e-mail in the git configuration.
   
  `VERSION_LEADER` and `VERSION_TRAILER` - are taken from the
  `.version-stamper` configuration file, when it is created, they
  initially remain either empty lines, and in the case of a submodule,
  `VERSION_LEADER` is formed from the name of the submodule. They set
  prefixes and suffixes of symbol names in version stamps (they determine
  the modification, for example, of the general `VERSION_TEXT` into a
  specific `YOURPROJECT_VERSION_TEXT`).

  The `--print` command always displays notations without a prefix and
  suffix for two reasons: firstly, it simplifies parsing in some scripts
  and, secondly, the prefix and suffix to the names are added by plugins;
  in the plugin text they are used without prefixes and suffixes, and
  plugins are considered adaptable to the needs of the project - changing
  them and developing your own are welcome.

  `VERSION_SUBMOD_NAME` and `VERSION_SUBMOD_PATH` match empty strings
  unless stamps are created for a project submodule. In this case, the
  `VERSION_SUPER_DIR` parameter also becomes non-empty.

- `-c` or `--config`<br/>
  Create a .version-stamper configuration file if it is missing and
  install the standard set of git hooks. The list of installed hooks is
  specified in the .version-stamper configuration file; if you change
  it, the subsequent stamp generation command will update the hooks in
  accordance with the new configuration. Hooks will also be updated when
  the version-stamper utility is updated.

- `-s` or `--setup`<br/>
  Install the hooks specified in the configuration file. Running the
  --generate or --config commands also installs hooks. This command is
  used to force hooks to update.

- `-g` or `--generate`<br/>
  Execute all configured plugins. This only applies to configured
  plugins in .version-stamper.

- `--git-hook GITHOOK`<br/>
  Use this option when version-stamper is running from git hook. It passes
  hook name (without path and leading '/' and/or '.'). This option turns
  on special processing during hook execution.
  Note: do not set it manually (except for test only), it must be used
  by corrresponding git hooks.

## Commands of version-stamper <a name="C4.2"/>

Along with the parameters listed above, the command line may contain
commands for launching plugins. If a stamp created by a plugin specified
on the command line is also created by a plugin configured in the
configuration file, then whether that stamp is included in `.gitignore`
or `.gitattributes` is determined by the configuration, not the command
line.

The command to execute the plugin looks like:

```
your_project> ./tools/stamper/version-stamper ... PLUGIN [plugin_options] FILE
```

Several commands can be specified on the command line to create version's
stamps; it is possible to create several stamps of the same plugin with
different file names (however, their content may be identical, so it’s
dubious)

There are only two valid parameters for the `plugin_options` plugin, and
they are mutually exclusive:

- `-i` or `--gitignore`<br/>
   When creating a stamp, include it in `.gitignore` as well

- `-a` or `--gitattributes`<br/>
   Add stamp parameters (usually the type of line ending used is eol=lf
   or eol=crlf) to the `.gitattributes` file.

Currently supported plugins and line terminator used:

- `CS` C# assembly properties, usually it is created by Visual Studio,
  not by a plugin; line ending CR+LF.

- `BAT` Windows Batch file; ending the line with CR+LF.

- `C` C-style defines; line ending is native, LF on Linux/Unix and
  CR+LF on Windows.

- `M` Matlab's class definition; line ending CR+LF.

- `SH` Shell script; line ending CR+LF.

- `MAKEILE` Makefile script; LF line ending.

This command creates or updates a file with the latest version information.
If such a file does not exist, a new file is created; otherwise, the file
is read and its version information is selectively changed. This allows
you to supplement such files with any additional information that will
be saved from update to update.

Example:

```
your_project> ./tools/stamper/version-stamper ... MAKEFILE -i build/version.mk
```

Stamps created by command line are not automatically updated; if you use
them, be sure to run the necessary commands in your project build scripts.

It is more convenient to configure the generation of the necessary stamps
in .version-stamper and update them either with one command
`version-stamper --generate`, or automatically with git hooks when creating
or changing commits.

If neither the options `-g`, `--generate`, `-c`, `--config`, nor the
command plugin executions are not specified, then version-stamper will
substitute the `default-cmd` configuration parameter instead of commands,
and if it is not specified or is empty, then `--help` will be used.

## Configuration file .version-stamper <a name="C4.3"/>

The .version-stamper configuration file is located at the root of the
project's working tree and contains:

- comment lines starting with the `#` character, these lines are skipped

- assignment of parameters in the form:

```
 parameter: value
```

After the colon there must be at least one whitespace character, followed
by the first non-whitespace character, starting with the value of the
parameter and continuing until the end of the line. If this name is a
file name and it contains spaces, then there is no need to put it in
quotes or escape it in any way.

Valid parameters:

1. `verbose` - talkative mode. true corresponds to the `--verbose` option
   on the command line, and false corresponds to `--quiet`. The `--verbose`
   and `--quiet` options (and their short forms) on the command line take
   precedence over the `verbose` configuration option. If nothing is
   specified, `--quiet` is assumed by default.

2. `abbrev` - number of characters in the short form of the hash, default
   8 characters.

3. `leader` and `trailer` are used to prefix the symbol names `VERSION_LEADER`
   and `VERSION_TRAILER`. Typically the values are either empty strings
   or the parameters are commented out, but for submodules the assumed
   value of `leader` is formed based on the submodule name.

4. `authorship` is used to assign `VERSION_AUTHORSHIP` and form a copyright
   or copyleft line (see the `declaration` parameter). Usually not needed,
   but some stamps (for example, for C#) contain information about copy.

5. `declaration` - copyright or copyleft line. Can be changed in any way...
   but do not forget that it complies with the license accepted in your
   project. By default, in the created configuration file, it is formed
   from the `STAMPER_DEFAULT_DECL` parameter (see the `version-stamper-conf`
   file from version-stamper), which specifies the beginning of the line
   (i.e. "Copyright (c)" or "Copyleft" and etc.), authorship (as in the
   `authorship` parameter) and the year of the first commit in the project
   or the current year if the project is still empty.

6. `default-cmd` - a command substituted by default if there are no
   essential commands and parameters on the version-stamper command line. 
   The usual value is either `--help` (suitable for just started projects),
   or `--list` and/or `--print`, which can be convenient when you are
   already used to the version-stamper command and it is more important
   to get information about current version and/or configuration.

7. List of stamps generated by default. Differs from the version-stamper
   command line commands that execute plugins only by having a `plugin-`
   prefix before the plugin name.<br/>
   <br/>
   `plugin-PLUGIN [-i | --gitignore | -a | --gitattributes ] FILE`<br/>
   <br/>
   This is done to prevent accidental coincidence of the name of any plugin
   with some configuration parameter (on the command line, all other
   parameters begin with `-` or `--` and are thus syntactically highlighted,
   the chance of an error is already small, and in the configuration,
   the parameters do not have a clearly distinguishing feature).
   <br/>
   <br/>
   For supported plugins, see the sections on version-stamper commands and
   the general overview. As with the command line, it is possible to specify
   multiple stamps corresponding to one plugin on separate lines.

8. `hooks` lists the git hooks to be activated. It is possible to specify
   a task in the form of an empty line, indicating that no hooks
   need to be installed. Installed hooks ensure automatic execution
   of version-stamper in cases where git makes changes to the repository
   and current information is updated - commit hashes, date and time,
   build number, etc.

If measures are taken to ensure that `version-stamper --generate` is
executed every time during the build process, then keeping the stamps
more or less up to date is not required, but may still be recommended.

If you do not need to install hooks, then leave `hooks` as an empty
line (commented out corresponds to the standard set). It makes sense to
change the proposed set in cases where the project requires the installation
of its own hooks and they begin to conflict with version-stamper's hooks.
Reducing the set of resellers will simply reduce the number of cases in
which stamps will be automatically rebuilt.

Specifying `pre-commit` and `post-commit` at the same time is redundant,
but not critical.

Hooks are updated when the version of version-stamper itself is updated
and when the path in which it should be executed changes. Calling
version-stamper from a hook is done in the same way that was used when
executing the version-stamper command, leading to updating hooks. If
version-stamper was launched using an explicitly specified path, then the
same path will be used in the hook. This makes it easy to include
version-stamper in your project - you simply place it somewhere in your
project tree and call it on a relative path, then it adapts the hooks to
run version-stamper from that location.

Some properties of hooks:

- `pre-commit`

   OK: version stamps (if they are tracked and not included in `.gitignore`)
   can be changed immediately before a commit and then included in it
   without special actions.

   NOT OK: SHA contains information about the ancestor commit, not the
   current commit. Particularly difficult are commits that replace existing
   ones (`--amend`), in which the current commit is deleted, and in its
   place a new (unknown at the time the hook is fired) commit is
   created, inheriting the ancestors of the one being undone, of which
   there may be not one, but several, if the commit being replaced was
   a merge.

   NOT OK: the type of commit (amend, message-only, squash, etc.) is
   difficult to determine, the information available in pre-commit is
   insufficient for this. You have to use tricks.

- `post-commit`

   OK: SHA corresponds to the actual commit just created.

   NOT OK: version stamps are updated after a commit is created, and if
   they are tracked by the repository, the working tree becomes changed
   (which looks strange when there are still changes after the commit and
   you can’t get rid of it). It is not recommended at all to bring version
   stamps under the control of the repository, and due to the difficulties
   in some git hooks, it is especially, but not always possible - the same
   stamp for C# is included in the project. If there is an option to NOT
   INCLUDE a stamp in the repository, then use the `--gitignore` or `-i`
   option to generate the stamp.

   NOT OK: this hook can be called repeatedly during the so-called squash
   commits.

   OK: the GIT_REFLOG_ACTION environment variable helps distinguish simple
   commits from special cases (rebase, merge, etc.).

- `post-checkout`

   OK: SHA contains the actual value.

   NOT OK: switching a branch or switching to a “detached head” mode
   changes the current branch and requires mandatory regeneration of
   stamps. It is advisable not to disable this hook.

   NOT OK: however, this can also lead to the collapse of squash operations
   if the stamp files are under the control of the repository (consecutive
   merging of commits is broken).

   OK: the GIT_REFLOG_ACTION environment variable helps distinguish simple
   switches (checkout) from special cases (rebase, merge, etc.).

- `post-rewrite`

   NOT OK: can be executed multiple times during a single squash operation

   OK: but there are arguments 'amend' or 'rebase' that clarify what is
   happening

   NOT OK: version stamps are updated after a commit is created, and if
   they are tracked by the repository, then the working tree becomes
   changed (which looks strange when there are still changes after the
   commit and you can’t get rid of it).

   OK: SHA contains the actual value.

- `post-merge`

   NOT OK: version stamps are updated after a commit is created, and if
   they are tracked by the repository, then the working tree becomes
   changed (which looks strange when there are still changes after the
   commit and you can’t get rid of it).

# Improve version-stamper <a name="C5"/>

## Plugin internals <a name="C5.1"/>

To create your own plugin, just create a file with a name corresponding
to `version-stamper-plugin-XXX`, where `XXX` is replaced by the name of
the plugin and place this file next to `version-stamper`. The plugin must
contain several functions; function names must also contain the name of
the plugin instead of `XXX`. For example, a function described here as
`__PLUGIN_XXX_NOTICE__` should be called `__PLUGIN_SH_NOTICE__` in the
case of a plugin for the `sh` scripting language.

During operation, `version-stamper` calculates many variables (see example
of the `version-stamper --print` command above), the names of such variables
begin with `VERSION_` and these names must be used to refer to the desired
values. But in the text of the created target stamp file, the names of
assigned variables can be anything and do not have to correspond to the
names of internal variables. In existing plugins, in most cases this is
the case, but not always - for example, you can look at the plugin for C#
(`version-stamper-plugin-CS`), which has almost nothing in common at all,
or at the plugin for Matlab (`version-stamper-plugin-M`), which has a
similar variable `VERSION_ID`, but in base 10, not 16, and a hexadecimal
`VERSION_HEX`, but as a string. Likewise, when calculating variables,
there are two different `VERSION_COMMIT_AUTHOR` and `VERSION_COMMIT_EMAIL`,
and in stamp files `VERSION_COMMIT_AUTHOR` is the concatenation of name
and mailing address.

Another feature is that in a large project there may be several parts,
each of which creates its own version stamp, but later when assembled
they are all used together. To avoid name confusion, it is possible to
add a prefix and/or suffix to variable names (in the `.version-stamper`
configuration they are called `leader` and `trailer`, respectively).
Accordingly, in plugins to correctly form variable names, you need to
use constructions of the form (for example, let there be a variable
`VERSION_TEXT`):

```
${VERSION_LEADER}VERSION_TEXT${VERSION_TRAILER} = "${VERSION_TEXT}"
```

In order not to avoid the use of poorly readable constructions, for all
typical variables their compound names are pre-constructed and assigned
to `NAME_...` variables, for example, for the mentioned variable
`VERSION_TEXT`, its name is already defined as `NAME_VERSION_TEXT` and
can be used in the plugin text clearer way:

```
${NAME_VERSION_TEXT} = "${VERSION_TEXT}"
```

The easiest way is to take any existing plugin as a basis and make the
necessary changes to it.

### `__PLUGIN_XXX_NOTICE__` <a name="C5.1.1"/>

This function prints a short description of this plugin to stdout. This
description is used by the `version-stamper --help` command when generating
a list of supported plugins.

For example, notice function may be:

```
function __PLUGIN_BAT_NOTICE__
{
	echo "   plugin-BAT        Windows Batch file; eol=CR+LF"
}
```

### `__PLUGIN_XXX_SAMPLE__` <a name="C5.1.2"/>

This function prints a one-line example of using the plugin to stdout.
This example is included in the `.version-stamper` configuration file
created by the `version-stamper --config` command. Normally, the output
line should begin with a comment character `#`, since the created
configuration file initially does not contain configured plugins - this
must be done by the project author. However, in special cases it may be
different.

Example:

```
function __PLUGIN_BAT_SAMPLE__
{
	echo "#plugin-BAT:      --gitignore  version.bat"
}
```

### `__PLUGIN_XXX_ATTRIB__` <a name="C5.1.3"/>

This function prints to stdout a set of parameters applied to the
generated version stamp in `.gitattributes`.

- `text eol=lf` for Unix/Linux files with `LF` line separator
- `text eol=crlf` for Windows files with line separator `CR+LF`
- `text` for files that may have different delimiters on different systems,
  for example regular `.c` or `.h` files.

Example:

```
function __PLUGIN_BAT_ATTRIB__
{
	echo "text eol=crlf"
}
```

*Note:* Updates to the `.gitattributes` and `.gitignore` files only occur
when a new version stamp file is created.

### `__PLUGIN_XXX_GETVER__` <a name="C5.1.4"/>

This function receives the text of the existing stamp from stdin and must
output to stdout the text with the version designation corresponding to
the contents of `VERSION_TEXT` (i.e. a string like "v1.2-333.branchname").
This text is used to compare the existing version of the stamp with the
one being created. If the version designation text is the same and the
working directory is “clean”, then the stamp file is not changed.

Typically this function can be implemented using simple sed or awk that
recognizes the desired pattern and returns the result.

*Note:* The existing template file is read before this function is
executed and line termination characters are converted to single
LF (Unix-style), this allows tools like grep, awk, sed, etc. to be used
without worrying about line breaks.

In the example with version stamps for `.bat` files, the stamp file contains
commands for assigning values, including, suppose it contains a command
like `set VERSION_TEXT=v1.2-333.branchname`, and the function should find
and return the substring `v1.2-333.branchname`. You can do it like this:

```
function __PLUGIN_BAT_GETVER__
{
	sed --binary --regexp-extended --silent \
		-e "s/^(\s*set\s+${NAME_VERSION_TEXT}=\s*)(.*)$/\\2/p"
}
```

The function searches the text for only the "strict" version designation
(i.e. the string must contain text with the key sequence VERSION_TEXT
with a prefix and suffix (i.e. `${NAME_VERSION_TEXT}`). This is done in
order to return an empty string instead of the version, if the prefix or
suffix of the environment variable names is changed: if the returned
string does not match the expected version, then the stamps will be
rebuilt, an empty string will naturally lead to a mismatch and replacement
of the stamp files.

### `__PLUGIN_XXX_CREATE__` <a name="C5.1.5"/>

This function is designed to create a new stamp file and is called when
the target file does not exist. The function receives an argument, which
is the name of the file to be created with a version stamp, into which
the required text should be written. When writing a stamp, you must use
the correct line ending characters (LF or CR+LF), for which it is
convenient to use one of the three available functions:

- `__STORE_LF__` - saves a file with single LFs

- `__STORE_CRLF__` - saves a file with CR+LF

- `__STORE_NATIVE_EOL__` - saves the file with LF delimiters on a unix-like
  system and CR+LF on Windows.

The text of the saved file is supplied to stdin, and the argument of the
function contains the name of the saved file. A typical implementation
pattern for such a function:

```
function __PLUGIN_BAT_CREATE__
{
    __STORE_NATIVE_EOL__ "$1" <<-END_OF_TEXT
		@echo off

		set ${NAME_VERSION_TEXT}=${VERSION_TEXT}
		set ${NAME_VERSION_BRANCH}=${VERSION_BRANCH}${VERSION_DIRTY}
		rem ...
END_OF_TEXT
}
```

### `__PLUGIN_XXX_MODIFY__` <a name="C5.1.6"/>

This function is used in cases where a stamp file already exists and
changes need to be made to it. The existing stamp is fed to stdin (with
LF line termination characters), and the function's only argument is the
name of the stamp file to write to. Like `__PLUGIN_CS_CREATE__` the function
must write a new stamp with the correct line ending characters.

The recommended practice is to find the required substrings in the original
stamp and replace them to match the new stamp. So in a typical case this
might be a call to sed or awk with a set of patterns to replace the old
version information with new ones.

It is not recommended to recreate the file again - the general idea is
that the stamp can be shortened compared to the one automatically created
or, conversely, supplemented with something new. That is why it is
recommended to simply replace the found values in the existing stamp,
leaving everything else unchanged.

In a particular case, the project authors may remove some unused part of
the version information from the stamp file (for example, commit hashes,
which sometimes correspond to the current commit and sometimes to its
ancestors). The behavior of the plugin in this case is at the discretion
of the plugin developer - the missing information can be ignored, or it
can be supplemented so that it is always present in this stamp.

Among the existing plugins, most ignore the absence of deleted information
(only what is found is updated), with the exception of a single plugin for
C# that ensures that the `AssemblyInformationalVersion` parameter is
present in the stamp.

Example:

```
function __PLUGIN_BAT_MODIFY__
{
	sed --binary --regexp-extended \
		-e "s/^(\s*set\s+)(\w*VERSION_TEXT\w*\s*)(=\s*)(.*)$/\\1${NAME_VERSION_TEXT}\\3${VERSION_TEXT}/" \
		-e "s/^(\s*set\s+)(\w*VERSION_BRANCH\w*\s*)(=\s*)(.*)$/\\1${NAME_VERSION_BRANCH}\\3${VERSION_BRANCH}${VERSION_DIRTY}/" \
	| __STORE_CRLF__ "$1"
}
```

This example finds strings containing key identifiers (`\w*VERSION_TEXT\w*`,
which match to the substring VERSION_TEXT with an arbitrary prefix and
suffix consisting of letters, numbers or an underscore - that is, this
is a "weak" check, because the VERSION_TEXT key sequence is important,
while prefix and suffix will not have an effect). Then line is split into
several fragments: 1) what is before the desired identifier, 2) the
identifier itself, 3) the assignment operator, 4) the old value and,
sometimes, 5) the continuation of the line after the value (the `set`
command everything after ` =` uses as a value and (5) is missing). After
that, the identifier (2) in the output line is replaced with a new one
(the prefix and/or suffix can be changed), the value (4) is replaced with
a new one, awhile the beginning of the line, the middle part with the
assignment operator and the rest of the line are preserved.

## Unit-Tests <a name="C5.2"/>

The test system is being developed and updated in a separate branch
`unit-tests`. The general idea is to keep everything related to tests in
the `./tests/` folder, which is excluded from the repository (see
`.gitignore`) in the main development branches. Thus, by simply cloning
version-stamper into your project, nothing extra beyond the required main
version-stamper working code will be cloned.

However, if debugging is required, or you will develop your own plugins,
then it makes sense to connect unit tests to the current branch. In the
simplest case, it is enough to simply extract all unit test files from
their branch to the current one (i.e. they are in an ignored folder,
this will not affect the state of the working tree in any way):

```
./tools/stamper> git checkout unit-tests -- ./tests/
./tools/stamper> git rm -r --cached tests/
./tools/stamper> ./tests/unit-tests.sh
```

And in cases where you also need to make changes to the test system, it
is advisable to merge your working branch (or `master`) with the
`unit-tests` branch and perform test corrections/additions directly
in the `unit-tests` branch:

```
./tools/stamper> git checkout unit-tests
./tools/stamper> git merge master
./tools/stamper> ...
```

In the `unit-tests` branch, the `.gitignore` file has been changed so
that files from the `./tests/` folder are included in the project, and
the `./tests/samples/` and `./tests/repos/` folders containing examples
and test repositories.

However, changes to unit tests can be made without merging branches, if
you first test them in the working branch (without including them in the
repository), and at the end simply switch to the `unit-tests` branch and
add the already corrected unit test files there one operation.

# Appendix <a name="C6"/>

## A little about git hooks <a name="C6.1"/>

Below are some typical execution sequences for git hooks. These sequences
should not be considered as a strict guide - they were obtained experimentally
and in reality can be modified depending on the actual situation (an empty
repository with no commits at all, a repository with history and a clean
working tree, a repository with local or prepared changes, etc.).

*Notes:* the word `old` denotes the "topmost" commit in history,
`new` - the new commit created by this operation. Sometimes
`new temp` is used - which denotes a new intermediate commit created to
apply changes sequentially. The term `distance` should be understood as
some kind of "commit number" or build number returned by the `git describe`
command. Can be thought of as a conditional "distance" from the current
commit to some commit in the past, perhaps to the initial commit.

**Regular** commit:

```
pre-commit  ->  prepare-commit-msg  ->  commit-msg  ->  post-commit
<---------------- o l d   c o m m i t ----------------><-- n e w -->
                                                       (distance increased)
```
                                                           
**Amend** commit:

```
pre-commit  ->  prepare-commit-msg  ->  commit-msg  ->  post-commit  ->  post-rewrite amend
<---------------- o l d   c o m m i t ----------------><------- n e w   c o m m i t ------->
                                                        (distance not changed)
```

**Squash** commit (**squash**):<br/>
Merging multiple commits is done in a loop where each new commit that is
merged is applied to an intermediate commit, thus summing up all the changes
in that intermediate commit. The final state of the intermediate commit
matches the desired result. However, if a failure occurs during such a
merge (which could be caused by an eavesdropper), then the entire sequence
can be rejected.

```
pre-rebase  ->  post-checkout  ->  (  prepare-commit-msg  ->  post-commit  ->  post-rewrite amend  ) ->  post-rewrite rebase
<-- o l d --><-- f i r s t -->        <----- p r e v -----><--- n e w   t e m p   c o m m i t ---><--- l a s t   c o m m i t --->
            (distance reduced here)  -------------------------------------------------------->    (distance remains reduced)
            (HEAD detached)                               (detached HEAD is promoted to temp commit)     (HEAD attached to branch)
                                    (ORIG_HEAD:old_sha)
                                    (AUTO_MERGE:other_sha)
```

The loop running for each commit in the merge calls the hooks
( prepare-commit-msg -> post-commit -> post-rewrite amend ). During this
cycle, ORIG_HEAD does not change. MERGE_MSG contains the text of the
message of the commit being added, and COMMIT_EDITMSG accumulates all
messages.

In the last iteration of the loop, the accumulated COMMIT_EDITMSG is
copied to SQUASH_MSG during prepare-commit-msg, after which the
COMMIT_EDITMSG is recreated from the SQUASH_MSG and additional text.
A REBASE_HEAD corresponding to the ORIG_HEAD is also added at the
beginning of the entire operation.

By post-commit time, the COMMIT_MSG file has been copied into the new
commit message, and SQUASH_MSG and AUTO_MERGE have been removed.

**Merge** commit; only partially tested, too many strategies and
methods of merging, incl. merging more than two branches at once
(octopus).

```
prepare-commit-msg  ->  commit-msg  ->  post-merge 0
<------- o l d   c o m m i t --------><--- n e w --->
                                      (distance increased by count of new commits on all ways)
(MERGE_HEAD - one or few SHAs to merge, one per line)
(ORIG_HEAD)
(MERGE_MODE - this is not strategy name, this is strategy options)
(MERGE_MSG)
```

## Overview of the git repository directory structure <a name="C6.2"/>

In the model case, we assume that we have a git repository in the `./MAIN`
directory, this repository has a `SUBMODULE` submodule (path to the
`./MAIN/SUBODULE` directory) and in addition the repository has an
additional working tree `./ WORKTREE`, while the submodule is also present
in the branch to which the `WORKTREE` working tree is configured.

A **Submodule** is characterized by a local path in the tree (in our
example, the `SUBMODULE` directory is located right at the root of the
repository), a source (the remote repository) and an optional branch.
Branch, if specified, simply specifies the initial state of the submodule;
Regardless of whether it is specified or not, the submodule will be in
the *detached head* state, and you can only switch it to the attached
state manually.

The submodule path is used as an "identifier" - information about the
submodule will be stored inside the repository folder `.git/modules/`
with the same relative path as it is located in the working tree.

A **working tree** is characterized by the path where it is located
(outside the main working tree), the assigned name of that tree, and
the branch to which the tree corresponds. In this case, a specific
branch cannot have more than one working tree.

The assigned worktree name is used to identify it within the
`.git/worktrees/` hierarchy.

```
folder  ./MAIN                  << a directory with a working tree (superproject) and a .git folder.
folder  .   ./SUBMODULE         << a project submodule, instead of a subfolder .git, contains a file
        .   .                      with a link to the desired subdirectory in the .git superproject.
 file   .   .   .git            << contains the relative path to the repository folder (here
        .   .   .                  "gitdir: ../.git/modules/SUBMODULE").
 file   .   .gitmodules         << superproject file describing the submodules included in it (name,
        .   .                      source address, local path, branch (if any)) as a configuration
        .   .                      file - you can use 'git config ...'.
folder  .   ./.git              << a .git subdirectory containing the superproject's repository data
        .   .   .                  and its nested submodule data and related work tree information.
 file   .   .   HEAD            << ref to the branch (in the form of ref: refs/heads/master or
        .   .   .                  commit hash for detached head).
 file   .   .   config          << superproject configuration (submodules have their own sections
        .   .   .                  with the source address and activity flag, but not a word about
        .   .   .                  subtrees).
 file   .   .   description     << usually not used, repository description.
 file   .   .   packed-refs     << list of references to commits in packed sets.
folder  .   .   ./branches      << usually an empty folder.
folder  .   .   ./hooks         << a set of repository interceptors (this repository and associated
        .   .   .                  work trees, but not submodules).
folder  .   .   ./info          << usually not used.
folder  .   .   ./logs          << a directory with files containing the history of branch head
        .   .   .                  movements.
folder  .   .   ./modules       << folder containing information about submodules (may be missing).
folder  .   .   .   ./SUBMODULE         << same relative path as the working directory.
 file   .   .   .   .   HEAD            << ref to the submodule branch.
 file   .   .   .   .   config          << submodule configuration.
 file   .   .   .   .   description     << not usually used, repository description.
 file   .   .   .   .   packed-refs     << list of references to commits in packed sets.
folder  .   .   .   .   ./branches      << usually an empty folder.
folder  .   .   .   .   ./hooks         << submodule's git hooks.
folder  .   .   .   .   ./info          << usually not used.
folder  .   .   .   .   ./logs          << a directory with files containing the history.
        .   .   .   .   .   ...
folder  .   .   .   .   ./objects       << directory with submodule repository objects.
folder  .   .   .   .   ./refs          << directory with refs (branches, tags) of the submodule.
folder  .   .   .   .   .   ./heads         << directory with local submodule branches.
 file   .   .   .   .   .   .   master      << a file with a commit hash of a submodule branch.
folder  .   .   .   .   .   ./remotes       << directory with remote submodule repositories.
folder  .   .   .   .   .   .   ./origin    << directory for the submodule's 'origin'.
 file   .   .   .   .   .   .   .   master  << a file with a commit hash of a remote branch.
folder  .   .   .   .   .   ./tags          << directory with submodule tags.
 file   .   .   .   .   .   .   v0.0        << a file with a commit hash of a tag.
folder  .   .   ./objects       << directory with superproject repository objects.
folder  .   .   .   ./00        << directory for objects whose hash starts with 00.
папки   .   .   .   .   ...
folder  .   .   .   ./FF        << directory for objects whose hash starts with FF.
folder  .   .   .   ./info
folder  .   .   .   ./pack      << folder of packed sets of objects.
folder  .   .   ./refs          << directory with refs (branches, tags) of the superproject.
folder  .   .   .   ./heads         << directory with local superproject branches.
 file   .   .   .   .   master      << a file with a commit hash of a superproject branch.
folder  .   .   .   ./remotes       << directory with remote superproject repositories.
folder  .   .   .   .   ./origin    << directory for the superproject's 'origin'
 file   .   .   .   .   .   master  << a file with a commit hash of a remote branch.
folder  .   .   .   ./tags          << directory with superproject tags.
 file   .   .   .   .   v0.0        << a file with a commit hash of a tag.
folder  .   .   ./worktrees     << a folder containing information about linked working trees
        .   .   .                  (may be missing).
folder  .   .   .   ./worktree-name << a folder with the name of the associated work tree.
 file   .   .   .   .   HEAD        << ref to the work tree branch.
 file   .   .   .   .   commondir   << relative path to MAIN/.git (here "../.." will actually
        .   .   .   .   .              point to ./MAIN/.git); no prefixes like "gitdir: ".
 file   .   .   .   .   gitdir      << absolute path to the working tree .git file (here
        .   .   .   .   .              "*/WORKTREE/.git"), no prefixes like "gitdir: ".
folder  .   .   .   .   ./logs      << a directory with files containing the history.
folder  .   .   .   .   ./modules   << folder containing information about submodules of
        .   .   .   .   .              work tree (may be missing).
folder  .   .   .   .   .   ./SUBMODULE << a folder describing the given submodule of the
        .   .   .   .   .   .              linked work tree (i.e. WORKTREE/SUBMODULE). This
        .   .   .   .   .   .              is a duplicate of the folder from the main tree
        .   .   .   .   .   .              ./MAIN/.git/modules/SUBMODULE.
folder  ./WORKTREE              << the linked working tree is treated the same as a repository
        .                          with a separate .git directory (git clone --separate-git-dir ...).
 file   .   .git                << contains the absolute path to the repository .git folder
        .   .                      (here "gitdir: */MAIN/.git/worktrees/worktree-name").
folder  .   ./SUBMODULE         << submodule's work tree.
 file   .   .   .git            << contains the absolute path to the repository .git folder
        .   .   .                  (here "gitdir: */MAIN/.git/worktrees/worktree-name/modules/SUBMODULE")
```

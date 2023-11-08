
# License

This Source Code Form is subject to the terms of the Mozilla
Public License, v. 2.0. If a copy of the MPL was not distributed
with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

# About

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
#       define  VERSION             0x0102014DL
#       define  VERSION_TEXT        "v1.2-333.branchname"
#       define  VERSION_DATE        "2023-11-06 20:16:40"
#       define  VERSION_SHORTDATE   2311062016L
#       define  VERSION_BRANCH      "branchname"
#       define  VERSION_HOSTINFO    "your@email.org openSUSE Leap 15.5"
#       define  VERSION_AUTHORSHIP  "Your Name"
#       define  VERSION_DECLARATION "Copyright (c) Your Name 2023"
// information below based on parent commit's hash
#       define  VERSION_SHA_ABBREV  "p:e2477886"
#       define  VERSION_SHA         "p:e2477886f1fff6ddac0e533f22d7be244674e064"
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

# Installation and use

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

## Options of version-stamper

Options usually have what is called a short form (such as -V or -q) and
a long form (such as --version or --quiet). Parameters can be used
separately, or may require additional values. Thus, the -cd, --directory
and --git-hook parameters require a value that can be specified either
as an additional argument separated by a space:

```
	version-stamper --directory "/other/working/directory"
```

or using an assignment:

```
	version-stamper --directory="/other/working/directory"
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
  your_project> ../version-stamper/version-stamper -l
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
  your_project> ../version-stamper/version-stamper -p
  A0.1-3.master  2023-11-06 22:17:09  andrey@makarov.local openSUSE Leap 15.5
     VERSION_HEX=         0102014D
     VERSION_TEXT=        v1.2-333.branchname
     VERSION_PREFIX=      v
     VERSION_MAJOR=       1
     VERSION_MINOR=       2
     VERSION_BUILD=       333
     VERSION_BRANCH=      branchname
     VERSION_DIRTY=       
     VERSION_DATE=        2023-11-06 22:17:09
     VERSION_SHORTDATE=   2311062217
     VERSION_SHA=         47920119e1110edeeda572e5612ab211096fdc6a
     VERSION_SHA_ABBREV=  47920119
     VERSION_HOSTINFO=    your@email.org openSUSE Leap 15.5
     VERSION_AUTHORSHIP=  Your Name
     VERSION_DECLARATION= Copyright (c) Your Name 2023
     VERSION_LEADER=      
     VERSION_TRAILER=     
     VERSION_SUBMOD_NAME= 
     VERSION_SUBMOD_PATH= 
     Note. The identifier names listed here are exposed in the plugin, not in the target file.
```

  Here version `v1.2` is the nearest tag containing the major and minor
  version numbers, 333 is the build number (the distance from the current
  commit to the tag), this information is returned by `git describe`.
  Version code 0102014D is a 32-bit number containing the major version
  number in the high byte, the minor number in the next byte, and 
  build number in the low 16-bit word. The name of the current branch
  `branchname` is either the name of the attached branch, or calculated
  if HEAD is detached (which is often the case for submodules).
  Computation cannot guarantee the correctness of the calculation or
  selection if there may be more than one matching branch for a given
  commit.

  `VERSION_DIRTY` - flag of the changed working tree (not taking into
  account changes in version stamps). Indicated by the `+` symbol if there
  are changes unsaved in the repository. In this case, the `+` character
  is also appended to the branch name in `VERSION_TEXT`.

  `VERSION_DATE` and `VERSION_SHORTDATE` - contain the current date (may
  differ from the commit date; especially for a modified working tree).

  `VERSION_SHA` and `VERSION_SHA_ABBREV` - contain information about the
  current commit and its ancestors (in this case, the prefix `p:` is
  added before the hash). The ancestor hash is used in the `pre-commit`
  hook because the hash of the new commit is not yet known at this time.

  `VERSION_AUTHORSHIP` and `VERSION_DECLARATION` - taken from the
  `.version-stamper` configuration file, when it is created, they are
  initially assigned based on the username and the standard configuration
  in the `version-stamper-config` parameter file.

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

- `-g` or `--generate`<br/>
  Execute all configured plugins. This only applies to configured
  plugins in .version-stamper.

- `--git-hook GITHOOK`<br/>
  Use this option when version-stamper is running from git hook. It passes
  hook name (without path and leading '/' and/or '.'). This option turns
  on special processing during hook execution.
  Note: do not set it manually (except for test only), it must be used
  by corrresponding git hooks.

## Commands of version-stamper

Along with the parameters listed above, the command line may contain
commands for launching plugins. If a stamp created by a plugin specified
on the command line is also created by a plugin configured in the
configuration file, then whether that stamp is included in `.gitignore`
or `.gitattributes` is determined by the configuration, not the command
line.

The command to execute the plugin looks like:

```
    your_project> ../version-stamper/version-stamper ... PLUGIN [plugin_options] FILE
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
    your_project> ../version-stamper/version-stamper ... MAKEFILE -i build/version.mk
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

# Configuration file .version-stamper

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

## A little about git hooks

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

# Plugin internals

To create your own plugin, just create a file with a name corresponding
to `version-stamper-plugin-XXX`, where `XXX` is replaced by the name of
the plugin and place this file next to `version-stamper`. The plugin must
contain several functions; The easiest way is to take any existing plugin
as a basis and make the necessary changes to it.

**`__PLUGIN_CS_NOTICE__`**<br/>
This function prints a short description of this plugin to stdout. This
description is used by the `version-stamper --help` command when generating
a list of supported plugins.

**`__PLUGIN_CS_SAMPLE__`**<br/>
This function prints a one-line example of using the plugin to stdout.
This example is included in the `.version-stamper` configuration file
created by the `version-stamper --config` command. Normally, the output
line should begin with a comment character `#`, since the created
configuration file initially does not contain configured plugins - this
must be done by the project author. However, in special cases it may be
different.

**`__PLUGIN_CS_ATTRIB__`**<br/>
This function prints to stdout a set of parameters applied to the
generated version stamp in `.gitattributes`.

*Note:* Updates to the `.gitattributes` and `.gitignore` files only occur
when a new version stamp file is created.

**`__PLUGIN_CS_GETVER__`**<br/>
This function receives the text of the existing stamp on stdin and must
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

**`__PLUGIN_CS_CREATE__`**<br/>
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
function __PLUGIN_CS_CREATE__
{
     __STORE_NATIVE_EOL__ "$1" <<-END_OF_TEXT
        version stamp text here
END_OF_TEXT
}
```

**`__PLUGIN_CS_MODIFY__`**<br/>
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

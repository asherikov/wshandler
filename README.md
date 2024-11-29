Introduction
============

`wshandler` is a workspace management utility similar to
<https://github.com/dirk-thomas/vcstool> and discontinued
<https://github.com/vcstools/wstool>. A workspace is a directory containing a set
of packages (typically git repositories) under development, see
<https://docs.ros.org/en/foxy/Tutorials/Beginner-Client-Libraries/Creating-A-Workspace/Creating-A-Workspace.html>
or <http://wiki.ros.org/catkin/workspaces for more information>.

Key features:
- `wshandler` mimics `wstool`'s 'stateful' workflow dropped in `vcstool`, e.g.,
  it is easy to keep track of your local changes with respect to the upstream;
- `wshandler` is implemented using `bash` and `yq` (<https://github.com/mikefarah/yq>);
- currently supported package sources: `git`;
- supported repository list formats: `repos` (default) and `rosinstall`
  (<https://docs.ros.org/en/independent/api/rosinstall/html/rosinstall_file_format.html>)


Installation
============

`wshandler` is a bash script that can be placed anywhere, e.g., your
`${HOME}/bin`. It requires `bash`, `yq`, and `git` to work, you can use
installation commands of the script to install dependencies, or download
AppImage package from <https://github.com/asherikov/wshandler/releases> that
includes `wshandler` and `yq` (`git` and `bash` must be present on the host
system).


Usage
=====

```
Usage (default values are shown in curly braces):
  wshandler [<COMMON_ARGS>] [<COMMAND_ARGS>] <COMMAND> <COMMAND_ARGS>

Notation:
  <REQUIRED ARGUMENT>
  {DEFAULT VALUE}
  [OPTIONAL ARGUMENT]
  (VALID OPTIONS IN A LIST)

Common arguments:
  -y|--yq <YQ_BINARY>         {yq}                    # override yq path
  -r|--root <WORKSPACE_ROOT>  {./}                    # parent of --list if it is a path
  -c|--cache <CACHE_DIR>      {<WORKSPACE_ROOT>}      # temporary files created here
  -t|--type rosinstall|repos  {repos}                 # repository list format
  -i|--indent 1|2|3...        {4}                     # default indentation in yaml repository list
  -k|--keep-going             {false}                 # do not stop on errors
  -l|--list <FILENAME>        {.rosinstall|.repos}    # default depends on --type

List commands:
  Information:
    status
    is_source_space
  Initialization:
    [-p|--policy <POLICY1[,POLICY2]> ({default}|shallow|nolfs)] clone git <LIST_REPOSITORY> [<BRANCH>]
    [-p|--policy <POLICY1[,POLICY2]> ({default}|shallow|nolfs)] init [git <PACKAGE_REPOSITORY> ...]
  Modification:
    [-p|--policy {ask}|add|show] scrape
    add git <PACKAGE_NAME> <PACKAGE_URL> <PACKAGE_VERSION>
    set_version_by_url <PACKAGE_URL> <PACKAGE_VERSION>
    set_version_by_name <PACKAGE_NAME> <PACKAGE_VERSION>
    remove <PACKAGE_NAME>
    remove_by_url <PACKAGE_URL>
    [-p|--policy {keep}|replace] merge <LIST_FILENAME>

Package repository commands:
  Global:
    [-j|--jobs <NUM_THREADS> {1}] [-p|--policy <POLICY1[,POLICY2]> ({default}|shallow|nolfs|rebase)] update
    [-j|--jobs <NUM_THREADS> {1}] clean
    [-j|--jobs <NUM_THREADS> {1}] [-s|-source {git}] foreach '<COMMAND>'
    prune
    push
    branch show ['<GREP_PATTERN>']
    branch new <BRANCH_NAME>
    branch delete <BRANCH_NAME>
    branch switch <BRANCH_NAME>
    branch merge <BRANCH_NAME> <TARGET_BRANCH {main}>
    commit '<MESSAGE>'
  Local:
    unshallow <PACKAGE_NAME>

wshandler installation commands:
  install_test_deps
  [-p|--policy {skip_yq}|snap|download] install <BIN_PATH {~/bin}>
```

Examples
========

- `wshandler status`
```
>>> wshandler status .../ccws/src/: git sources ---
Flags: H - version hash mismatch, M - uncommited changes
name              version  actual version              HM repository
----              -------  --------------              -- ----------
ariles            pkg_ws_2 tags/ws-2.3.1-0-ge2748ad4      https://github.com/asherikov/ariles.git
intrometry        main     tags/0.1.0-0-ga033cd5-dirty  M https://github.com/asherikov/intrometry.git
thread_supervisor master   tags/1.1.0-0-gbbf8a09          https://github.com/asherikov/thread_supervisor.git

<<< wshandler status .../ccws/src/: git sources ---
```

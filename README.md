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
Common arguments:
  -y|--yq <YQ_BINARY>         {yq}
  -r|--root <WORKSPACE_ROOT>  {./}
  -c|--cache <CACHE_DIR>      {<WORKSPACE_ROOT>}
  -t|--type rosinstall|repos  {repos}
  -i|--indent 1|2|3...        {4}
  -k|--keep-going             {false}
List commands:
  status
  [-j|--jobs <NUM_THREADS> {1}] [-p|--policy policy1[,policy2] ({default}|shallow|nolfs|rebase)] update
  [-j|--jobs <NUM_THREADS> {1}] clean
  [-p|--policy {ask}|add|show] scrape
  add git <NAME> <URL> <VERSION>
  set_version_by_url <URL> <VERSION>
  set_version_by_name <NAME> <VERSION>
  remove <NAME>
  remove_by_url <URL>
  [-p|--policy {keep}|replace] merge <FILENAME>
List initialization commands:
  [-p|--policy policy1[,policy2] ({default}|shallow|nolfs)] clone git <URL> [<BRANCH>]
  [-p|--policy policy1[,policy2] ({default}|shallow|nolfs)] init [git <URL1> ...]
Repository commands:
  [-j|--jobs <NUM_THREADS> {1}] [-s|-source {git}] foreach '<COMMAND>'
  prune
  push
  branch show ['<GREP_PATTERN>']
  branch new <BRANCH_NAME>
  branch delete <BRANCH_NAME>
  branch switch <BRANCH_NAME>
  branch merge <BRANCH_NAME> <TARGET_BRANCH {main}>
  commit '<MESSAGE>'
Installation commands:
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

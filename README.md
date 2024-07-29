Introduction
============

`wshandler` is a workspace management utility similar to
https://github.com/dirk-thomas/vcstool and discontinued
https://github.com/vcstools/wstool. A workspace is a directory containing a set
of packages (typically git repositories) under development, see
https://docs.ros.org/en/foxy/Tutorials/Beginner-Client-Libraries/Creating-A-Workspace/Creating-A-Workspace.html
or http://wiki.ros.org/catkin/workspaces for more information.

Key features:
- `wshandler` mimics `wstool`'s 'stateful' workflow dropped in `vcstool`, e.g.,
  it is easy to keep track of your local changes with respect to the upstream;
- `wshandler` is implemented using `bash` and `yq` (https://github.com/mikefarah/yq);
- currently supported package sources: `git`;
- supported repository list formats: `repos` (default) and `rosinstall`
  (https://docs.ros.org/en/independent/api/rosinstall/html/rosinstall_file_format.html)


Installation
============

`wshandler` is a bash script that can be placed anywhere, e.g., your
`${HOME}/bin`. It requires `bash`, `yq`, and `git` to work, you can use helper
`install.sh` script in this repository to install dependencies or download
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
Commands:
  status
  [-j|--jobs <NUM_THREADS> {1}] [-p|--policy {default}|shallow|rebase] update
  [-j|--jobs <NUM_THREADS> {1}] clean
  [-p|--policy {ask}|add|show] scrape
  add git <NAME> <URL> <VERSION>
  set_version_by_url <URL> <VERSION>
  set_version_by_name <NAME> <VERSION>
  remove <NAME>
  remove_by_url <URL>
  [-p|--policy {keep}|replace] merge <FILENAME>
```

Examples
========

- `wshandler status`
```
>>> wshandler status .../wshandler/tests/scrape/: git sources ---
name       version (hash)    actual version           repository
----       --------------    --------------           ----------
qpmad      master (53edb8a)  heads/master-0-g53edb8a  https://github.com/asherikov/qpmad.git
staticoma  master (06e8628)  heads/master-0-g06e8628  https://github.com/asherikov/staticoma.git

<<< wshandler status .../wshandler/tests/scrape/: git sources ---
```

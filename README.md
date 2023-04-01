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
- currently supported repository types: `git`;
- surrently supported repository list formats: `repos` and `rosinstall`
  (https://docs.ros.org/en/independent/api/rosinstall/html/rosinstall_file_format.html)


Installation
============

`wshandler` requires `bash`, `yq`, and `git` to work, you can use helper
`install.sh` script in this repository to install dependencies. The utility
itself is a single bash script that can be placed anywhere, e.g., your
`${HOME}/bin`.


Usage
=====

```
Usage:
  wshandler [<COMMON_ARGS>] [<COMMAND_ARGS>] <COMMAND> <COMMAND_ARGS>
Common arguments:
  -r|--root <WORKSPACE_ROOT>
  -c|--cache <CACHE_DIR>
  -t|--type rosinstall|repos
  -i|--indent 1|2|3...
  -k|--keep-going
Commands:
  status
  [-j|--jobs <NUM_THREADS>] [-p|--policy shallow] update
  [-j|--jobs <NUM_THREADS>] clean
  [-p|--policy ask|add|show] scrape
  add git <NAME> <URL> <VERSION>
  remove <NAME>
  [-p|--policy keep|replace] merge <FILENAME>
```

Examples
========

- `wshandler status`
```
>>> wshandler status /home/aleks/wshandler/tests/scrape/: git sources ---
name       version (actual)                  repository
----       ----------------                  ----------
qpmad      master (heads/master-0-g53edb8a)  https://github.com/asherikov/qpmad.git
staticoma  master (heads/master-0-g4c7e4e2)  https://github.com/asherikov/staticoma.git

<<< wshandler status /home/aleks/wshandler/tests/scrape/: git sources ---
```

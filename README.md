Introduction
============

`wshandler` is a workspace management utility similar to
<https://github.com/dirk-thomas/vcstool> (now
<https://github.com/ros-infrastructure/vcs2l>),
<https://github.com/ErickKramer/ripvcs/>, and discontinued
<https://github.com/vcstools/wstool>. It is also conceptually similar to
<https://github.com/jacebrowning/gitman>, which comes from a different
(non-ROS) background.

A workspace is a directory containing a set of packages (typically git
repositories), see
<https://docs.ros.org/en/foxy/Tutorials/Beginner-Client-Libraries/Creating-A-Workspace/Creating-A-Workspace.html>
or <http://wiki.ros.org/catkin/workspaces> for more information.

Key features:
- `wshandler` mimics `wstool`'s 'stateful' workflow dropped in `vcstool`, i.e.,
  it is easy to keep track of your local changes with respect to the upstream;
- `wshandler` is implemented in `bash` and relies on either `gojq`
  <https://github.com/itchyny/gojq> or `yq` <https://github.com/mikefarah/yq>
  for yaml processing;
- currently supported package sources: `git`;
- supported repository list formats: `repos` (default) and `rosinstall`
  (<https://docs.ros.org/en/independent/api/rosinstall/html/rosinstall_file_format.html>);
- custom repository list extensions:
    - repository entries can be tagged for selective updates and status
      information, e.g., `wshandler: {tags: [mytag]}`, see `./tests/tags/` for
      examples;
    - experimental sparse checkouts for entries that contain `wshandler:
      {sparse: [<path>]}`, see `./tests/sparse` for examples.


Installation
============

`wshandler` is a bash script that can be placed anywhere, e.g., your
`${HOME}/bin`. It requires `bash`, `git` and either `gojq` (default) or `yq` to
work. `gojq` is available via binary packages on many modern systems, but has
certain limitations, e.g., it always sorts entries and does not preserve
comments. `yq` is not available via debian packages on Ubuntu, but can be
installed using `snap`. You can also find an AppImage bundle including
`wshandler` and `yq` at <https://github.com/asherikov/wshandler/releases>
(`git` and `bash` must be present on the host system).


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
  -y|--yaml_tool auto|gojq|yq    {auto}               # Use gojq or yq, auto prefers gojq
  -Y|--yaml_binary <BINARY_PATH> {yq|gojq}            # Override yaml tool (yq/gojq) path
  -r|--root <WORKSPACE_ROOT>     {./}                 # Parent of --list if it is a path
  -c|--cache <CACHE_DIR>         {<WORKSPACE_ROOT>}   # Temporary files created here
  -t|--type rosinstall|repos     {repos}              # Repository list format
  -i|--indent 1|2|3...           {4}                  # Default indentation in yaml repository list
  -k|--keep-going                {false}              # Do not stop on errors
  -l|--list <FILENAME>           {.rosinstall|.repos} # Default depends on --type,
                                                      #can be specified multiple times,
                                                      #mutually exclusive with -L
  -L|--list-discover                                  # Automatically discover lists in the root,
                                                      #recursively searches for *.<type> files,
                                                      #mutually exclusive with -l,
                                                      #should be set after -r and -t.
  -T|--tag <TAG>                 {}                   # Filter repositories by tags
                                                      #can be specified multiple times
  -q|--quiet                                          # Suppress most of the output

Repository list commands:
  Information:
    [-u|--unsorted] status    # show workspace status
    is_source_space           # check if a directory is a workspace

  Initialization:
    Common arguments:
      [-p|--policy <POLICY1[,POLICY2]> ({default}|shallow|nolfs)]
        default   # plain clone
        shallow   # shallow clone
        nolfs     # disable git LFS
    clone git <LIST_REPOSITORY> [<BRANCH>]    # clone workspace from a given repository
    init [git <PACKAGE_REPOSITORY> ...]       # initialize new workspace

  Modification:
    [-p|--policy {ask}|add|show|clean] scrape <DIRECTORY {<WORKSPACE_ROOT>}>  # process unmanaged repositories
      ask         # interactive mode
      add         # automaticaly add repositories
      show        # show unmanaged repositories
      clean       # remove unmanaged repositories
    add git <PACKAGE_NAME> <PACKAGE_URL> <PACKAGE_VERSION>    # add a repository
    set_version_by_url <PACKAGE_URL> <PACKAGE_VERSION>        # set repository version
    set_version_by_name <PACKAGE_NAME> <PACKAGE_VERSION>      # set repository version
    set_version_to_hash                                       # set all repository versions to hash
    pin                                                       # alias for set_version_to_hash
    [-p|--policy <POLICY1[,POLICY2]> ({active})] set_version_to_branch <BRANCH_NAME>  # change to the given branch
      active      # switch if the given branch is checked out
    remove <PACKAGE_NAME> ...                                 # remove repository from a list
    remove_by_url <PACKAGE_URL> [<PACKAGE_URL>]               # remove repository from a list
    [-p|--policy {keep}|replace] merge <LIST_FILENAME>        # merge repository list
      keep        # keep original entries when there is a collision
      replace     # replace entries when there is a collision

Repository commands:
  Selective commands (<PACKAGE_NAME> may be a pattern):
    Common arguments:
      [-j|--jobs <NUM_THREADS> {1}]   # use multiple jobs if possible
      [-U|--unmanaged]                # work on unmanaged repository directories: directory names must be given
                                      #instead of package names, at least one is required, ignores --jobs
    clean [<PACKAGE_NAME> ...]        # remove repository
    prune [<PACKAGE_NAME> ...]        # git prune
    push [<PACKAGE_NAME> ...]         # git push
    unshallow [<PACKAGE_NAME> ...]    # git unshallow
    [-p|--policy <POLICY1[,POLICY2]> ({default}|shallow|nolfs|rebase)] update [<PACKAGE_NAME> ...] # git pull
      default      # plain clone
      shallow      # shallow clone
      nolfs        # disable git LFS
      rebase       # do git pull with rebase
      unmodified   # only unmodified repos
      nosubmodules # do not checkout submodules

  Generic commands:
    [-j|--jobs <NUM_THREADS> {1}] foreach git '<COMMAND>'  # execute command in each repository

  Branching commands:
    branch show ['<GREP_PATTERN>']                    # show matching branches
    branch new <BRANCH_NAME>                          # create a new branch in modified repositories
    branch allnew <BRANCH_NAME>                       # create a new branch in all repositories
    branch delete <BRANCH_NAME>                       # delete branch from all repositories
    branch merge <BRANCH_NAME> <TARGET_BRANCH {main}> # merge brach
    commit '<MESSAGE>'                                # commit to modified repositories

wshandler installation commands:
  install_test_deps                                                           # install test dependeincies
  [-p|--policy {skip_yaml_tool}|snap|download|apt] install <BIN_PATH {~/bin}> # install wshandler
      skip_yaml_tool  # do not install yaml tool
      snap            # install yaml tool (jq) using snap
      download        # download yaml tool (jq)
      apt             # install yaml tool (gojq) using apt
  upgrade <BIN_PATH {~/bin}>              # upgrade wshandler
  upgrade_appimage <BIN_PATH {~/bin}>     # upgrade wshandler AppImage
```

Examples
========

- `wshandler status`
```
>>> wshandler status: git sources ---
Flags: H - version hash mismatch, M - uncommited changes
name              version  actual version              HM repository
----              -------  --------------              -- ----------
ariles            pkg_ws_2 tags/ws-2.3.1-0-ge2748ad4      https://github.com/asherikov/ariles.git
intrometry        main     tags/0.1.0-0-ga033cd5-dirty  M https://github.com/asherikov/intrometry.git
thread_supervisor master   tags/1.1.0-0-gbbf8a09          https://github.com/asherikov/thread_supervisor.git

<<< wshandler status: git sources ---
```

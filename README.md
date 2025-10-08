Introduction
============

`wshandler` is a workspace management utility similar to
<https://github.com/dirk-thomas/vcstool> (now
<https://github.com/ros-infrastructure/vcs2l>),
<https://github.com/ErickKramer/ripvcs/>, and discontinued
<https://github.com/vcstools/wstool>. A workspace is a directory containing a
set of packages (typically git repositories) under development, see
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
- repository entries can be tagged for selective updates and status
  information, e.g., `wshandler: {tags: [mytag]}`, see `./tests/tags/` for
  examples;
- experimental sparse checkouts for extries that contain `wshandler: {sparse:
  [<path>]}`, see `./tests/sparse` for examples.


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
WSH: Usage (default values are shown in curly braces):
WSH:   wshandler [<COMMON_ARGS>] [<COMMAND_ARGS>] <COMMAND> <COMMAND_ARGS>
WSH:
WSH: Notation:
WSH:   <REQUIRED ARGUMENT>
WSH:   {DEFAULT VALUE}
WSH:   [OPTIONAL ARGUMENT]
WSH:   (VALID OPTIONS IN A LIST)
WSH:
WSH: Common arguments:
WSH:   -y|--yaml_tool auto|gojq|yq    {auto}               # Use gojq or yq, auto prefers gojq
WSH:   -Y|--yaml_binary <BINARY_PATH> {yq|gojq}            # Override yaml tool (yq/gojq) path
WSH:   -r|--root <WORKSPACE_ROOT>     {./}                 # Parent of --list if it is a path
WSH:   -c|--cache <CACHE_DIR>         {<WORKSPACE_ROOT>}   # Temporary files created here
WSH:   -t|--type rosinstall|repos     {repos}              # Repository list format
WSH:   -i|--indent 1|2|3...           {4}                  # Default indentation in yaml repository list
WSH:   -k|--keep-going                {false}              # Do not stop on errors
WSH:   -l|--list <FILENAME>           {.rosinstall|.repos} # Default depends on --type,
WSH:                                                       #can be specified multiple times,
WSH:                                                       #mutually exclusive with -L
WSH:   -L|--list-discover                                  # Automatically discover lists in the root,
WSH:                                                       #recursively searches for *.<type> files,
WSH:                                                       #mutually exclusive with -l,
WSH:                                                       #should be set after -r and -t.
WSH:   -T|--tag <TAG>                 {}                   # Filter repositories by tags
WSH:                                                       #can be specified multiple times
WSH:   -q|--quiet                                          # Suppress most of the output
WSH:
WSH: Repository list commands:
WSH:   Information:
WSH:     [-u|--unsorted] status    # show workspace status
WSH:     is_source_space           # check if a directory is a workspace
WSH:
WSH:   Initialization:
WSH:     Common arguments:
WSH:       [-p|--policy <POLICY1[,POLICY2]> ({default}|shallow|nolfs)]
WSH:         default   # plain clone
WSH:         shallow   # shallow clone
WSH:         nolfs     # disable git LFS
WSH:     clone git <LIST_REPOSITORY> [<BRANCH>]    # clone workspace from a given repository
WSH:     init [git <PACKAGE_REPOSITORY> ...]       # initialize new workspace
WSH:
WSH:   Modification:
WSH:     [-p|--policy {ask}|add|show|clean] scrape <DIRECTORY {<WORKSPACE_ROOT>}>  # process unmanaged repositories
WSH:       ask         # interactive mode
WSH:       add         # automaticaly add repositories
WSH:       show        # show unmanaged repositories
WSH:       clean       # remove unmanaged repositories
WSH:     add git <PACKAGE_NAME> <PACKAGE_URL> <PACKAGE_VERSION>    # add a repository
WSH:     set_version_by_url <PACKAGE_URL> <PACKAGE_VERSION>        # set repository version
WSH:     set_version_by_name <PACKAGE_NAME> <PACKAGE_VERSION>      # set repository version
WSH:     set_version_to_hash                                       # set all repository versions to hash
WSH:     [-p|--policy <POLICY1[,POLICY2]> ({active})] set_version_to_branch <BRANCH_NAME>  # change to the given branch
WSH:       active      # switch if the given branch is checked out
WSH:     remove <PACKAGE_NAME> ...                                 # remove repository from a list
WSH:     remove_by_url <PACKAGE_URL> [<PACKAGE_URL>]               # remove repository from a list
WSH:     [-p|--policy {keep}|replace] merge <LIST_FILENAME>        # merge repository list
WSH:       keep        # keep original entries when there is a collision
WSH:       replace     # replace entries when there is a collision
WSH:
WSH: Repository commands:
WSH:   Selective commands (<PACKAGE_NAME> may be a pattern):
WSH:     Common parameters:
WSH:       [-j|--jobs <NUM_THREADS> {1}]   # use multiple jobs if possible
WSH:     clean [<PACKAGE_NAME> ...]        # remove repository
WSH:     prune [<PACKAGE_NAME> ...]        # git prune
WSH:     push [<PACKAGE_NAME> ...]         # git push
WSH:     unshallow [<PACKAGE_NAME> ...]    # git unshallow
WSH:     [-p|--policy <POLICY1[,POLICY2]> ({default}|shallow|nolfs|rebase)] update [<PACKAGE_NAME> ...] # git pull
WSH:       default      # plain clone
WSH:       shallow      # shallow clone
WSH:       nolfs        # disable git LFS
WSH:       rebase       # do git pull with rebase
WSH:       unmodified   # only unmodified repos
WSH:       nosubmodules # do not checkout submodules
WSH:
WSH:   Generic commands:
WSH:     [-j|--jobs <NUM_THREADS> {1}] foreach git '<COMMAND>'  # execute command in each repository
WSH:
WSH:   Branching commands:
WSH:     branch show ['<GREP_PATTERN>']                    # show matching branches
WSH:     branch new <BRANCH_NAME>                          # create a new branch in modified repositories
WSH:     branch allnew <BRANCH_NAME>                       # create a new branch in all repositories
WSH:     branch delete <BRANCH_NAME>                       # delete branch from all repositories
WSH:     branch merge <BRANCH_NAME> <TARGET_BRANCH {main}> # merge brach
WSH:     commit '<MESSAGE>'                                # commit to modified repositories
WSH:
WSH: wshandler installation commands:
WSH:   install_test_deps                                                           # install test dependeincies
WSH:   [-p|--policy {skip_yaml_tool}|snap|download|apt] install <BIN_PATH {~/bin}> # install wshandler
WSH:       skip_yaml_tool  # do not install yaml tool
WSH:       snap            # install yaml tool (jq) using snap
WSH:       download        # download yaml tool (jq)
WSH:       apt             # install yaml tool (gojq) using apt
WSH:   upgrade <BIN_PATH {~/bin}>              # upgrade wshandler
WSH:   upgrade_appimage <BIN_PATH {~/bin}>     # upgrade wshandler AppImage
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

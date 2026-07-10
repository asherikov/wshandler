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


Features
--------

### Stateful workflow

`wshandler` mimics `wstool`'s 'stateful' workflow dropped in `vcstool`, i.e.,
it is easy to keep track of your local changes with respect to the upstream.

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


### Version pinning (workspace releases)

`wshandler pin` (or its deprecated alias `set_version_to_hash`) sets repository
versions to tags corresponding to the current commits, falling back to
commit hashes when no tag is available. This allows freezing workspace in
a desired state with more readable version references when tags exist.

Example workflow: bleeding edge version of workspace in the main branch
tracking latest versions of repositories and a release workspace branch with
fixed stable repository versions that is updated when necessary.


### Templated repository lists

Repository lists can be changed dynamically based on environment variables:
`--env-subst` flag forces substitution of environment variables into lists.
This feature can be used to swap repository URLs (http/git), repository
branches, etc.


### Multi-repo feature branches

Sometimes multiple repositories are modified during development of a particular
feature and need to be tested together. Provided that the feature branches are
named consistently you can achieve this with `--prefer-version` flag -- when
specified it forces `wshandler` to use given version (tag/branch) instead of
version specified in repository list. At least one repository must match the
specified ref, otherwise the command fails.


### Tagging

Repository entries can be tagged for selective updates and status information,
e.g., `wshandler: {tags: [mytag]}`, see `./tests/tags/` for examples.


### Sparce cehckouts

`wshandler` provides experimental sparse checkout support for entries that
contain `wshandler: {sparse: [<path>]}`, see `./tests/sparse` for examples.


### Supported source types

- Repository list formats:
    - `repos` (default);
    - `rosinstall` (<https://docs.ros.org/en/independent/api/rosinstall/html/rosinstall_file_format.html>).

- Repository types:
    - `git`.


Installation
============

`wshandler` is a bash script that can be placed anywhere, e.g., your
`${HOME}/bin`. It requires `bash`, `git` and either `gojq` (default,
<https://github.com/itchyny/gojq>) or `yq` (<https://github.com/mikefarah/yq>)
to work. `gojq` is available via binary packages on many modern systems, but
has certain limitations, e.g., it always sorts entries and does not preserve
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
  -e|--env-subst                                      # Perform environment variable substitution
                                                      #in repository lists (disabled by default),
                                                      #gettext envsubst has to be installed
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
    set_version_to_hash                                       # deprecated, use pin
    pin                                                       # set versions to tags when available, hash otherwise
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
      [-j|--jobs <NUM_THREADS> {1}]       # use multiple jobs if possible
      [-U|--unmanaged]                    # work on unmanaged repository directories: directory names must
                                          #be given instead of package names, at least one is required,
                                          #ignores --jobs
    clean [<PACKAGE_NAME> ...]            # remove repository
    prune [<PACKAGE_NAME> ...]            # git prune
    [-p|--policy <POLICY1[,POLICY2]>] push [<PACKAGE_NAME> ...]  # git push (sets upstream or pushes tags as needed)
      # policies:
        default    # push all repositories
        version    # skip repositories whose current version matches the repository list
    unshallow [<PACKAGE_NAME> ...]        # git unshallow
    feature_branches [<PACKAGE_NAME> ...] # list git feature branches
    [-p|--policy <POLICY1[,POLICY2]>] [-P|--prefer-version <REF>] update [<PACKAGE_NAME> ...] # git pull
      # policies:
        default      # plain clone
        shallow      # shallow clone
        nolfs        # disable git LFS
        rebase       # do git pull with rebase
        unmodified   # only unmodified repos
        nosubmodules # do not checkout submodules
        origin       # check origin URL matches list, remove and reclone if mismatch
      # <REF> -- Prefer specified tag or branch over the version in the repository list

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

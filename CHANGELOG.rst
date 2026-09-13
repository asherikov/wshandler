^^^^^^^^^
Changelog
^^^^^^^^^

Forthcoming (2026-09-20 15:36 UTC)
----------------------------------

* 38f1d46 Task#11: changelog command

Contributors: shoggoth

1.7.1 (2026-08-25 17:01 UTC)
----------------------------

* 123ebdd make foreach selective

Contributors: Alexander Sherikov

1.7.0 (2026-07-30 11:01 UTC)
----------------------------

* 1a9cd80 Update README
* 3de0264 .github: cleanup and add ubuntu 26
* 32e7cf3 bump version (#9)
* 45f4538 apply preferred version to workspace repository (#8)
* 38acf70 allow multiple sed arguments (#7)

Contributors: Alexander Sherikov,admin

1.6.0 (2026-07-10 11:14 UTC)
----------------------------

* 89e7c54 Add -s/--sed parameter
* 14f8e2e push policy
* d5cc3a5 Task#3: push branch upstream
* f1da135 Implement Redmine issue #1: rework pinning functionality

Contributors: Alexander Sherikov,shoggoth

1.5.0 (2026-06-20 11:32 UTC)
----------------------------

* 7914ce8 Update readme
* 73dadeb Add --prefer-version flag

Contributors: Alexander Sherikov

1.4.1 (2026-04-15 18:14 UTC)
----------------------------

* 4ac15ec status: output total number of repositories
* 4419f8e Optional environment variable substitution in repolists

Contributors: Alexander Sherikov

1.4.0 (2026-02-11 19:00 UTC)
----------------------------

* 66be346 Add "origin" update policy. More tests
* 368df17 Fix submodule and LFS handling

Contributors: Alexander Sherikov

1.3.3 (2026-02-10 16:13 UTC)
----------------------------

* 9df9730 Update submodules on version checkout

Contributors: Alexander Sherikov

1.3.2 (2026-01-29 21:11 UTC)
----------------------------

* db6e6f7 Fix updating fresh git repo

Contributors: Alexander Sherikov

1.3.1 (2026-01-29 20:03 UTC)
----------------------------

* 7182499 Fix error handling

Contributors: Alexander Sherikov

1.3.0 (2026-01-14 21:09 UTC)
----------------------------

* 955a776 Add feature_branches command

Contributors: Alexander Sherikov

1.2.1 (2025-12-27 21:35 UTC)
----------------------------

* 2df6061 Fix merging with gojq (reverse order)
* fc3e140 Improve error handling

Contributors: Alexander Sherikov

1.2.0 (2025-12-01 11:11 UTC)
----------------------------

* 27e7067 Update README
* 43485d8 Add alias for set_version_to_hash=pin
* fc5306e Allow using some of the commands on unmanaged repos.
* 8d08434 Update README
* 029665e Fix repo path bug in scrape command.
* 5668384 Update README
* d7d7122 Fix sparse tests; nosubmodules update policy
* 658e6d4 Experimental sparse checkouts
* c34a9c2 Minor refactoring + variable renamings
* 0b71ffc Fallback to list discovery if default is missing.
* 2cca7cd Add "unmodified" policy to update command.
* bae2900 Add automatic list discovery.
* bd7288e README: add link to vcs2l

Contributors: Alexander Sherikov

1.1.3 (2025-10-04 19:28 UTC)
----------------------------

* 29a2ee4 Fail on changing versions of missing repos

Contributors: Alexander Sherikov

1.1.2 (2025-08-15 16:13 UTC)
----------------------------

* e1fe701 Fix parallel execution bug

Contributors: Alexander Sherikov

1.1.1 (2025-08-14 16:02 UTC)
----------------------------

* 00728d9 Fix bug in scrape command

Contributors: Alexander Sherikov

1.1.0 (2025-08-13 18:36 UTC)
----------------------------

* 503d19d Fix git hash matching
* 6c3023c Add --quiet argument

Contributors: Alexander Sherikov

1.0.3 (2025-08-04 16:16 UTC)
----------------------------

* 7c5634c Fix xargs warning

Contributors: Alexander Sherikov

1.0.2 (2025-07-30 18:06 UTC)
----------------------------

* 6530a0a Fix xargs warning

Contributors: Alexander Sherikov

1.0.1 (2025-07-26 19:30 UTC)
----------------------------

* 20f68bb Do not update root when doing selective update.

Contributors: Alexander Sherikov

1.0.0 (2025-07-21 19:52 UTC)
----------------------------

* b9e4694 Implement tagging of entries in repository lists
* 4b5c0f6 Use yaml tools for entry filtering
* dfa143c More refactoring: formatting and deduplication
* 2690a8c Add support for multiple repository lists
* 9441481 More refactoring and bugfixes
* b95098a Refactoring
* 4c26ce3 +set_version_to_hash, branch switch -> set_version_to_branch
* 11106fc Multithreaded selective commands, package patterns
* 1fbdb64 +selective clean; +clean scrape policy
* e782bec Refactoring: generalize and fix bugs
* 7dbbcec Allow package selection for some commands, refactoring
* 4a5ecde Allow multiple package parameters for several commands
* 1e805ae upgrade_appimage: fix url
* fc2efcc scrape: optional search root
* ab61eb9 Update README.

Contributors: Alexander Sherikov

0.8.0 (2025-05-24 19:27 UTC)
----------------------------

* 6dfec4f gojq fixes
* b5ea92e Fix yaml tool search logic.
* 5bab9b3 Select yaml tool automatically by default. Bugfixes.
* 349f529 Add gojq support
* 8e10755 README fixes

Contributors: Alexander Sherikov

0.7.2 (2025-05-22 19:03 UTC)
----------------------------

* fb26580 .github: deprecate Ubuntu 20
* 7a3a834 Allow individual package update

Contributors: Alexander Sherikov

0.7.1 (2025-04-03 12:06 UTC)
----------------------------

* 17f5fe4 update: do not fail on updating workspace root with git

Contributors: Alexander Sherikov

0.7.0 (2024-12-19 17:17 UTC)
----------------------------

* 0e47104 Add upgrade commands

Contributors: Alexander Sherikov

0.6.3 (2024-12-09 16:25 UTC)
----------------------------

* 5c03e13 appimage: disable zsync (broken?)
* 4e8801a Sort (optional) repository list in status output

Contributors: Alexander Sherikov

0.6.2 (2024-11-29 09:57 UTC)
----------------------------

* fda5aef fix path in tag workflow

Contributors: Alexander Sherikov

0.6.1 (2024-11-29 09:53 UTC)
----------------------------

* 36446a9 fix github tag workflow

Contributors: Alexander Sherikov

0.6.0 (2024-11-29 09:47 UTC)
----------------------------

* 5c49205 --version argument (AppImage only)
* fdcd9d4 Add --list argument
* 87536b3 Add is_source_space command
* c5f1f09 Add unshallow command

Contributors: Alexander Sherikov

0.5.2 (2024-11-27 15:13 UTC)
----------------------------

* b3c7b99 Fix status flags

Contributors: Alexander Sherikov

0.5.1 (2024-10-16 15:30 UTC)
----------------------------

* cf7c0f8 fix "update": do not pull if branch is not tracking

Contributors: Alexander Sherikov

0.5.0 (2024-09-30 18:21 UTC)
----------------------------

* 3c95e19 Add nolfs policy
* 98bcae7 Download latest yq when installing or building AppImage

Contributors: Alexander Sherikov

0.4.1 (2024-08-26 19:45 UTC)
----------------------------

* 684391f Fix update of the root

Contributors: Alexander Sherikov

0.4.0 (2024-08-13 19:39 UTC)
----------------------------

* 9fce372 Add initialization commands

Contributors: Alexander Sherikov

0.3.0 (2024-08-08 18:47 UTC)
----------------------------

* 74b3909 Add helper commands for repository processing

Contributors: Alexander Sherikov

0.2.2 (2024-08-05 17:46 UTC)
----------------------------

* ef2070e Instalation fixes and extra yq path

Contributors: Alexander Sherikov

0.2.1 (2024-08-05 17:06 UTC)
----------------------------

* 4ef182e appimage: use new appimagetool
* 473041a Bump softprops/action-gh-release version

Contributors: Alexander Sherikov

0.2.0 (2024-08-04 18:26 UTC)
----------------------------

* 8937ca9 Remove dependency on 'column' utility
* f58eafc Update README

Contributors: Alexander Sherikov

0.1.0 (2024-07-29 18:42 UTC)
----------------------------

* 421e445 Add appimage target and pipeline
* 8bd3e7e Fix git update policy parameter
* 29148c7 Use repos by default, update README
* 89d7050 +rebase update policy, improve status output
* f667b5b scrape: limit search depth
* dff37b5 Add remove_by_url
* c69bfbe Fixes and improvements
* 4f1b3af Add '--yq' option to specify path to yq executable
* 43dec22 install.sh: add 'deps' option
* 4b97f77 Improve help message
* 97f5da8 Fix README
* dfc6aec Initial

Contributors: Alexander Sherikov


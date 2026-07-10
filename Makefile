TYPE?=repos
YAML_TOOL?=gojq
WSHANDLER?=./wshandler -y ${YAML_TOOL}

test: shellcheck
	@${MAKE} test_type TYPE=rosinstall
	@${MAKE} test_type TYPE=repos
	@${MAKE} wrap_test TEST=test_root_git
	@${MAKE} wrap_test TEST=test_clone_ws
	@${MAKE} wrap_test TEST=test_unmanaged

test_clone_ws:
	rm -rf tests/clone
	${WSHANDLER} -r tests/clone -p shallow clone git https://github.com/asherikov/sharf.git main

test_type:
	@${MAKE} wrap_test TEST=test_update
	@${MAKE} wrap_test TEST=test_remove
	@${MAKE} wrap_test TEST=test_scrape
	@${MAKE} wrap_test TEST=test_merge
	@${MAKE} wrap_test TEST=test_set_version
	@${MAKE} wrap_test TEST=test_pin
	@${MAKE} wrap_test TEST=test_branch
	@${MAKE} wrap_test TEST=test_init
	@${MAKE} wrap_test TEST=test_multilist
	@${MAKE} wrap_test TEST=test_tags
	@${MAKE} wrap_test TEST=test_sparse
	@${MAKE} wrap_test TEST=test_env_subst
	@${MAKE} wrap_test TEST=test_prefer_version
	@${MAKE} wrap_test TEST=test_push_policy
	@${MAKE} wrap_test TEST=test_sed

wrap_test:
	@echo ""
	@echo "${TEST} >>> ##############################################################"
	${MAKE} --quiet ${TEST}
	@echo "${TEST} <<< ##############################################################"
	@echo ""

test_update:
	${WSHANDLER} -t ${TYPE} --root tests/update/ clean
	${WSHANDLER} -t ${TYPE} -r tests/update/ status
	${WSHANDLER} -t ${TYPE} -r tests/update/ -q status
	${WSHANDLER} -t ${TYPE} -r tests/update/ -u status
	${WSHANDLER} -t ${TYPE} -r tests/update/ --jobs 2 update "staticoma.*"
	test -d tests/update/staticoma
	test ! -d tests/update/catkin
	${WSHANDLER} -t ${TYPE} -r tests/update/ --jobs 2 update
	${WSHANDLER} -t ${TYPE} -r tests/update/ feature_branches "staticoma.*"
	${WSHANDLER} -t ${TYPE} -r tests/update/ feature_branches
	# test submodule
	test -f tests/update/qpmad_tag/doc/gh-pages/index.html
	test -f tests/update/qpmad_commit/doc/gh-pages/index.html
	${WSHANDLER} -t ${TYPE} --root tests/update/ status
	# policy: origin
	cd tests/update/staticoma && git remote set-url origin https://github.com/asherikov/nonexistent.git
	! ${WSHANDLER} -t ${TYPE} -r tests/update/ update staticoma
	${WSHANDLER} -t ${TYPE} -r tests/update/ --policy origin update staticoma
	# policy: unmodified
	test -d tests/update/staticoma
	touch tests/update/staticoma/x
	${WSHANDLER} -t ${TYPE} --policy unmodified -r tests/update/ --jobs 2 update | grep "Skipping modified"
	${WSHANDLER} -t ${TYPE} --root tests/update/ -j 2 clean staticoma
	test ! -d tests/update/staticoma
	test -d tests/update/catkin
	${WSHANDLER} -t ${TYPE} --root tests/update/ -j 2 clean
	# policy: shallow,nosubmodules
	${WSHANDLER} -t ${TYPE} -r tests/update/ --jobs 2 --policy shallow,nosubmodules update
	# test that submodule is missing
	test ! -f tests/update/qpmad_tag/doc/gh-pages/index.html
	test ! -f tests/update/qpmad_commit/doc/gh-pages/index.html
	${WSHANDLER} -t ${TYPE} -r tests/update/ is_source_space
	! ${WSHANDLER} -t ${TYPE} -r ./ is_source_space
	! ${WSHANDLER} -t ${TYPE} -r ./nonexistent is_source_space
	${WSHANDLER} -t ${TYPE} -r tests/update/ unshallow staticoma
	${WSHANDLER} -t ${TYPE} -r tests/update/ unshallow
	${WSHANDLER} -t ${TYPE} -r tests/update/ prune staticoma
	${WSHANDLER} -t ${TYPE} -r tests/update/ prune
	${WSHANDLER} -t ${TYPE} -r tests/update/ update staticoma
	${WSHANDLER} -t ${TYPE} --root tests/update/ status
	${WSHANDLER} -t ${TYPE} --root tests/update/ -l .${TYPE} status
	${WSHANDLER} -t ${TYPE} --list tests/update/.${TYPE} status
	test -d tests/update/staticoma_commit
	${WSHANDLER} -t ${TYPE} --root tests/update/ -j 2 clean "staticoma.*"
	test ! -d tests/update/staticoma
	test ! -d tests/update/staticoma_commit
	test -d tests/update/catkin
	${WSHANDLER} -t ${TYPE} --root tests/update/ -j 2 clean catkin/
	test ! -d tests/update/catkin
	${WSHANDLER} -t ${TYPE} --root tests/update/ -j 2 clean
	${WSHANDLER} -t ${TYPE} -r tests/update/ --jobs 2 --policy shallow,rebase,nolfs update
	${WSHANDLER} -t ${TYPE} --root tests/update/ status
	${WSHANDLER} -t ${TYPE} --root tests/update/ -j 2 clean
	${WSHANDLER} -t ${TYPE} -r tests/update/ --jobs 2 --policy rebase update
	${WSHANDLER} -t ${TYPE} --root tests/update/ status
	${WSHANDLER} -t ${TYPE} --root tests/update/ -j 2 clean
	! ${WSHANDLER} -t ${TYPE} --root tests/update_nonexistent/ -p shallow update
	mkdir -p tests/update_new_repo/repo
	cd tests/update_new_repo/repo/ && git init
	${WSHANDLER} -t ${TYPE} -r tests/update_new_repo --policy add scrape
	${WSHANDLER} -t ${TYPE} --root tests/update_new_repo -p shallow update

test_scrape:
	rm -rf tests/scrape
	mkdir -p tests/scrape
	cd tests/scrape; git clone --depth 1 https://github.com/asherikov/staticoma.git
	cd tests/scrape; git clone --depth 1 https://github.com/asherikov/qpmad.git
	${WSHANDLER} -t ${TYPE} -r tests/scrape --policy add scrape
	test -s tests/scrape/.${TYPE}
	${WSHANDLER} -t ${TYPE} -r tests/scrape status
	rm tests/scrape/.${TYPE}
	${WSHANDLER} -t ${TYPE} -r tests/scrape --policy add scrape tests/scrape
	test -s tests/scrape/.${TYPE}
	rm tests/scrape/.${TYPE}
	mkdir -p tests/scrape/test
	mv tests/scrape/qpmad tests/scrape/test
	${WSHANDLER} -t ${TYPE} -r tests/scrape --policy add scrape tests/scrape/test
	test -s tests/scrape/.${TYPE}
	${WSHANDLER} -t ${TYPE} -r tests/scrape status
	rm tests/scrape/.${TYPE}
	${WSHANDLER} -t ${TYPE} -r tests/scrape --policy clean scrape
	test ! -s tests/scrape/.${TYPE}
	test ! -d tests/scrape/staticoma
	test ! -d tests/scrape/test/qpmad

test_merge:
	rm -rf tests/merge
	mkdir -p tests/merge
	touch tests/merge/.${TYPE}
	${WSHANDLER} -t ${TYPE} -r tests/merge merge tests/merge_a/.${TYPE}
	${WSHANDLER} -t ${TYPE} -r tests/merge status | grep staticoma1.git > /dev/null
	${WSHANDLER} -t ${TYPE} -r tests/merge merge tests/merge_b/.${TYPE}
	${WSHANDLER} -t ${TYPE} -r tests/merge status | grep staticoma1.git > /dev/null
	${WSHANDLER} -t ${TYPE} -r tests/merge -p replace merge tests/merge_b/.${TYPE}
	${WSHANDLER} -t ${TYPE} -r tests/merge status | grep staticoma.git > /dev/null

test_remove:
	rm -Rf tests/remove
	cp -r tests/update tests/remove
	${WSHANDLER} -t ${TYPE} --root tests/remove/ remove staticoma_commit
	${WSHANDLER} -t ${TYPE} --root tests/remove/ remove_by_url "https://github.com/ros-gbp/catkin-release.git"

test_init:
	rm -rf tests/init_${TYPE} tests/init_${TYPE}_nolfs
	${WSHANDLER} -t ${TYPE} --root tests/init_${TYPE} -p shallow init git https://github.com/asherikov/staticoma.git
	${WSHANDLER} -t ${TYPE} --root tests/init_${TYPE}_nolfs -p shallow,nolfs init git https://github.com/asherikov/staticoma.git
	rm -rf tests/init_${TYPE}/ && mkdir tests/init_${TYPE}/
	touch tests/init_${TYPE}/.${TYPE}
	cd tests/init_${TYPE}/ && git clone --depth 1 https://github.com/asherikov/staticoma.git
	${WSHANDLER} -t ${TYPE} -r tests/init_${TYPE} -p add scrape
	! grep "init_${TYPE}" tests/init_${TYPE}/.${TYPE}

test_set_version:
	${WSHANDLER} -t ${TYPE} --root tests/update/ set_version_by_url https://github.com/asherikov/qpmad.git master
	! ${WSHANDLER} -t ${TYPE} --root tests/update/ set_version_by_url NONE NONE
	${WSHANDLER} -t ${TYPE} --root tests/update/ set_version_by_name qpmad_tag 1.3.0
	grep 1.3.0 tests/update/.${TYPE} > /dev/null

test_pin:
	cp tests/pin/.${TYPE} tests/pin/.${TYPE}.test_pin
	${WSHANDLER} -t ${TYPE} --root tests/pin/ -p shallow update
	# versions start as commit hashes
	grep '6a6b5d7' tests/pin/.${TYPE} > /dev/null
	grep '4c7e4e2' tests/pin/.${TYPE} > /dev/null
	# pin replaces hashes with tags when tags are available
	${WSHANDLER} -t ${TYPE} --root tests/pin/ pin
	# qpmad: tag 1.3.0 points at this commit, so hash is replaced by tag
	grep '1\.3\.0' tests/pin/.${TYPE} > /dev/null
	! grep '6a6b5d7' tests/pin/.${TYPE} > /dev/null
	# staticoma: no tag at this commit, so hash is kept
	grep '4c7e4e2' tests/pin/.${TYPE} > /dev/null
	${WSHANDLER} -t ${TYPE} --root tests/pin/ clean
	mv tests/pin/.${TYPE}.test_pin tests/pin/.${TYPE}

test_branch:
	cp tests/update/.${TYPE} tests/update/.${TYPE}.test_branch
	${WSHANDLER} -t ${TYPE} --root tests/update/ clean
	${WSHANDLER} -t ${TYPE} --root tests/update/ -p shallow update
	${WSHANDLER} -t ${TYPE} --root tests/update/ branch show
	rm -Rf tests/update/staticoma_master/README.md
	${WSHANDLER} -t ${TYPE} --root tests/update/ branch new as_remove_readme
	env GIT_AUTHOR_NAME="Your Name" GIT_AUTHOR_EMAIL="you@example.com" GIT_COMMITTER_NAME="Your Name" GIT_COMMITTER_EMAIL="you@example.com" ${WSHANDLER} -t ${TYPE} --root tests/update/ commit "Remove README.md"
	${WSHANDLER} -t ${TYPE} --root tests/update/ set_version_to_branch as_remove_readme
	! ${WSHANDLER} -t ${TYPE} --root tests/update/ set_version_to_branch as_nonexistent
	${WSHANDLER} -t ${TYPE} --root tests/update/ status
	grep as_remove_readme tests/update/.${TYPE} > /dev/null
	! grep as_nonexistent tests/update/.${TYPE} > /dev/null
	${WSHANDLER} -t ${TYPE} --root tests/update/ branch merge as_remove_readme master
	${WSHANDLER} -t ${TYPE} --root tests/update/ set_version_by_name staticoma_master master
	${WSHANDLER} -t ${TYPE} --root tests/update/ branch allnew as_new
	${WSHANDLER} -t ${TYPE} --root tests/update/ set_version_to_branch as_new
	${WSHANDLER} -t ${TYPE} --root tests/update/ status
	grep as_new tests/update/.${TYPE} > /dev/null
	${WSHANDLER} -t ${TYPE} --root tests/update/ set_version_to_hash
	${WSHANDLER} -t ${TYPE} --root tests/update/ status
	! grep as_new tests/update/.${TYPE} > /dev/null
	mv tests/update/.${TYPE}.test_branch tests/update/.${TYPE}

test_multilist:
	${WSHANDLER} -t ${TYPE} --list tests/update/.${TYPE} --list tests/remove/.${TYPE} --root tests/update/ status
	${WSHANDLER} -t ${TYPE} --list tests/update/.${TYPE} --list tests/remove/.${TYPE} status
	! ${WSHANDLER} -t ${TYPE} --list tests/update/.${TYPE} --list-discover status
	${WSHANDLER} -t ${TYPE} --root tests/update/ --list-discover status
	cp tests/remove/.${TYPE} tests/update/multilist.${TYPE}
	${WSHANDLER} -t ${TYPE} --root tests/update/ --list-discover status
	rm tests/update/multilist.${TYPE}
	mv tests/update/.${TYPE} tests/update/renamed.${TYPE}
	${WSHANDLER} -t ${TYPE} --root tests/update/ status
	mv tests/update/renamed.${TYPE} tests/update/.${TYPE}
	${WSHANDLER} -t ${TYPE} --list tests/update/.${TYPE} --list tests/remove/.${TYPE} status
	${WSHANDLER} -t ${TYPE} --list tests/update/.${TYPE} --list tests/remove/.${TYPE} --root tests/update/ -p shallow update

test_tags:
	${WSHANDLER} -t ${TYPE} --root tests/tags/ -T tag1 status | grep catkin
	! ${WSHANDLER} -t ${TYPE} --root tests/tags/ -T tag1 status | grep qpmad
	! ${WSHANDLER} -t ${TYPE} --root tests/tags/ -T tag status | grep qpmad
	${WSHANDLER} -t ${TYPE} --root tests/tags/ -T tag2 status | grep staticoma
	! ${WSHANDLER} -t ${TYPE} --root tests/tags/ -T tag2 status | grep qpmad
	${WSHANDLER} -t ${TYPE} --root tests/tags/ -T tag3 status | grep staticoma
	${WSHANDLER} -t ${TYPE} --root tests/tags/ -T tag3 status | grep qpmad
	! ${WSHANDLER} -t ${TYPE} --root tests/tags/ -T tag3 status | grep catkin
	${WSHANDLER} -t ${TYPE} --root tests/tags/ -T tag1 -T tag2 status | grep catkin
	${WSHANDLER} -t ${TYPE} --root tests/tags/ -T tag1 -T tag2 status | grep staticoma
	! ${WSHANDLER} -t ${TYPE} --root tests/tags/ -T tag1 -T tag2 status | grep qpmad

test_sparse:
	${WSHANDLER} -t ${TYPE} --root tests/sparse/ clean
	${WSHANDLER} -t ${TYPE} --root tests/sparse -p shallow,nolfs,nosubmodules update
	${WSHANDLER} -t ${TYPE} --root tests/sparse -p shallow,nolfs,nosubmodules update

test_root_git:
	rm -Rf tests/root_git
	mkdir -p tests/root_git
	touch tests/root_git/.repos
	touch tests/root_git/.rosinstall
	cd tests/root_git; git init
	${WSHANDLER} --root tests/root_git -p shallow,nosubmodules update

test_unmanaged:
	rm -rf tests/unmanaged/
	mkdir -p tests/unmanaged/
	cd tests/unmanaged/ && git clone --depth 1 https://github.com/asherikov/staticoma.git
	${WSHANDLER} --unmanaged prune tests/unmanaged/staticoma
	${WSHANDLER} -U unshallow tests/unmanaged/staticoma
	${WSHANDLER} -U update tests/unmanaged/staticoma
	${WSHANDLER} -U feature_branches tests/unmanaged/staticoma
	${WSHANDLER} -U clean tests/unmanaged/staticoma
	test ! -d tests/unmanaged/staticoma

test_env_subst:
	WSH_TEST_GIT_HOST=https://github.com ${WSHANDLER} -t ${TYPE} --root tests/env_subst/ -e status | grep "https://github.com/asherikov/staticoma.git"
	! WSH_TEST_GIT_HOST=https://github.com ${WSHANDLER} -t ${TYPE} --root tests/env_subst/ status 2>&1 | grep "https://github.com/asherikov/staticoma.git"

test_prefer_version:
	${WSHANDLER} -t ${TYPE} --root tests/prefer_version/ clean
	# prefer a nonexistent ref: at least one repo must match, should fail
	! ${WSHANDLER} -t ${TYPE} -r tests/prefer_version/ -P nonexistent_branch_that_does_not_exist update
	# prefer an existing tag (1.3.0 exists in qpmad, 1.2.0 exists in staticoma)
	${WSHANDLER} -t ${TYPE} -r tests/prefer_version/ -P 1.3.0 update
	${WSHANDLER} -t ${TYPE} --root tests/prefer_version/ status | grep 1.3.0
	# prefer an existing branch (master exists in both repos)
	${WSHANDLER} -t ${TYPE} --root tests/prefer_version/ clean
	${WSHANDLER} -t ${TYPE} -r tests/prefer_version/ -P master update
	${WSHANDLER} -t ${TYPE} --root tests/prefer_version/ status | grep master
	# clean up
	${WSHANDLER} -t ${TYPE} --root tests/prefer_version/ clean

test_push_policy:
	# setup: create local bare repo to use as remote (avoids network prompts)
	rm -rf tests/push_policy
	mkdir -p tests/push_policy/bare_qpmad
	cd tests/push_policy/bare_qpmad && git init --bare
	# clone real repo, then point origin to local bare repo
	cd tests/push_policy && git clone --depth 1 https://github.com/asherikov/qpmad.git qpmad
	BARE_QPMAD=$$(cd tests/push_policy/bare_qpmad && pwd); \
	git -C tests/push_policy/qpmad remote set-url origin "$$BARE_QPMAD"
	# generate repository list using wshandler scrape, then pin to set version to hash/tag
	${WSHANDLER} -t ${TYPE} -r tests/push_policy --policy add scrape
	${WSHANDLER} -t ${TYPE} -r tests/push_policy pin
	# version policy: repos matching the list version should be skipped (no push attempted)
	${WSHANDLER} -t ${TYPE} --root tests/push_policy/ -p version push 2>&1 | grep "Skipping"
	# default policy: should attempt push to local bare repo (should succeed, no "Skipping")
	! ${WSHANDLER} -t ${TYPE} --root tests/push_policy/ -p default push 2>&1 | grep "Skipping"

test_sed:
	# sed replaces github.com with example.com in repo URLs
	${WSHANDLER} -t ${TYPE} --root tests/update/ -s 's|github\.com|example.com|g' status | grep "example.com/asherikov/staticoma.git"
	${WSHANDLER} -t ${TYPE} --root tests/update/ -s 's|github\.com|example.com|g' status | grep "example.com/asherikov/qpmad.git"
	# without sed, URLs should remain unchanged
	${WSHANDLER} -t ${TYPE} --root tests/update/ status | grep "github.com/asherikov/staticoma.git"
	! ${WSHANDLER} -t ${TYPE} --root tests/update/ status | grep "example.com"
	# sed with update: the replaced URL should be passed to the clone command
	rm -rf tests/update/staticoma tests/update/qpmad
	! ${WSHANDLER} -t ${TYPE} --root tests/update/ -s 's|github\.com|invalid\.invalid|g' update 2>&1

shellcheck:
	shellcheck wshandler

clean:
	rm -Rf build

WGET=wget --progress=dot:giga --timestamping --no-check-certificate
# aarch64
export ARCH?=x86_64
# arm64
YQ_ARCH?=amd64
APPDIR=build/appimage/AppDir_${ARCH}/

# --appimage-help
appimage:
	rm -Rf ${APPDIR}
	mkdir -p ${APPDIR}/usr/bin
	# https://github.com/AppImage/type2-runtime/issues/47
	# ${WGET} https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
	cd build/appimage \
		&& ${WGET} https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage \
		&& ${WGET} https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${YQ_ARCH}.tar.gz \
		&& tar -xf 'yq_linux_${YQ_ARCH}.tar.gz' -O > "AppDir_${ARCH}/usr/bin/yq" \
		&& chmod +x appimagetool-x86_64.AppImage
	cp wshandler "${APPDIR}/usr/bin/"
	test -z "${WSHANDLER_VERSION}" || sed -i -e "s/WSH_VERSION=/WSH_VERSION=${WSHANDLER_VERSION}/g" "${APPDIR}/usr/bin/wshandler"
	cp appimage/AppRun "${APPDIR}/AppRun"
	chmod +x "${APPDIR}/AppRun"
	chmod +x "${APPDIR}/usr/bin/yq"
	cp appimage/wshandler.png "${APPDIR}"
	cp appimage/wshandler.desktop "${APPDIR}"
	# --appimage-extract-and-run to avoid dependency on fuse in CI
	cd build/appimage \
		&& ./appimagetool-x86_64.AppImage \
		AppDir_${ARCH} wshandler-yq-${ARCH}.AppImage
	# broken?
	# --updateinformation "gh-releases-zsync|asherikov|wshandler|latest|wshandler-${ARCH}.AppImage.zsync"

appimage_deps:
	sudo apt install -y --no-install-recommends desktop-file-utils zsync

.PHONY: appimage

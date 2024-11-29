TYPE?=rosinstall
WSHANDLER?=./wshandler

test: shellcheck
	@${MAKE} test_type TYPE=rosinstall
	@${MAKE} test_type TYPE=repos
	@${MAKE} test_root_git
	${WSHANDLER} -r tests/clone -p shallow clone git https://github.com/asherikov/sharf.git main

test_type:
	@${MAKE} wrap_test TEST=test_update
	@${MAKE} wrap_test TEST=test_remove
	@${MAKE} wrap_test TEST=test_scrape
	@${MAKE} wrap_test TEST=test_merge
	@${MAKE} wrap_test TEST=test_set_version
	@${MAKE} wrap_test TEST=test_branch
	@${MAKE} wrap_test TEST=test_init

wrap_test:
	@echo ""
	@echo "${TEST} >>> ##############################################################"
	${MAKE} --quiet ${TEST}
	@echo "${TEST} <<< ##############################################################"
	@echo ""

test_update:
	${WSHANDLER} -t ${TYPE} --root tests/update/ clean
	${WSHANDLER} -t ${TYPE} -r tests/update/ status
	${WSHANDLER} -t ${TYPE} -r tests/update/ --jobs 2 update
	${WSHANDLER} -t ${TYPE} --root tests/update/ status
	${WSHANDLER} -t ${TYPE} --root tests/update/ -j 2 clean
	${WSHANDLER} -t ${TYPE} -r tests/update/ --jobs 2 --policy shallow update
	${WSHANDLER} -t ${TYPE} -r tests/update/ unshallow staticoma
	${WSHANDLER} -t ${TYPE} --root tests/update/ status
	${WSHANDLER} -t ${TYPE} --root tests/update/ -j 2 clean
	${WSHANDLER} -t ${TYPE} -r tests/update/ --jobs 2 --policy shallow,rebase,nolfs update
	${WSHANDLER} -t ${TYPE} --root tests/update/ status
	${WSHANDLER} -t ${TYPE} --root tests/update/ -j 2 clean
	${WSHANDLER} -t ${TYPE} -r tests/update/ --jobs 2 --policy rebase update
	${WSHANDLER} -t ${TYPE} --root tests/update/ status
	${WSHANDLER} -t ${TYPE} --root tests/update/ -j 2 clean

test_scrape:
	rm -rf tests/scrape
	mkdir -p tests/scrape
	cd tests/scrape; git clone https://github.com/asherikov/staticoma.git
	cd tests/scrape; git clone https://github.com/asherikov/qpmad.git
	${WSHANDLER} -t ${TYPE} -r tests/scrape --policy add scrape
	${WSHANDLER} -t ${TYPE} -r tests/scrape status

test_merge:
	rm -rf tests/merge
	cp -r tests/merge_a tests/merge
	${WSHANDLER} -t ${TYPE} -r tests/merge status
	${WSHANDLER} -t ${TYPE} -r tests/merge merge tests/merge_b/.${TYPE}
	${WSHANDLER} -t ${TYPE} -r tests/merge status
	${WSHANDLER} -t ${TYPE} -r tests/merge -p replace merge tests/merge_b/.${TYPE}
	${WSHANDLER} -t ${TYPE} -r tests/merge status

test_remove:
	rm -Rf tests/remove
	cp -r tests/update tests/remove
	${WSHANDLER} -t ${TYPE} --root tests/remove/ remove staticoma_commit
	${WSHANDLER} -t ${TYPE} --root tests/remove/ remove_by_url "https://github.com/ros-gbp/catkin-release.git"

test_init:
	${WSHANDLER} -t ${TYPE} --root tests/init_${TYPE} -p shallow init git https://github.com/asherikov/staticoma.git
	${WSHANDLER} -t ${TYPE} --root tests/init_${TYPE}_nolfs -p shallow,nolfs init git https://github.com/asherikov/staticoma.git

test_set_version:
	${WSHANDLER} -t ${TYPE} --root tests/update/ set_version_by_url https://github.com/asherikov/qpmad.git master
	${WSHANDLER} -t ${TYPE} --root tests/update/ set_version_by_name qpmad_tag 1.3.0

test_branch:
	${WSHANDLER} -t ${TYPE} --root tests/update/ clean
	${WSHANDLER} -t ${TYPE} --root tests/update/ update
	${WSHANDLER} -t ${TYPE} --root tests/update/ branch show
	rm -Rf tests/update/staticoma_master/README.md
	${WSHANDLER} -t ${TYPE} --root tests/update/ branch new as_remove_readme
	env GIT_AUTHOR_NAME="Your Name" GIT_AUTHOR_EMAIL="you@example.com" GIT_COMMITTER_NAME="Your Name" GIT_COMMITTER_EMAIL="you@example.com" ${WSHANDLER} -t ${TYPE} --root tests/update/ commit "Remove README.md"
	${WSHANDLER} -t ${TYPE} --root tests/update/ branch switch as_remove_readme
	${WSHANDLER} -t ${TYPE} --root tests/update/ status
	${WSHANDLER} -t ${TYPE} --root tests/update/ branch merge as_remove_readme master
	${WSHANDLER} -t ${TYPE} --root tests/update/ set_version_by_name staticoma_master master

test_root_git:
	rm -Rf tests/root_git
	mkdir -p tests/root_git
	touch tests/root_git/.repos
	touch tests/root_git/.rosinstall
	cd tests/root_git; git init
	${WSHANDLER} --root tests/root_git update

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
	cp appimage/AppRun "${APPDIR}/AppRun"
	chmod +x "${APPDIR}/AppRun"
	chmod +x "${APPDIR}/usr/bin/yq"
	cp appimage/wshandler.png "${APPDIR}"
	cp appimage/wshandler.desktop "${APPDIR}"
	# --appimage-extract-and-run to avoid dependency on fuse in CI
	cd build/appimage \
		&& ./appimagetool-x86_64.AppImage AppDir_${ARCH} wshandler-${ARCH}.AppImage

.PHONY: appimage

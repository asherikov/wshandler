TYPE=rosinstall

test: shellcheck
	@${MAKE} test_type TYPE=rosinstall
	@${MAKE} test_type TYPE=repos

test_type:
	@${MAKE} wrap_test TEST=test_update
	@${MAKE} wrap_test TEST=test_remove
	@${MAKE} wrap_test TEST=test_scrape
	@${MAKE} wrap_test TEST=test_merge
	@${MAKE} wrap_test TEST=test_set_version

wrap_test:
	@echo ""
	@echo "${TEST} >>> ##############################################################"
	${MAKE} --quiet ${TEST}
	@echo "${TEST} <<< ##############################################################"
	@echo ""

test_update:
	./wshandler -t ${TYPE} --root tests/update/ clean
	./wshandler -t ${TYPE} -r tests/update/ status
	./wshandler -t ${TYPE} -r tests/update/ --jobs 2 update
	./wshandler -t ${TYPE} --root tests/update/ status
	./wshandler -t ${TYPE} --root tests/update/ -j 2 clean
	./wshandler -t ${TYPE} -r tests/update/ --jobs 2 --policy shallow update
	./wshandler -t ${TYPE} --root tests/update/ status
	./wshandler -t ${TYPE} --root tests/update/ -j 2 clean
	./wshandler -t ${TYPE} -r tests/update/ --jobs 2 --policy shallow,rebase update
	./wshandler -t ${TYPE} --root tests/update/ status
	./wshandler -t ${TYPE} --root tests/update/ -j 2 clean
	./wshandler -t ${TYPE} -r tests/update/ --jobs 2 --policy rebase update
	./wshandler -t ${TYPE} --root tests/update/ status
	./wshandler -t ${TYPE} --root tests/update/ -j 2 clean

test_scrape:
	rm -rf tests/scrape
	mkdir -p tests/scrape
	cd tests/scrape; git clone https://github.com/asherikov/staticoma.git
	cd tests/scrape; git clone https://github.com/asherikov/qpmad.git
	./wshandler -t ${TYPE} -r tests/scrape --policy add scrape
	./wshandler -t ${TYPE} -r tests/scrape status

test_merge:
	rm -rf tests/merge
	cp -r tests/merge_a tests/merge
	./wshandler -t ${TYPE} -r tests/merge status
	./wshandler -t ${TYPE} -r tests/merge merge tests/merge_b/.${TYPE}
	./wshandler -t ${TYPE} -r tests/merge status
	./wshandler -t ${TYPE} -r tests/merge -p replace merge tests/merge_b/.${TYPE}
	./wshandler -t ${TYPE} -r tests/merge status

test_remove:
	rm -Rf tests/remove
	cp -r tests/update tests/remove
	./wshandler -t ${TYPE} --root tests/remove/ remove staticoma_commit
	./wshandler -t ${TYPE} --root tests/remove/ remove_by_url "https://github.com/ros-gbp/catkin-release.git"


test_set_version:
	./wshandler -t ${TYPE} --root tests/update/ set_version_by_url https://github.com/asherikov/qpmad.git master
	./wshandler -t ${TYPE} --root tests/update/ set_version_by_name qpmad_tag 1.3.0

shellcheck:
	shellcheck ./wshandler
	shellcheck ./install.sh

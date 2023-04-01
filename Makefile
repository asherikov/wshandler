TYPE=rosinstall

test: shellcheck
	@${MAKE} wrap_test TEST=test_update TYPE=rosinstall
	@${MAKE} wrap_test TEST=test_scrape TYPE=rosinstall
	@${MAKE} wrap_test TEST=test_merge TYPE=rosinstall
	@${MAKE} wrap_test TEST=test_update TYPE=repos
	@${MAKE} wrap_test TEST=test_scrape TYPE=repos
	@${MAKE} wrap_test TEST=test_merge TYPE=repos

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

shellcheck:
	shellcheck ./wshandler
	shellcheck ./install.sh

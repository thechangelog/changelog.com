.PHONY: linode-cli-token
linode-cli-token:
ifndef LINODE_CLI_TOKEN
	@echo "$(RED)LINODE_CLI_TOKEN$(NORMAL) environment variable must be set" && \
	echo "Learn more about Linode API tokens $(BOLD)https://cloud.linode.com/profile/tokens$(NORMAL) " && \
	exit 1
endif

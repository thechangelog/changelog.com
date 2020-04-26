.PHONY: tmp/changelog-ten.html
tmp/changelog-ten.html:
	@printf "Using $(BOLD)$(GREEN)https://github.com/gildas-lormeau/SingleFile$(NORMAL) " \
	; printf "save $(BOLD)https://changelog.com/ten$(NORMAL) to $(BOLD)$(@)$(NORMAL)\n" \
	; read -rp "(press any key to confirm)" -n 1

.PHONY: ten-image
ten-image: ten-image-build ten-image-publish

.PHONY: ten-image-build
ten-image-build: BUILD_VERSION = 2019-11-01T10.10.10Z
ten-image-build: $(DOCKER) tmp/changelog-ten.html
	@$(DOCKER) build \
	  --pull \
	  --tag thechangelog/ten:$(BUILD_VERSION) \
	  --file docker/Dockerfile.ten \
	  $(CURDIR)

.PHONY: ten-image-publish
ten-image-publish: BUILD_VERSION = 2019-11-01T10.10.10Z
ten-image-publish: $(DOCKER)
	@$(DOCKER) push thechangelog/ten:$(BUILD_VERSION)

TEN_DEPLOYMENT := ten-changelog
TEN_NAMESPACE := $(TEN_DEPLOYMENT)
TEN_TREE := $(KUBETREE) deployments $(TEN_DEPLOYMENT) --namespace $(TEN_NAMESPACE)
# Copy of https://changelog.com/ten
.PHONY: lke-ten-changelog
lke-ten-changelog: lke-ctx $(KUBETREE) $(YTT)
	$(YTT) \
	  --data-value name=$(TEN_DEPLOYMENT) \
	  --data-value namespace=$(TEN_NAMESPACE) \
	  --file $(CURDIR)/k8s/ten-changelog > $(CURDIR)/k8s/ten-changelog.yml \
	&& $(KUBECTL) apply --filename $(CURDIR)/k8s/ten-changelog.yml \
	&& $(TEN_TREE)

.PHONY: lke-ten-changelog-tree
lke-ten-changelog-tree: lke-ctx $(KUBETREE)
	$(TEN_TREE)

.PHONY: lke-ten-changelog-logs
lke-ten-changelog-logs: lke-ctx
	$(KUBECTL) logs deployments/$(TEN_DEPLOYMENT) --namespace $(TEN_NAMESPACE) --follow

.PHONY: lke-ten-changelog-certificate
lke-ten-changelog-certificate: lke-ctx
	$(KUBECTL) describe certificate --namespace $(TEN_NAMESPACE)

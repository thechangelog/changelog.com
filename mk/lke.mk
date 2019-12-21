# https://www.linode.com/docs/kubernetes/deploy-and-manage-lke-cluster-with-api-a-tutorial/

LKE_CONFIGS := $(CURDIR)/.kube/configs

ifeq ($(PLATFORM),Darwin)
PIP ?= /usr/local/bin/pip3
$(PIP):
	@brew install python3

LINODE_CLI ?= /usr/local/bin/linode-cli
$(LINODE_CLI): $(PIP)
	@$(PIP) install linode-cli

OCTANT ?= /usr/local/bin/octant
$(OCTANT):
	@brew install octant

K9S ?= /usr/local/bin/k9s
$(K9S):
	@brew install derailed/k9s/k9s
endif
ifeq ($(PLATFORM),Linux)
LINODE_CLI ?= /usr/bin/linode-cli
$(LINODE_CLI):
	$(error Please install linode-cli: https://github.com/linode/linode-cli)

OCTANT ?= /usr/bin/octant
$(OCTANT):
	$(error Please install octant: https://github.com/vmware-tanzu/octant#installation)

K9S ?= /usr/bin/k9s
$(K9S):
	$(error Please install k9s: https://github.com/derailed/k9s#installation)
endif

LINODE := $(LINODE_CLI) --all

.PHONY: linode
linode: $(LINODE_CLI) linode-cli-token

LKE_LS := $(LINODE) lke clusters-list
.PHONY: lke-ls
lke-ls: linode
	@$(LKE_LS)

$(LKE_CONFIGS):
	@mkdir -p $(LKE_CONFIGS)

.PHONY: lke-configs
lke-configs: linode $(LKE_CONFIGS)
	@$(LKE_LS) --json \
	  | $(JQ) --raw-output --compact-output '.[] | [.id, .label] | join(" ")' \
	  | while read -r lke_id lke_name \
	    ; do \
	      printf "Saving $(BOLD)$$lke_name$(NORMAL) LKE cluster config to $(BOLD)$(LKE_CONFIGS)/$$lke_name.yml$(NORMAL) ...\n" \
	      ; $(LINODE) lke kubeconfig-view $$lke_id --no-headers --text \
	      | base64 --decode \
	      > $(LKE_CONFIGS)/$$lke_name.yml \
	    ; done \
	  && printf "$(BOLD)$(GREEN)OK!$(NORMAL)\n" \
	  && printf "\nTo use a specific config with $(BOLD)kubectl$(NORMAL), run e.g. $(BOLD)export KUBECONFING=$(NORMAL)\n"

IS_KUBECONFIG_LKE_CONFIG := $(findstring $(LKE_CONFIGS), $(KUBECONFIG))
define HINT_LKE_CONFIG
printf "You may want to set $(BOLD)KUBECONFIG$(NORMAL) " \
; printf "to one of the configs stored in $(BOLD)$(LKE_CONFIGS)$(NORMAL)\n"
endef

# https://octant.dev/
.PHONY: lke-inspect
lke-inspect: $(OCTANT)
ifneq ($(IS_KUBECONFIG_LKE_CONFIG), $(LKE_CONFIGS))
	@$(HINT_LKE_CONFIG)
endif
	@$(OCTANT)

# https://github.com/derailed/k9s
.PHONY: lke-cli
lke-cli: $(K9S)
ifneq ($(IS_KUBECONFIG_LKE_CONFIG), $(LKE_CONFIGS))
	@$(HINT_LKE_CONFIG)
endif
	@$(K9S)

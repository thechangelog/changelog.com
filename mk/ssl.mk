ifeq ($(PLATFORM),Darwin)
OPENSSL := /usr/local/opt/openssl/bin/openssl
$(OPENSSL):
	@brew install openssl
endif
ifeq ($(PLATFORM),Linux)
OPENSSL := /usr/bin/openssl
$(OPENSSL):
	@sudo apt-get update && sudo apt-get install openssl
endif

XDG_CONFIG_HOME := $(CURDIR)/.config
export XDG_CONFIG_HOME

CERTBOT_CONFIG_DIR := $(XDG_CONFIG_HOME)/certbot
CERTBOT_ETC := $(CERTBOT_CONFIG_DIR)/etc/letsencrypt
$(CERTBOT_ETC):
	mkdir -p $(@)
CERTBOT_DATA := $(CERTBOT_CONFIG_DIR)/var/lib/letsencrypt
$(CERTBOT_DATA):
	mkdir -p $(@)

.PHONY: ssl-report
ssl-report: ## ssl | Run an SSL report via SSL Labs
	@open "https://www.ssllabs.com/ssltest/analyze.html?d=$(HOSTNAME)&latest"
.PHONY: ssl
ssl: ssl-report

# https://www.linode.com/docs/platform/nodebalancer/nodebalancer-reference-guide/#diffie-hellman-parameters
terraform/dhparams.pem: $(OPENSSL)
	@$(OPENSSL) dhparam -out terraform/dhparams.pem 2048

ifneq ($(DEBUG),)
CERTBOT_EXTRAS := -vvv --debug
endif
ifneq ($(TEST),)
CERTBOT_EXTRAS := $(CERTBOT_EXTRAS) --test-cert
endif
.PHONY: cert
cert: | $(DOCKER) $(CERTBOT_ETC) $(CERTBOT_DATA)
	$(DOCKER) run --interactive --tty --rm --name certbot \
	  --volume "$(CERTBOT_ETC):/etc/letsencrypt" \
	  --volume "$(CERTBOT_DATA):/var/lib/letsencrypt" \
	  certbot/certbot \
	  certonly $(CERTBOT_EXTRAS) \
	  --agree-tos \
	  -m services@changelog.com \
	  --preferred-challenges dns \
	  --manual \
	  -d '*.changelog.com' \
	  -d changelog.com

.PHONY: certs
certs: | $(DOCKER) $(CERTBOT_ETC) $(CERTBOT_DATA)
	$(DOCKER) run --interactive --tty --rm --name certbot \
	  --volume "$(CERTBOT_ETC):/etc/letsencrypt" \
	  --volume "$(CERTBOT_DATA):/var/lib/letsencrypt" \
	  certbot/certbot \
	  certificates

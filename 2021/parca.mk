# https://www.parca.dev/docs/kubernetes
# Agent & server versions on the website are always in sync.
# It is re-generated in Vercel after a release gets created:
# - https://github.com/parca-dev/parca/blob/7dc4a2456d95b124459fbc7661c9d9b9099f126d/.github/workflows/release.yml#L92-L94
# - https://github.com/parca-dev/parca.dev/blame/da283aec395887e0bfff05d126897ef1e6b72323/docs/kubernetes.mdx#L89

PARCA_SERVER_RELEASES := https://github.com/parca-dev/parca/releases
PARCA_SERVER_VERSION := 0.4.2

PARCA_AGENT_RELEASES := https://github.com/parca-dev/parca-agent/releases
PARCA_AGENT_VERSION := 0.2.0

.PHONY: lke-parca
lke-parca: | lke-ctx
	@printf "Create namespace to avoid any race conditions. $(BOLD)@brancz$(RESET) recommedation 👍\n"
	$(KUBECTL) get namespace parca || $(KUBECTL) create namespace parca
	$(KUBECTL) $(K_CMD) --filename https://github.com/parca-dev/parca-agent/releases/download/v$(PARCA_AGENT_VERSION)/kubernetes-manifest.yaml
	$(KUBECTL) $(K_CMD) --filename https://github.com/parca-dev/parca/releases/download/v$(PARCA_SERVER_VERSION)/kubernetes-manifest.yaml
lke-bootstrap:: | lke-parca

.PHONY: lke-parca-delete
lke-parca-delete: K_CMD = delete --ignore-not-found=true
lke-parca-delete: lke-parca

# 
.PHONY: lke-parca-pr-132
lke-parca-pr-132: | lke-ctx
	@printf "$(YELLOW)Try out PR #132: $(BOLD)https://github.com/parca-dev/parca-agent/pull/132$(RESET)\n"
	$(KUBECTL) patch daemonset parca-agent --namespace parca --patch-file manifests/parca/pr-132-patch.yml

# http://localhost:7070 (port forwarded to the server)
#
# Tip: hold SHIFT to click on a label in the overlay menu when hovering over a datapoint
#
# 🤯 While browsing the CPU Samples for a specific system process,
# click Compare, then click on a low datapoint in the left graph and high datapoint in the right one
# - Green means less CPU activity
# - Blue means the same amount of CPU activity
# - Red means more CPU activity
#
#
# Parca is built and exposes the standards eBPF, pprof etc.
# Download pprof file from the agent - http://localhost:7071 - for a specific "Show CPU profile"
#
# Use pprof to analyse that profile locally:
# perf report -i /tmp/perf.data
#
# For time spent in each function without its children:
# perf report --no-children -i /tmp/perf.data
#
# More context on the above:
# https://www.erlang-solutions.com/blog/performance-testing-the-jit-compiler-for-the-beam-vm#profiling
#
#
# Nice surprise (for another time): https://github.com/pyrra-dev/pyrra & https://demo.pyrra.dev/

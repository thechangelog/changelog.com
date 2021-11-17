# - [ ] Delete providers from https://cloud.upbound.io/changelogmedia/controlPlanes/16e3a96e-6505-4ad8-af96-098d5ba1eba4/settings
# - [ ] Delete control plane
# - [ ] Create new control plane - ensure it gets provisioned as v1.4.x-up
# - [ ] Use provider-tf-template to generate a Linode Crossplane provider from Terraform
# 	- https://github.com/crossplane-contrib/provider-tf-template
# 	- https://github.com/linode/terraform-provider-linode + https://registry.terraform.io/providers/linode/linode/latest/docs
# 	- https://github.com/crossplane-contrib/terrajet (the tool behind it)
# - [ ] Use a composite resource to provision the cluster + node pools, don't provision them separately
# 	- https://github.com/upbound/platform-ref-multi-k8s
# - [ ] Provision baseline K8s components via the composite resource, e.g. external-dns, traefik, etc.

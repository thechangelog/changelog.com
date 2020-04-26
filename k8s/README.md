# The new changelog.com setup for 2020

We have been talking about running changelog.com on Kubernetes (K8S) for a few years now.
This year we finally did it, the entire changelog.com infrastructure is running on Linode Kubernetes Engine, or LKE for short.

In this blog post we describe the entire setup, talk about why we made certain choices, and hopefully provide inspiration for your K8S journey.
Everything that we did for the changelog.com 2020 setup is available to you in a single command: `make changelog-2020` (add `--dry-run` if you only want to see what this command does, without actually running anything).
This command will resolve all dependencies, provision a new Linode Kubernetes Engine, and finally deploy onto LKE everything that goes into building & running changelog.com:

- [x] DNS integration (external-dns)
- [x] proxy (nginx-ingress with cert-manager)
- [ ] **monitoring, visualisation & logging (Prometheus, Grafana, Weave Scope & Loki)**
- [ ] highly-available database with disaster recovery (Crunchy Data PostgreSQL with pgBackRest & pgMonitor)
- [ ] web app (Phoenix)

If you have a domain that is managed by one of the DNS providers supported by [external-dns](https://github.com/kubernetes-sigs/external-dns), this setup will even manage DNS for you.
For example, given a **gerhard.io** domain, it takes 1 command to get the entire Changelog setup running at https://changelog.gerhard.io.
If you follow the link, you will see exactly what I mean.

Once you get the entire Changelog setup running in your own LKE cluster, you can see how various pieces fit together, experiment and better understand one way of combining a small subset of services that are made to run on K8S out of the box.
As you do this, I encourage you to explore the other make targets that begin with `lke-`, such as `lke-cli`, `lke-inspect`, etc.
Each of these commands makes it easy to use tools that are great `kubectl` companions, like [Octant](https://octant.dev/), [K9S](https://github.com/derailed/k9s) & [Popeye](https://github.com/derailed/popeye), [kapp](https://get-kapp.io/), etc.
They all run locally, on your host, and can be used with any K8S, including [kind](https://kind.sigs.k8s.io/).

If you find this useful and want to show your appreciation, we welcome your contributions via https://github.com/thechangelog/changelog.com.
This is the same place where you will find all changelog.com code and configuration, including the Phoenix web app codebase.
This post is a follow-up to [The new changelog.com setup for 2019](https://changelog.com/posts/the-new-changelog-setup-for-2019) & [The code behind Changelog's infrastructure](https://changelog.com/posts/the-code-behind-changelog-infrastructure), 
as well as [Changelog.com is open source](https://changelog.com/posts/changelog-is-open-source).

## Why K8S for 2020?

---

[Darren Shepherd, @ibuildthecloud](https://twitter.com/ibuildthecloud/status/1212216198596661248)
> I really don't get how people navigate the k8s ecosystem.
> It's so vast, so complex, and most projects are largely unproven.
> How do you gauge if the time investment to learn some new framework is worth it.
> I do this full time and it's even a struggle for me.

[Gerhard Lazu, @gerhardlazu](https://twitter.com/gerhardlazu/status/1212398935366668288?s=20)
> Start from the business goals & take small steps towards delivering vertical slices, on K8S.
> Current context: migrate http://changelog.com from Swarm to LKE.
> Larger context: https://changelog.com/posts/the-new-changelog-setup-for-2019.
> So far, so good: https://github.com/thechangelog/changelog.com/blob/master/mk/lke.mk

---

[Jim Angel](https://twitter.com/jimmangel/status/1213855850986651648)
> One of my biggest 💡 moments for Kubernetes was when my perspective shifted from:
> "K8s needs LTS (long term support), it's too hard to keep up in enterprise environments"
> to:
> "We need to keep up with upstream K8s releases and begin treating platforms like software"

---

## [Linode 2020 Roadmap](https://www.linode.com/2019/12/30/2019-a-year-in-review)

Wanted roadmap items which are planned, sorted by interest (most interesting first):

1. Cloud Firewall to control network traffic to your Linodes
1. Per customer network VLAN
1. Linode Kubernetes Engine global availability

Nice to have roadmap items which are planned, won't be too disappointed if they don't ship:

1. NodeBalancer PROXY protocol support - only if this can be configured from within K8S
1. NodeBalancer automatic Let’s Encrypt support - only if this can be configured from within K8S, Traefik ingress feels sufficient
1. Bare Metal machines with cloud infrastructure management - only if it improves K8S performance
1. Anycast Network for improved routing - only if LKE & managed databases can be replicated
1. Managed Databases for production-ready DBs - Crunchy Data PostgreSQL K8S Operator does the job

Missing roadmap items:

1. Linode stack for Crossplane - especially in combination with the next item
1. Customize default LKE deployment - Prometheus, Grafana, Loki, Harbor, etc.
1. Latest K8S versions always available - currently want 1.17
1. Containerd runtime alternative to Docker
1. [Container-native load-balancing](https://cloud.google.com/kubernetes-engine/docs/how-to/container-native-load-balancing)
1. NodeBalancer as K8S Ingress

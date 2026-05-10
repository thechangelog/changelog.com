Three agents, three VMs, three filesystems. None step on each other.

When an agent goes astray, the blast radius is one VM, not the host. Save the
good changes to the host mount & replace the VM with a fresh one. The most
pragmatic take on "Bring yourself back online". No setup. No polluting the Mac.
No monthly bill. Just Genesis, doing what Adam built it to do.

This document is the blueprint: the story behind the setup, the thinking behind
different choices, and the practical instructions to start contributing to
changelog.com with Claude. Launch, vibe, keep, destroy, repeat.

Adam already runs Claude Code as a daily driver. He just hasn't pointed it at
changelog.com yet. With Jerod's departure, he's the developer now, and this is
the on-ramp: a full dev environment, ready to go, running on Genesis. Claude
Code and all the relevant tooling is already installed. The documentation is
there, and so is all the knowledge that we (Jerod, Gerhard & Adam) have been
consolidating [over the years](https://changelog.com/topic/kaizen).

## What is Genesis?

The dev environment needs fast builds and headroom for agents. **Genesis**
already has both: an
[i9-13900K](https://ark.intel.com/content/www/us/en/ark/products/230496/intel-core-i9-13900k-processor-36m-cache-up-to-5-80-ghz.html)
(8P+16E cores, 32 threads, up to 5.8 GHz) with 128 GiB DDR5, running Ubuntu
with Ollama + Open Web UI for local LLMs. Of all Adam's machines, it has the
fastest CPU, the most RAM, and it's already running the OS he trusts for
servers.

Ollama is GPU-bound (3090 VRAM), not CPU-bound: the 70B model is *"a little
slower, but 32B is pretty fast, almost real time"* ([Friends #81,
L1057](https://github.com/thechangelog/transcripts/blob/master/friends/changelog--friends-81.md#L1057)).
Between queries Genesis idles. An 8 vCPU / 16 GiB VM uses a quarter of the
threads and an eighth of the RAM, leaving plenty for Ollama and the host, even
if running multiple instances.

Adam already uses Tailscale + SSH across his homelab: *"I just type 'SSH
Cineplex', because that's what it's named in Tailscale"* ([Friends #121,
L337](https://github.com/thechangelog/transcripts/blob/master/friends/changelog--friends-121.md#L337)).
The same applies here. SSH into the VM from the MacBook, from Silicon Valley,
from anywhere on the Tailnet. Claude Code runs in the terminal, so SSH is
the dev environment.

How does Genesis compare to changelog.com production?

| Environment                       | vCPUs | RAM    | Cost/mo | Notes                                       |
| --------------------------------- | ----: | -----: | ------: | ------------------------------------------- |
| **Fly.io performance-1x** (prod)  | 1     | 2 GB   | $32     | What changelog.com runs on today            |
| **Fly.io performance-8x**         | 8     | 16 GB  | $258    | Equivalent to this VM                       |
| **This VM**                       | 8     | 16 GB  | $0      | Dedicated vCPUs, local, no noisy neighbors  |
| Adam's **Genesis** (host)         | 24    | 128 GB | -       | i9-13900K, the VM runs inside this          |

The VM uses 8 of Genesis's 32 threads and 16 of its 128 GiB. It's 8x more
powerful than production, and equivalent to $258/mo of Fly.io compute. And all
for free, because Adam already owns this hardware.

## Why a VM? What VM? How?

A VM provides the ideal isolation layer for a tool that requires all the
privileges & runs in auto mode - `claude` - but that we can reset to a good
known state easily. It gets its own kernel, network, memory and CPU, without
being able to affect the physical host.

We want something boring, straightforward and proven. While microVMs are cool,
they can be finnicky. Adam has already expressed interest in something simpler.
Enter [Incus](https://github.com/lxc/incus), a true open
source VM manager from the Linux Containers community. Proxmox works
great for the homelab, but Incus VMs are CLI-native: no web UI, no
cluster config, just `incus launch` and go. For disposable agent
workspaces that get created and destroyed hourly, that's the right
trade-off.

Run these instructions locally, [because documentation
first](https://changelog.com/shipit/44#transcript-34). This is a blueprint, not
a ready-built image. Blueprints give LLMs a solid starting point to improve on,
and they give others following the journey the ingredients to take things in
their own direction. That is the
[Kaizen spirit](https://changelog.com/topic/kaizen).

## Create the VM blueprint ⏱️ `20-30mins`

This is what "bring yourself back online" looks like in practice. Starting from
a bare metal Ubuntu host, we build one reusable image with everything
pre-installed. Launch, vibe, keep, destroy, repeat.

> [!TIP]
> The image is always called `changelog`. Instances are called
> `changelog-<purpose>`, e.g. `changelog-vibe`.

### 1/7. A VM manager that stays out of the way ⏱️ `1-2mins`

The Ubuntu 24.04 (and also 26.04) apt repo only has Incus 6.x LTS. Use the
[Zabbly repo](https://github.com/zabbly/incus) for the latest stable release.

```bash
sudo mkdir -p /etc/apt/keyrings/
curl -fsSL https://pkgs.zabbly.com/key.asc | sudo tee /etc/apt/keyrings/zabbly.asc > /dev/null

sudo sh -c 'cat <<EOF > /etc/apt/sources.list.d/zabbly-incus-stable.sources
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/incus/stable
Suites: $(. /etc/os-release && echo ${VERSION_CODENAME})
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/zabbly.asc
EOF'

sudo apt update
sudo apt install -y incus
```

Add your user to the `incus-admin` group so Incus commands work without `sudo`
(log out and back in after):

```bash
sudo usermod -aG incus-admin $USER
newgrp incus-admin
```

Verify:

```bash
incus version
# If this is your first time running Incus on this machine, you should also run: incus admin init
# To start your first container, try: incus launch images:opensuse/tumbleweed
# Or for a virtual machine: incus launch images:opensuse/tumbleweed --vm
# 
# Client version: 7.0.0
# Server version: 7.0.0
```

### 2/7. A real IP on the LAN ⏱️ `1min`

```bash
incus admin init --minimal
```

This creates a `dir` storage pool at `/var/lib/incus/storage-pools/default/`
with no network bridge. The changelog VM uses macvlan on the physical LAN
interface, so it gets an IP directly from the network, no bridge needed.

The default Incus profile uses a NAT bridge, but we want the VM to get an IP
directly from the LAN. Create a profile that uses macvlan on the physical
network interface instead:

```bash
incus profile create macvlan
incus profile device add macvlan eth0 nic nictype=macvlan parent=enp97s0
incus profile device add macvlan root disk path=/ pool=default
```

> [!NOTE]
> In the command above, `enp97s0` is the physical network interface on Genesis.
> Replace this with your host's interface (check with `ip link`). Every VM
> launched with this profile gets its own LAN IP via DHCP, no bridge needed.

### 3/7. Boot with truth mounted ⏱️ `1-2mins`

```bash
incus launch images:ubuntu/24.04 changelog --vm \
  -p macvlan \
  -c limits.cpu=8 \
  -c limits.memory=16GiB \
  -d root,size=100GiB
until incus exec changelog -- true 2>/dev/null; do sleep 1; done
incus config device add changelog truth disk \
  source=$HOME/github.com/thechangelog/changelog.com \
  path=/truth
incus exec changelog -- su - ubuntu
```

Every VM is disposable, but the code isn't. The host's project directory is
mounted into the VM at `/truth`, a single source of truth that outlives every
boot-work-keep-destroy cycle.

### 4/7. Everything the system needs ⏱️ `2-4mins`

```bash
sudo apt install -y build-essential curl fish git inotify-tools libicu-dev libncurses-dev libreadline-dev libssl-dev rsync tmux unzip
sudo chsh -s /usr/bin/fish ubuntu
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
curl -fsSL https://get.docker.com | sudo bash
sudo usermod -aG docker ubuntu
exit
```

Re-enter to get fish shell + docker group:

```bash
incus exec changelog -- su - ubuntu
```

Integrate Homebrew into fish:

```fish
set -e fish_greeting
set -U fish_greeting ""

mkdir -p ~/.config/fish
echo >> /home/ubuntu/.config/fish/config.fish
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)"' >> ~/.config/fish/config.fish
source ~/.config/fish/config.fish
```

### 5/7. Everything the developer needs ⏱️ `3-6mins`

Install dependency managers:

```fish
brew install gcc mise asdf
echo 'mise activate fish | source' >> ~/.config/fish/config.fish
echo 'fish_add_path ~/.asdf/shims' >> ~/.config/fish/config.fish
source ~/.config/fish/config.fish
```

Install development tooling:

```fish
mise use -g direnv
echo 'direnv hook fish | source' >> ~/.config/fish/config.fish

mise use -g neovim@0.11
mise use -g just
mise use -g ripgrep
mise use -g tree-sitter

mise use -g zoxide
echo 'zoxide init fish | source' >> ~/.config/fish/config.fish

brew install claude-code
mkdir -p ~/.claude
mise use -g rtk
```

Configure Claude Code with RTK for more efficient token usage:

```fish
rtk init -g
```

NvChad config and plugin bootstrap:

```fish
git clone https://github.com/NvChad/starter ~/.config/nvim
nvim --headless "+Lazy! sync" +qa
```

Start with a great starship prompt:

```fish
echo 'format = "[|> changelog](#59B287 bold) $directory$cmd_duration$character"

[container]
disabled = true

[directory]
format = "[$path](bright-white)"

[character]
success_symbol = "[ <|](green bold)"
error_symbol = "[ <|](red bold)"

[cmd_duration]
min_time = 1000
format = " [$duration](white)"' > ~/.config/starship.toml
```

Shell prompt with git status and command timing:

```fish
mise use -g starship
echo 'starship init fish | source' >> ~/.config/fish/config.fish
```

Configure shell abbreviations:

```fish
echo 'abbr -a a apt
abbr -a b brew
abbr -a c claude --model \'claude-opus-4-6[1m]\' --effort high --dangerously-skip-permissions --remote-control $(hostname)
abbr -a d dagger
abbr -a f flyctl
abbr -a j just
abbr -a mx mix
abbr -a mp mix phx.server
abbr -a mt mix test
abbr -a mc mix compile
abbr -a n nvim
abbr -a p psql' > ~/.config/fish/conf.d/abbreviations.fish

source ~/.config/fish/conf.d/abbreviations.fish
```

> [!NOTE]
> The `--dangerously-skip-permissions` flag is safe here because all changes
> are limited to the VM. If the changes are wrong, stop the VM and launch a
> fresh one from the same image, just like "Bring yourself back
> online."

Shell completions and SSH agent:

```fish
brew completions link
mkdir -p ~/.config/fish/completions
starship completions fish > ~/.config/fish/completions/starship.fish
just --completions fish > ~/.config/fish/completions/just.fish

echo 'if not set -q SSH_AUTH_SOCK
  eval (ssh-agent -c) > /dev/null
end' >> ~/.config/fish/config.fish
```

### 6/7. Everything changelog needs ⏱️ `6-12mins`

```fish
cd /truth

echo "First run installs it"
direnv allow 
echo "Second run actually allows"
direnv allow

just install
```

> [!TIP]
> There are so many valuable insights in
> [transcripts](https://github.com/thechangelog/transcripts). They were so
> helpful when building this, that I actually ended up embedding them in my VM
> changelog base image via `sudo cp -r /truth/tmp/transcripts /transcripts`. Yes, I
> already had the [transcripts](https://github.com/thechangelog/transcripts)
> repo checked out in my local `changelog.com` repo instance, as
> `tmp/transcripts`.

Exit out of the VM, then remove the truth mount:

```bash
incus config device remove changelog truth
```

### 7/7. Freeze it, reuse it ⏱️ `4-5mins`

```bash
incus exec changelog -- su -c 'builtin history clear; rm -f ~/.local/share/fish/fish_history' - ubuntu
incus stop changelog
incus publish changelog --alias changelog --reuse
incus delete changelog
```

Verify:

```bash
incus image list
+-----------+--------------+--------+-------------------------------------+--------------+-----------------+------------+----------------------+
|   ALIAS   | FINGERPRINT  | PUBLIC |             DESCRIPTION             | ARCHITECTURE |      TYPE       |    SIZE    |     UPLOAD DATE      |
+-----------+--------------+--------+-------------------------------------+--------------+-----------------+------------+----------------------+
| changelog | 30117e98fa65 | no     | Ubuntu noble amd64 (20260509_07:42) | x86_64       | VIRTUAL-MACHINE | 2631.97MiB | 2026/05/10 19:44 BST |
+-----------+--------------+--------+-------------------------------------+--------------+-----------------+------------+----------------------+
|           | f57c0edc5b4f | no     | Ubuntu noble amd64 (20260509_07:42) | x86_64       | VIRTUAL-MACHINE | 297.29MiB  | 2026/05/09 17:34 BST |
+-----------+--------------+--------+-------------------------------------+--------------+-----------------+------------+----------------------+
```

## Update the base VM image

To update the base VM image in a follow-up session:

```bash
incus launch changelog changelog --vm \
  -p macvlan \
  -c limits.cpu=8 \
  -c limits.memory=16GiB \
  -d root,size=100GiB
until incus exec changelog -- true 2>/dev/null; do sleep 1; done
incus exec changelog -- su - ubuntu
```

Make changes, then:

```bash
incus exec changelog -- su -c 'builtin history clear; rm -f ~/.local/share/fish/fish_history' - ubuntu
incus stop changelog
incus publish changelog --alias changelog --reuse
incus delete changelog
```

## A new development session

Everything above was setup; done once. This is what happens every time. Two
minutes from cold start to Claude running in a fresh environment.

```bash
incus launch changelog changelog-vibe --vm \
  -p macvlan \
  -c limits.cpu=8 \
  -c limits.memory=16GiB \
  -d root,size=100GiB
until incus exec changelog-vibe -- true 2>/dev/null; do sleep 1; done
incus config device add changelog-vibe truth disk \
  source=$HOME/github.com/thechangelog/changelog.com \
  path=/truth
incus exec changelog-vibe -- su - ubuntu
```

Let's create a copy of the `/truth` mount so that `claude` can make all the
necessary changes on its copy, not the host version of `changelog.com`:

```fish
cp -r /truth ~/workspace
cd ~/workspace
```

Now fire up `claude` - there is a `c<SPACE>` shell abbreviation that has
all the right details in place:

```console
 ┌──────────────────────────────────────────────────────────────────────────
⣿│ ● ● ●                            
⣿│                                   
⣿│  |> changelog ~ <| claude --model claude-opus-4-6[1m] --effort high --dangerously-skip-permissions --remote-control changelog █              
⣿│                                   
⣿│                                   
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
```

> [!TIP]
> Use e.g. `tmux new -s vibing` to create a named tmux session in case you need
> to leave `claude` running while you are not connected to the VM. As an
> alternative, you can run `tmux` on the host where `incus` runs, and then just
> open VMs in different sessions / tabs.

> [!TIP]
> Running `just contribute` alongside `claude` is probably a good idea. There
> are a few other alternatives, run `just` to see what they are. Also, if you
> want to access the app instance on the LAN, you will want to prepend
> `HOST=<LAN-IP>` to the command, and then open `http://<LAN-IP>:4000` in your
> browser.

### Save changes back to truth

As `claude` iterates, it will reach different points that are good and we want
to keep:

```fish
just keep
```

This rsyncs `~/workspace` back to `/truth` (the host mount), excluding build
artifacts, deps, and other generated directories. Run it whenever you reach a
good checkpoint. Changes land on the host filesystem, so they survive VM
deletion.

### Stop session & cleanup

When you're done, exit the VM and clean up:

```bash
incus stop changelog-vibe
incus delete changelog-vibe
```

The changes you kept via `just keep` are safe on the host, go ahead and commit
them. The VM is disposable.

## What comes next

The agents have a workspace, a rhythm, and a safe way to fail. What they don't
have yet is eyes on production and ears on the community:

- Sentry CLI for addressing exceptions (small scale)
- Honeycomb CLI for exploring and addressing user-facing issues (large scale)
- gh CLI for interacting with issues, loading PR data, etc.
- Zulip CLI for learning what the users are asking for

The blueprint improves every time it's used. That's the [Kaizen
spirit](https://changelog.com/topic/kaizen).

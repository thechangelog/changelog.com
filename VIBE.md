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
> The image is always called `changelog`. Instance names are derived from the
> source path: `basename` with `.` & `_` replaced by `-`, e.g. `changelog-com`.

### 1/6. A VM manager that stays out of the way ⏱️ `2-3mins`

The Ubuntu 24.04 (and also 26.04) apt repo only has Incus 6.x LTS, and the
default Incus setup NATs VMs behind a bridge. One task makes both choices
right:

```bash
mise vm:incus enp97s0
```

It installs the latest stable Incus from the
[Zabbly repo](https://github.com/zabbly/incus), adds your user to the
`incus-admin` group so Incus commands work without `sudo` (log out, back in,
and re-run the task if it tells you to), initializes Incus with a minimal
config — a `dir` storage pool at `/var/lib/incus/storage-pools/default/`, no
NAT bridge — and creates a `macvlan` profile on the physical network
interface, so every VM gets its own IP directly from the LAN via DHCP.

> [!NOTE]
> In the command above, `enp97s0` is the physical network interface on Genesis.
> Replace this with your host's interface (check with `ip link`).

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

> [!TIP]
> If you have ZFS available, use it instead of the default `dir` pool for much
> faster `incus publish` times. The `dir` backend reads and compresses the entire
> virtual disk (even empty space), while ZFS only processes allocated blocks and
> compresses with lz4 at near memory bandwidth speed:
>
> ```bash
> sudo zfs create <your-pool>/incus
> incus storage create zfs zfs source=<your-pool>/incus
> incus profile device set macvlan root pool=zfs
> ```

### 2/6. Boot with truth mounted ⏱️ `1-2mins`

```bash
mise vm:image
```

Every VM is disposable, but the code isn't. The host's project directory is
mounted into the VM at the same path it has on the host, with a stable
`/host/repo` symlink pointing at it — a single source of truth that outlives
every boot-work-keep-destroy cycle. Path-mirroring means file paths mean the
same thing on the host and in the VM; `/host/repo` means the tooling never
needs to know what that path is.

> [!NOTE]
> If the project is a linked `git worktree`, the main repo's `.git` directory
> is also mounted — read-only. `git status/log/diff` work inside the VM, but
> nothing in the VM can touch the host's objects, refs, or hooks. Commits
> happen on the host, after `mise vm:keep`.

### 3/6. Everything the system needs ⏱️ `2-4mins`

```bash
sudo apt install -y build-essential curl dnsutils fish git htop btop inotify-tools libicu-dev libncurses-dev libreadline-dev libssl-dev rsync tmux unzip
sudo chsh -s /usr/bin/fish ubuntu
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
curl -fsSL https://get.docker.com | sudo bash
sudo usermod -aG docker ubuntu
```

Remove system gnupg to avoid version conflicts with brew's gpg (system 2.4.4
daemons launched via systemd socket activation are incompatible with brew's
2.5.20 client, causing `mise install` GPG verification to fail):

```bash
sudo systemctl --user disable --now gpg-agent.socket gpg-agent-ssh.socket gpg-agent-extra.socket gpg-agent-browser.socket dirmngr.socket 2>/dev/null || true
sudo apt remove -y gnupg gnupg-utils gpg gpg-agent gpgsm dirmngr keyboxd gpg-wks-client
sudo apt autoremove -y
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

### 4/6. Everything the developer needs ⏱️ `3-6mins`

Install dependency managers & `tig`:

```fish
brew install gcc mise tig
echo 'mise activate fish | source' >> ~/.config/fish/config.fish
source ~/.config/fish/config.fish
```

Install development tooling:

```fish
mise use -g neovim@0.11
mise use -g dust
mise use -g fd
mise use -g ripgrep
mise use -g tree-sitter

mise use -g zoxide
echo 'zoxide init fish | source' >> ~/.config/fish/config.fish

mise use -g claude
echo 'set -gx DISABLE_AUTOUPDATER 1' >> ~/.config/fish/config.fish
echo 'set -gx CLAUDE_CODE_ENABLE_AUTO_MODE 1' >> ~/.config/fish/config.fish
mkdir -p ~/.claude
mise use -g rtk
echo 'set -gx RTK_TELEMETRY_DISABLED 1' >> ~/.config/fish/config.fish # Blocks telemetry regardless of consent
```

Configure Claude Code with RTK for more efficient token usage:

```fish
rtk init -g
```

Check how much RTK is saving at any point with `rtk gain`. It transparently
rewrites read-heavy commands (`grep`, `read`, `git show/log/diff`, `ls`) so
Claude spends fewer tokens on the same output. On this host:

```console
$ rtk gain
RTK Token Savings (Global Scope)
════════════════════════════════════════════════════════════

Total commands:    435
Input tokens:      1.2M
Output tokens:     720.7K
Tokens saved:      475.5K (39.8%)
Total exec time:   33.6s (avg 77ms)
Efficiency meter: ██████████░░░░░░░░░░░░░░ 39.8%

By Command
────────────────────────────────────────────────────────────────────────
  #  Command                   Count   Saved    Avg%    Time  Impact
────────────────────────────────────────────────────────────────────────
 1.  rtk grep                    104  241.2K   13.3%     2ms  ██████████
 2.  rtk read                     51  183.5K    7.1%     1ms  ████████░░
 3.  rtk git show 5aad8e85         1   26.3K   83.8%    31ms  █░░░░░░░░░
 ...
```

Nearly 40% fewer tokens across 435 commands — the bulk from `grep` and `read`,
exactly the operations an agent runs most while exploring a codebase.

LazyVim config and plugin bootstrap:

```fish
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
sed -i '/import = "lazyvim.plugins"/a\    { import = "lazyvim.plugins.extras.lang.elixir" },' \
    ~/.config/nvim/lua/config/lazy.lua
echo 'return {
  { "LazyVim/LazyVim", opts = { colorscheme = "retrobox" } },
}' > ~/.config/nvim/lua/plugins/colorscheme.lua
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
abbr -a c claude --dangerously-skip-permissions
abbr -a cr claude --dangerously-skip-permissions --remote-control $(hostname)_$(date +%Y-%m-%d_%H-%M)
abbr -a d docker
abbr -a f flyctl
abbr -a g git
abbr -a m mise
abbr -a mx mix
abbr -a n nvim
abbr -a p psql
abbr -a t tig' > ~/.config/fish/conf.d/abbreviations.fish

source ~/.config/fish/conf.d/abbreviations.fish
```

> [!NOTE]
> The `--dangerously-skip-permissions` flag is safe here because all changes
> are limited to the VM. If the changes are wrong, stop the VM and launch a
> fresh one from the same image, just like "Bring yourself back
> online."

Wider tmux session names (default truncates at 10 characters):

```fish
echo 'set -g status-left-length 22' > ~/.tmux.conf
```

Shell completions and SSH agent:

```fish
brew completions link
mkdir -p ~/.config/fish/completions
starship completions fish > ~/.config/fish/completions/starship.fish
mise use -g usage
mise completions fish > ~/.config/fish/completions/mise.fish

echo 'if not set -q SSH_AUTH_SOCK
  eval (ssh-agent -c) > /dev/null
end' >> ~/.config/fish/config.fish
```

Fish functions for the VM lifecycle:

```fish
function workspace
    if not test -d ~/workspace
        echo "Copying /host/repo → ~/workspace..."
        cp -a (realpath /host/repo) ~/workspace
        echo "Done."
    end
    cd ~/workspace
end
funcsave workspace

function clean
    test -d ~/workspace && cd ~/workspace && mise vm:keep
    rm -rf ~/.claude/backups ~/.claude/cache ~/.claude/file-history ~/.claude/history.jsonl ~/.claude/mcp-needs-auth-cache.json
    rm -rf ~/.claude/plans ~/.claude/session-env ~/.claude/sessions ~/.claude/shell-snapshots
    rm -f ~/.docker/config.json
    rm -rf ~/.fly
    rm -rf ~/workspace
    builtin history clear
    rm -f ~/.local/share/fish/fish_history
    rm -f ~/.bash_history
    brew autoremove
    brew cleanup --prune=all
    docker system prune --all --force
end
funcsave clean

function work
    workspace
    set -l ts (date +%Y-%m-%d_%H-%M)
    set -l cmd "claude --dangerously-skip-permissions"
    echo "Starting tmux session $ts..."
    tmux new-session -s $ts -n claude "$cmd $argv"
end
funcsave work

function workr
    work --remote-control (hostname)_(date +%Y-%m-%d_%H-%M)
end
funcsave workr

function update
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y

    brew update
    brew upgrade
    brew autoremove
    brew cleanup --prune=all

    mise up
    mise prune
end
funcsave update
```

`workspace` copies `/host/repo` into `~/workspace` on first use so `claude` works
on its own copy, not the host mount. `clean` wipes all session state first —
Claude sessions, shell history, the workspace copy — then reclaims space
(`brew autoremove`, `brew cleanup --prune=all`, `docker system prune`). The wipe
runs before the heavy reclaim steps on purpose: if a prune is killed (OOM under
load), no stale history or sessions leak into the published snapshot. `work` ties them
together: set up the workspace, start a named tmux session, and launch Claude
inside it — one command from SSH to vibing. `workr` does the same but adds
`--remote-control` so you can drive the session from another client. `update`
refreshes everything in one shot: apt (`update`/`upgrade`/`autoremove`), brew
(`update`/`upgrade`/`autoremove`/`cleanup --prune=all`), and mise (`up`/`prune`).
Run it from the project (`/host/repo` or `~/workspace`) so `mise prune` sees the
right configs and doesn't offer to remove the project toolchain.

Land new shells in the workspace whenever one exists:

```fish
echo 'test -d ~/workspace && cd ~/workspace' >> ~/.config/fish/config.fish
```

### 5/6. Everything changelog needs ⏱️ `6-12mins`

```fish
cd /host/repo
mise install
```

Sign in to 1Password (one-time setup, then per-session):

```fish
# One-time: add your account
op account add
# Enter: changelog.1password.com, your email, secret key, password

# Per-session: sign in
eval (op signin)
```

Enable fnox-env so secrets load automatically from 1Password:

```fish
mise team:secrets:load
```

This loads shared secrets from the changelog vault and personal secrets
(like `NEON_API_KEY`) from the Employee vault. See
[CONTRIBUTING.md](CONTRIBUTING.md#how-do-i-configure-secrets-team-members-only)
for details.

> [!TIP]
> There are so many valuable insights in
> [transcripts](https://github.com/thechangelog/transcripts). They were so
> helpful when building this, that I actually ended up embedding them in my VM
> changelog base image via `sudo cp -r /host/repo/tmp/transcripts /transcripts`. Yes, I
> already had the [transcripts](https://github.com/thechangelog/transcripts)
> repo checked out in my local `changelog.com` repo instance, as
> `tmp/transcripts`.

### 6/6. Freeze it, reuse it ⏱️ `4-5mins`

```bash
mise vm:blueprint
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
mise vm:launch
```

Make changes, then freeze:

```bash
mise vm:blueprint
```

## A new development session

Everything above was setup; done once. This is what happens every time. Two
minutes from cold start to Claude running in a fresh environment.

```bash
mise vm:launch
```

Re-running it re-enters the same VM (starting it first if stopped), so
sessions are resumable until you destroy them. It refuses to resume a VM whose
mounted source is a different path — two projects with the same `basename`
can't silently land in each other's VM.

Now type `work` — it sets up `~/workspace`, starts a timestamped tmux session
and launches `claude` inside it, so sessions survive disconnects: detach with
`Ctrl-b d`, come back with `tmux attach`. `workr` does the same with remote
control.

To run `claude` directly, without tmux, there is a `c<SPACE>` shell
abbreviation for local sessions and `cr<SPACE>` for remote-control sessions:

```console
 ┌───────────────────────────────────────────────────────────
⣿│ ● ● ●                            
⣿│                                   
⣿│  |> changelog ~ <| claude --dangerously-skip-permissions █
⣿│                                   
⣿│                                   
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
```

> [!TIP]
> As an alternative to tmux inside the VM, you can run `tmux` on the host where
> `incus` runs, and then just open VMs in different sessions / tabs.

> [!TIP]
> Running `mise contribute` alongside `claude` is probably a good idea. There
> are a few other alternatives, run `mise tasks` to see what they are. On Linux,
> `mise dev` automatically sets `HOST` to the LAN IP so the app is accessible
> from other machines — open `http://<LAN-IP>:4000` in your browser.

### Keep the good changes

As `claude` iterates, it will reach different points that are good and we want
to keep:

```fish
mise vm:keep
```

This rsyncs `~/workspace` back to `/host/repo` (the host mount), excluding build
artifacts and generated directories via `.gitignore` filters. Run it whenever
you reach a good checkpoint. Changes land on the host filesystem, so they
survive VM deletion.

> [!NOTE]
> `vm:keep` refuses to run unless the destination is the real host mount
> (a `virtiofs`/`9p` filesystem). If `/host/repo` were a plain directory — a
> stale VM, a missing symlink — rsync would happily fill it and the changes
> would look kept but vanish on destroy. Better a loud error than silent loss.

### Stop session & cleanup

When you're done, exit the VM and clean up. On the host, from the same project
directory you launched from:

```bash
mise vm:destroy $PWD
```

It derives the VM name from the path (`changelog-com`), stops it, and deletes
it.

The changes you kept via `mise vm:keep` are safe on the host, go ahead and
commit them. The VM is disposable.

## What comes next

The agents have a workspace, a rhythm, and a safe way to fail. What they don't
have yet is eyes on production and ears on the community:

- Sentry CLI for addressing exceptions (small scale)
- Honeycomb CLI for exploring and addressing user-facing issues (large scale)
- Zulip CLI for learning what the users are asking for

The blueprint improves every time it's used. That's the [Kaizen
spirit](https://changelog.com/topic/kaizen).

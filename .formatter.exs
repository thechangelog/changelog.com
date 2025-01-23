[
  import_deps: [:ecto, :phoenix],
  inputs: ["*.{eex,heex,ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{eex,heex,ex,exs}"],
  subdirectories: ["priv/*/migrations"]
]

# required env variables:
# - PROXY_ADDR

# myrc
set -gx MYRC_PATH "$HOME/myrc"

# load dotenv file through bash
function load_dotenv --argument-names file
  test -f "$file"; or return 0
  command -q bash; or begin; echo "dotenv: bash not found, skip $file" >&2; return 0; end
  command bash -c '
    declare -A old
    while IFS= read -r -d "" kv; do old["${kv%%=*}"]=${kv#*=}; done < <(env -0)
    set -a; . "$1"; set +a
    while IFS= read -r -d "" kv; do
      n=${kv%%=*}; v=${kv#*=}
      [ "${old[$n]+x}" ] && [ "${old[$n]}" = "$v" ] && continue
      printf "%s=%s\0" "$n" "$v"
    done < <(env -0)
  ' bash "$file" | while read -z -l entry
    set -l kv (string split -m1 = -- $entry)
    set -gx "$kv[1]" "$kv[2]"
  end
end

# load .env
load_dotenv "$MYRC_PATH/.env"

# aliases
alias cl="clear"
alias zj="zellij"

# nodejs
set -gx NODE_OPTIONS "--max_old_space_size=8192"
set -gx COREPACK_NPM_REGISTRY "https://registry.npmmirror.com"

# editor
set -gx EDITOR "nvim"

# pager
set -gx PAGER "most"

# podman
set -gx DOCKER_HOST "unix:///run/user/1000/podman/podman.sock"
alias pm="podman"
alias pmc="podman compose"
alias docker="podman"

# enable proxy
function pxyon
  if test -n "$PROXY_ADDR"
    set -gx https_proxy "http://$PROXY_ADDR"
    set -gx http_proxy "http://$PROXY_ADDR"
    set -gx all_proxy "socks5://$PROXY_ADDR"
  else
    echo "Error: PROXY_ADDR is not set." >&2
    return 1
  end
end

# disable proxy
function pxyoff
  set -e https_proxy
  set -e http_proxy
  set -e all_proxy
end

# show proxy
function pxyshow
  echo "https_proxy=\"$https_proxy\""
  echo "http_proxy=\"$http_proxy\""
  echo "all_proxy=\"$all_proxy\""
end

# convert git remote url to https repo url
function repourl
  set remote_url (git remote get-url origin)
  if test -n "$remote_url"
    if string match -q "git@*" "$remote_url"
      set repo_url (echo $remote_url | sed -e 's/\.git$//' -e 's/:/\//' -e 's/git@/https:\/\//')
    else
      set repo_url (echo $remote_url | sed -e 's/\.git$//')
    end
    echo $repo_url
  else
    echo "Error: Unable to get remote url." >&2
    return 1
  end
end

# create PR for current directory's git repository
function mkpr
  set repo_url (repourl)
  if test -n "$repo_url"
    set compare_url "$repo_url/compare/$argv[1]...$(git branch --show-current)"
    echo "compare_url: $compare_url"
    $BROWSER $compare_url
  else
    echo "Error: Unable to get repo url." >&2
    return 1
  end
end

# open current directory's git repository in browser
function repo
  set repo_url (repourl)
  if test -n "$repo_url"
    $BROWSER $repo_url
  else
    echo "Error: Unable to get repo url." >&2
    return 1
  end
end

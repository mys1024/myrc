# required env variables:
# - PROXY_ADDR

# load .env
if [ -f .env ]; then
  source .env
fi

# aliases
alias cl="clear"

# Node.js
export NODE_OPTIONS="--max_old_space_size=8192"
export COREPACK_NPM_REGISTRY="https://registry.npmmirror.com"

# Podman
export DOCKER_HOST="unix:///run/user/1000/podman/podman.sock"
alias pm="podman"
alias pmc="podman compose"
alias docker="podman"

# enable proxy
function pxyon() {
  if [ -n "$PROXY_ADDR" ]; then
    export https_proxy="http://${PROXY_ADDR}"
    export http_proxy="http://${PROXY_ADDR}"
    export all_proxy="socks5://${PROXY_ADDR}"
  else
    echo "Error: PROXY_ADDR is not set."
  fi
}

# disable proxy
function pxyoff() {
  unset https_proxy
  unset http_proxy
  unset all_proxy
}

# show proxy
function pxyshow() {
  echo "https_proxy: ${https_proxy}"
  echo "http_proxy: ${http_proxy}"
  echo "all_proxy: ${all_proxy}"
}

# convert git remote url to https repo url
function repourl() {
  remote_url=$(git remote get-url origin)
  if [ -n $remote_url ]; then
    if [[ $remote_url == git@* ]]; then
      repo_url=$(echo $remote_url | sed -e -e 's/\.git$//' 's/:/\//' -e 's/git@/https:\/\//')
    else
      repo_url=$(echo $remote_url | sed -e 's/\.git$//')
    fi
    echo $repo_url
  else
    echo "Error: Unable to get remote url."
  fi
}

# create PR for current directory's git repository
function mkpr() {
  repo_url=$(repourl)
  if [ -n "$repo_url" ]; then
    compare_url="${repo_url}/compare/${1}...$(git branch --show-current)"
    echo "compare_url: ${compare_url}"
    $BROWSER $compare_url
  else
    echo "Error: Unable to get repo url."
  fi
}

# open current directory's git repository in browser
function repo() {
  repo_url=$(repourl)
  if [ -n "$repo_url" ]; then
    $BROWSER $repo_url
  else
    echo "Error: Unable to get repo url."
  fi
}

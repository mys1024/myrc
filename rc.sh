# required env variables:
# - PROXY_ADDR

# load .env
source .env

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
  export https_proxy="http://${PROXY_ADDR}"
  export http_proxy="http://${PROXY_ADDR}"
  export all_proxy="socks5://${PROXY_ADDR}"
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

# alias for clear
alias cl="clear"

# create PR for current directory's git repository
function mkpr() {
  remote_url=$(git remote get-url origin)
  repo_url=$(echo $remote_url | sed -e 's/:/\//' -e 's/git@/https:\/\//' -e 's/\.git$//')
  compare_url="${repo_url}/compare/${1}...$(git branch --show-current)"
  echo "remote_url: ${remote_url}"
  echo "compare_url: ${compare_url}"
  $BROWSER $compare_url
}

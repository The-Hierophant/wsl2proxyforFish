# !/usr/bin/fish

##########################################
# Copyrights 2020, Wizcas <chen@0x1c.dev>
# Copyrights 2022, The-Hierophant
# This script is under MIT license
##########################################

#----------- 辅助工具 -----------
####### 颜色码 ########
set RED "\033[31m"     # Error message
set GREEN "\033[32m"   # Success message
set YELLOW "\033[33m"  # Warning message
set BLUE "\033[34m"    # Info message
set MAGENTA "\033[35m" # Info message
set TEAL "\033[36m"    # Info message
set RAW "\033[0m"

# function colorEcho
#   echo -e "{$(1)}{$(@:2)}{$(RAW)}" 1>&2
# end
##########################

# 一些预定义常量
set VERSION '0.2.0'
set conf "$HOME/.wsl2proxyfish.conf"
set socks "$HOME/socksproxy"
set varsfile "$HOME/wsl2proxy.vars"
set cmd "wsl2proxy"

# 从WSL的DNS配置中解析当前Windows主机的访问IP，因为每次重启都会变
set host (cat /etc/resolv.conf | sed -n 's/^nameserver\W\(.*\)$/\1/p')

# Load proxy settings from our config file. Throws an error message if not found.
function loadConf
  if [ ! -f "$conf" ]
    # echo "未找到配置文件$conf"
    echo -e "未找到配置文件$TEAL$conf$RED，请首先执行"$YELLOW"setup"$RED"命令。"
    exit 1
  end
  . "$conf"
  set -g url "$protocol://$host:$port"
  # echo $url
end

# The `on` command's handler
function on
  loadConf
  echo -e "正在配置代理服务器"$YELLOW""$url""$RAW""
  set -U http_proxy $url
  set -U https_proxy $url
  applyGit $url
  # updateSocksProxy
end

# Set the proxy settings for git
function applyGit
  # For HTTP/HTTPS protocol
  # echo $argv
  git config --global http.proxy $argv
  # For git:// protocol
  # git config --global core.gitproxy {$(socks)}
  echo "✔️️ git设置完毕"
end

# Unset all proxy settings
function off
  set -U http_proxy
  set -U https_proxy
  echo "👋🏻️ 已删除系统变量"
  git config --global --unset http.proxy
  git config --global --unset core.gitproxy
  echo "👋🏻️ 已删除git配置"
  echo -e $RED "
如果不再使用代理服务器，别忘了:
$RAW
1.  删除或注释掉$YELLOW$getProfile$RAW 中wsl2proxy 相关的部分
2.  删除或注释掉$YELLOW~/.ssh/config$RAW 中的代理设置
"
end

# Print the help info
function help
  echo -e "
WSL代理服务器配置工具


本工具自动检测WSL的Windows主机地址，并使用自定义的代理信息为
HTTP，HTTPS和Git添加代理配置。

Usage:
  "$cmd" <COMMAND>

Commands:

  on       开启代理设置，只有使用setup正常配置后才能生效。
           执行方式："$TEAL". "$cmd" on"$RAW"
  off      关闭代理设置。
           执行方式："$TEAL". "$cmd" off"$RAW"
  url      打印当前的代理服务器地址
  help     显示本帮助信息
"
end

switch $argv
  case on
    on
  case off
    off
  case help
    off
end


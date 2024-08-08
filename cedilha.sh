#!/bin/bash
# This fixes the cedilha/cedilla in Ubuntu 14.04 and over if you are using
# English (US, alternative international) keyboard. Let me know if this 
# works for you if you are using another version or keyboard layout.
# This script is based on the following bugtrack:
# https://bugs.launchpad.net/ubuntu/+source/ibus/+bug/518056/comments/39

set -euxo pipefail

# root privileges verification
if [ "$EUID" -ne 0 ]; then
  echo "This script requires root privileges."
  echo "Try: sudo $0"
  exit 1
fi

# Using /etc/os-release rather than lsb_release because it will support
# distributions derived from Ubuntu, such as LinuxMint.
# lsb_release does not display this kind of information.
# See: https://www.freedesktop.org/software/systemd/man/os-release.html
#
# HINT: A list of /etc/os-releases can be found here:
# https://gitlab.com/zygoon/os-release-zoo
#
# TODO: Test against Debian itself. I think it might work.
if [ -f /etc/os-release ]; then
   tested_os_name=ubuntu
   tested_os_version=(14.04 16.04 18.04 20.04 22.04 24.04)
   tested_ubuntu_codenames=(xenial bionic focal jammy noble)
   source /etc/os-release
   # TODO: We should be evaluating $UBUNTU_CODENAME rather than VERSION_ID. This
   # approach would make our script work with Ubuntu and its variations with
   # less 'if' statements. We could even remove 'tested_os_name' and 'os_name'.
   #
   # Unfortunately, this was introduced in 2016, and it is not merged back into
   # 14.04/Trusty Tar. Maybe in April 2019, when it reaches its own EOL, we could
   # use it. More info: https://github.com/systemd/systemd/issues/3429
   if [ -z $UBUNTU_CODENAME ]; then
      os_name=$ID
      os_version=$VERSION_ID
   else
      # Wen can assume it will work since it has the same Ubuntu codename.
      # Otherwise, we should expand $tested_os_name to other Ubuntu variants.
      os_name=ubuntu
      os_version=$UBUNTU_CODENAME
   fi
else
   # Although Ubuntu 12.04 had this file, I'm keeping this older version in case somebody needs it.
   tested_os_name=Ubuntu
   tested_os_version=(16.04 14.04)
   os_name=$(lsb_release -is)
   os_version=$(lsb_release -rs)
fi

echo $os_name $os_version

# os name and version verification
if [ "${os_name}" != "${tested_os_name}" ] && [[ -n "${tested_os_version[$os_version]}" ]]; then
   echo "This script has only been tested with $tested_os_name $tested_os_version and you are on $os_name $os_version. Aborting."
   exit 1
fi

# change GTK configuration (32 or 64 bits)
architecture=$(uname -m)
if [ "${architecture}" == "x86_64" ]; then
   sed -i.bak 's#"cedilla" "Cedilla" "gtk30" "/usr/share/locale" "az:ca:co:fr:gv:oc:pt:sq:tr:wa"#"cedilla" "Cedilla" "gtk30" "/usr/share/locale" "az:ca:co:fr:gv:oc:pt:sq:tr:wa:en"#g' /usr/lib/x86_64-linux-gnu/gtk-3.0/3.0.0/immodules.cache
   sed -i.bak 's#"cedilla" "Cedilla" "gtk20" "/usr/share/locale" "az:ca:co:fr:gv:oc:pt:sq:tr:wa"#"cedilla" "Cedilla" "gtk20" "/usr/share/locale" "az:ca:co:fr:gv:oc:pt:sq:tr:wa:en"#g' /usr/lib/x86_64-linux-gnu/gtk-2.0/2.10.0/immodules.cache
else
   sed -i.bak 's#"cedilla" "Cedilla" "gtk20" "/usr/share/locale" "az:ca:co:fr:gv:oc:pt:sq:tr:wa"#"cedilla" "Cedilla" "gtk20" "/usr/share/locale" "az:ca:co:fr:gv:oc:pt:sq:tr:wa:en"#g' /usr/lib/i386-linux-gnu/gtk-2.0/2.10.0/immodules.cache
fi

# replaces ć for ç /usr/share/X11/locale/en_US.UTF-8/Compose
sed -i.bak 's/ć/ç/g' /usr/share/X11/locale/en_US.UTF-8/Compose

# append the first parameter to /etc/environment if is not there
append_to_env() {
   str_to_add=$1
   where_to_add=/etc/environment
   if grep --quiet --invert-match $str_to_add $where_to_add; then
      echo $str_to_add >> $where_to_add
   fi
}

append_to_env GTK_IM_MODULE=cedilla
append_to_env QT_IM_MODULE=cedilla

echo "Restart your computer and try ç."

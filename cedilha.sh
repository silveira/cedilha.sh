#!/bin/bash
# This fixes the cedilha/cedilla in Ubuntu 16.04 if you are using English (US, alternative international) keyboard. If you are using other version or keyboard layout let me know if this worked for you.
# This script is based on https://bugs.launchpad.net/ubuntu/+source/ibus/+bug/518056/comments/39

os_name=$(lsb_release -is)
os_version=$(lsb_release -rs)
tested_os_name=Ubuntu
tested_os_version=16.04

# os name and version verification
if [ "${os_name}" != "${tested_os_name}" ] || [ "${os_version}" != "${tested_os_version}" ]; then
	echo "This script has only been tested with $tested_os_name $tested_os_version and you are on $os_name $os_version. Aborting."
	exit 1
fi

# root privileges verification
if [ "$EUID" -ne 0 ]
  then echo "This script requires root privileges."
  exit 1
fi

# change gtk configuration (32 or 64 bits)
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

append_to_env PATH
append_to_env GTK_IM_MODULE=cedilla

echo "Restart your computer and try ç	."



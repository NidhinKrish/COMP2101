#!/bin/bash
# this script displays system information

# TASK: This script produces a report. It does not communicate errors or deal with the user pressing ^C
#       Create the 4 functions described in the comments for
#         help display
#         error message display (2 of these)
#         temporary files cleanup to be used with interrupts
#       Create a trap command to attach your interrupt handling function to the signal that will be received if the user presses ^C while the script is running

# Start of section to be done for TASK
# This is where your changes will go for this TASK

# This function will send an error message to stderr
# Usage:
#   error-message ["some text to print to stderr"]
function error-message {
echo "[-]Error -  $1" 2> errors.txt
}
# This function will send a message to stderr and exit with a failure status
# Usage:
#   error-exit ["some text to print to stderr" [exit-status]]
function error-exit {
status=$?
echo "[-]Error - $1 "
echo "Exiting with Exit status $status"
exit
}
#This function displays help information if the user asks for it on the command line or gives us a bad command line
function displayhelp {
cat <<EOF
this is the help section
USAGE :
sysconfig.sh [option]

OPTIONS:
  -h or --help
             display this help Summary
  --memory
             display this machines memories information
  --disk
             display this machines disk usage information
  --printer
             display this machines printer information
  --host
             display host name
  --domain
             display domain name
  --ipconfig
             display this machines IP info and all network interfaces
  --os
             display this machines operating systems name and version
  --cpu
             display this machines hardware information
EOF
}

# This function will remove all the temp files created by the script
# The temp files are all named similarly, "/tmp/somethinginfo.$$"
# A trap command is used after the function definition to specify this function is to be run if we get a ^C while running
function cleanup {
  rm /tmp/sysreport.$$
  rm /tmp/sysinfo.$$
  rm /tmp/businfo.$$
  rm /tmp/memoryinfo.$$
  rm /tmp/cpuinfo.$$
  exit
}
# End of section to be done for TASK
# Remainder of script does not require any modification, but may need to be examined in order to create the functions for TASK

# DO NOT MODIFY ANYTHING BELOW THIS LINE

#This function produces the network configuration for our report
function getipinfo {
  #!/bin/bash
  #
  # this script displays some host identification information for a Linux machine
  #
  # Sample output:
  #   Hostname      : zubu
  #   LAN Address   : 192.168.2.2
  #   LAN Name      : net2-linux
  #   External IP   : 1.2.3.4
  #   External Name : some.name.from.our.isp

  # the LAN info in this script uses a hardcoded interface name of "eno1"
  #    - change eno1 to whatever interface you have and want to gather info about in order to test the script

  # TASK 1: Accept options on the command line for verbose mode and an interface name
  #         If the user includes the option -v on the command line, set the varaible $verbose to contain the string "yes"
  #            e.g. network-config-expanded.sh -v
  #         If the user includes one and only one string on the command line without any option letter in front of it, only show information for that interface
  #            e.g. network-config-expanded.sh ens34
  #         Your script must allow the user to specify both verbose mode and an interface name if they want
  # TASK 2: Dynamically identify the list of interface names veRfor the computer running the script, and use a for loop to generate the report for every interface except loopback

  ################
  # Data Gathering
  ################
  # the first part is run once to get information about the host
  # grep is used to filter ip command output so we don't have extra junk in our output
  # stream editing with sed and awk are used to extract only the data we want displayed

  #####
  # Once per host report
  #####
  if [ $# -lt 2 ]
  then
    case "$1" in
      -v )
  	    echo "verbose mode set to yes"
  	    verbose="yes"
  	    exit
  	    ;;
    esac
     * )
     case "$1" in
     	   echo "interface selected is $*"
     	   ipv4_address=$(ip a s $* |awk -F '[/ ]+' '/inet /{print $3}')
         echo "The Ipv4 Address is $ipv4_address"

    esac
  elif [ $# -gt 1 ]
  then
    case "$1" in
      -v )
  	    echo "verbose mode set to yes"
  	    verbose="yes"
  	    ;;
    esac
    case "$2" in
     ens33 )
     	   echo "interface selected is ens33"
     	   ipv4_address=$(ip a s ens33|awk -F '[/ ]+' '/inet /{print $3}')
         echo "The Ipv4 Address is $ipv4_address"
         exit
   	     ;;
    esac
  fi
  [ "$verbose" = "yes" ] && echo "Gathering host information"
  # we use the hostname command to get our system name
  my_hostname=$(hostname)

  [ "$verbose" = "yes" ] && echo "Identifying default route"
  # the default route can be found in the route table normally
  # the router name is obtained with getent
  default_router_address=$(ip r s default| cut -d ' ' -f 3)
  default_router_name=$(getent hosts $default_router_address|awk '{print $2}')

  [ "$verbose" = "yes" ] && echo "Checking for external IP address and hostname"
  # finding external information relies on curl being installed and relies on live internet connection
  external_address=$(curl -s icanhazip.com)
  external_name=$(getent hosts $external_address | awk '{print $2}')

  verbose="no"
cat <<EOF


  System Identification Summary
  =============================
  Hostname      : $my_hostname
  Default Router: $default_router_address
  Router Name   : $default_router_name
  External IP   : $external_address
  External Name : $external_name
EOF

  #####
  # End of Once per host report
  #####

  #,, the second part of the output generates a per-interface report
  # the task is to change this from something that runs once using a fixed value for the interface name to
  #   a dynamic list obtained by parsing the interface names out of a network info command like "ip"
  #   and using a loop to run this info gathering section for every interface found

  # the default version uses a fixed name and puts it in a variable
  #####
  # Per-interface report
  #####

  # define the interface being summarized
  interface="$1"
  [ "$verbose" = "yes" ] && echo "Reporting on interface(s): $interface"

  [ "$verbose" = "yes" ] && echo "Getting IPV4 address and name for interface $interface"
  # Find an address and hostname for the interface being summarized
  # we are assuming there is only one IPV4 address assigned to this interface
  ipv4_address=$(ip a s $interface|awk -F '[/ ]+' '/inet /{print $3}')
  ipv4_hostname=$(getent hosts $ipv4_address | awk '{print $2}')

  [ "$verbose" = "yes" ] && echo "Getting IPV4 network block info and name for interface $interface"
  # Identify the network number for this interface and its name if it has one
  # Some organizations have enough networks that it makes sense to name them just like how we name hosts
  # To ensure your network numbers have names, add them to your /etc/networks file, one network to a line, as   networkname networknumber
  #   e.g. grep -q mynetworknumber /etc/networks || (echo 'mynetworkname mynetworknumber' |sudo tee -a /etc/networks)
  network_address=$(ip route list dev $interface scope link|cut -d ' ' -f 1)
  network_number=$(cut -d / -f 1 <<<"$network_address")
  network_name=$(getent networks $network_number|awk '{print $1}')

cat<<EOF
  Interface $interface:
  ===============
  Address         : $ipv4_address
  Name            : $ipv4_hostname
  Network Address : $network_address
  Network Name    : $network_name
EOF

}
  # reuse our netid.sh script from lab 4
  #!/bin/bash
#
# this script displays some host identification information for a Linux machine
#
# Sample output:
#   Hostname      : zubu
#   LAN Address   : 192.168.2.2
#   LAN Name      : net2-linux
#   External IP   : 1.2.3.4
#   External Name : some.name.from.our.isp

# the LAN info in this script uses a hardcoded interface name of "eno1"
#    - change eno1 to whatever interface you have and want to gather info about in order to test the script

# TASK 1: Accept options on the command line for verbose mode and an interface name
#         If the user includes the option -v on the command line, set the varaible $verbose to contain the string "yes"
#            e.g. network-config-expanded.sh -v
#         If the user includes one and only one string on the command line without any option letter in front of it, only show information for that interface
#            e.g. network-config-expanded.sh ens34
#         Your script must allow the user to specify both verbose mode and an interface name if they want
# TASK 2: Dynamically identify the list of interface names veRfor the computer running the script, and use a for loop to generate the report for every interface except loopback

################
# Data Gathering
################
# the first part is run once to get information about the host
# grep is used to filter ip command output so we don't have extra junk in our output
# stream editing with sed and awk are used to extract only the data we want displayed

#####
# Once per host report
#####
if [ $# -lt 2 ]
then
  case "$1" in
    -v )
	    echo "verbose mode set to yes"
	    verbose="yes"
	    exit
	    ;;
  esac
  case "$1" in
   ens33 )
   	   echo "interface selected is ens33"
   	   ipv4_address=$(ip a s ens33|awk -F '[/ ]+' '/inet /{print $3}')
       echo "The Ipv4 Address is $ipv4_address"

  esac
elif [ $# -gt 1 ]
then
  case "$1" in
    -v )
	    echo "verbose mode set to yes"
	    verbose="yes"
	    ;;
  esac
  case "$2" in
   ens33 )
   	   echo "interface selected is ens33"
   	   ipv4_address=$(ip a s ens33|awk -F '[/ ]+' '/inet /{print $3}')
       echo "The Ipv4 Address is $ipv4_address"
       exit
 	     ;;
  esac
fi
[ "$verbose" = "yes" ] && echo "Gathering host information"
# we use the hostname command to get our system name
my_hostname=$(hostname)

[ "$verbose" = "yes" ] && echo "Identifying default route"
# the default route can be found in the route table normally
# the router name is obtained with getent
default_router_address=$(ip r s default| cut -d ' ' -f 3)
default_router_name=$(getent hosts $default_router_address|awk '{print $2}')

[ "$verbose" = "yes" ] && echo "Checking for external IP address and hostname"
# finding external information relies on curl being installed and relies on live internet connection
external_address=$(curl -s icanhazip.com)
external_name=$(getent hosts $external_address | awk '{print $2}')

verbose="no"

cat <<EOF


System Identification Summary
=============================
Hostname      : $my_hostname
Default Router: $default_router_address
Router Name   : $default_router_name
External IP   : $external_address
External Name : $external_name

EOF

#####
# End of Once per host report
#####

#,, the second part of the output generates a per-interface report
# the task is to change this from something that runs once using a fixed value for the interface name to
#   a dynamic list obtained by parsing the interface names out of a network info command like "ip"
#   and using a loop to run this info gathering section for every interface found

# the default version uses a fixed name and puts it in a variable
#####
# Per-interface report
#####

# define the interface being summarized
interface="$1"
[ "$verbose" = "yes" ] && echo "Reporting on interface(s): $interface"

[ "$verbose" = "yes" ] && echo "Getting IPV4 address and name for interface $interface"
# Find an address and hostname for the interface being summarized
# we are assuming there is only one IPV4 address assigned to this interface
ipv4_address=$(ip a s $interface|awk -F '[/ ]+' '/inet /{print $3}')
ipv4_hostname=$(getent hosts $ipv4_address | awk '{print $2}')

[ "$verbose" = "yes" ] && echo "Getting IPV4 network block info and name for interface $interface"
# Identify the network number for this interface and its name if it has one
# Some organizations have enough networks that it makes sense to name them just like how we name hosts
# To ensure your network numbers have names, add them to your /etc/networks file, one network to a line, as   networkname networknumber
#   e.g. grep -q mynetworknumber /etc/networks || (echo 'mynetworkname mynetworknumber' |sudo tee -a /etc/networks)
network_address=$(ip route list dev $interface scope link|cut -d ' ' -f 1)
network_number=$(cut -d / -f 1 <<<"$network_address")
network_name=$(getent networks $network_number|awk '{print $1}')

cat <<EOF
Interface $interface:
===============
Address         : $ipv4_address
Name            : $ipv4_hostname
Network Address : $network_address
Network Name    : $network_name

EOF
}

# process command line options
partialreport=
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      displayhelp
      error-exit
      ;;
    --host)
      hostnamewanted=true
      partialreport=true
      ;;
    --domain)
      domainnamewanted=true
      partialreport=true
      ;;
    --ipconfig)
      ipinfowanted=true
      partialreport=true
      ;;
    --os)
      osinfowanted=true
      partialreport=true
      ;;
    --cpu)
      cpuinfowanted=true
      partialreport=true
      ;;
    --memory)
      memoryinfowanted=true
      partialreport=true
      ;;
    --disk)
      diskinfowanted=true
      partialreport=true
      ;;
    --printer)
      printerinfowanted=true
      partialreport=true
      ;;
    *)
      error-exit "$1 is invalid"
      ;;
  esac
  shift
done

# gather data into temporary files to reduce time spent running lshw
sudo lshw -class system >/tmp/sysinfo.$$ 2>/dev/null
sudo lshw -class memory >/tmp/memoryinfo.$$ 2>/dev/null
sudo lshw -class bus >/tmp/businfo.$$ 2>/dev/null
sudo lshw -class cpu >/tmp/cpuinfo.$$ 2>/dev/null

# extract the specific data items into variables
systemproduct=`sed -n '/product:/s/ *product: //p' /tmp/sysinfo.$$`
systemwidth=`sed -n '/width:/s/ *width: //p' /tmp/sysinfo.$$`
systemmotherboard=`sed -n '/product:/s/ *product: //p' /tmp/businfo.$$|head -1`
systembiosvendor=`sed -n '/vendor:/s/ *vendor: //p' /tmp/memoryinfo.$$|head -1`
systembiosversion=`sed -n '/version:/s/ *version: //p' /tmp/memoryinfo.$$|head -1`
systemcpuvendor=`sed -n '/vendor:/s/ *vendor: //p' /tmp/cpuinfo.$$|head -1`
systemcpuproduct=`sed -n '/product:/s/ *product: //p' /tmp/cpuinfo.$$|head -1`
systemcpuspeed=`sed -n '/size:/s/ *size: //p' /tmp/cpuinfo.$$|head -1`
systemcpucores=`sed -n '/configuration:/s/ *configuration:.*cores=//p' /tmp/cpuinfo.$$|head -1`

# gather the remaining data needed
sysname=`hostname`
domainname=`hostname -d`
osname=`sed -n -e '/^NAME=/s/^NAME="\(.*\)"$/\1/p' /etc/os-release`
osversion=`sed -n -e '/^VERSION=/s/^VERSION="\(.*\)"$/\1/p' /etc/os-release`
memoryinfo=`sudo lshw -class memory|sed -e 1,/bank/d -e '/cache/,$d' |egrep 'size|description'|grep -v empty`
ipinfo=`getipinfo`
diskusage=`df -h -t ext4`
printerlist="`lpstat -e`
Default printer: `lpstat -d|cut -d : -f 2`"

# create output

[[ (! "$partialreport" || "$hostnamewanted") && "$sysname" ]] &&
  echo "Hostname:     $sysname" >/tmp/sysreport.$$
[[ (! "$partialreport" || "$domainnamewanted") && "$domainname" ]] &&
  echo "Domainname:   $domainname" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$osinfowanted") && "$osname" && "$osversion" ]] &&
  echo "OS:           $osname $osversion" >>/tmp/sysreport.$$
[[ ! "$partialreport" || "$cpuinfowanted" ]] &&
  echo "System:       $systemproduct ($systemwidth)
Motherboard:  $systemmotherboard
BIOS:         $systembiosvendor $systembiosversion
CPU:          $systemcpuproduct from $systemcpuvendor
CPU config:   $systemcpuspeed with $systemcpucores core(s) enabled" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$memoryinfowanted") && "$memoryinfo" ]] &&
  echo "RAM installed:
$memoryinfo" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$diskinfowanted") && "$diskusage" ]] &&
  echo "Disk Usage:
$diskusage" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$printerinfowanted") && "$printerlist" ]] &&
  echo "Printer(s):
$printerlist" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$ipinfowanted") && "$ipinfo" ]] &&
  echo "IP Configuration:" >>/tmp/sysreport.$$ &&
  echo "$ipinfo" >> /tmp/sysreport.$$

cat /tmp/sysreport.$$

# cleanup temporary files
cleanup

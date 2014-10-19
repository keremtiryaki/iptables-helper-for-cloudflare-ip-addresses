# backup old rules
iptables-save >/iptablesExportBeforeCloudFlareSettings

# delete only all INPUT CHAIN RULES
iptables --flush INPUT

#adding INPUTS
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

#ask user to ssh 22 ip
echo "Your ip address is:"
echo $SSH_CLIENT | awk '{ print $1}'
echo "Please enter your current ip adress for ssh port 22"
read ipaddress
iptables -A INPUT -p tcp --source $ipaddress --dport 22 -j ACCEPT


#allow all cloudflare ip addresses for http and https
for i in `curl https://www.cloudflare.com/ips-v4`; do iptables -A INPUT -p tcp --source $i --dport 80 -j ACCEPT; done
for i in `curl https://www.cloudflare.com/ips-v4`; do iptables -A INPUT -p tcp --source $i --dport 443 -j ACCEPT; done

#drop all others
iptables -A INPUT -j DROP

####################################################################################################

# backup old rules
ip6tables-save >/ip6tablesExportBeforeCloudFlareSettings

# delete only all INPUT CHAIN RULES
ip6tables --flush INPUT

#adding INPUTS
ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
ip6tables -A INPUT -i lo -j ACCEPT

#allow all cloudflare ip addresses for http and https
for i in `curl https://www.cloudflare.com/ips-v6`; do ip6tables -A INPUT -p tcp --source $i --dport 80 -j ACCEPT; done
for i in `curl https://www.cloudflare.com/ips-v6`; do ip6tables -A INPUT -p tcp --source $i --dport 443 -j ACCEPT; done
#drop all others
ip6tables -A INPUT -j DROP


PS3='Please enter your choice: '
options=("Install iptables-persistent" "Restore your backups" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install iptables-persistent")
			echo "During the installation, you will be asked if you want to save the iptable rules to both the IPv4 rules and the IPv6 rules. Say yes to both."
			read -p "[Yy] to continue " -n 1 -r
			if [[ $REPLY =~ ^[Yy]$ ]]
			then
	            apt-get install iptables-persistent
				service iptables-persistent start
			fi
            ;;
        "Restore your backups")
			iptables-restore </iptablesExportBeforeCloudFlareSettings
			ip6tables-restore </ip6tablesExportBeforeCloudFlareSettings
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done
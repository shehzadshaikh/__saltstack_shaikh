[x] STEP 1:
=======
User Creation :
  salty  

salt-ssh with public key
https://docs.saltstack.com/en/latest/topics/ssh/


[x] STEP 2:
=======
yum repo local.nexus and proxy in yum.repo for internet.
proxy setup for public repositories


[x] STEP 3:
=======
Initiate salt-minon through salt-ssh state apply saltminion.sls and maintain state


[] STEP 4:
=======
Apply generic state : Stanard configurations
Standard Configuration:
 - [x] ntp
 - [x] sshd
 - [x] proxy
 - [x] rsyslog
 - [x] selinux
 - [x] stdtools (wget, unzip, expect, lsof, telnet, nc/netcat, tree, screen, nettools, tmux, m4, motif, rsync, mlocate, traceroute, tcpdump ..)
 - [x] firewalld/iptables/??ufw
 - [] motd
 - [x] banner
 - [x] zabbix_agent
 - [x] ds_agent
 - [] nexus_repo
 - [] cis_benchmark
 - [x] localusers
 - [] adjoin 
 - [] swap_space
 - [x] java
 - [x] salt-minon
 - [x] configure history
 - [x] limits
 - [] network

[] STEP 5:
=======
 APPLICATION SPECIFIC BASED ON SERVER STATE.

[] IMPROVEMENT 6:
=======
 - [] condition for minion installation
 - [] rsys log fine tuning
 - [] history to export rsys

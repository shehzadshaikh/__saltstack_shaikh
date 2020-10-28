[x] STEP 1:
=======
User Creation :
  salty  

salt-ssh with public key
https://docs.saltstack.com/en/latest/topics/ssh/


[] STEP 2:
=======
yum repo local.nexus and proxy in yum.repo for internet.


[] STEP 3:
=======
Initiate salt-minon through salt-ssh stateapply saltminion.sls and maintain state


[] STEP 4:
=======
Apply generic state : Stanard configurations
Standard Configuration:
 - [x] ntp
 - [x] sshd
 - [x] rsyslog
 - [x] selinux
 - [x] stdtools (wget, unzip, expect, lsof, telnet, nc/netcat, tree, screen, nettools, tmux, m4, motif, rsync, mlocate, traceroute, tcpdump ..)
 - [x] firewalld/iptables/??ufw
 - [] motd
 - [] zabbix_agent
 - [] ds_agent
 - [] nexus_repo
 - [] cis_benchmark
 - [x] localusers
 - [] adjoin 
 - [] swap_space
 - [] java
 - [] salt-minon
 - [] configure history
 - [] network

[] STEP 5:
=======
 APPLICATION SPECIFIC BASED ON SERVER STATE.

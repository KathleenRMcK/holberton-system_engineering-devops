# Create manifest that kills a process names killmenow


exec { 'pkill -f killmenow':
    path => '/usr/bin/:/usr/local/bin/:/bin/'
}

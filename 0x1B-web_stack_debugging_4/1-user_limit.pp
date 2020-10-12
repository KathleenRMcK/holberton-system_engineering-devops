# configs user limit
exec { 'hard limit':
  command => 'sudo sed -i \'s/hard limit nofile 5/nofile 30000/\' /etc/security/limits.conf',
  provider => shell,
}
exec { 'soft limit':
  command => 'sudo sed -i \'s/soft limit nofile 4/nofile 10000/\' /etc/security/limits.conf',
  provider => shell,
}
exec { 'restart':
  command => 'sysctl -p',
  provider => shell,
}

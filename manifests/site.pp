stage { 'notify': before => Stage['main'] }

# lint:ignore:autoloader_layout
class notify_role {
    notify{ "Node ${::fqdn} has role ${::role}": loglevel => info }
}

class notify_norole {
  notify{ "Node ${::fqdn} has no role set.": loglevel => warning }
}
# lint:endignore

node default {
  # FIXME:
  # your base class goes here
  # include base
  if $::role != 'notset' {
    class { 'notify_role': stage => 'notify' }
    include "role::${role}"
  } else {
    class { 'notify_norole': stage => 'notify' }
  }
}

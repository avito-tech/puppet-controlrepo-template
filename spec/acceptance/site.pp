node default {
  include base

  if $role {
    notify{ "Node ${::fqdn} has role ${role}.": }
    include "role::${role}"
  } else {
    notify{ "Node ${::fqdn} has no role set.": }
  }
}

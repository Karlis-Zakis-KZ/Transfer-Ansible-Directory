# manifest.pp
node default {
  ios_config { 'Ensure ACL configuration is present':
    commands => [
      "ip access-list standard ${acl_name}",
      "permit ${ip_range} ${wildcard_mask}",
    ],
  }
}

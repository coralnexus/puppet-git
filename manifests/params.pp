
class git::params inherits git::default {

  $base_name = 'git'

  include users::params

  #---

  $user       = module_param('user', 'git')
  $gid        = module_param('gid', 785)
  $group      = module_param('group', 'git')
  $alt_groups = module_array('alt_groups')
  $home_dir   = module_param('home_dir', '/var/git')

  #---

  $build_package_names  = module_array('build_package_names')
  $common_package_names = module_array('common_package_names')
  $extra_package_names  = module_array('extra_package_names')
  $package_ensure       = module_param('package_ensure', 'present')

  #---

  $prefix_template = module_param('prefix_template', 'wrapper')

  $hook_file_mode = module_param('hook_file_mode', '0755')

  #---

  $config_template = module_param('config_template', 'gitconfig')
  $config_file     = module_param('config_file', '.gitconfig')

  $root_config_file = module_param('root_config_file', "${users::params::root_home_dir}/${config_file}")
  $root_config      = module_hash('root_config', {
    user => {
      name  => module_param('root_name', $users::params::root_label),
      email => module_param('root_email', $users::params::root_email)
    }
  })
  $skel_config_file = module_param('skel_config_file', "${users::params::skel_home_dir}/${config_file}")
  $skel_config      = module_hash('skel_config', {
    user => {
      name  => module_param('skel_name', $users::params::user_label),
      email => module_param('skel_email', $users::params::user_email)
    }
  })

  $git_label           = module_param('git_label', 'Git account')
  $git_email           = module_param('git_email')
  $deny_current_branch = module_param('deny_current_branch', 'ignore')

  $git_config_file = module_param('git_config_file', "${home_dir}/${config_file}")
  $git_config      = module_hash('git_config', {
    user => {
      name  => $git_label,
      email => $git_email
    },
    recieve => {
      denyCurrentBranch => $deny_current_branch
    }
  })

  $allowed_ssh_key         = module_param('allowed_ssh_key')
  $allowed_ssh_key_type    = module_param('allowed_ssh_key_type', $users::params::default_ssh_key_type)
  $public_ssh_key          = module_param('public_ssh_key')
  $private_ssh_key         = module_param('private_ssh_key')
  $ssh_key_type            = module_param('ssh_key_type', $users::params::default_ssh_key_type)
  $known_hosts             = module_array('known_hosts')
  $password                = module_param('password')

  #---

  $revision                = module_param('revision', 'master')
  $base                    = module_param('base', false)

  $monitor_file_mode       = module_param('monitor_file_mode', false)

  $post_update_template    = module_param('post_update_template', 'git/post-update.erb')
  $post_update_commands    = module_array('post_update_commands')
}

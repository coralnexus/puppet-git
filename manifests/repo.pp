
define git::repo(

  $repo_name            = $name,
  $user                 = $git::params::user,
  $group                = $git::params::group,
  $home_dir             = $git::params::home_dir,
  $source               = undef,
  $revision             = $git::params::revision,
  $base                 = $git::params::base,
  $post_update_commands = $git::params::post_update_commands,
  $post_update_template = $git::params::post_update_template,
  $update_notify        = undef

) {
  $base_name       = $git::params::base_name
  $definition_name = "${base_name}_repo_${repo_name}"

  $repo_dir        = ensure($home_dir, "${home_dir}/${repo_name}", $repo_name)
  $repo_git_dir    = ensure($base, $repo_dir, "${repo_dir}/.git")

  #--

  coral::vcsrepo { $definition_name:
    resources => {
      repo => {
        path     => $repo_dir,
        ensure   => ensure($base, 'base', ensure($source, 'latest', 'present')),
        source   => $source,
        revision => ensure($source and $revision, $revision, undef)
      }
    },
    defaults => {
      provider => 'git',
      owner    => $user,
      group    => $group,
      force    => true,
      notify   => $update_notify
    },
    require  => Coral::File[$base_name]
  }

  #---

  coral::exec { $definition_name:
    resources => {
      receive_denyCurrentBranch => {
        command     => ensure($home_dir and ! $base, "git config receive.denyCurrentBranch ignore"),
        refreshonly => true
      }
    },
    defaults => {
      cwd       => $repo_dir,
      user      => $user,
      subscribe => Vcsrepo["${definition_name}_repo"]
    }
  }

  #---

  coral::file { "${definition_name}_hooks":
    resources => {
      post_update => {
        path    => 'post-update',
        content => template($post_update_template)
      }
    },
    defaults => {
      owner         => $user,
      group         => $group,
      mode          => $git::params::hook_file_mode,
      path_template => $git::params::prefix_template
    },
    options => {
      normalize_path  => false,
      template_prefix => "${repo_git_dir}/hooks/"
    },
    require => Coral::Exec[$definition_name]
  }
}

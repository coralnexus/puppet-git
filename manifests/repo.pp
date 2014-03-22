
define git::repo(

  $path                 = $name,
  $user                 = $git::params::user,
  $owner                = $git::params::owner,
  $group                = $git::params::group,
  $home_dir             = $git::params::home_dir,
  $source               = undef,
  $revision             = $git::params::revision,
  $base                 = $git::params::base,
  $monitor_file_mode    = $git::params::monitor_file_mode,
  $post_update_commands = $git::params::post_update_commands,
  $post_update_template = $git::params::post_update_template,
  $update_notify        = undef

) {
  $base_name       = $git::params::base_name
  $definition_name = name("${base_name}_repo_${name}")

  $repo_dir        = ensure($home_dir, "${home_dir}/${path}", $path)
  $repo_git_dir    = ensure($base, $repo_dir, "${repo_dir}/.git")

  #--

  corl::vcsrepo { $definition_name:
    resources => {
      repo => {
        path     => $repo_dir,
        ensure   => ensure($base, 'base', ensure($source, 'latest', 'present')),
        source   => ensure($source),
        revision => ensure($source and $revision, $revision)
      }
    },
    defaults => {
      provider => 'git',
      user     => $user,
      owner    => $owner,
      group    => $group,
      force    => true,
      notify   => $update_notify
    },
    require  => Corl::File[$base_name]
  }

  #---

  corl::exec { $definition_name:
    resources => {
      receive_denyCurrentBranch => {
        command     => ensure($home_dir and ! $base, "git config receive.denyCurrentBranch ignore")
      },
      core_filemode => {
        command => "git config core.filemode ${monitor_file_mode}"
      }
    },
    defaults => {
      cwd         => $repo_dir,
      user        => $user,
      refreshonly => true,
      subscribe   => Vcsrepo["${definition_name}_repo"]
    }
  }

  #---

  corl::file { "${definition_name}_hooks":
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
    require => Corl::Exec[$definition_name]
  }
}

# Class: git
#
#   This module manages Git components.
#
#   Adrian Webb <adrian.webb@coralnexus.com>
#   2012-05-22
#
#   Tested platforms:
#    - Ubuntu 12.04
#
# Parameters: (see <example/params.json> for Hiera configurations)
#
# Actions:
#
#  Installs, configures, and manages Git components.
#
# Requires:
#
# Sample Usage:
#
#   include git
#
class git inherits git::params {

  $base_name = $git::params::base_name

  #-----------------------------------------------------------------------------
  # Installation

  coral::package { $base_name:
    resources => {
      build_packages  => {
        name => $git::params::build_package_names
      },
      common_packages => {
        name    => $git::params::common_package_names,
        require => 'build_packages'
      },
      extra_packages  => {
        name    => $git::params::extra_package_names,
        require => 'common_packages'
      }
    },
    defaults  => {
      ensure => $git::params::package_ensure
    }
  }

  #-----------------------------------------------------------------------------
  # Configuration

  coral::file { $base_name:
    resources => {
      root_gitconfig => {
        path    => $git::params::root_config_file,
        content => $git::params::root_config
      },
      skel_gitconfig => {
        path    => $git::params::skel_config_file,
        content => $git::params::skel_config
      },
      git_gitconfig => {
        path    => ensure($git::params::user, $git::params::git_config_file),
        content => $git::params::git_config,
        require => Users::User[$git::params::user]
      }
    },
    defaults => { content_template => $git::params::config_template }
  }

  #-----------------------------------------------------------------------------
  # Actions

  coral::exec { $base_name: }

  #-----------------------------------------------------------------------------
  # User

  if $git::params::user {
    users::user { $git::params::user:
      system               => true,
      label                => $git::params::git_label,
      email                => $git::params::git_email,
      gid                  => $git::params::gid,
      group                => $git::params::group,
      alt_groups           => $git::params::alt_groups,
      password             => $git::params::password,
      home_dir             => $git::params::home_dir,
      allowed_ssh_key      => $git::params::allowed_ssh_key,
      allowed_ssh_key_type => $git::params::allowed_ssh_key_type,
      ssh_key_type         => $git::params::ssh_key_type,
      public_ssh_key       => $git::params::public_ssh_key,
      private_ssh_key      => $git::params::private_ssh_key,
      require              => Coral::Package[$base_name],
    }
  }

  #-----------------------------------------------------------------------------
  # Resources

  coral_resources('git::repo', "${base_name}::repo", "${base_name}::repo_defaults")
}


class git::default {

  case $::operatingsystem {
    debian, ubuntu: {
      $common_package_names = ['git']
    }
  }
}

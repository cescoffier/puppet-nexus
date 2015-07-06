# Resource: nexus::artifact
#
# This resource downloads Maven Artifacts from Nexus
#
# Parameters:
# [*gav*] : The artifact groupid:artifactid:version (mandatory)
# [*packaging*] : The packaging type (jar by default)
# [*classifier*] : The classifier (no classifier by default)
# [*repository*] : The repository such as 'public', 'central'...(mandatory)
# [*output*] : The output file (mandatory)
# [*ensure*] : If 'present' checks the existence of the output file (and downloads it if needed), if 'absent' deletes the output
# file, if not set redownload the artifact
# [*timeout*] : Optional timeout for download exec. 0 disables - see exec for default.
# [*owner*] : Optional user to own the file
# [*group*] : Optional group to own the file
# [*mode*] : Optional mode for file
#
# Actions:
# If ensure is set to 'present' the resource checks the existence of the file and download the artifact if needed.
# If ensure is set to 'absent' the resource deleted the output file.
# If ensure is not set or set to 'update', the artifact is re-downloaded.
#
# Sample Usage:
#  class nexus:artifact {
#}
#
define nexus::artifact (
  $gav,
  $repository,
  $output,
  $packaging  = 'jar',
  $classifier = undef,
  $ensure     = update,
  $timeout    = undef,
  $owner      = undef,
  $group      = undef,
  $mode       = undef
) {

  include nexus

  if($nexus::username and $nexus::password) {
    $args = "-u ${nexus::username} -p '${nexus::password}'"
  } elsif ($nexus::netrc) {
    $args = '-m'
  }

  if ($classifier!=undef) {
    $includeClass = "-c ${classifier}"
  }

  $cmd = "/opt/nexus-script/download-artifact-from-nexus.sh -a ${gav} -e ${packaging} ${$includeClass} -n ${nexus::url} -r ${repository} -o ${output} ${args} -v"

  if (($ensure != absent) and ($gav =~ /-SNAPSHOT/)) {
    exec { "Checking ${gav}-${classifier}":
      command => "${cmd} -z",
      timeout => $timeout,
      before  => Exec["Download ${name}"],
    }
  }

  if $ensure == present {
    exec { "Download ${name}":
      command => $cmd,
      creates => $output,
      timeout => $timeout,
    }
  } elsif $ensure == absent {
    file { "Remove ${name}":
      ensure => absent,
      path   => $output,
    }
  } else {
    exec { "Download ${name}":
      command => $cmd,
      timeout => $timeout,
    }
  }

  if $ensure != absent {
    file { $output:
      ensure  => file,
      require => Exec["Download ${name}"],
      owner   => $owner,
      group   => $group,
      mode    => $mode,
    }
  }

}

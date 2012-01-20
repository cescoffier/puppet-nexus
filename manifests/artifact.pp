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
# [*ensure*] : If 'present' checks the existence of the output file (and downloads it if needed), if 'absent' deletes the output file, if not set redownload the artifact
#
# Actions:
# If ensure is set to 'present' the resource checks the existence of the file and download the artifact if needed.
# If ensure is set to 'absent' the resource deleted the output file.
# If ensure is not set or set to 'update', the artifact is re-downloaded.
#
# Sample Usage:
#  class nexus {
#   url => http://edge.spree.de/nexus,
#   username => user,
#   password => password
# }
#
define nexus::artifact(
	$gav,
	$packaging = "jar",
	$classifier = "",
	$repository,
	$output,
	$ensure = update
	) {
	
	include nexus
	
	if ($nexus::authentication) {
		$args = "-u ${nexus::user} -p '${nexus::pwd}'"
	} else {
		$args = ""
	}

	if ($classifier) {
		$includeClass = "-c ${classifier}"	
	}

	$cmd = "/opt/nexus-script/download-artifact-from-nexus.sh -a ${gav} -e ${packaging} ${$includeClass} -n ${nexus::NEXUS_URL} -r ${repository} -o ${output} $args -v"
	
	if $ensure == present {
		exec { "Download ${gav}-${classifier}":
			command => $cmd,
			unless  => "/bin/test -f ${output}"
		}
	} elsif $ensure == absent {
		file { "Remove ${gav}-${classifier}":
			path   => $output,
			ensure => absent
		}
	} else {
		exec { "Download ${gav}-${classifier}":
			command => $cmd,
		}
	}
}
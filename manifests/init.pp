# Class: nexus
#
# This module downloads Maven Artifacts from Nexus
#
# Parameters:
# [*url*] : The Nexus base url (mandatory)
# [*username*] : The username used to connect to nexus
# [*password*] : The password used to connect to nexus
#
# Actions:
# Checks and intialized the Nexus support.
#
# Sample Usage:
#  class nexus {
#   url => http://edge.spree.de/nexus,
#   username => user,
#   password => password
# }
#
class nexus(
	$url = "",
	$username = "",
	$password = "") {

# Check arguments
# url mandatory
if $url == "" {
	fail("Cannot initialize the Nexus class - the url parameter is mandatory")
}
$NEXUS_URL = $url

if ($username != "")  and ($password == "") {
	fail("Cannot initialize the Nexus class - both username and password must be set")
} elsif ($username == "")  and ($password != "") {
	fail("Cannot initialize the Nexus class - both username and password must be set")
} elsif ($username == "")  and ($password == "") {
	$authentication = false
} else {
	$authentication = true
	$user = $username
	$pwd = $password
}

# Install script
file { "/opt/nexus-script/download-artifact-from-nexus.sh":
		ensure   => file,
	    owner    => "root",
	    mode     => "0755",
		source   => "puppet:///modules/nexus/download-artifact-from-nexus.sh",
		require  => [File["/opt/nexus-script"]]
}

file { "/opt/nexus-script":
	ensure => directory
}	

}

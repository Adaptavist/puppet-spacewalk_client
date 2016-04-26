class spacewalk_client::params {
    # OS independant params
    $spacewalk_server_uri = 'XMLRPC'
    $spacewalk_server_protocol = 'https'
    $local_certificate_file = 'RHN-ORG-TRUSTED-SSL-CERT'
    $local_certificate_folder = '/usr/share/rhn'
    $subsystem_directory = '/var/lock/subsys'
    $force_registration = 'false'
    $spacewalk_poll_interval = '60'
    $spacewalk_poll_config = '/etc/sysconfig/rhn/rhnsd'
    $rhnsd_service = 'rhnsd'

    # OS specific params
    case $::operatingsystem {
        'Ubuntu': {
            $osr_array = split($::operatingsystemmajrelease,'[\/\.]')
            $distrelease = $osr_array[0]
            if ! $distrelease {
                fail("spacewalk_client - Unparsable \$::operatingsystemmajrelease: ${::operatingsystemmajrelease}")
            }
            if ($distrelease == '12') {
                $spacewalk_repo_channels = 'precise precise-updates precise-security'
            } elsif ($distrelease == '14') {
                $spacewalk_repo_channels = 'trusty trusty-updates trusty-security'
            } else {
                fail("spacewalk_client - Unsupported Ubuntu Version: ${distrelease}")
            }
            $spacewalk_repository = 'ppa:aaronr/spacewalk'
            $spacewalk_packages = ['software-properties-common', 'apt-transport-spacewalk', 'rhnsd', 'python-libxml2']
            $package_manager_disable_diff_file = '/etc/apt/apt.conf.d/00spacewalk'
            $package_manager_disable_diff_content = 'Acquire::Pdiffs "false";'
            $package_manager_repo_file = '/etc/apt/sources.list.d/spacewalk.list'
            $spacewalk_repository_package = undef
        }
        'RedHat', 'CentOS': {
            if ($::operatingsystemmajrelease == '7') {
                $major_os_version = '7'
            } elsif ($::operatingsystemmajrelease == '6') {
                $major_os_version = '6'
            } else {
                fail("spacewalk_client - Unsupported RHEL/CentOS Version: ${::operatingsystemmajrelease}")
            }
            $spacewalk_repository = "http://yum.spacewalkproject.org/2.3-client/RHEL/${major_os_version}/x86_64/spacewalk-client-repo-2.3-2.el${major_os_version}.noarch.rpm"
            $spacewalk_packages = ['rhn-client-tools', 'rhn-check', 'rhn-setup', 'rhnsd', 'm2crypto', 'yum-rhn-plugin', 'rhncfg-management', 'rhncfg-actions']
            $package_manager_disable_diff_file = undef
            $package_manager_disable_diff_content = undef
            $package_manager_repo_file = undef
            $spacewalk_repo_channels = undef
            $spacewalk_repository_package = "spacewalk-client-repo-2.3-2.el${major_os_version}.noarch"
        }
        default: {
            fail("spacewalk_client - Unsupported Operating System: ${::operatingsystem}")
        }
    }
}
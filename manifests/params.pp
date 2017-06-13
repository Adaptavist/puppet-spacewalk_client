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
    $allow_deploy_action = false
    $allow_diff_action  = false
    $allow_upload_action = false
    $allow_mtime_upload_action = false
    $allow_run_action = false
    $install_osad = false
    $osad_service = 'osad'
    $yum_gpg_keys = {}
    $spool_directory = '/var/spool/rhn'

    # OS specific params
    case $::operatingsystem {
        'Ubuntu': {
            $osr_array = split($::operatingsystemmajrelease,'[\/\.]')
            $major_os_version = $osr_array[0]
            if ! $major_os_version {
                fail("spacewalk_client - Unparsable \$::operatingsystemmajrelease: ${::operatingsystemmajrelease}")
            }
            if ($major_os_version == '12') {
                $spacewalk_repo_channels = 'precise precise-updates precise-security'
                $osad_repository_config_file = '/etc/apt/sources.list.d/mj-casalogic-spacewalk-ubuntu-precise.list'
            } elsif ($major_os_version == '14') {
                $spacewalk_repo_channels = 'trusty trusty-updates trusty-security'
                $osad_repository_config_file = '/etc/apt/sources.list.d/mj-casalogic-spacewalk-ubuntu-trusty.list'
            } else {
                fail("spacewalk_client - Unsupported Ubuntu Version: ${major_os_version}")
            }
            $spacewalk_repository = 'ppa:aaronr/spacewalk'
            $spacewalk_packages = ['software-properties-common', 'apt-transport-spacewalk', 'rhnsd', 'python-libxml2','rhncfg']
            $package_manager_disable_diff_file = '/etc/apt/apt.conf.d/00spacewalk'
            $package_manager_disable_diff_content = 'Acquire::Pdiffs "false";'
            $package_manager_repo_file = '/etc/apt/sources.list.d/spacewalk.list'
            $spacewalk_repository_package = undef
            $osad_packages = ['osad','pyjabber']
            $osad_repository = 'ppa:mj-casalogic/spacewalk-ubuntu'
            $osad_repository_release = 'precise'

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
            $osad_packages = ['osad']
            $osad_repository = undef
            $osad_repository_distribution = undef
            $osad_repository_config_file = undef

        }
        default: {
            fail("spacewalk_client - Unsupported Operating System: ${::operatingsystem}")
        }
    }
}

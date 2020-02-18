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
    $osad_logrotate_file = '/etc/logrotate.d/osad'
    $osad_logrotate_perms = '0644'

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
            $osad_packages = ['osad','pyjabber']
            $osad_repository = 'ppa:mj-casalogic/spacewalk-ubuntu'
            $osad_repository_release = 'precise'
            $spacewalk_repository_name = undef
            $spacewalk_repository_gpg = undef
        }
        'RedHat', 'CentOS': {
            if ($::operatingsystemmajrelease == '8') {
                $major_os_version = '8'
            } elsif ($::operatingsystemmajrelease == '7') {
                $major_os_version = '7'
            } elsif ($::operatingsystemmajrelease == '6') {
                $major_os_version = '6'
            } else {
                fail("spacewalk_client - Unsupported RHEL/CentOS Version: ${::operatingsystemmajrelease}")
            }
            if ($major_os_version == '8' ) {
                $spacewalk_repository = 'https://copr-be.cloud.fedoraproject.org/results/%40spacewalkproject/spacewalk-2.8-client/fedora-28-x86_64/'
                $spacewalk_packages = ['rhn-client-tools', 'rhn-check', 'rhn-setup', 'rhnsd', 'yum-rhn-plugin', 'rhncfg-management', 'rhncfg-actions']
            } else {
                $spacewalk_repository = "http://copr-be.cloud.fedoraproject.org/archive/spacewalk/2.3-client/RHEL/${major_os_version}/\$basearch/"
                $spacewalk_packages = ['rhn-client-tools', 'rhn-check', 'rhn-setup', 'rhnsd', 'm2crypto', 'yum-rhn-plugin', 'rhncfg-management', 'rhncfg-actions']
            }
            $spacewalk_repository_gpg = 'http://copr-be.cloud.fedoraproject.org/archive/spacewalk/RPM-GPG-KEY-spacewalk-2014'
            $spacewalk_repository_name = 'spacewalk-client'
            $package_manager_disable_diff_file = undef
            $package_manager_disable_diff_content = undef
            $package_manager_repo_file = undef
            $spacewalk_repo_channels = undef
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

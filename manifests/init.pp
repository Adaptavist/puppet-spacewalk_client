class spacewalk_client  (
    $spacewalk_server_address,
    $spacewalk_activation_key,
    $spacewalk_certificate_url,
    $spacewalk_server_uri                  = $spacewalk_client::params::spacewalk_server_uri,
    $spacewalk_server_protocol             = $spacewalk_client::params::spacewalk_server_protocol,
    $spacewalk_repository                  = $spacewalk_client::params::spacewalk_repository,
    $spacewalk_repository_package          = $spacewalk_client::params::spacewalk_repository_package,
    $spacewalk_packages                    = $spacewalk_client::params::spacewalk_packages,
    $local_certificate_folder              = $spacewalk_client::params::local_certificate_folder,
    $local_certificate_file                = $spacewalk_client::params::local_certificate_file,
    $package_manager_disable_diff_file     = $spacewalk_client::params::package_manager_disable_diff_file,
    $package_manager_disable_diff_content  = $spacewalk_client::params::package_manager_disable_diff_content,
    $package_manager_repo_file             = $spacewalk_client::params::package_manager_repo_file,
    $spacewalk_repo_channels               = $spacewalk_client::params::spacewalk_repo_channels,
    $subsystem_directory                   = $spacewalk_client::params::subsystem_directory,
    $force_registration                    = $spacewalk_client::params::force_registration,
    $spacewalk_poll_interval               = $spacewalk_client::params::spacewalk_poll_interval,
    $spacewalk_poll_config                 = $spacewalk_client::params::spacewalk_poll_config,
    $rhnsd_service                         = $spacewalk_client::params::rhnsd_service,
    $allow_deploy_action                   = $spacewalk_client::params::allow_deploy_action,
    $allow_diff_action                     = $spacewalk_client::params::allow_diff_action,
    $allow_upload_action                   = $spacewalk_client::params::allow_upload_action,
    $allow_mtime_upload_action             = $spacewalk_client::params::allow_mtime_upload_action,
    $allow_run_action                      = $spacewalk_client::params::allow_run_action,
    $osad_packages                         = $spacewalk_client::params::osad_packages,
    $install_osad                          = $spacewalk_client::params::install_osad,
    $osad_service                          = $spacewalk_client::params::osad_service
    ) inherits spacewalk_client::params {

    #validate stuff
    validate_re($spacewalk_server_protocol, ['^https$', '^http$'])

    if ($::operatingsystem == 'RedHat' or $::operatingsystem == 'CentOS') {
        package { $spacewalk_repository_package:
            ensure   => 'installed',
            source   => $spacewalk_repository,
            provider => 'rpm',
        }
        $repo_require = [Package[$spacewalk_repository_package]]
    } elsif ($::operatingsystem == 'Ubuntu') {
        exec { 'spacewalk_repository':
            command => "add-apt-repository ${spacewalk_repository} -y"
        }

        file { $subsystem_directory:
            ensure => 'directory'
        }

        $repo_require = [Exec['spacewalk_repository'], File[$subsystem_directory]]
    } else {
        fail("spacewalk_client - Unsupported Operating System: ${::operatingsystem}")
    }

    if str2bool($force_registration) {
        $real_force_registration = '--force'
        $register_unless = 'test 1 = 2'
    } else {
        $real_force_registration = ''
        $register_unless = 'test -f /etc/sysconfig/rhn/systemid'
    }

    package { $spacewalk_packages:
        ensure  => 'installed',
        require => $repo_require
    } ->
    exec { 'get_spacewalk_certificate':
        command => "wget ${spacewalk_certificate_url} -P ${local_certificate_folder}",
        creates => "${local_certificate_folder}/${local_certificate_file}"
    } ->
    exec { 'register_spacewalk_client':
        command => "rhnreg_ks ${real_force_registration} --serverUrl=${spacewalk_server_protocol}://${spacewalk_server_address}/${spacewalk_server_uri} --sslCACert=${local_certificate_folder}/${local_certificate_file} --activationkey=${spacewalk_activation_key}",
        unless  => $register_unless
    }

    if ($::operatingsystem == 'Ubuntu') {
        file { $package_manager_repo_file:
            ensure  => 'present',
            content => "deb spacewalk://${spacewalk_server_address} channels: ${spacewalk_repo_channels}\n",
            require => Exec['register_spacewalk_client']
        }

        # create config file that disables apt-get update diffs
        file { $package_manager_disable_diff_file:
            ensure  => 'present',
            content => "${package_manager_disable_diff_content}\n",
            require => Exec['register_spacewalk_client']
        }
    }
  
    # TODO - turn this into an exec so it can have a check that the file exists
    augeas { 'update_polling_interval':
        context =>  "/files/${spacewalk_poll_config}/",
        changes =>  "set INTERVAL ${spacewalk_poll_interval}",
        notify  => exec['restart_rhnsd'],
        require => Package[$spacewalk_packages]
    }

    exec { 'restart_rhnsd':
        command     => "service ${rhnsd_service} restart",
        refreshonly => 'true'
    }

    # TODO - MAKE OSAD AND RHN-ACTIONS-CONTROL WORK WITH UBUNTU
    if ($::operatingsystem == 'RedHat' or $::operatingsystem == 'CentOS') {
        # work out actions
        
        $deploy_action  = str2bool($allow_deploy_action) ? {
            false => '--disable-deploy',
            default => '--enable-deploy',
        }

        $diff_action  = str2bool($allow_diff_action) ? {
            false => '--disable-diff',
            default => '--enable-diff',
        }

        $upload_action  = str2bool($allow_upload_action) ? {
            false => '--disable-upload',
            default => '--enable-upload',
        }

        $mtime_upload_action = str2bool($allow_mtime_upload_action) ? {
            false => '--disable-mtime-upload',
            default => '--enable-mtime-upload',
        }

        $run_action = str2bool($allow_run_action) ? {
            false => '--disable-run',
            default => '--enable-run',
        }


        exec { 'update_spacewalk_action_control':
            command => "rhn-actions-control ${deploy_action} ${diff_action} ${upload_action} ${mtime_upload_action} ${run_action} -f",
            require => Exec['register_spacewalk_client']
        }

        if str2bool($install_osad) {
            # if osad is needed install it
            package { $osad_packages:
                ensure  => 'installed',
                require => $repo_require
            } ->
            # and make sure the service is 
            service {$osad_service:
                ensure => running,
                enable => true,
            }
        }
    }
}

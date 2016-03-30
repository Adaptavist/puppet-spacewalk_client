class spacewalk_client  (
    $spacewalk_server_address              = $spacewalk_client::params::spacewalk_server_address,
    $spacewalk_server_uri                  = $spacewalk_client::params::spacewalk_server_uri,
    $spacewalk_server_protocol             = $spacewalk_client::params::spacewalk_server_protocol,
    $spacewalk_certificate_url             = $spacewalk_client::params::spacewalk_certificate_url,
    $spacewalk_repository                  = $spacewalk_client::params::spacewalk_repository,
    $spacewalk_repository_package          = $spacewalk_client::params::spacewalk_repository_package,
    $spacewalk_packages                    = $spacewalk_client::params::spacewalk_packages,
    $spacewalk_activation_key              = $spacewalk_client::params::spacewalk_activation_key,
    $local_certificate_folder              = $spacewalk_client::params::local_certificate_folder,
    $local_certificate_file                = $spacewalk_client::params::local_certificate_file,
    $package_manager_disable_diff_file     = $spacewalk_client::params::package_manager_disable_diff_file,
    $package_manager_disable_diff_command  = $spacewalk_client::params::package_manager_disable_diff_command,
    $package_manager_repo_file             = $spacewalk_client::params::package_manager_repo_file,
    $spacewalk_repo_channels               = $spacewalk_client::params::spacewalk_repo_channels,
    $subsystem_directory                   = $spacewalk_client::params::subsystem_directory,
    $force_registration                    = $spacewalk_client::params::force_registration,
    $spacewalk_poll_interval               = $spacewalk_client::params::spacewalk_poll_interval,
    $spacewalk_poll_config                 = $spacewalk_client::params::spacewalk_poll_config,
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
            command => 'add-apt-repository ${spacewalk_repository} -y'
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
    } else {
        $real_force_registration = ''
    }

    package { $spacewalk_packages:
        ensure  => 'installed',
        require => $repo_require
    } ->
    exec { 'get_spacewalk_certificate':
        command => "wget ${spacewalk_certificate_url} -P ${local_certificate_folder}"
    } ->
    exec { 'register_spacewalk_client':
        command => "rhnreg_ks ${real_force_registration} --serverUrl=${spacewalk_server_protocol}://${spacewalk_server_address}/${spacewalk_server_uri} --sslCACert=${local_certificate_folder}/${local_certificate_file} --activationkey=${spacewalk_activation_key}"
    }

    if ($::operatingsystem == 'Ubuntu') {
        file { $package_manager_repo_file:
            ensure  => 'present',
            content => "deb spacewalk://${spacewalk_server_address}/${spacewalk_server_uri} channels: ${spacewalk_repo_channels}",
            require => Exec['register_spacewalk_client']
        }

        file { $package_manager_disable_diff_file:
            ensure  => 'present',
            content => $package_manager_disable_diff_command,
            require => Exec['register_spacewalk_client']
        }
    }

    # TODO - set polling interval

    # TODO - rhn-actions-control to delegate addition permissions
}
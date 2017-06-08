# spacewalk_client Module
[![Build Status](https://travis-ci.org/Adaptavist/puppet-spacewalk_client.svg?branch=master)](https://travis-ci.org/Adaptavist/puppet-spacewalk_client)
## Overview

The **spacewalk_client** module registers a system with a spacewalk server, it also installs all the nessisary components to achieve this

Currently Ubuntu 12/14 and RHEL/Centos 6/7 are supported.

## Configuration

`spacewalk_client::spacewalk_server_address`

Specified the URL to use to communicate with Spacewalk, used with the `spacewalk_server_protocol` and `spacewalk_server_uri` variables, this is a mandatory variable and has no default

`spacewalk_client::spacewalk_activation_key`

Specified the activation key to use to register with Spacewalk, this is a mandatory variable and has no default

`spacewalk_client::spacewalk_certificate_url`

Specified where to download the RHN trust certificate from, this is a mandatory variable and has no default

`spacewalk_client::spacewalk_server_uri`

Specified the URI to use to communicate with Spacewalk, used with the `spacewalk_server_address` and `spacewalk_server_protocol` variables, it defaults to **XMLRPC**

`spacewalk_client::spacewalk_server_protocol`

Specified the protocol to use to access spacewalk, used with the `spacewalk_server_address` and `spacewalk_server_uri` variables, valid options are http or https, it defaults to **https**

`spacewalk_client::spacewalk_repository`

Specified the package repository from which Spacekwalk packages can be installed, defaults to **pa:aaronr/spacewalk** on Ubuntu and **http://yum.spacewalkproject.org/2.3-client/RHEL/<MAJOR_OS_VERSION>/x86_64/spacewalk-client-repo-2.3-2.el<MAJOR_OS_VERSION>.noarch.rpm** on RHEL/CentOS systems

`spacewalk_client::spacewalk_repository_package`

Specified the name of the RPM package used to add the Spacewalk repo, is the RPM package specified in `spacewalk_repository`, this is only needed for RHEL/CentOS systems and defaults to **spacewalk-client-repo-2.3-2.el<MAJOR_OS_VERSION>.noarch.rpm**

`spacewalk_client::spacewalk_packages`

Specifies a list of packages that need to be installed from the Spacewalk repository, defaults to **['software-properties-common', 'apt-transport-spacewalk', 'rhnsd', 'python-libxml2']** on Ubuntu and **['rhn-client-tools', 'rhn-check', 'rhn-setup', 'rhnsd', 'm2crypto', 'yum-rhn-plugin', 'rhncfg-management', 'rhncfg-actions']** on RHEL/CentOS systems

`spacewalk_client::local_certificate_folder`

Specified the local folder to be used when downloading the RHN trust certificate from, it defaults to **/usr/share/rhn**

`spacewalk_client::local_certificate_file`

Specified the local file to be used when downloading the RHN trust certificate from, it defaults to **RHN-ORG-TRUSTED-SSL-CERT**

`spacewalk_client::package_manager_repo_file`

Specifies the location of a file that configures an apt-get repo pointing to the spacewalk server, only used for Ubuntu systems, defaults to **/etc/apt/sources.list.d/spacewalk.list**

`spacewalk_client::package_manager_disable_diff_file`

Specified the location of a file to disable pdiffs on the apt repositories provided by the Spacewalk server, only used for Ubuntu systems, defaults to **/etc/apt/apt.conf.d/00spacewalk**

`spacewalk_client::package_manager_disable_diff_content`

Specified the content of the file to disable pdiffs on the apt repositories provided by the Spacewalk server, only used for Ubuntu systems, defaults to **Acquire::Pdiffs "false";**

`spacewalk_client::spacewalk_repo_channels`

Specified the repo channels used for apt-get repositories pointing to the spacewalk server, only used for Ubuntu systems, defaults to **precise precise-updates precise-security** for Ubuntu 12 and **trusty trusty-updates trusty-security** for Ubuntu 14

`spacewalk_client::subsystem_directory`

Specifies the subsystem lock directory, defaults to **/var/lock/subsys**

`spacewalk_client::force_registration`

Specified if the registration of the client should be forced (allows registrtion even if it believes itself to already be registered), defaults to **false**

`spacewalk_client::spacewalk_poll_interval`

Specifies the interval at which rhnsd should poll the spacewalk server for instructions, defaults to **60** minutes, which is the lowest amount it can be

`spacewalk_client::spacewalk_poll_config`

Specifies the file which controlls rhnsd's polling interval, defaults to **etc/sysconfig/rhn/rhnsd**

`spacewalk_client::rhnsd_service`

Specifies the name of the rhnsd service, defaults to **rhnsd**

`spacewalk_client::allow_deploy_action`

Specifies if spacewalk should have deploy action rights on the client, currently this is only avaliable for RHEL/CentOS systems and defaults to **false**

`spacewalk_client::allow_diff_action`

Specifies if spacewalk should have diff action rights on the client, currently this is only avaliable for RHEL/CentOS systems and defaults to **false**

`spacewalk_client::allow_upload_action`

Specifies if spacewalk should have upload action rights on the client, currently this is only avaliable for RHEL/CentOS systems and defaults to **false**

`spacewalk_client::allow_mtime_upload_action`

Specifies if spacewalk should have mtime upload action rights on the client, currently this is only avaliable for RHEL/CentOS systems and defaults to **false**

`spacewalk_client::allow_run_action`

Specifies if spacewalk should have run action rights on the client, currently this is only avaliable for RHEL/CentOS systems and defaults to **false**

`spacewalk_client::osad_packages`

Specifies a list of packages that need to be installed to support OSAD, defaults to **['osad','pyjabber']** on Ubuntu and **['osad']** on RHEL/CentOS systems

`spacewalk_client::install_osad`

Specified if OSAD should be installed, defaults to **false**

`spacewalk_client::osad_service`

Specified the name of the OSAD service, defaults to **osad**

`spacewalk_client::yum_gpg_keys`

A hash of YUM Repository GPG keys to be installed, only used for RHEL/CentOS systems and defaults to **empty hash**

`spacewalk_client::osad_repository`

Specified the package repository from which OSAD packages can be installed, only used for Ubuntu systems, defaults to  **ppa:mj-casalogic/spacewalk-ubuntu** 

`spacewalk_client::osad_repository_release`

Specifies the release version to use for the OSAD package repository, only used for Ubuntu systems, defaults to **precise**, there is no trusty (Ubuntu 14) version avaliable, however precise (Ubuntu 12) packages work with 14

`spacewalk_client::osad_repository_config_file`

Secified the apt config file for the OSAD repo, only used for Ubuntu systems and defaults to */etc/apt/sources.list.d/mj-casalogic-spacewalk-ubuntu-precise.list* on Ubuntu 12 and */etc/apt/sources.list.d/mj-casalogic-spacewalk-ubuntu-trusty.list* on Ubuntu 14

`spacewalk_client::spool_directory`

Specifies the spool directory, defaults to **/var/spool/rhn**

## Example Usage:
 
    spacewalk_client::spacewalk_server_address: 'spacewalk.example.com'
    spacewalk_client::spacewalk_certificate_url: 'https://spacewalk.example.com/pub/RHN-ORG-TRUSTED-SSL-CERT'
    spacewalk_client::spacewalk_server_uri 'XMLRPC;
    spacewalk_client::spacewalk_server_protocol 'https'
    spacewalk_client::spacewalk_activation_key:    1-234567890"
    spacewalk_client::install_osad: true
    spacewalk_client::allow_deploy_action = false
    spacewalk_client::allow_diff_action  = false
    spacewalk_client::allow_upload_action = false
    spacewalk_client::allow_mtime_upload_action = false
    spacewalk_client::allow_run_action = true


## Dependencies

This module depends on the following puppet modules:

* puppetlabs/stdlib


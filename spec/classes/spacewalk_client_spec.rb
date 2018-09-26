require 'spec_helper'

describe 'spacewalk_client', :type => 'class' do

  spacewalk_repository_package = 'spacewalk_repository_package'
  spacewalk_repository = 'spacewalk_repository'
  spacewalk_repository_gpg = 'spacewalk_repository_gpg'
  spacewalk_repository_name = 'spacewalk_repository_name'
  operatingsystemmajrelease_centos = '7'
  fail_operatingsystemrelease = '5'
  fail_operatintsystem = 'Windows'
  if Puppet.version.to_f >= 4.0
      repo_require_centos = "[Yumrepo[#{spacewalk_repository_name}]{:name=>\"#{spacewalk_repository_name}\"}]"
  else
      repo_require_centos = "Yumrepo[#{spacewalk_repository_name}]"
  end
  spacewalk_certificate_url = 'spacewalk_certificate_url'
  local_certificate_folder = '/usr/share/rhn'
  default_force_registration = ''
  spacewalk_server_protocol = 'http'
  spacewalk_server_address = 'spacewalk_server_address'
  spacewalk_server_uri = 'spacewalk_server_uri'
  local_certificate_file = 'local_certificate_file'
  spacewalk_activation_key = 'spacewalk_activation_key'
  centos_spacewalk_package1 = 'rhn-client-tools'
  centos_spacewalk_package2 = 'rhn-check'
  centos_spacewalk_package3 = 'rhn-setup'
  centos_spacewalk_package4 = 'rhnsd'
  centos_spacewalk_package5 = 'm2crypto'
  centos_spacewalk_package6 = 'yum-rhn-plugin'
  centos_spacewalk_package7 = 'rhncfg-management'
  centos_spacewalk_package8 = 'rhncfg-actions'
  centos_osad_package = 'oasd_fake'
  ubuntu_spacewalk_package1 = 'software-properties-common'
  ubuntu_spacewalk_package2 = 'apt-transport-spacewalk'
  ubuntu_spacewalk_package3 = 'rhnsd'
  ubuntu_spacewalk_package4 = 'python-libxml2'
  subsystem_directory = '/var/lock/subsys'
  osad_repository = 'osad_repository'
  spool_directory = '/var/spool/rhn'
  repo_require_ubuntu = "[Apt::Ppa[#{spacewalk_repository}]{:name=>\"#{spacewalk_repository}\"}, Apt::Ppa[#{osad_repository}]{:name=>\"#{osad_repository}\"}, File[#{subsystem_directory}]{:path=>\"#{subsystem_directory}\"}, File[#{spool_directory}]{:path=>\"#{spool_directory}\"}]"
  spacewalk_repo_channels_12 = 'precise precise-updates precise-security'
  spacewalk_repo_channels_14 = 'trusty trusty-updates trusty-security'
  spacewalk_poll_interval = '120'
  osad_service = 'osad_fake'
  action_require = 'Exec[register_spacewalk_client]'
  osad_repository_release = 'bob'
  osad_repository_config_file = '/tmp/config.me'
  osad_logrotate_file = '/tmp/osad'
  osad_logrotate_perms = '0600'

  
  context "Should fail for unsupported CentOS version" do
    let(:facts) { {
      :operatingsystem => "CentOS",
      :operatingsystemmajrelease => fail_operatingsystemrelease
      } }
    let(:params) { {
      :spacewalk_server_address => spacewalk_server_address,
      :spacewalk_activation_key => spacewalk_activation_key,
      :spacewalk_certificate_url => spacewalk_certificate_url,
      } }
    
    it do
      should compile.and_raise_error(/spacewalk_client - Unsupported RHEL\/CentOS Version: #{fail_operatingsystemrelease}/)
    end
  end

  context "Should fail for unsupported Ubuntu version" do
    let(:facts) { {
      :operatingsystem => "Ubuntu",
      :operatingsystemmajrelease => fail_operatingsystemrelease
      } }
    let(:params) { {
      :spacewalk_server_address => spacewalk_server_address,
      :spacewalk_activation_key => spacewalk_activation_key,
      :spacewalk_certificate_url => spacewalk_certificate_url,
      } }
    
    it do
      should compile.and_raise_error(/spacewalk_client - Unsupported Ubuntu Version: #{fail_operatingsystemrelease}/)
    end
  end

  context "Should fail for unsupported OS" do
    let(:facts) { {
      :operatingsystem => fail_operatintsystem,
      :operatingsystemmajrelease => operatingsystemmajrelease_centos
      } }
    let(:params) { {
      :spacewalk_server_address => spacewalk_server_address,
      :spacewalk_activation_key => spacewalk_activation_key,
      :spacewalk_certificate_url => spacewalk_certificate_url,
      } }
    
    it do
      should compile.and_raise_error(/Unsupported Operating System: #{fail_operatintsystem}/)
    end
  end


  context "Should fail for Unparsable operatingsystemmajrelease:" do
    let(:facts) { {
      :operatingsystem => "Ubuntu",
      :operatingsystemmajrelease => ''
      } }
    let(:params) { {
      :spacewalk_server_address => spacewalk_server_address,
      :spacewalk_activation_key => spacewalk_activation_key,
      :spacewalk_certificate_url => spacewalk_certificate_url,
      } }
    
    it do
      should compile.and_raise_error(/Unparsable \$::operatingsystemmajrelease:/)
    end
  end

  context "Should register spacewalk client on Redhat" do
    let(:facts) { {
      :operatingsystem => "RedHat",
      :operatingsystemmajrelease => operatingsystemmajrelease_centos
      } }
    let(:params) { {
      :spacewalk_repository_gpg => spacewalk_repository_gpg,
      :spacewalk_repository_name => spacewalk_repository_name,
      :spacewalk_repository => spacewalk_repository,
      :spacewalk_certificate_url => spacewalk_certificate_url,
      :local_certificate_folder => local_certificate_folder,
      :spacewalk_server_protocol => spacewalk_server_protocol,
      :spacewalk_server_address => spacewalk_server_address,
      :spacewalk_server_uri => spacewalk_server_uri,
      :local_certificate_file => local_certificate_file,
      :spacewalk_activation_key => spacewalk_activation_key,
      :spacewalk_poll_interval => spacewalk_poll_interval
      } }
    
    it do
      should contain_yumrepo(spacewalk_repository_name).with(
          'gpgcheck' => 1,
          'baseurl' => spacewalk_repository,
          'enabled' => 1,
          'gpgkey' => spacewalk_repository_gpg
      )
      should contain_package(centos_spacewalk_package1).with(
        'ensure'  => 'installed',
        'require' => repo_require_centos
      )
      should contain_package(centos_spacewalk_package2).with(
        'ensure'  => 'installed',
        'require' => repo_require_centos
      )
      should contain_package(centos_spacewalk_package3).with(
        'ensure'  => 'installed',
        'require' => repo_require_centos
      )
      should contain_package(centos_spacewalk_package4).with(
        'ensure'  => 'installed',
        'require' => repo_require_centos
      )
      should contain_package(centos_spacewalk_package5).with(
        'ensure'  => 'installed',
        'require' => repo_require_centos
      )
      should contain_package(centos_spacewalk_package6).with(
        'ensure'  => 'installed',
        'require' => repo_require_centos
      )
      should contain_package(centos_spacewalk_package7).with(
        'ensure'  => 'installed',
        'require' => repo_require_centos
      )
      should contain_package(centos_spacewalk_package8).with(
        'ensure'  => 'installed',
        'require' => repo_require_centos
      )
      should contain_exec('get_spacewalk_certificate').with(
          'command' => "wget #{spacewalk_certificate_url} -P #{local_certificate_folder}"
      )
      should contain_exec('register_spacewalk_client').with(
          'command' => "rhnreg_ks #{default_force_registration} --serverUrl=#{spacewalk_server_protocol}://#{spacewalk_server_address}/#{spacewalk_server_uri} --sslCACert=#{local_certificate_folder}/#{local_certificate_file} --activationkey=#{spacewalk_activation_key}"
      )
    end
  end

  context "Should register spacewalk client on Ubuntu 12" do
    let(:facts) { {
      :operatingsystem => "Ubuntu",
      :osfamily => "Debian",
      :lsbdistid => 'Ubuntu',
      :operatingsystemmajrelease => '12.04',
      :lsbdistrelease => '12.04',
      :lsbdistcodename => 'precise',
      :puppetversion => Puppet.version
      } }
    let(:params) { {
      :spacewalk_repository_gpg => spacewalk_repository_gpg,
      :spacewalk_repository_name => spacewalk_repository_name,
      :spacewalk_repository => spacewalk_repository,
      :spacewalk_certificate_url => spacewalk_certificate_url,
      :local_certificate_folder => local_certificate_folder,
      :spacewalk_server_protocol => spacewalk_server_protocol,
      :spacewalk_server_address => spacewalk_server_address,
      :spacewalk_server_uri => spacewalk_server_uri,
      :local_certificate_file => local_certificate_file,
      :spacewalk_activation_key => spacewalk_activation_key,
      :spacewalk_poll_interval => spacewalk_poll_interval,
      :osad_repository => osad_repository
      } }
    
    it do
      should_not contain_package(spacewalk_repository_package).with(
          'ensure'   => 'installed',
          'source'   => spacewalk_repository,
          'provider' => 'rpm',
      )
      should contain_apt__ppa(spacewalk_repository)
      should contain_apt__ppa(osad_repository)
      should contain_file(subsystem_directory).with(
          'ensure' => 'directory'
      )
      should contain_file(spool_directory).with(
          'ensure' => 'directory'
      )
      should contain_package(ubuntu_spacewalk_package1).with(
        'ensure'  => 'installed',
        'require' => repo_require_ubuntu
      )
      should contain_package(ubuntu_spacewalk_package2).with(
        'ensure'  => 'installed',
        'require' => repo_require_ubuntu
      )
      should contain_package(ubuntu_spacewalk_package3).with(
        'ensure'  => 'installed',
        'require' => repo_require_ubuntu
      )
      should contain_package(ubuntu_spacewalk_package4).with(
        'ensure'  => 'installed',
        'require' => repo_require_ubuntu
      )
      should contain_exec('get_spacewalk_certificate').with(
          'command' => "wget #{spacewalk_certificate_url} -P #{local_certificate_folder}"
      )
      should contain_exec('register_spacewalk_client').with(
          'command' => "rhnreg_ks #{default_force_registration} --serverUrl=#{spacewalk_server_protocol}://#{spacewalk_server_address}/#{spacewalk_server_uri} --sslCACert=#{local_certificate_folder}/#{local_certificate_file} --activationkey=#{spacewalk_activation_key}"
      )
      should contain_file('/etc/apt/sources.list.d/spacewalk.list').with(
            'ensure'  => 'present',
            'content' => "deb spacewalk://#{spacewalk_server_address} channels: #{spacewalk_repo_channels_12}\n",
      )

      should contain_file('/etc/apt/apt.conf.d/00spacewalk').with(
            'ensure'  => 'present',
            'content' => "Acquire::Pdiffs \"false\";\n",
      )
    end
  end

  context "Should register spacewalk client on Ubuntu 14" do
    let(:facts) { {
      :operatingsystem => "Ubuntu",
      :osfamily => "Debian",
      :lsbdistid => 'Ubuntu',
      :operatingsystemmajrelease => '14.04',
      :lsbdistrelease => '14.04',
      :lsbdistcodename => 'trusty',
      :puppetversion => Puppet.version
      } }
    let(:params) { {
      :spacewalk_repository_gpg => spacewalk_repository_gpg,
      :spacewalk_repository_name => spacewalk_repository_name,
      :spacewalk_repository => spacewalk_repository,
      :spacewalk_certificate_url => spacewalk_certificate_url,
      :local_certificate_folder => local_certificate_folder,
      :spacewalk_server_protocol => spacewalk_server_protocol,
      :spacewalk_server_address => spacewalk_server_address,
      :spacewalk_server_uri => spacewalk_server_uri,
      :local_certificate_file => local_certificate_file,
      :spacewalk_activation_key => spacewalk_activation_key,
      :osad_repository => osad_repository,
      :osad_repository_release => osad_repository_release,
      :osad_repository_config_file => osad_repository_config_file
      } }
    
    it do
      should_not contain_package(spacewalk_repository_package).with(
          'ensure'   => 'installed',
          'source'   => spacewalk_repository,
          'provider' => 'rpm',
      )
      should contain_apt__ppa(spacewalk_repository)
      should contain_apt__ppa(osad_repository)
      should contain_exec('modify_osad_repository').with(
        'command' => "sed -i 's#/ubuntu.*main#/ubuntu #{osad_repository_release} main#g' #{osad_repository_config_file}",
        'require' => "Apt::Ppa[#{osad_repository}]",
        'before'  => "File[#{subsystem_directory}]"
      )
      should contain_file(subsystem_directory).with(
          'ensure' => 'directory'
      )
      should contain_file(spool_directory).with(
          'ensure' => 'directory'
      )
      should contain_file(subsystem_directory).with(
          'ensure' => 'directory'
      )
      should contain_package(ubuntu_spacewalk_package1).with(
        'ensure'  => 'installed',
        'require' => repo_require_ubuntu
      )
      should contain_package(ubuntu_spacewalk_package2).with(
        'ensure'  => 'installed',
        'require' => repo_require_ubuntu
      )
      should contain_package(ubuntu_spacewalk_package3).with(
        'ensure'  => 'installed',
        'require' => repo_require_ubuntu
      )
      should contain_package(ubuntu_spacewalk_package4).with(
        'ensure'  => 'installed',
        'require' => repo_require_ubuntu
      )
      should contain_exec('get_spacewalk_certificate').with(
          'command' => "wget #{spacewalk_certificate_url} -P #{local_certificate_folder}"
      )
      should contain_exec('register_spacewalk_client').with(
          'command' => "rhnreg_ks #{default_force_registration} --serverUrl=#{spacewalk_server_protocol}://#{spacewalk_server_address}/#{spacewalk_server_uri} --sslCACert=#{local_certificate_folder}/#{local_certificate_file} --activationkey=#{spacewalk_activation_key}"
      )
      should contain_file('/etc/apt/sources.list.d/spacewalk.list').with(
            'ensure'  => 'present',
            'content' => "deb spacewalk://#{spacewalk_server_address} channels: #{spacewalk_repo_channels_14}\n",
      )

      should contain_file('/etc/apt/apt.conf.d/00spacewalk').with(
            'ensure'  => 'present',
            'content' => "Acquire::Pdiffs \"false\";\n",
      )
    end
  end

  context "Should install osad on Redhat with all actions disabled" do
    let(:facts) { {
      :operatingsystem => "RedHat",
      :operatingsystemmajrelease => operatingsystemmajrelease_centos
      } }
    let(:params) { {
      :spacewalk_repository_gpg => spacewalk_repository_gpg,
      :spacewalk_repository_name => spacewalk_repository_name,
      :spacewalk_repository => spacewalk_repository,
      :spacewalk_certificate_url => spacewalk_certificate_url,
      :local_certificate_folder => local_certificate_folder,
      :spacewalk_server_protocol => spacewalk_server_protocol,
      :spacewalk_server_address => spacewalk_server_address,
      :spacewalk_server_uri => spacewalk_server_uri,
      :local_certificate_file => local_certificate_file,
      :spacewalk_activation_key => spacewalk_activation_key,
      :spacewalk_poll_interval => spacewalk_poll_interval,
      :install_osad => true,
      :osad_packages => centos_osad_package,
      :osad_service => osad_service,
      :allow_deploy_action => false,
      :allow_diff_action => false,
      :allow_upload_action  => false,
      :allow_mtime_upload_action => false,
      :allow_run_action  => false,
      :osad_logrotate_file => osad_logrotate_file,
      :osad_logrotate_perms => osad_logrotate_perms
      } }
    
    it do
      should contain_package(centos_osad_package).with(
        'ensure'  => 'installed',
        'require' => repo_require_centos
      )
      should contain_service(osad_service).with(
        'ensure' => 'running',
        'enable' => 'true'
      )
      should contain_exec('update_spacewalk_action_control').with(
        'command' => "rhn-actions-control --disable-deploy --disable-diff --disable-upload --disable-mtime-upload --disable-run -f",
        'require' => action_require
      )
      should contain_file(osad_logrotate_file).with('mode' => osad_logrotate_perms)
    end
  end

 context "Should install osad on Redhat with all actions enabled" do
    let(:facts) { {
      :operatingsystem => "RedHat",
      :operatingsystemmajrelease => operatingsystemmajrelease_centos
      } }
    let(:params) { {
      :spacewalk_repository_gpg => spacewalk_repository_gpg,
      :spacewalk_repository_name => spacewalk_repository_name,
      :spacewalk_repository => spacewalk_repository,
      :spacewalk_certificate_url => spacewalk_certificate_url,
      :local_certificate_folder => local_certificate_folder,
      :spacewalk_server_protocol => spacewalk_server_protocol,
      :spacewalk_server_address => spacewalk_server_address,
      :spacewalk_server_uri => spacewalk_server_uri,
      :local_certificate_file => local_certificate_file,
      :spacewalk_activation_key => spacewalk_activation_key,
      :spacewalk_poll_interval => spacewalk_poll_interval,
      :install_osad => true,
      :osad_packages => centos_osad_package,
      :osad_service => osad_service,
      :allow_deploy_action => true,
      :allow_diff_action => true,
      :allow_upload_action  => true,
      :allow_mtime_upload_action => true,
      :allow_run_action  => true,
      :osad_logrotate_file => osad_logrotate_file,
      :osad_logrotate_perms => osad_logrotate_perms
      } }
    
    it do
      should contain_package(centos_osad_package).with(
        'ensure'  => 'installed',
        'require' => repo_require_centos
      )
      should contain_service(osad_service).with(
        'ensure' => 'running',
        'enable' => 'true'
      )
      should contain_exec('update_spacewalk_action_control').with(
        'command' => "rhn-actions-control --enable-deploy --enable-diff --enable-upload --enable-mtime-upload --enable-run -f",
        'require' => action_require
      )
      should contain_file(osad_logrotate_file).with('mode' => osad_logrotate_perms)
    end
  end

end

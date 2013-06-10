#!/usr/bin/env bats

setup() {
  export PATH="/opt/chef/embedded/bin:$PATH"
  KITCHEN="/tmp/kitchen-chef-solo/cookbooks/virtualbox"

  prepare_kitchen
}

prepare_kitchen() {
  apt-get install -qy build-essential libxml2-dev libxslt1-dev

  pushd "$KITCHEN"
  bundle install
  # dot-files are not uploaded to the VM, so we have to generate .kitchen.yml
  generate_kitchen_yml
  popd
}

generate_kitchen_yml() {
  cat > ".kitchen.yml" <<-EOS
	---
	driver_plugin: vagrant

	platforms:
	- name: ubuntu-12.04
	  driver_config:
	    provider: virtualbox
	    box: canonical-ubuntu-12.04-i386
	    box_url: http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-i386-vagrant-disk1.box
	    require_chef_omnibus: true

	suites:
	- name: default
	  run_list:
	  - recipe[virtualbox]
	  - recipe[vagrant]
	  attributes:
	    vagrant:
	      url: http://files.vagrantup.com/packages/7e400d00a3c5a0fdf2809c8b5001a035415a607b/vagrant_1.2.2_i686.deb
	      plugins:
	      - vagrant-berkshelf
	EOS
}

@test "runs test-kitchen" {
  pushd "$KITCHEN"
  run kitchen test
  popd
  [ $status -eq 0 ]
}

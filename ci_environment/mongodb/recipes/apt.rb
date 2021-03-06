# -*- coding: utf-8 -*-
#
# Cookbook Name:: mongodb
# Recipe:: apt
#
# Author:: Michael Strüder (<mikezter@ryoukai.org>)
#
# Copyright 2011, Active Prospect, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node.set[:mongodb][:installed_from] = "apt"
# default settings from apt repo
node.set[:mongodb][:datadir]     = "/var/lib/mongodb"
node.set[:mongodb][:config]      = "/etc/mongodb.conf"
node.set[:mongodb][:logfile]     = "/var/log/mongodb/mongodb.log"
node.set[:mongodb][:pidfile]     = "/var/run/mongodb.pid"


execute "apt-get update" do
  action :nothing

  not_if "which mongod && which mongo"
end

execute "add 10gen apt key" do
  command "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10"
  action :nothing

  not_if "which mongod && which mongo"
end

# Note: hardcoded repo for SysV style init
cookbook_file "/etc/apt/sources.list.d/mongodb.list" do
  source 'mongodb.list'
  owner "root"
  mode "0644"
  notifies :run, resources(:execute => "add 10gen apt key"), :immediately
  notifies :run, resources(:execute => "apt-get update"), :immediately

  not_if "which mongod && which mongo"
end

package "mongodb-10gen" do
  action :install
  not_if "which mongod && which mongo"
end

cookbook_file "/etc/init.d/mongodb" do
  source "mongodb.sysvinit.sh"
  owner  "root"

  mode   0751
end

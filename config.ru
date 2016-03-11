# This file is used by Rack-based servers to start the application.

require 'coverband'
Coverband.configure

require ::File.expand_path('../config/environment',  __FILE__)
run Delve::Application

require 'librato-rack'
use Librato::Rack

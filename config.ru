# This file is used by Rack-based servers to start the application.
require 'sidekiq/web'
require 'sidekiq-scheduler/web'
require_relative 'config/environment'
run Sidekiq::Web
run Rails.application

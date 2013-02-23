#!/usr/bin/env ruby -w

require 'rubygems'
require 'httparty'
require 'json'

credentials_path = File.expand_path('../credentials.json', __FILE__)

if File.exist? credentials_path
  credentials = JSON.parse File.open(credentials_path, 'r').read
else
  puts "Must supply an API key in credentials.json"
  exit
end

puts credentials

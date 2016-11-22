#!/usr/bin/env ruby

require 'erb'

PRODUCT_VERSION = ARGV[0]
SERVICE_BROKER_VERSION = ARGV[1]
SERVICE_ADAPTER_VERSION = ARGV[2]
SERVICE_RELEASE_VERSION = ARGV[3]
ERB_TEMPLATE_FILE = ARGV[4]

simple_template = File.read("#{ERB_TEMPLATE_FILE}")

renderer = ERB.new(simple_template)
puts output = renderer.result()

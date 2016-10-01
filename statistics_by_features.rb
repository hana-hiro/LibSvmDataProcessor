#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require './libsvmdata_reader.rb'
require './average_calculator.rb'

ARGV.each do |filename|
  sum = Hash.new{ |hash, key| hash[key] = 0.0 }
  squared_sum = Hash.new{ |hash, key| hash[key] = 0.0 }

  num_instances = 0
  read_libsvm_file(filename) do |label, instance_hash|
    instance_hash.each do |key, val|
      sum[key] += val
      squared_sum[key] += val * val
    end

    num_instances += 1
    STDERR.puts "#{filename}: Read #{num_instances} instances." if num_instances % 10000 == 0
  end
  STDERR.puts "#{filename}: Read #{num_instances} instances." if num_instances % 10000 != 0

  open("#{filename}.info", "w") do |infofile|
    sum.keys.sort.each do |key|
      average = sum[key] / num_instances
      infofile.puts "#{key} #{average} #{Math.sqrt(squared_sum[key] / num_instances - average**2)}"
    end
  end
end

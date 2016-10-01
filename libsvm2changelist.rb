#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require './libsvmdata_reader'

def main(file_del, file_ins)
  output = {}

  delcount = 0
  read_libsvm_file(file_del) do |label, instance_hash|
    instance_hash.each_pair do |key, val|
      output[[delcount, key-1]] = 0
    end
    delcount += 1
  end

  inscount = 0
  read_libsvm_file(file_ins) do |label, instance_hash|
    instance_hash.each_pair do |key, val|
      output[[inscount, key-1]] = val
    end
    inscount += 1
  end

  if delcount != inscount
    STDERR.puts "Error: The number of instances for the deletion and the insertion must be matched"
    exit
  end

  output.each_pair do |pos, val|
    puts "#{pos[0]},#{pos[1]},#{val}"
  end
end

main(*ARGV)

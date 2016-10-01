#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

def parse_libsvm_line(line)
  instance = line.split
  instance_hash = {}
  begin
    label = Float(instance.shift)
    instance.each do |elem|
      unless elem =~ /\A(\d+):/
        raise ArgumentError
      end
      feature_id = $1
      value = $' #'#
      instance_hash[Integer(feature_id)] = Float(value)
    end
  rescue ArgumentError
    raise ArgumentError, "Invalid instance format: #{line.inspect}"
  end

  [label, instance_hash]
end

def read_libsvm_file(filename)
  IO.foreach(filename) do |line|
    yield parse_libsvm_line(line)
  end
end

if $0 == __FILE__
  ARGV.each do |a|
    begin
      loaded_instances = 0
      read_libsvm_file(a) do |label, instance_hash|
        loaded_instances += 1
        puts "#{a}: #{loaded_instances} instances loaded" if loaded_instances % 10000 == 0
      end
      puts "#{a}: #{loaded_instances} instances loaded" if loaded_instances % 10000 != 0
    rescue Exception => e
      puts e
    else
      puts "#{a}: OK"
    end
  end
end

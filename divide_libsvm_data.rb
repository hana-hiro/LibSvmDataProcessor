#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# データをランダムに分割する。
# [Usage]
#   divide_data FILE N1 N2 N3...
# 
# FILEを N1:N2:N3:... の比率で分割し保存する。
# 例えば、divide_data mydata.lsvm 5 3 2 と指定した場合、
# 以下のことをファイルを全部読み込むまで繰り返す。
# - FILEの先頭から10行を読み込む（5+3+2=10）
# - うち5行を無作為抽出して mydata.div1.lsvm に書き込む
# - うち3行を無作為抽出して mydata.div2.lsvm に書き込む
# - うち2行を無作為抽出して mydata.div3.lsvm に書き込む

$: << File.dirname(__FILE__)
require 'libsvmdata_reader'

RANDOMIZED = true

if ARGV.size < 3
  STDERR.puts "Usage: divide_data FILE N1 N2 N3..."
  exit
end

file = ARGV[0]
counts = []

# Check counts
begin
  counts = ARGV[1..-1].map{ |a| Integer(a) }
  raise if counts.any?{ |a| a <= 0 }
rescue
  raise "Option error: numbers must be all positive integers" 
end

count_total = counts.inject{ |i, j| i + j }

# Check the largest feature ID
largest_key = -1
read_libsvm_file(file) do |label, instance_hash|
  if instance_hash.empty?
    STDERR.puts "Warning: instance with no value"
  else
    largest_key = [largest_key, instance_hash.keys.max].max
  end
end
STDERR.puts "The largest feature ID of file #{file} is #{largest_key}."
if largest_key == -1
  STDERR.puts "Error: largest_key not found"
  exit
end

if file =~ /\.[^\.\/]*\z/
  file_head = $`
  file_tail = $&
else
  file_head = file
  file_tail = ''
end

digits = (Math.log(counts.size + 0.5)/Math.log(10)).to_i + 1
outfiles = counts.each_index.map{ |i| open(sprintf("%s.div%0#{digits}d%s", file_head, i+1, file_tail), "w") }

kept_data = []
num_instances = 0
is_first_trial = counts.map{ true }

IO.foreach(file) do |line|
  kept_data << line
  if kept_data.size >= count_total
    kept_data.shuffle! if RANDOMIZED
    counts.each_with_index do |c, i|
      c.times do
        source = kept_data.pop
        if is_first_trial[i]
          # そのファイルに書き込むのが初めての場合、
          # 「特徴番号の最大値:0」という情報を書き込んでおく
          # （もしその特徴番号の値を持っていればその限りではない）。
          # ファイルが分かれても、もともとの特徴数がわかるように。
          is_first_trial[i] = false
          line_parsed = parse_libsvm_line(source)
          unless line_parsed[1].has_key?(largest_key)
            source_chomped = source.chomp
            newline = source[(source_chomped.length)..-1]
            source = "#{source_chomped} #{largest_key}:0#{newline}"
          end
        end
        outfiles[i] << source
      end
    end
  end
  num_instances += 1
  STDERR.puts "#{file}: Read #{num_instances} instances." if num_instances % 10000 == 0
end
STDERR.puts "#{file}: Read #{num_instances} instances." if num_instances % 10000 != 0

kept_data.shuffle!
counts.each_with_index do |c, i|
  c.times do
    break if kept_data.empty?
    outfiles[i] << kept_data.pop
  end
end

outfiles.each do |f|
  STDERR.puts "Closing the resulted file \"#{f.path}\" ..."
  f.close
end

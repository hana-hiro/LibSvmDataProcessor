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

RANDOMIZED = true

if ARGV.size < 3
  STDERR.puts "Usage: divide_data FILE N1 N2 N3..."
  exit
end

file = ARGV[0]
counts = []

begin
  counts = ARGV[1..-1].map{ |a| Integer(a) }
  raise if counts.any?{ |a| a <= 0 }
rescue
  raise "Option error: numbers must be all positive integers" 
end

count_total = counts.inject{ |i, j| i + j }

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
IO.foreach(file) do |line|
  kept_data << line
  if kept_data.size >= count_total
    kept_data.shuffle! if RANDOMIZED
    counts.each_with_index do |c, i|
      c.times do
        outfiles[i] << kept_data.pop
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

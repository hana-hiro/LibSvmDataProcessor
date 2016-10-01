#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# 桁落ちを回避しつつ平均を求めるためのクラス
# 要素をstorage_size個を上限に加算し、その個数になったときに初めて割る
class AverageCalculator
  def initialize(storage_size = 128)
    @storage_size = storage_size
    @tmp_sum = 0.0
    @tmp_count = 0
    @merged_average = 0.0
    @merged_count = 0
  end
  
  def <<(value)
    @tmp_sum += value
    @tmp_count += 1
    if @tmp_count >= @storage_size
      @merged_average = average
      @merged_count += @tmp_count
      @tmp_sum = 0.0
      @tmp_count = 0
    end
  end
  
  def average
    (@merged_average * @merged_count + @tmp_sum) / (@merged_count + @tmp_count)
  end
end

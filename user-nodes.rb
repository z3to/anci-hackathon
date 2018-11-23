#!/usr/bin/env ruby
# encoding: utf-8
Dir.chdir(File.dirname(__FILE__))

require "json"
require "csv"
require "awesome_print"

class DomainMap
  def setDomain(v)
    @minV = v[0].to_f
    @maxV = v[1].to_f
    self
  end

  def setRange(v)
    @minN = v[0].to_f
    @maxN = v[1].to_f
    self
  end

  def domainMap(v)
    v = v.to_f
    if (v <= @minV)
      @minN
    elsif (v >= @maxV)
      @maxN
    else
      (((@maxN - @minN) * ((v - @minV) / (@maxV - @minV))) + @minN).round(20)
    end
  end
end

data = JSON.parse(File.read('data/input/user.json'), symbolize_names: true)

minX = data.min_by { |el| el[:x] }[:x]
maxX = data.max_by { |el| el[:x] }[:x]
minY = data.min_by { |el| el[:y] }[:y]
maxY = data.max_by { |el| el[:y] }[:y]

ap [minX, maxX, minY, maxY]

scaleX = DomainMap.new.setDomain([minX / 3, maxX]).setRange([0, 1])
scaleY = DomainMap.new.setDomain([minY / 3, maxY]).setRange([0, 1])

CSV.open('data/output/user-nodes.csv', "w") do |row|
  row << ['id', 'label', 'count', 'x', 'y', 'data', 'group']
  data.each do |el|
    row << [el[:id], el[:label], 1, scaleX.domainMap(el[:x]), scaleY.domainMap(el[:y]), el[:data], el[:group]]
    # network[:nodes].push({
    #   :id => el[:id],
    #   :label => el[:label],
    #   :count => 2,
    #   :fx => el[:x],
    #   :fy => el[:y],
    #   :data => el[:data],
    #   :group => el['tag']
    # })
  end
end
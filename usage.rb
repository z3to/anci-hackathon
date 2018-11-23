#!/usr/bin/env ruby
# encoding: utf-8
Dir.chdir(File.dirname(__FILE__))

require "json"
require "csv"
require "awesome_print"
require 'date'

def readCSV (file)
  CSV.read("#{file}", { encoding: "UTF-8", headers: true }).map { |d| d.to_hash }
end

data = readCSV('data/input/instagram.csv')

hashtags = []
# dates = []

# row.each do |image|
# 	# dates.push(Date.strptime(image['created_time'], '%Y-%m-%d %H:%M:%S'))
# 	hashtags.push(*image['tags'].split(', ')) unless image['tags'].nil?
# end

# ap data

data.map! do |image|
	tags = image['tags'].nil? ? [] : image['tags'].split(', ')
	hashtags.push(*tags)
	{
		:tags => tags,
		:likes => image['no_likes'],
		:date => Date.strptime(image['created_time'], '%Y-%m-%d %H:%M:%S').strftime("%Y-%m-01")
	}
end

# ap data

# data.each do |image|
# 	# dates.push(Date.strptime(image['created_time'], '%Y-%m-%d %H:%M:%S'))
# 	hashtags.push(*image['tags'].split(', ')) unless image['tags'].nil?
# end

# ap dates.length
# ap dates.group_by { |i| i.strftime("%Y-%W") }.length

tags = []
hashtags.group_by { |i| i }.each do |tag, arr|
	tags.push({
		:size => arr.length,
		:tag => tag
	})
end

popular_tags = tags.select { |i| i[:size] > 70 }

ap popular_tags

events = []

popular_tags.each do |tag|
	data.each do |image|
		if image[:tags].include? tag[:tag]
			events.push({
				:date => image[:date],
				:likes => image[:likes],
				:tag => tag[:tag]
			})
		end
	end
end

CSV.open('data/output/events.csv', "w") do |row|
  row << ['tag', 'date', 'count']

	events.group_by { |i| i[:tag] }.each do |tag, dates|
		dates.group_by { |n| n[:date] }.each do |date, likes|
			ap likes
			number = likes.inject(0) { |sum, p| sum + Integer(p[:likes]) }
			row << [tag, date, number]
			ap "#{tag} #{date} #{number}"
		end
	end

end

# 	tags.each do |key, value|
# 		row << [key, value[:label], value[:size]]
# 	end
# end

# # COUNT HASHTAGS
# tags = Hash.new(0)

# tags_with_id = Hash.new(0)
# ids_with_tag = Hash.new(0)

# hashtags.group_by { |i| i }.each_with_index do |(tag, arr), index|
# 	tags_with_id[tag] = index
# 	ids_with_tag[index] = tag

# 	tags[index] = {
# 		:id => index,
# 		:label => tag,
# 		:size => arr.length
# 	}
# end

# CSV.open('data/output/nodes.csv', "w") do |row|
#   row << ['tag', 'label', 'count']
# 	tags.each do |key, value|
# 		row << [key, value[:label], value[:size]]
# 	end
# end

# ap tags_with_id
# ap ids_with_tag

# COUNT HASHTAGS END

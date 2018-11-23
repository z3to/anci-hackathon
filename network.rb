#!/usr/bin/env ruby
# encoding: utf-8
Dir.chdir(File.dirname(__FILE__))

require "json"
require "csv"
require "awesome_print"

def readCSV (file)
  CSV.read("#{file}", { encoding: "UTF-8", headers: true }).map { |d| d.to_hash }
end

network = {
	:nodes => [],
	:links => []
}

data = readCSV('data/input/instagram.csv')

hashtags = []

data.each do |image|
	hashtags.push(*image['tags'].split(', ')) unless image['tags'].nil?
end

# COUNT HASHTAGS
GLOABAL_TAGS = Hash.new(0)

tags_with_id = Hash.new(0)
ids_with_tag = Hash.new(0)

hashtags.group_by { |i| i }.each_with_index do |(tag, arr), index|
	tags_with_id[tag] = index
	ids_with_tag[index] = tag

	GLOABAL_TAGS[index] = {
		:id => index,
		:label => tag,
		:size => arr.length
	}
end

CSV.open('data/output/nodes.csv', "w") do |row|
  row << ['tag', 'label', 'count']
	GLOABAL_TAGS.each do |key, value|
		# network[:nodes].push({ :id => "#{key}", :label => value[:label], :size => value[:size], :group => 1})
		row << [key, value[:label], value[:size]]
	end
end

# ap GLOABAL_TAGS

# ap tags_with_id
# ap ids_with_tag

# COUNT HASHTAGS END

# BUILD HASHTAG NETWORK

links = []

data.each do |image|
	unless image['tags'].nil?
		pairs = []
		tags = image['tags'].split(', ')
		tags.each do |source|
			source_id = tags_with_id[source]
			tags.each do |target|
				target_id = tags_with_id[target]
				pairs.push([source_id, target_id]) unless source_id === target_id
			end
		end
		pairs.uniq { |pair| pair.sort.join(',') }
		links.push(*pairs)
	end
end

edges = Hash.new(0)

links.group_by { |i| i.sort.join(',') }.each do |edge, arr|
	edges[edge] = arr.length
end

useful_edges = edges.select { |key, value| value > 2 }

networked_nodes = useful_edges.map do |key, value|
	key.split(',')
end.flatten.uniq

# ap networked_nodes
# ap GLOABAL_TAGS

GLOABAL_TAGS.each do |key, value|
	# ap "#{key}"
	network[:nodes].push({ :id => "#{key}", :label => value[:label], :size => value[:size], :group => 1}) if networked_nodes.include? "#{key}"
end

# ap edges.length
# ap useful_edges.length

CSV.open('data/output/edges.csv', "w") do |row|
  row << ['source', 'target', 'weight']
	useful_edges.each do |key, value|
		parts = key.split(',')
		source = parts[0]
		target = parts[1]
		network[:links].push({ :source => source, :target => target, :value => value})
		row << [*key.split(','), value]
	end
end

# ap edges

File.open('data/output/network.json', 'w') do |f|
  f.write(JSON.pretty_generate(network))
end

# BUILD HASHTAG NETWORK END

# BUILD USER NODES

user = data.select { |item| ["348550915", "1561110271", "1682880966", "43947917", "1484936442"].include? item["user_id"] }

CSV.open('data/output/user-nodes.csv', "w") do |row|
  row << ['id', 'label', 'count', 'x', 'y', 'data', 'group']
	user.each do |value|
		row << [value["id"], value["user_name"], 0, 0, 0, value["created_time"], 'user']
	end
end

ap networked_nodes

CSV.open('data/output/user-edges.csv', "w") do |row|
  row << ['source', 'target', 'weight']
	user.each do |value|
		unless value['tags'].nil?
			tags = value['tags'].split(', ')
			tags.each do |tag|
				if networked_nodes.include? "#{tags_with_id[tag]}"
					row << [value["id"], tags_with_id[tag], 1]
				end
			end
		end
	end
end

# BUILD USER NODES END
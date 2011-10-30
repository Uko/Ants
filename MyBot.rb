$:.unshift File.dirname($0)
require 'ants.rb'

ai=AI.new
$unseen=[]

ai.setup do |ai|
	ai.rows.each do |row|
    ai.cols.each do |col|
      $unseen.push [row,col]
    end
  end
end

def distance from, to
  #calculate the closest distance between to locations'
  d_col = [(from.col - to.col).abs, from.ai.cols - (from.col - to.col).abs].min
  d_row = [(from.row - to.row).abs, from.ai.rows - (from.row - to.row).abs].min
  d_row + d_col
end

def direction from, to
  halfRow=from.ai.rows/2
  halfColumn=from.ai.cols/2
    d = []
    if from.row < to.row
      if to.row - from.row >= halfRow
        d.push :N
      end
      if to.row - from.row <= halfRow
        d.push :S
      end
    end
    if to.row < from.row
      if from.row - to.row >= halfRow
        d.push :S
      end
      if from.row - to.row <= halfRow
        d.push :N
      end
    end
    if from.col < to.col
      if to.col - from.col >= halfColumn
        d.push :W
      end
      if to.col - from.col <= halfColumn
        d.push :E
      end
    end
    if to.col < from.col
      if from.col - to.col >= halfColumn
        d.push :E
      end
      if from.col - to.col <= halfColumn
        d.push :W
      end
    end
    d
end

def move! ant, direction
  destination=ant.square.neighbor(direction)
  if destination.land? && !$moves.key?(destination) && !destination.ant?
    $moves[destination]=ant
    ant.order direction
    true
  else
    false
  end
end

def moveToLocation ant, location
  directions = direction(ant.square,location)
  directions.each do |dir|
    if move!(ant, dir)
      return true
    end
  end
  false
end

ai.run do |ai|
	# your turn code here
	$moves={}
	$targets={}
	distances=[]
	ai.hills.each do |hill|
	  $moves[hill]=nil
	end
	#fing distances between each food and ant
	ai.food.each do |snack|
	  ai.my_ants.each do |ant|
		  dist=distance(ant.square,snack)
		  distances.push({:dist => dist, :ant => ant, :loc => snack})
    end
  end
	distances.sort!{|x, y| x[:dist]<=>y[:dist]}
	#puts distances
	distances.each do |i|
		if !$targets.key?(i[:loc]) && !$targets.value?(i[:ant])
		  if moveToLocation(i[:ant],i[:loc])
		    $targets[i[:loc]]=i[:ant]
		  end
		end
	end
	ai.hills.each do |hill|
	  if hill.ant? && hill.ant.owner=0 && !$moves.value?(hill.ant)
	    [:N, :E, :S, :W].each do |dir|
	      if move!(hill.ant, dir)
          break
        end
	    end
	  end
	end
end
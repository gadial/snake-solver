class Array
	def sum
		self.inject(0){|sum, x| sum+x}
	end
end

def switch_values(current_value,values)
	return values[(values.index(current_value)+1) % values.length]
end
#my snake's signature
$StandardSignature=[3,2,1,2,1,2,3,1,2,2,1,3,1,3]
class SnakeSquare
	attr_accessor :color, :crucial, :coords, :spin
	def initialize(color, crucial, coords, spin)
		self.color=color
		self.crucial=crucial
		self.coords=coords.dup
		self.spin=spin
	end
	def inspect
		"#{coords.inspect}, #{color.inspect}"
	end
end

class Snake
# a Snake's "signature" is a description of the snake when placed on 2d with the following
# rule: for every square, it's next neighbor in the snake is either up to left
# the signaure states exactly how many square are there in any row
	attr_accessor :signature, :squares
	def initialize(signature)
		self.signature=signature
		self.squares=[]

		current_color=:green
		current_coords=[0,0,0]
		self.signature.each do |squares_in_line|
			squares_in_line.times do |i|
				current_coords[0]+=1 unless i==0
				squares << SnakeSquare.new(current_color,true,current_coords,0)
				current_color=switch_values(current_color,[:green, :white])
			end
			current_coords[1]+=1
		end
	end
	def inspect
		self.squares.inject(""){|string, square| string+square.inspect+"\n"}
	end
end

def on_same_line(coord1, coord2)
#to be on the same line, exactly two coordinates have to match
	coord_count=0
	3.times do |i|
		coord_count+=1 if coord1[i]==coord2[i]
	end
	return 2==coord_count
end

class PseudoSnake
#A snake represenation with minimal information and no spatial information
#Used for solving only, not for display
	attr_accessor :signature, :squares
	#there are two types of squares: joints and bridges.
	#bridges join two squares on the same lines, joints do not.
	def initialize(signature)
		self.signature=signature
		self.squares=[]
		
		temp_snake=Snake.new(signature)

		temp_snake.squares.length.times do |i|
			if i==0 or i==(temp_snake.squares.length-1)
				squares << :bridge
			else
				if on_same_line(temp_snake.squares[i-1].coords,temp_snake.squares[i+1].coords)
					squares << :bridge
				else
					squares << :joint
				end
			end			
		end
	end
	def inspect
		self.squares.inject(""){|string, square| string+square.inspect+"\n"}
	end
	
	def assemble
          def recurse(current_direction,current_squares)
                  return current_squares if self.squares.length==current_squares.length
                  current_square_number=current_squares.length-1
                  if self.squares[current_square_number]==:bridge
                          add_square(current_squares,current_direction)
                          return nil if (not_legal(current_squares))
                          return recurse(current_direction,current_squares)
                  else
                          possible_directions=remaining_directions(current_direction)
                          possible_directions.each do |direction|
                                  new_squares=current_squares.dup
                                  add_square(new_squares,direction)
                                  next if (not_legal(new_squares))
                                  result=recurse(direction,new_squares)
                                  return result if result != nil
                          end
                  end
                  return nil
          end

	current_direction=:positive_x
	current_squares=[[0,0,0]]
	result = recurse(current_direction,current_squares)
	return result
      end


end

def direction_to_coords(direction)
	case direction
		when :positive_x: return [0,1]
		when :negative_x: return [0,-1]
		when :positive_y: return [1,1]
		when :negative_y: return [1,-1]
		when :positive_z: return [2,1]
		when :negative_z: return [2,-1]

	end
end

def add_square(squares, direction)
	coord=direction_to_coords(direction)
	new_square=squares.last.dup
	new_square[coord[0]]+=coord[1]
	squares << new_square
end

def remaining_directions(direction)
	directions=[:positive_x, :negative_x, :positive_y, :negative_y, :positive_z, :negative_z]
	case direction
		when :positive_x, :negative_x: directions.delete(:positive_x); directions.delete(:negative_x)
                when :positive_y, :negative_y: directions.delete(:positive_y); directions.delete(:negative_y)
                when :positive_z, :negative_z: directions.delete(:positive_z); directions.delete(:negative_z)
	end
	return directions
end

def not_legal(squares, cube_size=3)
	#checking we are within the boarder
	3.times do |i|
		used_coords=squares.collect{|x| x[i]}.uniq
		return true if used_coords.length > cube_size
	end
	#checking we do not overlapse
	return true if squares.uniq.length != squares.length
	return false 
end

def each_possible_signature(size = 3)
	#Three basic criterions for signatures of snakes that MIGHT become a size x size x size cube:
	#1) Total number of squares = (size)^3
	#2) All entries between 1 and size.
	#3) No more than (size-2) consecutive 1 entries

	def recurse(current_signature, n, size)
		raise "n is smaller than 0: #{n}" if n<0
		if n==0
			yield(current_signature)
		end
		consecutive_ones_at_end=(current_signature.collect{|x| (x==1)?(1):(0)}.reverse.index(0)) || current_signature.length
		start_from=(consecutive_ones_at_end<size-2)?(1):(2)
		start_from.upto(size) do |i|
			break if i>n
			recurse(signatures, current_signature.dup << i, n-i,size)
		end
	end

	recurse([],size**3, size)
end

#snake=PseudoSnake.new([1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2])
snake=PseudoSnake.new([1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2])
#puts snake.inspect
puts snake.assemble.inspect
# File.open ("signatures") do |file|
#   temp_signature=file.readline
#   snake=PseudoSnake.new(temp_signature.to_array)
#   puts temp_signature if snake.assemble_snake != nil
# end
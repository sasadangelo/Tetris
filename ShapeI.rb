require 'gosu'

# ShapeI
#
# This class represents the I-Shape.
class ShapeI < Shape
    # An I-Shape has 2 rotation cycle, so it needs
    # to rotation to complete a cycle. 
    def initialize(game)
        super(game)
        @rotation_block = @blocks[1]
        @rotation_cycle = 2
    end
  
    # The x,y position of each block is adjusted according to
    # the shape position and size. The adjust is first applied 
    # assuming the shape is its first position. Then it is rotated.
    def get_blocks
        @blocks[0].x = @x
        @blocks[1].x = @x
        @blocks[2].x = @x
        @blocks[3].x = @x
        @blocks[0].y = @y
        @blocks[1].y = @blocks[0].y + @blocks[0].height
        @blocks[2].y = @blocks[1].y + @blocks[1].height
        @blocks[3].y = @blocks[2].y + @blocks[2].height
    
        apply_rotation
    
        @blocks.each { |block| block.color = 0xffb2ffff }
    end
end

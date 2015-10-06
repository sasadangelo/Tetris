require 'gosu'


# Block
#
# This class represents a simple block in Tetris game.
# All the pieces in the game (i.e. L Shape, Z Shape, Cube Shape and so on)
# are composed by blocks. For example, this is an example of L Shape where
# each X is a block:
#
#     X
#     X
#     X
#     X
#     XXXXXX
#
# The World is a grid where each cells is a block. Logically a block has a 1x1
# cells. Phisically, on a video windows, a block has its upper left corner in 
# x,y and its size is width and height that is fixed to 32x32 pixels.
class Block
    # True if the block is falling
    attr_accessor :falling
    # The block position, size and color.
    attr_accessor :x, :y, :width, :height, :color
  
    # The image of a block. It is a simple 32x32 pixel square white in color by default.
    @@image = nil
  
    def initialize(game)
        # The image is loaded only once for all blocks
        if @@image == nil
            @@image = Gosu::Image.new(game, "images/block.png", false) 
        end
    
        # The initial position of the block is 0, 0 and its size is
        # 32x32 pixel. The default colori is white.
        @x = 0
        @y = 0
        @width  = @@image.width;
        @height = @@image.height
        @game = game
        @color = 0xffffffff
    end

    # Draw the block
    def draw
        @@image.draw(@x, @y, 0, 1, 1, @color)
    end
  
    # Two blocks collide only when they are at the same position, since the world is a grid
    def collide(block)
        return (block.x == @x && block.y == @y)
    end
  
    # Check if this block collides with other block. The game objects has
    # a list of all the block currently present on video windows, so it is
    # sufficient scan them and check if one them collide with current block.
    # The method returns the first block found that collide with this one, nil
    # otherwise.
    def collide_with_other_blocks
        @game.blocks.each do |block|
            if collide(block)
                return block
            end
        end
        nil
    end
end

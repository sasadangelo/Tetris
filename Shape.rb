require 'gosu'
require './Block'

# Shape
#
# It is the base class for all the Tetris shapes (I-Shape, L-Shape, Z-Shape, Cube-Shape and so on).
class Shape
    attr_accessor :rotation
    
    def initialize(game)
        @game = game
        # A shape can move in two way:
        # 1. horizontally when user press left/right keys
        # 2. vertically when the shape falls
        #
        # Both the movement should occurs after a specific time. This is necessary
        # to avoid to have a game with object that moves like crazy.
        # Each horizontal movement should wait at least 100 ms.
        # Each vertical movement should wait a variable time that depends on:
        # 1. the game level: in this case the updateInterval is (500 - gamelevel*50) ms
        # 2. the user press down key: in this case the time is 100 ms
        @last_fall_update = Gosu::milliseconds 
        @last_move_update = Gosu::milliseconds 
    
        # All the shapes in Tetris are composed by 4 blocks:
        @blocks = [Block.new(game), Block.new(game), Block.new(game), Block.new(game) ]

        # All the shapes are positioned in upper-left corner and 
        # all of thems falls at the beginning. When the shape lay
        # on another shape the falling terminates.
        @x = @y = 0
        @falling = true
    
        # Each shape rotate around the second block (block[1]). The second
        # block represents the rotation axis.
        @rotation_block = @blocks[1]
        # How many rotations we can do before a full cycle? I-Shape requires
        # 2 rotations, L-Shape 4, T-Shape 4, Z-Shape 4.
        @rotation_cycle = 1
        # Current rotation state
        @rotation = 0
    end
  
    # This is the method that apply the rotation on the shape.
    def apply_rotation
        if @rotation_block != nil
            (1..@rotation.modulo(@rotation_cycle)).each do |i|
                @blocks.each do |block|
                    old_x = block.x
                    old_y = block.y
                    block.x = @rotation_block.x + (@rotation_block.y - old_y)
                    block.y = @rotation_block.y - (@rotation_block.x - old_x)
                end
            end
        end
    end
 
    # Note that the following function is defined properly only when the object is unrotated
    # Otherwise the line of symmetry will be misplaced and wrong results will be produced
    def reverse
        # Mirror the shape by the y axis, effectively creating shape counterparts such as 'L' and 'J'
        center = (get_bounds[2] + get_bounds[0]) / 2.0
        @blocks.each do |block|
            block.x = 2*center - block.x - @game.block_width
        end
    end
  
    # This method returns the minimum square that contains the shape.
    def get_bounds
        # Go throug all blocks to find the bounds of this shape
        x_min = []
        y_min = []
        x_max = []
        y_max = []
        @blocks.each do |block| 
            x_min << block.x
            y_min << block.y
      
            x_max << block.x + block.width
            y_max << block.y + block.height
        end

        return [x_min.min, y_min.min, x_max.max, y_max.max]
    end
 
    # This method returns true if the time passed from last fall movement of the shape 
    # (    Gosu::milliseconds - @last_fall_update) is > than updateInterval.
    # The updateInterval decrease with increase of game level and when user
    # press down key.
    def needs_fall_update?
        # updateInterval is 450 for level 1
        #                   400 for level 2
        #                   350 for level 3
        #             ...
        #                   100 for level 8
        # It is 100 if user press down key.
        if ( @game.button_down?(Gosu::KbDown) )
            updateInterval = 100
        else
            updateInterval = 500 - @game.level*50
        end
        # If the time passed from last update is > updateInterval then
        # an update is necessary and @last_fall_update is updated to current time.
        if ( Gosu::milliseconds - @last_fall_update > updateInterval )
            @last_fall_update = Gosu::milliseconds 
        end
    end
  
    # This method returns true if the time passed from last horizontal movement of the shape 
    # (    Gosu::milliseconds - @last_move_update) is > than 100 ms.
    def needs_move_update?
        if ( Gosu::milliseconds - @last_move_update > 100 )
            @last_move_update = Gosu::milliseconds 
        end
    end
  
    # Draw each block belonging to the shape.
    # Each block of the shape is adjusted to the
    # shape position (see get_blocks), then each block is drawn.
    def draw
        get_blocks.each { |block| block.draw }
    end

    # This method is used to update the shape when it falls
    def update
        # The update occurs only if the shape is falling. If it lays on other shapes
        # nothing happen
        if ( @falling ) 
            # After a movement or gravity update, we check if the moved shape collides with the world.
            # If it does, we restore its position to the last known good position.
            # This is the reason why the old position is kept.
            old_x = @x
            old_y = @y
      
            # Check if it is passed enough time to let the shape falls.
            # In this case @y is increased by 32 pixels.
            if needs_fall_update?
                @y = (@y + @game.block_height)
            end
      
            # We let the shape falls but if it collides the following occurs:
            # 1. the shape returns to the old position
            # 2. the falling process completes
            # 3. the game engine let a new shape to fall
            # 4. a check is done to verify if a line has been completed and then can be removed.
            if ( collide )
                @y = (old_y)
                @falling = false
                @game.spawn_next_shape
                @game.delete_lines_of(self)
            else  
                # If enough time is passed for an horizontal movement do the following:
                # 1. if user pressed left key update the x position moving the shape on the left.
                # 2. if user pressed right key update the x position moving the shape on the right.
                #
                # After the movement check if the shape collide with something else. If so,
                # recover its old x position.
                if needs_move_update?
                    if (@game.button_down?(Gosu::KbLeft))
                        @x =  (@x - @game.block_width)
                    end
                    if (@game.button_down?(Gosu::KbRight))
                        @x = ( @x + @game.block_width)
                    end
          
                    if ( collide )
                        @x = (old_x)
                    end 
                end  
            end
        end
    end
  
    # This method checks if the shape collide with something.
    # The method first scan all the 4 blocks to check if they collide
    # with another block in the game.
    # Then the method check also if the shape bounds collide with 
    # main windows.
    def collide
        # For each block of the shape, check if it collides with
        # another block in the game.
        get_blocks.each do |block|
            collision = block.collide_with_other_blocks;
            if (collision)
                return true
            end
        end

        # Check if the shape collide with main windows
        bounds = get_bounds
  
        if ( bounds[3] > @game.height )
            return true
        end
  
        if ( bounds[2] > @game.width )
            return true
        end
  
        if ( bounds[0] < 0 )
            return true
        end    
        return false
    end
end

require 'gosu'
require './Shape'
require './ShapeI'
require './ShapeL'
require './ShapeJ'
require './ShapeT'
require './ShapeS'
require './ShapeZ'
require './ShapeCube'

# TetrisGameWindow
#
# This class represents the main windows. It derives from Gosu::Window.
class TetrisGameWindow < Gosu::Window
    # blocks will contain the list of all the blocks present on the main window.
    attr_accessor :blocks
    attr_reader :block_height, :block_width
    attr_reader :level
    # In tetris one shap at a time will fall. This variable contains the falling shape.
    attr_reader :falling_shape

    STATE_PLAY = 1
    STATE_GAMEOVER = 2

    # Screen size in pixel. Since each Cell is 32x32 pixels we will have a
    # Grid of 10x20 Cells.
    WIDTH = 320 
    HEIGHT = 640

    def initialize
        super(WIDTH, HEIGHT, false)

        @block_width = 32
        @block_height = 32
    
        @blocks = []
    
        @state = STATE_PLAY
    
        spawn_next_shape
    
        @lines_cleared = 0
        @level = 0

        self.caption = "Tetris : #{@lines_cleared} lines"
        @song = Gosu::Song.new("sounds/TetrisB_8bit.ogg")
    end
    
    # update() is an overrides of Gosu::Window's update method. It is called 60 times 
    # per second (by default) and should contain the main game logic: move objects, 
    #handle collisions, etc.    
    def update
        # If the game is playing check if the current shape collide.
        # In this case the game is over.
        if ( @state == STATE_PLAY )
            if ( @falling_shape.collide )
                @state = STATE_GAMEOVER
            else
                @falling_shape.update
            end

            # Each 10 lines cleared the level advance by 1 and shape falls
            # quckly.
            @level = @lines_cleared / 10
            self.caption = "Tetris : #{@lines_cleared} lines"
        else 
            # If the game is over and user press space key another game is started.
            if ( button_down?(Gosu::KbSpace) )
                @blocks = []
                @falling_shape = nil
                @level = 0
                @lines_cleared = 0
                spawn_next_shape
                @state = STATE_PLAY
            end
        end
    
        # If user press ESC the game is finished.
        if ( button_down?(Gosu::KbEscape) )
            close
        end
        
        # The song is played.
        @song.play(true)
    end

    # draw() is an overrides of Gosu::Window's draw methods. It is called after update and 
    # whenever the window needs redrawing for other reasons, and may also be skipped every 
    # other time if the FPS go too low. It should contain the code to redraw the whole 
    # screen, but no updates to the game's state.
    def draw
        @blocks.each { |block| block.draw }
        @falling_shape.draw
    
        if @state == STATE_GAMEOVER
            text = Gosu::Image.from_text(self, "Game Over", "Arial", 40)
            text.draw(width/2 - 90, height/2 - 20, 0, 1, 1)
        end
    end    

    # When user press shape the falling shape is rotated.
    # If rotation cause a collision is does not occur and old value of rotation is recovered.
    def button_down(id)
        if ( id == Gosu::KbSpace && @falling_shape != nil )
            @falling_shape.rotation += 1
            if ( @falling_shape.collide )
                @falling_shape.rotation -= 1
            end
        end
    end
  
    # When the a shape finished to fall a new one must fall.
    # This function is used to generate a new shape that will be the
    # new falling shape.
    def spawn_next_shape
        # Spawn a random shape and add the current falling shape' blocks to the "static" blocks list
        if (@falling_shape != nil )
            # The blocks of the falling shape will be added
            # to the list of block present on the main window.
            @blocks += @falling_shape.get_blocks 
        end

        generator = Random.new
        shapes = [ShapeI.new(self), ShapeL.new(self), ShapeJ.new(self), ShapeCube.new(self), ShapeZ.new(self), ShapeT.new(self), ShapeS.new(self)]
        shape = generator.rand(0..(shapes.length-1))
        @falling_shape = shapes[shape]
    end
  
    # Given an y line on the screen this method says if it is complete.
    # A line is complete when we found WIDTH SCREEN/WIDTH BLOCK (320/32=10 items) on the line.
    def line_complete(y)
        # Important is that the screen resolution should be divisable by the block_width, otherwise there would be gap
        # If the count of blocks at a line is equal to the max possible blocks for any line - the line is complete
        i = @blocks.count{|item| item.y == y}
        if ( i == width / block_width )
            return true;
        end
        return false;
    end

    # When the falling shape completes its journey this method is called
    # to check if its block completes one or more lines.
    def delete_lines_of( shape )
        deleted_lines = []

        # Go through each block of the shape and check if the lines they are on are complete.
        # If so, the line of the block will be candidate for removal.
        shape.get_blocks.each do |block|
            if ( line_complete(block.y) )
                deleted_lines.push(block.y)
                # Remove from blocks all the block belonging to the same line.
                @blocks = @blocks.delete_if { |item| item.y == block.y }
            end
        end
    
        # @lines_cleared is increased by the number of lines deleted.
        @lines_cleared += deleted_lines.length

        # This applies the standard gravity found in classic Tetris games - all blocks go down by the 
        # amount of lines cleared
        @blocks.each do |block|
            i = deleted_lines.count{ |y| y > block.y }
            block.y += i*block_height
        end
    end
end

# Initializing and showing the main window
window = TetrisGameWindow.new
window.show
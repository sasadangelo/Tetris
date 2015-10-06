require 'gosu'
require './ShapeZ'

class ShapeS < ShapeZ
    def get_blocks
        # Reverse will reverse also the direction of rotation that's applied in apply_rotation
        # This will temporary disable rotation in the super method, so we can handle the rotation here after the reverse
        old_rotation = @rotation
        @rotation = 0  
    
        super
        reverse
    
        @rotation = old_rotation
        apply_rotation
    
        @blocks.each { |block| block.color = 0xff00ff00}
    end
end

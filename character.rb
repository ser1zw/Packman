#  -*- mode: ruby; coding: utf-8-unix -*- 

class Character
  AROUND_DXDY = [[0, 1], [-1, 0], [0, -1], [1, 0]]
  WALL = '#'

  attr_accessor :x, :y, :field, :time
  attr_accessor :prev_x, :prev_y
  
  def initialize(x, y, field)
    @x, @y, @field = x, y, field
    @time = 0
  end

  def move_to(x, y)
    update_position(x, y)
    @time += 1
  end

  def move
    @time += 1
  end

  def update_position(x, y)
    @prev_x, @prev_y = @x, @y
    @x, @y = x, y
  end

  def symbol
    throw 'symbol is not set'
  end

  def dup
    Marshal.load(Marshal.dump(self))
  end
end

class Packman < Character
  def symbol; '@'; end
end

class Enemy < Character
  def move
    if @time == 0
      first_move
    else
      next_move
    end
    super
  end

  # t = 0のときの動き
  def first_move
    AROUND_DXDY.each { |dx, dy|
      if @field[@y + dy][@x + dx] != WALL
        update_position(@x + dx, @y + dy)
        break
      end
    }
  end

  # t > 0のときの動き
  def next_move
    around = []
    AROUND_DXDY.each { |dx, dy| around << [@x + dx, @y + dy] if @field[@y + dy][@x + dx] != WALL }

    case around.size
    when 1
      update_position(*around[0])
    when 2
      unless (around[0][0] == @prev_x and around[0][1] == @prev_y)
        update_position(*around[0])
      else
        update_position(*around[1])
      end
    else
      crossroad_move
    end
  end

  # 交差点での動き
  def crossroad_move
  end

  def symbol; 'X'; end
end

class V < Enemy

  def initialize(x, y, field, packman)
    throw unless packman.is_a? Packman
    @packman = packman
    super(x, y, field)
  end

  def crossroad_move
    dx = @packman.x - @x
    dy = @packman.y - @y
    px = dx > 0 ? 1 : -1
    py = dy > 0 ? 1 : -1

    if dy != 0 and @field[@y + py][@x] != WALL
      update_position(@x, @y + py)
    elsif dx != 0 and @field[@y][@x + px] != WALL
      update_position(@x + px, @y)
    else
      first_move
    end
  end

  def symbol; 'V'; end
end

class H < V
  def crossroad_move
    dx = @packman.x - @x
    dy = @packman.y - @y
    px = dx > 0 ? 1 : -1
    py = dy > 0 ? 1 : -1
    
    if dx != 0 and @field[@y][@x + px] != WALL
      update_position(@x + px, @y)
    elsif dy != 0 and @field[@y + py][@x] != WALL
      update_position(@x, @y + py)
    else
      first_move
    end
  end

  def symbol; 'H'; end
end

class L < Enemy
  HALF_PI = Math::PI * 0.5

  def crossroad_move
    vec_x = @x - @prev_x
    vec_y = @y - @prev_y

    radius_list.each { |rad|
      next_x = @x + (vec_x * Math.cos(rad) - vec_y * Math.sin(rad)).to_i
      next_y = @y + (vec_x * Math.sin(rad) + vec_y * Math.cos(rad)).to_i

      if @field[next_y][next_x] != WALL
        update_position(next_x, next_y)
        break
      end
    }
  end

  def radius_list; [-HALF_PI, 0, HALF_PI]; end
  def symbol; 'L'; end
end

class R < L
  def radius_list; [HALF_PI, 0, -HALF_PI]; end
  def symbol; 'R'; end
end

class J < L
  def initialize(x, y, field)
    @which_action = 0
    super(x, y, field)
  end

  def radius_list
    rad_list = [[-HALF_PI, 0, HALF_PI], [HALF_PI, 0, -HALF_PI]][@which_action]
    @which_action ^= 1
    rad_list
  end
  
  def symbol; 'J'; end
end


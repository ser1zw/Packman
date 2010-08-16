#!/usr/bin/env ruby
#  -*- mode: ruby; coding: utf-8-unix -*- 
require 'test/unit'
require 'character'

class TestEnemy < Test::Unit::TestCase

  def set_to(character)
    character.field[character.y][character.x] = character.symbol
  end

  def puts_field(field)
    puts
    puts field.map { |row| row.join }.join("\n")
  end

  def setup
    @field1 = ['###########',
               '#         #',
               '#         #',
               '####      #',
               '#         #',
               '###########'].map { |l| l.split(//) }

    @field2 = ['#########',
               '#### ####',
               '#### ####',
               '#### ####',
               '#       #',
               '#### ####',
               '#### ####',
               '#### ####',
               '#########'].map { |l| l.split(//) }

    @field3 = ['###########',
               '#         #',
               '#         #',
               '#  #      #',
               '#         #',
               '#         #',
               '#         #',
               '###########'].map { |l| l.split(//) }

    @field4 = ['#######',
               '### ###',
               '### ###',
               '#     #',
               '### ###',
               '### ###',
               '#######'].map { |l| l.split(//) }

    @field5 = ['#####',
               '#   #',
               '## ##',
               '#####'].map { |l| l.split(//) }

    @field6 = ['#######',
               '### ###',
               '#     #',
               '### ###',
               '#     #',
               '### ###',
               '#######'].map { |l| l.split(//) }

    @field7 = ['###########',
               '#    #    #',
               '# ##   ## #',
               '# #  #    #',
               '# # ### # #',
               '#         #',
               '###########'].map { |l| l.split(//) }

  end

  def test_time0
    # Down
    x, y = 4, 2
    e = Enemy.new(x, y, @field1)
    e.move
    assert_equal([x, y + 1], [e.x, e.y])
    
    # Left
    x, y = 3, 2
    e = Enemy.new(x, y, @field1)
    e.move
    assert_equal([x - 1, y], [e.x, e.y])

    # Up
    x, y = 1, 2
    e = Enemy.new(x, y, @field1)
    e.move
    assert_equal([x, y - 1], [e.x, e.y])

    # Right
    x, y = 1, 4
    e = Enemy.new(x, y, @field1)
    e.move
    assert_equal([x + 1, y], [e.x, e.y])
  end

  def test_deadend
    x, y = 4, 1
    e = Enemy.new(x, y, @field2)
    e.time = 1
    e.move
    assert_equal([x, y + 1], [e.x, e.y])

    x, y = 1, 4
    e = Enemy.new(x, y, @field2)
    e.time = 1
    e.move
    assert_equal([x + 1, y], [e.x, e.y])

    x, y = 4, 7
    e = Enemy.new(x, y, @field2)
    e.time = 1
    e.move
    assert_equal([x, y - 1], [e.x, e.y])

    x, y = 7, 4
    e = Enemy.new(x, y, @field2)
    e.time = 1
    e.move
    assert_equal([x - 1, y], [e.x, e.y])
  end

  def test_aisle
    x, y = 4, 1
    e = Enemy.new(x, y, @field2)
    e.move
    e.move
    assert_equal([x, y + 2], [e.x, e.y])

    x, y = 1, 4
    e = Enemy.new(x, y, @field2)
    e.move
    e.move
    assert_equal([x + 2, y], [e.x, e.y])

    x, y = 4, 7
    e = Enemy.new(x, y, @field2)
    e.move
    e.move
    assert_equal([x, y - 2], [e.x, e.y])

    x, y = 7, 4
    e = Enemy.new(x, y, @field2)
    e.move
    e.move
    assert_equal([x - 2, y], [e.x, e.y])
  end

  def test_crossroad_move_v
    packman = Packman.new(2, 1, @field3)
    packman.move_to(2, 2)
    set_to(packman)

    # dy != 0 and field[y + dy][x] != '#'
    x, y = 3, 6
    v = V.new(x, y, @field3, packman)
    v.move_to(x, y - 1)
    v.move
    assert_equal([x, y - 2], [v.x, v.y])

    # dy == 0 and field[y][x + dx] != '#'
    x, y = packman.x + 3, packman.y
    v = V.new(x, y, @field3, packman)
    v.move_to(x - 1, y)
    v.move
    assert_equal([x - 2, y], [v.x, v.y])

    # dx != 0 and field[y][x + dx] != '#'
    x, y = 3, 5
    v = V.new(x, y, @field3, packman)
    v.move_to(x, y - 1)
    v.move
    assert_equal([x - 1, y - 1], [v.x, v.y])

    # dx == 0 and field[y + dy][x] != '#'
    x, y = packman.x, packman.y + 3
    v = V.new(x, y, @field3, packman)
    v.move_to(x, y - 1)
    v.move
    assert_equal([x, y - 2], [v.x, v.y])
  end
  
  def test_crossroad_move_h
    packman = Packman.new(2, 2, @field3)

    # dx != 0 and field[y][x + dx] != '#'
    x, y = 3, 5
    h = H.new(x, y, @field3, packman)
    h.move_to(x, y - 1)
    h.move
    assert_equal([x - 1, y - 1], [h.x, h.y])

    # dx == 0 and field[y + dy][x] != '#'
    x, y = packman.x, packman.y + 3
    h = H.new(x, y, @field3, packman)
    h.move_to(x, y - 1)
    h.move
    assert_equal([x, y - 2], [h.x, h.y])

    # dy != 0 and field[y + dy][x] != '#'
    x, y = 3, 6
    h = H.new(x, y, @field3, packman)
    h.move_to(x, y - 1)
    h.move
    assert_equal([x - 1, y - 1], [h.x, h.y])

    # dy == 0 and field[y][x + dx] != '#'
    x, y = packman.x + 3, packman.y
    h = H.new(x, y, @field3, packman)
    h.move_to(x - 1, y)
    h.move
    assert_equal([x - 2, y], [h.x, h.y])
  end

  def test_crossroad_move_l
    x, y = 3, 4
    l = L.new(x, y, @field4)
    l.move_to(x, y - 1)
    l.move
    assert_equal([x - 1, y - 1], [l.x, l.y])

    x, y = 2, 3
    l = L.new(x, y, @field4)
    l.move_to(x + 1, y)
    l.move
    assert_equal([x + 1, y - 1], [l.x, l.y])

    x, y = 3, 2
    l = L.new(x, y, @field4)
    l.move_to(x, y + 1)
    l.move
    assert_equal([x + 1, y + 1], [l.x, l.y])

    x, y = 4, 3
    l = L.new(x, y, @field4)
    l.move_to(x - 1, y)
    l.move
    assert_equal([x - 1, y + 1], [l.x, l.y])

    x, y = 1, 1
    l = L.new(x, y, @field5)
    l.move_to(x + 1, y)
    l.move
    assert_equal([x + 2, y], [l.x, l.y])

  end

  def test_crossroad_move_r
    x, y = 3, 4
    r = R.new(x, y, @field4)
    r.move_to(x, y - 1)
    r.move
    assert_equal([x + 1, y - 1], [r.x, r.y])

    x, y = 2, 3
    r = R.new(x, y, @field4)
    r.move_to(x + 1, y)
    r.move
    assert_equal([x + 1, y + 1], [r.x, r.y])

    x, y = 3, 2
    r = R.new(x, y, @field4)
    r.move_to(x, y + 1)
    r.move
    assert_equal([x - 1, y + 1], [r.x, r.y])

    x, y = 4, 3
    r = R.new(x, y, @field4)
    r.move_to(x - 1, y)
    r.move
    assert_equal([x - 1, y - 1], [r.x, r.y])

    x, y = 3, 1
    r = R.new(x, y, @field5)
    r.move_to(x - 1, y)
    r.move
    assert_equal([x - 2, y], [r.x, r.y])
  end

  def test_crossroad_move_j
    x, y = 2, 4
    j = J.new(x, y, @field6)
    j.move_to(x + 1, y)
    j.move
    assert_equal([x + 1, y - 1], [j.x, j.y])
    j.move_to(x + 1, y - 2)
    j.move
    assert_equal([x + 2, y - 2], [j.x, j.y])

    j.move_to(x + 2, y - 2)
    j.move_to(x + 1, y - 2)
    j.move
    assert_equal([x + 1, y - 1], [j.x, j.y])
  end

  def test_lv1
    packman = Packman.new(7, 5, @field7)
    packman.move_to(7, 4)

    v = V.new(6, 5, @field7, packman)
    v.dbg = true
    h = H.new(8, 5, @field7, packman)
    v.move_to(7, 5)
    h.move_to(7, 5)
    v.move
    h.move

    assert_equal([packman.x, packman.y], [v.x, v.y])
    assert_equal([packman.x, packman.y], [h.x, h.y])

  end
end



#!/usr/bin/ruby
# -*- mode: ruby; coding: utf-8-unix -*-
require "curses"
require 'character'

SPACE = ' '
DOT = '.'
WALL = '#'

def show(time, score, input_history, field)
  clear
  addstr "TIME: #{time}\tSCORE: #{score}\n"
  addstr "INPUT: #{input_history.join}\n"
  addstr "PRESS 'q' to quit, 'u' to undo\n"
  addstr field.map { |row| row.join }.join("\n")
  refresh
end

if ARGV.size == 0
  puts "USAGE: ruby #{__FILE__} input_file"
  exit
end

input = nil
open(ARGV[0], 'r') { |f| input = f.read.lines.map { |l| l.chomp } }
TIME_LIMIT = input.shift.to_i
WIDTH, HEIGHT = input.shift.split(/\s/).map { |x| x.to_i }
field = input.map { |l| l.split(//) }
dot_map = field.map { |row|
  row.map { |x| if x == DOT or x == WALL then x else SPACE end }
}

packman = nil
enemies = []
HEIGHT.times { |y|
  WIDTH.times { |x|
    case field[y][x]
    when '@'
      packman = Packman.new(x, y, field)
    when 'V', 'H'
      enemies << "#{field[y][x]}.new(#{x}, #{y}, field, packman)"
    when 'L', 'R', 'J'
      enemies << "#{field[y][x]}.new(#{x}, #{y}, field)"
    end
  }
}
enemies.map! { |x| eval x }

score = 0
time = TIME_LIMIT
include Curses
# init_screen

history_suffix = '_history'
input_history = []
packman_history = []
enemies_history = []
score_history = []
field_history = []
dot_map_history = []
gameover = false

begin
  show(time, score, input_history, field)
  while !gameover
    # 入力を受け取って
    c = getch.chr
    dx, dy = 0, 0
    case c
    when 'h'
      dx = -1
    when 'j'
      dy = 1
    when 'k'
      dy = -1
    when 'l'
      dx = 1
    when '.'
    when 'u'
      unless time == TIME_LIMIT
        input_history.pop
        %w(score packman enemies field dot_map).each { |obj_name|
          eval("#{obj_name} = #{obj_name}#{history_suffix}.pop")
        }
        time += 1
      end
      show(time, score, input_history, field)
      next
    when 'q'
      break
    else
      show(time, score, input_history, field)
      next
    end

    # 指定された方向に行けなかったら無効
    unless (0...WIDTH).include?(packman.x + dx) and
        (0...HEIGHT).include?(packman.y + dy) and
        field[packman.y + dy][packman.x + dx] != WALL
      next
    end
    input_history << c
    packman_history << packman.dup
    enemies_history << Marshal.load(Marshal.dump(enemies))
    score_history << score
    field_history << Marshal.load(Marshal.dump(field))
    dot_map_history << Marshal.load(Marshal.dump(dot_map))

    # 敵動かして
    enemies.each { |c|
      if field[c.y][c.x] == packman.symbol
        field[c.y][c.x] = packman.symbol
      else
        field[c.y][c.x] = dot_map[c.y][c.x]
      end
      
      c.move
      field[c.y][c.x] = c.symbol
    }

    # パックマン動かして
    field[packman.y][packman.x] = SPACE if field[packman.y][packman.x] == packman.symbol
    packman.move_to(packman.x + dx, packman.y + dy)
    field[packman.y][packman.x] = packman.symbol

    # 衝突判定して
    enemies.each { |c|
      if (c.x == packman.x and c.y == packman.y) or
          (c.x == packman.prev_x and c.y == packman.prev_y and
           c.prev_x == packman.x and c.prev_y == packman.y)
        gameover = true
        break
      end
    }

    # ポイント加算っと
    if dot_map[packman.y][packman.x] == DOT
      score += 1
      dot_map[packman.y][packman.x] = SPACE
    end
    time -= 1
    show(time, score, input_history, field)
    gameover = true if time <= 0
  end
  
  addstr "\n"
  addstr "GAMEOVER\n" if gameover
  addstr "PRESS ANY KEY...\n"
  getch
ensure
  close_screen
end


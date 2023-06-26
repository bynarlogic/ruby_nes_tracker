# frozen_string_literal: true

require "wavefile"
require "byebug"
require_relative "nes_tracker/version"
require_relative "nes_tracker/synth_voices/noise"
require_relative "nes_tracker/synth_voices/pulse"
require_relative "nes_tracker/utilities/audio_engine"

module NesTracker
  class Error < StandardError; end

  class Machine
    SONG_LENGTH = 16

    def initialize
      @song = Array.new(3) { Array.new(SONG_LENGTH, '--') }
      @engine = NesTracker::Utilities::AudioEngine.new
      run
    end

    def run
      print_title
      sleep 3

      loop do
        print "Enter command: "
        input = gets.chomp
        command, *args = input.split(' ')

        case command.downcase
        when 'note'
          add_note(*args)
        when 'play'
          play_song(*args)
        when 'exit'
          break
        else
          puts "Invalid command"
        end
      end
    end

    private 

    attr_reader :noise, :engine

    def print_title
      puts <<-'EOF'
        _   _   _   _     _   _   _     _   _   _   _   _   _   _    
       / \ / \ / \ / \   / \ / \ / \   / \ / \ / \ / \ / \ / \ / \ 
      ( R | u | b | y ) ( N | E | S ) ( T | r | a | c | k | e | r )
       \_/ \_/ \_/ \_/   \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ \_/
      EOF
    end

    def add_note(channel, row, note)
      channel = channel.to_i
      row = row.to_i
      note = note.to_i

      if channel < 0 || channel >= @song.length
        puts "Invalid channel. Must be between 0 and #{@song.length - 1}"
        return
      end

      if row > SONG_LENGTH || row < 0
        puts "#{row} is an invalid row"
        return
      end

      @song[channel][row] = note
      puts "Added note #{note} to channel #{channel} at row #{row}"
    end

    def play_song(bpm = 120)
      bpm = bpm.to_f
      puts "Playing song at #{bpm} BPM:"
      delay_time = 0.25
      loop do
        @song.transpose.each_with_index do |row, index|
          system "clear" 
          puts "#{index == @current_position ? '>' : ' '} #{row.join(' ')}"
          puts "\nSong:"
          @song.transpose.each_with_index do |full_row, full_index|
            puts "#{full_index == @current_position ? '>' : ' '} #{full_row.join(' ')}"
          end
          @current_position = (index + 1) % @song.transpose.size

          engine.process_row(row, "row_#{index}.wav", delay_time)
        end
      end
    end
  end
end

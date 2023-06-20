require 'wavefile'
require 'unimidi'
require 'byebug'

include WaveFile

# Configuration
SAMPLE_RATE = 44100
BUFFER_SIZE = 4096
SECONDS = 0.15

# Function to generate triangle wave
def triangle_wave(x)
  2.0 * (x.abs - 0.5)
end

def midi_to_freq(note_number)
  440.0 * (2.0 ** ((note_number - 69) / 12.0))
end

# Function to visualize a waveform with ASCII
def visualize_waveform(samples, height)
  min, max = samples.minmax
  scale = [max.abs, min.abs].max / (height / 2.0)

  samples.map do |sample|
    bar_height = (sample / scale).round.abs
    ' ' * ((height / 2) - bar_height) + '#' * bar_height * 2
  end.join("\n")
end

# Open the first MIDI input
input = UniMIDI::Input.first.open

while 1 do
  # Handle MIDI input
  input.gets.each do |midi_message|
    if midi_message[:data][0] == 144 && midi_message[:data][2] > 0 # Note on message
      note_number = midi_message[:data][1]
      frequency = midi_to_freq(note_number)

      puts frequency

      # Generate and write the triangle waveform
      file_name = "triangle_wave.wav"
      buffer_format = Format.new(:mono, :pcm_16, SAMPLE_RATE)

      Writer.new(file_name, buffer_format) do |writer|
        num_samples_per_cycle = SAMPLE_RATE / frequency
        num_samples_total = SAMPLE_RATE * SECONDS
        samples = []

        num_samples_total.to_i.times do |i|
          x = (i % num_samples_per_cycle).to_f / num_samples_per_cycle
          samples << (triangle_wave(x) * 0x7FFF).round
          if samples.length == BUFFER_SIZE
            system('clear')
            puts visualize_waveform(samples, 20)
            buffer = Buffer.new(samples, buffer_format)
            writer.write(buffer)
            samples.clear
          end
        end
      end

      # Play the generated .wav file
      system("afplay #{file_name}")
    end
  end
end

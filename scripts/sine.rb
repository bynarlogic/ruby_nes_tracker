require 'wavefile'
require 'unimidi'
require 'byebug'

include WaveFile

# Configuration
SAMPLE_RATE = 44100
BUFFER_SIZE = 4096
SECONDS = 0.15

# Function to generate Chebyshev polynomial
def chebyshev(n, x)
  case n
  when 0
    1
  when 1
    x
  else
    2 * x * chebyshev(n - 1, x) - chebyshev(n - 2, x)
  end
end

def midi_to_freq(note_number)
  440.0 * (2.0 ** ((note_number - 69) / 12.0))
end

# Open the first MIDI input
input = UniMIDI::Input.first.open

while 1 do
  # Handle MIDI input
  input.gets.each do |midi_message|
    if midi_message[:data][0] == 144 && midi_message[:data][2] > 0 # Note on message
      note_number = midi_message[:data][1]
      frequency = midi_to_freq(note_number)

      # Randomize the order of the Chebyshev polynomial
      # chebyshev_order = rand(1..10)
      chebyshev_order = 3

      puts frequency

      # Generate and write the Chebyshev waveform
      file_name = "chebyshev.wav"
      buffer_format = Format.new(:mono, :pcm_16, SAMPLE_RATE)

      Writer.new(file_name, buffer_format) do |writer|
        num_samples_per_cycle = SAMPLE_RATE / frequency
        num_samples_total = SAMPLE_RATE * SECONDS
        samples = []

        num_samples_total.to_i.times do |i|
          x = Math.sin(2.0 * Math::PI * (i % num_samples_per_cycle) / num_samples_per_cycle)
          samples << (chebyshev(chebyshev_order, x) * 0x7FFF).round
          if samples.length == BUFFER_SIZE
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
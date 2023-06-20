require 'wavefile'
require 'unimidi'
require 'byebug'

include WaveFile

# Configuration
SAMPLE_RATE = 44100
BUFFER_SIZE = 4096

# Function for delta modulation
def delta_modulation(samples, step_size)
  bit_depth = 8
  max_amplitude = 2**(bit_depth - 1) 

  output = []
  last_sample = 0

  samples.each do |sample|
    difference = sample - last_sample
    delta = (difference / step_size.to_f).round
    output << delta
    last_sample = delta * step_size
  end

  output = output.map do |sample|
    # Apply bit crushing effect
    (sample / max_amplitude.to_f).round * max_amplitude
  end

  output
end

# Function to process a sample file
def process_sample_file(file_name)
  modulated_samples = []
  Reader.new(file_name, Format.new(:mono, :pcm_16, SAMPLE_RATE)).each_buffer(BUFFER_SIZE) do |buffer|
    modulated_samples.concat(delta_modulation(buffer.samples, 0.1))

    # Convert float samples back to :pcm_16 samples
    modulated_samples = modulated_samples.map do |sample| 
      (sample * 0x7FFF).round
    end 

    Writer.new("Modulated#{file_name}", Format.new(:mono, :pcm_16, SAMPLE_RATE)) do |writer|
      buffer = Buffer.new(modulated_samples, Format.new(:mono, :pcm_16, SAMPLE_RATE))
      writer.write(buffer)
    end
  end
end

# Open the first MIDI input
input = UniMIDI::Input.first.open

while true do
  # Handle MIDI input
  input.gets.each do |midi_message|
    if midi_message[:data][0] == 144 && midi_message[:data][2] > 0 # Note on message
      # Process a sample file
      process_sample_file("Kick.wav")
      # Play the generated .wav file
      system("afplay ModulatedKick.wav")
    end
  end
end

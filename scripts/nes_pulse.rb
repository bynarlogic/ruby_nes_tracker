require 'wavefile'
require 'unimidi'
require 'byebug'

include WaveFile

# Configuration
SAMPLE_RATE = 44100
BUFFER_SIZE = 4096
SECONDS = 0.25

# Function to generate pulse wave
def pulse_wave(pulse_width, x)
  x < pulse_width ? 1.0 : -1.0
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
      frequency_1 = midi_to_freq(note_number)
      frequency_2 = midi_to_freq(note_number + 7)
      frequency_3 = midi_to_freq(note_number - 12)

      puts frequency_1 + frequency_2 + frequency_3

      # Generate and write the pulse waveform
      file_name = "pulse_wave.wav"
      buffer_format = Format.new(:mono, :pcm_16, SAMPLE_RATE)

      Writer.new(file_name, buffer_format) do |writer|
        num_samples_per_cycle_1 = SAMPLE_RATE / frequency_1
        num_samples_per_cycle_2 = SAMPLE_RATE / frequency_2
        num_samples_per_cycle_3 = SAMPLE_RATE / frequency_3
        num_samples_total = SAMPLE_RATE * SECONDS
        samples = []

        num_samples_total.to_i.times do |i|
          x_1 = (i % num_samples_per_cycle_1).to_f / num_samples_per_cycle_1
          x_2 = (i % num_samples_per_cycle_2).to_f / num_samples_per_cycle_2
          x_3 = (i % num_samples_per_cycle_3).to_f / num_samples_per_cycle_3
          


          sample_1 = pulse_wave(0.5, x_1)
          sample_2 = pulse_wave(0.5, x_2)
          sample_3 = pulse_wave(0.5, x_3)

          combined_sample = ((sample_1 + sample_2 + sample_3) / 3.0) * 0x7FFF

          samples << combined_sample.round

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

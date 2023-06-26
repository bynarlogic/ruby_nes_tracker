module NesTracker::Utilities
  class AudioEngine
    REST  = "--"
    SAMPLE_RATE = 44100
    SECONDS = 0.25
    BUFFER_SIZE = 4096

    def initialize
      @pulse_1 = NesTracker::SynthVoices::Pulse.new
      @pulse_2 = NesTracker::SynthVoices::Pulse.new
      @noise = NesTracker::SynthVoices::Noise.new
      @notes = []
    end

  	def process_row(row, file_name, delay_time)
      @notes = row

      return sleep delay_time if num_instruments == 0

      buffer_format = WaveFile::Format.new(:mono, :pcm_16, SAMPLE_RATE)
      full_file_name = File.join(File.dirname(__dir__), "/samples", file_name)

      WaveFile::Writer.new(full_file_name, buffer_format) do |writer|
        num_samples_total = SAMPLE_RATE * delay_time
        samples = []

        num_samples_total.to_i.times do |i|
          samples << process_sample(i)
          if samples.length == BUFFER_SIZE
            buffer = WaveFile::Buffer.new(samples, buffer_format)
            writer.write(buffer)
            samples.clear
          end
        end
      end

      # Play the generated .wav file
      system("afplay #{full_file_name}")
  	end

    private

    attr_reader :noise, :pulse_1, :pulse_2
    attr_accessor :notes

    def process_sample(index)
      samples = notes.map.with_index do |note, i|
        if note != REST
          cycle = samples_per_cycle(note)
          (instruments[i].process_sample(index, cycle) * 0x7FFF).round
        end
      end

      samples.compact!
      if samples.empty?
        0
      else
        (samples.sum / samples.size).round
      end
    end

    def instruments
      [pulse_1, pulse_2, noise]
    end

    def num_instruments
      notes.reject {|note| note == REST}.count.to_f
    end

    def samples_per_cycle(note)
      SAMPLE_RATE / midi_to_freq(note)
    end

    def midi_to_freq(note_number)
      440.0 * (2.0 ** ((note_number.to_i - 69) / 12.0))
    end
  end
end

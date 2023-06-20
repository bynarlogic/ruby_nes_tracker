module NesTracker::SynthVoices
  include WaveFile

  class Noise
    # Configuration
    SAMPLE_RATE = 44100
    BUFFER_SIZE = 4096
    SECONDS = 0.15

    # Function to generate white noise
    def white_noise
      2.0 * rand - 1.0
    end

    def file_name
      File.dirname(__dir__) + "/samples/white_noise.wav"
    end

    def play
      # Generate and write the white noise
      buffer_format = WaveFile::Format.new(:mono, :pcm_16, SAMPLE_RATE)

      WaveFile::Writer.new(file_name, buffer_format) do |writer|
        num_samples_total = SAMPLE_RATE * SECONDS
        samples = []

        num_samples_total.to_i.times do |i|
          samples << (white_noise * 0x7FFF).round
          if samples.length == BUFFER_SIZE
            buffer = WaveFile::Buffer.new(samples, buffer_format)
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
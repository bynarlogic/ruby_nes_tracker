module Utilities
	def write_to_buffer(file_name)
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
	end
end
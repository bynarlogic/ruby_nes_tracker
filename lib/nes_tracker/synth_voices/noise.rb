module NesTracker::SynthVoices
  class Noise
    # Function to generate white noise
    def white_noise
      2.0 * rand - 1.0
    end

    def process_sample(i, samples_per_cycle)
      white_noise
    end
  end
end
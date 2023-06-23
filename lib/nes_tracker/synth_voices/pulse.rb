module NesTracker::SynthVoices
  class Pulse
    # Function to generate pulse wave
    def pulse_wave(pulse_width, x)
      x < pulse_width ? 1.0 : -1.0
    end

    def process_sample(i, samples_per_cycle)
      x = (i % samples_per_cycle).to_f / samples_per_cycle
      pulse_wave(0.5, x)
    end
  end
end
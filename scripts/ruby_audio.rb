require 'ffi-portaudio'

# Sine wave parameters
frequency = 440.0
sample_rate = 44100
phase = 0
two_pi = 2.0 * Math::PI

FFI::PortAudio::API.Pa_Initialize()

output_parameters = FFI::PortAudio::StreamParameters.new
output_parameters.device = FFI::PortAudio::API.Pa_GetDefaultOutputDevice
output_parameters.channel_count = 1
output_parameters.sample_format = :float32
output_parameters.suggested_latency = FFI::PortAudio::API.Pa_GetDeviceInfo(output_parameters.device)[:default_high_output_latency]

stream = FFI::PortAudio::Stream.new(output_parameters, sample_rate, 1024) do |input, output, frames, time_info, status|
  output.map! do
    # Calculate the next sample
    sample = Math.sin(phase)

    # Increment the phase
    phase += two_pi * frequency / sample_rate

    # Make sure the phase wraps around
    phase -= two_pi while phase >= two_pi

    # Return the sample
    sample
  end
end

# Start the stream
stream.start

# Keep the script running while the stream is active
sleep while stream.active?

# Close the stream
stream.close

# Terminate PortAudio
FFI::PortAudio::API.Pa_Terminate()

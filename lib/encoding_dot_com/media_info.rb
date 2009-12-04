require 'parsedate'

module EncodingDotCom
  # Represents information about a video or image in the encoding.com queue
  class MediaInfo
    attr_reader :bitrate, :duration, :video_codec, :video_bitrate, :frame_rate, :size, :pixel_aspect_ratio, :display_aspect_ratio, :audio_codec, :audio_sample_rate, :audio_channels

    # Creates a MediaInfo object, given a <response> Nokogiri::XML::Node
    #
    # See the encoding.com documentation for GetMediaInfo action for more details
    def initialize(node)
      @bitrate = (node / "bitrate").text
      @duration = (node / "duration").text.to_f
      @video_codec = (node / "video_codec").text
      @video_bitrate = (node / "video_bitrate").text
      @frame_rate = (node / "frame_rate").text.to_f
      @size = (node / "size").text
      @pixel_aspect_ratio = (node / "pixel_aspect_ratio").text
      @display_aspect_ratio = (node / "display_aspect_ratio").text
      @audio_codec = (node / "audio_codec").text
      @audio_sample_rate = (node / "audio_sample_rate").text.to_i
      @audio_channels = (node / "audio_channels").text.to_i
    end
  end
end

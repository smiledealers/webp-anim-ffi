require_relative 'util'

# WebPAnimDecoderOptions dec_options;
# WebPAnimDecoderOptionsInit(&dec_options);
# // Tune 'dec_options' as needed.
# WebPAnimDecoder* dec = WebPAnimDecoderNew(webp_data, &dec_options);
# WebPAnimInfo anim_info;
# WebPAnimDecoderGetInfo(dec, &anim_info);
# for (uint32_t i = 0; i < anim_info.loop_count; ++i) {
#   while (WebPAnimDecoderHasMoreFrames(dec)) {
#     uint8_t* buf;
#     int timestamp;
#     WebPAnimDecoderGetNext(dec, &buf, &timestamp);
#     // ... (Render 'buf' based on 'timestamp').
#     // ... (Do NOT free 'buf', as it is owned by 'dec').
#   }
#   WebPAnimDecoderReset(dec);
# }
# const WebPDemuxer* demuxer = WebPAnimDecoderGetDemuxer(dec);
# // ... (Do something using 'demuxer'; e.g. get EXIF/XMP/ICC data).
# WebPAnimDecoderDelete(dec);
#
# typedef struct WebPAnimDecoder WebPAnimDecoder;  // Main opaque object.

module WebP
  module Anim
    class Decoder
      def initialize(data)
        @webp_data         = C::Data.new
        @webp_data[:bytes] = FFI::MemoryPointer.new(:char, data.bytesize).put_bytes(0, data)
        @webp_data[:size]  = data.bytesize
      end

      def info
        setup_decoder

        @info = C::AnimInfo.new
        res   = C.anim_decoder_get_info(@anim_decoder, @info)
        raise 'AnimDecoder get info failed.' if res == 0

        @info
      ensure
        teardown_decoder
      end

    private

      def setup_decoder
        @anim_decoder_options = C::AnimDecoderOptions.new
        res = C.anim_decoder_options_init(@anim_decoder_options, C::CONSTANTS[:WEBP_DEMUX_ABI_VERSION])
        raise 'Decoder options init failed.' if res == 0

        @anim_decoder = C.anim_decoder_new(@webp_data, @anim_decoder_options, C::CONSTANTS[:WEBP_DEMUX_ABI_VERSION])
      end

      def teardown_decoder
        C.anim_decoder_delete(@anim_decoder)
      end
    end
  end
end

module WebP
  module Anim
    module C
      CONSTANTS = enum(
        :WEBP_DEMUX_ABI_VERSION, 0x0107
      )

      FORMAT_FEATURE = enum(
        :format_flags,
        :canvas_width,
        :canvas_height,
        :loop_count,
        :background_color,
        :frame_count
      )

      DEMUX_STATE = enum(
        :demux_parse_error,    -1,
        :demux_parsing_header,  0,
        :demux_parsed_header,   1,
        :demux_done,            2
      )

      MUX_ANIM_DISPOSE = enum(
        :mux_dispose_none,
        :mux_dispose_background
      )

      MUX_ANIM_BLEND = enum(
        :mux_blend,
        :mux_no_blend
      )

      PARSE_STATUS = enum(
        :parse_ok,
        :parse_need_more_data,
        :parse_error
      )

      CSP_MODE = enum(
        :mode_rgb,
        :mode_rgba,
        :mode_bgr,
        :mode_bgra,
        :mode_argb,
        :mode_rgba_4444,
        :mode_rgb_565,
        # RGB-premultiplied transparent modes (alpha value is preserved]
        :mode_rgbA,
        :mode_bgrA,
        :mode_Argb,
        :mode_rgbA_4444,
        # YUV modes must come after RGB ones.
        :mode_yuv,
        :mode_yuva,
        :mode_last
      )

      class MemBuffer < FFI::Struct
        layout :start_,    :size_t,
               :end_,      :size_t,
               :riff_end_, :size_t,
               :buf_size_, :size_t,
               :buf_,      :uint8
      end

      class Data < FFI::Struct
        layout :bytes, :pointer,
               :size,  :size_t
      end

      class ChunkData < FFI::Struct
        layout :offset_, :size_t,
               :size_,   :size_t
      end

      class Frame < FFI::Struct
        layout :x_offset_,         :int,
               :y_offset_,         :int,
               :width_,            :int,
               :height_,           :int,
               :has_alpha_,        :int,
               :duration_,         :int,
               :dispose_method_,   MUX_ANIM_DISPOSE,
               :blend_method_,     MUX_ANIM_BLEND,
               :frame_num_,        :int,
               :complete_,         :int,
               :image_components_, [ChunkData.ptr, 2],
               :next_,             Frame.ptr
      end

      class Chunk < FFI::Struct
        layout :data_, ChunkData.ptr,
               :next_, Chunk.ptr
      end

      class Demuxer < FFI::Struct
        layout :mem_,           MemBuffer.ptr,
               :state_,         DEMUX_STATE,
               :is_ext_format_, :int,
               :feature_flags_, :uint32,
               :canvas_width_,  :int,
               :canvas_height_, :int,
               :loop_count_,    :int,
               :bgcolor_,       :uint32,
               :num_frames_,    :int,
               :frames_,        Frame.ptr,
               :frames_tail_,   Frame.ptr,
               :chunks_,        Chunk.ptr,
               :chunks_tail_,   Chunk.ptr
      end

      class AnimDecoderOptions < FFI::Struct
        layout :color_mode,  CSP_MODE,
               :use_threads, :int,
               :padding,     [:uint32, 7]
      end

      class DecoderConfig < FFI::Struct
      end

      class AnimInfo < FFI::Struct
        layout :canvas_width,  :uint32,
               :canvas_height, :uint32,
               :loop_count,    :uint32,
               :bgcolor,       :uint32,
               :frame_count,   :uint32,
               :pad,           [:uint32, 4]

        def canvas_width
          self[:canvas_width]
        end

        def canvas_height
          self[:canvas_height]
        end

        def frame_count
          self[:frame_count]
        end
      end

      class Iterator < FFI::Struct
        layout :frame_num,      :int,
               :num_frames,     :int,
               :fragment_num,   :int,
               :num_fragments,  :int,
               :x_offset,       :int,
               :y_offset,       :int,
               :width,          :int,
               :height,         :int,
               :duration,       :int,
               :dispose_method, MUX_ANIM_DISPOSE,
               :complete,       :int,
               :fragment,       Data.ptr,
               :has_alpha,      :int,
               :blend_method,   MUX_ANIM_BLEND,
               :pad,            [:uint32, 2] # ,
              # :private_,       :void
      end

      class AnimDecoder < FFI::Struct
        layout :demux_,                   Demuxer.ptr,
               :config_,                  DecoderConfig.ptr,
               :blend_func_,              callback([:uint32, :uint32, :int], :void),
               :info_,                    AnimInfo.ptr,
               :curr_frame_,              :uint8,
               :prev_frame_disposed_,     :uint8,
               :prev_frame_timestamp_,    :int,
               :prev_iter_,               Iterator.ptr,
               :prev_frame_was_keyframe_, :int,
               :next_frame_,              :int
      end

      # Demux API
      # attach_function :demux_version,       # Internal function name
      #                 :WebPGetDemuxVersion, # External function name
      #                 [],                   # Function arguments
      #                 :int                  # Function return value
      # attach_function :demux,
      #                 :WebPDemuxInternal,
      #                 [:pointer, DEMUX_STATE],
      #                 Demuxer.by_ref
      # attach_function :demux_info,
      #                 :WebPDemuxGetI,
      #                 [Demuxer.by_ref, FORMAT_FEATURE],
      #                 :uint32

      # Decode API
      attach_function :anim_decoder_options_init,
                      :WebPAnimDecoderOptionsInitInternal,
                      [AnimDecoderOptions.by_ref, :int],
                      :int
      attach_function :anim_decoder_new,
                      :WebPAnimDecoderNewInternal,
                      [Data.by_ref, AnimDecoderOptions.by_ref, :int],
                      AnimDecoder.by_ref
      attach_function :anim_decoder_get_info,
                      :WebPAnimDecoderGetInfo,
                      [AnimDecoder.by_ref, AnimInfo.by_ref],
                      :int
      attach_function :anim_decoder_has_more_frames,
                      :WebPAnimDecoderHasMoreFrames,
                      [AnimDecoder.by_ref],
                      :int
      attach_function :anim_decoder_next_frame,
                      :WebPAnimDecoderGetNext,
                      [AnimDecoder.by_ref, :buffer_out, :int],
                      :int
      attach_function :anim_decoder_reset,
                      :WebPAnimDecoderReset,
                      [AnimDecoder.by_ref],
                      :void
      attach_function :anim_decoder_get_demuxer,
                      :WebPAnimDecoderGetDemuxer,
                      [AnimDecoder.by_ref],
                      Demuxer.by_ref
      attach_function :anim_decoder_reset,
                      :WebPAnimDecoderReset,
                      [AnimDecoder.by_ref],
                      :void
      attach_function :anim_decoder_delete,
                      :WebPAnimDecoderDelete,
                      [AnimDecoder.by_ref],
                      :void
    end
  end
end

require 'ffi'

module Webp
  module Anim
    module C
      FormatFeature = enum(
        :ff_format_flags,
        :ff_canvas_width,
        :ff_canvas_height,
        :ff_loop_count,
        :ff_background_color,
        :ff_frame_count
      )

      DemuxState = enum(
        :demux_parse_error,    -1,
        :demux_parsing_header,  0,
        :demux_parsed_header,   1,
        :demux_done,            2
      )

      MuxAnimDispose = enum(
        :mux_dispose_none,
        :mux_dispose_background
      )

      MuxAnimBlend = enum(
        :mux_blend,
        :mux_no_blend
      )

      enum :parse_status, [
        :parse_ok,
        :parse_need_more_data,
        :parse_error
      ]

      enum :webp_csp_mode, [
        :mode_rgb,
        :mode_rgba,
        :mode_bgr,
        :mode_bgra,
        :mode_argb,
        :mode_rgba_4444,
        :mode_rgb_565,
        :mode_rgbA,
        :mode_bgrA,
        :mode_Argb,
        :mode_rgbA_4444,
        :mode_yuv,
        :mode_yuva,
        :mode_last
      ]

      class MemBuffer < FFI::Struct
        layout :start_,    :size_t,
               :end_,      :size_t,
               :riff_end_, :size_t,
               :buf_size_, :size_t,
               :buf_,      :uint8
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
               :dispose_method_,   :mux_anim_dispose,
               :blend_method_,     :mux_anim_blend,
               :frame_num_,        :int,
               :complete_,         :int,
               :image_components_, [ChunkData.ptr, 2],
               :next_,             Frame.ptr
      end

      class Chunk < FFI::Struct
        layout :data_, ChunkData.ptr,
               :next_, Chunk.ptr
      end

      class WebPDemuxer < FFI::Struct
        layout :mem_,           MemBuffer.ptr,
               :state_,         :demux_state,
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

      class WebPAnimDecoderOptions < FFI::Struct
        layout :color_mode,  :webp_csp_mode,
               :use_threads, :int,
               :padding,     [:uint32, 7]
      end
    end
  end
end

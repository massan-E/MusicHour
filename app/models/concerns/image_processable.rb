module ImageProcessable
  class ImageProcessingError < StandardError; end

  module_function

  def process_and_transform_image(image_io, width)
    return unless image_io.present?

    begin
      processed_image = ImageProcessing::Vips
        .source(image_io)
        .resize_to_fit(width, nil)
        .convert("webp")
        .saver(strip: true, quality: 85)
        .call

      ActionDispatch::Http::UploadedFile.new(
        tempfile: processed_image,
        filename: "#{File.basename(image_io.original_filename, '.*')}.webp",
        type: "image/webp"
      )
    rescue => e
      Rails.logger.error "Image processing error: #{e.message}"
      raise ImageProcessingError, "画像の処理中にエラーが発生しました: #{e.message}"
    end
  end
end

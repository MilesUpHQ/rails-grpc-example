module FileHelpers
  def generate_test_image(name: 'test_image.jpg', content_type: 'image/jpeg', size: 1.kilobyte)
    file = Tempfile.new([name.split('.').first, File.extname(name)])
    file.binmode

    while file.size < size
      remaining_size = size - file.size
      file.write(SecureRandom.random_bytes([remaining_size, 1024].min))
    end

    file.rewind
    raise "File size is not correct" unless file.size <= size

    uploaded_file = ActionDispatch::Http::UploadedFile.new(
      filename: name,
      type: content_type,
      tempfile: file
    )

    uploaded_file
  end
end

RSpec.configure do |config|
  config.include FileHelpers
end

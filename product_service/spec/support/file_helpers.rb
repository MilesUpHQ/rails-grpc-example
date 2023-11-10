# spec/support/file_helpers.rb
module FileHelpers
  def generate_test_image(name: 'test_image.jpg', content_type: 'image/jpeg', size: 1.kilobyte)
    # file = Tempfile.new([name.split('.').first, File.extname(name)], binmode: true)
    file = Tempfile.new([name.split('.').first, File.extname(name)])
    file.binmode
    file.write(SecureRandom.random_bytes(size)) while file.size < size

    # raise "Test file is not large enough" unless file.size > 5.megabytes

    file.rewind
    p file
    # Verify file size
    raise "File size is not correct" unless file.size == size

    # Create the uploaded file object
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

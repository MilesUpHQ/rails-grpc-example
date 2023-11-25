module ResponseHelper

  def expect_error_to_be_present
    expect(json['error']).to be_present
  end

  def expect_email_error_message
    expect(json['error']).to include("Email can't be blank")
  end
end
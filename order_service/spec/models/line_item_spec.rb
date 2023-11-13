# spec/models/line_item_spec.rb
require 'rails_helper'

RSpec.describe LineItem, type: :model do
  it 'is valid with valid attributes' do
    line_item = create(:line_item)
    expect(line_item).to be_valid
  end

  # Add additional tests for validations and custom methods
end

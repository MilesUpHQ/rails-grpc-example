# app/controllers/authentication_controller.rb
class AuthenticationController < ApplicationController
  def register
    user = User.new(user_params)
    if user.save
      token = User.encode_token({ user_id: user.id })
      render json: { user: user, token: token, message: 'User created successfully' }, status: :created
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      token = User.encode_token({ user_id: user.id })
      render json: { user: user, token: token }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end
end

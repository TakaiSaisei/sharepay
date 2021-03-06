class AuthController < ApplicationController
  skip_before_action :authenticate_user
  before_action :validate_sms_code

  # POST /auth/login
  def login
    user = User.find_or_initialize_by(phone: auth_params[:phone])

    if user.persisted?
      render json: { token: encode_token({ user_id: user.id }) }, status: :ok
    elsif user.save
      render json: { token: encode_token({ user_id: user.id }) }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def auth_params
    params.permit(:phone, :sms_code)
  end

  def validate_sms_code
    if (code = auth_params[:sms_code])
      code.eql?('1234') ? return : render(json: { success: false, error: 'Invalid SMS code' }, status: :conflict)
    else
      # send sms code
      render(json: { success: true }, status: :ok)
    end
  end
end

class JsonWebToken
  SECRET_KEY = ENV['JWT_SECRET']

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    raise StandardError, 'Token ausente' if token.nil?

    body = JWT.decode(token, SECRET_KEY).first
    HashWithIndifferentAccess.new(body)
  rescue JWT::ExpiredSignature
    raise StandardError, 'Token expirado'
  rescue JWT::DecodeError
    raise StandardError, 'Token inválido'
  end
end
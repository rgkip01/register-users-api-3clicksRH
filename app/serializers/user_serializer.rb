class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :email, :document, :date_of_birth

  has_many :addresses, serializer: AddressSerializer
end

class AddressSerializer
  include FastJsonapi::ObjectSerializer
  attributes :street, :city, :state, :zip_code, :country, :complement

  belongs_to :user
end

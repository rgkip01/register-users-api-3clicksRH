class AddressSerializer
  include FastJsonapi::ObjectSerializer
  attributes :street,
             :city,
             :state,
             :zip_code,
             :country,
             :complement,
             :created_at,
             :updated_at

  belongs_to :user
end

# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :user

  validates :street,
            :city,
            :state,
            :zip_code,
            :country, presence: true
end

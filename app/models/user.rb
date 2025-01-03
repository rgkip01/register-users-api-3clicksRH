# frozen_string_literal: true

class User < ApplicationRecord
  has_many :addresses, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :document, presence: true, uniqueness: true, format: { with: /\A\d{11}\z/, message: 'deve conter 11 dígitos.' }
  validates :date_of_birth, presence: true
end

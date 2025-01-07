# frozen_string_literal: true

class User < ApplicationRecord
  has_many :addresses, dependent: :destroy
  before_save :normalize_document

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :document, presence: true, uniqueness: true
  validates :date_of_birth, presence: true

  private

  def normalize_document
    self.document = document.gsub(/\D/, '') if document.present? && document.match?(/\A\d{11}\z/)
  end
end

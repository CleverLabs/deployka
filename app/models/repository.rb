# frozen_string_literal: true

class Repository < ApplicationRecord
  has_paper_trail

  belongs_to :project, required: true
  has_many :deployment_configurations_addons, dependent: :destroy
  has_many :addons, through: :deployment_configurations_addons
  has_many :web_processes, inverse_of: :deployment_configuration, dependent: :destroy

  accepts_nested_attributes_for :web_processes, allow_destroy: true

  validates :name, :path, :status, :integration_id, :integration_type, presence: true

  enum status: RepositoryConstants::STATUSES
  enum integration_type: ProjectsConstants::Providers::ALL
end
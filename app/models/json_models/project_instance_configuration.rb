# frozen_string_literal: true

module JSONModels
  class ProjectInstanceConfiguration
    include StoreModel::Model

    attribute :application_name, :string
    attribute :env_variables
    attribute :deployment_configuration_id, :integer
    attribute :application_url, :string
    attribute :repo_path, :string
    attribute :git_reference, :string

    validates :application_name, :deployment_configuration_id, :application_url, :repo_path, :git_reference, presence: true
  end
end
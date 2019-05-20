# frozen_string_literal: true

module Deployment
  class Configuration
    include ShallowAttributes

    attribute :application_name, String
    attribute :repo_path, String
    attribute :private_key, String
    attribute :env_variables, Hash
    attribute :deployment_configuration_id, Integer

    def self.build_from_project_instance(project_instance)
      # TODO: get deployment_configurations from project_instance
      project_instance.project.deployment_configurations.map do |deployment_configuration|
        new(
          application_name: "#{project_instance.project.name}-#{project_instance.name}-#{deployment_configuration.name}".tr(" ", "-").downcase,
          repo_path: deployment_configuration.repo_path,
          private_key: deployment_configuration.private_key,
          env_variables: deployment_configuration.env_variables
        )
      end
    end

    def self.build_from_project(project, instance_name)
      # TODO: change from project to input params
      project.deployment_configurations.map do |deployment_configuration|
        new(
          application_name: "#{project.name}-#{instance_name}-#{deployment_configuration.name}".tr(" ", "-").downcase,
          repo_path: deployment_configuration.repo_path,
          private_key: deployment_configuration.private_key,
          env_variables: deployment_configuration.env_variables,
          deployment_configuration_id: deployment_configuration.id
        )
      end
    end
  end
end
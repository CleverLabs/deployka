# frozen_string_literal: true

module Deployment
  module Processes
    class DeployNewInstance
      def initialize(project_instance)
        @project_instance = project_instance
      end

      def call(current_user)
        configurations = Deployment::ConfigurationBuilder.new.by_project_instance(@project_instance)
        build_action = BuildAction.create!(project_instance: @project_instance, author: current_user, action: BuildActionConstants::CREATE_INSTANCE)
        ServerActionsCallJob.perform_later(Deployment::ServerActions::Create.to_s, configurations.map(&:to_h), build_action)
      end
    end
  end
end

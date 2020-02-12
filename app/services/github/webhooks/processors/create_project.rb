# frozen_string_literal: true

module Github
  module Webhooks
    module Processors
      class CreateProject
        def initialize(body)
          @wrapped_body = Github::Events::Installation.new(payload: body)
        end

        def call
          user = find_user
          project = find_project
          perform_plugins_callback(project)
          ProjectUserRole.find_or_create_by(user: user, project: project).update!(role: ProjectUserRoleConstants::ADMIN)
          @wrapped_body.repos.each { |repo_info| create_repo(repo_info, project) }
          ReturnValue.ok
        end

        private

        def find_user
          # User has to create project inside the system, so it has to be authenticated
          user_reference = ::UserReference.find_by(auth_provider: ProjectsConstants::Providers::GITHUB, auth_uid: @wrapped_body.initiator_info.id)
          GithubEntity.ensure_info_exists(user_reference.user, @wrapped_body.raw_initiator_info) # TODO: github entity might references to user reference instead of user
          user_reference.user
        end

        def find_project
          ::Project.find_or_create_by(integration_type: ProjectsConstants::Providers::GITHUB, integration_id: @wrapped_body.installation_id).tap do |project|
            project.update!(name: @wrapped_body.organization_info.name) if project.name != @wrapped_body.organization_info.name
            GithubEntity.ensure_info_exists(project, @wrapped_body.raw_organization_info)
          end
        end

        def perform_plugins_callback(project)
          project_info = Plugins::Adapters::NewProject.build(project)
          Plugins::Entry::OnProjectCreation.new(project_info).call
        end

        def create_repo(repo_info, project)
          configuration = ::Repository.create!(
            project: project,
            path: repo_info.full_name,
            name: repo_info.name,
            integration_type: ProjectsConstants::Providers::GITHUB,
            integration_id: repo_info.id,
            status: RepositoryConstants::INSTALLED
          )

          GithubEntity.ensure_info_exists(configuration, repo_info.raw_info)
        end
      end
    end
  end
end

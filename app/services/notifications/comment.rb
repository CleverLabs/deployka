# frozen_string_literal: true

module Notifications
  class Comment
    # rubocop:disable Layout/LineLength
    FIRST_COMMENT_TEXT = %{
---
[<img height="70" width="70" src='https://deployqa-production.s3.amazonaws.com/public-icons/run.png' align='absmiddle' title='Deploy branch via Stagy' />](%<deploy_url>s) [<img height="70" width="70" src='https://deployqa-production.s3.amazonaws.com/public-icons/run_with_setup_dark.png' align='absmiddle' title='Customize and deploy branch via Stagy' />](%<custom_deploy_url>s) [<img height="70" width="50" src='https://deployqa-production.s3.amazonaws.com/public-icons/setup.png' align='absmiddle' title='Open instance page' />](%<project_instance_url>s)
}
    # rubocop:enable Layout/LineLength

    def initialize(project_instance_domain)
      @project_instance_domain = project_instance_domain
      @project_instance = project_instance_domain.project_instance_record
    end

    def failure_header
      "Unexpected error in Stagy"
    end

    def header
      format(
        FIRST_COMMENT_TEXT,
        deploy_url: deploy_url,
        custom_deploy_url: deploy_url(custom_deploy: true),
        project_instance_url: project_instance_url
      )
    end

    def deploying
      "Deploying..."
    end

    def deployed
      @project_instance_domain.configurations.inject("Application `#{@project_instance.name}` deployed!\n") do |result, configuration|
        result + "#{configuration.repo_path}:`#{configuration.git_reference}` url: #{configuration.application_url}\n"
      end
    end

    def failed
      "Deployment of '#{@project_instance.name}' failed. <#{project_instance_url}|Project instance>"
    end

    private

    def deploy_url(options = {})
      Rails.application.routes.url_helpers.project_project_instance_deploy_url(@project_instance.project_id, @project_instance.id, options)
    end

    def project_instance_url
      Rails.application.routes.url_helpers.project_project_instance_url(@project_instance.project_id, @project_instance.id)
    end
  end
end

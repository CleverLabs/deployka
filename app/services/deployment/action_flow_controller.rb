# frozen_string_literal: true

module Deployment
  class ActionFlowController
    delegate :states, :context=, :last_state, to: :@state_machine

    def initialize(build_action, deployment_statuses)
      @state_machine = ::ActionStateMachine.new
      @project_instance = build_action.project_instance
      @logger = BuildActionLogger.new(build_action)
      @deployment_statuses = deployment_statuses
    end

    def start
      @project_instance.update!(deployment_status: @deployment_statuses.fetch(:running))
      self
    end

    def add_state(state_name, &block)
      @state_machine.add_state(
        state_name,
        before: -> { @logger.info(I18n.t("build_addons.log.#{state_name}"), context: context_name) },
        on_error: ->(errors, backtrace) { @logger.error(errors.to_s, context: context_name, error_backtrace: backtrace) },
        &block
      )
      self
    end

    def finalize
      if last_state.status.ok?
        @logger.info(I18n.t("build_addons.log.success"), context: context_name)
        deployment_status = @deployment_statuses.fetch(:success)
      else
        deployment_status = @deployment_statuses.fetch(:failure)
      end

      @project_instance.update!(deployment_status: deployment_status)
      last_state.status
    end

    private

    delegate :context, to: :@state_machine

    def context_name
      return "Global" unless context

      context.application_name
    end
  end
end
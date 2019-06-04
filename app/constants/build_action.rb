# frozen_string_literal: true

module BuildAction
  ACTIONS = [
    CREATE_INSTANCE = :create_instance,
    UPDATE_INSTANCE = :update_instance,
    RELOAD_INSTANCE = :reload_instance,
    DESTROY_INSTANCE = :destroy_instance
  ].freeze

  module Log
    STATUSES = [
      INFO = :info,
      ERROR = :error
    ].freeze
  end
end

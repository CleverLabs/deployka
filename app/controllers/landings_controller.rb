# frozen_string_literal: true

class LandingsController < ApplicationController
  skip_before_action :login_if_not

  layout "landing"

  def index
    return redirect_to projects_path if authenticated? && Rails.env.production?

    render :index
  end

  def roles
    @role_name = params[:role]
    raise unless %w[for-managers for-qa for-sales for-developers].include? params[:role]

    @texts = I18n.t("landing.roles.#{@role_name}.how-it-helps")
    render :roles
  end

  def pricing
    render :pricing
  end

  def faq
    render :faq
  end

  def create
    return redirect_to("/") if params[:email].blank?

    WaitingList.create(email: params[:email])
    render :done, layout: false
  end
end

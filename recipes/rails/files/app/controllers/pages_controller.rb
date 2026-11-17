require "sidekiq/api"

class PagesController < ApplicationController
  def home
    HelloJob.perform_async("homemade")
    @postgres = ActiveRecord::Base.connection.select_value("select version()").split(" on ").first
    @processed = Sidekiq::Stats.new.processed
  end
end

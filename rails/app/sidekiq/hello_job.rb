class HelloJob
  include Sidekiq::Job

  def perform(name)
    Rails.logger.info("Hello, #{name}")
  end
end

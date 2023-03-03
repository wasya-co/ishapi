
require "spec_helper"

RSpec.describe IshApi::EmailMessageIntakeJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later(123) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

end

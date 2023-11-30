
require "spec_helper"

RSpec.describe Ishapi::EmailMessageIntakeJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later(123) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  describe 'test' do
    it 'creates the email_message' do

      n = ::Office::EmailMessage.all.length

      object_key = 'fom5a97nif6j9urfp46sbchi33sks90e9kkrn181'
      MsgStub.where({ object_key: object_key }).delete
      stub = MsgStub.create!({ object_key: object_key })
      id = stub.id
      Ishapi::EmailMessageIntakeJob.perform_now( stub.id.to_s )

      ::Office::EmailMessage.all.length.should eql( n + 1 )

    end
  end

end

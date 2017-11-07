require 'rails_helper'

RSpec.describe StartFlowRapidproTask do
  describe StartFlowRapidproTask::Install do
    describe ".rake_tasks" do
      it { expect(described_class.rake_tasks).to eq([:run!]) }
    end
  end

  describe "#run!" do
    let(:do_run) { true }

    def do_run!
      subject.run!
    end

    def setup_scenario
      super
      stub_request(:post, asserted_rapidpro_endpoint).to_return(mocked_remote_response)
      phone_call_to_run_flow
      phone_call_not_completed
      phone_call_flow_already_run
      phone_call_callout_not_running
      do_run! if do_run
    end

    let(:mocked_remote_response) {
      {
        :body => mocked_remote_response_body,
        :status => mocked_remote_response_status,
        :headers => mocked_remote_response_headers,
      }
    }

    let(:mocked_remote_response_body) {
      {
        "id" => mocked_remote_response_body_id,
        "uuid" => mocked_remote_response_body_uuid
      }.to_json
    }

    let(:mocked_remote_response_body_id) { 1234 }
    let(:mocked_remote_response_body_uuid) { SecureRandom.uuid }
    let(:mocked_remote_response_status) { 201 }
    let(:mocked_remote_response_headers_content_type) { "application/json" }

    let(:mocked_remote_response_headers) {
      {
        "Content-Type" => mocked_remote_response_headers_content_type
      }
    }

    let(:rapidpro_flow_id_key) { "rapidpro_flow_id" }
    let(:existing_rapidpro_flow_id) { 99 }

    let(:running_callout) { create(:callout, :status => :running) }

    let(:phone_call_to_run_flow) {
      create(
        :phone_call,
        :status => :completed,
        :callout => running_callout
      )
    }

    let(:phone_call_not_completed) {
      create(
        :phone_call,
        :callout => running_callout
      )
    }

    let(:phone_call_flow_already_run) {
      create(
        :phone_call,
        :status => :completed,
        :callout => running_callout,
        :metadata => {
          rapidpro_flow_id_key => existing_rapidpro_flow_id
        }
      )
    }

    let(:phone_call_callout_not_running) {
      create(
        :phone_call,
        :status => :completed
      )
    }

    let(:asserted_rapidpro_endpoint) {
      "#{rapidpro_base_url}/#{rapidpro_api_version}/flow_starts.json"
    }

    let(:rapidpro_base_url) { "https://app.rapidpro.io/api" }
    let(:rapidpro_api_version) { "v2" }
    let(:rapidpro_api_token) { "api-token" }

    let(:start_flow_rapidpro_request_params_flow_id) {
      "flow-id"
    }

    let(:start_flow_rapidpro_request_urn_telegram_id) {
      "telegram-id"
    }

    let(:start_flow_rapidpro_request_urns) {
      ["telegram:#{start_flow_rapidpro_request_urn_telegram_id}"]
    }

    let(:start_flow_rapidpro_request_params) {
      {
        "flow" => start_flow_rapidpro_request_params_flow_id,
        "groups" => [],
        "contacts" => [],
        "urns" => start_flow_rapidpro_request_urns,
        "extra" => {}
      }
    }

    let(:dynamic_request_params) {
      {
        "urns" => ["tel: #{phone_call_to_run_flow.msisdn}"]
      }
    }

    def env
      {
        "RAPIDPRO_BASE_URL" => rapidpro_base_url,
        "RAPIDPRO_API_VERSION" => rapidpro_api_version,
        "RAPIDPRO_API_TOKEN" => rapidpro_api_token,
        "START_FLOW_RAPIDPRO_TASK_REMOTE_REQUEST_PARAMS" => start_flow_rapidpro_request_params.to_json
      }
    end

    def assert_run!
      expect(WebMock.requests.count).to eq(1)
      phone_call_flow_already_run.reload
      phone_call_not_completed.reload
      phone_call_to_run_flow.reload

      expect(
        phone_call_flow_already_run.metadata[rapidpro_flow_id_key]
      ).to eq(existing_rapidpro_flow_id)

      [phone_call_not_completed, phone_call_callout_not_running].each do |phone_call|
        expect(phone_call.metadata[rapidpro_flow_id_key]).to eq(nil)
      end

      expect(
        phone_call_to_run_flow.metadata[rapidpro_flow_id_key]
      ).to eq(mocked_remote_response_body_id)

      expect(
        phone_call_to_run_flow.metadata["rapidpro_flow_started_at"]
      ).to be_present

      request = WebMock.requests.last
      request_body = JSON.parse(request.body)
      request_headers = request.headers

      expect(request_headers["Content-Type"]).to eq("application/json")
      expect(request_headers["Authorization"]).to eq("Token #{rapidpro_api_token}")
      expect(request_body).to eq(start_flow_rapidpro_request_params.merge(dynamic_request_params))
    end

    it { assert_run! }

    context "SLEEP_BETWEEN_FLOW_STARTS=0.75" do
      let(:sleep_between_flow_starts) { 0.75 }
      let(:asserted_sleep) { sleep_between_flow_starts }
      let(:do_run) { false }

      def env
        super.merge(
          "START_FLOW_RAPIDPRO_TASK_SLEEP_BETWEEN_FLOW_STARTS" => sleep_between_flow_starts.to_s
        )
      end

      def assert_run!
        allow(subject).to receive(:sleep)
        expect(subject).to receive(:sleep).with(asserted_sleep)
        do_run!
      end

      it { assert_run! }
    end
  end
end

require 'spec_helper'

describe InfoController do

  let(:valid_session) { {} }

  describe "GET "

  describe "GET connection parameters" do
    it "gives a HOST and PORT to use for websocket connection" do
      get :connection_params, {}, valid_session
      response.status.should be 200
      parsed_body = JSON.parse(response.body)
      parsed_body['host'].should be_a String
      parsed_body['port'].should be_a Integer
    end

    context "when on OpenShift server" do
      before do
        Rails.application.config.stubs(:openshift).returns("FAKE_GEAR_UUID")
      end
      it "gives 8000 as port number" do
        get :connection_params, {}, valid_session
        response.status.should be 200
        parsed_body = JSON.parse(response.body)
        parsed_body['port'].should be 8000
      end
    end
  end
end
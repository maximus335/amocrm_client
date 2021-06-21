# frozen_string_literal: true

RSpec.shared_examples 'request method' do
  before do
    stub_request(meth, url).to_return(body: body.to_json, status: status, headers: headers)
  end

  let(:config) { AmocrmClient.config.client }
  let(:url) { config['api_endpoint'] + config['api_path'] + path }
  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:body) { { 'test' => 'test' } }
  let(:status) { 200 }

  context 'when status 200' do
    let(:status) { 200 }

    it '' do
      expect(request).to eq(body)
    end
  end

  context 'when status 301' do
    let(:status) { 301 }

    it 'raise exeption' do
      expect { request }.to raise_error(::AmocrmClient::AmoMovedPermanentlyError)
    end
  end

  context 'when status 400' do
    let(:status) { 400 }

    it 'raise exeption' do
      expect { request }.to raise_error(::AmocrmClient::AmoBadRequestError)
    end
  end

  context 'when status 403' do
    let(:status) { 403 }

    it 'raise exeption' do
      expect { request }.to raise_error(::AmocrmClient::AmoForbiddenError)
    end
  end

  context 'when status 404' do
    let(:status) { 404 }

    it 'raise exeption' do
      expect { request }.to raise_error(::AmocrmClient::AmoNotFoundError)
    end
  end

  context 'when status 500' do
    let(:status) { 500 }

    it 'raise exeption' do
      expect { request }.to raise_error(::AmocrmClient::AmoInternalError)
    end
  end

  context 'when status 502' do
    let(:status) { 502 }

    it 'raise exeption' do
      expect { request }.to raise_error(::AmocrmClient::AmoBadGatewayError)
    end
  end

  context 'when status 503' do
    let(:status) { 503 }

    it 'raise exeption' do
      expect { request }.to raise_error(::AmocrmClient::AmoServiceUnaviableError)
    end
  end

  context 'when status 429' do
    let(:status) { 429 }

    it 'raise exeption' do
      expect { request }.to raise_error(::AmocrmClient::AmoRequestsPerSecExceeded)
    end
  end

  context 'when status 401' do
    before do
      stub_request(meth, url).with(headers: bad_h).to_return(body: body.to_json, status: 401, headers: headers)
      stub_request(meth, url).with(headers: good_h).to_return(body: body.to_json, status: 200, headers: headers)
      stub_request(:post, oautn_url).to_return(body: refresh_tokens.to_json, status: 200, headers: headers)
    end

    let(:bad_h) { { 'Authorization' => "Bearer #{AmocrmClient.config.oauth['init_access_token']}" } }
    let(:good_h) { { 'Authorization' => "Bearer #{access_token}" } }
    let(:oautn_url) { config['api_endpoint'] + AmocrmClient.config.oauth['path'] }
    let(:access_token) { 'access_token' }
    let(:refresh_tokens) do
      {
        'refresh_token' => 'refresh_token',
        'access_token' => access_token
      }
    end

    it 'update tokens' do
      request
      expect(AmocrmClient::StorTokens.new(AmocrmClient.config).find).to eq(refresh_tokens)
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe AmocrmClient::Connection do
  let(:connection) { AmocrmClient.connection }
  let(:stor_token) { connection.stor_token }
  let(:config) { connection.config }

  context "when init connection" do
    let(:init_tokens) do
      {
        'refresh_token' => config.oauth['init_refresh_token'],
        'access_token' => config.oauth['init_access_token']
      }
    end

    it "should create client" do
      expect(connection.connect).to be_kind_of(Faraday::Connection)
      expect(connection.redlock).to be_kind_of(AmocrmClient::Redlock)
    end

    it 'should set tokens' do
      connection
      expect(stor_token.find).to eq(init_tokens)
    end
  end

  describe '.request' do
    before do
      allow(connection).to receive(:redlock).and_return(redlock)
      allow(redlock).to receive(:with_redlock) do |&block|
        block.call
      end
      allow(redlock).to receive(:refresh_with_redlock) do |&block|
        block.call
      end
    end

    subject(:request) { connection.request(meth, path) }

    let(:redlock) { instance_double('AmocrmClient::Redlock') }

    context 'when methods is get' do
      it_behaves_like 'request method' do
        let(:meth) { :get }
        let(:path) { 'path' }
      end
    end

    context 'when methods is post' do
      it_behaves_like 'request method' do
        let(:meth) { :post }
        let(:path) { 'path' }
      end
    end

    context 'when methods is patch' do
      it_behaves_like 'request method' do
        let(:meth) { :patch }
        let(:path) { 'path' }
      end
    end

    context 'when additional accounts connection is present' do
      let(:connection) { AmocrmClient.accounts.connection_additional }

      context 'when methods is get' do
        it_behaves_like 'request method' do
          let(:meth) { :get }
          let(:path) { 'path' }
        end
      end

      context 'when methods is post' do
        it_behaves_like 'request method' do
          let(:meth) { :post }
          let(:path) { 'path' }
        end
      end

      context 'when methods is patch' do
        it_behaves_like 'request method' do
          let(:meth) { :patch }
          let(:path) { 'path' }
        end
      end
    end
  end
end

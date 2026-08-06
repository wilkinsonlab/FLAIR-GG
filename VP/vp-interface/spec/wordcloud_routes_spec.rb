# frozen_string_literal: false

require_relative 'spec_helper'

RSpec.describe 'Word cloud routes', type: :request do
  before { stub_vp }

  describe 'GET /flair-gg-vp-server/wordcloud' do
    it 'renders the wordcloud view with frequencies from the cache' do
      allow(Wordcloud).to receive(:new).and_return(instance_double(Wordcloud, count_words: { 'seed' => 3 }))

      get '/flair-gg-vp-server/wordcloud'

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to include('text/html')
    end
  end

  describe 'GET /flair-gg-vp-server/wordcloud/force-refresh' do
    after { FileUtils.rm_f('./cache/WCREFRESHING') }

    it 'rebuilds the word cloud when not already refreshing' do
      expect(Wordcloud).to receive(:refreshing?).and_return(false)
      expect(Wordcloud).to receive(:new).with(refresh: true)
                                        .and_return(instance_double(Wordcloud, count_words: { 'wheat' => 2 }))

      get '/flair-gg-vp-server/wordcloud/force-refresh'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('wheat')
    end

    it 'returns the stale layout without rebuilding when already refreshing' do
      expect(Wordcloud).to receive(:refreshing?).and_return(true)
      expect(Wordcloud).not_to receive(:new)

      get '/flair-gg-vp-server/wordcloud/force-refresh'

      expect(last_response.status).to eq(200)
    end
  end
end

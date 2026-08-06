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

    it 'safely embeds a label containing quotes, backslashes, and a script-closing sequence' do
      tricky_label = %(Weird "label" with a \\ and a </script> inside)
      allow(Wordcloud).to receive(:new).and_return(instance_double(Wordcloud, count_words: { tricky_label => 1 }))

      get '/flair-gg-vp-server/wordcloud'

      expect(last_response.status).to eq(200)
      expect(last_response.body).not_to include('</script> inside') # would prematurely close the script tag unescaped

      word_array_json = last_response.body[/var word_array = (\[.*?\]);/m, 1]
      parsed = JSON.parse(word_array_json)
      expect(parsed).to eq([{ 'text' => tricky_label, 'weight' => 1 }])
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

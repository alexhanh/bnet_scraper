require 'spec_helper'

describe BnetScraper::Starcraft2::GrandmasterScraper do
  describe '#scrape' do
    let(:scraper) { BnetScraper::Starcraft2::GrandmasterScraper.new(region: :us) }
    subject  { scraper }
    before do
      VCR.use_cassette('grandmaster_na', record: :new_episodes) do
        scraper.scrape
      end
    end
    it { should have(200).players }

    context 'player statistics' do
      let(:player) { scraper.players[0] }

      it 'should have rank 1' do
        player[:rank].should == '1st'
      end

      it 'should have a race' do
        player[:race].should == 'zerg'
      end

      it 'should have a name' do
        player[:name].should == '[Qntc] QuanticHyuN'
      end

      it 'should have points' do
        player[:points].should == '953'
      end

      it 'should have wins' do
        player[:wins].should == '71'
      end

      it 'should have losses' do
        player[:losses].should == '11'
      end
    end
  end
end

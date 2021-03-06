require 'spec_helper'

describe BnetScraper::Starcraft2::LeagueScraper do
  let(:url) { "http://us.battle.net/sc2/en/profile/2377239/1/Demon/ladder/134659" }
  subject { BnetScraper::Starcraft2::LeagueScraper.new(url: url) }

  it_behaves_like 'an SC2 Scraper' do
    let(:scraper_class) { BnetScraper::Starcraft2::LeagueScraper }
    let(:subject) { scraper_class.new(url: "http://us.battle.net/sc2/en/profile/2377239/1/Demon/ladder/134659") }
  end

  describe '#initialize' do
    it 'should dissect the league_id from the URL' do
      subject.league_id.should == '134659'
    end
  end

  describe '#scrape' do
    context 'valid profile' do
      before do
        VCR.use_cassette('demon_leagues') do
          subject.scrape
        end
      end

      its(:season) { should == '2013 Season 1' }
      its(:name) { should == 'Kalathi Echo' }
      its(:division) { should == 'Platinum' }
      its(:size) { should == '1v1' }
      its(:random) { should be_false }
    end

    context 'invalid profile' do
      it 'should raise InvalidProfileError' do
        VCR.use_cassette('invalid_leagues') do
          url = 'http://us.battle.net/sc2/en/profile/2377239/1/SomeDude/leagues/12345' 
          scraper = BnetScraper::Starcraft2::LeagueScraper.new(url: url)
          expect { scraper.scrape }.to raise_error(BnetScraper::InvalidProfileError)
        end
      end
    end
  end
end

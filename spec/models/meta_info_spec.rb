require 'rails_helper'

RSpec.describe MetaInfo, type: :model do

    before(:all) do
      @meta_info = create(:meta_info, server_version: 5, minimal_client_version: 10)
    end

    subject { @meta_info }

    context 'Object' do
      it { is_expected.to be_valid }
      it { expect(@meta_info.server_version).to eq 5}
      it { expect(@meta_info.server_version).to be_a Integer }
      it { expect(@meta_info.minimal_client_version).to eq 10}
      it { expect(@meta_info.minimal_client_version).to be_a Integer }
    end

    context 'Views' do
      it 'returns all meta migration' do
        expect(MetaInfo.all.to_a.size).to eq(1)
      end

      it 'returns all meta_info by server_version' do
        expect(MetaInfo.by_server_version(key: 5).to_a.size).to eq(1)
      end

      it 'returns meta_info by server_version' do
        expect(MetaInfo.find_by(5).id).to eq(@meta_info.id)
      end

  end

end

require 'spec_helper'

describe SpreeShopifyImporter::DataSavers::Zones::ZoneUpdater, type: :service do
  include ActiveJob::TestHelper

  subject { described_class.new(shopify_object, parent_object, spree_zone) }

  before { authenticate_with_shopify }

  describe '#update!' do
    context 'with country shipping_zone data feed', vcr: { cassette_name: 'shopify/base_country_zone' } do
      authenticate_with_shopify
      let(:shopify_shipping_zone) { ShopifyAPI::ShippingZone.first }
      let!(:shipping_zone_data_feed) do
        create(:shopify_data_feed,
               shopify_object_id: shopify_shipping_zone.id,
               shopify_object_type: shopify_shipping_zone.class.name,
               data_feed: shopify_shipping_zone.to_json)
      end
      let!(:old_zone_data_feed) do
        create(:shopify_data_feed,
               shopify_object_id: 516_252_868,
               shopify_object_type: 'ShopifyAPI::Country',
               parent_id: shipping_zone_data_feed.id)
      end
      let!(:country) { create(:country, iso: 'HR') }
      let!(:spree_zone) { create(:zone, name: 'Domestic/18869387313/Croatia', kind: 'country') }
      let!(:old_spree_zone_member) { create(:zone_member, zoneable: country, zone: spree_zone) }
      let(:parent_object) { shopify_shipping_zone }
      let(:shopify_object) { parent_object.countries.first }
      let(:new_spree_zone_member) do
        Spree::ZoneMember.find_by!(
          zoneable_type: 'Spree::Country',
          zoneable_id: country.id,
          zone_id: spree_zone.id
        )
      end

      it 'does not create spree zone' do
        expect { subject.update! }.not_to change(Spree::Zone, :count)
      end

      it 'updates spree zone' do
        expect(spree_zone.description).not_to eq("shopify shipping to #{shopify_object.name}")
        subject.update!
        expect(spree_zone.description).to eq("shopify shipping to #{shopify_object.name}")
      end

      it 'destroys old spree zone member' do
        subject.update!
        expect(spree_zone.members.count).to eq 1
        expect(new_spree_zone_member).not_to eq(old_spree_zone_member)
      end

      it 'creates spree zone member' do
        subject.update!
        expect(spree_zone.members.count).to eq 1
        expect(spree_zone.reload.members.first).to eq new_spree_zone_member
      end
    end
  end
end
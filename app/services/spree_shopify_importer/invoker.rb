module SpreeShopifyImporter
  class Invoker
    ROOT_FETCHERS = [
      SpreeShopifyImporter::DataFetchers::ShopFetcher,
      SpreeShopifyImporter::DataFetchers::ProductsFetcher,
      SpreeShopifyImporter::DataFetchers::StockLocationsFetcher,
      SpreeShopifyImporter::DataFetchers::ShopifyZonesFetcher,
      SpreeShopifyImporter::DataFetchers::UsersFetcher,
      SpreeShopifyImporter::DataFetchers::TaxonsFetcher,
      SpreeShopifyImporter::DataFetchers::OrdersFetcher
    ].freeze

    def initialize(credentials: nil)
      @credentials = credentials
      @credentials ||= {
        api_key: Spree::ShopifyImporter::Config[:shopify_api_key],
        password: Spree::ShopifyImporter::Config[:shopify_password],
        shop_domain: Spree::ShopifyImporter::Config[:shopify_shop_domain],
        token: Spree::ShopifyImporter::Config[:shopify_token],
        api_version: Spree::ShopifyImporter::Config[:shopify_api_version]
      }
    end

    def import!
      connect

      initiate_import!
    end

    def import_products!
      connect

      SpreeShopifyImporter::DataFetchers::ProductsFetcher.new.import!
    end

    def import_products_test!
      # connect
      product_object = SpreeShopifyImporter::DataFeed.find_by(shopify_object_type: "ShopifyAPI::Product")

      SpreeShopifyImporter::Importers::ProductImporterJob.perform_later(product_object.data_feed)
    end

    private

    def connect
      set_current_credentials
      SpreeShopifyImporter::Connections::Client.instance.get_connection(@credentials)
    end

    def set_current_credentials
      Spree::ShopifyImporter::Config[:shopify_current_credentials] = @credentials
    end

    def initiate_import!
      ROOT_FETCHERS.each do |fetchers|
        fetchers.new.import!
      end
    end
  end
end

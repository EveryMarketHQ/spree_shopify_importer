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

    def import_products(limit)
      if limit
        products = SpreeShopifyImporter::DataFeed.where(shopify_object_type: "ShopifyAPI::Product", spree_object_id: nil).where.not(data_feed: [nil, ""]).limit(limit)
      else
        products = SpreeShopifyImporter::DataFeed.where(shopify_object_type: "ShopifyAPI::Product", spree_object_id: nil).where.not(data_feed: [nil, ""])
      end

      products.each do |product|
        SpreeShopifyImporter::Importers::ProductImporterJob.perform_later(product.data_feed)
      end
    end

    def import_taxons
      taxons = SpreeShopifyImporter::DataFeed.where(shopify_object_type: "ShopifyAPI::CustomCollection", spree_object_id: nil).where.not(data_feed: [nil, ""])

      taxons.each do |taxon|
        SpreeShopifyImporter::Importers::TaxonImporterJob.perform_later(taxon.data_feed)
      end
    end

    def import_users
      users = SpreeShopifyImporter::DataFeed.where(shopify_object_type: "ShopifyAPI::Customer", spree_object_id: nil).where.not(data_feed: [nil, ""])

      users.each do |user|
        SpreeShopifyImporter::Importers::UserImporterJob.perform_later(user.data_feed)
      end
    end

    def import_missing_images
      spree_images = SpreeShopifyImporter::DataFeed.where(shopify_object_type: "ShopifyAPI::Image", spree_object_id: nil).where.not(parent_id: nil)

      spree_images.each do |image|
        next if image.parent.spree_object.nil?
        SpreeShopifyImporter::Importers::ImageImporterJob.perform_later(image.data_feed, image.parent, image.parent.spree_object)
      end
    end

    def import_products_test
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

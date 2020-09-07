class SpreeShopifyImporterJob < ApplicationJob
  queue_as { Spree::ShopifyImporter::Config[:shopify_import_queue] }
end

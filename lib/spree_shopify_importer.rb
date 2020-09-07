require "spree_core"
require "spree_shopify_importer/engine"
require "spree_shopify_importer/version"
require "shopify_api"

module Spree
  module ShopifyImporter
    module_function

    def config(*)
      yield(Spree::ShopifyImporter::Config)
    end
  end
end
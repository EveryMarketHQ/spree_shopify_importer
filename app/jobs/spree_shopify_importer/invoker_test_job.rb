module SpreeShopifyImporter
  class InvokerTestJob < ::SpreeShopifyImporterJob
    def perform(credentials: nil)
      SpreeShopifyImporter::Invoker.new(credentials: credentials).import_products_test!
    end
  end
end

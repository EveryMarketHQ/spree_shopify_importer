module SpreeShopifyImporter
  module DataFetchers
    class SmartTaxonsFetcher < BaseFetcher
      private

      def resources
        SpreeShopifyImporter::Connections::SmartCollection.all
      end

      def job
        SpreeShopifyImporter::Importers::TaxonImporterJob
      end
    end
  end
end

module SpreeShopifyImporter
  module DataSavers
    module Products
      class ProductBase < BaseDataSaver
        delegate :attributes, :tags, :options, to: :parser

        private

        def assign_spree_product_to_data_feed
          @shopify_data_feed.update!(spree_object: @spree_product)
        end

        def add_tags
          # TODO: - issues with tags
          # @spree_product.tag_list = tags
          # @spree_product.save!
        end

        def add_option_types
          return if options.blank?
          # skip if only option is Title
          return if options.first.name == "Title"

          @spree_product.update!(option_type_ids: create_option_types)
        end

        def create_option_types
          options.map do |option|
            option_type = SpreeShopifyImporter::DataSavers::OptionTypes::OptionTypeCreator.new(option).create!
            option_type.id
          end
        end

        def add_master_sku_weight_barcode
          # set only if option is Title
          if options.first.name == "Title" and options.first.values.first == "Default Title"
            @spree_product.master.update!(sku: @shopify_product.variants.first.try(:sku) || "", 
              weight: @shopify_product.variants.first.try(:grams) || 0,
              barcode: @shopify_product.variants.first.try(:barcode) || "")
          end
        end

        def add_brand
          @spree_product.update!(main_brand: shopify_product.vendor)
        end
        
        def create_spree_variants
          @shopify_product.variants.each do |variant|
            # skip if variant is Default Title
            next if variant.title == "Default Title"
            SpreeShopifyImporter::Importers::VariantImporterJob.perform_later(variant.to_json,
                                                                              @shopify_data_feed,
                                                                              @spree_product,
                                                                              variant_image(variant))
          end
        end

        def create_delivery_profiles
          SpreeShopifyImporter::Importers::DeliveryProfileImporter.new(@spree_product, @shopify_product).call
        end

        # According to shopify api documentation variant can have only one image
        # https://help.shopify.com/api/reference/product_variant

        # it is no true anymore - # TODO:
        def variant_image(variant)
          variant_image = shopify_images.detect { |image| image.variant_ids.include?(variant.id) }
          return if variant_image.blank?

          variant_image.to_json
        end

        def create_spree_images
          shopify_images.select { |image| image.variant_ids.empty? }.each do |image|
            SpreeShopifyImporter::Importers::ImageImporterJob.perform_later(image.to_json,
                                                                            @shopify_data_feed,
                                                                            @spree_product)
          end
        end

        def shopify_images
          @shopify_images ||= shopify_product.images
        end

        def parser
          @parser ||= SpreeShopifyImporter::DataParsers::Products::BaseData.new(shopify_product)
        end

        def shopify_product
          @shopify_product ||= ShopifyAPI::Product.new(data_feed)
        end
      end
    end
  end
end

module SpreeShopifyImporter
  module DataParsers
    module Variants
      class BaseData
        def initialize(shopify_variant, spree_product)
          @shopify_variant = shopify_variant
          @spree_product = spree_product
        end

        def attributes
          @attributes ||= {
            sku: @shopify_variant.sku.blank? ? "" : @shopify_variant.sku,
            price: @shopify_variant.price,
            compare_at_price: @shopify_variant.compare_at_price,
            weight: @shopify_variant.grams,
            position: @shopify_variant.position,
            product_id: @spree_product.id,
            track_inventory: track_inventory?
          }
        end

        def option_value_ids
          @option_value_ids ||= %w[option1 option2 option3].map { |option_name|
            next unless (option_value = @shopify_variant.send(option_name))

            Spree::OptionValue.find_by!(
              option_type_id: @spree_product.option_type_ids,
              name: option_value.strip.downcase
            ).id
          }.uniq
        end

        def track_inventory?
          @track_inventory ||= @shopify_variant.inventory_management.eql?("shopify")
        end
      end
    end
  end
end

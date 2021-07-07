class AddMainBrandToSpreeProductsTable < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_products, :main_brand, :string, after: :slug
  end
end

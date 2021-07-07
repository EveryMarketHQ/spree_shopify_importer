class AddBrandToSpreeProductsTable < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_products, :brand, :string, after: :slug
  end
end

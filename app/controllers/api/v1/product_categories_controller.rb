require 'openssl'
require 'base64'

class Api::V1::ProductCategoriesController < ApplicationController
  before_action :set_product_category, only: [:show]

  def index
    categories = ProductCategory.all
    encrypted_data = encrypt_data(categories)
    render json: { data: encrypted_data }
  end

  def show
    encrypted_data = encrypt_data(@product_category)
    render json: { data: encrypted_data }
  end

  def create
    category = ProductCategory.new(category_params)
    if category.save
      encrypted_data = encrypt_data(category)
      render json: { data: encrypted_data }, status: :created
    else
      encrypted_error = encrypt_data({ error: category.errors.full_messages })
      render json: { data: encrypted_error }, status: :unprocessable_entity
    end
  end

  private

  def set_product_category
    @product_category = ProductCategory.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    encrypted_error = encrypt_data({ error: "Product category not found" })
    render json: { data: encrypted_error }, status: :not_found
  end

  def category_params
    params.require(:product_category).permit(:name, :description)
  end

  def encrypt_data(data)
    encrypted = AesEncryptionService.encrypt(data)
    encrypted || AesEncryptionService.encrypt({ error: "Encryption failed" }) 
  end
end

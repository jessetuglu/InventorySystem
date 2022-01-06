class ItemController < ApplicationController
  before_action :get_item, :except => [:create, :all]

  def delete_all
    Item.destroy_all
    render status: 200
  end

  def all
    @items = Item.all
    render json: {items: @items}, status: 200
  end

  def get
    return render json: {error: "Could not get item, did you provide an ID?"}, status: 404 unless @item
    render json: {item: @item}, status: 200
  end

  def create
    @item = Item.new(create_params)
    if create_params[:collection_id].present?
      coll = Collection.find_by(id: create_params[:collection_id])
      return render json: {errors: "Could not find collection with id: #{create_params[:collection_id]}"}, status: 422 unless coll
      @item.collection = coll
    end
    return render json: {errors: @item.errors.full_messages}, status: 422 unless @item.save

    render json: {item: @item}, status: 200
  end

  def delete
    return render json: {error: "Could not get item, did you provide an ID?"}, status: 404 unless @item
    return render json: {errors: "Could not destroy item: #{@item.errors.full_messages}"}, status: 400 unless @item.destroy

    render json: {msg: "Item deleted."}, status: 200
  end

  def update
    return render json: {error: "Could not get item, did you provide an ID?"}, status: 404 unless @item

    @item.description = update_params[:description] if update_params[:description].present?
    @item.title = update_params[:title] if update_params[:title].present?
    @item.quantity = update_params[:quantity] if update_params[:quantity].present?

    if update_params[:collection_id].present?
      coll = Collection.find_by(id: update_params[:collection_id])
      return render json: {errors: "Could not find collection with id: #{create_params[:collection_id]}"}, status: 422 unless coll
      @item.collection = coll
    end

    return render json: {errors: "Could not update item: #{@item.errors.full_messages}"}, status: 422 unless @item.save
    render json: {item: @item}, status: 200
  end

  private

  def create_params
    params.require(:item).permit(:title, :description, :quantity, :collection_id)
  end

  def update_params
    params.require(:item).permit(:title, :description, :quantity, :collection_id)
  end

  def get_item
    @item = nil
    @item = Item.find_by(id: params[:id]) if params[:id].present?
  end
end

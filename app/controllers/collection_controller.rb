class CollectionController < ApplicationController
  before_action :get_collection, :except => [:create, :all]

  class InvalidItemID < StandardError
    def initialize(id)
      super("Invalid Item ID: '#{id}'")
    end
  end

  def delete_all
    Collection.destroy_all
    render status: 200
  end

  def all
    @collections = Collection.all
    render json: {collections: @collections}, status: 200
  end

  def get
    return render json: {error: "Could not find collection, did you provide an ID?"}, status: 404 unless @collection
    render json: {collection: @collection}, status: 200
  end

  def add_items
    return render json: {error: "Could not find collection, did you provide an ID?"}, status: 404 unless @collection
    if add_or_del_item_params[:items]
      begin
        add_or_delete_items(add_or_del_item_params[:items], false)
      rescue InvalidItemID => e
        return render json: {error: "#{e.message}"}, status: 422
      end
    end

    return render json: {error: "Could not save collection"}, status: 422 unless @collection.save
    render json: {collection: @collection}, status: 200
  end

  def delete_items
    return render json: {error: "Could not find collection, did you provide an ID?"}, status: 404 unless @collection
    if add_or_del_item_params[:items]
      begin
        add_or_delete_items(add_or_del_item_params[:items], true)
      rescue InvalidItemID => e
        return render json: {error: "#{e.message}"}, status: 422
      end
    end

    return render json: {error: "Could not save collection"}, status: 422 unless @collection.save
    render json: {collection: @collection}, status: 200
  end

  def create
    @collection = Collection.new(create_params)
    return render json: {errors: @collection.errors.full_messages}, status: 422 unless @collection.save

    render json: {collection: @collection}, status: 200
  end

  def delete
    return render json: {error: "Could not get collection."}, status: 404 unless @collection
    return render json: {errors: "Could not destroy collection: #{@collection.errors.full_messages}"}, status: 400 unless @collection.destroy

    render json: {msg: "Collection deleted."}, status: 200
  end

  def update
    return render json: {error: "Could not get collection."}, status: 404 unless @collection

    @collection.name = update_params[:name] if update_params[:name].present?
    return render json: {errors: "Could not update collection: #{@collection.errors.full_messages}"}, status: 422 unless @collection.save
    render json: {item: @collection}, status: 200
  end

  private

  def create_params
    params.require(:collection).permit(:name)
  end

  def update_params
    params.require(:collection).permit(:name)
  end

  def add_or_del_item_params
    params.require(:collection).permit(:id, items: [:id])
  end

  def get_collection
    @collection = nil
    @collection = Collection.find_by(id: params[:collection][:id]) if params[:collection].present?
  end

  def add_or_delete_items(items_in, del = true)
    items_in.each do |it|
      item = Item.find_by(id: it[:id])
      raise InvalidItemID.new(it[:id]) unless item
      if del
        raise InvalidItemID.new(it[:id]) unless @collection.items.include?(item)
        @collection.items.delete(item)
      else
        @collection.items << item
      end
    end
  end
end

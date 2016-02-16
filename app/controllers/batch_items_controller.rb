class BatchItemsController < ApplicationController
  include DcHelper

  before_action :set_batch_item, only: [:show, :edit, :update, :destroy]
  before_action :set_batch
  before_action :collections_for_select, only: [:new, :edit]

  helper_method :sort_column, :sort_direction

  layout 'admin'

  # GET /batch_items
  # GET /batch_items.json
  def index
    @items = BatchItem.where(batch_id: @batch.id).page(params[:page])
  end

  # GET /batch_items/1
  # GET /batch_items/1.json
  def show
  end

  # GET /batch_items/new
  def new
    @item = BatchItem.new
  end

  # GET /batch_items/1/edit
  def edit
  end

  # POST /batch_items
  # POST /batch_items.json
  def create
    @item = BatchItem.new(batch_item_params)
    @item.batch = @batch

    respond_to do |format|
      if @item.save
        format.html { redirect_to batch_batch_item_path(@batch, @item), notice: 'Batch item was successfully created.' }
        format.json { render :show, status: :created, location: @item }
      else
        format.html { render :new }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /batch_items/1
  # PATCH/PUT /batch_items/1.json
  def update
    respond_to do |format|
      if @item.update(batch_item_params)
        format.html { redirect_to batch_batch_item_path(@batch, @item), notice: 'Batch item was successfully updated.' }
        format.json { render :show, status: :ok, location: @item }
      else
        format.html { render :edit }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /batch_items/1
  # DELETE /batch_items/1.json
  def destroy
    @item.destroy
    respond_to do |format|
      format.html { redirect_to batch_batch_items_path(@batch), notice: 'Batch item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_batch_item
      @item = BatchItem.find(params[:id])
    end

    def set_batch
      @batch = Batch.find(params[:batch_id])
    end

    def collections_for_select
      @collections_for_select = Collection.all.collect { |c| [ "#{c.display_title} (#{c.slug})", c.id ] }
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def batch_item_params
      remove_blank_multi_values
      params.require(:batch_item).permit(
          :collection_id,
          :slug,
          :dpla,
          :public,
          :other_collections,
          :date_range,
          :dc_title       => [],
          :dc_format      => [],
          :dc_publisher   => [],
          :dc_identifier  => [],
          :dc_rights      => [],
          :dc_contributor => [],
          :dc_coverage_s  => [],
          :dc_coverage_t  => [],
          :dc_date        => [],
          :dc_source      => [],
          :dc_subject     => [],
          :dc_type        => [],
          :dc_description => [],
          :dc_creator     => [],
          :dc_language    => [],
          :dc_relation    => []
      )
    end

    def remove_blank_multi_values
      dc_fields.each do |f|
        params[:batch_item][f].reject! { |v| v == '' } if params[:batch_item][f]
      end
    end

    def sort_column
      BatchItem.column_names.include?(params[:sort]) ? params[:sort] : 'id'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end

end
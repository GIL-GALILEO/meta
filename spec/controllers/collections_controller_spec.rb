require 'rails_helper'

RSpec.describe Meta::CollectionsController, type: :controller do

  let(:super_admin) {
    Fabricate(:super)
  }

  before(:each) {
    sign_in super_admin
  }

  let(:valid_attributes) {
    {
        slug: 'test-collection-slug',
        dc_title: "Test Collection DC Title\nTest Subtitle",
        display_title: 'Test Collections Display Title',
    }
  }

  let(:invalid_attributes) {
    {
        slug: 'invalid item slug'
    }
  }

  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'assigns all collections as @collections' do
      collection = Collection.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:collections)).to eq([collection])
    end

    it 'assigns collections connected to a admin to @collections' do
      sign_out super_admin # todo
      basic_admin = Fabricate(:basic)
      sign_in basic_admin
      collection1 = Fabricate(:collection)
      collection2 = Fabricate(:collection)
      collection3 = Fabricate(:collection)
      collection4 = Fabricate(:collection)
      repository1 = Fabricate(:repository)
      repository2 = Fabricate(:repository)
      repository3 = Fabricate(:repository)
      repository1.collections << collection1
      repository2.collections << collection2
      repository2.collections << collection4
      repository3.collections << collection3
      basic_admin.repositories << repository1
      basic_admin.collections << collection2
      get :index, {}, valid_session
      expect(assigns(:collections)).to include(collection1, collection2)
      expect(assigns(:collections)).not_to include(collection3, collection4)
    end

  end

  describe 'GET #show' do
    it 'assigns the requested collection as @collection' do
      collection = Collection.create! valid_attributes
      get :show, {:id => collection.to_param}, valid_session
      expect(assigns(:collection)).to eq(collection)
    end
  end

  describe 'GET #new' do
    it 'assigns a new collection as @collection' do
      get :new, {}, valid_session
      expect(assigns(:collection)).to be_a_new(Collection)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested collection as @collection' do
      collection = Collection.create! valid_attributes
      get :edit, {:id => collection.to_param}, valid_session
      expect(assigns(:collection)).to eq(collection)
    end
  end

  describe 'POST #create' do

    context 'basic admin without repository assigned' do
      it 'restricts admin from creating a Collection' do
        sign_out super_admin
        basic_admin = Fabricate(:basic)
        sign_in basic_admin
        post :create, {:collection => valid_attributes}, valid_session
        expect(response).to redirect_to root_url
      end
    end

    context 'basic admin with repository assigned' do
      it 'allows creation of a collection if the admin is assigned to the selected repository' do
        sign_out super_admin
        basic_admin = Fabricate(:basic)
        sign_in basic_admin
        repository = Fabricate(:repository)
        basic_admin.repositories << repository
        collection = Fabricate.build(:collection) { repository repository }
        collection.repository = repository
        post :create, {:collection => collection.as_json}, valid_session
        expect(response).to redirect_to meta_collection_path(assigns(:collection))
      end
    end

    context 'with valid params' do
      it 'creates a new Collection' do
        expect {
          post :create, {:collection => valid_attributes}, valid_session
        }.to change(Collection, :count).by(1)
      end

      it 'assigns a newly created collection as @collection' do
        post :create, {:collection => valid_attributes}, valid_session
        expect(assigns(:collection)).to be_a(Collection)
        expect(assigns(:collection)).to be_persisted
      end

      it 'redirects to the created collection' do
        post :create, {:collection => valid_attributes}, valid_session
        expect(response).to redirect_to(meta_collection_path(Collection.last))
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved collection as @collection' do
        post :create, {:collection => invalid_attributes}, valid_session
        expect(assigns(:collection)).to be_a_new(Collection)
      end

      it 're-renders the "new" template' do
        post :create, {:collection => invalid_attributes}, valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        {
            dc_title: "Updated Test DC Title\nNew Subtitle"
        }
      }

      it 'fails if admin is not assigned the collection or collection repository' do
        sign_out super_admin
        basic_admin = Fabricate(:basic)
        sign_in basic_admin
        collection = Collection.create! valid_attributes
        put :update, {:id => collection.id, :collection => new_attributes}, valid_session
        collection.reload
        expect(response).to redirect_to root_url
      end

      it 'allows basic admin to update a collection if collection is assigned' do
        sign_out super_admin
        basic_admin = Fabricate(:basic)
        sign_in basic_admin
        collection = Fabricate(:collection)
        basic_admin.collections << collection
        put :update, {:id => collection.id, :collection => new_attributes}, valid_session
        collection.reload
        a = collection
        b = assigns(:collection)
        expect(assigns(:collection).dc_title).to include 'New Subtitle'
      end

      it 'allows basic admin to update a collection if parent repository is assigned' do
        sign_out super_admin
        basic_admin = Fabricate(:basic)
        sign_in basic_admin
        repository = Fabricate(:repository)
        basic_admin.repositories << repository
        collection = Fabricate(:collection) { repository repository }
        collection.repository = repository
        put :update, {:id => collection.id, :collection => new_attributes}, valid_session
        collection.reload
        expect(assigns(:collection).dc_title).to include 'New Subtitle'
      end

      it 'updates the requested collection' do
        collection = Collection.create! valid_attributes
        put :update, {:id => collection.id, :collection => new_attributes}, valid_session
        collection.reload
        expect(assigns(:collection).dc_title).to include 'New Subtitle'
      end

      it 'assigns the requested collection as @collection' do
        collection = Collection.create! valid_attributes
        put :update, {:id => collection.id, :collection => new_attributes}, valid_session
        expect(assigns(:collection)).to eq(collection)
      end

      it 'redirects to the collection' do
        collection = Collection.create! valid_attributes
        put :update, {:id => collection.id, :collection => new_attributes}, valid_session
        expect(response).to redirect_to(meta_collection_path(collection))
      end
    end

    context 'with invalid params' do
      it 'assigns the collection as @collection' do
        collection = Collection.create! valid_attributes
        put :update, {:id => collection.to_param, :collection => invalid_attributes}, valid_session
        expect(assigns(:collection)).to eq(collection)
      end

      it 're-renders the "edit" template' do
        collection = Collection.create! valid_attributes
        put :update, {:id => collection.to_param, :collection => invalid_attributes}, valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested collection' do
      collection = Collection.create! valid_attributes
      expect {
        delete :destroy, {:id => collection.to_param}, valid_session
      }.to change(Collection, :count).by(-1)
    end

    it 'redirects to the collections list' do
      collection = Collection.create! valid_attributes
      delete :destroy, {:id => collection.to_param}, valid_session
      expect(response).to redirect_to(meta_collections_url)
    end
  end

end

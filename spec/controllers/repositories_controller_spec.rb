require 'rails_helper'

RSpec.describe RepositoriesController, type: :controller do

  let(:super_user) { Fabricate(:super) }

  before(:each) { sign_in super_user }

  let(:valid_attributes) do
    {
      slug: 'test-controller-slug',
      title: 'Test Controller Title',
      coordinates: '31.978987, -81.161760'
    }
  end

  let(:invalid_attributes) do
    { slug: 'invalid collection slug' }
  end

  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'assigns all repositories as @repositories' do
      repository = Repository.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:repositories)).to eq([repository])
    end

    it 'assigns a repository connected to a admin to @repositories' do
      sign_out super_user # todo
      basic_user = Fabricate(:basic)
      sign_in basic_user
      repository1 = Fabricate(:repository)
      repository2 = Fabricate(:repository)
      basic_user.repositories << repository1
      get :index, {}, valid_session
      expect(assigns(:repositories)).to include(repository1)
      expect(assigns(:repositories)).not_to include(repository2)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested repository as @repository' do
      repository = Repository.create! valid_attributes
      get :show, {id: repository.id }, valid_session
      expect(assigns(:repository)).to eq(repository)
    end
  end

  describe 'GET #new' do
    it 'assigns a new repository as @repository' do
      get :new, {}, valid_session
      expect(assigns(:repository)).to be_a_new(Repository)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested repository as @repository' do
      repository = Repository.create! valid_attributes
      get :edit, { id: repository.id }, valid_session
      expect(assigns(:repository)).to eq(repository)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Repository' do
        expect {
          post :create, { repository: valid_attributes }, valid_session
        }.to change(Repository, :count).by(1)
      end

      it 'assigns a newly created repository as @repository' do
        post :create, { repository: valid_attributes }, valid_session
        expect(assigns(:repository)).to be_a(Repository)
        expect(assigns(:repository)).to be_persisted
      end

      it 'redirects to the created repository' do
        post :create, { repository: valid_attributes}, valid_session
        expect(response).to redirect_to(repository_path(Repository.last))
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved repository as @repository' do
        post :create, { repository: invalid_attributes }, valid_session
        expect(assigns(:repository)).to be_a_new(Repository)
      end

      it 're-renders the "new" template' do
        post :create, { repository: invalid_attributes }, valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        { title: 'Updated Title' }
      end

      it 'updates the requested repository' do
        repository = Repository.create! valid_attributes
        put :update, { id: repository.id, repository: new_attributes }, valid_session
        repository.reload
        expect(assigns(:repository).title).to eq 'Updated Title'
      end

      it 'assigns the requested repository as @repository' do
        repository = Repository.create! valid_attributes
        put :update, { id: repository.id, repository: valid_attributes }, valid_session
        expect(assigns(:repository)).to eq(repository)
      end

      it 'redirects to the repository' do
        repository = Repository.create! valid_attributes
        put :update, { id: repository.id, repository: valid_attributes }, valid_session
        expect(response).to redirect_to(repository_path(repository))
      end
    end

    context 'with invalid params' do
      it 'assigns the repository as @repository' do
        repository = Repository.create! valid_attributes
        put :update, { id: repository.id, repository: invalid_attributes }, valid_session
        expect(assigns(:repository)).to eq(repository)
      end

      it 're-renders the "edit" template' do
        repository = Repository.create! valid_attributes
        put :update, { id: repository.id, repository: invalid_attributes }, valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested repository' do
      repository = Repository.create! valid_attributes
      expect {
        delete :destroy, { id: repository.id }, valid_session
      }.to change(Repository, :count).by(-1)
    end

    it 'redirects to the repositories list' do
      repository = Repository.create! valid_attributes
      delete :destroy, { id: repository.id }, valid_session
      expect(response).to redirect_to(repositories_url)
    end
  end

end

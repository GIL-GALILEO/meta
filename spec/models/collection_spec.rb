require 'rails_helper'

RSpec.describe Collection, type: :model do

  it 'has none to begin with' do
    expect(Collection.count).to eq 0
  end
  
  it 'has one after adding one' do
    Fabricate(:collection)
    expect(Collection.count).to eq 1
  end

  # duh
  it 'belongs to a Repository' do
    r = Fabricate(:repository) {
      collections(count: 1)
    }
    expect(r.collections.first.repository).to be_kind_of Repository
  end

  it 'has a record_id that tracks changes to repository' do
    c = Fabricate :collection
    expect(c.record_id.include? c.slug).to be_truthy
    r = Fabricate :repository
    c.repository = r
    c.save
    expect(c.record_id.include? r.slug).to be_truthy
  end
  
  it 'has a title' do
    c = Fabricate(:collection)
    expect(c.display_title).not_to be_empty
  end
  
  it 'has a slug' do
    c = Fabricate(:collection)
    expect(c.slug).not_to be_empty
  end
  
  it 'contains Items' do
    c = Fabricate(:collection) {
      items(count: 1)
    }
    expect(c.items.first).to be_kind_of Item
  end

  it 'respond to Public Items' do
    expect(Fabricate(:collection)).to respond_to :dpla_items
  end

  it 'respond to DPLA Items' do
    expect(Fabricate(:collection)).to respond_to :public_items
  end

  it 'can have associated Subjects' do
    c = Fabricate(:collection) {
      subjects(count: 1)
    }
    expect(c).to respond_to 'subjects'
    expect(c.subjects.first).to be_a Subject
  end

  it 'can have associated Time Periods' do
    c = Fabricate(:collection) {
      time_periods(count: 1)
    }
    expect(c).to respond_to 'subjects'
    expect(c.time_periods.first).to be_a TimePeriod
  end

  it 'has an array of Portals' do

    c = Fabricate :collection
    p = Fabricate :portal

    c.portals << p

    expect(c.portals.first).to be_a Portal

  end

  it 'prevents items with other_collection arrays containing a collection id from persisting after a collection is destroyed' do
    c = Fabricate(:collection)
    i = Fabricate(:item)
    i.other_collections << c.id.to_s
    i.save
    c.destroy
    i.reload
    expect(i.other_collections).to be_empty
  end

  context 'portal removal behavior' do

    before :each do

      @collection = Fabricate :collection
      @portal = Fabricate :portal
      @portal2 = Fabricate :portal

    end

    it 'should be unassigned from a portal if its repository is unassigned from that portal' do

      r = @collection.repository

      r.portals << @portal
      @collection.portals << @portal
      @collection.portals << @portal2

      @collection.reload

      expect(r.portals).to include @portal
      expect(@collection.portals).to include @portal
      expect(@collection.portals).to include @portal2

      r.portals = []

      expect(r.portals).not_to include @portal
      expect(@collection.portals).not_to include @portal
      expect(@collection.portals).to include @portal2

    end

  end

  context 'public_display? behavior' do

    context 'non-public repository' do
      before :each do
        @collection = Fabricate :collection
        @collection.public = true
        @collection.save
      end

      it 'collection should return false for public_display?' do
        expect(@collection.public?).to eq true
        expect(Repository.last.public?).to eq false
        expect(@collection.display?).to be false
      end
    end

  end

end

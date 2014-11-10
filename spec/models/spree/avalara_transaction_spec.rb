require 'spec_helper'

describe Spree::AvalaraTransaction, :type => :model do

  it { should belong_to :order }
  it { should belong_to :return_authorization }
  # it { should have_one :adjustment }
  it { should validate_presence_of :order }
  it { should have_db_index :order_id }

  before :each do
    MyConfigPreferences.set_preferences
    stock_location = FactoryGirl.create(:stock_location)
    @order = FactoryGirl.create(:order)
    line_item = FactoryGirl.create(:line_item)
    line_item.tax_category.update_attributes(name: "Clothing", description: "PC030000")
    @order.line_items << line_item
  end

  describe "rnt_tax" do
    it "should return @myrnttax variable" do
      @order.avalara_lookup
      expect(@order.avalara_transaction.rnt_tax).to eq(@rnt_tax)
    end
  end
  describe "amount" do
    it "should return @myrnttax variable" do
      @order.avalara_lookup
      expect(@order.avalara_transaction.amount).to eq(@rnt_tax)
    end
  end
  describe "lookup_avatax" do
    it "should look up avatax" do
      @order.avalara_capture
      expect(@order.avalara_transaction.lookup_avatax).to eq("0.4")
    end
  end

  describe "commit_avatax" do
    it "should commit avatax" do
      @order.avalara_capture
      expect(@order.avalara_transaction.commit_avatax(@order.line_items, @order)).to eq("0.4")
    end
  end

  describe "commit_avatax_final" do
    it "should commit avatax final" do
      @order.avalara_capture
      expect(@order.avalara_transaction.commit_avatax_final(@order.line_items, @order, @order.number.to_s + ":" + @order.id.to_s, @order.completed_at)).to eq("0.4")
    end
  end
end

require "spec_helper"

describe FavouritesController do
  include Devise::TestHelpers
  render_views
  let(:question) { Factory.create :question2 }
  
  describe "Any User" do
    let(:user) { Factory.create(:endless_user) }
    describe "with one favourited question" do
      it "shows the user's favourites page" do
        Factory.create(:favourite, :user => user, :question => question)
        get :index, :user_id => user.id
        assigns(:questions).first.should eq(question)
        response.should render_template("users/favourites")
        response.should be_success
      end
    end
    
  end
  
  describe "An authorized user" do
    before do
      sign_in question.user
    end
    
    context "with Javascript disabled " do
      describe "adds a question to his favourites" do
        it "should work" do
          post :toggle, :id => question.id
          assigns(:favourite).should eq(Favourite.last)
          response.should redirect_to(:controller => "questions", :action => "show", :id => question.id, :friendly_id => question.friendly_id)
        end
      end
      describe "removes a question from his favourites" do
        it "should work" do
          Factory.create(:favourite, :user => question.user, :question => question)
          post :toggle, :id => question.id
          question.favourites.should be_empty
          response.should redirect_to(:controller => "questions", :action => "show", :id => question.id, :friendly_id => question.friendly_id)
        end
      end
    end
    
    context "with Javascript enabled " do
      describe "adds a question to his favourites" do
        it "should work" do
          xhr :post, :toggle, :id => question.id
          assigns(:favourite).should eq(Favourite.last)
          response.should be_success
          response.should render_template("toggle")
        end
      end
      describe "removes a question from his favourites" do
        it "should work" do
          Factory.create(:favourite, :user => question.user, :question => question)
          xhr :post, :toggle, :id => question.id
          question.favourites.should be_empty
          response.should be_success
          response.should render_template("toggle")
        end
      end
    end
  end
end
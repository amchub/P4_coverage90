require 'spec_helper'

describe MoviesController do
  describe 'search movies by director' do

    it 'should call find_by_id' do
      m=mock('Movie')
      m.stub(:director).and_return('George Lucas')
      #Movie.stub(:find_all_by_director)
      Movie.should_receive(:find_by_id).with('1').and_return(m)
      get :search_same_director_movies, {:search_terms => '1'}
    end

    it 'should call movie.director' do
      m=mock('Movie')
      Movie.stub(:find_by_id).and_return(m)
      m.should_receive(:director).and_return('George Lucas')
      get :search_same_director_movies, {:search_terms => '1'}
    end

    it 'should call find_all_by_director' do
      m=mock('Movie')
      Movie.stub(:find_by_id).and_return(m)
      m.stub(:director).and_return('George Lucas')
      Movie.should_receive(:find_all_by_director).with('George Lucas')
      get :search_same_director_movies, {:search_terms => '1'}
    end

    it 'should assign find_all_by_director results to an instance variable' do
      m=mock('Movie')
      fake_results = [mock('Movie'),mock('Movie')]
      Movie.stub(:find_by_id).and_return(m)
      m.stub(:director).and_return('George Lucas')
      Movie.stub(:find_all_by_director).and_return(fake_results)  
      get :search_same_director_movies, {:search_terms => '1'}
      assigns(:movies).should == fake_results
    end

    it 'should select the same director search results template for rendering' do
      m=mock('Movie')
      #fake_results = [mock('Movie'),mock('Movie')]
      Movie.stub(:find_by_id).and_return(m)
      m.stub(:director).and_return('George Lucas')
      Movie.stub(:find_all_by_director)#.and_return(fake_results) 
      get :search_same_director_movies, {:search_terms => '1'}
      response.should render_template('search_same_director_movies') 
    end

    it 'should show a flash message with empty string' do
      m=mock('Movie', :title => 'Star Wars')
      #fake_results = [mock('Movie'),mock('Movie')]
      Movie.stub(:find_by_id).and_return(m)
      m.stub(:director).and_return('')
      #Movie.stub(:find_all_by_director).and_return(fake_results) 
      get :search_same_director_movies, {:search_terms => '1'}
      flash[:notice].should match(/'(.*)' has no director info/) 
    end

    it 'should show a flash message with nil' do
      m=mock('Movie', :title => 'Star Wars')
      #fake_results = [mock('Movie'),mock('Movie')]
      Movie.stub(:find_by_id).and_return(m)
      m.stub(:director).and_return(nil)
      #Movie.stub(:find_all_by_director).and_return(fake_results) 
      get :search_same_director_movies, {:search_terms => '1'}
      flash[:notice].should match(/'(.*)' has no director info/) 
    end

    it 'should redirect to movies_path with empty string' do
      m=mock('Movie', :title => 'Star Wars')
      #fake_results = [mock('Movie'),mock('Movie')]
      Movie.stub(:find_by_id).and_return(m)
      m.stub(:director).and_return('')
      #Movie.stub(:find_all_by_director).and_return(fake_results) 
      get :search_same_director_movies, {:search_terms => '1'}
      response.should redirect_to(:controller => 'movies', :action => 'index')
    end
  end
  
#############################################################################
  
  describe 'search in tmdb' do

    it 'should call the model method that performs TMDb search' do
      Movie.should_receive(:find_in_tmdb).with('hardware')
      post :search_tmdb, {:search_terms => 'hardware'}
    end

    it 'should select the Search Results template for rendering' do
      Movie.stub(:find_in_tmdb)
      post :search_tmdb, {:search_terms => 'hardware'}
      response.should render_template('search_tmdb')
    end

    it 'should make the TMDb search results available to that template' do
      fake_results = [mock('Movie'), mock('Movie')]
      Movie.stub(:find_in_tmdb).and_return(fake_results)
      post :search_tmdb, {:search_terms => 'hardware'}
      # look for controller method to assign @movies
      assigns(:movie).should == fake_results
    end

#############################################################################

    it 'should appear a flash message if the movie does not exist' do
      Movie.stub(:find_in_tmdb).and_return([])
      post :search_tmdb, {:search_terms => 'Movie That Does Not Exist'}
      flash[:notice].should match(/'(.*)' was not found in TMDb./)
    end

    it 'should redirect to the index if the movie does not exist' do
      Movie.stub(:find_in_tmdb).and_return([])
      post :search_tmdb, {:search_terms => 'Movie That Does Not Exist'}
      response.should redirect_to(:controller => 'movies', :action => 'index')
    end

#############################################################################

    it 'should appear a flash message when raise an api key exception' do
      Movie.stub(:find_in_tmdb).and_raise(Movie::InvalidKeyError)
      post :search_tmdb, {:search_terms => 'Fight Club'}
      flash[:notice].should match(/^Search not available$/)
    end

    it 'should redirect to the index when raise an api key exception' do
      Movie.stub(:find_in_tmdb).and_raise(Movie::InvalidKeyError)
      post :search_tmdb, {:search_terms => 'Fight Club'}
      response.should redirect_to(:controller => 'movies', :action => 'index')
    end
  end

#############################################################################

  describe 'show method' do  
    
    it 'should call find' do
      Movie.should_receive(:find).with('id')
      get :show, {:id => 'id'}
    end
    
    it 'should assign find results to an instance variable' do
      fake_results = mock('Movie')
      Movie.stub(:find).and_return(fake_results)
      get :show, {:id => 'id'}
      assigns(:movie).should == fake_results
    end
    
    it 'should select the show template for rendering' do
      fake_results = mock('Movie')
      Movie.stub(:find).and_return(fake_results)
      get :show, {:id => 'id'}
      response.should render_template('show')
    end
  end
      
#############################################################################
  
  describe 'index method' do
  
    it 'should call all_ratings' do
      m= mock('Movie')
      Movie.should_receive(:find_all_by_rating)
      get :index, {:id => 'id'}
    end
    
    it 'should assign find_all_by_rating results to an instance variable' do
      fake_results = mock('Movie')
      Movie.stub(:find_all_by_rating).and_return(fake_results)
      get :index, {:id => 'id'}
      assigns(:movies).should == fake_results
    end    
    
    it 'should select the index template for rendering' do
      fake_results= mock('Movie')
      Movie.stub(:find_all_by_rating).and_return(fake_results)
      get :index, {:id => 'id'}
      response.should render_template('index')
    end    
    it 'should assign hilite to an instance variable 1' do
      get :index, {:id => 'id', :sort => 'title'}
      assigns(:title_header).should == 'hilite'
    end
    it 'should assign hilite to an instance variable 2' do
      get :index, {:id => 'id', :sort => 'release_date'}
      assigns(:date_header).should == 'hilite'
    end
  end
 
#############################################################################
  
  describe 'new method' do
    it 'should select the new template for rendering' do
      get :new
      response.should render_template('new')
    end
  end

#############################################################################
  
  describe 'create method' do
  
    it 'should call Movie.create!' do
      fake_results= mock('Movie', :title => 'Fight Club')
      Movie.should_receive(:create!).with('m').and_return(fake_results)
      get :create, {:movie => 'm'}
    end
    
    it 'should assign Movie.create! results to an instance variable' do
      fake_results= mock('Movie', :title => 'Fight Club')
      Movie.stub(:create!).and_return(fake_results)
      get :create, {:movie => fake_results}
      assigns(:movie).should == fake_results
    end
    
    it 'should redirect to index_path' do
      fake_results= mock('Movie', :title => 'Fight Club')
      Movie.stub(:create!).and_return(fake_results)
      get :create, {:movie => fake_results}
      response.should redirect_to(:controller => 'movies', :action => 'index') 
    end
    
    it 'should show a flash message' do
      fake_results= mock('Movie', :title => 'Fight Club')
      Movie.stub(:create!).and_return(fake_results)
      get :create, {:movie => fake_results}      
      flash[:notice].should match(/^(.*) was successfully created.$/) 
    end
  end
  
#############################################################################
  
  describe 'edit method' do
  
    it 'should call Movie.find' do
      Movie.should_receive(:find).with('id')
      get :edit, {:id => 'id'}
    end
    
    it 'should assign Movie.find results to an instance variable' do
      fake_results = mock('Movie')
      Movie.should_receive(:find).and_return(fake_results)
      get :edit, {:id => 'id'}
      assigns(:movie).should == fake_results
    end  
    
  end
  
#############################################################################

  describe 'update' do
  
    it 'should call Movie.find' do
      m = mock('Movie', :title => 'Fight Club')
      Movie.should_receive(:find).with('id').and_return(m)
      m.stub(:update_attributes!)
      put :update, {:id => 'id', :movie => 'm'}
    end
    
    it 'should call @movie.update_attributes!' do
      m = mock('Movie', :title => 'Fight Club')
      Movie.stub(:find).and_return(m)
      m.should_receive(:update_attributes!)
      put :update, {:id => 'id', :movie => 'm'}
    end
    
    it 'should assign Movie.find results to an instance variable' do
      m = mock('Movie', :title => 'Fight Club')
      Movie.stub(:find).and_return(m)
      m.stub(:update_attributes!)
      put :update, {:id => 'id', :movie => 'm'}
      assigns(:movie).should == m
    end
    
    it 'should redirect to the show view' do
      m = mock('Movie', :title => 'Fight Club')
      Movie.stub(:find).and_return(m)
      m.stub(:update_attributes!)
      put :update, {:id => 'id', :movie => 'm'}
      response.should redirect_to(:controller => 'movies', :action => 'show', :id => m)
    end
        
    it 'should show a flash message' do
      m = mock('Movie', :title => 'Fight Club')
      Movie.stub(:find).and_return(m)
      m.stub(:update_attributes!)
      put :update, {:id => 'id', :movie => 'm'}
      flash[:notice].should match(/^(.*) was successfully updated.$/) 
    end
  end
  
#############################################################################
  
  describe 'destroy' do
  
    it 'should call Movie.find' do
      m = mock('Movie', :title => 'Fight Club')
      Movie.should_receive(:find).with('id').and_return(m)
      m.stub(:destroy)
      delete :destroy , {:id => 'id'}
    end
    
    it 'should call @movie.destroy' do
      m = mock('Movie', :title => 'Fight Club')
      Movie.stub(:find).and_return(m)
      m.should_receive(:destroy)
      delete :destroy , {:id => 'id'}
    end

    it 'should redirect to index_path' do
      m = mock('Movie', :title => 'Fight Club')
      Movie.stub(:find).and_return(m)
      m.stub(:destroy)
      delete :destroy , {:id => 'id'}
      response.should redirect_to(:controller => 'movies', :action => 'index')
    end
    
    it 'should show a flash message' do
      m = mock('Movie', :title => 'Fight Club')
      Movie.stub(:find).and_return(m)
      m.stub(:destroy)
      delete :destroy , {:id => 'id'}
      flash[:notice].should match(/^Movie '(.*)' deleted.$/)
    end
  end
  
end



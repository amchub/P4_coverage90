class Movie < ActiveRecord::Base

  class Movie::InvalidKeyError < StandardError ; end

  def self.api_key
    #'01234567890123456789012345678901' # API key de Tmdb inválida
    'ffeb25e4939ba203b3dd7d5e3a57ad61' # API key de Tmdb válida
  end


  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end

  def self.find_in_tmdb(string)
    Tmdb.api_key = self.api_key
    begin
      TmdbMovie.find(:title => string, :limit => 1)

    rescue ArgumentError => tmdb_error
      raise Movie::InvalidKeyError, tmdb_error.message

    rescue RuntimeError => tmdb_error
      if tmdb_error.message =~ /status code '404'/
        raise Movie::InvalidKeyError, tmdb_error.message
      else
        raise RuntimeError, tmdb_error.message
      end

    end
  end

end

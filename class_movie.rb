class Movie

  attr_reader :id, :title, :year, :rating, :genre, :studio

  def self.all_with_ordering(order)
    if order == "year"
      self.all(sql_string_year)
    elsif order == "rating"
      self.all(sql_string_rating)
    else
      self.all(sql_string)
    end
  end

  def self.get_by_movie_id(movie_id)
    movie = Movie.new
    string = sql_string
    string << " WHERE movies.id = ($1)"
    db_connection do |conn|
      movie = conn.exec_params(string, [movie_id])
    end
    movie = Movie.new(movie[0])
    movie
  end

  def initialize (args = {})
    @id = args["id"].to_i
    @title = args["movie"]
    @year = args["year"].to_i
    if args["rating"]
      @rating = args["rating"].to_i
    else
      @rating = "NO RATING"
    end
    @genre = args["genre"]
    if args["studio"]
      @studio = args["studio"]
    else
      @studio = "NO STUDIO"
    end
  end

  private

  def self.sql_string
    string = "SELECT movies.id, movies.title AS movie, movies.year, movies.rating, "
    string << "genres.name AS genre, studios.name AS studio "
    string << "FROM movies "
    string << "LEFT OUTER JOIN genres ON movies.genre_id = genres.id "
    string << "LEFT OUTER JOIN studios ON movies.studio_id = studios.id"
  end

  def self.sql_string_year
    sql_string << " ORDER BY movies.year"
  end

  def self.sql_string_rating
    sql_string << " ORDER BY movies.rating DESC NULLS LAST"
  end

  def self.all(string)
    movies = []
    db_connection do |conn|
      movies = conn.exec_params(string)
    end
    movies = movies.to_a.map {|movie| Movie.new(movie)}
    movies
  end

end

class Movie

  attr_reader :id, :title, :year, :rating, :genre, :studio

  def self.all_by_title
    movies = self.all
    movies.sort_by {|movie| movie.title}
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

  private

  def self.all
    movies = []
    db_connection do |conn|
      movies = conn.exec_params(sql_string)
    end
    movies = movies.to_a.map {|movie| Movie.new(movie)}
    movies
  end

end
